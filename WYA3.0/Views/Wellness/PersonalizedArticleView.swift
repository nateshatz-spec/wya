import SwiftUI

struct PersonalizedArticleView: View {
    @EnvironmentObject var store: DataStore
    
    var body: some View {
        let article = AIManager.shared.generatePersonalizedArticle(store: store)
        
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: article.icon)
                            .font(.system(size: 24))
                            .foregroundColor(Theme.blue)
                        Text("PERSONALIZED CLARITY")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(Theme.blue)
                    }
                    
                    Text(article.title)
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(Theme.nearBlack)
                }
                
                // Hero Image (Placeholder or abstract shape)
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(
                        LinearGradient(colors: [Theme.blue.opacity(0.1), Theme.blue.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: article.icon)
                            .font(.system(size: 80))
                            .foregroundColor(Theme.blue.opacity(0.2))
                    )
                
                // Content
                Text(article.content)
                    .font(.system(size: 18))
                    .foregroundColor(Theme.darkGrey)
                    .lineSpacing(10)
                
                Divider()
                
                // Action/Reflection
                VStack(alignment: .leading, spacing: 20) {
                    Text("REFLECT ON THIS")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(Theme.midGrey)
                    
                    Text("How does this pattern manifest in your daily life? Try logging a journal entry about a time you noticed this today.")
                        .font(.system(size: 15))
                        .foregroundColor(Theme.midGrey)
                        .italic()
                }
                .padding(24)
                .background(Theme.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .auraStroke(color: Theme.blue.opacity(0.1))
                
                Spacer()
            }
            .padding(30)
        }
        .background(Theme.offWhite)
        .navigationBarTitleDisplayMode(.inline)
    }
}
