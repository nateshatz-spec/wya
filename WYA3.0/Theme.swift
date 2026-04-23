import SwiftUI

// MARK: - Design System
struct Theme {

    // MARK: Adaptive backgrounds
    /// Main page/screen background
    static let offWhite    = Color(UIColor.wya("f5f5f7", dark: "1c1c1e"))
    /// Card / elevated surface
    static let cardBg      = Color(UIColor.wya("ffffff", dark: "2c2c2e"))
    /// Input field (TextEditor, TextField rows)
    static let inputBg     = Color(UIColor.wya("f0f0f5", dark: "3a3a3c"))

    // MARK: Adaptive text
    static let nearBlack   = Color(UIColor.wya("1d1d1f", dark: "f5f5f7"))
    static let midGrey     = Color(UIColor.wya("86868b", dark: "8e8e93"))
    static let darkGrey    = Color(UIColor.wya("6e6e73", dark: "636366"))
    static let lightGrey   = Color(UIColor.wya("e8e8ed", dark: "38383a"))

    // MARK: Adaptive accent tints
    static let blueSubtle  = Color(UIColor.wya("e8f0fe", dark: "0a2540"))

    // MARK: Static accent colors (vibrant in both modes)
    static let white          = Color.white
    static let blue           = Color(hex: "0071e3")
    static let blueLight      = Color(hex: "2997ff")
    static let companion      = Color(hex: "8b5cf6")
    static let companionLight = Color(hex: "a855f7")
    static let green          = Color(hex: "22c55e")
    static let red            = Color(hex: "ef4444")
    static let orange         = Color(hex: "f97316")
    static let yellow         = Color(hex: "eab308")

    // MARK: Radii
    static let radiusSm: CGFloat = 8
    static let radiusMd: CGFloat = 12
    static let radiusLg: CGFloat = 18
    static let radiusXl: CGFloat = 24

    // MARK: Layout Spacing
    static let mainPadding: CGFloat = 20
    static let mainSpacing: CGFloat = 24

    // MARK: Medication pill colors
    static let pillColors: [Color] = [
        Color(hex: "8b5cf6"), Color(hex: "3b82f6"), Color(hex: "14b8a6"),
        Color(hex: "f97316"), Color(hex: "ec4899"), Color(hex: "eab308"),
        Color(hex: "ef4444"), Color(hex: "6366f1"), Color(hex: "22c55e"),
        Color(hex: "64748b")
    ]
}

// MARK: - Aura System
struct AuraPalette: Identifiable {
    let id: String
    let name: String
    let primary: Color
    let secondary: Color
    let gradient: [Color]
    let minLevel: Int
    
    /// Standardized outline color for cards and secondary strokes
    var outline: Color {
        switch id {
        case "sunlight": return primary.opacity(0.2)
        case "midnight": return primary.opacity(0.25)
        default: return primary.opacity(0.15)
        }
    }
    
    static let allPalettes: [String: AuraPalette] = [
        "ice": AuraPalette(
            id: "ice", name: "Ice Blue",
            primary: Color(hex: "0071e3"), secondary: Color(hex: "2997ff"),
            gradient: [Color(hex: "0071e3").opacity(0.15), Color(hex: "2997ff").opacity(0.05), Color.white],
            minLevel: 1
        ),
        "forest": AuraPalette(
            id: "forest", name: "Deep Forest",
            primary: Color(hex: "059669"), secondary: Color(hex: "10b981"),
            gradient: [Color(hex: "059669").opacity(0.15), Color(hex: "10b981").opacity(0.05), Color.white],
            minLevel: 1
        ),
        "storm": AuraPalette(
            id: "storm", name: "Quiet Storm",
            primary: Color(hex: "ef4444"), secondary: Color(hex: "f97316"),
            gradient: [Color(hex: "ef4444").opacity(0.15), Color(hex: "f97316").opacity(0.05), Color.white],
            minLevel: 1
        ),
        "sunlight": AuraPalette(
            id: "sunlight", name: "Radiant Sunlight",
            primary: Color(hex: "f59e0b"), secondary: Color(hex: "fbbf24"),
            gradient: [Color(hex: "f59e0b").opacity(0.15), Color(hex: "fbbf24").opacity(0.05), Color.white],
            minLevel: 1
        ),
        "midnight": AuraPalette(
            id: "midnight", name: "Starlit Midnight",
            primary: Color(hex: "6366f1"), secondary: Color(hex: "8b5cf6"),
            gradient: [Color(hex: "0f172a"), Color(hex: "1e293b")],
            minLevel: 20
        )
    ]

