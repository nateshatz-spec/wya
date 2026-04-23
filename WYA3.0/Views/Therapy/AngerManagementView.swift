import SwiftUI
import Combine

struct AngerManagementView: View {
    @EnvironmentObject var store: DataStore
    @State private var pressure: Double = 0.0
    @State private var isVenting = false
    @State private var sessionScore = 0
    @State private var showingResult = false
    @State private var lastSessionXP = 0
    @State private var feedback = "Hold to vent steam"
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var shakeAmount: CGFloat = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // MARK: - Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("ANGER LAB")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.orange)
                        Text("Emotional Regulation")
                            .font(.system(size: 28, weight: .black))
                    }
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.1))
                            .frame(width: 50, height: 50)
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 20))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // MARK: - Strategy Intro
                VStack(alignment: .leading, spacing: 16) {
                    Text("Anger is energy. It's not about stopping it, but directing it. Use these strategies to cool your 'Internal Engine'.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Theme.darkGrey)
                        .lineSpacing(4)
                    
                    HStack(spacing: 12) {
                        NavigationLink(destination: CoolingStrategiesView()) {
                            Label("COOLING TOOLS", systemImage: "snow")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.orange)
                                .clipShape(Capsule())
                        }
                        
                        NavigationLink(destination: PrimaryEmotionToolView()) {
                            Label("PEEL THE ONION", systemImage: "eye")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(.orange)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.orange.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                // MARK: - De-escalation Tools
                VStack(alignment: .leading, spacing: 16) {
                    Text("IMMEDIATE ACTION")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(Theme.midGrey)
                    
                    VStack(spacing: 12) {
                        NavigationLink(destination: NinetySecondRuleToolView()) {
                            ToolRow(title: "The 90-Second Rule", icon: "timer", color: .orange, description: "Wait out the chemical surge before you react.")
                        }
                        NavigationLink(destination: OppositeActionToolView()) {
                            ToolRow(title: "Opposite Action", icon: "arrow.left.arrow.right", color: .blue, description: "If you want to yell, try whispering.")
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                // MARK: - Minigame Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("PRESSURE VALVE MINIGAME")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(Theme.midGrey)
                        Spacer()
                        Text("Calmness: \(store.angerScore)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.orange)
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .fill(Theme.cardBg)
                            .frame(height: 440)
                            .auraStroke(color: Color.orange.opacity(0.15))
                            .modifier(Shake(animatableData: shakeAmount))
                        
                        VStack(spacing: 24) {
                            ZStack {
                                // Background Ring
                                Circle()
                                    .stroke(Color.orange.opacity(0.1), lineWidth: 30)
                                    .frame(width: 200, height: 200)
                                
                                // Glowing Aura
                                Circle()
                                    .stroke(Color.orange.opacity(0.2 * pressure), lineWidth: 40)
                                    .frame(width: 200, height: 200)
                                    .blur(radius: 15)
                                
                                // Progress Ring
                                Circle()
                                    .trim(from: 0, to: pressure)
                                    .stroke(
                                        AngularGradient(colors: [.orange, .red, .orange], center: .center),
                                        style: StrokeStyle(lineWidth: 30, lineCap: .round)
                                    )
                                    .frame(width: 200, height: 200)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.linear(duration: 0.1), value: pressure)
                                
                                VStack(spacing: 0) {
                                    Text("\(Int(pressure * 100))%")
                                        .font(.system(size: 32, weight: .black))
                                    Text("PRESSURE")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(Theme.midGrey)
                                }
                                
                                SteamEmitter(isVenting: isVenting)
                                    .offset(y: -100)
                            }
                            
                            VStack(spacing: 12) {
                                Text(feedback)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(pressure > 0.8 ? .red : Theme.midGrey)
                                    .animation(.default, value: feedback)
                                
                                ValveControl(isPressed: $isVenting, pressure: pressure)
                                    .shadow(color: (pressure > 0.8 ? Color.red : Color.orange).opacity(0.4), radius: isVenting ? 10 : 25)
                            }
                        }
                    }
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .background(Theme.offWhite)
        .onReceive(timer) { _ in
            if isVenting {
                if pressure > 0 {
                    pressure -= 0.025
                    sessionScore += 1
                    feedback = "Releasing tension..."
                    
                    // Rhythmic haptic feedback - faster pulses as pressure drops
                    if sessionScore % (pressure > 0.5 ? 2 : 1) == 0 {
                        UIImpactFeedbackGenerator(style: pressure > 0.8 ? .heavy : .medium).impactOccurred()
                    }
                } else {
                    pressure = 0
                    feedback = "System cooled."
                    if sessionScore > 0 {
                        finishVentingSession()
                    }
                }
            } else {
                if pressure < 1.0 {
                    pressure += 0.003
                }
                
                if pressure >= 1.0 {
                    pressure = 1.0
                    feedback = "CRITICAL: VENT NOW!"
                    shakeAmount += 2.0
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                } else if pressure > 0.8 {
                    feedback = "Warning: High Pressure"
                    shakeAmount += 0.5
                    if Int(pressure * 100) % 2 == 0 {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                } else {
                    feedback = "Pressure building... hold valve"
                    shakeAmount = 0
                }
            }
        }
        .onChange(of: isVenting) { old, newValue in
            if old == true && newValue == false {
                finishVentingSession()
            }
        }
        .navigationTitle("Anger Lab")
        .navigationBarTitleDisplayMode(.inline)
        .locked(feature: "Anger Regulation Lab", description: "Unlock de-escalation tools and emotional regulation exercises.")
        .sheet(isPresented: $showingResult) {
            VStack(spacing: 30) {
                ResultCardView(
                    title: "Anger Release",
                    subtitle: "Great job regulating your pressure today.",
                    score: "+\(lastSessionXP) XP",
                    palette: .fromID(store.selectedAuraID)
                )
                .scaleEffect(0.8)
                .frame(height: 500)
                
                Button(action: {
                    ShareManager.shared.shareResult(
                        title: "Anger Release",
                        subtitle: "Regulated my focus on WYA today.",
                        score: "+\(lastSessionXP) XP",
                        palette: .fromID(store.selectedAuraID)
                    )
                }) {
                    Label("Share to Story", systemImage: "square.and.arrow.up.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(Theme.blue)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                
                Button("Done") { showingResult = false }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Theme.midGrey)
            }
            .padding()
            .presentationDetents([.large])
        }
    }
    
    private func finishVentingSession() {
        if sessionScore > 5 {
            withAnimation {
                store.angerScore += Int(Double(sessionScore) / 5.0)
                store.addXP(Int(Double(sessionScore) / 2.0))
            }
            store.completeQuest(type: .anger)
            store.incrementSessions()
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            
            // Analytics
            AnalyticsManager.shared.log(.minigame_completed, params: [
                "type": "anger_valve",
                "score": sessionScore,
                "pressure_released": Int(Double(sessionScore) / 5.0)
            ])
            
            // App Store Review
            ReviewManager.shared.requestReviewIfAppropriate(store: store)
            
            lastSessionXP = Int(Double(sessionScore) / 2.0)
            showingResult = true
        }
        sessionScore = 0
    }
}

struct NinetySecondRuleToolView: View {
    @State private var timeRemaining = 90
    @State private var isActive = false
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 40) {
            Text("THE 90-SECOND RULE")
                .font(.system(size: 11, weight: .black))
                .foregroundColor(.orange)
            
            ZStack {
                Circle()
                    .stroke(Color.orange.opacity(0.1), lineWidth: 20)
                    .frame(width: 250, height: 250)
                
                Circle()
                    .trim(from: 0, to: CGFloat(timeRemaining) / 90.0)
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 250, height: 250)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1.0), value: timeRemaining)
                
                VStack(spacing: 8) {
                    Text("\(timeRemaining)")
                        .font(.system(size: 60, weight: .black))
                    Text("SECONDS")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Theme.midGrey)
                }
            }
            
            Text("Wait for the physiological surge of adrenaline to clear your system. Do not act until the timer hits zero.")
                .font(.system(size: 15))
                .foregroundColor(Theme.darkGrey)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: { isActive = true }) {
                Text(isActive ? "Wait..." : "Start De-escalation")
                    .font(.system(size: 17, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 40).padding(.vertical, 16)
                    .background(Color.orange)
                    .clipShape(Capsule())
            }
            .disabled(isActive)
            
            Spacer()
        }
        .padding(30)
        .background(Theme.offWhite)
        .onReceive(timer) { _ in
            if isActive && timeRemaining > 0 {
                timeRemaining -= 1
                if timeRemaining == 0 {
                    isActive = false
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                }
            }
        }
        .navigationTitle("90-Second Rule")
    }
}

