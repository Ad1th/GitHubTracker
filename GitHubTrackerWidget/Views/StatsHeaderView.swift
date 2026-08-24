import SwiftUI

public struct StatsHeaderView: View {
    public let data: ContributionData
    
    public init(data: ContributionData) {
        self.data = data
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            StatItem(
                value: "\(data.totalContributions.formattedWithCommas)",
                label: "Contributions",
                systemImage: nil
            )
            
            Spacer(minLength: 8)
            
            StatItem(
                value: "\(data.currentStreak)",
                label: "Current Streak",
                systemImage: "flame.fill",
                accentColor: .orange
            )
            
            Spacer(minLength: 8)
            
            StatItem(
                value: "\(data.longestStreak)",
                label: "Best Streak",
                systemImage: "trophy.fill",
                accentColor: .yellow
            )
            
            Spacer(minLength: 8)
            
            StatItem(
                value: "\(data.contributionsToday)",
                label: "Today",
                systemImage: "sun.max.fill",
                accentColor: .green
            )
        }
    }
}

public struct StatItem: View {
    let value: String
    let label: String
    let systemImage: String?
    var accentColor: Color? = nil
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                if let icon = systemImage {
                    Image(systemName: icon)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(accentColor ?? .primary)
                }
                Text(value)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            }
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }
}

extension Int {
    var formattedWithCommas: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
