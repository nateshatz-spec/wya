import SwiftUI

struct CycleTrackerView: View {
    @EnvironmentObject var store: DataStore
    @State private var showingLog = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.mainSpacing) {
                    // Current Phase Card
                    phaseCard
                    
                    // Stats Grid
                    HStack(spacing: 16) {
                        statBox(title: "Cycle Day", value: "14", icon: "calendar", color: .pink)
                        statBox(title: "Status", value: "Regular", icon: "checkmark.circle", color: .green)
                    }
                    
                    // AI Correlation
                    if let correlation = AIManager.shared.generateInsights(store: store).first(where: { $0.title.contains("Luteal") || $0.title.contains("Harmony") }) {
                        VStack(alignment: .leading, spacing: 16) {
                            headerSection(title: "CLARITY CORRELATION", icon: "sparkles")
                            
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Theme.blue.opacity(0.1))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: correlation.icon)
                                        .foregroundColor(Theme.blue)
                                        .font(.system(size: 18, weight: .bold))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(correlation.title)
                                        .font(.system(size: 14, weight: .black))
                                        .foregroundColor(Theme.nearBlack)
                                    Text(correlation.content)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(Theme.darkGrey)
                                        .lineSpacing(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .padding(24)
                            .background(Theme.cardBg)
                            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                            .auraStroke(color: Theme.blue.opacity(0.1))
                        }
                    }
                    
                    // Calendar/History
                    VStack(alignment: .leading, spacing: 16) {
                        headerSection(title: "HISTORY", icon: "clock.arrow.circlepath")
                        
                        if store.cycleEntries.isEmpty {
                            emptyState
                        } else {
                            ForEach(store.cycleEntries.reversed()) { entry in
                                CycleEntryRow(entry: entry)
                            }
                        }
                    }
                }
                .padding(Theme.mainPadding)
            }
            .navigationTitle("Cycle Tracker")
            .background(Theme.offWhite)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingLog = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Theme.blue)
                    }
                }
            }
            .sheet(isPresented: $showingLog) {
                CycleLogView()
            }
        }
    }
    
    private var phaseCard: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.pink.opacity(0.1), lineWidth: 20)
                    .frame(width: 160, height: 160)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.pink, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("PHASE")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(Theme.midGrey)
                    Text("Ovulatory")
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(.pink)
                    Text("High Fertility")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Theme.darkGrey)
                }
            }
            
            Text("Your mood may be elevated today. AI suggests focusing on social activities.")
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(Theme.darkGrey)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .auraStroke(color: .pink.opacity(0.2))
    }
    
    private func statBox(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 18))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Theme.midGrey)
                Text(value)
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(Theme.nearBlack)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .auraStroke(color: color.opacity(0.1))
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "drop.circle")
                .font(.system(size: 40))
                .foregroundColor(Theme.lightGrey)
            Text("No logs yet. Start tracking your cycle to see patterns with your mood and anxiety.")
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(Theme.midGrey)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
    
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
}

struct CycleEntryRow: View {
    let entry: CycleEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.date)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Theme.midGrey)
                Text(entry.phase)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Theme.nearBlack)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                ForEach(entry.symptoms, id: \.self) { symptom in
                    Text(symptom)
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.blue.opacity(0.1))
                        .foregroundColor(Theme.blue)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(20)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .auraStroke(color: Theme.blue.opacity(0.05))
    }
}

struct CycleLogView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedPhase = "Menstrual"
    @State private var selectedFlow = 1
    @State private var selectedSymptoms: Set<String> = []
    
    let phases = ["Menstrual", "Follicular", "Ovulatory", "Luteal"]
    let symptoms = ["Cramps", "Headache", "Bloating", "Acne", "Fatigue", "Mood Swings"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Cycle Info") {
                    Picker("Phase", selection: $selectedPhase) {
                        ForEach(phases, id: \.self) { Text($0) }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Flow Intensity")
                            .font(.system(size: 14, weight: .bold))
                        
                        HStack(spacing: 12) {
                            ForEach(0...3, id: \.self) { level in
                                Button(action: { selectedFlow = level }) {
                                    Text(level == 0 ? "None" : "\(level)")
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(selectedFlow == level ? Color.pink : Theme.offWhite)
                                        .foregroundColor(selectedFlow == level ? .white : Theme.nearBlack)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Symptoms") {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(symptoms, id: \.self) { symptom in
                            Toggle(symptom, isOn: Binding(
                                get: { selectedSymptoms.contains(symptom) },
                                set: { isOn in
                                    if isOn { selectedSymptoms.insert(symptom) }
                                    else { selectedSymptoms.remove(symptom) }
                                }
                            ))
                            .toggleStyle(.button)
                            .tint(.pink)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Log Cycle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let entry = CycleEntry(phase: selectedPhase, flow: selectedFlow, symptoms: Array(selectedSymptoms))
                        store.cycleEntries.append(entry)
                        store.saveAll()
                        dismiss()
                    }
                }
            }
        }
    }
}
