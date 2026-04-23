import SwiftUI
import Combine

// MARK: - App Tab Definition
enum AppTab: String, CaseIterable, Codable {
    case profile    = "profile"
    case wellness   = "wellness"
    case prevention = "prevention"
    case meds       = "meds"
    case analytics  = "analytics"

    var label: String {
        switch self {
        case .wellness:   return "Wellness"
        case .prevention: return "Prevention"
        case .meds:       return "Meds"
        case .analytics: return "Trends"
        case .profile:   return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .wellness:   return "heart.fill"
        case .prevention: return "shield.lefthalf.filled"
        case .meds:       return "pills.fill"
        case .analytics: return "chart.xyaxis.line"
        case .profile:   return "person.crop.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .wellness:   return Color(hex: "ef4444")
        case .prevention: return Color(hex: "0071e3")
        case .meds:       return Color(hex: "22c55e")
        case .analytics: return Color(hex: "0071e3")
        case .profile:   return Color(hex: "6366f1")
        }
    }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .wellness:   WellnessView()
        case .prevention: PreventionLabView()
        case .meds:       MedicationView()
        case .analytics: AnalyticsView()
        case .profile:   ProfileView()
        }
    }
}

// MARK: - Tab Store (persists to UserDefaults)
class TabStore: ObservableObject {
    static let shared = TabStore()
    private let key = "wya_active_tabs"
    private let maxTabs = 5

    @Published var activeTabs: [AppTab] {
        didSet { save() }
    }
    
    @Published var selectedTab: AppTab = .profile
    @Published var activeQuestType: Quest.QuestType? = nil

    init() {
        if let data = UserDefaults.standard.data(forKey: "wya_active_tabs"),
           let decoded = try? JSONDecoder().decode([AppTab].self, from: data) {
            activeTabs = decoded
        } else {
            activeTabs = [.profile, .wellness, .prevention, .meds, .analytics]
        }
    }

    func save() {
        if let encoded = try? JSONEncoder().encode(activeTabs) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}
