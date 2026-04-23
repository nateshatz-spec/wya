import SwiftUI

struct PreventionLabView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss
    @State private var showingAddTrack = false
    @State private var showingCravingLog = false
    @State private var showingCommitment = false
    @State private var hasCommittedToday = false
    @State private var activeInsight: AIInsight? = nil
    @State private var hasShownInsight = false
    @EnvironmentObject var tabStore: TabStore
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 32) {
                        // MARK: - Daily Commitment
                        commitmentCard
                        
                        // MARK: - AI Recovery Coach
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 12, weight: .bold))
                                Text("AI RECOVERY COACH")
                                    .font(.system(size: 11, weight: .black))
                                    .kerning(1)
                            }
                            .foregroundColor(Theme.midGrey)
                            .padding(.horizontal, 4)
                            
                            Text(AIManager.shared.getRecoveryEncouragement(store: store))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Theme.nearBlack)
                                .padding(24)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Theme.cardBg)
                                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                                .auraStroke(color: Theme.blue.opacity(0.1))
                        }

                        // MARK: - Presets
                        VStack(alignment: .leading, spacing: 16) {
                            Text("QUICK START")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(Theme.midGrey)
                                .padding(.horizontal, 4)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    presetButton(name: "Alcohol", emoji: "🍷", savings: 15.0)
                                    presetButton(name: "Nicotine", emoji: "💨", savings: 10.0)
                                    presetButton(name: "Caffeine", emoji: "☕️", savings: 5.0)
                                    presetButton(name: "Cannabis", emoji: "🌿", savings: 12.0)
                                    presetButton(name: "Sugar", emoji: "🍩", savings: 8.0)
                                    presetButton(name: "Social Media", emoji: "📱", savings: 0.0)
                                    presetButton(name: "Gambling", emoji: "🎲", savings: 50.0)
                                    presetButton(name: "Fast Food", emoji: "🍔", savings: 15.0)
                                    presetButton(name: "Shopping", emoji: "🛍️", savings: 20.0)
                                }
                            }
                        }

                        // MARK: - Active Tracks
                        if !store.recoveryTracks.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("YOUR STRENGTH")
                                        .font(.system(size: 11, weight: .black))
                                        .foregroundColor(Theme.midGrey)
                                    Spacer()
                                    Button(action: { showingAddTrack = true }) {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(Theme.blue)
                                    }
                                }
                                
                                ForEach(store.recoveryTracks) { track in
                                    trackCard(track: track)
                                }
                            }
                        }
                        
                        // MARK: - Craving Management
                        VStack(alignment: .leading, spacing: 20) {
                            Text("CRAVING MANAGEMENT")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(Theme.midGrey)
                                .padding(.horizontal, 4)
                            
                            Button(action: { showingCravingLog = true }) {
                                HStack {
                                    Image(systemName: "bolt.fill")
                                    Text("Log a Craving")
                                    Spacer()
                                    Image(systemName: "plus.circle.fill")
                                }
                                .font(.system(size: 16, weight: .black))
                                .foregroundColor(.white)
                                .padding(24)
                                .background(Theme.orange)
                                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                                .shadow(color: Theme.orange.opacity(0.3), radius: 15, y: 8)
                            }
                            
                            if !store.cravingEntries.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("HISTORY")
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundColor(Theme.midGrey.opacity(0.6))
                                        .padding(.horizontal, 4)
                                    
                                    ForEach(store.cravingEntries.reversed().prefix(3)) { craving in
                                        HStack(spacing: 16) {
                                            ZStack {
                                                Circle()
                                                    .fill(craving.wasHandled ? Theme.green.opacity(0.1) : Theme.orange.opacity(0.1))
                                                    .frame(width: 40, height: 40)
                                                Image(systemName: craving.wasHandled ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                                    .foregroundColor(craving.wasHandled ? Theme.green : Theme.orange)
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(craving.trigger)
                                                    .font(.system(size: 14, weight: .bold))
                                                Text("Intensity: \(craving.intensity)/5")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(Theme.midGrey)
                                            }
                                            Spacer()
                                            Text(craving.date.formatted(date: .omitted, time: .shortened))
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(Theme.lightGrey)
                                        }
                                        .padding(16)
                                        .background(Theme.cardBg)
                                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                        .auraStroke(color: (craving.wasHandled ? Theme.green : Theme.orange).opacity(0.1))
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                    .blur(radius: store.recoveryTracks.isEmpty ? 10 : 0)
                    .disabled(store.recoveryTracks.isEmpty)
                }
                
                if store.recoveryTracks.isEmpty {
                    lockedOverlay
                }
            }
            .background(Theme.offWhite)
            .background(Theme.offWhite)
            .navigationTitle("Prevention Lab")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                        Text("AI PROTECTED")
                            .font(.system(size: 10, weight: .black))
                    }
                    .foregroundColor(Theme.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.blue.opacity(0.1))
                    .clipShape(Capsule())
                }
            }
            .sheet(isPresented: $showingAddTrack) { AddTrackView() }
            .sheet(isPresented: $showingCravingLog) { CravingLogView() }
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        activeInsight = AIManager.shared.getProactiveTip(context: .recovery, store: store)
                        hasShownInsight = true
                    }
                }
            }
            .onReceive(tabStore.$activeQuestType) { type in
                guard type == .recovery else { return }
                tabStore.activeQuestType = nil
            }
        }
    }
    
    private var commitmentCard: some View {
        Button(action: {
            withAnimation(.spring()) {
                hasCommittedToday = true
            }
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            store.addXP(25)
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(hasCommittedToday ? Theme.green.opacity(0.1) : Theme.blue.opacity(0.1))
                        .frame(width: 56, height: 56)
                    Image(systemName: hasCommittedToday ? "checkmark.shield.fill" : "hand.raised.fill")
                        .font(.system(size: 24))
                        .foregroundColor(hasCommittedToday ? Theme.green : Theme.blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(hasCommittedToday ? "Committed to Clarity" : "Daily Commitment")
                        .font(.system(size: 17, weight: .black))
                        .foregroundColor(Theme.nearBlack)
                    Text(hasCommittedToday ? "You've pledged your strength for today." : "I commit to my clarity and strength today.")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.midGrey)
                        .lineLimit(1)
                }
                Spacer()
                if !hasCommittedToday {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Theme.lightGrey)
                }
            }
            .padding(20)
            .background(Theme.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .auraStroke(color: hasCommittedToday ? Theme.green.opacity(0.2) : Theme.blue.opacity(0.1))
        }
        .buttonStyle(.plain)
        .disabled(hasCommittedToday)
    }

    private var lockedOverlay: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Theme.blue.opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Theme.blue)
            }
            
            VStack(spacing: 8) {
                Text("Prevention Locked")
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(Theme.nearBlack)
                Text("Add at least one substance you are trying to quit to unlock your personalized Prevention Lab.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Theme.darkGrey)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: { showingAddTrack = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Setup My Lab")
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 16)
                .background(Theme.blue)
                .clipShape(Capsule())
                .shadow(color: Theme.blue.opacity(0.3), radius: 10, y: 5)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.offWhite.opacity(0.8))
    }

    private func presetButton(name: String, emoji: String, savings: Double) -> some View {
        Button(action: {
            store.addRecoveryTrack(name: name, emoji: emoji, dailySavings: savings)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }) {
            VStack(spacing: 8) {
                Text(emoji).font(.system(size: 24))
                Text(name).font(.system(size: 13, weight: .bold))
            }
            .frame(width: 90, height: 80)
            .background(Theme.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .auraStroke(color: Theme.blue.opacity(0.1))
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }

    private func trackCard(track: RecoveryTrack) -> some View {
        VStack(spacing: 20) {
            HStack {
                Text(track.emoji)
                    .font(.system(size: 32))
                VStack(alignment: .leading, spacing: 2) {
                    Text(track.name)
                        .font(.system(size: 18, weight: .bold))
                    Text("Since \(track.startDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.midGrey)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(track.streak)")
                        .font(.system(size: 24, weight: .black))
                    Text("DAYS")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(Theme.midGrey)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("$\(String(format: "%.2f", track.totalSavings))")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Theme.green)
                    Text("TOTAL SAVED")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(Theme.midGrey)
                    Text("$\(String(format: "%.1f", track.dailySavings)) / day")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(Theme.blue.opacity(0.6))
                }
                Spacer()
                Button(action: {
                    if let index = store.recoveryTracks.firstIndex(where: { $0.id == track.id }) {
                        store.recoveryTracks.remove(at: index)
                        store.saveAll()
                    }
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.lightGrey)
                }
            }
        }
        .padding(24)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .auraStroke(color: Theme.blue.opacity(0.1))
    }
}

