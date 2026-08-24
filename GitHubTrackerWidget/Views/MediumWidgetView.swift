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
        
        VStack(alignment: .leading, spacing: 8) {
            // Header with Sync Button
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
                
                HStack(spacing: 6) {
                    Text("@\(data.userProfile.username)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    if #available(macOS 14.0, *) {
                        Button(intent: RefreshContributionsIntent()) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.secondary)
                                .padding(3)
                                .background(Circle().fill(Color.primary.opacity(0.08)))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            // Primary Stats
            StatsHeaderView(data: data)
            
            // Heatmap Graph Grid (Scaled up & Centered)
            HeatmapView(days: data.heatmapDays, weeksToShow: 21, squareSize: 10.5, spacing: 3.5)
                .frame(maxWidth: .infinity, alignment: .center)
            
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
