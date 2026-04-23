import Foundation

struct Quest: Identifiable, Codable {
    let id: UUID
    let title: String
    let xpReward: Int
    var isCompleted: Bool
    let type: QuestType
    let dateCreated: String // yyyy-MM-dd
    
    enum QuestType: String, Codable {
        case mood, breathing, journal, medication, sleep, assessment, recovery, cbt, dbt, anger
    }
}