    /// Safely retrieves a palette by ID, falling back to 'ice' if not found.
    static func fromID(_ id: String) -> AuraPalette {
        if let palette = allPalettes[id] {
            return palette
        }
        return allPalettes["ice"] ?? AuraPalette(
            id: "ice", name: "Ice Blue",
            primary: Color(hex: "0071e3"), secondary: Color(hex: "2997ff"),
            gradient: [Color(hex: "e8f0fe"), Color(hex: "ffffff")],
            minLevel: 1
        )
    }
}

extension Collection {
    /// Safe array access
    subscript(indices index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - UIColor adaptive helper
extension UIColor {
    /// Creates a UIColor that automatically switches between light/dark hex values.
    static func wya(_ light: String, dark: String) -> UIColor {
        UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light) }
    }

    convenience init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r = CGFloat((int >> 16) & 0xFF) / 255
        let g = CGFloat((int >> 8)  & 0xFF) / 255
        let b = CGFloat( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}

// MARK: -xlor hex extension (for SwiftUI Color)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:  (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red:   Double(r) / 255,
                  green: Double(g) / 255,
                  blue:  Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

// MARK: - Card Style
struct CardStyle: ViewModifier {
    @Environment(\.colorScheme) var scheme
    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(Theme.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusXl, style: .continuous))
            .shadow(color: .black.opacity(scheme == .dark ? 0 : 0.06), radius: 16, x: 0, y: 6)
    }
}

// MARK: - Aura Stroke Style
struct AuraStroke: ViewModifier {
    let color: Color
    var radius: CGFloat = Theme.radiusXl
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(color, lineWidth: 0.6) // Slightly thicker than before for "premium" feel
            )
    }
}

// MARK: - View helpers
extension View {
    func cardStyle() -> some View { modifier(CardStyle()) }
    
    func auraStroke(color: Color, radius: CGFloat = Theme.radiusXl) -> some View {
        modifier(AuraStroke(color: color, radius: radius))
    }
    
    func auraBackground(palette: AuraPalette) -> some View {
        AuraBackgroundContainer(palette: palette) { self }
    }

    func dismissKeyboardOnReturn() -> some View {
        self.onSubmit(of: .text) { hideKeyboard() }
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}

// MARK: - Aura Background Container
struct AuraBackgroundContainer<Content: View>: View {
    let palette: AuraPalette
    let content: () -> Content
    
    @State private var pulseOpacity: Double = 0.5
    
    var body: some View {
        ZStack {
            // 1. Primary Gradient Background
            LinearGradient(colors: palette.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            // 2. Subtle Ambient Light (Orb)
            Circle()
                .fill(palette.primary.opacity(0.12))
                .blur(radius: 100)
                .offset(x: -150, y: -200)
            
            // 3. The Main Content
            content()
            
            // 4. THE GLOWING MOOD RING
            // This ring wraps around the entire screen frame
            RoundedRectangle(cornerRadius: 40, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [palette.primary, palette.secondary.opacity(0.5), palette.primary.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 8
                )
                .blur(radius: 12)
                .opacity(pulseOpacity)
                .padding(2)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
        .animation(.easeInOut(duration: 0.8), value: palette.id)
        .onAppear {
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                pulseOpacity = 0.8
            }
        }
    }
}
