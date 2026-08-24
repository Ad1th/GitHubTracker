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
        
        VStack(alignment: .leading, spacing: 12) {
            // Header with Sync Button
            HStack(alignment: .center) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.green)
                    Text("GitHub Activity")
                        .font(.system(size: 13, weight: .semibold))
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
            
            // Contribution Heatmap Grid
            VStack(alignment: .leading, spacing: 4) {
                Text("CONTRIBUTIONS")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.secondary)
                HeatmapView(days: data.heatmapDays, weeksToShow: 30)
            }
            
            // Language Distribution Bar
            if !data.languageStats.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TOP LANGUAGES")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)
                    
                    LanguageDistributionBar(languages: data.languageStats)
                }
            }
            
            // Recent Activity Section
            if !data.recentActivities.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("RECENT ACTIVITY")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(data.recentActivities.prefix(3)) { activity in
                            HStack(spacing: 6) {
                                Image(systemName: activity.type.iconName)
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundColor(.secondary)
                                
                                Text(activity.repositoryName)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                
                                Text("• \(activity.details)")
                                    .font(.system(size: 10, weight: .regular))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                
                                Spacer(minLength: 0)
                            }
                        }
                    }
                }
            }
            
            Spacer(minLength: 0)
            
            // Footer
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.orange)
                    Text("\(data.currentStreak) day streak (Best: \(data.longestStreak))")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(timeAgoString(from: data.lastUpdated))
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(.secondary.opacity(0.8))
            }
        }
        .padding(14)
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
        VStack(alignment: .leading, spacing: 4) {
            GeometryReader { geometry in
                HStack(spacing: 1.5) {
                    ForEach(languages) { lang in
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(lang.color)
                            .frame(width: max(0, geometry.size.width * CGFloat(lang.percentage / 100.0)))
                    }
                }
            }
            .frame(height: 6)
            .cornerRadius(3)
            
            HStack(spacing: 8) {
                ForEach(languages.prefix(4)) { lang in
                    HStack(spacing: 3) {
                        Circle()
                            .fill(lang.color)
                            .frame(width: 5, height: 5)
                        Text(lang.name)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.primary)
                        Text("\(Int(lang.percentage))%")
                            .font(.system(size: 9, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}
