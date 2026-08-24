import SwiftUI
import WidgetKit

public struct MediumWidgetView: View {
    public let entry: GitHubWidgetEntry
    
    public init(entry: GitHubWidgetEntry) {
        self.entry = entry
    }
    
    public var body: some View {
        let data = entry.contributionData
        
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack(alignment: .center) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.green)
                    Text("GitHub")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("@\(data.userProfile.username)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            // Primary Stats
            StatsHeaderView(data: data)
            
            // Bigger Heatmap Graph Grid
            HeatmapView(days: data.heatmapDays, weeksToShow: 22)
            
            // Footer
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.orange)
                    Text("\(data.currentStreak) day streak")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(timeAgoString(from: data.lastUpdated))
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(.secondary.opacity(0.8))
            }
        }
        .padding(12)
        .containerBackground(for: .widget) {
            Color(nsColor: .init(name: nil, dynamicProvider: { appearance in
                appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                    ? NSColor(white: 0.11, alpha: 1.0)
                    : NSColor(white: 0.98, alpha: 1.0)
            }))
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 { return "Updated just now" }
        let minutes = seconds / 60
        if minutes < 60 { return "Updated \(minutes)m ago" }
        let hours = minutes / 60
        if hours < 24 { return "Updated \(hours)h ago" }
        return "Updated yesterday"
    }
}
