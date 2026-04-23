import Foundation
import SwiftUI
import Combine


// MARK: - Models
struct CravingEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let intensity: Int
    let trigger: String
    let wasHandled: Bool
}

struct RecoveryTrack: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var emoji: String
    var startDate: Date
    var dailySavings: Double
    
    var streak: Int {
        let diff = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        return max(0, diff)
    }
    
    var totalSavings: Double {
        Double(streak) * dailySavings
    }
}

struct TherapyReflection: Identifiable, Codable {
    let id: UUID
    let date: Date
    let toolType: String // "CBT", "DBT", "Anger"
    let content: [String: String] // Key-Value pairs for the specific tool fields
}

// MARK: - Data Store (UserDefaults persistence)
class DataStore: ObservableObject {
    static let shared = DataStore(userId: "default")

    private let prefix: String

    // MARK: - Chat
    @Published var chatMessages: [ChatMessage] = []
    @Published var chatTopics: [String: Int] = [:]
    @Published var visitCount: Int = 0

    // MARK: - Mood
    @Published var moodEntries: [MoodEntry] = []

    // MARK: - Journal
    @Published var journalEntries: [JournalEntry] = []

    // MARK: - Medications
    @Published var medications: [Medication] = []
    @Published var doses: [DoseRecord] = []
    @Published var sideEffects: [SideEffect] = []

    // MARK: - Assessments
    @Published var assessments: [AssessmentResult] = []
    @Published var lastAssessmentDate: String? = nil

    // MARK: - Gratitude
    @Published var gratitudeEntries: [GratitudeEntry] = []

    // MARK: - Sleep
    @Published var sleepEntries: [SleepEntry] = []

    // MARK: - Hope Box
    @Published var hopeBoxImages: [Data] = []
    
    // MARK: - Recovery
    @Published var recoveryTracks: [RecoveryTrack] = []
    @Published var cravingEntries: [CravingEntry] = []

    // MARK: - ML Tool Ranking
    @Published var toolScores: [String: Int] = [:]
    
    // MARK: - Journey (Gamification)
    @Published var totalXP: Int = 0
    @Published var level: Int = 1
    @Published var lastSeenRank: String = ""
    @Published var justLeveledUp = false
    @Published var dailyQuests: [Quest] = []
    @Published var selectedAuraID: String = "ice"
    @Published var safeSpaceActive: Bool = false
    @Published var isPremium: Bool = false
    @Published var notificationsEnabled: Bool = true
    @Published var hapticsEnabled: Bool = true
    @Published var dynamicAuraEnabled: Bool = true
    @Published var showAuraPicker: Bool = false
    @Published var hasCompletedOnboarding: Bool = false
    @Published var totalSessionsCompleted: Int = 0
    @Published var lastReviewRequestVersion: String = ""
    
    // MARK: - Cloud Sync
    @Published var lastSyncedAt: Date? = nil
    
    // MARK: - User Profile
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var userGender: String = "" // "Male", "Female", "Other"
    @Published var mentalConditions: [String] = []
    @Published var onboardingAnxietyLevel: Int? = nil
    
    // MARK: - Therapy Performance
    @Published var cbtScore: Int = 0
    @Published var dbtScore: Int = 0
    @Published var angerScore: Int = 0
    
    // MARK: - Feminine Wellness
    @Published var cycleEntries: [CycleEntry] = []
    @Published var wellnessGoals: [String] = []
    @Published var therapyReflections: [TherapyReflection] = []
    
    // MARK: - Premium Features
    @Published var auraShards: Int = 0
    @Published var safetyPlan: SafetyPlan = .empty
    @Published var windDownEnabled: Bool = false

    // MARK: - Clarity Rank
    struct ClarityRank: Identifiable, Equatable {
        var id: String { name }
        let name: String
        let minLogs: Int
        let maxLogs: Int
        let colorHex: String
        let symbol: String
    }

    static let clarityRanks = [
        ClarityRank(name: "Initiate", minLogs: 0, maxLogs: 5, colorHex: "86868b", symbol: "moon.fill"),
        ClarityRank(name: "Spark", minLogs: 6, maxLogs: 15, colorHex: "6366f1", symbol: "sparkles"),
        ClarityRank(name: "Visionary", minLogs: 16, maxLogs: 30, colorHex: "0071e3", symbol: "eye.fill"),
        ClarityRank(name: "Radiant", minLogs: 31, maxLogs: 50, colorHex: "8b5cf6", symbol: "sun.max.fill"),
        ClarityRank(name: "Pure Clarity", minLogs: 51, maxLogs: Int.max, colorHex: "1d1d1f", symbol: "diamond.fill")
    ]

