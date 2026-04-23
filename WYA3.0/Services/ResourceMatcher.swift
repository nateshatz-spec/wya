import Foundation

// MARK: - Smart Resource Matcher
struct ResourceMatch: Identifiable {
    let id = UUID()
    let type: SuggestionType
    let title: String
    let reason: String
    let resource: Resource
    
    enum SuggestionType {
        case trigger, mood, habit
    }
}

struct ResourceMatcher {
    private static let triggerMap: [String: Resource] = [
        "Work 💼":         ResourceLibrary.all[0],
        "Sleep 😴":        ResourceLibrary.all[2],
        "Relationship ❤️": ResourceLibrary.all[1]
    ]

    static func matches(
        moods: [MoodEntry],
        sleep: [SleepEntry],
        assessments: [AssessmentResult]
    ) -> [ResourceMatch] {
        var suggestions: [ResourceMatch] = []
        let triggerSuggestions = getTriggerMatches(from: moods)
        suggestions.append(contentsOf: triggerSuggestions)
        return Array(suggestions.prefix(3))
    }
    
    private static func getTriggerMatches(from entries: [MoodEntry]) -> [ResourceMatch] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let cutoffStr = formatter.string(from: cutoff)
        let recent = entries.filter { $0.date >= cutoffStr }
        guard !recent.isEmpty else { return [] }
        var counts: [String: Int] = [:]
        for entry in recent {
            for trigger in entry.triggers {
                counts[trigger, default: 0] += 1
            }
        }
        return counts.keys.compactMap { trigger -> ResourceMatch? in
            guard let resource = triggerMap[trigger], (counts[trigger] ?? 0) >= 1 else { return nil }
            return ResourceMatch(
                type: .trigger,
                title: "Pattern Detected",
                reason: "You've logged **\(trigger)** recently.",
                resource: resource
            )
        }
    }
}
