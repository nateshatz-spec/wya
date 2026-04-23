import SwiftUI
import Combine

struct CBTThoughtReframerView: View {
    @EnvironmentObject var store: DataStore
    @State private var fallingThoughts: [FallingThought] = []
    @State private var score = 0
    @State private var timer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()
    @State private var showingReframe = false
    @State private var selectedThought: FallingThought?
    @State private var showingResult = false
    
    struct FallingThought: Identifiable {
        let id = UUID()
        let text: String
        var x: CGFloat
        var y: CGFloat
        var isCaught = false
    }
    
    let negativeThoughts = [
        "I'm not good enough",
        "Everything will go wrong",
        "Nobody likes me",
        "I can't do this",
        "It's all my fault",
        "I'll never get better"
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // MARK: - Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("CBT LAB")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(Theme.blue)
                        Text("Cognitive Clarity")
                            .font(.system(size: 28, weight: .black))
                    }
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(Theme.blue.opacity(0.1))
                            .frame(width: 50, height: 50)
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(Theme.blue)
                            .font(.system(size: 20))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // MARK: - Educational Intro
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your thoughts create your reality. Identifying 'Cognitive Distortions' is the first step to neutralising anxiety.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Theme.darkGrey)
                        .lineSpacing(4)
                    
                    HStack(spacing: 12) {
                        NavigationLink(destination: DistortionLibraryView()) {
                            Label("DISTORTION LIBRARY", systemImage: "book.fill")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Theme.blue)
                                .clipShape(Capsule())
                        }
                        
                        NavigationLink(destination: ABCToolView()) {
                            Label("ABC MODEL", systemImage: "arrow.triangle.branch")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(Theme.blue)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Theme.blue.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                // MARK: - Quick Tools
                VStack(alignment: .leading, spacing: 16) {
                    Text("PRACTICE TOOLS")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(Theme.midGrey)
                    
                    VStack(spacing: 12) {
                        NavigationLink(destination: RealityCheckView()) {
                            ToolRow(title: "Reality Check", icon: "checkmark.shield.fill", color: .green, description: "Challenge your thoughts with evidence-based questions.")
                        }
                        NavigationLink(destination: ThoughtRecordView()) {
                            ToolRow(title: "Thought Record", icon: "square.and.pencil", color: .purple, description: "Document and reframe your current belief system.")
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                // MARK: - Minigame Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("THOUGHT REFRAMER GAME")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(Theme.midGrey)
                        Spacer()
                        Text("Score: \(score)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Theme.blue)
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .fill(Theme.cardBg)
                            .frame(height: 350)
                            .auraStroke(color: Theme.blue.opacity(0.15))
                        
                        if fallingThoughts.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 30))
                                    .foregroundColor(Theme.blue.opacity(0.3))
                                Text("Wait for negative thoughts to appear...")
                                    .font(.system(size: 13))
                                    .foregroundColor(Theme.midGrey)
                            }
                        }
                        
                        ForEach(fallingThoughts) { thought in
                            if !thought.isCaught {
                                ThoughtCloud(text: thought.text)
                                    .position(x: thought.x, y: thought.y)
                                    .onTapGesture {
                                        catchThought(thought)
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
            spawnThought()
        }
        .onReceive(Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()) { _ in
            updatePositions()
        }
        .sheet(item: $selectedThought) { thought in
            ReframeSheet(thought: thought.text) {
                score += 1
                store.cbtScore += 1
                store.completeQuest(type: .cbt)
                store.saveAll()
                fallingThoughts.removeAll { $0.id == thought.id }
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                
                // Analytics
                AnalyticsManager.shared.log(.minigame_completed, params: [
                    "type": "cbt_reframer",
                    "thought": thought.text
                ])
                
                // Session Tracking
                store.completeQuest(type: .anger)
            store.incrementSessions()
                
                // App Store Review
                ReviewManager.shared.requestReviewIfAppropriate(store: store)
            }
        }
        .navigationTitle("CBT Lab")
        .navigationBarTitleDisplayMode(.inline)
        .locked(feature: "CBT Therapy Lab", description: "Unlock clinical cognitive reframing tools and distortion tracking.")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Finish") {
                    showingResult = true
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Theme.blue)
            }
        }
        .sheet(isPresented: $showingResult) {
            VStack(spacing: 30) {
                ResultCardView(
                    title: "Thought Reframe",
                    subtitle: "You've successfully reframed \(score) intrusive thoughts today.",
                    score: "LEVEL UP",
                    palette: .fromID(store.selectedAuraID)
                )
                .scaleEffect(0.8)
                .frame(height: 500)
                
                Button(action: {
                    ShareManager.shared.shareResult(
                        title: "Thought Reframe",
                        subtitle: "Reframed my focus on WYA today.",
                        score: "\(score) Reframes",
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
    
    private func spawnThought() {
        // Limit spawn area to the game box
        let gameWidth = UIScreen.main.bounds.width - 48
        let x = CGFloat.random(in: 40...gameWidth - 40)
        let thought = FallingThought(text: negativeThoughts.randomElement()!, x: x, y: 0)
        fallingThoughts.append(thought)
    }
    
    private func updatePositions() {
        for i in 0..<fallingThoughts.count {
            fallingThoughts[i].y += 2
        }
        // Remove if past the box height (350)
        fallingThoughts.removeAll { $0.y > 350 }
    }
    
    private func catchThought(_ thought: FallingThought) {
        selectedThought = thought
    }
}

struct ToolRow: View {
    let title: String
    let icon: String
    let color: Color
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(color.opacity(0.1)).frame(width: 44, height: 44)
                Image(systemName: icon).foregroundColor(color).font(.system(size: 18))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 15, weight: .bold)).foregroundColor(Theme.nearBlack)
                Text(description).font(.system(size: 12)).foregroundColor(Theme.midGrey).multilineTextAlignment(.leading)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold)).foregroundColor(Theme.lightGrey)
        }
        .padding(16)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .auraStroke(color: color.opacity(0.1))
    }
}

