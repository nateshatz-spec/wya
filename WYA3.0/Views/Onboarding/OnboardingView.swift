import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var store: DataStore
    @EnvironmentObject var auth: AuthManager
    @State private var currentStep = 0
    @State private var name: String = ""
    @State private var selectedGoals: Set<String> = []
    @State private var selectedConditions: Set<String> = []
    @State private var showingDisclaimer = false
    
    private let totalSteps = 8
    @State private var gender: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSigningUp = false
    @State private var errorMessage: String?
    @State private var showingLogin = false
    
    var body: some View {
        ZStack {
            // Background based on current step or neutral
            Theme.offWhite.ignoresSafeArea()
            
            // Background Aura (Dynamic Palette based on step)
            AuraBackgroundContainer(palette: currentPalette) {
                VStack(spacing: 0) {
                    // Progress Bar
                    progressHeader
                    
                    TabView(selection: $currentStep) {
                        WelcomeStepView(onSignInTap: { showingLogin = true })
                            .tag(0)
                        
                        GoalSelectionStep(selectedGoals: $selectedGoals)
                            .tag(1)
                        
                        ConditionStepView(selectedConditions: $selectedConditions)
                            .tag(2)
                        
                        GenderStepView(selectedGender: $gender)
                            .tag(3)
                        
                        ProfileSetupStep(name: $name)
                            .tag(4)
                        
                        AuthStepView(email: $email, password: $password)
                            .tag(5)
                        
                        AuraIntroStep()
                            .tag(6)
                        
                        CelebrationStepView(name: name)
                            .tag(7)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentStep)
                    
                    // Navigation Button
                    navigationFooter
                }
            }
        }
        .interactiveDismissDisabled()
        .sheet(isPresented: $showingDisclaimer) {
            MedicalDisclaimerView()
        }
        .sheet(isPresented: $showingLogin) {
            LoginView()
        }
        .overlay {
            if isSigningUp {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    VStack(spacing: 20) {
                        ProgressView()
                            .tint(.white)
                        Text("Creating your account...")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .alert("Signup Failed", isPresented: .init(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "")
        }
        .onAppear {
            if !store.hasSeenDisclaimer {
                showingDisclaimer = true
                store.hasSeenDisclaimer = true
                store.saveAll()
            }
        }
    }
    
    private var currentPalette: AuraPalette {
        switch currentStep {
        case 0: return .fromID("ice")
        case 1: return .fromID("sunlight")
        case 2: return .fromID("forest")
        case 3: return .fromID("midnight")
        case 4: return .fromID("ice")
        case 5: return .fromID("sunlight")
        case 6: return .fromID("ice")
        default: return .fromID("ice")
        }
    }
    
    private var progressHeader: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index <= currentStep ? Theme.blue : Theme.lightGrey)
                    .frame(height: 4)
                    .animation(.spring(), value: currentStep)
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, 20)
    }
    
    private var navigationFooter: some View {
        VStack(spacing: 16) {
            Button(action: nextStep) {
                Text(currentStep == totalSteps - 1 ? "Start Journey" : "Continue")
                    .font(.system(size: 17, weight: .black))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
            }
            .disabled(!canContinue)
            .accessibilityLabel(currentStep == totalSteps - 1 ? "Finish Onboarding" : "Continue to next step")
            .accessibilityHint("Goes to step \(currentStep + 2) of \(totalSteps)")
            
            if currentStep < totalSteps - 1 {
                Button("Skip for now") {
                    finishOnboarding()
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Theme.midGrey)
            }
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 40)
    }
    
    private var canContinue: Bool {
        switch currentStep {
        case 3: return !gender.isEmpty
        case 4: return !name.isEmpty
        case 5: return !email.isEmpty && password.count >= 6
        default: return true
        }
    }
    
    private func nextStep() {
        if currentStep == 5 { // This is the Auth Step
            performSignUp()
        } else if currentStep < totalSteps - 1 {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                currentStep += 1
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } else {
            // Final completion
            store.hasCompletedOnboarding = true
            store.saveAll()
            
            // Sync with AuthManager to trigger the view switch
            withAnimation(.spring()) {
                auth.hasCompletedOnboarding = true
            }
        }
    }
    
    private func finishOnboarding() {
        // Fallback for the "Skip" button
        store.hasCompletedOnboarding = true
        store.saveAll()
        
        withAnimation(.spring()) {
            auth.hasCompletedOnboarding = true
        }
    }
    
    private func performSignUp() {
        guard !email.isEmpty && password.count >= 6 else { return }
        
        isSigningUp = true
        errorMessage = nil
        
        auth.signUp(name: name, email: email, password: password) { error in
            isSigningUp = false
            
            if let error = error {
                errorMessage = error.localizedDescription
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                return
            }
            
            // Success! Proceed to Celebration
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                currentStep += 1 // Go to Aura Intro
            }
            
            // Save local metadata
            store.userName = name
            store.userGender = gender
            store.wellnessGoals = Array(selectedGoals)
            store.mentalConditions = Array(selectedConditions)
            store.saveAll()
            
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}

