import SwiftUI

struct SleepLogView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss
    
    @State private var hours: Double = 7.0
    @State private var quality: Int = 3
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Theme.blue)
                        .padding(24)
                        .background(Theme.blue.opacity(0.1))
                        .clipShape(Circle())
                    
                    Text("Sleep Tracking")
                        .font(.system(size: 24, weight: .bold))
                    Text("Quality sleep reduces anxiety by 30%.")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.midGrey)
                }
                .padding(.top, 40)
                
                // Hours Selector
                VStack(spacing: 16) {
                    HStack {
                        Text("HOURS SLEPT")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(Theme.midGrey)
                        Spacer()
                        Text("\(String(format: "%.1f", hours)) hrs")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(Theme.blue)
                    }
                    
                    Slider(value: $hours, in: 0...12, step: 0.5)
                        .tint(Theme.blue)
                }
                .padding(24)
                .background(Theme.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                
                // Quality Selector
                VStack(alignment: .leading, spacing: 16) {
                    Text("SLEEP QUALITY")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(Theme.midGrey)
                    
                    HStack(spacing: 12) {
                        ForEach(1...5, id: \.self) { score in
                            Button(action: { quality = score }) {
                                Text("\(score)")
                                    .font(.system(size: 17, weight: .bold))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 54)
                                    .background(quality == score ? Theme.blue : Theme.offWhite)
                                    .foregroundColor(quality == score ? .white : Theme.nearBlack)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                        }
                    }
                }
                .padding(24)
                .background(Theme.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                
                // MARK: - Wind Down Mode
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("WIND DOWN MODE")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(Theme.midGrey)
                            Text("Warm amber tint to aid sleep")
                                .font(.system(size: 12))
                                .foregroundColor(Theme.midGrey)
                        }
                        Spacer()
                        Toggle("", isOn: $store.windDownEnabled)
                            .labelsHidden()
                            .tint(Theme.orange)
                    }
                }
                .padding(24)
                .background(Theme.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .auraStroke(color: store.windDownEnabled ? Theme.orange.opacity(0.2) : .clear)
                
                Spacer()
                
                Button(action: save) {
                    Text("Log Sleep")
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Theme.blue)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .background(Theme.offWhite)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
    
    private func save() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        store.addSleepEntry(hours: hours, quality: quality)
        store.addXP(15)
        store.completeQuest(type: .sleep)
        dismiss()
    }
}
