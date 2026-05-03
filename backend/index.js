require("dotenv").config();
const express = require("express");
const admin = require("firebase-admin");
const { GoogleGenerativeAI } = require("@google/generative-ai");

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 8080;

// 1. Initialize Firebase Admin
try {
    if (process.env.FIREBASE_SERVICE_ACCOUNT) {
        const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);

        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
            projectId: process.env.FIREBASE_PROJECT_ID,
        });
    } else {
        admin.initializeApp({
            projectId: process.env.FIREBASE_PROJECT_ID,
        });
    }

    console.log("✅ Firebase Admin initialized");
} catch (error) {
    console.error("❌ Firebase initialization failed:", error.message);
    process.exit(1);
}

const db = admin.firestore();

// 2. Initialize Gemini AI
if (!process.env.GEMINI_API_KEY) {
    console.error("❌ Missing GEMINI_API_KEY");
    process.exit(1);
}
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({
    model: "gemini-3.1-pro-preview",
    generationConfig: { responseMimeType: "application/json" },
});

// 3. AI Triage Logic
async function performTriage(alertData) {
    console.log(`🤖 Triaging Alert: ${alertData.id}`);
    
    const prompt = `
      You are the NEXUS Crisis Intelligence Brain for a luxury hotel. 
      Analyze the following sensor data or manual alert trigger:
      
      Source: ${alertData.trigger_source || "Unknown"}
      Location: ${alertData.location || "Unknown"}
      Title: ${alertData.title || "Emergency"}
      Description: ${alertData.description || "No description provided"}
      Raw Data: ${JSON.stringify(alertData)}

      Return a structured JSON response with these exact keys:
      - crisis_class: (e.g., "Fire", "Medical Emergency", "Intruder", "Flood", "Gas Leak")
      - severity: (e.g., "Critical", "High", "Medium", "Low")
      - recommended_action: (A short system-level instruction, max 10 words)
      - instructions_for_staff: (Clear, numbered steps for hotel staff)
      - evacuate_floor: (Boolean: true/false)
      - notify_emergency_services: (Boolean: true/false)
      - iptv_broadcast: (A message to be displayed on guest room TVs)
    `;

    try {
        const result = await model.generateContent(prompt);
        const responseText = result.response.text();
        const intelligence = JSON.parse(responseText);

        return {
            ...intelligence,
            triage_status: "completed",
            triaged_at: admin.firestore.FieldValue.serverTimestamp(),
        };
    } catch (error) {
        console.error("⚠️ Gemini Triage Failed:", error.message);
        return {
            crisis_class: "manual_review_required",
            severity: "medium",
            recommended_action: "Dispatch nearest staff immediately",
            instructions_for_staff: "Gemini unavailable. Follow manual emergency SOP. Check source sensors manually.",
            evacuate_floor: false,
            notify_emergency_services: true,
            iptv_broadcast: "Nexus System: Emergency alert detected. Staff is investigating.",
            triage_status: "failed",
            error_log: error.message,
            triaged_at: admin.firestore.FieldValue.serverTimestamp(),
        };
    }
}

// 4. AI Summary Logic
async function performSummary(alertData, auditLogs) {
    console.log(`📝 Generating Summary for Alert: ${alertData.id}`);
    
    const logsText = auditLogs.map(log => 
        `[${log.timestamp}] ${log.action}: ${log.details}`
    ).join("\n");

    const prompt = `
      You are the NEXUS Crisis Intelligence Brain. 
      Generate a professional After-Action Report (AAR) for this resolved incident.
      
      Incident: ${alertData.title}
      Location: ${alertData.location}
      Timeline:
      ${logsText}

      Return a JSON with:
      - summary: (2-3 sentence summary)
      - timeline_highlights: (List of 3 moments)
      - response_assessment: (Assessment of effectiveness)
      - recommendations: (Future measures)
    `;

    try {
        const result = await model.generateContent(prompt);
        const summaryData = JSON.parse(result.response.text());
        
        const formattedReport = `
# AI AFTER-ACTION REPORT
## Summary
${summaryData.summary}
## Highlights
${summaryData.timeline_highlights.map(h => `- ${h}`).join("\n")}
## Assessment
${summaryData.response_assessment}
        `.trim();

        return {
            ai_summary_formatted: formattedReport,
            summary_generated_at: admin.firestore.FieldValue.serverTimestamp(),
        };
    } catch (error) {
        console.error("⚠️ Gemini Summary Failed:", error.message);
        return {
            ai_summary_formatted: "AI Synthesis failed. Refer to raw logs.",
            summary_status: "failed",
        };
    }
}

// 5. REST Endpoints
app.post("/triage", async (req, res) => {
    const alertData = req.body;
    if (!alertData.id) return res.status(400).send("Missing alert ID");
    
    const result = await performTriage(alertData);
    await db.collection("alerts").doc(alertData.id).update(result);
    res.json(result);
});

// 6. Real-time Firestore Listener (Replaces Cloud Functions)
// This ensures that when a document is created in Firestore, the backend 
// picks it up automatically without needing the app to call an endpoint.
db.collection("alerts").onSnapshot((snapshot) => {
    snapshot.docChanges().forEach(async (change) => {
        const data = change.doc.data();
        const id = change.doc.id;

        if (change.type === "added" && !data.triage_status) {
            const result = await performTriage({ id, ...data });
            await db.collection("alerts").doc(id).update(result);
        }

        if (change.type === "modified" && data.escalationStatus === "RESOLVED" && !data.ai_summary_formatted) {
            // Fetch logs for summary
            const logsSnap = await db.collection("alerts").doc(id).collection("audit_logs").orderBy("timestamp").get();
            const logs = logsSnap.docs.map(d => d.data());
            const summary = await performSummary({ id, ...data }, logs);
            await db.collection("alerts").doc(id).update(summary);
        }
    });
});

app.listen(PORT, () => {
    console.log(`🚀 NEXUS Railway Backend running on port ${PORT}`);
});
