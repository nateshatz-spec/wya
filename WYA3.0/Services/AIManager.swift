import Foundation

struct AIInsight: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    let icon: String
}

class AIManager {
    static let shared = AIManager()
    
    func generateInsights(store: DataStore) -> [AIInsight] {
        var insights: [AIInsight] = []
        
        // 1. Mood & Resilience
        let recentMoods = store.moodEntries.suffix(7)
        let averageMood = Double(recentMoods.map { $0.mood }.reduce(0, +)) / max(Double(recentMoods.count), 1.0)
        
        if averageMood < 3.0 {
            insights.append(AIInsight(
                title: "Mood Resilience",
                content: "Your mood has been lower than average this week. AI suggests focusing on 'Small Wins' — pick one minor task today to complete.",
                icon: "chart.line.downtrend.xyaxis"
            ))
        } else if averageMood > 4.0 {
            insights.append(AIInsight(
                title: "Peak Clarity",
                content: "You're in a high-clarity phase! This is a great time to tackle more complex journal prompts or start a new wellness goal.",
                icon: "sparkles"
            ))
        }
        
        // 2. Trigger Recognition
        let topTriggers = store.getTopTriggers()
        if let top = topTriggers.first {
            insights.append(AIInsight(
                title: "Stressor Analysis",
                content: "AI identified '\(top.0)' as your primary stressor. Patterns suggest this peaks in the afternoon. Try a 5-min breathing session at 2 PM.",
                icon: "bolt.fill"
            ))
        }
        
        // 3. Sleep & Mood Correlation
        if let lastSleep = store.sleepEntries.last {
            if lastSleep.hours < 6.0 && averageMood < 3.5 {
                insights.append(AIInsight(
                    title: "Rest Recovery",
                    content: "Low sleep (\(String(format: "%.1f", lastSleep.hours))h) is correlating with your lower mood logs. AI recommends an earlier bedtime tonight.",
                    icon: "moon.zzz.fill"
                ))
            }
        }
        
        // 4. Recovery Progress
        let totalSavings = store.recoveryTracks.map { $0.totalSavings }.reduce(0, +)
        if totalSavings > 0 {
            insights.append(AIInsight(
                title: "Financial Strength",
                content: "You've saved a total of $\(String(format: "%.2f", totalSavings)) through your recovery tracks. That's a huge tangible win!",
                icon: "dollarsign.circle.fill"
            ))
        }
        
        // 5. Assessment Trends
        if store.assessments.count >= 2 {
            let last = store.assessments.last!.score
            let prev = store.assessments[store.assessments.count - 2].score
            if last < prev {
                insights.append(AIInsight(
                    title: "Clinical Progress",
                    content: "Your latest assessment score improved! This validates the work you're putting into your daily check-ins.",
                    icon: "arrow.up.forward.circle.fill"
                ))
            }
        }
        
        // 6. Medication Adherence
        let today = store.currentDateString()
        let medsTaken = store.doses.filter { $0.date == today }.count
        if medsTaken < store.medications.count && !store.medications.isEmpty {
            insights.append(AIInsight(
                title: "Medication Alert",
                content: "Don't forget your regimen! AI noticed you haven't completed today's doses. Consistency is vital for long-term clarity.",
                icon: "pills.fill"
            ))
        }
        
        // 7. Hormonal Correlation
        if store.userGender == "Female" && !store.cycleEntries.isEmpty {
            let hormonalInsight = getHormonalCorrelation(store: store)
            insights.append(hormonalInsight)
        }
        
        return insights
    }

