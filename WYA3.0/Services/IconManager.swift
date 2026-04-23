import UIKit
import SwiftUI
import Combine

enum AppIcon: String, CaseIterable, Identifiable {
    case primary = "AppIcon"
    case midnight = "AppIconMidnight"
    case gold = "AppIconGold"
    case solar = "AppIconSolar"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .primary: return "Classic Clarity"
        case .midnight: return "Midnight Echo"
        case .gold: return "Gold Rush"
        case .solar: return "Solar Flare"
        }
    }
    
    var previewColor: Color {
        switch self {
        case .primary: return .blue
        case .midnight: return .indigo
        case .gold: return .orange
        case .solar: return .red
        }
    }
}

class IconManager: ObservableObject {
    static let shared = IconManager()
    
    @Published var currentIcon: AppIcon = .primary
    
    init() {
        if let iconName = UIApplication.shared.alternateIconName {
            currentIcon = AppIcon(rawValue: iconName) ?? .primary
        }
    }
    
    func setIcon(_ icon: AppIcon) {
        let iconName = icon == .primary ? nil : icon.rawValue
        
        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
                print("Failed to set alternate icon: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.currentIcon = icon
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            }
        }
    }
}