struct OppositeActionToolView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("OPPOSITE ACTION")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(.blue)
                
                Text("When your emotion is unhelpful, do the exact opposite of what your urge tells you to do.")
                    .font(.system(size: 16, weight: .medium))
                
                VStack(spacing: 16) {
                    oppositeRow(urge: "Yelling / Attacking", action: "Whisper / Use Soft Voice", icon: "mouth.fill")
                    oppositeRow(urge: "Clenching Fists", action: "Open Palms / Relax Hands", icon: "hand.raised.fill")
                    oppositeRow(urge: "Stomping / Fast Pace", action: "Walk Slowly / Sit Down", icon: "figure.walk")
                    oppositeRow(urge: "Frowning / Scowling", action: "Half-Smile / Relax Face", icon: "face.smiling.fill")
                }
            }
            .padding(30)
        }
        .background(Theme.offWhite)
        .navigationTitle("Opposite Action")
    }
    
    private func oppositeRow(urge: String, action: String, icon: String) -> some View {
        HStack(spacing: 20) {
            ZStack {
                Circle().fill(Color.blue.opacity(0.1)).frame(width: 50, height: 50)
                Image(systemName: icon).foregroundColor(.blue).font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("URGE: \(urge)").font(.system(size: 11, weight: .black)).foregroundColor(.red)
                Text("ACTION: \(action)").font(.system(size: 15, weight: .bold)).foregroundColor(.blue)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .auraStroke(color: Color.blue.opacity(0.1))
    }
}

struct ValveControl: View {
    @Binding var isPressed: Bool
    var pressure: Double
    
    var body: some View {
        ZStack {
            // Valve Base
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.orange.opacity(0.8), Color.red.opacity(0.6)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 60
                    )
                )
                .frame(width: 100, height: 100)
                .shadow(color: .orange.opacity(0.3), radius: isPressed ? 5 : 15)
            
            // Valve Spokes
            ForEach(0..<6) { i in
                RoundedRectangle(cornerRadius: 4)
                    .fill(LinearGradient(
                        colors: [pressure > 0.8 ? .red : .white, .orange.opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 8, height: 45)
                    .offset(y: -40)
                    .rotationEffect(.degrees(Double(i) * 60 + (isPressed ? 45 : 0)))
            }
            
            // Center Cap
            Circle()
                .fill(Color.white)
                .frame(width: 44, height: 44)
                .shadow(radius: 4)
                .overlay(
                    Image(systemName: "gauge.with.dots.needle.bottom.100percent")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(pressure > 0.8 ? .red : .orange)
                        .rotationEffect(.degrees(pressure * 180 - 90))
                )
        }
        .scaleEffect(isPressed ? 0.85 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.5), value: isPressed)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

struct SteamParticle: View {
    @State private var opacity: Double = 0.6
    @State private var scale: CGFloat = 0.3
    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    
    var body: some View {
        Image(systemName: "cloud.fill")
            .foregroundColor(.white)
            .font(.system(size: 20))
            .opacity(opacity)
            .scaleEffect(scale)
            .offset(offset)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                rotation = Double.random(in: -30 ... 30)
                withAnimation(.easeOut(duration: 1.2)) {
                    opacity = 0
                    scale = 2.5
                    offset = CGSize(
                        width: CGFloat.random(in: -60 ... 60),
                        height: CGFloat.random(in: -150 ... -100)
                    )
                }
            }
    }
}

struct SteamEmitter: View {
    let isVenting: Bool
    @State private var particleIds: [UUID] = []
    let timer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            ForEach(particleIds, id: \.self) { id in
                SteamParticle()
            }
        }
        .onReceive(timer) { _ in
            if isVenting {
                let newId = UUID()
                particleIds.append(newId)
                // Cleanup
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    particleIds.removeAll { $0 == newId }
                }
            }
        }
    }
}