// MARK: - Step Views

struct WelcomeStepView: View {
    var onSignInTap: () -> Void
    @State private var showLogo = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 40) {
                ZStack {
                    // Animated glow behind logo
                    Circle()
                        .fill(Theme.blue.opacity(0.1))
                        .frame(width: 160, height: 160)
                        .blur(radius: 40)
                        .scaleEffect(showLogo ? 1.2 : 0.8)
                    
                    Image("logo") // Using the actual logo asset
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 140)
                        .scaleEffect(showLogo ? 1.0 : 0.5)
                        .opacity(showLogo ? 1.0 : 0)
                }
                
                VStack(spacing: 16) {
                    Text("WELCOME TO WYA 3.0")
                        .font(.system(size: 14, weight: .black))
                        .kerning(4)
                        .foregroundColor(Theme.blue)
                        .opacity(showLogo ? 1 : 0)
                        .offset(y: showLogo ? 0 : 20)
                    
                    Text("Find Your Clarity.")
                        .font(.system(size: 40, weight: .black))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Theme.nearBlack)
                        .opacity(showLogo ? 1 : 0)
                        .offset(y: showLogo ? 0 : 20)
                    
                    Text("A cinematic experience for your mental wellness. Master your anxiety with AI-powered insights.")
                        .font(.system(size: 17, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Theme.darkGrey)
                        .padding(.horizontal, 40)
                        .opacity(showLogo ? 0.8 : 0)
                        .offset(y: showLogo ? 0 : 20)
                }
            }
            
            Spacer()
            
            Button(action: onSignInTap) {
                HStack {
                    Text("Already a member?")
                        .foregroundColor(Theme.midGrey)
                    Text("Sign In")
                        .foregroundColor(Theme.blue)
                        .fontWeight(.bold)
                }
                .font(.system(size: 15))
            }
            .opacity(showLogo ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3)) {
                showLogo = true
            }
        }
    }
}

struct GoalSelectionStep: View {
    @Binding var selectedGoals: Set<String>
    
    let goals = [
        ("Manage Anxiety", "bolt.shield"),
        ("Better Sleep", "moon.stars"),
        ("Track Meds", "pills"),
        ("Journaling", "pencil.line"),
        ("Daily Gratitude", "heart"),
        ("Clinical Progress", "chart.xyaxis.line")
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("YOUR GOALS")
                    .font(.system(size: 12, weight: .black))
                    .kerning(2)
                    .foregroundColor(Theme.blue)
                
                Text("What brings you here?")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(Theme.nearBlack)
            }
            .padding(.top, 40)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(goals, id: \.0) { goal in
                    Button(action: {
                        if selectedGoals.contains(goal.0) {
                            selectedGoals.remove(goal.0)
                        } else {
                            selectedGoals.insert(goal.0)
                        }
                        UISelectionFeedbackGenerator().selectionChanged()
                    }) {
                        VStack(spacing: 12) {
                            Image(systemName: goal.1)
                                .font(.system(size: 24))
                            Text(goal.0)
                                .font(.system(size: 14, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(selectedGoals.contains(goal.0) ? Theme.blue : Theme.cardBg)
                        .foregroundColor(selectedGoals.contains(goal.0) ? .white : Theme.nearBlack)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .auraStroke(color: selectedGoals.contains(goal.0) ? .clear : Theme.blue.opacity(0.1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
    }
}

struct ProfileSetupStep: View {
    @Binding var name: String
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 8) {
                Text("IDENTITY")
                    .font(.system(size: 12, weight: .black))
                    .kerning(2)
                    .foregroundColor(Theme.blue)
                
                Text("How should we\naddress you?")
                    .font(.system(size: 28, weight: .black))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Theme.nearBlack)
            }
            .padding(.top, 40)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("YOUR NAME")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(Theme.midGrey)
                
                TextField("Enter your name", text: $name)
                    .font(.system(size: 20, weight: .bold))
                    .padding(20)
                    .background(Theme.cardBg)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .auraStroke(color: Theme.blue.opacity(0.1))
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
    }
}

struct AuraIntroStep: View {
    @State private var isBreathing = false
    @State private var breathStatus = "Inhale"
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 8) {
                Text("THE MOOD RING")
                    .font(.system(size: 12, weight: .black))
                    .kerning(2)
                    .foregroundColor(Theme.blue)
                
                Text("Your Aura.")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(Theme.nearBlack)
            }
            .padding(.top, 40)
            
            // A visual representation of the aura with breathing animation
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [.blue, .purple, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: isBreathing ? 240 : 180, height: isBreathing ? 240 : 180)
                    .blur(radius: 40)
                    .opacity(isBreathing ? 0.4 : 0.2)
                
                Circle()
                    .stroke(Theme.blue.opacity(0.2), lineWidth: 1)
                    .frame(width: 260, height: 260)
                    .scaleEffect(isBreathing ? 1.0 : 0.8)
                
                Image(systemName: "circle.hexagongrid.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        .linearGradient(colors: [Theme.blue, Theme.blueLight], startPoint: .top, endPoint: .bottom)
                    )
                    .scaleEffect(isBreathing ? 1.1 : 0.95)
            }
            .frame(height: 260)
            
            VStack(spacing: 8) {
                Text(breathStatus)
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(Theme.blue)
                    .transition(.opacity)
                    .id(breathStatus)
                
                Text("The edges of your screen will glow based on your mood. It's a living reflection of your mental state.")
                    .font(.system(size: 16, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Theme.darkGrey)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                isBreathing = true
            }
            
            // Cycle text
            Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
                withAnimation {
                    breathStatus = (breathStatus == "Inhale") ? "Exhale" : "Inhale"
                }
            }
        }
    }
}

