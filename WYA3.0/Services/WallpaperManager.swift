import SwiftUI
import UIKit

struct AuraWallpaperView: View {
    let palette: AuraPalette
    
    var body: some View {
        ZStack {
            LinearGradient(colors: palette.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            // Subtle Orb
            Circle()
                .fill(palette.primary.opacity(0.2))
                .blur(radius: 100)
                .offset(x: -100, y: -200)
            
            VStack {
                Spacer()
                Text("WYA")
                    .font(.system(size: 40, weight: .black))
                    .foregroundColor(.white.opacity(0.3))
                    .kerning(10)
                    .padding(.bottom, 60)
            }
        }
        .frame(width: 1170, height: 2532) // iPhone 13 Pro Max size roughly
    }
}

class WallpaperManager {
    @MainActor
    static func exportWallpaper(palette: AuraPalette) {
        let renderer = ImageRenderer(content: AuraWallpaperView(palette: palette))
        renderer.scale = 3.0
        
        if let uiImage = renderer.uiImage {
            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
            
            // Haptic feedback
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}
