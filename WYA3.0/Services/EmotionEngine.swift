import Foundation

// MARK: - Emotion Engine
struct EmotionEngine {
    struct EmotionMatch {
        let key: String
        let weight: Int
    }

    static let emotions: [(key: String, words: [String], weight: Int)] = [
        ("crisis", ["suicide","kill myself","hurt myself","self harm","want to die","end my life","don't want to live"], 10),
        ("very_sad", ["hopeless","devastated","broken","can't go on","worthless","hate myself","empty inside","miserable","shattered"], 8),
        ("sad", ["sad","unhappy","down","crying","upset","disappointed","hurt","lonely","alone","depressed","low","blue","heartbroken"], 5),
        ("anxious", ["anxious","nervous","worried","panic","scared","afraid","overwhelmed","stressed","on edge","freaking out","tense","dread"], 5),
        ("angry", ["angry","furious","pissed","frustrated","annoyed","irritated","mad","rage","hate","fed up"], 5),
        ("tired", ["tired","exhausted","drained","burned out","no energy","worn out","fatigue","sleepy","can't sleep"], 4),
        ("confused", ["confused","lost","don't know what to do","uncertain","stuck","torn","conflicted"], 3),
        ("okay", ["okay","alright","fine","not bad","decent","meh","so-so"], 2),
        ("good", ["good","happy","great","wonderful","excited","grateful","thankful","proud","accomplished","joyful","content"], 1),
        ("amazing", ["amazing","incredible","fantastic","awesome","best day","thrilled","ecstatic","blessed","elated"], 0)
    ]

    static let topics: [(key: String, words: [String])] = [
        ("work", ["work","job","boss","coworker","meeting","deadline","project","office","career"]),
        ("relationship", ["partner","boyfriend","girlfriend","husband","wife","relationship","dating","breakup","divorce"]),
        ("family", ["family","mom","dad","parent","mother","father","sibling","brother","sister","kids","children"]),
        ("school", ["school","college","university","class","professor","exam","homework","study","student"]),
        ("health", ["health","sick","doctor","hospital","pain","medication","therapy","therapist"]),
        ("friends", ["friend","friendship","social","hangout","excluded","ghosted"]),
        ("money", ["money","bills","debt","rent","salary","budget","broke","financial"]),
        ("sleep", ["sleep","insomnia","nightmare","dream","nap","tired","rest"]),
        ("exercise", ["exercise","gym","workout","run","walk","yoga"]),
        ("hobby", ["hobby","reading","music","art","cooking","gaming","movie","book"])
    ]

    static let topicLabels: [String: String] = [
        "work":"work","relationship":"your relationship","family":"your family",
        "school":"school","health":"your health","friends":"your friends",
        "money":"finances","sleep":"sleep","exercise":"exercise","hobby":"your hobbies"
    ]

    static func detectEmotion(_ text: String) -> String? {
        let lower = text.lowercased()
        var best: String? = nil
        var bestWeight = -1
        for emotion in emotions {
            for word in emotion.words {
                if lower.contains(word) && emotion.weight > bestWeight {
                    best = emotion.key
                    bestWeight = emotion.weight
                }
            }
        }
        return best
    }

    static func detectTopics(_ text: String) -> [String] {
        let lower = text.lowercased()
        var found: [String] = []
        for topic in topics {
            for word in topic.words {
                if lower.contains(word) {
                    found.append(topic.key)
                    break
                }
            }
        }
        return found
    }

    static func getResponse(for emotion: String?) -> String {
        let key = emotion ?? "neutral"
        let pool = responses[key] ?? responses["neutral"]!
        return pool.randomElement()!
    }

