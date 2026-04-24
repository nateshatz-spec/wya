import { GoogleGenerativeAI } from "@google/generative-ai";

/**
 * Clarity Ads Copywriter Engine 🦋
 * Uses Gemini to generate psychology-backed ad copy for WYA 3.0.
 */

export async function generateAdCopy(brandDescription: string) {
    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || "");
    const model = genAI.getGenerativeModel({ model: "gemini-1.5-pro" });

    const prompt = `
        You are a world-class performance marketing creative director.
        The product is "WYA 3.0" (What's Your Anxiety).
        Product Description: ${brandDescription}
        
        Task: Generate 5 high-converting ad variations.
        Each variation must include:
        1. Headline (Short, punchy, stops the scroll)
        2. Subheadline (Explains the value prop clearly)
        3. CTA (Call to action)
        4. ImagePrompt (Description for an AI image generator to create the background vibe)

        Format the output as a JSON array of objects. 
        IMPORTANT: The response MUST be a valid JSON array and nothing else.
        Focus on psychological themes: "Clarity," "Mastery," "Cinematic Peace," and "Scientific Backing."
    `;

    const result = await model.generateContent(prompt);
    const response = await result.response;
    const text = response.text();
    
    // Parse the JSON from the markdown response
    const jsonMatch = text.match(/\[[\s\S]*\]/);
    if (jsonMatch) {
        return JSON.parse(jsonMatch[0]);
    }
    return [];
}
