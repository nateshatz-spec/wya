import SwiftUI

struct CrisisCommandView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss
    
    @State private var currentStep = 0
    @State private var itemsFound: [String] = []
    @State private var isGroundingActive = false
    
    let groundingSteps = [
        (5, "See", "Name 5 things you can see around you.", "eye.fill"),
        (4, "Feel", "Name 4 things you can feel (e.g. feet on floor).", "hand.tap.fill"),
        (3, "Hear", "Name 3 things you can hear right now.", "ear.fill"),
        (2, "Smell", "Name 2 things you can smell.", "nose.fill"),
        (1, "Taste", "Name 1 thing you can taste.", "mouth.fill")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.offWhite.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: - Panic Alert Header
                        VStack(spacing: 8) {
                            Image(systemName: "exclamationmark.shield.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Theme.red)
                            Text("Crisis Support")
                                .font(.system(size: 28, weight: .black))
                                .foregroundColor(Theme.nearBlack)
                            Text("You are safe. We are here with you.")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Theme.midGrey)
                        }
                        .padding(.top, 40)
                        
                        if !isGroundingActive {
                            mainMenu
                        } else {
                            groundingFlow
                        }
                        
                        Spacer()
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Exit") { dismiss() }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Theme.midGrey)
                }
            }
        }
    }
    
    private var mainMenu: some View {
        VStack(spacing: 16) {
            // MARK: - Grounding Exercise
            Button(action: {
                withAnimation(.spring()) {
                    isGroundingActive = true
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                }
            }) {
                HStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Theme.blue.opacity(0.1))
                            .frame(width: 60, height: 60)
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 24))
                            .foregroundColor(Theme.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Grounding Exercise")
                            .font(.system(size: 18, weight: .black))
                            .foregroundColor(Theme.nearBlack)
                        Text("The 5-4-3-2-1 technique")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.midGrey)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Theme.lightGrey)
                }
                .padding(24)
                .background(Theme.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .auraStroke(color: Theme.blue.opacity(0.1))
            }
            .buttonStyle(.plain)
            
            // MARK: - Safety Plan
            NavigationLink(destination: SafetyPlanEditorView()) {
                HStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Theme.green.opacity(0.1))
                            .frame(width: 60, height: 60)
                        Image(systemName: "list.bullet.clipboard.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Theme.green)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Safety Plan")
                            .font(.system(size: 18, weight: .black))
                            .foregroundColor(Theme.nearBlack)
                        Text(store.safetyPlan.warningSigns.isEmpty ? "Create your plan for strength" : "Reminders of your strength")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.midGrey)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Theme.lightGrey)
                }
                .padding(24)
                .background(Theme.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .auraStroke(color: Theme.green.opacity(0.1))
            }
            .buttonStyle(.plain)
            
            // MARK: - Emergency Contacts
            VStack(alignment: .leading, spacing: 16) {
                Text("GET HELP NOW")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(Theme.midGrey)
                    .padding(.horizontal, 4)
                
                HStack(spacing: 12) {
                    emergencyButton(title: "Crisis Line", sub: "Text HOME to 741741", color: Theme.nearBlack, icon: "phone.fill")
                    emergencyButton(title: "Emergency", sub: "Call 911", color: Theme.red, icon: "staroflife.fill")
                }
            }
            .padding(.top, 12)
        }
    }
    
    private var groundingFlow: some View {
        let step = groundingSteps[currentStep]
        
        return VStack(spacing: 32) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Theme.blue.opacity(0.1))
                        .frame(width: 100, height: 100)
                    Image(systemName: step.3)
                        .font(.system(size: 40))
                        .foregroundColor(Theme.blue)
                }
                
                Text("\(step.0) \(step.1)")
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(Theme.nearBlack)
                
                Text(step.2)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Theme.darkGrey)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .padding(.top, 40)
            
            VStack(spacing: 12) {
                Button(action: nextStep) {
                    Text(currentStep < 4 ? "I've Found Them" : "I Feel Better")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Theme.blue)
                        .clipShape(Capsule())
                        .shadow(color: Theme.blue.opacity(0.3), radius: 15, y: 8)
                }
                
                if currentStep < 4 {
                    Button(action: { isGroundingActive = false }) {
                        Text("Stop Grounding")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Theme.midGrey)
                    }
                    .padding(.top, 8)
                }
            }
            
            // Progress dots
            HStack(spacing: 8) {
                ForEach(0..<5) { i in
                    Circle()
                        .fill(i == currentStep ? Theme.blue : Theme.lightGrey)
                        .frame(width: 8, height: 8)
                }
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
    }
    
    private func nextStep() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        if currentStep < 4 {
            withAnimation(.spring()) {
                currentStep += 1
            }
        } else {
            store.addXP(30)
            store.addAuraShards(5, source: "Grounding")
            dismiss()
        }
    }
    
    private func emergencyButton(title: String, sub: String, color: Color, icon: String) -> some View {
        Button(action: { /* Call action */ }) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.system(size: 15, weight: .black))
                Text(sub)
                    .font(.system(size: 11, weight: .bold))
                    .opacity(0.7)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: color.opacity(0.2), radius: 10, y: 5)
        }
    }
}
