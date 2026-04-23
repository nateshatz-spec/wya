import SwiftUI

struct Achievement {
    let id: String
    let name: String
    let description: String
    let icon: String
    let minLogs: Int
    let color: Color
}

struct AchievementsListView: View {
    @EnvironmentObject var store: DataStore
    
    let achievements = [
        Achievement(id: "first_log", name: "The First Step", description: "Logged your first mood entry.", icon: "medal.fill", minLogs: 1, color: .blue),
        Achievement(id: "early_adopter", name: "Observer", description: "Logged 10 entries.", icon: "compass.fill", minLogs: 10, color: .green),
        Achievement(id: "night_owl", name: "Night Reflection", description: "Logged 15 entries.", icon: "moon.fill", minLogs: 15, color: .purple),
        Achievement(id: "streak_master", name: "Resonance Master", description: "Logged 50 entries.", icon: "trophy.fill", minLogs: 50, color: .orange)
    ]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.mainPadding) {
            ForEach(achievements, id: \.id) { achievement in
                let unlocked = store.totalLogs >= achievement.minLogs
                
                VStack(alignment: .leading, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(unlocked ? achievement.color.opacity(0.12) : Theme.offWhite)
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: achievement.icon)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(unlocked ? achievement.color : Theme.midGrey)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(achievement.name)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(unlocked ? Theme.nearBlack : Theme.midGrey)
                            .lineLimit(1)
                        
                        Text(achievement.description)
                            .font(.system(size: 11))
                            .foregroundColor(Theme.midGrey)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: 140)
                .background(Theme.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: Theme.radiusLg, style: .continuous))
                .auraStroke(color: AuraPalette.fromID(store.selectedAuraID).outline, radius: Theme.radiusLg)
                .shadow(color: .black.opacity(unlocked ? 0.04 : 0), radius: 10, y: 4)
                .opacity(unlocked ? 1.0 : 0.6)
                .grayscale(unlocked ? 0 : 0.8)
            }
        }
    }
}