struct RealityCheckView: View {
    let questions = [
        "What evidence supports this thought?",
        "What evidence contradicts this thought?",
        "Am I misinterpreting the facts?",
        "What would I tell a friend in this situation?",
        "Is this thought helpful or harmful?",
        "What is the worst that could realistically happen?"
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("THE REALITY CHECK")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(.green)
                
                Text("Go through these questions when you feel a cognitive distortion taking hold.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Theme.darkGrey)
                
                ForEach(questions, id: \.self) { question in
                    HStack(spacing: 16) {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundColor(.green)
                        Text(question)
                            .font(.system(size: 16, weight: .bold))
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.cardBg)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .auraStroke(color: Color.green.opacity(0.1))
                }
            }
            .padding(30)
        }
        .background(Theme.offWhite)
        .navigationTitle("Reality Check")
    }
}

struct ThoughtRecordView: View {
    @State private var situation = ""
    @State private var thought = ""
    @State private var evidenceFor = ""
    @State private var evidenceAgainst = ""
    @State private var newThought = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("7-STEP THOUGHT RECORD")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(.purple)
                
                Group {
                    recordField(title: "1. Situation", placeholder: "What happened?", text: $situation)
                    recordField(title: "2. Automatic Thought", placeholder: "What did you tell yourself?", text: $thought)
                    recordField(title: "3. Evidence FOR", placeholder: "Facts supporting the thought...", text: $evidenceFor)
                    recordField(title: "4. Evidence AGAINST", placeholder: "Facts contradicting it...", text: $evidenceAgainst)
                    recordField(title: "5. Balanced Thought", placeholder: "A realistic replacement...", text: $newThought)
                }
                
                Button(action: {
                    // Save logic could go here
                }) {
                    Text("Complete Record")
                        .font(.system(size: 17, weight: .black))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.blue)
                        .clipShape(Capsule())
                }
            }
            .padding(30)
        }
        .background(Theme.offWhite)
        .navigationTitle("Thought Record")
    }
    
    private func recordField(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.system(size: 13, weight: .bold)).foregroundColor(Theme.midGrey)
            TextField(placeholder, text: text, axis: .vertical)
                .padding()
                .background(Theme.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .auraStroke(color: Theme.blue.opacity(0.1))
        }
    }
}