struct AddTrackView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var emoji = "🚫"
    @State private var savings = "10.00"
    
    let basicSubstances = [
        ("Alcohol", "🍷", 15.0),
        ("Nicotine", "💨", 10.0),
        ("Caffeine", "☕️", 5.0),
        ("Cannabis", "🌿", 12.0),
        ("Sugar", "🍩", 8.0),
        ("Social Media", "📱", 0.0),
        ("Gambling", "🎲", 50.0),
        ("Fast Food", "🍔", 15.0),
        ("Shopping", "🛍️", 20.0),
        ("Custom", "🚫", 10.0)
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Quick Select") {
                    Picker("Substance", selection: $name) {
                        Text("Select a substance").tag("")
                        ForEach(basicSubstances, id: \.0) { sub in
                            Text("\(sub.1) \(sub.0)").tag(sub.0)
                        }
                    }
                    .onChange(of: name) { oldValue, newValue in
                        if let sub = basicSubstances.first(where: { $0.0 == newValue }) {
                            emoji = sub.1
                            if savings == "10.00" || savings == "0.0" || savings.isEmpty {
                                savings = String(format: "%.2f", sub.2)
                            }
                        }
                    }
                }
                
                Section("Details") {
                    TextField("What are you tracking?", text: $name)
                    TextField("Emoji", text: $emoji)
                }
                
                Section("Financial Impact") {
                    TextField("Savings per day ($)", text: $savings)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("New Recovery Track")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        store.addRecoveryTrack(name: name, emoji: emoji, dailySavings: Double(savings) ?? 0)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

struct CravingLogView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss
    @State private var intensity = 3
    @State private var trigger = ""
    @State private var handled = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Craving Details") {
                    Stepper("Intensity: \(intensity)/5", value: $intensity, in: 1...5)
                    TextField("Trigger (e.g. Stress, Social)", text: $trigger)
                }
                Section("Outcome") {
                    Toggle("I handled this craving", isOn: $handled)
                }
            }
            .navigationTitle("Log Craving")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.addCravingEntry(intensity: intensity, trigger: trigger, handled: handled)
                        store.addXP(10)
                        dismiss()
                    }
                    .disabled(trigger.isEmpty)
                }
            }
        }
    }
}
