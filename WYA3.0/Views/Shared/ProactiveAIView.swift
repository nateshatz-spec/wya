import SwiftUI

struct ProactiveAIView: View {
    let insight: AIInsight
    let onDismiss: () -> Void
    
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                // Icon Aura
                ZStack {
                    Circle()
                        .fill(Theme.blue.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: insight.icon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Theme.blue)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("AI INSIGHT")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(Theme.blue)
                            .kerning(1)
                        Spacer()
                        Button(action: {
                            withAnimation(.spring()) {
                                isVisible = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onDismiss()
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Theme.lightGrey)
                        }
                    }
                    
                    Text(insight.title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Theme.nearBlack)
                    
                    Text(insight.content)
                        .font(.system(size: 14))
                        .foregroundColor(Theme.darkGrey)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(24)
            .background(Theme.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .auraStroke(color: Theme.blue.opacity(0.2))
            .shadow(color: .black.opacity(0.08), radius: 30, y: 15)
        }
        .padding(.horizontal, 20)
        .offset(y: isVisible ? 0 : 300)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isVisible = true
            }
        }
    }
}
