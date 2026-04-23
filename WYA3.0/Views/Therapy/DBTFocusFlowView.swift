import SwiftUI
import Combine

struct DBTFocusFlowView: View {
    @EnvironmentObject var store: DataStore
    @State private var dotPosition: CGPoint = .zero
    @State private var targetPosition: CGPoint = .zero
    @State private var score = 0
    @State private var timeRemaining = 60
    @State private var isActive = false
    @State private var showingResult = false
    @State private var lastSessionXP = 0
    @State private var feedback = "Stay on the dot"
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // MARK: - Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("DBT LAB")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.purple)
                        Text("Dialectical Flow")
                            .font(.system(size: 28, weight: .black))
                    }
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(Color.purple.opacity(0.1))
                            .frame(width: 50, height: 50)
                        Image(systemName: "circle.dotted")
                            .foregroundColor(.purple)
                            .font(.system(size: 20))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // MARK: - Skills Intro
                VStack(alignment: .leading, spacing: 16) {
                    Text("DBT is about finding the 'Middle Path'. When emotions are high, use these skills to return to your Wise Mind.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Theme.darkGrey)
                        .lineSpacing(4)
                    
                    HStack(spacing: 12) {
                        NavigationLink(destination: TIPPSkillsView()) {
                            Label("TIPP SKILLS", systemImage: "thermometer.snowflake")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.purple)
                                .clipShape(Capsule())
                        }
                        
                        NavigationLink(destination: WiseMindToolView()) {
                            Label("WISE MIND", systemImage: "plus.circle")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(.purple)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.purple.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                // MARK: - Mindfulness Tools
                VStack(alignment: .leading, spacing: 16) {
                    Text("DISTRESS TOLERANCE")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(Theme.midGrey)
                    
                    VStack(spacing: 12) {
                        NavigationLink(destination: STOPToolView()) {
                            ToolRow(title: "The STOP Skill", icon: "hand.raised.fill", color: .red, description: "Stop, Take a breath, Observe, Proceed mindfully.")
                        }
                        NavigationLink(destination: OneMindfullyToolView()) {
                            ToolRow(title: "One-Mindfully", icon: "eye.fill", color: .purple, description: "Practice total focus on a single activity.")
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                // MARK: - Minigame Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("FOCUS FLOW MINIGAME")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(Theme.midGrey)
                        Spacer()
                        Text("Time: \(timeRemaining)s")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.purple)
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .fill(Theme.cardBg)
                            .frame(height: 350)
                            .auraStroke(color: Color.purple.opacity(0.15))
                        
                        if !isActive {
                            VStack(spacing: 20) {
                                Image(systemName: "dot.circle.viewfinder")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color.purple.opacity(0.3))
                                
                                Button(action: startGame) {
                                    Text("Start Session")
                                        .font(.system(size: 15, weight: .black))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 24).padding(.vertical, 12)
                                        .background(Color.purple)
                                        .clipShape(Capsule())
                                }
                            }
                        } else {
                            Circle()
                                .fill(Color.purple)
                                .frame(width: 30, height: 30)
                                .position(targetPosition)
                                .shadow(color: Color.purple.opacity(0.3), radius: 10)
                            
                            Circle()
                                .stroke(Color.purple, lineWidth: 2)
                                .frame(width: 50, height: 50)
                                .position(dotPosition)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            dotPosition = value.location
                                            checkProximity()
                                        }
                                )
                            
                            VStack {
                                Spacer()
                                ZStack {
                                    GroundingEmitter(isActive: feedback == "Grounding...")
                                        .frame(width: 50, height: 50)
                                        .position(dotPosition)
                                    
                                    Text(feedback)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(feedback == "Grounding..." ? .purple : Theme.midGrey)
                                        .padding(.bottom, 20)
                                }
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
            if isActive {
                moveTarget()
            }
        }
        .onReceive(Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()) { _ in
            if isActive && timeRemaining > 0 {
                timeRemaining -= 1
                if timeRemaining == 0 {
                    isActive = false
                    feedback = "Session Complete"
                    
                    // Analytics
                    AnalyticsManager.shared.log(.minigame_completed, params: [
                        "type": "dbt_focus_flow",
                        "score": score
                    ])
                    
                    // Session Tracking
                    store.incrementSessions()
                    
                    store.completeQuest(type: .dbt)
                    
                    // App Store Review
                    ReviewManager.shared.requestReviewIfAppropriate(store: store)
                    
                    lastSessionXP = score / 10
                    showingResult = true
                }
            }
        }
        .navigationTitle("DBT Lab")
        .navigationBarTitleDisplayMode(.inline)
        .locked(feature: "DBT Therapy Lab", description: "Unlock dialectical mindfulness tools and distress tolerance skills.")
        .sheet(isPresented: $showingResult) {
            VStack(spacing: 30) {
                ResultCardView(
                    title: "Dialectical Flow",
                    subtitle: "You maintained focus for 60 seconds. Your Wise Mind is strengthening.",
                    score: "+\(lastSessionXP) XP",
                    palette: .fromID(store.selectedAuraID)
                )
                .scaleEffect(0.8)
                .frame(height: 500)
                
                Button(action: {
                    ShareManager.shared.shareResult(
                        title: "Dialectical Flow",
                        subtitle: "Practiced mindfulness flow on WYA today.",
                        score: "\(score) Focus Pts",
                        palette: .fromID(store.selectedAuraID)
                    )
                }) {
                    Label("Share to Story", systemImage: "square.and.arrow.down.fill")
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
    
    private func startGame() {
        isActive = true
        timeRemaining = 60
        targetPosition = CGPoint(x: 200, y: 400)
        dotPosition = CGPoint(x: 200, y: 400)
    }
    
    private func moveTarget() {
        withAnimation(.easeInOut(duration: 2.0)) {
            let maxX = UIScreen.main.bounds.width - 60
            let maxY: CGFloat = 350 - 60 // Constrain to game box
            targetPosition = CGPoint(
                x: CGFloat.random(in: 40.0...maxX),
                y: CGFloat.random(in: 40.0...maxY)
            )
        }
    }
    
    private func checkProximity() {
        let dist = sqrt(pow(dotPosition.x - targetPosition.x, 2) + pow(dotPosition.y - targetPosition.y, 2))
        if dist < 40 {
            score += 1
            store.dbtScore += 1
            feedback = "Grounding..."
            
            // Rhythmic haptics for staying on target
            if Int(score) % 5 == 0 {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            }
        } else {
            feedback = "Return to the center"
        }
    }
}

struct STOPToolView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("THE STOP SKILL")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(.red)
                
                VStack(spacing: 16) {
                    stopRow(letter: "S", title: "Stop", content: "Freeze! Do not move a muscle. Your urges are just feelings, not facts.")
                    stopRow(letter: "T", title: "Take a Breath", content: "Inhale deeply. Exhale slowly. Pull yourself back into the present moment.")
                    stopRow(letter: "O", title: "Observe", content: "Notice what is happening inside and outside you. What are the facts?")
                    stopRow(letter: "P", title: "Proceed Mindfully", content: "Ask your Wise Mind: What is the most effective thing to do now?")
                }
            }
            .padding(30)
        }
        .background(Theme.offWhite)
        .navigationTitle("STOP Skill")
    }
    
    private func stopRow(letter: String, title: String, content: String) -> some View {
        HStack(alignment: .top, spacing: 20) {
            Text(letter)
                .font(.system(size: 32, weight: .black))
                .foregroundColor(.red)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 18, weight: .bold))
                Text(content).font(.system(size: 15)).foregroundColor(Theme.darkGrey)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .auraStroke(color: Color.red.opacity(0.1))
    }
}

