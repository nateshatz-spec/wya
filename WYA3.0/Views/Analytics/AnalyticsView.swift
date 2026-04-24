import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject var store: DataStore
    @State private var showingExport = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(hex: "0F1419").ignoresSafeArea()
                
                ScrollView {
                    if store.moodEntries.isEmpty {
                        lockedStateView
                    } else {
                        VStack(spacing: 32) {
                            // Header info
                            headerInfo
                            
                            // Mood Trends Chart
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Mood Trends")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                
                                MoodLineChart(logs: store.moodEntries)
                                    .frame(height: 200)
                            }
                            .padding(.horizontal, 4)
                            
                            // Aura Intensity Gauges
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Aura Intensity (Daily Average)")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                HStack(spacing: 20) {
                                    AuraGauge(label: "Overall Intensity", value: 72, sublabel: "High - Pulse")
                                    AuraGauge(label: "Consistency", value: 84, sublabel: "Stable")
                                }
                            }
                            
                            // Clinical Summary
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Clinical Summary")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                
                                HStack(spacing: 16) {
                                    RecoveryProgressCard()
                                    TriggerAnalysisCard(triggers: store.getTopTriggers())
                                }
                            }
                            
                            Spacer(minLength: 40)
                        }
                        .padding(20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundColor(Theme.blue)
                        Text("WYA 3.0")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.white)
                        Text("Your Analytics")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 24))
                }
            }
        }
    }
    
    private var lockedStateView: some View {
        VStack(spacing: 40) {
            Spacer(minLength: 100)
            
            ZStack {
                Circle()
                    .fill(Theme.blue.opacity(0.1))
                    .frame(width: 140, height: 140)
                    .blur(radius: 20)
                
                Image(systemName: "chart.xyaxis.line")
                    .font(.system(size: 60))
                    .foregroundColor(Theme.blue)
                    .opacity(0.3)
                
                Image(systemName: "lock.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .offset(x: 20, y: 20)
            }
            
            VStack(spacing: 16) {
                Text("Trends Locked")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.white)
                
                Text("Log your first mood to unlock AI-powered insights and clinical trends.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                // Navigate to Wellness tab to log mood
                // Note: In a real app we'd trigger the log sheet or switch tabs
            }) {
                Text("Start Your First Log")
                    .font(.system(size: 15, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(Theme.blue)
                    .clipShape(Capsule())
                    .shadow(color: Theme.blue.opacity(0.4), radius: 10)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var headerInfo: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Week: Oct 23 - 29")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            Spacer()
            HStack(spacing: 20) {
                Image(systemName: "chevron.left")
                Text("Oct")
                    .font(.system(size: 16, weight: .medium))
                Image(systemName: "chevron.right")
            }
            .foregroundColor(.white.opacity(0.5))
        }
    }
}

// MARK: - Custom Charting Components

struct MoodLineChart: View {
    let logs: [MoodEntry]
    
    var body: some View {
        VStack {
            ZStack {
                // Grid Lines
                VStack(spacing: 34) {
                    ForEach(0..<6) { i in
                        Divider().background(Color.white.opacity(0.05))
                    }
                }
                
                // The Line
                GeometryReader { geo in
                    let points = getPoints(size: geo.size)
                    
                    Path { path in
                        if let first = points.first {
                            path.move(to: first)
                            for point in points.dropFirst() {
                                path.addLine(to: point)
                            }
                        }
                    }
                    .stroke(
                        LinearGradient(colors: [Theme.blue, Theme.blue.opacity(0.5)], startPoint: .top, endPoint: .bottom),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                    )
                    .shadow(color: Theme.blue.opacity(0.5), radius: 10)
                    
                    // Points
                    ForEach(0..<points.count, id: \.self) { i in
                        Circle()
                            .fill(Theme.blue)
                            .frame(width: 8, height: 8)
                            .position(points[i])
                            .shadow(color: Theme.blue, radius: 4)
                        
                        // Value Tag for Thursday (Mockup specific)
                        if i == 3 {
                            Text("8.2")
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Theme.blue)
                                .clipShape(Capsule())
                                .position(x: points[i].x, y: points[i].y - 20)
                        }
                    }
                }
            }
            
            // X-Axis
            HStack {
                ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.4))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 10)
        }
    }
    
    private func getPoints(size: CGSize) -> [CGPoint] {
        let values: [CGFloat] = [0.2, 0.4, 0.3, 0.8, 0.5, 0.6, 0.75]
        var points: [CGPoint] = []
        let stepX = size.width / 6
        
        for i in 0..<values.count {
            let x = CGFloat(i) * stepX
            let y = size.height * (1 - values[i])
            points.append(CGPoint(x: x, y: y))
        }
        return points
    }
}

struct AuraGauge: View {
    let label: String
    let value: Int
    let sublabel: String
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.05), lineWidth: 10)
                
                Circle()
                    .trim(from: 0, to: CGFloat(value) / 100.0)
                    .stroke(
                        LinearGradient(colors: [Color(hex: "A855F7"), Color(hex: "7C3AED")], startPoint: .top, endPoint: .bottom),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: Color(hex: "A855F7").opacity(0.5), radius: 6)
                
                Text("\(value)%")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: 120, height: 120)
            
            VStack(spacing: 2) {
                Text(label)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Text(sublabel)
                    .font(.system(size: 11))
                    .foregroundColor(Theme.blue.opacity(0.8))
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .frame(maxWidth: .infinity)
    }
}

struct RecoveryProgressCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recovery Progress")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            
            Text("78% Complete")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
            
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 6)
                    Circle()
                        .trim(from: 0, to: 0.78)
                        .stroke(Theme.blue, lineWidth: 6)
                        .rotationEffect(.degrees(-90))
                    Text("78%")
                        .font(.system(size: 12, weight: .bold))
                }
                .frame(width: 50, height: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    progressRow(label: "Mood Stability")
                    progressRow(label: "Symptom Reduction")
                    progressRow(label: "Resilience Growth")
                }
            }
            
            HStack {
                Text("Positive summary is upward...")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.4))
                Spacer()
                Image(systemName: "arrow.up.right")
                    .foregroundColor(Theme.blue)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .frame(maxWidth: .infinity)
    }
    
    private func progressRow(label: String) -> some View {
        Text(label)
            .font(.system(size: 9, weight: .medium))
            .foregroundColor(.white.opacity(0.7))
    }
}

struct TriggerAnalysisCard: View {
    let triggers: [(String, Int)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trigger Analysis")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                triggerItem(index: 1, label: "Stress (45%)", icon: "waveform.path.ecg", color: .purple)
                triggerItem(index: 2, label: "Sleep Issues (30%)", icon: "moon.fill", color: .orange)
                triggerItem(index: 3, label: "Conflict (15%)", icon: "bubble.left.fill", color: .blue)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .frame(maxWidth: .infinity)
    }
    
    private func triggerItem(index: Int, label: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("\(index). \(label)")
                    .font(.system(size: 10, weight: .medium))
                Spacer()
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundColor(color)
            }
            Capsule()
                .fill(Color.white.opacity(0.1))
                .frame(height: 4)
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(LinearGradient(colors: [color, color.opacity(0.5)], startPoint: .leading, endPoint: .trailing))
                        .frame(width: 40) // Simplified for UI
                }
        }
    }
}


// MARK: - Color Hex Extension
// Note: This is now handled globally in Theme.swift