struct ABCToolView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("THE ABC MODEL")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(Theme.blue)
                
                Text("Developed by Albert Ellis, this model helps you understand the link between events and your emotional response.")
                    .font(.system(size: 16, weight: .medium))
                
                VStack(spacing: 20) {
                    abcStep(letter: "A", title: "Activating Event", content: "What actually happened? Stick to the facts without interpretation.")
                    abcStep(letter: "B", title: "Beliefs", content: "What did you tell yourself about the event? (e.g. 'I'm a failure')")
                    abcStep(letter: "C", title: "Consequences", content: "How did you feel and act as a result of those beliefs?")
                }
                
                Text("Challenge 'B' to change 'C'.")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(Theme.blue)
                    .padding(.top, 10)
            }
            .padding(30)
        }
        .background(Theme.offWhite)
        .navigationTitle("ABC Model")
    }
    
    private func abcStep(letter: String, title: String, content: String) -> some View {
        HStack(alignment: .top, spacing: 20) {
            Text(letter)
                .font(.system(size: 24, weight: .black))
                .foregroundColor(Theme.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 17, weight: .bold))
                Text(content).font(.system(size: 14)).foregroundColor(Theme.darkGrey)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct CBTInfoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("THE CBT APPROACH")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(Theme.blue)
                
                Text("Your thoughts create your reality. CBT (Cognitive Behavioral Therapy) focuses on identifying 'Cognitive Distortions'—biased ways of thinking that aren't based on facts.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Theme.nearBlack)
                
                VStack(alignment: .leading, spacing: 16) {
                    tipRow(title: "Catch It", content: "Notice the negative thought as it happens. Don't let it slide into your subconscious.")
                    tipRow(title: "Check It", content: "Is this thought 100% true? What evidence do you have against it?")
                    tipRow(title: "Change It", content: "Replace it with a balanced, factual statement. This isn't just 'positive thinking'—it's realistic thinking.")
                }
                
                NavigationLink(destination: DistortionLibraryView()) {
                    HStack {
                        Image(systemName: "book.fill")
                        Text("Identify Distortions")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.blue)
                    .clipShape(Capsule())
                }
                
                Spacer()
            }
            .padding(30)
        }
        .background(Theme.offWhite)
        .navigationTitle("CBT Insights")
    }
    
    private func tipRow(title: String, content: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Circle()
                .fill(Theme.blue.opacity(0.1))
                .frame(width: 32, height: 32)
                .overlay(Text("!").font(.system(size: 14, weight: .black)).foregroundColor(Theme.blue))
            
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

struct DistortionLibraryView: View {
    let distortions = [
        ("All-or-Nothing", "Viewing things in black-and-white. 'If I'm not perfect, I failed.'"),
        ("Overgeneralization", "Seeing a single negative event as a never-ending pattern of defeat."),
        ("Mental Filter", "Picking out a single negative detail and dwelling on it exclusively."),
        ("Disqualifying the Positive", "Rejecting positive experiences by insisting they 'don't count'."),
        ("Mind Reading", "Arbitrarily concluding that someone is reacting negatively to you."),
        ("Catastrophizing", "Expecting disaster to strike, no matter what.")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("COMMON DISTORTIONS")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(Theme.blue)
                    .padding(.horizontal, 20)
                
                ForEach(distortions, id: \.0) { item in
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
                    .auraStroke(color: Theme.blue.opacity(0.1))
                    .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 20)
        }
        .background(Theme.offWhite)
        .navigationTitle("Distortion Library")
    }
}

struct ThoughtCloud: View {
    let text: String
    @State private var pulse = false
    
    var body: some View {
        ZStack {
            // Ambient Glow
            Circle()
                .fill(Color.red.opacity(0.1))
                .frame(width: 80, height: 60)
                .blur(radius: 10)
                .scaleEffect(pulse ? 1.2 : 0.8)
            
            // Cloud Shape (using circles)
            ZStack {
                Circle().fill(Theme.cardBg).frame(width: 40, height: 40).offset(x: -20)
                Circle().fill(Theme.cardBg).frame(width: 50, height: 50).offset(y: -10)
                Circle().fill(Theme.cardBg).frame(width: 40, height: 40).offset(x: 20)
            }
            .shadow(color: .black.opacity(0.05), radius: 5)
            
            Text(text)
                .font(.system(size: 11, weight: .black))
                .foregroundColor(Theme.nearBlack)
                .multilineTextAlignment(.center)
                .frame(width: 80)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

struct ReframeSheet: View {
    let thought: String
    let onReframe: () -> Void
    @Environment(\.dismiss) var dismiss
    @State private var reframedText = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("NEGATIVE THOUGHT")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.red)
                    Text(thought)
                        .font(.system(size: 20, weight: .bold))
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.red.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("REFRAME IT")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(Theme.blue)
                    TextField("How would you reframe this?", text: $reframedText)
                        .font(.system(size: 18, weight: .medium))
                        .padding()
                        .background(Theme.cardBg)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .auraStroke(color: Theme.blue.opacity(0.2))
                }
                
                Button(action: {
                    onReframe()
                    dismiss()
                }) {
                    Text("Neutralize Thought")
                        .font(.system(size: 17, weight: .black))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.blue)
                        .clipShape(Capsule())
                }
                .disabled(reframedText.isEmpty)
                
                Spacer()
            }
            .padding(30)
            .navigationTitle("Reframe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
