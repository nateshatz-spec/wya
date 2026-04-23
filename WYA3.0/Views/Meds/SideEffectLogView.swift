import SwiftUI

struct SideEffectLogView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedMedId: String = "General"
    @State private var effectName: String = ""
    @State private var severity: Double = 3
    @State private var notes: String = ""
    
    let commonEffects = [
        "Nausea 🤢", "Dizziness 😵‍💫", "Fatigue 🥱", "Headache 🤕",
        "Insomnia 👁️", "Dry Mouth 👄", "Anxiety 😰", "Weight Change ⚖️"
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // MARK: - Medication Picker
                    VStack(alignment: .leading, spacing: 16) {
                        Text("WHICH MEDICATION?")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(Theme.midGrey)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(store.medications) { med in
                                    Button(action: { selectedMedId = med.id }) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(med.name)
                                                .font(.system(size: 14, weight: .bold))
                                            Text(med.dosage)
                                                .font(.system(size: 10))
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(selectedMedId == med.id ? Theme.blue : Theme.offWhite)
                                        .foregroundColor(selectedMedId == med.id ? .white : Theme.nearBlack)
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    }
                                    .buttonStyle(.plain)
                                }
                                
                                Button(action: { selectedMedId = "General" }) {
                                    Text("General / Not Sure")
                                        .font(.system(size: 14, weight: .bold))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(selectedMedId == "General" ? Theme.blue : Theme.offWhite)
                                        .foregroundColor(selectedMedId == "General" ? .white : Theme.nearBlack)
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // MARK: - Effect Type
                    VStack(alignment: .leading, spacing: 16) {
                        Text("WHAT ARE YOU FEELING?")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(Theme.midGrey)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 10)], spacing: 10) {
                            ForEach(commonEffects, id: \.self) { effect in
                                Button(action: { effectName = effect }) {
                                    Text(effect)
                                        .font(.system(size: 14, weight: .medium))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(effectName == effect ? Theme.orange : Theme.offWhite)
                                        .foregroundColor(effectName == effect ? .white : Theme.nearBlack)
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        TextField("Other effect...", text: $effectName)
                            .padding(16)
                            .background(Theme.offWhite)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .padding(.horizontal, 24)
                    
                    // MARK: - Severity
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("SEVERITY")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(Theme.midGrey)
                            Spacer()
                            Text("\(Int(severity))/5")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Theme.orange)
                        }
                        
                        Slider(value: $severity, in: 1...5, step: 1)
                            .tint(Theme.orange)
                    }
                    .padding(.horizontal, 24)
                    
                    // MARK: - Notes
                    VStack(alignment: .leading, spacing: 16) {
                        Text("NOTES")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(Theme.midGrey)
                        
                        TextEditor(text: $notes)
                            .frame(height: 100)
                            .padding(12)
                            .background(Theme.offWhite)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .padding(.horizontal, 24)
                    
                    // MARK: - Submit
                    Button(action: saveEffect) {
                        Text("Log Side Effect")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(effectName.isEmpty ? Theme.lightGrey : Theme.orange)
                            .clipShape(Capsule())
                            .shadow(color: Theme.orange.opacity(effectName.isEmpty ? 0 : 0.2), radius: 10, y: 5)
                    }
                    .disabled(effectName.isEmpty)
                    .padding(.horizontal, 24)
                }
                .padding(.vertical, 24)
            }
            .background(Theme.cardBg)
            .navigationTitle("Log Side Effect")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func saveEffect() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        store.addSideEffect(medId: selectedMedId, effect: effectName, severity: Int(severity), notes: notes)
        store.addXP(10)
        dismiss()
    }
}
