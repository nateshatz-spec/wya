import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: DataStore
    @EnvironmentObject var auth: AuthManager
    @EnvironmentObject var tabStore: TabStore
    @State private var activeInsight: AIInsight? = nil
    @State private var hasShownInsight = false
    @State private var showingDebug = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.mainSpacing) {
                    headerSection
                    
                    VStack(alignment: .leading, spacing: 32) {
                        clarityPathSection
                        dailyQuestsSection
                        focusAreasSection
                        achievementsSection
                        auraActionsSection
                    }
                }
                .padding(Theme.mainPadding)
            }
            .background(Theme.offWhite)
            .navigationTitle(String(localized: "Profile"))
            .navigationBarTitleDisplayMode(.inline)
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
                        activeInsight = AIManager.shared.getProactiveTip(context: .home, store: store)
                        hasShownInsight = true
                    }
                }
            }
            .sheet(isPresented: $showingDebug) {
                DebugMenuView()
            }
        }
    }
    
    private var appIconSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "APP ICON"))
                .font(.system(size: 10, weight: .black))
                .foregroundColor(Theme.midGrey)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(AppIcon.allCases) { icon in
                        Button(action: { IconManager.shared.setIcon(icon) }) {
                            VStack(spacing: 8) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(icon.previewColor.gradient)
                                        .frame(width: 60, height: 60)
                                        .shadow(color: icon.previewColor.opacity(0.3), radius: 5)
                                    
                                    if IconManager.shared.currentIcon == icon {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 20, weight: .bold))
                                            .shadow(radius: 2)
                                    }
                                }
                                
                                Text(icon.displayName)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(Theme.nearBlack)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding(16)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .auraStroke(color: Theme.blue.opacity(0.1))
    }

    private var headerSection: some View {
        HStack(spacing: 20) {
            ZStack(alignment: .bottomTrailing) {
                LinearGradient(colors: [Color(hex: "4b5563"), Color(hex: "1f2937")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                
                NavigationLink(destination: MoreView()) {
                    Circle()
                        .fill(Theme.blue)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .shadow(radius: 4)
                        .offset(x: 4, y: 4)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(store.userName.isEmpty ? auth.displayName.uppercased() : store.userName.uppercased())
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(Theme.nearBlack)
                    .onLongPressGesture(minimumDuration: 2.0) {
                        showingDebug = true
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    }
                
                VStack(alignment: .leading, spacing: 4) {
                    Label(store.userEmail, systemImage: "envelope")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Theme.midGrey)
                    
                    Label("VERIFIED", systemImage: "checkmark.shield.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Theme.blue)
                    
                    if store.isPremium {
                        Label("PLUS", systemImage: "crown.fill")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 4)
    }
    
    private var clarityPathSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionLabel(icon: "sparkles", text: String(localized: "CLARITY PATH"))
            ClarityLevelView()
        }
    }
    
    private var dailyQuestsSection: some View {
        Group {
            if !store.dailyQuests.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    sectionLabel(icon: "list.bullet.circle.fill", text: String(localized: "DAILY QUESTS"))
                    
                    VStack(spacing: 12) {
                        ForEach(store.dailyQuests) { quest in
                            Button(action: { navigateToQuest(quest) }) {
                                HStack(spacing: 16) {
                                    Image(systemName: quest.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(quest.isCompleted ? Theme.green : Theme.lightGrey)
                                        .font(.system(size: 20))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(quest.title)
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(quest.isCompleted ? Theme.midGrey : Theme.nearBlack)
                                            .strikethrough(quest.isCompleted)
                                        
                                        Text("+\(quest.xpReward) XP")
                                            .font(.system(size: 11, weight: .black))
                                            .foregroundColor(Theme.blue)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(Theme.lightGrey)
                                }
                                .padding(16)
                                .background(Theme.cardBg)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .auraStroke(color: quest.isCompleted ? Theme.green.opacity(0.1) : Theme.blue.opacity(0.1))
                            }
                            .buttonStyle(.plain)
                            .contentShape(Rectangle())
                            .disabled(quest.isCompleted)
                        }
                    }
                }
            }
        }
    }
    
    private var focusAreasSection: some View {
        Group {
            if !store.mentalConditions.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    sectionLabel(icon: "target", text: String(localized: "FOCUS AREAS"))
                    
                    FlowLayout(spacing: 8) {
                        ForEach(store.mentalConditions, id: \.self) { condition in
                            Text(condition)
                                .font(.system(size: 10, weight: .black))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Theme.blue.opacity(0.1))
                                .foregroundColor(Theme.blue)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionLabel(icon: "medal.fill", text: String(localized: "ACHIEVEMENTS"))
            AchievementsListView()
        }
    }
    
    private var auraActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionLabel(icon: "sparkles", text: String(localized: "AURA ACTIONS"))
            
            Button(action: { 
                WallpaperManager.exportWallpaper(palette: .fromID(store.selectedAuraID))
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Export Aura Wallpaper")
                            .font(.system(size: 15, weight: .bold))
                        Text("Save your current vibe to Photos")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.midGrey)
                    }
                    Spacer()
                    Image(systemName: "square.and.arrow.down.fill")
                        .foregroundColor(Theme.blue)
                }
                .padding(16)
                .background(Theme.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .auraStroke(color: Theme.blue.opacity(0.1))
            }
            .buttonStyle(.plain)
            
            if store.isPremium {
                appIconSection
            }
        }
    }

    private func sectionLabel(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
            Text(text)
                .font(.system(size: 11, weight: .black))
                .kerning(1)
        }
        .foregroundColor(Theme.midGrey)
        .padding(.horizontal, 4)
    }

    private func navigateToQuest(_ quest: Quest) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        tabStore.activeQuestType = quest.type
        
        switch quest.type {
        case .mood, .breathing, .sleep, .assessment, .journal, .cbt, .dbt, .anger:
            tabStore.selectedTab = .wellness
        case .medication:
            tabStore.selectedTab = .meds
        case .recovery:
            tabStore.selectedTab = .prevention
        }
    }
}
