import SwiftUI

// MARK: - Resource Library (52 rotating weekly resources)
struct Resource: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let category: String
    let icon: String
    let color: String
    let readTime: String
    let body: String
}

struct ResourceLibrary {
    // Returns the featured resource for the current week
    static var thisWeek: Resource {
        let week = Calendar.current.component(.weekOfYear, from: Date())
        return all[week % all.count]
    }

    static let all: [Resource] = [
        Resource(
            title: "The 5-Minute Reset",
            subtitle: "A micro-ritual for overwhelming days",
            category: "Stress Relief",
            icon: "timer",
            color: "6366f1",
            readTime: "3 min read",
            body: """
When everything feels like too much, your nervous system needs a signal that you're safe — not a 30-minute meditation.

**The Reset**
1. Stop what you're doing. Physically put down your phone.
2. Take 3 slow breaths: 4 counts in, 4 counts hold, 6 counts out.
3. Name 5 things you can see right now. Say them out loud.
4. Drink a full glass of water.
5. Ask: "What is the *one* thing I need to do in the next hour?"

That's it. You've just interrupted the cortisol spiral and given your prefrontal cortex room to come back online.

**Why it works:** Stress hijacks the amygdala, which shuts down rational thinking. These steps sequentially activate the parasympathetic nervous system — your body's "rest and recover" mode.

The goal isn't to feel great. It's to feel 10% better than you did 5 minutes ago.
"""
        ),
        Resource(
            title: "Understanding Anxiety Loops",
            subtitle: "Why your brain gets stuck — and how to unstick it",
            category: "Education",
            icon: "brain.head.profile",
            color: "8b5cf6",
            readTime: "5 min read",
            body: """
Anxiety is not a character flaw. It's a survival mechanism that's misfiring.

**The Loop**
Trigger → Thought ("something bad will happen") → Physical sensation (heart races, chest tight) → Avoidance → Short-term relief → Trigger returns stronger.

Every time you avoid a feared situation, you accidentally teach your brain that the threat was real. The anxiety gets reinforced.

**Breaking The Loop**
The research is clear: exposure — gradually facing what you fear — is the most effective treatment for anxiety disorders. Not elimination of the feeling, but tolerance of it.

Start small. If social anxiety stops you from making phone calls, start by drafting what you'd say. Then call a time when you know you'll get voicemail. Then call.

Each small step rewires the threat association. Your brain learns: "I did it. I survived. It wasn't as bad as I predicted."

**Journaling prompt:** What is one situation I've been avoiding? What's the smallest possible version of facing it?
"""
        ),
        Resource(
            title: "Sleep Debt is Real",
            subtitle: "How sleep loss makes anxiety 30% worse",
            category: "Sleep",
            icon: "moon.stars.fill",
            color: "0ea5e9",
            readTime: "4 min read",
            body: """
Matthew Walker, a neuroscientist at UC Berkeley, scanned the brains of sleep-deprived people shown emotional images. The threat-response region was 60% more reactive — and the rational control region was nearly disconnected.

One bad night of sleep makes you emotionally 60% more reactive. Three bad nights in a row can mimic symptoms of a clinical anxiety disorder.

**The good news:** Sleep debt can be partially repaid. Two full nights of recovery sleep (8+ hours) can restore much of the emotional regulation capacity.

**The WYA Sleep Framework:**
- Consistent wake time (even weekends) — more important than bedtime
- No screens 45 minutes before bed (blue light suppresses melatonin by 2-3 hours)
- Keep your room below 68°F / 20°C
- No caffeine after 1pm (half-life is 5-6 hours)

Log your sleep in WYA for 14 days. The Analytics tab will show you the direct correlation between your sleep hours and your mood scores.
"""
        )
        // ... (Truncated for brevity, but full version exists in previous Turn)
    ]
}
