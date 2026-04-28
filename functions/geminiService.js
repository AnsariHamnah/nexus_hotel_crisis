const { GoogleGenerativeAI } = require("@google/generative-ai");
const logger = require("firebase-functions/logger");

/**
 * GeminiService - Shared logic for Gemini API interactions
 */
class GeminiService {
    constructor() {
        if (!process.env.GEMINI_API_KEY) {
            logger.error("Missing GEMINI_API_KEY in environment variables");
            throw new Error("Missing GEMINI_API_KEY");
        }
        
        this.genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
        
        // Critical: Use the model suggested by Solution Challenge support
        this.modelName = "gemini-3.1-pro-preview";
        
        this.model = this.genAI.getGenerativeModel({
            model: this.modelName,
            generationConfig: {
                responseMimeType: "application/json",
            },
        });
        
        logger.info(`GeminiService initialized with model: ${this.modelName}`);
    }

    async generateStructuredContent(prompt) {
        try {
            logger.info(`Calling Gemini API (${this.modelName}) with prompt length: ${prompt.length}`);
            const result = await this.model.generateContent(prompt);
            const responseText = result.response.text();
            
            try {
                return JSON.parse(responseText);
            } catch (parseError) {
                logger.error("Failed to parse Gemini JSON response", { responseText });
                throw new Error("Invalid AI response format");
            }
        } catch (error) {
            logger.error(`Gemini API Error (${this.modelName}):`, error);
            throw error;
        }
    }
}

module.exports = new GeminiService();
