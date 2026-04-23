import SwiftUI
import CoreMotion
import Combine

struct SomaticLabView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss
    
    @State private var motionManager = CMMotionManager()
    @State private var shakeCount = 0
    @State private var isShakingMode = false
    @State private var shakeIntensity: Double = 0.0
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.offWhite.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        header
                        
                        if isShakingMode {
                            shakingInterface
                        } else {
                            toolList
                        }
                        
                        Spacer()
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Somatic Lab")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.walk.motion")
                .font(.system(size: 40))
                .foregroundColor(Theme.blue)
                .padding(20)
                .background(Theme.blue.opacity(0.1))
                .clipShape(Circle())
            
            Text("Physical Release")
                .font(.system(size: 24, weight: .black))
                .foregroundColor(Theme.nearBlack)
            
            Text("Anxiety lives in the body. Release it through movement and sensation.")
                .font(.system(size: 14))
                .foregroundColor(Theme.midGrey)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
    
    private var toolList: some View {
        VStack(spacing: 16) {
            // MARK: - Shake it Off
            Button(action: startShaking) {
                HStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Theme.orange.opacity(0.1))
                            .frame(width: 56, height: 56)
                        Image(systemName: "iphone.radiowaves.left.and.right")
                            .font(.system(size: 24))
                            .foregroundColor(Theme.orange)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Shake it Off")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(Theme.nearBlack)
                        Text("Literally shake the stress away")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.midGrey)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Theme.lightGrey)
                }
                .padding(20)
                .background(Theme.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .auraStroke(color: Theme.orange.opacity(0.1))
            }
            .buttonStyle(.plain)
            
            // MARK: - Vagus Nerve Stim
            NavigationLink(destination: VagusNerveView()) {
                HStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Theme.blue.opacity(0.1))
                            .frame(width: 56, height: 56)
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 24))
                            .foregroundColor(Theme.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Vagus Nerve Hack")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(Theme.nearBlack)
                        Text("Cold water & humming guides")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.midGrey)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Theme.lightGrey)
                }
                .padding(20)
                .background(Theme.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .auraStroke(color: Theme.blue.opacity(0.1))
            }
            .buttonStyle(.plain)
            
            // MARK: - PMR
            NavigationLink(destination: PMRView()) {
                HStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Theme.green.opacity(0.1))
                            .frame(width: 56, height: 56)
                        Image(systemName: "figure.arms.open")
                            .font(.system(size: 24))
                            .foregroundColor(Theme.green)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Muscle Relaxation")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(Theme.nearBlack)
                        Text("Progressive tension release")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.midGrey)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Theme.lightGrey)
                }
                .padding(20)
                .background(Theme.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .auraStroke(color: Theme.green.opacity(0.1))
            }
            .buttonStyle(.plain)
        }
    }
    
    private var shakingInterface: some View {
        VStack(spacing: 40) {
            ZStack {
                Circle()
                    .stroke(Theme.orange.opacity(0.1), lineWidth: 4)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: CGFloat(shakeCount) / 50.0)
                    .stroke(Theme.orange, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 8) {
                    Text("\(shakeCount)")
                        .font(.system(size: 64, weight: .black))
                        .foregroundColor(Theme.nearBlack)
                    Text("SHAKES")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(Theme.midGrey)
                }
            }
            .padding(.top, 40)
            
            Text("SHAKE YOUR PHONE VIGOROUSLY")
                .font(.system(size: 14, weight: .black))
                .foregroundColor(Theme.orange)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Theme.orange.opacity(0.1))
                .clipShape(Capsule())
            
            Button(action: { 
                stopMotion()
                isShakingMode = false 
            }) {
                Text("I'm Finished")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Theme.midGrey)
            }
        }
    }
    
    private func startShaking() {
        withAnimation(.spring()) {
            isShakingMode = true
        }
        shakeCount = 0
        
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: .main) { data, error in
                guard let data = data else { return }
                
                let acceleration = sqrt(pow(data.acceleration.x, 2) + pow(data.acceleration.y, 2) + pow(data.acceleration.z, 2))
                
                if acceleration > 2.5 {
                    shakeCount += 1
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    
                    if shakeCount == 50 {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        store.addXP(25)
                        store.addAuraShards(3, source: "Shaking")
                        stopMotion()
                        withAnimation { isShakingMode = false }
                    }
                }
            }
        }
    }
    
    private func stopMotion() {
        motionManager.stopAccelerometerUpdates()
    }
}