    static let responses: [String: [String]] = [
        "crisis": ["I'm really glad you told me that. You're not alone, and help is available right now. Please reach out to the 988 Suicide & Crisis Lifeline (call or text 988) or text HOME to 741741. Your life matters. 💛"],
        "very_sad": ["I hear you, and I'm sorry you're carrying so much. It's okay to feel this way. Would you like to tell me more?","That sounds really heavy. What you're feeling is valid. What's weighing on you the most?"],
        "sad": ["I'm sorry you're feeling that way. Want to talk about what's making you feel down?","That must be tough. I'm here to listen — what's been going on?","It's okay to have days like this. What do you think is contributing?"],
        "anxious": ["Anxiety can feel so overwhelming. Want to talk about what's causing it?","Let's break it down — what's the main thing on your mind right now?","That sounds stressful. Take a breath. What's worrying you the most?"],
        "angry": ["It sounds like you're really frustrated. That's valid. What happened?","I can tell this is bothering you. Want to vent? I'm here to listen."],
        "tired": ["Feeling drained is tough. Is it physical or emotional exhaustion?","Sometimes we need permission to slow down. What's been draining you?"],
        "confused": ["It's okay to feel uncertainty. Talking it through can bring clarity. What's on your mind?","Feeling stuck is common. What are you wrestling with?"],
        "okay": ["Just okay? I'd love to hear more. What's been the highlight of your day?","Okay is fine! Was there anything that stood out today?"],
        "good": ["That makes me happy to hear! 😊 What's been going well?","I love that! Tell me about the good stuff.","That's wonderful! What contributed to your good mood?"],
        "amazing": ["That's incredible! 🎉 Tell me everything!","YES! That energy is contagious! What happened?"],
        "neutral": ["Thanks for sharing. How does that make you feel?","I appreciate you telling me. What are your thoughts on it?","Tell me more about that. How are you feeling about it?"]
    ]
}

// MARK: - Distortion Engine (CBT)
struct DistortionEngine {
    struct Distortion {
        let name: String
        let description: String
        let patterns: [String]
        let reframe: String
    }

    static let distortions: [Distortion] = [
        Distortion(name: "All-or-Nothing", description: "Seeing things in black & white", patterns: ["always","never","every time","nothing ever","completely","totally","impossible","ruined","perfect"], reframe: "Try replacing 'always/never' with 'sometimes' or 'often'. Reality is usually somewhere in between."),
        Distortion(name: "Catastrophizing", description: "Expecting the worst possible outcome", patterns: ["worst","disaster","terrible","horrible","awful","end of the world","can't handle","falling apart","everything is ruined"], reframe: "Ask yourself: What's more likely to happen? Often, the worst case is very unlikely."),
        Distortion(name: "Mind Reading", description: "Assuming you know what others think", patterns: ["they think","everyone thinks","they probably","they must think","they hate","no one likes","they're judging","people think"], reframe: "You can't read minds. Consider asking directly or considering alternative explanations."),
        Distortion(name: "Should Statements", description: "Using 'should' as a form of self-criticism", patterns: ["i should","i must","i have to","i need to be","i ought to","supposed to"], reframe: "Replace 'should' with 'I would like to' or 'It would be nice if'. Be gentle with yourself."),
        Distortion(name: "Emotional Reasoning", description: "Believing feelings equal facts", patterns: ["i feel like a failure","i feel stupid","i feel worthless","i feel ugly","i feel like nobody","i feel useless"], reframe: "Feelings are valid but not facts. Just because you feel it doesn't make it true."),
        Distortion(name: "Personalization", description: "Blaming yourself for things outside your control", patterns: ["my fault","i caused","because of me","i'm to blame","if only i","i made them"], reframe: "Consider other factors at play. You're not responsible for everything."),
        Distortion(name: "Overgeneralization", description: "Drawing broad conclusions from single events", patterns: ["this always happens","nothing works","everyone leaves","i can never","no one ever","it's always"], reframe: "One event doesn't define a pattern. Look for counter-examples."),
        Distortion(name: "Mental Filtering", description: "Focusing only on negatives", patterns: ["only bad","nothing good","can't see any","only negative","everything went wrong"], reframe: "Try to identify one positive thing, even small. The full picture includes both."),
        Distortion(name: "Labeling", description: "Assigning fixed labels to yourself", patterns: ["i'm a loser","i'm stupid","i'm worthless","i'm a failure","i'm pathetic","i'm weak","i'm broken"], reframe: "You are not a label. One behavior or event doesn't define who you are."),
        Distortion(name: "Fortune Telling", description: "Predicting negative outcomes", patterns: ["it won't work","it'll fail","they'll reject","i'll never","going to go wrong","it's going to be bad","won't ever get better"], reframe: "The future isn't written yet. What evidence supports a different outcome?")
    ]

    static func detect(in text: String) -> [Distortion] {
        let lower = text.lowercased()
        var found: [Distortion] = []
        for distortion in distortions {
            for pattern in distortion.patterns {
                if lower.contains(pattern) {
                    found.append(distortion)
                    break
                }
            }
        }
        return found
    }
}