struct ConditionStepView: View {
    @Binding var selectedConditions: Set<String>
    
    let conditions = [
        ("Social Anxiety", "person.2.fill"),
        ("General Anxiety", "wind"),
        ("Panic Disorder", "exclamationmark.circle.fill"),
        ("Depression", "cloud.rain.fill"),
        ("ADHD", "bolt.fill"),
        ("OCD", "arrow.3.trianglepath"),
        ("PTSD", "shield.fill"),
        ("Stress", "thermometer.high")
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("PERSONALIZATION")
                    .font(.system(size: 12, weight: .black))
                    .kerning(2)
                    .foregroundColor(Theme.blue)
                
                Text("What should we track?")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(Theme.nearBlack)
            }
            .padding(.top, 40)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(conditions, id: \.0) { condition in
                        Button(action: {
                            if selectedConditions.contains(condition.0) {
                                selectedConditions.remove(condition.0)
                            } else {
                                selectedConditions.insert(condition.0)
                            }
                            UISelectionFeedbackGenerator().selectionChanged()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: condition.1)
                                    .font(.system(size: 18))
                                    .frame(width: 32, height: 32)
                                    .background(selectedConditions.contains(condition.0) ? Color.white.opacity(0.2) : Theme.blue.opacity(0.1))
                                    .clipShape(Circle())
                                
                                Text(condition.0)
                                    .font(.system(size: 14, weight: .bold))
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                if selectedConditions.contains(condition.0) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(selectedConditions.contains(condition.0) ? Theme.blue : Theme.cardBg)
                            .foregroundColor(selectedConditions.contains(condition.0) ? .white : Theme.nearBlack)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .auraStroke(color: selectedConditions.contains(condition.0) ? .clear : Theme.blue.opacity(0.1))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
            }
        }
    }
}

struct GenderStepView: View {
    @Binding var selectedGender: String
    
