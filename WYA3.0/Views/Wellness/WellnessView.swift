import SwiftUI

struct WellnessView: View {
    @EnvironmentObject var store: DataStore
    @State private var showingMoodLog = false
    @State private var showingBreathing = false
    @State private var showingJournal = false
    @State private var showingHopeBox = false
    @State private var showingCrisis = false
    @State private var showingSleep = false
    @State private var showingAssessments = false
    @State private var showingCBT = false
    @State private var showingDBT = false
    @State private var showingAnger = false
    @State private var activeInsight: AIInsight? = nil
    @State private var hasShownInsight = false
    @EnvironmentObject var tabStore: TabStore
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.mainSpacing) {
                    // Crisis Support
                    crisisCard
                    
                    // Featured Resource
                    featuredCard
                    
                    // Daily Check-in or Empty State Mission
                    if store.moodEntries.isEmpty {
                        dailyMissionCard
                    } else {
                        moodCheckIn
                    }
                    
                    // Clinical Tools
                    toolGrid()
                }
                .padding(Theme.mainPadding)
            }
            .navigationTitle(String(localized: "Wellness"))
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                        Text(String(localized: "AI POWERED"))
                            .font(.system(size: 10, weight: .black))
                    }
                    .foregroundColor(Theme.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.blue.opacity(0.1))
                    .clipShape(Capsule())
                    .accessibilityLabel("AI Powered Features")
                    .accessibilityAddTraits(.isHeader)
                }
            }
            .background(Theme.offWhite)
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        activeInsight = AIManager.shared.getProactiveTip(context: .wellness, store: store)
                        hasShownInsight = true
                    }
                }
            }
            .fullScreenCover(isPresented: $showingCrisis) {
                CrisisCommandView()
            }
            .fullScreenCover(isPresented: $showingBreathing) { BreathingView() }
            .sheet(isPresented: $showingMoodLog) { MoodLogView() }
            .sheet(isPresented: $showingJournal) { JournalView() }
            .sheet(isPresented: $showingSleep) { SleepLogView() }
            .sheet(isPresented: $showingAssessments) { AssessmentView() }
            .onReceive(tabStore.$activeQuestType) { type in
                guard let type = type else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    switch type {
                    case .mood: showingMoodLog = true
                    case .breathing: showingBreathing = true
                    case .journal: showingJournal = true
                    case .sleep: showingSleep = true
                    case .assessment: showingAssessments = true
                    case .cbt: showingCBT = true
                    case .dbt: showingDBT = true
                    case .anger: showingAnger = true
                    default: break
                    }
                    tabStore.activeQuestType = nil
                }
            }
            .sheet(isPresented: $showingCBT) { CBTThoughtReframerView() }
            .sheet(isPresented: $showingDBT) { DBTFocusFlowView() }
            .sheet(isPresented: $showingAnger) { AngerManagementView() }
        }
    }
    
    private var crisisCard: some View {
        Button(action: { showingCrisis = true }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Theme.red.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: "exclamationmark.shield.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Theme.red)
                }
                
                Text(String(localized: "Crisis Support"))
                    .font(.system(size: 15, weight: .black))
                    .foregroundColor(Theme.nearBlack)
                
                Spacer()
                
                Text(String(localized: "HELP NOW"))
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Theme.red)
                    .clipShape(Capsule())
            }
            .padding(12)
            .background(Theme.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .auraStroke(color: Theme.red.opacity(0.1), radius: 18)
            .accessibilityLabel("Crisis Support. Get help now.")
            .accessibilityHint("Opens emergency contacts and resources.")
        }
        .buttonStyle(.plain)
    }
    
    private var featuredCard: some View {
        let resource = ResourceLibrary.thisWeek
        return NavigationLink(destination: ResourceDetailView(resource: resource)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("FEATURED THIS WEEK")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(Color(hex: resource.color))
                    Spacer()
                    Image(systemName: resource.icon)
                        .foregroundColor(Color(hex: resource.color))
                }
                
                Text(resource.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Theme.nearBlack)
                
                Text(resource.subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(Theme.darkGrey)
                    .lineLimit(2)
            }
            .padding(20)
            .background(Theme.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusXl, style: .continuous))
            .auraStroke(color: Color(hex: resource.color).opacity(0.2))
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
    
    private var moodCheckIn: some View {
        Button(action: { showingMoodLog = true }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Theme.blue.opacity(0.1))
                        .frame(width: 48, height: 48)
                    Image(systemName: "face.smiling.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Theme.blue)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Log Your Mood")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Theme.nearBlack)
                    Text("Check in with yourself")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.midGrey)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Theme.lightGrey)
            }
            .padding(16)
            .background(Theme.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusXl, style: .continuous))
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
    
    private var dailyMissionCard: some View {
        Button(action: { showingMoodLog = true }) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("DAILY MISSION")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(Theme.blue)
                    Spacer()
                    Image(systemName: "target")
                        .foregroundColor(Theme.blue)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Start Your Journey")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(Theme.nearBlack)
                    Text("Your dashboard is waiting. Log your first mood to unlock AI insights and personalized tools.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.darkGrey)
                        .lineSpacing(4)
                }
                
                HStack {
                    Text("LOG FIRST MOOD")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Theme.blue)
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 20))
                        .foregroundColor(Theme.blue.opacity(0.3))
                }
                .padding(.top, 8)
            }
            .padding(24)
            .background(Theme.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .auraStroke(color: Theme.blue.opacity(0.15))
        }
        .buttonStyle(.plain)
    }

    private func toolGrid() -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            toolCard(title: "Assessments", icon: "cloud.rain.fill", color: Theme.blue, destination: AssessmentView())
            toolCard(title: "Somatic Lab", icon: "figure.walk.motion", color: Theme.blue, destination: SomaticLabView())
            toolCard(title: "Daily Article", icon: "doc.text.fill", color: Theme.orange, destination: PersonalizedArticleView())
            
            Button(action: { showingBreathing = true }) {
                toolCardLabel(title: "Breathing", icon: "wind", color: Theme.green)
            }
            .buttonStyle(.plain)
            
            Button(action: { showingJournal = true }) {
                toolCardLabel(title: "Journal", icon: "pencil.and.outline", color: Theme.blue)
            }
            .buttonStyle(.plain)

            toolCard(title: "Hope Box", icon: "archivebox.fill", color: Theme.orange, destination: HopeBoxView())

            toolCard(title: "Sleep", icon: "moon.fill", color: Color(hex: "6366f1"), destination: SleepLogView())
            
            if store.userGender == "Female" {
                toolCard(title: "Cycle", icon: "drop.fill", color: .pink, destination: CycleTrackerView())
            }

            toolCard(title: "CBT Lab", icon: "brain.head.profile", color: Theme.blue, destination: CBTThoughtReframerView())
            toolCard(title: "DBT Lab", icon: "flowchart.fill", color: .purple, destination: DBTFocusFlowView())
            toolCard(title: "Anger Lab", icon: "flame.fill", color: .orange, destination: AngerManagementView())
        }
    }
    
    
    private func toolCardLabel(title: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Theme.nearBlack)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusLg, style: .continuous))
        .auraStroke(color: color.opacity(0.1))
    }
    
    private func toolCard<V: View>(title: String, icon: String, color: Color, destination: V) -> some View {
        NavigationLink(destination: destination) {
            toolCardLabel(title: title, icon: icon, color: color)
        }
        .buttonStyle(.plain)
    }
}
