import SwiftUI
import WidgetKit

public struct SmallWidgetView: View {
    public let entry: GitHubWidgetEntry
    
    public init(entry: GitHubWidgetEntry) {
        self.entry = entry
    }
    
    public var body: some View {
        let data = entry.contributionData
        
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Image(systemName: "square.stack.3d.up.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                Text("@\(data.userProfile.username)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Spacer()
            }
            .padding(.bottom, 12)
            
            Spacer(minLength: 0)
            
            // Streak Stat
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.orange)
                    Text("\(data.currentStreak)")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
                Text("day streak")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer(minLength: 0)
            
            Divider()
                .opacity(0.4)
                .padding(.vertical, 8)
            
            // Today & Total Stats
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text("\(data.contributionsToday)")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("today")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 1) {
                    Text(data.totalContributions.formattedWithCommas)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("this year")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(14)
        .containerBackground(for: .widget) {
            Color(nsColor: .init(name: nil, dynamicProvider: { appearance in
                appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                    ? NSColor(white: 0.11, alpha: 1.0)
                    : NSColor(white: 0.98, alpha: 1.0)
            }))
        }
    }
}
