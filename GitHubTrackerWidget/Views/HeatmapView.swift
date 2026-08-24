import SwiftUI

public struct HeatmapView: View {
    public let days: [ContributionDay]
    public let weeksToShow: Int
    
    public init(days: [ContributionDay], weeksToShow: Int = 24) {
        self.days = days
        self.weeksToShow = weeksToShow
    }
    
    private var structuredWeeks: [[ContributionDay?]] {
        guard !days.isEmpty else { return [] }
        
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
        
        return result
    }
    
    public var body: some View {
        HStack(spacing: 3.5) {
            ForEach(0..<structuredWeeks.count, id: \.self) { weekIdx in
                VStack(spacing: 3.5) {
                    ForEach(0..<7, id: \.self) { dayIdx in
                        if let day = structuredWeeks[weekIdx][dayIdx] {
                            HeatmapSquare(day: day)
                        } else {
                            RoundedRectangle(cornerRadius: 2.5)
                                .fill(Color.primary.opacity(0.04))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .aspectRatio(1.0, contentMode: .fit)
                        }
                    }
                }
            }
        }
    }
}

private struct HeatmapSquare: View {
    let day: ContributionDay
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .fill(day.level.color)
            .overlay(
                RoundedRectangle(cornerRadius: 2.5)
                    .stroke(day.isToday ? Color.accentColor : Color.clear, lineWidth: 1.2)
            )
            .aspectRatio(1.0, contentMode: .fit)
            .accessibilityLabel("\(day.count) contributions on \(day.dateString)")
    }
}
