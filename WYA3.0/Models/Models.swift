import Foundation
import CoreLocation
import Combine
// MARK: - Chat Message
struct ChatMessage: Codable, Identifiable {
    let id: String
    let role: MessageRole
    let text: String
    let date: String
    let time: String

    init(role: MessageRole, text: String) {
        self.id = UUID().uuidString
        self.role = role
        self.text = text
        let now = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        self.date = df.string(from: now)
        let tf = DateFormatter()
        tf.dateFormat = "h:mm a"
        self.time = tf.string(from: now)
    }
}

enum MessageRole: String, Codable {
    case bot, user
}

// MARK: - Mood Entry
struct MoodEntry: Codable, Identifiable {
    let id: String
    let mood: Int // 0-4 (terrible to amazing)
    let journal: String
    let date: String
    let time: String
    var triggers: [String]
    var temperature: Int?
    var weatherIcon: String?

    init(mood: Int, journal: String = "", triggers: [String] = [], temperature: Int? = nil, weatherIcon: String? = nil) {
        self.id = UUID().uuidString
        self.mood = mood
        self.journal = journal
        self.triggers = triggers
        self.temperature = temperature
        self.weatherIcon = weatherIcon
        let now = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        self.date = df.string(from: now)
        let tf = DateFormatter()
        tf.dateFormat = "h:mm a"
        self.time = tf.string(from: now)
    }

    var emoji: String {
        let emojis = ["😞", "😟", "😐", "🙂", "😄"]
        return emojis[indices: mood - 1] ?? "😐"
    }

    var label: String {
        let labels = ["Terrible", "Bad", "Okay", "Good", "Amazing"]
        return labels[indices: mood - 1] ?? "Okay"
    }
}

// MARK: - Journal Entry
struct JournalEntry: Codable, Identifiable {
    let id: String
    let text: String
    let prompt: String
    let date: String
    let time: String
    var distortions: [String]
    var themes: [String]

    init(text: String, prompt: String = "", distortions: [String] = [], themes: [String] = []) {
        self.id = UUID().uuidString
        self.text = text
        self.prompt = prompt
        self.distortions = distortions
        self.themes = themes
        let now = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        self.date = df.string(from: now)
        let tf = DateFormatter()
        tf.dateFormat = "h:mm a"
        self.time = tf.string(from: now)
    }
}

// MARK: - Medication
struct Medication: Codable, Identifiable {
    let id: String
    var name: String
    var dosage: String
    var frequency: String
    var times: [String]
    var colorIndex: Int
    var active: Bool
    let createdAt: String

    init(name: String, dosage: String, frequency: String, times: [String], colorIndex: Int) {
        self.id = UUID().uuidString
        self.name = name
        self.dosage = dosage
        self.frequency = frequency
        self.times = times
        self.colorIndex = colorIndex
        self.active = true
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        self.createdAt = df.string(from: Date())
    }

    var frequencyLabel: String {
        switch frequency {
        case "once-daily": return "Once daily"
        case "twice-daily": return "Twice daily"
        case "three-daily": return "3x daily"
        case "as-needed": return "As needed"
        case "weekly": return "Weekly"
        default: return frequency
        }
    }
}

struct DoseRecord: Codable, Identifiable {
    let id: String
    let medId: String
    let date: String
    let time: String
    var taken: Bool
    var takenAt: String?

    init(medId: String, date: String, time: String) {
        self.id = UUID().uuidString
        self.medId = medId
        self.date = date
        self.time = time
        self.taken = true
        let tf = DateFormatter()
        tf.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        self.takenAt = tf.string(from: Date())
    }
}

struct SideEffect: Codable, Identifiable {
    let id: String
    let medId: String
    let effect: String
    let severity: Int
    let notes: String
    let date: String

    init(medId: String, effect: String, severity: Int, notes: String = "") {
        self.id = UUID().uuidString
        self.medId = medId
        self.effect = effect
        self.severity = severity
        self.notes = notes
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        self.date = df.string(from: Date())
    }
}

// MARK: - Assessment
struct AssessmentResult: Codable, Identifiable {
    let id: String
    let type: String // "PHQ-9" or "GAD-7"
    let score: Int
    let answers: [Int]
    let date: String

    init(type: String, score: Int, answers: [Int]) {
        self.id = UUID().uuidString
        self.type = type
        self.score = score
        self.answers = answers
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        self.date = df.string(from: Date())
    }

    var severity: String {
        if type == "PHQ-9" {
            switch score {
            case 0...4: return "Minimal"
            case 5...9: return "Mild"
            case 10...14: return "Moderate"
            case 15...19: return "Moderately Severe"
            default: return "Severe"
            }
        } else {
            switch score {
            case 0...4: return "Minimal"
            case 5...9: return "Mild"
            case 10...14: return "Moderate"
            default: return "Severe"
            }
        }
    }

    var severityColor: String {
        switch severity {
        case "Minimal": return "22c55e"
        case "Mild": return "eab308"
        case "Moderate": return "f97316"
        default: return "ef4444"
        }
    }
}

// MARK: - Gratitude Entry
struct GratitudeEntry: Codable, Identifiable {
    let id: String
    let items: [String]
    let date: String

    init(items: [String]) {
        self.id = UUID().uuidString
        self.items = items
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        self.date = df.string(from: Date())
    }
}

// MARK: - Sleep Entry
struct SleepEntry: Codable, Identifiable {
    let id: String
    let hours: Double
    let quality: Int // 1-5
    let date: String
    let notes: String

    init(hours: Double, quality: Int, notes: String = "") {
        self.id = UUID().uuidString
        self.hours = hours
        self.quality = quality
        self.notes = notes
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        self.date = df.string(from: Date())
    }
}

// MARK: - Cycle Entry
struct CycleEntry: Codable, Identifiable {
    let id: String
    let date: String
    let phase: String // "Menstrual", "Follicular", "Ovulatory", "Luteal"
    let flow: Int // 0-3
    let symptoms: [String]
    let notes: String

    init(phase: String, flow: Int, symptoms: [String], notes: String = "") {
        self.id = UUID().uuidString
        self.phase = phase
        self.flow = flow
        self.symptoms = symptoms
        self.notes = notes
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        self.date = df.string(from: Date())
    }
}

// MARK: - Aura & Gamification
struct AuraShard: Codable, Identifiable {
    let id: UUID
    let date: Date
    let amount: Int
    let source: String // "Mood Log", "Therapy", etc.
}

// MARK: - Crisis & Safety
struct SafetyPlan: Codable, Identifiable {
    let id: UUID
    var warningSigns: [String]
    var copingStrategies: [String]
    var safeContacts: [String]
    var professionalContacts: [String]
    var safeEnvironmentSteps: [String]
    
    static var empty: SafetyPlan {
        SafetyPlan(id: UUID(), warningSigns: [], copingStrategies: [], safeContacts: [], professionalContacts: [], safeEnvironmentSteps: [])
    }
}
