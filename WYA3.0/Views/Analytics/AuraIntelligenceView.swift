import SwiftUI

struct AuraIntelligenceView: View {
    @EnvironmentObject var store: DataStore
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Prediction Card
                predictionCard
                
                // MARK: - Aura Legend
                auraLegend
                
                // MARK: - Correlations
                correlationSection
                
                // MARK: - Aura History
                auraHistory
            }
            .padding(20)
        }
        .navigationTitle("Aura Intelligence")
        .background(Theme.offWhite)
        .locked(feature: "Aura Intelligence", description: "Unlock predictive forecasting and deep correlation analytics.")
    }
    
    private var predictionCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(Theme.blue)
                Text("AURA FORECAST")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(Theme.midGrey)
                Spacer()
                Text("AI PREDICTION")
                    .font(.system(size: 10, weight: .black))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.blue.opacity(0.1))
                    .foregroundColor(Theme.blue)
                    .clipShape(Capsule())
            }
            
            Text("Based on your 7-day trend, tomorrow's Aura is likely to be:")
                .font(.system(size: 15))
                .foregroundColor(Theme.darkGrey)
            
            HStack(spacing: 16) {
                Circle()
                    .fill(Theme.blue.opacity(0.2))
                    .frame(width: 64, height: 64)
                    .overlay(Image(systemName: "sun.max.fill").foregroundColor(Theme.blue))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Radiant Clarity")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(Theme.nearBlack)
                    Text("High sleep quality and consistent med adherence are driving positive trends.")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.midGrey)
                }
            }
            .padding(20)
            .background(Theme.offWhite)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .padding(24)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .auraStroke(color: Theme.blue.opacity(0.1))
    }
    
    private var correlationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("CORRELATIONS")
                .font(.system(size: 11, weight: .black))
                .foregroundColor(Theme.midGrey)
                .padding(.horizontal, 4)
            
            VStack(spacing: 12) {
                correlationRow(title: "Sleep vs Anxiety", impact: "+40%", description: "Better sleep correlates with lower anxiety scores.", color: .purple)
                correlationRow(title: "Meds Adherence", impact: "+25%", description: "Consistent doses lead to more stable Aura colors.", color: .green)
                correlationRow(title: "Journaling Frequency", impact: "+15%", description: "Days with journal entries show higher emotional clarity.", color: .blue)
            }
        }
    }
    
    private func correlationRow(title: String, impact: String, description: String, color: Color) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(color.opacity(0.1)).frame(width: 44, height: 44)
                Text(impact)
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(Theme.midGrey)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .auraStroke(color: color.opacity(0.1))
    }
    
    private var auraLegend: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AURA LEGEND")
                .font(.system(size: 11, weight: .black))
                .foregroundColor(Theme.midGrey)
                .padding(.horizontal, 4)
            
            VStack(spacing: 1) {
                legendRow(name: "Ice Blue", color: Color(hex: "0071e3"), meaning: "Clarity & Calm", description: "Indicates low physiological stress and high focus.")
                legendRow(name: "Deep Forest", color: Color(hex: "059669"), meaning: "Growth & Recovery", description: "Seen during consistent mindfulness and physical rest.")
                legendRow(name: "Quiet Storm", color: Color(hex: "ef4444"), meaning: "High Activation", description: "Signals active emotional processing or high stress.")
                legendRow(name: "Radiant Sunlight", color: Color(hex: "f59e0b"), meaning: "Peak Wellness", description: "Optimal mood, sleep, and social engagement.")
                legendRow(name: "Starlit Midnight", color: Color(hex: "6366f1"), meaning: "Deep Mastery", description: "Advanced state of resilience and clinical progress.")
            }
            .background(Theme.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .auraStroke(color: Theme.blue.opacity(0.1))
        }
    }
    
    private func legendRow(name: String, color: Color, meaning: String, description: String) -> some View {
        HStack(spacing: 16) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
                .auraStroke(color: color.opacity(0.3), radius: 6)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(name)
                        .font(.system(size: 14, weight: .black))
                    Spacer()
                    Text(meaning)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(color.opacity(0.1))
                        .clipShape(Capsule())
                }
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(Theme.midGrey)
            }
        }
        .padding(16)
    }

    private var auraHistory: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AURA HISTORY")
                .font(.system(size: 11, weight: .black))
                .foregroundColor(Theme.midGrey)
                .padding(.horizontal, 4)
            
            HStack(spacing: 8) {
                ForEach(0..<14) { i in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Theme.pillColors.randomElement()?.opacity(0.3) ?? Theme.blue.opacity(0.3))
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                }
            }
            .padding(16)
            .background(Theme.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}