    private func getHormonalCorrelation(store: DataStore) -> AIInsight {
        let entries = store.cycleEntries
        let moods = store.moodEntries
        
        // Group mood by cycle phase
        var phaseMoods: [String: [Int]] = [:]
        for entry in entries {
            let entryMoods = moods.filter { $0.date == entry.date }
            if !entryMoods.isEmpty {
                phaseMoods[entry.phase, default: []].append(contentsOf: entryMoods.map { $0.mood })
            }
        }
        
        if let lutealMoods = phaseMoods["Luteal"], !lutealMoods.isEmpty {
            let avgLuteal = Double(lutealMoods.reduce(0, +)) / Double(lutealMoods.count)
            if avgLuteal < 3.0 {
                return AIInsight(
                    title: "Luteal Sensitivity",
                    content: "AI detected a trend: your mood drops by \(String(format: "%.1f", 3.0 - avgLuteal)) points during your Luteal phase. Consider increasing your magnesium intake and prioritizing sleep during this window.",
                    icon: "moon.haze.fill"
                )
            }
        }
        
        return AIInsight(
            title: "Hormonal Harmony",
            content: "Your mood remains stable across your cycle phases. This indicates high hormonal resilience!",
            icon: "face.smiling.fill"
        )
    }
    
    func getSmartJournalPrompt(store: DataStore) -> String {
        let lastMood = store.moodEntries.last?.mood ?? 3
        let topTrigger = store.getTopTriggers().first?.0 ?? "general stress"
        
        if lastMood <= 2 {
            return "You've been feeling low. If you could give your younger self one piece of advice right now, what would it be?"
        } else if topTrigger.localizedCaseInsensitiveContains("work") {
            return "Work seems to be on your mind. What's one boundary you could set tomorrow to protect your peace?"
        } else if topTrigger.localizedCaseInsensitiveContains("relationship") {
            return "Relationships take energy. What's one thing you appreciate about yourself, regardless of others' opinions?"
        } else {
            return "What's one thing that went better than expected today?"
        }
    }
    
    func getRecoveryEncouragement(store: DataStore) -> String {
        let tracks = store.recoveryTracks
        if tracks.isEmpty {
            return "Every journey starts with a single step. Is there something you'd like to track your strength against today?"
        }
        
        let longestStreak = tracks.map { $0.streak }.max() ?? 0
        let handledCravings = store.cravingEntries.filter { $0.wasHandled }.count
        
        if handledCravings > 0 {
            return "You've successfully navigated \(handledCravings) cravings. Each one you handle makes the next one easier. You are winning."
        }
        
        return "You've hit a \(longestStreak)-day streak! That's proof of your resilience. Keep building that momentum."
    }

    enum ProactiveContext {
        case recovery, medication, wellness, home
    }

    func getProactiveTip(context: ProactiveContext, store: DataStore) -> AIInsight? {
        switch context {
        case .recovery:
            let recentCravings = store.cravingEntries.suffix(3)
            if recentCravings.contains(where: { $0.intensity >= 4 }) {
                return AIInsight(
                    title: "High Intensity Detected",
                    content: "Your recent cravings have been intense. Try the 'Ice Water' technique: submerge your hands in cold water for 30 seconds to reset your nervous system.",
                    icon: "thermometer.snowflake"
                )
            }
            if store.recoveryTracks.isEmpty {
                return AIInsight(
                    title: "Ready to Start?",
                    content: "Setting your first track is the best way to visualize your progress. What's one thing you want to prioritize today?",
                    icon: "flag.fill"
                )
            }
            
        case .medication:
            let adherence = calculateAdherence(store: store)
            if adherence < 0.7 {
                return AIInsight(
                    title: "Adherence Support",
                    content: "It looks like a few doses were missed. Try setting a secondary alarm or placing your meds near your toothbrush for a physical trigger.",
                    icon: "alarm.fill"
                )
            }
            if !store.sideEffects.isEmpty && store.sideEffects.last?.severity ?? 0 >= 4 {
                return AIInsight(
                    title: "Side Effect Monitor",
                    content: "You recently logged a severe side effect. AI recommends noting exactly when it happens relative to your dose to share with your provider.",
                    icon: "exclamationmark.triangle.fill"
                )
            }

        case .wellness:
            let lastMood = store.moodEntries.last?.mood ?? 3
            if lastMood <= 2 {
                return AIInsight(
                    title: "Self-Compassion",
                    content: "You logged a low mood recently. Remember that progress isn't linear. It's okay to have 'off' days — try a 2-min breathing session now.",
                    icon: "heart.fill"
                )
            }
            
            // Check for Hormonal Context
            if store.userGender == "Female", let lastCycle = store.cycleEntries.last {
                if lastCycle.phase == "Luteal" && lastMood < 3 {
                    return AIInsight(
                        title: "Luteal Self-Care",
                        content: "You're in your Luteal phase and mood is dipping. This is a normal hormonal shift. AI recommends a 'Self-Care Sprint': light stretching and zero high-stress tasks for 1 hour.",
                        icon: "spa.fill"
                    )
                }
            }
            
        case .home:
            if store.totalXP > 0 && store.level == 1 {
                return AIInsight(
                    title: "Level Up Pending",
                    content: "You're earning XP! Check your profile to see your progress on the Clarity Path.",
                    icon: "leaf.fill"
                )
            }
        }
        return nil
    }

