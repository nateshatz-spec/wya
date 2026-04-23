import SwiftUI

struct ClarityLevelView: View {
    @EnvironmentObject var store: DataStore
    
    var body: some View {
        let rank = store.currentClarityRank
        let nextRank = DataStore.clarityRanks.first { $0.minLogs > store.totalLogs }
        let progress = store.clarityProgress
        
        VStack(spacing: 24) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: rank.symbol)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: rank.colorHex))
                            .frame(width: 32, height: 32)
                            .background(Color(hex: rank.colorHex).opacity(0.12))
                            .clipShape(Circle())
                        
                        Text("LEVEL \(store.level)")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(Theme.midGrey)
                    }
                    
                    Text(rank.name.uppercased())
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(Theme.nearBlack)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(store.totalLogs)")
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(Theme.blue)
                    Text("TOTAL LOGS")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(Theme.midGrey)
                }
            }
            
            // Progress Bar
            VStack(spacing: 12) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Theme.inputBg)
                            .frame(height: 12)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Theme.blue, Theme.blueLight],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .frame(width: max(12, geo.size.width * CGFloat(progress)), height: 12)
                            .shadow(color: Theme.blue.opacity(0.3), radius: 6, y: 3)
                    }
                }
                .frame(height: 12)
                
                HStack {
                    Text(rank.name)
                    Spacer()
                    if let next = nextRank {
                        Text("\(next.minLogs - store.totalLogs) MORE TO \(next.name)")
                    } else {
                        Text("PEAK CLARITY ACHIEVED")
                    }
                }
                .font(.system(size: 10, weight: .black))
                .foregroundColor(Theme.midGrey)
            }
        }
        .padding(24)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusXl, style: .continuous))
        .auraStroke(color: AuraPalette.fromID(store.selectedAuraID).outline)
        .shadow(color: .black.opacity(0.04), radius: 12, y: 6)
    }
}
