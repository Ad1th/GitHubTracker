import SwiftUI
import WidgetKit
import AppIntents

public struct MediumWidgetView: View {
    public let entry: GitHubWidgetEntry
    
    public init(entry: GitHubWidgetEntry) {
        self.entry = entry
    }
    
    public var body: some View {
        let data = entry.contributionData
        
        VStack(alignment: .leading, spacing: 6) {
            // Header with Sync Button
            HStack(alignment: .center) {
                HStack(spacing: 5) {
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.green)
                    Text("GitHub")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                HStack(spacing: 5) {
                    Text("@\(data.userProfile.username)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    if #available(macOS 14.0, *) {
                        Button(intent: RefreshContributionsIntent()) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.secondary)
                                .padding(2.5)
                                .background(Circle().fill(Color.primary.opacity(0.08)))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            // Primary 4 Stats
            StatsHeaderView(data: data)
            
            // Heatmap Graph Grid (Scaled perfectly for 155pt widget height)
            HeatmapView(
                days: data.heatmapDays,
                weeksToShow: 19,
                squareSize: 9.5,
                spacing: 3.0,
                showWeekdayLabels: false
            )
            .frame(maxWidth: .infinity, alignment: .center)
            
            // Footer
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.orange)
                    Text("\(data.currentStreak) day streak")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(timeAgoString(from: data.lastUpdated))
                    .font(.system(size: 8.5, weight: .regular))
                    .foregroundColor(.secondary.opacity(0.8))
            }
        }
        .padding(10)
        .containerBackground(for: .widget) {
            Color(nsColor: .windowBackgroundColor)
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