struct OneMindfullyToolView: View {
    var body: some View {
        VStack(spacing: 32) {
            Text("ONE-MINDFULLY")
                .font(.system(size: 11, weight: .black))
                .foregroundColor(.purple)
            
            Text("Focus on a single sensory experience for 60 seconds.")
                .font(.system(size: 17, weight: .bold))
                .multilineTextAlignment(.center)
            
            ZStack {
                Circle()
                    .stroke(Color.purple.opacity(0.1), lineWidth: 4)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .fill(Color.purple.opacity(0.05))
                    .frame(width: 180, height: 180)
                
                Image(systemName: "eye.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.purple)
            }
            
            Text("Observe one object in your room. Notice its shape, color, and texture without judging it.")
                .font(.system(size: 15))
                .foregroundColor(Theme.darkGrey)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding(30)
        .background(Theme.offWhite)
        .navigationTitle("One-Mindfully")
    }
}

struct DBTInfoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("THE DBT APPROACH")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(.purple)
                
                Text("DBT (Dialectical Behavior Therapy) is about balance. This game focuses on 'One-Mindfully'—the skill of doing one thing with your whole attention.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Theme.nearBlack)
                
                VStack(alignment: .leading, spacing: 16) {
                    tipRow(title: "Distress Tolerance", content: "When emotions are high, your brain's 'logical center' shuts down. A simple, focused task pulls you back into reality.")
                    tipRow(title: "The Flow State", content: "Focusing on a single moving point forces your eyes and brain to sync, which physically lowers your heart rate.")
                    tipRow(title: "Acceptance", content: "If you lose focus, simply notice it without judgment and return to the target. That return is where the growth happens.")
                }
                
                NavigationLink(destination: TIPPSkillsView()) {
                    HStack {
                        Image(systemName: "thermometer.snowflake")
                        Text("Emergency TIPP Skills")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .clipShape(Capsule())
                }
                
                Spacer()
            }
            .padding(30)
        }
        .background(Theme.offWhite)
        .navigationTitle("DBT Insights")
    }
    