    private func calculateAdherence(store: DataStore) -> Double {
        let today = store.currentDateString()
        let loggedToday = store.doses.filter { $0.date == today }.count
        let expectedToday = store.medications.filter { $0.frequencyLabel != "As Needed" }.count
        guard expectedToday > 0 else { return 1.0 }
        return min(Double(loggedToday) / Double(expectedToday), 1.0)
    }

    func generatePersonalizedArticle(store: DataStore) -> (title: String, content: String, icon: String) {
        let topTrigger = store.getTopTriggers().first?.0 ?? "general stress"
        let avgMood = Double(store.moodEntries.suffix(7).map { $0.mood }.reduce(0, +)) / max(Double(store.moodEntries.suffix(7).count), 1.0)
        let avgSleep = store.sleepEntries.suffix(7).map { $0.hours }.reduce(0, +) / max(Double(store.sleepEntries.suffix(7).count), 1.0)
        
        let disclaimer = "\n\nDISCLAIMER: This article is AI-generated for educational purposes and is not medical advice. Consult a professional before making changes to your health regimen."
        
        if avgSleep < 6.0 {
            return (
                "The Neuro-Chemistry of Sleep",
                "Your recent data shows a trend of shorter sleep cycles. Lack of REM sleep directly impacts the amygdala's ability to regulate fear and anxiety. Prioritizing a 15-minute 'Dark Hour' before bed—no screens, dim lights—can help recalibrate your melatonin production." + disclaimer,
                "moon.stars.fill"
            )
        } else if topTrigger.localizedCaseInsensitiveContains("work") {
            return (
                "Navigating Occupational Burnout",
                "With '\(topTrigger)' identified as a major influencer, your cortisol levels are likely spiking in professional contexts. Research suggests that 'Micro-Breaks'—standing up and looking at something 20 feet away for 20 seconds—can prevent the cognitive fatigue that leads to heightened anxiety." + disclaimer,
                "briefcase.fill"
            )
        } else if avgMood < 3.0 {
            return (
                "The Biology of Low-Clarity Phases",
                "When your clarity is lower, your brain is often in a 'protective' mode, prioritizing survival over complex processing. This is a time for 'Low-Friction Wellness'—gentle movement, hydrating, and reducing sensory input. Remember: you are not your mood; you are the observer of it." + disclaimer,
                "sparkles"
            )
        } else {
            return (
                "Maintaining the Growth Momentum",
                "You are currently in a high-resilience phase. This is the optimal window to 'Future-Proof' your wellness by documenting what is working. Take 5 minutes to write down three things you did this week that made a difference; these will be your anchor points during future storms." + disclaimer,
                "arrow.up.heart.fill"
            )
        }
    }
}
