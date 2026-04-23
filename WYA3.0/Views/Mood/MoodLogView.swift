import SwiftUI

struct MoodLogView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedMood: Int = 3
    @State private var selectedTriggers: Set<String> = []
    @State private var notes: String = ""
    @State private var showingConfetti = false
    @FocusState private var isNotesFocused: Bool
    
    let moods = [
        (1, "Very Bad", "😫"),
        (2, "Bad", "😔"),
        (3, "Okay", "😐"),
        (4, "Good", "😊"),
        (5, "Amazing", "🤩")
    ]
    
    let triggers = [
        "Work 💼", "Relationship ❤️", "Family 👨‍👩‍👧", "Friends 👥",
        "Sleep 😴", "Health 🏥", "Exercise 🏃", "Food 🍎",
        "Money 💸", "School 📚", "Weather ☁️", "Other 🔄"
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // MARK: - Mood Selection
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(moodColor(selectedMood).opacity(0.15))
                                .frame(width: 200, height: 200)
                                .blur(radius: 50)
                            
                            Text(moods.first(where: { $0.0 == selectedMood })?.2 ?? "😐")
                                .font(.system(size: 80))
                                .shadow(color: moodColor(selectedMood).opacity(0.3), radius: 20)
                        }
                        .padding(.top, 20)
                        
                        HStack(spacing: 12) {
                            ForEach(moods, id: \.0) { mood in
                                Button(action: {
                                    selectedMood = mood.0
                                    UISelectionFeedbackGenerator().selectionChanged()
                                 }) {
                                    VStack(spacing: 8) {
                                        Text(mood.2).font(.system(size: 24))
                                        Text(mood.1).font(.system(size: 10, weight: .bold))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(selectedMood == mood.0 ? moodColor(mood.0).opacity(0.1) : Theme.cardBg)
                                    .foregroundColor(selectedMood == mood.0 ? moodColor(mood.0) : Theme.midGrey)
                                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                    .auraStroke(color: selectedMood == mood.0 ? moodColor(mood.0).opacity(0.4) : Theme.blue.opacity(0.05))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // MARK: - Triggers
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Influences")
                                .font(.system(size: 14, weight: .black))
                                .foregroundColor(Theme.midGrey)
                            Spacer()
                            if !selectedTriggers.isEmpty {
                                Text("\(selectedTriggers.count)")
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(Theme.blue)
                                    .clipShape(Circle())
                            }
                        }
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 8)], spacing: 8) {
                            ForEach(triggers, id: \.self) { trigger in
                                Button(action: {
                                    if selectedTriggers.contains(trigger) {
                                        selectedTriggers.remove(trigger)
                                    } else {
                                        selectedTriggers.insert(trigger)
                                    }
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                }) {
                                    Text(trigger)
                                        .font(.system(size: 13, weight: .medium))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(selectedTriggers.contains(trigger) ? Theme.blue : Theme.cardBg)
                                        .foregroundColor(selectedTriggers.contains(trigger) ? .white : Theme.nearBlack)
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        .auraStroke(color: selectedTriggers.contains(trigger) ? .clear : Theme.blue.opacity(0.05))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // MARK: - Notes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notes")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(Theme.midGrey)
                        
                        TextField("What's on your mind?", text: $notes, axis: .vertical)
                            .focused($isNotesFocused)
                            .lineLimit(3...5)
                            .padding(16)
                            .background(Theme.cardBg)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .auraStroke(color: Theme.blue.opacity(0.05))
                    }
                    .padding(.horizontal, 20)
                    
                    // MARK: - Submit
                    Button(action: saveLog) {
                        Text("Save Check-in")
                            .font(.system(size: 17, weight: .black))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Theme.blue)
                            .clipShape(Capsule())
                            .shadow(color: Theme.blue.opacity(0.2), radius: 10, y: 5)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                }
                .padding(.vertical, 20)
            }
            .background(Theme.offWhite)
            .onTapGesture { isNotesFocused = false }
            .navigationTitle("Daily Check-in")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Theme.midGrey)
                }
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") { isNotesFocused = false }
                            .fontWeight(.black)
                    }
                }
            }
        }
    }
    
    private func saveLog() {
        isNotesFocused = false
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        store.addMoodLog(mood: selectedMood, triggers: Array(selectedTriggers), notes: notes)
        
        // Gamification: Add XP
        store.addXP(15)
        store.addAuraShards(2, source: "Mood Log")
        store.completeQuest(type: .mood)
        
        dismiss()
    }
    private func moodColor(_ mood: Int) -> Color {
        switch mood {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .green
        case 5: return .blue
        default: return Theme.blue
        }
    }
}
