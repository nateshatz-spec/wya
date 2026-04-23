# What's Your Anxiety — Your Mind, Unlocked
[![Deployment Status](https://github.com/nateshatz-spec/wya/actions/workflows/deploy.yml/badge.svg)](https://github.com/nateshatz-spec/wya/actions)

What's Your Anxiety is a premium mental health toolkit designed to bridge the gap between clinical therapy and daily wellness. It combines **Aura Intelligence** (advanced mood visualization) with evidence-based **Clinical Labs** to provide users with rapid relief and long-term emotional clarity.

## Project Structure

- **/WYA3.0**: The core iOS application built with SwiftUI.
- **/WYA-Cloud**: Cloudflare Workers API providing secure synchronization and user data persistence.
- **/WYA-Web**: High-fidelity landing page and support site for the platform.
- **/Marketing**: App Store descriptions, social media drafts, and branding assets.

## Key Features

- **Clinical Labs**: Interactive modules for CBT, DBT, and Anger Regulation.
- **Crisis Command**: A rapid-access safety plan and crisis resource hub.
- **Cloud Sync**: End-to-end secure synchronization via Cloudflare D1.
- **Aura Tracking**: Visualizing mental health trends through integrated sleep, mood, and activity data.

## Getting Started

### iOS App
1. Open `WYA3.0.xcodeproj` in Xcode 15+.
2. Ensure you have the `Secrets.swift` file configured with your Cloudflare API keys.
3. Build and run on a physical device for full haptic feedback.

### Backend (WYA-Cloud)
1. `cd WYA-Cloud`
2. `npm install`
3. `npx wrangler deploy` to push the API to your Cloudflare account.

## Technical Details

- **Language**: Swift (SwiftUI), TypeScript (Workers).
- **Backend**: Cloudflare Workers + D1 Database.
- **Production API**: `https://api.whatsyouranxiety.com`
- **Privacy**: End-to-end data encryption and Apple-compliant Privacy Manifests.

---
© 2026 WYA Wellness. Developed for mental clarity.
