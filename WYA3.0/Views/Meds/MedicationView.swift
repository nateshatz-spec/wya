import SwiftUI

struct MedicationView: View {
    @EnvironmentObject var store: DataStore
    @State private var showingAddMed = false
    @State private var showingSideEffectLog = false
    @State private var activeInsight: AIInsight? = nil
    @State private var hasShownInsight = false
    @EnvironmentObject var tabStore: TabStore
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // MARK: - Adherence Header
                    VStack(spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("ADHERENCE")
                                    .font(.system(size: 11, weight: .black))
                                    .foregroundColor(Theme.midGrey)
                                    .kerning(1)
                                Text("\(Int(adherenceRate * 100))%")
                                    .font(.system(size: 36, weight: .black))
                                    .foregroundColor(Theme.nearBlack)
                            }
                            Spacer()
                            ZStack {
                                Circle()
                                    .stroke(Theme.offWhite, lineWidth: 8)
                                    .frame(width: 70, height: 70)
                                Circle()
                                    .trim(from: 0, to: adherenceRate)
                                    .stroke(Theme.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                    .frame(width: 70, height: 70)
                                    .rotationEffect(.degrees(-90))
                                
                                Image(systemName: "checkmark.shield.fill")
                                    .foregroundColor(Theme.blue)
                                    .font(.system(size: 20))
                            }
                        }
                        .padding(24)
                        .background(Theme.cardBg)
                        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                        .shadow(color: .black.opacity(0.04), radius: 15, y: 10)
                    }
                    .padding(.horizontal, 20)

                    // MARK: - Daily Schedule
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("TODAY'S SCHEDULE")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(Theme.midGrey)
                                .kerning(1)
                            Spacer()
                            Text(store.currentDateString())
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Theme.blue)
                        }
                        .padding(.horizontal, 24)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(["Morning", "Afternoon", "Evening", "Bedtime", "As Needed"], id: \.self) { time in
                                    ScheduleSlot(time: time, meds: store.medications.filter { $0.frequencyLabel == time })
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }

                    // MARK: - Active Medications
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("ACTIVE MEDICATIONS")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(Theme.midGrey)
                                .kerning(1)
                            Spacer()
                            Button(action: { showingAddMed = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Theme.blue)
                            }
                        }
                        .padding(.horizontal, 24)

                        if store.medications.isEmpty {
                            emptyState
                        } else {
                            VStack(spacing: 16) {
                                ForEach(store.medications) { med in
                                    MedRow(med: med)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }

                    // MARK: - Side Effects
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("SIDE EFFECTS")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(Theme.midGrey)
                                .kerning(1)
                            Spacer()
                            Button(action: { showingSideEffectLog = true }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Log Effect")
                                }
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Theme.orange)
                            }
                        }
                        .padding(.horizontal, 24)

                        if store.sideEffects.isEmpty {
                            Button(action: { showingSideEffectLog = true }) {
                                HStack {
                                    Image(systemName: "exclamationmark.bubble.fill")
                                        .foregroundColor(Theme.orange)
                                    Text("No side effects reported recently.")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(Theme.midGrey)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(Theme.lightGrey)
                                }
                                .padding(20)
                                .background(Theme.cardBg)
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .auraStroke(color: Theme.orange.opacity(0.1))
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 20)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(store.sideEffects.reversed().prefix(5)) { effect in
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack {
                                                Text(effect.effect)
                                                    .font(.system(size: 14, weight: .bold))
                                                Spacer()
                                                Text("\(effect.severity)/5")
                                                    .font(.system(size: 10, weight: .black))
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(Theme.orange)
                                                    .clipShape(Capsule())
                                            }
                                            
                                            Text(effect.date)
                                                .font(.system(size: 10))
                                                .foregroundColor(Theme.midGrey)
                                        }
                                        .padding(16)
                                        .frame(width: 160)
                                        .background(Theme.cardBg)
                                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                        .auraStroke(color: Theme.orange.opacity(0.1))
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                .padding(.vertical, 24)
            }
            .background(Theme.offWhite)
            .navigationTitle("Medications")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddMed) {
                AddMedicationView()
            }
            .sheet(isPresented: $showingSideEffectLog) {
                SideEffectLogView()
            }
            .overlay(alignment: .bottom) {
                if let insight = activeInsight {
                    ProactiveAIView(insight: insight) {
                        activeInsight = nil
                    }
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .onAppear {
                if !hasShownInsight {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        activeInsight = AIManager.shared.getProactiveTip(context: .medication, store: store)
                        hasShownInsight = true
                    }
                }
            }
            .onReceive(tabStore.$activeQuestType) { type in
                guard type == .medication else { return }
                tabStore.activeQuestType = nil
            }
        }
    }

    private var adherenceRate: Double {
        let today = store.currentDateString()
        let loggedToday = store.doses.filter { $0.date == today }.count
        let expectedToday = store.medications.filter { $0.frequencyLabel != "As Needed" }.count
        guard expectedToday > 0 else { return 1.0 }
        return min(Double(loggedToday) / Double(expectedToday), 1.0)
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "pills.fill")
                .font(.system(size: 40))
                .foregroundColor(Theme.lightGrey)
            Text("No Active Regimen")
                .font(.system(size: 17, weight: .bold))
            Text("Keep track of your psychiatric or wellness medications safely.")
                .font(.system(size: 14))
                .foregroundColor(Theme.midGrey)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: { showingAddMed = true }) {
                Text("Add Medication")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Theme.blue)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 20)
    }
}

struct ScheduleSlot: View {
    let time: String
    let meds: [Medication]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(time.uppercased())
                .font(.system(size: 10, weight: .black))
                .foregroundColor(Theme.midGrey)
            
            if meds.isEmpty {
                Text("None")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Theme.lightGrey)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(meds) { med in
                        Text(med.name)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Theme.nearBlack)
                    }
                }
            }
        }
        .frame(width: 110, height: 100, alignment: .topLeading)
        .padding(16)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .auraStroke(color: Theme.blue.opacity(0.1))
    }
}

struct MedRow: View {
    @EnvironmentObject var store: DataStore
    let med: Medication
    
    var isLoggedToday: Bool {
        store.doses.contains { $0.medId == med.id && $0.date == store.currentDateString() }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isLoggedToday ? Theme.green.opacity(0.1) : Theme.blue.opacity(0.1))
                    .frame(width: 54, height: 54)
                Image(systemName: isLoggedToday ? "checkmark.circle.fill" : "pills.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(isLoggedToday ? Theme.green : Theme.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(med.name)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Theme.nearBlack)
                HStack(spacing: 8) {
                    Text(med.dosage)
                        .font(.system(size: 12, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.offWhite)
                        .clipShape(Capsule())
                    
                    Text(med.frequencyLabel)
                        .font(.system(size: 12))
                        .foregroundColor(Theme.midGrey)
                }
            }
            
            Spacer()
            
            if !isLoggedToday {
                Button(action: logMed) {
                    Text("Take")
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Theme.blue)
                        .clipShape(Capsule())
                        .shadow(color: Theme.blue.opacity(0.2), radius: 5, y: 2)
                }
            } else {
                Text("Taken")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Theme.green)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Theme.green.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding(20)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .auraStroke(color: isLoggedToday ? Theme.green.opacity(0.2) : Theme.blue.opacity(0.1))
        .shadow(color: .black.opacity(0.02), radius: 10, y: 5)
    }
    
    private func logMed() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            store.logMedication(id: med.id)
            store.addXP(15)
            store.completeQuest(type: .medication)
        }
    }
}