    var totalLogs: Int { 
        moodEntries.count + 
        journalEntries.count + 
        doses.count + 
        assessments.count + 
        gratitudeEntries.count + 
        sleepEntries.count +
        cravingEntries.count
    }

    var currentClarityRank: ClarityRank {
        Self.clarityRanks.first { totalLogs >= $0.minLogs && totalLogs <= $0.maxLogs } ?? Self.clarityRanks[0]
    }

    var clarityProgress: Double {
        let rank = currentClarityRank
        let range = Double(rank.maxLogs - rank.minLogs + 1)
        let completed = Double(totalLogs - rank.minLogs)
        return completed / range
    }

    private let defaults: UserDefaults

    init(userId: String) {
        let safeId = String(userId.prefix(12).replacingOccurrences(of: ".", with: "_"))
        self.prefix = "wya_\(safeId)_"
        self.defaults = .standard
        
        loadAll()
    }

    func loadAll() {
        chatMessages = load("chat_messages") ?? []
        chatTopics = load("chat_topics") ?? [:]
        visitCount = defaults.integer(forKey: prefix + "visit_count")
        moodEntries = load("mood_entries") ?? []
        journalEntries = load("journal_entries") ?? []
        medications = load("medications") ?? []
        doses = load("doses") ?? []
        sideEffects = load("side_effects") ?? []
        assessments = load("assessments") ?? []
        lastAssessmentDate = defaults.string(forKey: prefix + "last_assessment")
        gratitudeEntries = load("gratitude_entries") ?? []
        sleepEntries = load("sleep_entries") ?? []
        hopeBoxImages = load("hope_box_images") ?? []
        toolScores = load("tool_scores") ?? [:]
        totalXP = defaults.integer(forKey: prefix + "total_xp")
        selectedAuraID = defaults.string(forKey: prefix + "selected_aura") ?? "ice"
        dailyQuests = load("daily_quests") ?? []
        recoveryTracks = load("recovery_tracks") ?? []
        cravingEntries = load("craving_entries") ?? []
        userName = defaults.string(forKey: prefix + "user_name") ?? ""
        userEmail = defaults.string(forKey: prefix + "user_email") ?? ""
        mentalConditions = load("mental_conditions") ?? []
        onboardingAnxietyLevel = defaults.object(forKey: prefix + "onboarding_anxiety") as? Int
        wellnessGoals = load("wellness_goals") ?? []
        userGender = defaults.string(forKey: prefix + "user_gender") ?? ""
        cycleEntries = load("cycle_entries") ?? []
        cbtScore = defaults.integer(forKey: prefix + "cbt_score")
        dbtScore = defaults.integer(forKey: prefix + "dbt_score")
        angerScore = defaults.integer(forKey: prefix + "anger_score")
        notificationsEnabled = defaults.bool(forKey: prefix + "notifications_enabled")
        hapticsEnabled = defaults.bool(forKey: prefix + "haptics_enabled")
        dynamicAuraEnabled = defaults.bool(forKey: prefix + "dynamic_aura_enabled")
        isPremium = defaults.bool(forKey: prefix + "is_premium")
        hasCompletedOnboarding = defaults.bool(forKey: prefix + "has_completed_onboarding")
        lastSeenRank = defaults.string(forKey: prefix + "last_seen_rank") ?? ""
        level = defaults.integer(forKey: prefix + "persisted_level")
        if level < 1 { level = 1 }
        therapyReflections = load("therapy_reflections") ?? []
        
        auraShards = defaults.integer(forKey: prefix + "aura_shards")
        safetyPlan = load("safety_plan") ?? .empty
        windDownEnabled = defaults.bool(forKey: prefix + "wind_down_enabled")
        
        calculateLevel()
        refreshQuestsIfNeeded()
        
        // Pull latest from cloud (async, merges if cloud is newer)
        CloudSyncService.shared.pull()
    }