struct Shake: GeometryEffect {
    var amount: CGFloat = 8
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

struct AngerInfoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("THE ANGER APPROACH")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(.orange)
                
                Text("Anger is a secondary emotion—it's usually a shield for hurt or fear. Managing it isn't about 'stopping' it, but about regulating its intensity.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Theme.nearBlack)
                
                VStack(alignment: .leading, spacing: 16) {
                    tipRow(title: "The Window of Tolerance", content: "When you're angry, you're outside your 'Window'. This game helps you practice staying in control while the pressure is high.")
                    tipRow(title: "Controlled Venting", content: "Exploding causes damage. Suppressing causes health issues. Controlled release (like this valve) teaches your body to let go slowly.")
                    tipRow(title: "Pause & Pulse", content: "Notice the haptic pulses. Use them to time your breathing. Exhaling while venting helps lower your blood pressure.")
                }
                
                NavigationLink(destination: CoolingStrategiesView()) {
                    HStack {
                        Image(systemName: "snow")
                        Text("Cooling Strategies")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .clipShape(Capsule())
                }
                
                Spacer()
            }
            .padding(30)
        }
        .background(Theme.offWhite)
        .navigationTitle("Anger Insights")
    }
    
    private func tipRow(title: String, content: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Circle()
                .fill(Color.orange.opacity(0.1))
                .frame(width: 32, height: 32)
                .overlay(Text("!").font(.system(size: 14, weight: .black)).foregroundColor(.orange))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .black))
                Text(content)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.darkGrey)
            }
        }
    }
}

