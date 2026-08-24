import SwiftUI
import WidgetKit
import AppIntents

public struct LargeWidgetView: View {
    public let entry: GitHubWidgetEntry
    
    public init(entry: GitHubWidgetEntry) {
        self.entry = entry
    }
    
    public var body: some View {
        let data = entry.contributionData
        
        VStack(alignment: .leading, spacing: 14) {
            // Header with Sync Button
            HStack(alignment: .center) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.green)
                    Text("GitHub")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Text("@\(data.userProfile.username)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    if #available(macOS 14.0, *) {
                        Button(intent: RefreshContributionsIntent()) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                                .padding(4)
                                .background(Circle().fill(Color.primary.opacity(0.08)))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            // Primary 4 Stats (Exact match to app preview)
            StatsHeaderView(data: data)
            
            // Contribution Heatmap Section (Large & Prominent)
            VStack(alignment: .leading, spacing: 6) {
                HeatmapView(
                    days: data.heatmapDays,
                    weeksToShow: 21,
                    squareSize: 12.5,
                    spacing: 4.0,
                    showWeekdayLabels: true
                )
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 4)
            }
            
            // Language Distribution Bar
            if !data.languageStats.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("TOP LANGUAGES")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                    
                    LanguageDistributionBar(languages: data.languageStats)
                }
            }
            
            Spacer(minLength: 0)
            
            // Footer
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.orange)
                    Text("\(data.currentStreak) day streak")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.primary)
                    Text("(Best: \(data.longestStreak) days)")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(timeAgoString(from: data.lastUpdated))
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.secondary.opacity(0.8))
            }
        }
        .padding(16)
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

public struct LanguageDistributionBar: View {
    public let languages: [LanguageStat]
    
    public init(languages: [LanguageStat]) {
        self.languages = languages
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            GeometryReader { geometry in
                HStack(spacing: 2) {
                    ForEach(languages) { lang in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(lang.color)
                            .frame(width: max(0, geometry.size.width * CGFloat(lang.percentage / 100.0)))
                    }
                }
            }
            .frame(height: 8)
            .cornerRadius(4)
            
            HStack(spacing: 12) {
                ForEach(languages.prefix(4)) { lang in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(lang.color)
                            .frame(width: 6, height: 6)
                        Text(lang.name)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.primary)
                        Text("\(Int(lang.percentage))%")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}
