import SwiftUI

struct ResourceDetailView: View {
    let resource: Resource
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header Image/Icon
                ZStack {
                    LinearGradient(
                        colors: [Color(hex: resource.color).opacity(0.8), Color(hex: resource.color)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    
                    Image(systemName: resource.icon)
                        .font(.system(size: 80))
                        .foregroundColor(.white.opacity(0.3))
                        .offset(x: 80, y: 40)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(resource.category.uppercased())
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(.white.opacity(0.8))
                            .kerning(1)
                        
                        Text(resource.title)
                            .font(.system(size: 32, weight: .black))
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        HStack {
                            Label(resource.readTime, systemImage: "clock.fill")
                            Spacer()
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(32)
                }
                .padding(.horizontal, 16)
                
                // Body Content
                VStack(alignment: .leading, spacing: 20) {
                    Text(resource.body)
                        .font(.system(size: 17))
                        .lineSpacing(8)
                        .foregroundColor(Theme.nearBlack)
                        .multilineTextAlignment(.leading)
                    
                    Divider()
                        .padding(.vertical, 10)
                    
                    // Action Footer
                    VStack(alignment: .leading, spacing: 16) {
                        Text("TRY THIS NEXT")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(Theme.midGrey)
                        
                        HStack(spacing: 12) {
                            actionButton(title: "Share", icon: "square.and.arrow.up")
                            actionButton(title: "Favorite", icon: "heart")
                            actionButton(title: "Mark Read", icon: "checkmark.circle.fill")
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .background(Theme.offWhite)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func actionButton(title: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Theme.blue)
                .frame(width: 50, height: 50)
                .background(Theme.blue.opacity(0.1))
                .clipShape(Circle())
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Theme.midGrey)
        }
        .frame(maxWidth: .infinity)
    }
}
