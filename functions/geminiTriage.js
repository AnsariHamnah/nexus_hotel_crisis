const logger = require("firebase-functions/logger");
const geminiService = require("./geminiService");

/**
 * Perform AI Triage on a new alert
 */
async function performTriage(alertData) {
    logger.info("Starting AI Triage process", { alertId: alertData.id });

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
        const intelligence = await geminiService.generateStructuredContent(prompt);
        return {
            ...intelligence,
            triage_status: "completed",
        };
    } catch (error) {
        logger.error("Triage AI generation failed, applying fallback", { error: error.message });
        
        // Production Fallback
        return {
            crisis_class: alertData.category || "Pending Classification",
            severity: "High (Fallback)",
            recommended_action: "Manual verification required immediately",
            instructions_for_staff: "AI triage failed. Proceed with standard emergency response protocols. Check source sensors manually.",
            evacuate_floor: false,
            notify_emergency_services: true,
            iptv_broadcast: "Nexus System: Emergency alert detected. Staff is investigating. Please remain calm.",
            triage_status: "failed",
            error_log: error.message,
        };
    }
}

module.exports = { performTriage };
