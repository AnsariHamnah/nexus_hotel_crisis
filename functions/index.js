const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const logger = require("firebase-functions/logger");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

// Initialize Firebase Admin
initializeApp();
const db = getFirestore();

// Import AI Logic
const { performTriage } = require("./geminiTriage");
const { generateSummary } = require("./geminiSummary");

/**
 * onAlertCreated
 * Triggers when a new document is created in the /alerts collection.
 * Uses Gemini AI to classify the crisis and provide actionable intelligence.
 */
exports.onAlertCreated = onDocumentCreated("alerts/{alertId}", async (event) => {
    const alertId = event.params.alertId;
    const alertData = event.data.data();

    if (alertData.triage_status === "completed" || alertData.triage_status === "failed") {
        logger.info(`Alert ${alertId} already triaged, skipping.`);
        return;
    }

    try {
        const triageResult = await performTriage({ id: alertId, ...alertData });

        const updateData = {
            ...triageResult,
            triaged_at: FieldValue.serverTimestamp(),
        };

        await db.collection("alerts").doc(alertId).update(updateData);
        logger.info(`Successfully triaged alert: ${alertId}`);

    } catch (error) {
        logger.error(`Critical error in onAlertCreated for ${alertId}:`, error);
    }
});

/**
 * onAlertUpdated
 * Triggers when an alert is resolved to generate the After-Action Report.
 */
exports.onAlertUpdated = onDocumentUpdated("alerts/{alertId}", async (event) => {
    const alertId = event.params.alertId;
    const beforeData = event.data.before.data();
    const afterData = event.data.after.data();

    // Only trigger when status changes to RESOLVED
    if (beforeData.escalationStatus !== "RESOLVED" && afterData.escalationStatus === "RESOLVED") {
        logger.info(`Alert ${alertId} resolved. Generating AI summary...`);

        try {
            // 1. Fetch audit logs for this alert
            const logsSnapshot = await db.collection("alerts").doc(alertId).collection("audit_logs")
                .orderBy("timestamp", "asc")
                .get();
            
            const logs = logsSnapshot.docs.map(doc => ({
                id: doc.id,
                ...doc.data(),
                timestamp: doc.data().timestamp?.toDate().toISOString() || "N/A"
            }));

            // 2. Generate Summary
            const summaryResult = await generateSummary(afterData, logs);

            // 3. Update the alert with the summary
            await db.collection("alerts").doc(alertId).update(summaryResult);
            
            // 4. Also post a summary entry to global audit logs for visibility
            await db.collection("audit_logs_global").add({
                action: "AI_SUMMARY_GENERATED",
                details: `AI After-Action Report generated for incident ${alertId}`,
                performedBy: "GEMINI_AI",
                timestamp: FieldValue.serverTimestamp(),
            });

            logger.info(`Successfully generated AI summary for alert: ${alertId}`);

        } catch (error) {
            logger.error(`Error generating summary for ${alertId}:`, error);
        }
    }
});