struct CoolingStrategiesView: View {
    let strategies = [
        ("The 90-Second Rule", "An emotional chemical surge lasts about 90 seconds. If you can wait that long without acting, the peak will pass."),
        ("Opposite Action", "If you feel like yelling, try whispering. If you feel like clenching your fists, open your palms."),
        ("Change Your Environment", "Physically leave the room. The change in visual and auditory stimuli helps reset your nervous system."),
        ("The 'I' Statement", "Instead of 'You make me so mad', try 'I feel frustrated because...' it shifts the brain from attack mode to expression mode.")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("DE-ESCALATION TOOLS")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 20)
                
                ForEach(strategies, id: \.0) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.0)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(Theme.nearBlack)
                        Text(item.1)
                            .font(.system(size: 14))
                            .foregroundColor(Theme.midGrey)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.cardBg)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .auraStroke(color: Color.orange.opacity(0.1))
                    .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 20)
        }
        .background(Theme.offWhite)
        .navigationTitle("Cooling Strategies")
    }
}

struct PrimaryEmotionToolView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("PEEL THE ONION")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(.orange)
                
                Text("Anger is often a 'Secondary Emotion'. It acts as a shield to protect us from feeling more vulnerable 'Primary Emotions'.")
                    .font(.system(size: 16, weight: .medium))
                
                VStack(spacing: 12) {
                    onionLayer(level: "SHIELD", title: "Anger", color: .red, description: "The outward expression. Loud, intense, and defensive.")
                    onionLayer(level: "CORE", title: "Primary Emotion", color: .blue, description: "The true feeling: Hurt, Fear, Rejection, or Sadness.")
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("WHY IT MATTERS")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(Theme.midGrey)
                    
                    Text("If you only treat the anger, you're only treating the symptom. Identifying the primary emotion allows you to address the actual problem.")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.darkGrey)
                        .padding(20)
                        .background(Theme.cardBg)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
            .padding(30)
        }
        .background(Theme.offWhite)
        .navigationTitle("Primary Emotions")
    }
    
    private func onionLayer(level: String, title: String, color: Color, description: String) -> some View {
        HStack(spacing: 20) {
            VStack {
                Text(level)
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(color)
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(Circle().stroke(color, lineWidth: 2))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 17, weight: .bold))
                Text(description).font(.system(size: 14)).foregroundColor(Theme.darkGrey)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .auraStroke(color: color.opacity(0.1))
    }
}