    private func tipRow(title: String, content: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Circle()
                .fill(Color.purple.opacity(0.1))
                .frame(width: 32, height: 32)
                .overlay(Text("!").font(.system(size: 14, weight: .black)).foregroundColor(.purple))
            
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

struct TIPPSkillsView: View {
    let skills = [
        ("Temperature", "Splash ice-cold water on your face for 30 seconds. It triggers the mammalian dive reflex to slow your heart rate."),
        ("Intense Exercise", "Do jumping jacks or pushups for 60 seconds to burn off intense emotional energy."),
        ("Paced Breathing", "Slowing your breath down to 5-7 breaths per minute (inhale for 4, exhale for 6)."),
        ("Paired Relaxation", "Tense your muscles while inhaling, and say 'Relax' while exhaling and releasing.")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("THE TIPP PROTOCOL")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(.purple)
                    .padding(.horizontal, 20)
                
                ForEach(skills, id: \.0) { item in
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
                    .auraStroke(color: Color.purple.opacity(0.1))
                    .padding(.horizontal, 20)
                }
                
                Text("Use these when your emotional intensity is an 8/10 or higher and you feel like you might act impulsively.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Theme.midGrey)
                    .padding(20)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 20)
        }
        .background(Theme.offWhite)
        .navigationTitle("TIPP Skills")
    }
}

struct GroundingParticle: View {
    @State private var opacity: Double = 0.8
    @State private var scale: CGFloat = 0.2
    @State private var offset: CGSize = .zero
    
    var body: some View {
        Circle()
            .fill(Color.purple.opacity(0.4))
            .frame(width: 8, height: 8)
            .opacity(opacity)
            .scaleEffect(scale)
            .offset(offset)
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    opacity = 0
                    scale = 2.0
                    offset = CGSize(
                        width: CGFloat.random(in: -30...30),
                        height: CGFloat.random(in: -30...30)
                    )
                }
            }
    }
}

struct GroundingEmitter: View {
    let isActive: Bool
    @State private var particleIds: [UUID] = []
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            ForEach(particleIds, id: \.self) { id in
                GroundingParticle()
            }
        }
        .onReceive(timer) { _ in
            if isActive {
                let newId = UUID()
                particleIds.append(newId)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    particleIds.removeAll { $0 == newId }
                }
            }
        }
    }
}

struct WiseMindToolView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("THE WISE MIND")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(.purple)
                
                Text("Wise Mind is the synthesis of your 'Reasonable Mind' and your 'Emotional Mind'. It is the place of intuition and calm.")
                    .font(.system(size: 16, weight: .medium))
                
                VStack(spacing: 0) {
                    mindBox(title: "Reasonable Mind", icon: "brain", color: .blue, content: "Focuses on facts, logic, and planning. Ignores feelings.")
                    
                    ZStack {
                        Circle()
                            .fill(.purple)
                            .frame(width: 60, height: 60)
                            .overlay(Text("WISE").font(.system(size: 12, weight: .black)).foregroundColor(.white))
                            .shadow(color: .purple.opacity(0.3), radius: 10)
                    }
                    .padding(.vertical, -30)
                    .zIndex(10)
                    
                    mindBox(title: "Emotional Mind", icon: "heart.fill", color: .red, content: "Focuses on feelings, urges, and moods. Ignores facts.")
                }
                .padding(.vertical, 20)
                
                Text("Practice: Ask yourself, 'In this moment, what does my Wise Mind say?'")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(.purple)
            }
            .padding(30)
        }
        .background(Theme.offWhite)
        .navigationTitle("Wise Mind")
    }
    
    private func mindBox(title: String, icon: String, color: Color, content: String) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon).foregroundColor(color)
                Text(title).font(.system(size: 17, weight: .bold))
            }
            Text(content).font(.system(size: 14)).foregroundColor(Theme.darkGrey).multilineTextAlignment(.center)
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .auraStroke(color: color.opacity(0.1))
    }
}
