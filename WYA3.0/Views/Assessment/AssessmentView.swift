import SwiftUI

struct AssessmentView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss
    @State private var activeTest: String? = nil
    @State private var currentQ = 0
    @State private var answers: [Int] = []
    @State private var showResult = false

    let phq9 = [
        "Little interest or pleasure in doing things",
        "Feeling down, depressed, or hopeless",
        "Trouble falling or staying asleep, or sleeping too much",
        "Feeling tired or having little energy",
        "Poor appetite or overeating",
        "Feeling bad about yourself — or that you are a failure",
        "Trouble concentrating on things",
        "Moving or speaking slowly, or being fidgety/restless",
        "Thoughts that you would be better off dead, or of hurting yourself"
    ]

    let gad7 = [
        "Feeling nervous, anxious, or on edge",
        "Not being able to stop or control worrying",
        "Worrying too much about different things",
        "Trouble relaxing",
        "Being so restless that it's hard to sit still",
        "Becoming easily annoyed or irritable",
        "Feeling afraid as if something awful might happen"
    ]

    let options = ["Not at all", "Several days", "More than half the days", "Nearly every day"]

    var questions: [String] { activeTest == "PHQ-9" ? phq9 : gad7 }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if activeTest == nil {
                    // Test selection
                    VStack(spacing: 16) {
                        Text("Standardized assessments to track your mental health over time.")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.midGrey)
                            .multilineTextAlignment(.center)

                        Button(action: { startTest("PHQ-9") }) {
                            testCard(title: "PHQ-9", subtitle: "Depression Screening", icon: "cloud.rain.fill", color: Theme.blue, questions: 9)
                        }
                        Button(action: { startTest("GAD-7") }) {
                            testCard(title: "GAD-7", subtitle: "Anxiety Screening", icon: "bolt.heart.fill", color: Theme.orange, questions: 7)
                        }
                    }
                    .padding(16)

                    // History
                    if !store.assessments.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("📊 History")
                                .font(.system(size: 15, weight: .semibold))
                            ForEach(store.assessments.reversed()) { r in
                                HStack {
                                    Text(r.type).font(.system(size: 13, weight: .bold)).foregroundColor(Theme.blue)
                                    Text("\(r.score) pts").font(.system(size: 13, weight: .semibold))
                                    Text(r.severity)
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(Color(hex: r.severityColor))
                                        .padding(.horizontal, 8).padding(.vertical, 2)
                                        .background(Color(hex: r.severityColor).opacity(0.1))
                                        .clipShape(Capsule())
                                    Spacer()
                                    Text(r.date).font(.system(size: 11)).foregroundColor(Theme.midGrey)
                                }
                                .padding(12)
                                .background(Theme.offWhite)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMd, style: .continuous))
                            }
                        }
                        .cardStyle()
                        .padding(.horizontal, 16)
                    }

                } else if showResult {
                    // Result
                    resultView
                } else {
                    // Question flow
                    questionView
                }
            }
        }
        .background(Theme.offWhite)
        .navigationTitle("Assessments")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func testCard(title: String, subtitle: String, icon: String, color: Color, questions: Int) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 48, height: 48)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 17, weight: .bold)).foregroundColor(Theme.nearBlack)
                Text(subtitle).font(.system(size: 13)).foregroundColor(Theme.midGrey)
                Text("\(questions) questions · 2 min").font(.system(size: 11)).foregroundColor(Theme.midGrey)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(Theme.lightGrey)
        }
        .padding(16)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusXl, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }

    private var questionView: some View {
        VStack(spacing: 20) {
            // Progress
            ProgressView(value: Double(currentQ), total: Double(questions.count))
                .tint(Theme.blue)
                .padding(.horizontal, 16)

            Text("Question \(currentQ + 1) of \(questions.count)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Theme.midGrey)

            VStack(spacing: 16) {
                Text("Over the last 2 weeks, how often have you been bothered by:")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.midGrey)

                Text(questions[currentQ])
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.nearBlack)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.vertical, 8)

                // Q9 crisis note
                if activeTest == "PHQ-9" && currentQ == 8 {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.fill").foregroundColor(.red)
                        Text("If you're in crisis, call 988 now.")
                            .font(.system(size: 13, weight: .semibold)).foregroundColor(.red)
                    }
                    .padding(12)
                    .background(Color.red.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMd, style: .continuous))
                }

                ForEach(0..<4) { i in
                    Button(action: { answerQuestion(i) }) {
                        Text(options[i])
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Theme.nearBlack)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Theme.offWhite)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMd, style: .continuous))
                    }
                }
            }
            .cardStyle()
            .padding(.horizontal, 16)
        }
    }

    private var resultView: some View {
        let score = answers.reduce(0, +)
        let result = AssessmentResult(type: activeTest!, score: score, answers: answers)

        return VStack(spacing: 20) {
            VStack(spacing: 12) {
                Text(result.type).font(.system(size: 14, weight: .semibold)).foregroundColor(Theme.blue)
                Text("\(score)").font(.system(size: 56, weight: .bold)).foregroundColor(Color(hex: result.severityColor))
                Text(result.severity)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: result.severityColor))
                Text("out of \(activeTest == "PHQ-9" ? 27 : 21)")
                    .font(.system(size: 13)).foregroundColor(Theme.midGrey)
            }
            .cardStyle()

            Button(action: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                store.assessments.append(result)
                store.saveAssessments()
                store.completeQuest(type: .assessment)
                store.addXP(30)
                activeTest = nil
                showResult = false
                dismiss()
            }) {
                Text("DONE")
                    .font(.system(size: 17, weight: .black))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 18)
                    .background(Theme.blue)
                    .clipShape(Capsule())
                    .shadow(color: Theme.blue.opacity(0.3), radius: 15, y: 8)
            }
            .padding(.horizontal, 16)
        }
        .padding(16)
    }

    private func startTest(_ type: String) {
        activeTest = type; currentQ = 0; answers = []; showResult = false
    }

    private func answerQuestion(_ value: Int) {
        answers.append(value)
        if currentQ + 1 < questions.count {
            withAnimation { currentQ += 1 }
        } else {
            withAnimation { showResult = true }
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
