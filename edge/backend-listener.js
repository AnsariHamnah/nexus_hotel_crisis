require("dotenv").config();
const admin = require("firebase-admin");
const { GoogleGenerativeAI } = require("@google/generative-ai");

/**
 * NEXUS - Local Crisis Intelligence Listener
 * This script replaces Firebase Cloud Functions for users on the Spark (Free) plan.
 * It listens to Firestore in real-time and processes new alerts using Gemini AI.
 */

// 1. Initialize Firebase Admin
// Make sure to have GOOGLE_APPLICATION_CREDENTIALS env var pointing to your service account JSON
try {
  admin.initializeApp();
  console.log("Firebase Admin initialized successfully");
} catch (error) {
  console.error("Firebase initialization failed:", error);
  process.exit(1);
}
const db = admin.firestore();
console.log("Connected to Firestore successfully");

// 2. Initialize Gemini AI
if (!process.env.GEMINI_API_KEY) {
  console.error("FATAL ERROR: Missing GEMINI_API_KEY in .env file");
  process.exit(1);
}

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

const model = genAI.getGenerativeModel({
  model: "gemini-2.5-flash",
  generationConfig: {
    responseMimeType: "application/json",
  },
});

console.log("🚀 NEXUS Edge Intelligence Backend is starting...");

// 3. Real-time Firestore Listener
const alertsRef = db.collection("alerts");

alertsRef.onSnapshot((snapshot) => {
  snapshot.docChanges().forEach(async (change) => {
    // Only process NEWLY CREATED documents
    if (change.type === "added") {
      const alertId = change.doc.id;
      const alertData = change.doc.data();

      // Duplicate Prevention: Skip if already triaged
      if (alertData.triage_status) {
        return;
      }

      console.log(`\n🔔 New Alert Detected: ${alertId}`);
      console.log(`📍 Location: ${alertData.location || "Unknown"}`);

      try {
        // Prepare Prompt
        const prompt = `
          You are the NEXUS Crisis Intelligence Brain for a luxury hotel. 
          Analyze the following sensor data or manual alert trigger:
          
          Source: ${alertData.trigger_source || "Unknown"}
          Location: ${alertData.location || "Unknown"}
          Raw Data: ${JSON.stringify(alertData)}

          Return a structured JSON response with these exact keys:
          - crisis_class: (e.g., "Fire", "Medical Emergency", "Intruder", "Flood", "Gas Leak")
          - severity: (e.g., "Critical", "High", "Medium", "Low")
          - recommended_action: (A short system-level instruction)
          - instructions_for_staff: (Clear, numbered steps for hotel staff)
          - evacuate_floor: (Boolean: true/false)
          - notify_emergency_services: (Boolean: true/false)
          - iptv_broadcast: (A message to be displayed on guest room TVs)
        `;

        // Call Gemini
        const result = await model.generateContent(prompt);
        const responseText = result.response.text();

        let intelligence;
        try {
          intelligence = JSON.parse(responseText);
        } catch (parseError) {
          throw new Error("AI returned invalid JSON format");
        }

        // Update Firestore
        const updateData = {
          ...intelligence,
          triage_status: "completed",
          triaged_at: admin.firestore.FieldValue.serverTimestamp(),
        };

        await alertsRef.doc(alertId).update(updateData);
        console.log(`✅ Alert ${alertId} triaged successfully: ${intelligence.crisis_class} (${intelligence.severity})`);

      } catch (error) {
        console.error(`❌ Error processing alert ${alertId}:`, error.message);

        // Fallback Handling
        const fallbackData = {
          crisis_class: "Pending Classification",
          severity: "High (Fallback)",
          recommended_action: "Manual verification required immediately",
          instructions_for_staff: "AI classification failed. Please check the alert source manually and follow standard emergency protocols.",
          evacuate_floor: false,
          notify_emergency_services: true,
          iptv_broadcast: "Nexus System: Emergency alert detected. Please stay in your room until further notice.",
          triage_status: "failed",
          triaged_at: admin.firestore.FieldValue.serverTimestamp(),
          error_log: error.message,
        };

        await alertsRef.doc(alertId).update(fallbackData);
        console.log(`⚠️ Applied fallback intelligence for alert ${alertId}`);
      }
    }
  });
}, (err) => {
  console.error("🔥 Firestore Listener Error:", err);
});

console.log("📡 Listening for new alerts in /alerts collection...");
