import SwiftUI

// MARK: - Design System
struct Theme {

    // MARK: Premium Dark Palette
    /// Main page/screen background (Deep Charcoal)
    static let background  = Color(hex: "0F1419")
    static let offWhite    = Color(hex: "0F1419") // Defaulting all screens to dark
    
    /// Card / elevated surface (Lighter Charcoal)
    static let cardBg      = Color(hex: "1A1F24")
    
    /// Input field
    static let inputBg     = Color(hex: "24292F")

    // MARK: Adaptive text (Optimized for dark)
    static let nearBlack   = Color.white
    static let midGrey     = Color(hex: "94A3B8")
    static let darkGrey    = Color(hex: "64748B")
    static let lightGrey   = Color(hex: "1E293B")

    // MARK: Adaptive accent tints
    static let blueSubtle  = Color(hex: "0071E3").opacity(0.1)

    // MARK: Static accent colors
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
    static let radiusLg: CGFloat = 20
    static let radiusXl: CGFloat = 28 // More organic corners

    // MARK: Layout Spacing
    static let mainPadding: CGFloat = 20
    static let mainSpacing: CGFloat = 32 // More "breathable" cinematic spacing

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
    
    var outline: Color {
        return primary.opacity(0.2)
    }
    
    static let allPalettes: [String: AuraPalette] = [
        "ice": AuraPalette(
            id: "ice", name: "Ice Blue",
            primary: Color(hex: "0071e3"), secondary: Color(hex: "2997ff"),
            gradient: [Color(hex: "0F1419"), Color(hex: "0F1419")], // Dark base
            minLevel: 1
        ),
        "forest": AuraPalette(
            id: "forest", name: "Deep Forest",
            primary: Color(hex: "059669"), secondary: Color(hex: "10b981"),
            gradient: [Color(hex: "0F1419"), Color(hex: "0F1419")],
            minLevel: 1
        ),
        "storm": AuraPalette(
            id: "storm", name: "Quiet Storm",
            primary: Color(hex: "ef4444"), secondary: Color(hex: "f97316"),
            gradient: [Color(hex: "0F1419"), Color(hex: "0F1419")],
            minLevel: 1
        ),
        "sunlight": AuraPalette(
            id: "sunlight", name: "Radiant Sunlight",
            primary: Color(hex: "f59e0b"), secondary: Color(hex: "fbbf24"),
            gradient: [Color(hex: "0F1419"), Color(hex: "0F1419")],
            minLevel: 1
        ),
        "midnight": AuraPalette(
            id: "midnight", name: "Starlit Midnight",
            primary: Color(hex: "6366f1"), secondary: Color(hex: "8b5cf6"),
            gradient: [Color(hex: "0F1419"), Color(hex: "0F1419")],
            minLevel: 20
        )
    ]

    static func fromID(_ id: String) -> AuraPalette {
        allPalettes[id] ?? allPalettes["ice"]!
    }
}

// MARK: - UIColor adaptive helper (Force Dark)
extension UIColor {
    static func wya(_ light: String, dark: String) -> UIColor {
        UIColor(hex: dark) // Always return dark for the cinematic look
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

extension Collection {
    /// Safe array access to prevent index-out-of-bounds crashes
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - SwiftUI Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
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
    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(Theme.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusXl, style: .continuous))
            .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)
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
                    .stroke(color.opacity(0.2), lineWidth: 1.0)
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
    
    @State private var pulseOpacity: Double = 0.4
    
    var body: some View {
        ZStack {
            // 1. Hard Dark Background
            Theme.background.ignoresSafeArea()
            
            // 2. Subtle Ambient Glow
            Circle()
                .fill(palette.primary.opacity(0.08))
                .blur(radius: 120)
                .offset(x: -100, y: -200)
            
            // 3. The Main Content
            content()
            
            // 4. THE GLOWING MOOD RING
            RoundedRectangle(cornerRadius: 44, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [palette.primary, palette.secondary.opacity(0.3), palette.primary.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 6
                )
                .blur(radius: 10)
                .opacity(pulseOpacity)
                .padding(4)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
        .animation(.easeInOut(duration: 0.8), value: palette.id)
        .onAppear {
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                pulseOpacity = 0.6
            }
        }
    }
}
