import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject var store: DataStore
    @State private var showingExport = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.mainSpacing) {
                    // MARK: - Aura Intelligence
                    auraIntelligenceCard
                    
                    // MARK: - AI Insights
                    VStack(alignment: .leading, spacing: 16) {
                        headerSection(title: String(localized: "AI CLARITY REPORT"), icon: "sparkles")
                        
                        VStack(spacing: 20) {
                            let insights = AIManager.shared.generateInsights(store: store)
                            if insights.isEmpty {
                                Text(String(localized: "Logging more data will unlock deeper AI insights."))
                                    .font(.system(size: 14))
                                    .foregroundColor(Theme.midGrey)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 20)
                            } else {
                                ForEach(insights) { insight in
                                    HStack(spacing: 16) {
                                        ZStack {
                                            Circle()
                                                .fill(Theme.blue.opacity(0.1))
                                                .frame(width: 44, height: 44)
                                            Image(systemName: insight.icon)
                                                .foregroundColor(Theme.blue)
                                                .font(.system(size: 18, weight: .bold))
                                        }
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(insight.title)
                                                .font(.system(size: 14, weight: .black))
                                                .foregroundColor(Theme.nearBlack)
                                            Text(insight.content)
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundColor(Theme.darkGrey)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .lineSpacing(2)
                                        }
                                    }
                                    .accessibilityElement(children: .combine)
                                    .accessibilityLabel("\(insight.title): \(insight.content)")
                                    
                                    if insight.id != insights.last?.id {
                                        Divider().background(Theme.blue.opacity(0.05))
                                    }
                                }
                            }
                        }
                        .padding(24)
                        .background(Theme.cardBg)
                        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                        .auraStroke(color: Theme.blue.opacity(0.15))
                        .shadow(color: .black.opacity(0.04), radius: 20, y: 12)
                    }

                    // MARK: - Mood Trends
                    VStack(alignment: .leading, spacing: 16) {
                        headerSection(title: String(localized: "MOOD TRENDS"), icon: "waveform.path.ecg")
                        
                        if store.moodEntries.isEmpty {
                            emptyState(text: String(localized: "Log your mood for a few days to see trends."))
                        } else {
                            MoodMiniChart(logs: store.moodEntries)
                                .frame(height: 180)
                                .padding(20)
                                .background(Theme.cardBg)
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        }
                    }
                    
                    // MARK: - Triggers
                    VStack(alignment: .leading, spacing: 16) {
                        headerSection(title: String(localized: "TOP TRIGGERS"), icon: "bolt.fill")
                        
                        let triggers = store.getTopTriggers()
                        if triggers.isEmpty {
                            emptyState(text: String(localized: "Patterns will appear as you log more data."))
                        } else {
                            let maxCount = max(triggers.first?.1 ?? 1, 1)
                            VStack(spacing: 12) {
                                ForEach(triggers.prefix(5), id: \.0) { trigger, count in
                                    triggerRow(name: trigger, count: count, max: maxCount)
                                }
                            }
                            .padding(20)
                            .background(Theme.cardBg)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        }
                    }
                    
                    // MARK: - Sleep vs Mood
                    VStack(alignment: .leading, spacing: 16) {
                        headerSection(title: "LIFESTYLE IMPACT", icon: "moon.stars.fill")
                        
                        VStack(spacing: 16) {
                            let avgSleep = store.sleepEntries.isEmpty ? 0 : store.sleepEntries.map { $0.hours }.reduce(0, +) / Double(store.sleepEntries.count)
                            impactRow(label: "Sleep Average", value: "\(String(format: "%.1f", avgSleep))h", icon: "bed.double.fill", color: .purple)
                            
                            let medCount = store.doses.filter { $0.date == store.currentDateString() }.count
                            let totalScheduled = store.medications.count
                            let adherence = totalScheduled == 0 ? 0 : (Double(medCount) / Double(totalScheduled)) * 100
                            impactRow(label: "Today's Adherence", value: "\(Int(adherence))%", icon: "pills.fill", color: .green)
                            
                            let totalSavings = store.recoveryTracks.map { $0.totalSavings }.reduce(0, +)
                            impactRow(label: "Total Savings", value: "$\(Int(totalSavings))", icon: "dollarsign.circle.fill", color: .green)
                            
                            let cravingsManaged = store.cravingEntries.filter { $0.wasHandled }.count
                            impactRow(label: "Cravings Managed", value: "\(cravingsManaged)", icon: "bolt.shield.fill", color: .orange)

                            impactRow(label: "Journal Reflections", value: "\(store.journalEntries.count)", icon: "pencil.and.outline", color: .blue)
                        }
                        .padding(20)
                        .background(Theme.cardBg)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    }
                    
                    // MARK: - Clinical Performance
                    VStack(alignment: .leading, spacing: 16) {
                        headerSection(title: "CLINICAL SKILLS", icon: "hammer.fill")
                        
                        VStack(spacing: 16) {
                            impactRow(label: "CBT Reframing", value: "\(store.cbtScore) pts", icon: "brain.head.profile", color: .blue)
                            impactRow(label: "DBT Grounding", value: "\(store.dbtScore) pts", icon: "flowchart.fill", color: .purple)
                            impactRow(label: "Anger Regulation", value: "\(store.angerScore) pts", icon: "flame.fill", color: .orange)
                        }
                        .padding(20)
                        .background(Theme.cardBg)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    }
                }
                .padding(Theme.mainPadding)
            }
            .navigationTitle("Analytics")
            .background(Theme.offWhite)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingExport = true }) {
                        Image(systemName: "doc.text.below.ecg.fill")
                            .foregroundColor(Theme.blue)
                    }
                }
            }
            .sheet(isPresented: $showingExport) {
                ClinicalExportView()
            }
            .locked(feature: "Advanced Analytics", description: "Unlock AI insights, trigger tracking, and clinical trend reporting.")
        }
    }
    
    private var auraIntelligenceCard: some View {
        NavigationLink(destination: AuraIntelligenceView()) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Theme.blue.opacity(0.1))
                            .frame(width: 40, height: 40)
                        Image(systemName: "sparkles")
                            .foregroundColor(Theme.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Aura Intelligence")
                            .font(.system(size: 17, weight: .black))
                            .foregroundColor(Theme.nearBlack)
                        Text("View correlations & predictions")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.midGrey)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Theme.lightGrey)
                }
            }
            .padding(20)
            .background(Theme.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .auraStroke(color: Theme.blue.opacity(0.15))
        }
        .buttonStyle(.plain)
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
    
    private func emptyState(text: String) -> some View {
        VStack(spacing: 24) {
            Image("analytics_empty_state")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: Theme.blue.opacity(0.1), radius: 10)
            
            VStack(spacing: 8) {
                Text("Waiting for Data")
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(Theme.nearBlack)
                Text(text)
                    .font(.system(size: 14))
                    .foregroundColor(Theme.midGrey)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .auraStroke(color: Theme.blue.opacity(0.1))
    }
    
    private func triggerRow(name: String, count: Int, max: Int) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(name).font(.system(size: 14, weight: .bold))
                Spacer()
                Text("\(count) logs").font(.system(size: 12)).foregroundColor(Theme.midGrey)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.offWhite).frame(height: 8)
                    Capsule().fill(Theme.blue).frame(width: geo.size.width * CGFloat(Double(count)/Double(max)), height: 8)
                }
            }
            .frame(height: 8)
        }
    }
    
    private func impactRow(label: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(color.opacity(0.1)).frame(width: 40, height: 40)
                Image(systemName: icon).foregroundColor(color).font(.system(size: 16))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.system(size: 14, weight: .bold))
                Text("Impact on Clarity: High").font(.system(size: 11)).foregroundColor(Theme.midGrey)
            }
            Spacer()
            Text(value).font(.system(size: 15, weight: .black)).foregroundColor(Theme.nearBlack)
        }
    }
}

struct MoodMiniChart: View {
    let logs: [MoodEntry]
    
    var body: some View {
        let recent = logs.suffix(7)
        HStack(alignment: .bottom, spacing: 12) {
            ForEach(recent) { log in
                VStack(spacing: 8) {
                    ZStack(alignment: .bottom) {
                        Capsule().fill(Theme.offWhite).frame(width: 20, height: 100)
                        Capsule().fill(moodColor(log.mood)).frame(width: 20, height: CGFloat(log.mood * 20))
                    }
                    Text(String(log.date.suffix(2)))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Theme.midGrey)
                }
                .frame(maxWidth: .infinity)
            }
        }
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
