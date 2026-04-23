import SwiftUI

struct GratitudeView: View {
    @EnvironmentObject var store: DataStore
    @State private var text: String = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // List of past entries
                if store.gratitudeEntries.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Theme.orange.opacity(0.3))
                        Text("Start Your Gratitude Practice")
                            .font(.system(size: 18, weight: .bold))
                        Text("Logging 3 things you're grateful for daily can rewire your brain for positivity.")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.midGrey)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(store.gratitudeEntries.reversed()) { entry in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(entry.date)
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundColor(Theme.midGrey)
                                    Text(entry.items.joined(separator: ", "))
                                        .font(.system(size: 15))
                                        .foregroundColor(Theme.nearBlack)
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Theme.cardBg)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                        }
                        .padding(16)
                    }
                }
                
                // Add Entry
                VStack(spacing: 16) {
                    TextField("I am grateful for...", text: $text)
                        .padding(16)
                        .background(Theme.offWhite)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    
                    Button(action: save) {
                        Text("Add Entry")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(text.isEmpty ? Theme.lightGrey : Theme.blue)
                            .clipShape(Capsule())
                    }
                    .disabled(text.isEmpty)
                }
                .padding(20)
                .background(Theme.cardBg)
                .shadow(color: .black.opacity(0.05), radius: 20, y: -10)
            }
            .navigationTitle("Gratitude")
            .background(Theme.offWhite)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
    
    private func save() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let entry = GratitudeEntry(items: [text])
        store.gratitudeEntries.append(entry)
        store.addXP(10)
        store.saveAll()
        text = ""
    }
}
