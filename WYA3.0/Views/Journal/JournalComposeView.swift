import SwiftUI

struct JournalComposeView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss
    
    @State private var text: String = ""
    @State private var selectedPrompt: String = "Free Write"
    @State private var detectedDistortions: [DistortionEngine.Distortion] = []
    @FocusState private var isEditorFocused: Bool
    
    let prompts = [
        "Free Write",
        "What's one thing you're proud of today?",
        "What's a challenge you're currently facing?",
        "How did you handle a stressful moment recently?",
        "What's something you're looking forward to?",
        "Write about a person who makes you feel safe."
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Header / Prompt
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("REFLECTING ON")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(Theme.midGrey)
                            
                            Menu {
                                ForEach(prompts, id: \.self) { prompt in
                                    Button(prompt) { selectedPrompt = prompt }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(selectedPrompt)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Theme.nearBlack)
                                        .lineLimit(1)
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(Theme.midGrey)
                                }
                            }
                        }
                        Spacer()
                        
                        Text("\(text.count) chars")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Theme.midGrey)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    
                    Divider().background(Theme.blue.opacity(0.05))
                }
                .background(Theme.cardBg)
                
                // MARK: - Editor
                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text("Share your thoughts here...")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Theme.lightGrey)
                            .padding(.top, 32).padding(.leading, 24)
                    }
                    
                    TextEditor(text: $text)
                        .focused($isEditorFocused)
                        .padding(24)
                        .font(.system(size: 18, weight: .medium))
                        .lineSpacing(6)
                        .scrollContentBackground(.hidden)
                        .onChange(of: text) { oldValue, newValue in
                            detectedDistortions = DistortionEngine.detect(in: newValue)
                        }
                }
                .background(Theme.offWhite)
                
                // MARK: - Real-time Analysis
                if let d = detectedDistortions.first {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Theme.orange.opacity(0.1))
                                .frame(width: 40, height: 40)
                            Image(systemName: "sparkles")
                                .foregroundColor(Theme.orange)
                                .font(.system(size: 16, weight: .bold))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Clarity Insight: \(d.name)")
                                .font(.system(size: 12, weight: .black))
                                .foregroundColor(Theme.orange)
                            Text(d.reframe)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Theme.darkGrey)
                                .lineLimit(2)
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(Theme.cardBg)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .auraStroke(color: Theme.orange.opacity(0.2))
                    .padding(16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // MARK: - Footer
                VStack(spacing: 0) {
                    Divider().background(Theme.blue.opacity(0.05))
                    
                    Button(action: saveEntry) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Complete Entry")
                        }
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(text.count < 10 ? Theme.lightGrey : Theme.blue)
                        .clipShape(Capsule())
                        .shadow(color: Theme.blue.opacity(text.count < 10 ? 0 : 0.2), radius: 10, y: 5)
                    }
                    .disabled(text.count < 10)
                    .padding(24)
                }
                .background(Theme.cardBg)
            }
            .onTapGesture { isEditorFocused = false }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(Theme.midGrey)
                        .fontWeight(.bold)
                }
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") { isEditorFocused = false }
                            .fontWeight(.black)
                    }
                }
            }
        }
    }
    
    private func saveEntry() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        store.addJournalEntry(
            prompt: selectedPrompt,
            text: text,
            distortions: detectedDistortions.map { $0.name }
        )
        store.addXP(25)
        store.completeQuest(type: .journal)
        dismiss()
    }
}
