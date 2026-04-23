import SwiftUI
import UIKit

struct ResultCardView: View {
    let title: String
    let subtitle: String
    let score: String?
    let palette: AuraPalette
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(palette.primary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(Theme.nearBlack)
                
                Text(subtitle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Theme.midGrey)
                    .multilineTextAlignment(.center)
            }
            
            if let score = score {
                Text(score)
                    .font(.system(size: 48, weight: .black))
                    .foregroundColor(palette.primary)
                    .padding(.vertical, 10)
            }
            
            HStack {
                Image(systemName: "w.circle.fill")
                Text("WYA CLARITY")
                    .font(.system(size: 12, weight: .black))
                    .kerning(2)
            }
            .foregroundColor(Theme.blue)
            .padding(.top, 20)
        }
        .padding(40)
        .frame(width: 400, height: 600)
        .background(
            ZStack {
                Theme.cardBg
                LinearGradient(colors: [palette.primary.opacity(0.1), .clear], startPoint: .top, endPoint: .bottom)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .auraStroke(color: palette.primary.opacity(0.1), radius: 32)
    }
}

class ShareManager {
    static let shared = ShareManager()
    
    @MainActor
    func shareResult(title: String, subtitle: String, score: String?, palette: AuraPalette) {
        let renderer = ImageRenderer(content: ResultCardView(title: title, subtitle: subtitle, score: score, palette: palette))
        renderer.scale = 3.0
        
        if let uiImage = renderer.uiImage {
            let activityVC = UIActivityViewController(activityItems: [uiImage], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                
                // For iPad support
                if let popover = activityVC.popoverPresentationController {
                    popover.sourceView = rootVC.view
                    popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                    popover.permittedArrowDirections = []
                }
                
                rootVC.present(activityVC, animated: true)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }
    }
}
