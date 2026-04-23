import SwiftUI

struct JournalView: View {
    @EnvironmentObject var store: DataStore
    @State private var showingCompose = false
    
    let prompts = [
        "What's one thing you're proud of today?",
        "What's a challenge you're currently facing?",
        "How did you handle a stressful moment recently?",
        "What's something you're looking forward to?",
        "Write about a person who makes you feel safe."
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.mainSpacing) {
                    // MARK: - AI Smart Prompt
                    VStack(alignment: .leading, spacing: 16) {
                        headerSection(title: "AI SMART PROMPT", icon: "sparkles")
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text(AIManager.shared.getSmartJournalPrompt(store: store))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Theme.nearBlack)
                                .lineSpacing(4)
                            
                            Button(action: { showingCompose = true }) {
                                Text("Reflect with AI")
                                    .font(.system(size: 13, weight: .black))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Theme.blue)
                                    .clipShape(Capsule())
                            }
                            .contentShape(Capsule())
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.cardBg)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .auraStroke(color: Theme.blue.opacity(0.1))
                    }

                    // MARK: - New Entry
                    HStack(spacing: 16) {
                        Button(action: { showingCompose = true }) {
                            hubButton(title: "Journal", icon: "pencil.and.outline", color: Theme.blue)
                        }
                        .buttonStyle(.plain)
                        .contentShape(Rectangle())
                        
                        Button(action: { showingGratitude = true }) {
                            hubButton(title: "Gratitude", icon: "sun.max.fill", color: Theme.orange)
                        }
                        .buttonStyle(.plain)
                        .contentShape(Rectangle())
                    }
                    
                    // MARK: - History
                    if store.journalEntries.isEmpty {
                        VStack(spacing: 12) {
                            Text("Empty Journal")
                                .font(.system(size: 15, weight: .semibold))
                            Text("Your journey starts here. Write your first reflection.")
                                .font(.system(size: 13))
                                .foregroundColor(Theme.midGrey)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)
                    } else {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("PREVIOUS ENTRIES")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(Theme.midGrey)
                                .padding(.horizontal, 4)
                            
                            ForEach(store.journalEntries.reversed()) { entry in
                                JournalEntryCard(entry: entry)
                            }
                        }
                    }
                }
                .padding(Theme.mainPadding)
            }
            .navigationTitle("Journal")
            .background(Theme.offWhite)
            .sheet(isPresented: $showingCompose) {
                JournalComposeView()
            }
            .sheet(isPresented: $showingGratitude) {
                GratitudeView()
            }
        }
    }
    
    @State private var showingGratitude = false
    
    private func headerSection(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
            Text(title)
                .font(.system(size: 11, weight: .black))
                .kerning(1)
        }
        .foregroundColor(Theme.midGrey)
        .padding(.horizontal, 4)
    }

    private func hubButton(title: String, icon: String, color: Color) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Theme.nearBlack)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .auraStroke(color: color.opacity(0.1))
    }
}

struct JournalEntryCard: View {
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                    Text(entry.date)
                }
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Theme.midGrey)
                
                Spacer()
                
                if !entry.distortions.isEmpty {
                    Text("\(entry.distortions.count) INSIGHTS")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Theme.blue)
                        .clipShape(Capsule())
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(entry.prompt)
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(Theme.nearBlack.opacity(0.8))
                    .lineLimit(1)
                
                Text(entry.text)
                    .font(.system(size: 15))
                    .foregroundColor(Theme.nearBlack)
                    .lineSpacing(4)
                    .lineLimit(4)
            }
        }
        .padding(24)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .auraStroke(color: Theme.blue.opacity(0.05))
        .shadow(color: .black.opacity(0.02), radius: 10, y: 5)
    }
}