    let genders = [
        ("Female", "person.fill.viewfinder"),
        ("Male", "person.fill"),
        ("Other", "person.fill.questionmark")
    ]
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 8) {
                Text("PERSONALIZATION")
                    .font(.system(size: 12, weight: .black))
                    .kerning(2)
                    .foregroundColor(Theme.blue)
                
                Text("Your Identity.")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(Theme.nearBlack)
            }
            .padding(.top, 40)
            
            VStack(spacing: 16) {
                ForEach(genders, id: \.0) { gender in
                    Button(action: {
                        selectedGender = gender.0
                        UISelectionFeedbackGenerator().selectionChanged()
                    }) {
                        HStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(selectedGender == gender.0 ? Color.white.opacity(0.2) : Theme.blue.opacity(0.1))
                                    .frame(width: 48, height: 48)
                                Image(systemName: gender.1)
                                    .font(.system(size: 20))
                                    .foregroundColor(selectedGender == gender.0 ? .white : Theme.blue)
                            }
                            
                            Text(gender.0)
                                .font(.system(size: 18, weight: .bold))
                            
                            Spacer()
                            
                            if selectedGender == gender.0 {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(selectedGender == gender.0 ? Theme.blue : Theme.cardBg)
                        .foregroundColor(selectedGender == gender.0 ? .white : Theme.nearBlack)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .auraStroke(color: selectedGender == gender.0 ? .clear : Theme.blue.opacity(0.1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
    }
}

struct CelebrationStepView: View {
    let name: String
    @State private var showContent = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                // Outer glow
                Circle()
                    .fill(Theme.blue.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .scaleEffect(showContent ? 1.2 : 0.8)
                    .opacity(showContent ? 1 : 0)
                
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        .linearGradient(colors: [Theme.blue, Theme.blueLight], startPoint: .top, endPoint: .bottom)
                    )
                    .scaleEffect(showContent ? 1.0 : 0.5)
                    .rotationEffect(.degrees(showContent ? 0 : -45))
            }
            
            VStack(spacing: 16) {
                Text("YOU'RE ALL SET")
                    .font(.system(size: 12, weight: .black))
                    .kerning(2)
                    .foregroundColor(Theme.blue)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                
                Text("Welcome, \(name).")
                    .font(.system(size: 34, weight: .black))
                    .foregroundColor(Theme.nearBlack)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                
                Text("Your journey to clarity starts now. We've prepared your personalized dashboard and therapy tools.")
                    .font(.system(size: 16, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Theme.darkGrey)
                    .padding(.horizontal, 40)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
            }
            
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                showContent = true
            }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}

struct AuthStepView: View {
    @Binding var email: String
    @Binding var password: String
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text("SECURITY")
                    .font(.system(size: 12, weight: .black))
                    .kerning(2)
                    .foregroundColor(Theme.blue)
                
                Text("Secure Your Cloud.")
                    .font(.system(size: 32, weight: .black))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Theme.nearBlack)
                
                Text("Create an account to sync your aura and therapy tools across all your devices.")
                    .font(.system(size: 15, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Theme.darkGrey)
                    .padding(.horizontal, 40)
            }
            .padding(.top, 40)
            
            VStack(spacing: 24) {
                // Email Field
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(Theme.blue)
                        Text("EMAIL ADDRESS")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(Theme.midGrey)
                    }
                    
                    TextField("your@email.com", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(20)
                        .background(Theme.cardBg)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .auraStroke(color: email.contains("@") ? Theme.blue.opacity(0.3) : Theme.blue.opacity(0.1))
                }
                
                // Password Field
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(Theme.blue)
                        Text("PASSWORD")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(Theme.midGrey)
                    }
                    
                    SecureField("At least 6 characters", text: $password)
                        .padding(20)
                        .background(Theme.cardBg)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .auraStroke(color: password.count >= 6 ? Theme.blue.opacity(0.3) : Theme.blue.opacity(0.1))
                }
            }
            .padding(.horizontal, 30)
            
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("End-to-end encrypted sync")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Theme.darkGrey)
            }
            .padding(.top, 10)
            
            Spacer()
        }
    }
}

struct LoginView: View {
    @EnvironmentObject var auth: AuthManager
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggingIn = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.offWhite.ignoresSafeArea()
                
                VStack(spacing: 32) {
                    VStack(spacing: 12) {
                        Text("WELCOME BACK")
                            .font(.system(size: 12, weight: .black))
                            .kerning(2)
                            .foregroundColor(Theme.blue)
                        
                        Text("Sign In")
                            .font(.system(size: 34, weight: .black))
                            .foregroundColor(Theme.nearBlack)
                    }
                    .padding(.top, 60)
                    
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("EMAIL")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(Theme.midGrey)
                            TextField("your@email.com", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding(18)
                                .background(Theme.cardBg)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("PASSWORD")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(Theme.midGrey)
                            SecureField("Enter your password", text: $password)
                                .padding(18)
                                .background(Theme.cardBg)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.red)
                            .padding(.horizontal, 40)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: handleLogin) {
                        if isLoggingIn {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Sign In")
                                .font(.system(size: 17, weight: .black))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Theme.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 30)
                    .disabled(email.isEmpty || password.isEmpty || isLoggingIn)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func handleLogin() {
        isLoggingIn = true
        errorMessage = nil
        
        auth.signIn(email: email, password: password) { error in
            isLoggingIn = false
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            
            // On success, the app will automatically switch views via auth.hasCompletedOnboarding
            dismiss()
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(DataStore(userId: "preview"))
        .environmentObject(AuthManager())
}