struct VagusNerveView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                guideCard(title: "Cold Water Splash", text: "Splash ice-cold water on your face. This triggers the 'Mammalian Dive Reflex' which instantly slows your heart rate.", icon: "drop.fill", color: .blue)
                
                guideCard(title: "The Hum", text: "Close your mouth and hum a low note. Feel the vibration in your chest and throat. This stimulates the vagus nerve directly.", icon: "waveform", color: .purple)
                
                guideCard(title: "Ear Massage", text: "Gently massage the hollow of your outer ear. This area is rich in vagal nerve endings.", icon: "ear", color: .orange)
            }
            .padding(20)
        }
        .navigationTitle("Vagus Nerve Hacks")
    }
    
    func guideCard(title: String, text: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 18, weight: .bold))
            }
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(Theme.darkGrey)
                .lineSpacing(4)
        }
        .padding(24)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .auraStroke(color: color.opacity(0.1))
    }
}

struct PMRView: View {
    @State private var currentStep = 0
    @State private var isTensed = false
    @State private var progress: Double = 0.0
    @State private var timer: Timer.TimerPublisher = Timer.publish(every: 0.1, on: .main, in: .common)
    @State private var cancellable: Cancellable?
    
    let steps = [
        ("Feet & Toes", "Curl your toes tightly into your soles. Hold... and release."),
        ("Lower Legs", "Tense your calf muscles by pulling your toes toward your knees. Hold... and release."),
        ("Glutes & Hips", "Squeeze your glutes as tight as possible. Hold... and release."),
        ("Stomach", "Tighten your abdominal muscles as if someone is about to punch you. Hold... and release."),
        ("Hands & Arms", "Make tight fists and flex your biceps. Hold... and release."),
        ("Shoulders", "Pull your shoulders up to your ears. Hold... and release."),
        ("Face", "Scrunch up your whole face—eyes, mouth, forehead. Hold... and release.")
    ]
    
    var body: some View {
        ZStack {
            Theme.offWhite.ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Progress
                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { i in
                        Capsule()
                            .fill(i <= currentStep ? Theme.green : Theme.lightGrey.opacity(0.3))
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal, 30)
                
                VStack(spacing: 12) {
                    Text(steps[currentStep].0.uppercased())
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(Theme.green)
                    Text(steps[currentStep].1)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Theme.nearBlack)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(height: 120)
                
                // Visual Pulse
                ZStack {
                    Circle()
                        .fill(Theme.green.opacity(isTensed ? 0.2 : 0.05))
                        .frame(width: 240, height: 240)
                        .scaleEffect(isTensed ? 1.1 : 1.0)
                    
                    Circle()
                        .stroke(Theme.green, lineWidth: 2)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Theme.green, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                    
                    Text(isTensed ? "TENSE" : "RELAX")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(Theme.green)
                }
                
                Spacer()
                
                if currentStep < steps.count - 1 {
                    Button(action: nextStep) {
                        Text("Next Muscle Group")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                            .background(Theme.green)
                            .clipShape(Capsule())
                    }
                } else {
                    Button(action: { /* Dismiss/Finish */ }) {
                        Text("Session Complete")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                            .background(Theme.blue)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.top, 40)
            .padding(.bottom, 20)
        }
        .navigationTitle("Muscle Relaxation")
        .onAppear { startSequence() }
        .onDisappear { cancellable?.cancel() }
    }
    
    private func startSequence() {
        progress = 0
        isTensed = true
        cancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if progress < 1.0 {
                    progress += 0.02
                } else {
                    if isTensed {
                        isTensed = false
                        progress = 0
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                }
            }
    }
    
    private func nextStep() {
        withAnimation {
            currentStep += 1
            startSequence()
        }
    }
}
