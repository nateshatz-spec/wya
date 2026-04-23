import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        return CGSize(width: proposal.width ?? 0, height: rows.last.map { $0.maxY } ?? 0)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        for row in rows {
            for (view, frame) in row.items {
                view.place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: ProposedViewSize(frame.size))
            }
        }
    }
    
    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [RowData] {
        var rows: [RowData] = []
        var currentRow = RowData()
        var x: CGFloat = 0
        var y: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && !currentRow.items.isEmpty {
                currentRow.maxY = y + (currentRow.items.map { $0.1.height }.max() ?? 0)
                rows.append(currentRow)
                currentRow = RowData()
                x = 0
                y = currentRow.maxY + spacing
            }
            currentRow.items.append((view, CGRect(x: x, y: y, width: size.width, height: size.height)))
            x += size.width + spacing
        }
        
        if !currentRow.items.isEmpty {
            currentRow.maxY = y + (currentRow.items.map { $0.1.height }.max() ?? 0)
            rows.append(currentRow)
        }
        
        return rows
    }
    
    struct RowData {
        var items: [(LayoutSubview, CGRect)] = []
        var maxY: CGFloat = 0
    }
}
