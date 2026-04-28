const logger = require("firebase-functions/logger");
const geminiService = require("./geminiService");

/**
 * Generate AI After-Action Report (Incident Summary)
 */
async function generateSummary(alertData, auditLogs) {
    logger.info("Starting AI Summary generation", { alertId: alertData.id });

    const logsText = auditLogs.map(log => 
        `[${log.timestamp}] ${log.action}: ${log.details} (by ${log.performedBy})`
    ).join("\n");

    const prompt = `
      You are the NEXUS Crisis Intelligence Brain. 
      Generate a professional After-Action Report (AAR) for the following resolved incident.
      
      Incident: ${alertData.title}
      Category: ${alertData.category}
      Location: ${alertData.location}
      
      Incident Timeline:
      ${logsText}

      Return a structured JSON response with these exact keys:
      - summary: (A 2-3 sentence high-level summary of what happened)
      - timeline_highlights: (A list of the 3 most critical moments)
      - response_assessment: (Professional assessment of the staff response time and effectiveness)
      - recommendations: (Future preventative measures)
    `;

    try {
        const summaryData = await geminiService.generateStructuredContent(prompt);
        
        // Format the summary into a readable string for the UI
        const formattedReport = `
# AI AFTER-ACTION REPORT

## Summary
${summaryData.summary}

## Key Timeline Moments
${summaryData.timeline_highlights.map(h => `- ${h}`).join("\n")}

## Response Assessment
${summaryData.response_assessment}

## Recommendations
${summaryData.recommendations}
        `.trim();

        return {
            ai_summary_raw: summaryData,
            ai_summary_formatted: formattedReport,
            summary_generated_at: new Date().toISOString(),
        };
    } catch (error) {
        logger.error("Summary AI generation failed, applying fallback", { error: error.message });
        
        return {
            ai_summary_formatted: "AI Synthesis failed. Please refer to the raw audit logs for incident timeline.",
            summary_status: "failed",
        };
    }
}

module.exports = { generateSummary };