    func saveAll() {
        save("chat_messages", chatMessages)
        save("chat_topics", chatTopics)
        defaults.set(visitCount, forKey: prefix + "visit_count")
        save("mood_entries", moodEntries)
        save("journal_entries", journalEntries)
        save("medications", medications)
        save("doses", doses)
        save("side_effects", sideEffects)
        save("assessments", assessments)
        save("gratitude_entries", gratitudeEntries)
        save("sleep_entries", sleepEntries)
        save("hope_box_images", hopeBoxImages)
        save("tool_scores", toolScores)
        defaults.set(totalXP, forKey: prefix + "total_xp")
        defaults.set(selectedAuraID, forKey: prefix + "selected_aura")
        save("daily_quests", dailyQuests)
        save("recovery_tracks", recoveryTracks)
        save("craving_entries", cravingEntries)
        defaults.set(userName, forKey: prefix + "user_name")
        defaults.set(userEmail, forKey: prefix + "user_email")
        save("mental_conditions", mentalConditions)
        defaults.set(onboardingAnxietyLevel, forKey: prefix + "onboarding_anxiety")
        save("wellness_goals", wellnessGoals)
        defaults.set(userGender, forKey: prefix + "user_gender")
        save("cycle_entries", cycleEntries)
        defaults.set(cbtScore, forKey: prefix + "cbt_score")
        defaults.set(dbtScore, forKey: prefix + "dbt_score")
        defaults.set(angerScore, forKey: prefix + "anger_score")
        defaults.set(notificationsEnabled, forKey: prefix + "notifications_enabled")
        defaults.set(hapticsEnabled, forKey: prefix + "haptics_enabled")
        defaults.set(dynamicAuraEnabled, forKey: prefix + "dynamic_aura_enabled")
        defaults.set(isPremium, forKey: prefix + "is_premium")
        defaults.set(hasCompletedOnboarding, forKey: prefix + "has_completed_onboarding")
        defaults.set(lastSeenRank, forKey: prefix + "last_seen_rank")
        defaults.set(level, forKey: prefix + "persisted_level")
        save("therapy_reflections", therapyReflections)
        defaults.set(auraShards, forKey: prefix + "aura_shards")
        save("safety_plan", safetyPlan)
        defaults.set(windDownEnabled, forKey: prefix + "wind_down_enabled")
        
        // Sync with widgets
        WidgetManager.shared.syncData(store: self)
        
        // Schedule cloud sync (debounced)
        CloudSyncService.shared.schedulePush()
    }

    func resetAllData() {
        moodEntries = []
        journalEntries = []
        medications = []
        doses = []
        sideEffects = []
        assessments = []
        gratitudeEntries = []
        sleepEntries = []
        hopeBoxImages = []
        recoveryTracks = []
        cravingEntries = []
        totalXP = 0
        level = 1
        hasCompletedOnboarding = false
        userName = ""
        userEmail = ""
        userGender = ""
        mentalConditions = []
        saveAll()
    }

    func addXP(_ amount: Int) {
        totalXP += amount
        calculateLevel()
        saveAll()
    }
    
    func incrementSessions() {
        totalSessionsCompleted += 1
        saveAll()
    }

    private func calculateLevel() {
        var currentLevel = 1
        var xp = totalXP
        while xp >= (currentLevel * 100) {
            xp -= (currentLevel * 100)
            currentLevel += 1
        }
        if currentLevel > level {
            level = currentLevel
            justLeveledUp = true
        } else {
            level = currentLevel
        }
    }

    private func refreshQuestsIfNeeded() {
        let today = todayKey()
        if dailyQuests.isEmpty || dailyQuests.first?.dateCreated != today {
            generateDailyQuests()
        }
    }

    private func generateDailyQuests() {
        let today = todayKey()
        let pool: [(String, Quest.QuestType, Int)] = [
            ("Log your mood today", .mood, 15),
            ("Finish a breathing exercise", .breathing, 20),
            ("Write a journal entry", .journal, 25),
            ("Record your sleep", .sleep, 15),
            ("Take your medications", .medication, 10),
            ("Take a mental health assessment", .assessment, 30),
            ("Practice CBT Reframing", .cbt, 25),
            ("Practice DBT Grounding", .dbt, 25),
            ("Practice Anger Regulation", .anger, 25),
            ("Log 3 things you're grateful for", .journal, 20),
            ("Check your recovery progress", .recovery, 20)
        ]
        let shuffled = pool.shuffled()
        dailyQuests = shuffled.prefix(3).map { item in
            Quest(id: UUID(), title: item.0, xpReward: item.2, isCompleted: false, type: item.1, dateCreated: today)
        }
        saveAll()
    }

