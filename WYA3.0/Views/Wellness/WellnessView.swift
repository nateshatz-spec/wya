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
            ZStack {
                // Background
                Theme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Your Wellness")
                                    .font(.system(size: 28, weight: .black))
                                    .foregroundColor(.white)
                                Text("Find your clarity today")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            Spacer()
                            Image(systemName: "sparkles")
                                .font(.system(size: 24))
                                .foregroundColor(Theme.blue)
                                .shadow(color: Theme.blue, radius: 10)
                        }
                        .padding(.top, 20)
                        
                        // Crisis Support (Pinned to top)
                        crisisCard
                        
                        // Daily Mission / Mood Check-in
                        if store.moodEntries.isEmpty {
                            dailyMissionCard
                        } else {
                            moodCheckIn
                        }
                        
                        // Featured Resource
                        featuredCard
                        
                        // Tool Grid Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Clinical Lab")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            toolGrid()
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
            }
            .navigationBarHidden(true)
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
                        .fill(Theme.red.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "exclamationmark.shield.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Theme.red)
                        .shadow(color: Theme.red.opacity(0.5), radius: 5)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Crisis Support")
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(.white)
                    Text("Immediate help resources")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
                
                Text("HELP")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Theme.red)
                    .clipShape(Capsule())
                    .shadow(color: Theme.red.opacity(0.4), radius: 10)
            }
            .padding(16)
            .background(Theme.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .auraStroke(color: Theme.red.opacity(0.2), radius: 24)
        }
        .buttonStyle(.plain)
    }
    
    private var featuredCard: some View {
        let resource = ResourceLibrary.thisWeek
        return NavigationLink(destination: ResourceDetailView(resource: resource)) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("FEATURED")
                        .font(.system(size: 11, weight: .black))
                        .kerning(1)
                        .foregroundColor(Color(hex: resource.color))
                    Spacer()
                    Image(systemName: resource.icon)
                        .foregroundColor(Color(hex: resource.color))
                        .font(.system(size: 18))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(resource.title)
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(.white)
                    
                    Text(resource.subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(2)
                        .lineSpacing(4)
                }
            }
            .padding(24)
            .background(Theme.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .auraStroke(color: Color(hex: resource.color).opacity(0.2))
        }
        .buttonStyle(.plain)
    }
    
    private var moodCheckIn: some View {
        Button(action: { showingMoodLog = true }) {
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Theme.blue.opacity(0.15))
                        .frame(width: 56, height: 56)
                    Image(systemName: "face.smiling.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Theme.blue)
                        .shadow(color: Theme.blue.opacity(0.5), radius: 8)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mood Check-in")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Text("How are you feeling right now?")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.2))
            }
            .padding(20)
            .background(Theme.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .auraStroke(color: Theme.blue.opacity(0.15))
        }
        .buttonStyle(.plain)
    }
    
    private var dailyMissionCard: some View {
        Button(action: { showingMoodLog = true }) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("DAILY MISSION")
                        .font(.system(size: 11, weight: .black))
                        .kerning(1)
                        .foregroundColor(Theme.blue)
                    Spacer()
                    Image(systemName: "target")
                        .foregroundColor(Theme.blue)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Log First Mood")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(.white)
                    Text("Unlock your AI Clarity Report and start your recovery journey today.")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                        .lineSpacing(4)
                }
                
                HStack {
                    Text("GET STARTED")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(Theme.blue)
                        .clipShape(Capsule())
                        .shadow(color: Theme.blue.opacity(0.4), radius: 10)
                    
                    Spacer()
                    Image(systemName: "sparkles")
                        .foregroundColor(Theme.blue.opacity(0.4))
                }
                .padding(.top, 8)
            }
            .padding(24)
            .background(Theme.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .auraStroke(color: Theme.blue.opacity(0.2))
        }
        .buttonStyle(.plain)
    }

    private func toolGrid() -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
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
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.15))
                .clipShape(Circle())
                .shadow(color: color.opacity(0.3), radius: 5)
            
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .auraStroke(color: color.opacity(0.1))
    }
    
    private func toolCard<V: View>(title: String, icon: String, color: Color, destination: V) -> some View {
        NavigationLink(destination: destination) {
            toolCardLabel(title: title, icon: icon, color: color)
        }
        .buttonStyle(.plain)
    }
}
