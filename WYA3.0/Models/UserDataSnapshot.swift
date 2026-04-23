import Foundation

/// Full snapshot of user data for cloud sync.
/// Mirrors the relevant `DataStore` state so it can be serialized/deserialized as a single JSON blob.
struct UserDataSnapshot: Codable {
    /// Schema version for future migration support
    let schemaVersion: Int
    /// When this snapshot was created
    let updatedAt: Date

    // MARK: - User Profile
    var userName: String
    var userEmail: String
    var userGender: String
    var mentalConditions: [String]
    var onboardingAnxietyLevel: Int?
    var wellnessGoals: [String]

    // MARK: - Clinical Data
    var moodEntries: [MoodEntry]
    var journalEntries: [JournalEntry]
    var medications: [Medication]
    var doses: [DoseRecord]
    var sideEffects: [SideEffect]
    var assessments: [AssessmentResult]
    var lastAssessmentDate: String?
    var gratitudeEntries: [GratitudeEntry]
    var sleepEntries: [SleepEntry]
    var cycleEntries: [CycleEntry]

    // MARK: - Recovery
    var recoveryTracks: [RecoveryTrack]
    var cravingEntries: [CravingEntry]

    // MARK: - Therapy
    var therapyReflections: [TherapyReflection]
    var cbtScore: Int
    var dbtScore: Int
    var angerScore: Int

    // MARK: - Safety
    var safetyPlan: SafetyPlan

    // MARK: - Gamification
    var totalXP: Int
    var level: Int
    var selectedAuraID: String
    var auraShards: Int
    var totalSessionsCompleted: Int

    // MARK: - Settings
    var notificationsEnabled: Bool
    var hapticsEnabled: Bool
    var dynamicAuraEnabled: Bool
    var isPremium: Bool

    // MARK: - Current schema version
    static let currentSchemaVersion = 1
}
