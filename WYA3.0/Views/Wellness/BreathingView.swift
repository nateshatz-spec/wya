import SwiftUI

struct BreathingView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss
    
    @State private var isInhaling = false
    @State private var text = "Get Ready"
    @State private var timer: Timer?
    @State private var cycles = 0
    @State private var isActive = false
    
    let duration: Double = 4.0
    
    var body: some View {
        ZStack {
            Theme.nearBlack.ignoresSafeArea()
            
            VStack(spacing: 60) {
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Capsule())
                    }
                    Spacer()
                    Text("Cycles: \(cycles)")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Breathing Circle
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(Theme.green.opacity(0.2))
                        .frame(width: isInhaling ? 320 : 180)
                        .blur(radius: isInhaling ? 40 : 20)
                    
                    // Main circle
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Theme.green, Theme.green.opacity(0.6)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 150
                            )
                        )
                        .frame(width: isInhaling ? 260 : 140)
                        .shadow(color: Theme.green.opacity(0.5), radius: 30)
                    
                    Text(text)
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(.white)
                }
                .animation(.easeInOut(duration: duration), value: isInhaling)
                
                Spacer()
                
                if !isActive {
                    Button(action: startBreathing) {
                        Text("START SESSION")
                            .font(.system(size: 16, weight: .black))
                            .foregroundColor(.black)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 20)
                            .background(Theme.green)
                            .clipShape(Capsule())
                    }
                } else {
                    Text("Focus on your breath. Follow the circle.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
            }
            .padding(.vertical, 40)
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startBreathing() {
        isActive = true
        runCycle()
    }
    
    private func runCycle() {
        text = "Breathe In"
        isInhaling = true
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            text = "Hold"
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                text = "Breathe Out"
                isInhaling = false
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    cycles += 1
                    store.addXP(5)
                    if cycles % 4 == 0 {
                        store.completeQuest(type: .breathing)
                    }
                    if isActive {
                        runCycle()
                    }
                }
            }
        }
    }
}