    func todayKey() -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: Date())
    }

    func saveAssessments() {
        save("assessments", assessments)
        defaults.set(lastAssessmentDate, forKey: prefix + "last_assessment")
    }

    private func save<T: Encodable>(_ key: String, _ value: T) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: prefix + key)
        }
    }

    private func load<T: Decodable>(_ key: String) -> T? {
        guard let data = defaults.data(forKey: prefix + key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    // MARK: - Clinical Helpers
    func currentDateString() -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: Date())
    }

    func addMoodLog(mood: Int, triggers: [String], notes: String) {
        let entry = MoodEntry(mood: mood, journal: notes, triggers: triggers)
        moodEntries.append(entry)
        
        // Dynamic Mood Ring Logic
        // 1-2: Red (storm), 3: Yellow (sunlight), 4: Green (forest), 5: Blue (ice)
        if dynamicAuraEnabled {
            switch mood {
            case 1, 2: selectedAuraID = "storm"
            case 3:    selectedAuraID = "sunlight"
            case 4:    selectedAuraID = "forest"
            case 5:    selectedAuraID = "ice"
            default:   selectedAuraID = "ice"
            }
        }
        
        saveAll()
    }

    func addJournalEntry(prompt: String, text: String, distortions: [String]) {
        let entry = JournalEntry(text: text, prompt: prompt, distortions: distortions)
        journalEntries.append(entry)
        saveAll()
    }

    func addMedication(name: String, dose: String, time: String) {
        let med = Medication(name: name, dosage: dose, frequency: "daily", times: [time], colorIndex: Int.random(in: 0...5))
        medications.append(med)
        saveAll()
    }

    func logMedication(id: String) {
        let record = DoseRecord(medId: id, date: currentDateString(), time: "Now")
        doses.append(record)
        saveAll()
    }

    func addSleepEntry(hours: Double, quality: Int) {
        let entry = SleepEntry(hours: hours, quality: quality)
        sleepEntries.append(entry)
        saveAll()
    }

    func trackToolUsage(title: String, wasHelpful: Bool) {
        toolScores[title, default: 0] += wasHelpful ? 1 : -1
        saveAll()
    }

    func getTopTriggers() -> [(String, Int)] {
        var counts: [String: Int] = [:]
        for entry in moodEntries {
            for trigger in entry.triggers {
                counts[trigger, default: 0] += 1
            }
        }
        return counts.sorted { $0.value > $1.value }
    }
    
    func completeQuest(type: Quest.QuestType) {
        if let index = dailyQuests.firstIndex(where: { $0.type == type && !$0.isCompleted }) {
            dailyQuests[index].isCompleted = true
            addXP(dailyQuests[index].xpReward)
        }
    }

    func addRecoveryTrack(name: String, emoji: String, dailySavings: Double) {
        let track = RecoveryTrack(id: UUID(), name: name, emoji: emoji, startDate: Date(), dailySavings: dailySavings)
        recoveryTracks.append(track)
        saveAll()
    }

    func addSideEffect(medId: String, effect: String, severity: Int, notes: String) {
        let entry = SideEffect(medId: medId, effect: effect, severity: severity, notes: notes)
        sideEffects.append(entry)
        saveAll()
    }

    func addCravingEntry(intensity: Int, trigger: String, handled: Bool) {
        let entry = CravingEntry(id: UUID(), date: Date(), intensity: intensity, trigger: trigger, wasHandled: handled)
        cravingEntries.append(entry)
        completeQuest(type: .recovery)
        saveAll()
    }

    // MARK: - Premium Methods
    func addAuraShards(_ amount: Int, source: String) {
        auraShards += amount
        // Also add a log entry if we want to track history later
        saveAll()
    }

    func updateSafetyPlan(_ plan: SafetyPlan) {
        safetyPlan = plan
        saveAll()
    }

    // MARK: - Cloud Sync Snapshot

    /// Serialize the current state into a snapshot for cloud upload.
    func toSnapshot() -> UserDataSnapshot {
        UserDataSnapshot(
            schemaVersion: UserDataSnapshot.currentSchemaVersion,
            updatedAt: Date(),
            userName: userName,
            userEmail: userEmail,
            userGender: userGender,
            mentalConditions: mentalConditions,
            onboardingAnxietyLevel: onboardingAnxietyLevel,
            wellnessGoals: wellnessGoals,
            moodEntries: moodEntries,
            journalEntries: journalEntries,
            medications: medications,
            doses: doses,
            sideEffects: sideEffects,
            assessments: assessments,
            lastAssessmentDate: lastAssessmentDate,
            gratitudeEntries: gratitudeEntries,
            sleepEntries: sleepEntries,
            cycleEntries: cycleEntries,
            recoveryTracks: recoveryTracks,
            cravingEntries: cravingEntries,
            therapyReflections: therapyReflections,
            cbtScore: cbtScore,
            dbtScore: dbtScore,
            angerScore: angerScore,
            safetyPlan: safetyPlan,
            totalXP: totalXP,
            level: level,
            selectedAuraID: selectedAuraID,
            auraShards: auraShards,
            totalSessionsCompleted: totalSessionsCompleted,
            notificationsEnabled: notificationsEnabled,
            hapticsEnabled: hapticsEnabled,
            dynamicAuraEnabled: dynamicAuraEnabled,
            isPremium: isPremium
        )
    }

    /// Apply a cloud snapshot to local state and persist.
    func apply(snapshot s: UserDataSnapshot) {
        userName = s.userName
        userEmail = s.userEmail
        userGender = s.userGender
        mentalConditions = s.mentalConditions
        onboardingAnxietyLevel = s.onboardingAnxietyLevel
        wellnessGoals = s.wellnessGoals
        moodEntries = s.moodEntries
        journalEntries = s.journalEntries
        medications = s.medications
        doses = s.doses
        sideEffects = s.sideEffects
        assessments = s.assessments
        lastAssessmentDate = s.lastAssessmentDate
        gratitudeEntries = s.gratitudeEntries
        sleepEntries = s.sleepEntries
        cycleEntries = s.cycleEntries
        recoveryTracks = s.recoveryTracks
        cravingEntries = s.cravingEntries
        therapyReflections = s.therapyReflections
        cbtScore = s.cbtScore
        dbtScore = s.dbtScore
        angerScore = s.angerScore
        safetyPlan = s.safetyPlan
        totalXP = s.totalXP
        level = s.level
        selectedAuraID = s.selectedAuraID
        auraShards = s.auraShards
        totalSessionsCompleted = s.totalSessionsCompleted
        notificationsEnabled = s.notificationsEnabled
        hapticsEnabled = s.hapticsEnabled
        dynamicAuraEnabled = s.dynamicAuraEnabled
        isPremium = s.isPremium
        lastSyncedAt = s.updatedAt

        // Persist locally (but don't re-trigger cloud push to avoid loop)
        let encoder = JSONEncoder()
        func localSave<T: Encodable>(_ key: String, _ value: T) {
            if let data = try? encoder.encode(value) {
                defaults.set(data, forKey: prefix + key)
            }
        }
        localSave("mood_entries", moodEntries)
        localSave("journal_entries", journalEntries)
        localSave("medications", medications)
        localSave("doses", doses)
        localSave("side_effects", sideEffects)
        localSave("assessments", assessments)
        localSave("gratitude_entries", gratitudeEntries)
        localSave("sleep_entries", sleepEntries)
        localSave("cycle_entries", cycleEntries)
        localSave("recovery_tracks", recoveryTracks)
        localSave("craving_entries", cravingEntries)
        localSave("therapy_reflections", therapyReflections)
        localSave("safety_plan", safetyPlan)
        localSave("mental_conditions", mentalConditions)
        localSave("wellness_goals", wellnessGoals)
        defaults.set(userName, forKey: prefix + "user_name")
        defaults.set(userEmail, forKey: prefix + "user_email")
        defaults.set(userGender, forKey: prefix + "user_gender")
        defaults.set(onboardingAnxietyLevel, forKey: prefix + "onboarding_anxiety")
        defaults.set(lastAssessmentDate, forKey: prefix + "last_assessment")
        defaults.set(totalXP, forKey: prefix + "total_xp")
        defaults.set(level, forKey: prefix + "persisted_level")
        defaults.set(selectedAuraID, forKey: prefix + "selected_aura")
        defaults.set(auraShards, forKey: prefix + "aura_shards")
        defaults.set(cbtScore, forKey: prefix + "cbt_score")
        defaults.set(dbtScore, forKey: prefix + "dbt_score")
        defaults.set(angerScore, forKey: prefix + "anger_score")
        defaults.set(notificationsEnabled, forKey: prefix + "notifications_enabled")
        defaults.set(hapticsEnabled, forKey: prefix + "haptics_enabled")
        defaults.set(dynamicAuraEnabled, forKey: prefix + "dynamic_aura_enabled")
        defaults.set(isPremium, forKey: prefix + "is_premium")

        calculateLevel()
    }
}
