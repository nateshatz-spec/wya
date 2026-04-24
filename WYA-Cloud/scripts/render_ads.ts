import { chromium } from "playwright";
import * as path from "path";
import * as fs from "fs";
import * as dotenv from "dotenv";
import { generateAdCopy } from "./generate_ad_copy";

dotenv.config();

/**
 * Clarity Ads Renderer 🦋
 * Orchestrates the generation of ad copy and visual rendering.
 */

async function main() {
    const isMock = process.argv.includes("--mock");
    console.log(`🦋 Starting Clarity Ads Generation${isMock ? " (MOCK MODE)" : ""}...`);

    const brandDesc = "WYA 3.0 is a cinematic mental health app with Aura Intelligence and haptic grounding labs. It focuses on luxury aesthetics and clinical depth.";
    
    let ads;
    if (isMock) {
        console.log("🛠️ Using high-fidelity mock ad copy...");
        ads = [
            {
                Headline: "Master Your\nInner Calm.",
                Subheadline: "Experience the next evolution of mental wellness with Aura Intelligence.",
                CTA: "Start Free Trial"
            },
            {
                Headline: "Cinematic\nClarity.",
                Subheadline: "A premium toolkit designed for the modern mind. Clinical depth meets luxury design.",
                CTA: "Explore Labs"
            },
            {
                Headline: "Your Mind,\nUnlocked.",
                Subheadline: "WYA 3.0 brings evidence-based CBT to your fingertips with stunning visual tracking.",
                CTA: "Download Beta"
            }
        ];
    } else {
        // 1. Generate Ad Copy
        console.log("🤖 Consulting Gemini for high-converting copy...");
        ads = await generateAdCopy(brandDesc);
    }

    if (!ads || ads.length === 0) {
        console.error("❌ Failed to generate ad copy.");
        return;
    }

    console.log(`✅ Generated ${ads.length} ad variations.`);

    // 2. Prepare Output Directory
    const outputDir = path.join(__dirname, "../../Marketing/Generated-Ads");
    if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir, { recursive: true });
    }

    // 3. Launch Browser
    console.log("🌐 Launching Playwright renderer...");
    const browser = await chromium.launch();
    const context = await browser.newContext({
        viewport: { width: 1080, height: 1080 }
    });
    const page = await context.newPage();

    // 4. Render each ad
    const templatePath = `file://${path.join(__dirname, "../templates/ad_template.html")}`;

    // A few cinematic placeholder images if we don't have a real image generator API integrated
    const placeholders = [
        "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe", // Abstract blue
        "https://images.unsplash.com/photo-1620641788421-7a1c342ea42e", // Dark purple
        "https://images.unsplash.com/photo-1557683316-973673baf926", // Dark gradient
        "https://images.unsplash.com/photo-1614850523296-e8c041de439f", // Cinematic texture
        "https://images.unsplash.com/photo-1635776062127-d379bfcba9f8"  // Soft glow
    ];

    for (let i = 0; i < ads.length; i++) {
        const ad = ads[i];
        console.log(`📸 Rendering Ad ${i + 1}: ${ad.Headline}`);

        // Construct URL with params
        const queryParams = new URLSearchParams({
            headline: ad.Headline,
            subheadline: ad.Subheadline,
            cta: ad.CTA,
            bg: placeholders[i % placeholders.length] + "?auto=format&fit=crop&q=80&w=1080&h=1080"
        });

        await page.goto(`${templatePath}?${queryParams.toString()}`);
        
        // Wait for image to load
        await page.waitForSelector("#bg-target", { state: "visible" });
        // Give it a moment for any CSS transitions or fonts
        await page.waitForTimeout(2000);

        const fileName = `ad_${i + 1}_${ad.Headline.toLowerCase().replace(/[^a-z0-9]/g, "_")}.png`;
        const filePath = path.join(outputDir, fileName);

        await page.screenshot({ path: filePath });
        console.log(`   Saved to: ${fileName}`);
    }

    await browser.close();
    console.log("\n✨ All ads generated successfully!");
    console.log(`📁 Check your results in: ${outputDir}`);
}

main().catch(err => {
    console.error("💥 Fatal Error:", err);
});
