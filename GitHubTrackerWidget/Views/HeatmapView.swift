import SwiftUI

public struct HeatmapView: View {
    public let days: [ContributionDay]
    public let weeksToShow: Int
    public let squareSize: CGFloat?
    public let spacing: CGFloat
    public let showWeekdayLabels: Bool
    
    private let structuredWeeks: [[ContributionDay?]]
    
    public init(
        days: [ContributionDay],
        weeksToShow: Int = 20,
        squareSize: CGFloat? = nil,
        spacing: CGFloat = 3.5,
        showWeekdayLabels: Bool = false
    ) {
        self.days = days
        self.weeksToShow = weeksToShow
        self.squareSize = squareSize
        self.spacing = spacing
        self.showWeekdayLabels = showWeekdayLabels
        
        guard !days.isEmpty else {
            self.structuredWeeks = []
            return
        }
        
        let maxWeekIndex = days.map { $0.weekIndex }.max() ?? 0
        let minWeekIndex = max(0, maxWeekIndex - weeksToShow + 1)
        
        var result: [[ContributionDay?]] = []
        
        for w in minWeekIndex...maxWeekIndex {
            var weekDays: [ContributionDay?] = Array(repeating: nil, count: 7)
            let weekItems = days.filter { $0.weekIndex == w }
            for item in weekItems {
                let dayIdx = (item.weekday - 1) % 7
                if dayIdx >= 0 && dayIdx < 7 {
                    weekDays[dayIdx] = item
                }
            }
            result.append(weekDays)
        }
        self.structuredWeeks = result
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: spacing + 2) {
            // Optional Weekday Labels (Mon, Wed, Fri)
            if showWeekdayLabels {
                VStack(spacing: spacing) {
                    Text("")
                        .font(.system(size: 8, weight: .medium))
                        .frame(height: squareSize ?? 10)
                    Text("M")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(height: squareSize ?? 10)
                    Text("")
                        .font(.system(size: 8, weight: .medium))
                        .frame(height: squareSize ?? 10)
                    Text("W")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(height: squareSize ?? 10)
                    Text("")
                        .font(.system(size: 8, weight: .medium))
                        .frame(height: squareSize ?? 10)
                    Text("F")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(height: squareSize ?? 10)
                    Text("")
                        .font(.system(size: 8, weight: .medium))
                        .frame(height: squareSize ?? 10)
                }
            }
            
            // Heatmap Grid
            HStack(spacing: spacing) {
                ForEach(0..<structuredWeeks.count, id: \.self) { weekIdx in
                    VStack(spacing: spacing) {
                        ForEach(0..<7, id: \.self) { dayIdx in
                            if let day = structuredWeeks[weekIdx][dayIdx] {
                                HeatmapSquare(day: day, size: squareSize)
                            } else {
                                RoundedRectangle(cornerRadius: (squareSize ?? 10) * 0.25)
                                    .fill(Color.primary.opacity(0.04))
                                    .frame(width: squareSize, height: squareSize)
                                    .aspectRatio(squareSize == nil ? 1.0 : nil, contentMode: .fit)
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct HeatmapSquare: View {
    let day: ContributionDay
    let size: CGFloat?
    
    var body: some View {
        let cornerRadius: CGFloat = (size ?? 10) * 0.25
        
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(day.level.color)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(day.isToday ? Color.accentColor : Color.clear, lineWidth: 1.5)
            )
            .frame(width: size, height: size)
            .aspectRatio(size == nil ? 1.0 : nil, contentMode: .fit)
            .accessibilityLabel("\(day.count) contributions on \(day.dateString)")
    }
}
