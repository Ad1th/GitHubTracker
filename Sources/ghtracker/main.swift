import Foundation
#if canImport(GitHubTrackerCore)
import GitHubTrackerCore
#endif

enum ANSI {
    static let reset = "\u{001B}[0m"
    static let bold = "\u{001B}[1m"
    static let dim = "\u{001B}[2m"
    
    static let green = "\u{001B}[38;5;46m"
    static let orange = "\u{001B}[38;5;208m"
    static let yellow = "\u{001B}[38;5;220m"
    static let cyan = "\u{001B}[38;5;51m"
    static let gray = "\u{001B}[38;5;242m"
    static let white = "\u{001B}[38;5;255m"
}

extension Int {
    var formattedWithCommas: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

@main
struct GHTrackerCLI {
    static func main() async {
        let store = ConfigStore.shared
        let username = store.getUsername()
        
        var data: ContributionData? = store.loadContributionData()
        
        let args = CommandLine.arguments
        let forceRefresh = args.contains("--refresh") || args.contains("-r")
        
        if data == nil || forceRefresh {
            print("\(ANSI.dim)Fetching live GitHub data for @\(username)...\(ANSI.reset)")
            do {
                data = try await ContributionService.shared.fetchContributionData(username: username)
            } catch {
                print("\(ANSI.orange)Warning: Live fetch failed (\(error.localizedDescription)). Showing cached data.\(ANSI.reset)")
                data = store.loadContributionData() ?? ContributionData.sample(username: username)
            }
        }
        
        guard let data = data else {
            print("No GitHub contribution data available.")
            return
        }
        
        renderTerminalDashboard(data: data)
    }
    
    static func renderTerminalDashboard(data: ContributionData) {
        let u = data.userProfile.username
        let authLabel = data.isAuthenticated ? "\(ANSI.green)Authenticated (GraphQL)\(ANSI.reset)" : "\(ANSI.cyan)Public (REST)\(ANSI.reset)"
        
        print("\n\(ANSI.bold)========================================================================\(ANSI.reset)")
        print("\(ANSI.bold)  GITHUB CONTRIBUTION TRACKER (Pure Swift SDK)\(ANSI.reset)           \(ANSI.cyan)@\(u)\(ANSI.reset)")
        print("\(ANSI.dim)  Status: \(authLabel)\(ANSI.dim)  |  Last updated: \(timeAgo(from: data.lastUpdated))\(ANSI.reset)")
        print("\(ANSI.bold)========================================================================\(ANSI.reset)\n")
        
        let totalStr = data.totalContributions.formattedWithCommas
        print("  \(ANSI.bold)Total:\(ANSI.reset) \(ANSI.white)\(totalStr)\(ANSI.reset)     \(ANSI.bold)Streak:\(ANSI.reset) \(ANSI.orange)🔥 \(data.currentStreak) days\(ANSI.reset) (Best: \(data.longestStreak))     \(ANSI.bold)Today:\(ANSI.reset) \(ANSI.green)☀️ \(data.contributionsToday)\(ANSI.reset)")
        print("  \(ANSI.dim)Week: \(data.contributionsThisWeek)  |  Month: \(data.contributionsThisMonth)  |  Repos: \(data.repoCount)\(ANSI.reset)\n")
        
        print("  \(ANSI.bold)CONTRIBUTION HEATMAP (Last 26 Weeks)\(ANSI.reset)\n")
        renderHeatmapGrid(days: data.heatmapDays, weeksToShow: 26)
        
        print("\n  \(ANSI.dim)Legend: \(ContributionDay.IntensityLevel.zero.ansiColor)■\(ANSI.reset) 0  \(ContributionDay.IntensityLevel.low.ansiColor)■\(ANSI.reset) 1-3  \(ContributionDay.IntensityLevel.medium.ansiColor)■\(ANSI.reset) 4-7  \(ContributionDay.IntensityLevel.high.ansiColor)■\(ANSI.reset) 8-11  \(ContributionDay.IntensityLevel.max.ansiColor)■\(ANSI.reset) 12+\(ANSI.reset)")
        
        if !data.languageStats.isEmpty {
            print("\n  \(ANSI.bold)TOP LANGUAGES\(ANSI.reset)")
            for lang in data.languageStats.prefix(5) {
                let barLength = Int(lang.percentage / 4.0)
                let bar = String(repeating: "█", count: max(1, barLength))
                let paddedName = lang.name.padding(toLength: 12, withPad: " ", startingAt: 0)
                let pctStr = String(format: "%4.1f%%", lang.percentage)
                print("  \(ANSI.gray)\(paddedName)\(ANSI.reset) \(ANSI.cyan)\(bar)\(ANSI.reset) \(ANSI.dim)\(pctStr)\(ANSI.reset)")
            }
        }
        
        if !data.recentActivities.isEmpty {
            print("\n  \(ANSI.bold)RECENT ACTIVITY\(ANSI.reset)")
            for act in data.recentActivities.prefix(4) {
                let timeStr = timeAgo(from: act.date)
                print("  \(ANSI.yellow)•\(ANSI.reset) \(ANSI.bold)\(act.repositoryName)\(ANSI.reset) - \(act.details) \(ANSI.dim)(\(timeStr))\(ANSI.reset)")
            }
        }
        
        print("\n\(ANSI.bold)========================================================================\(ANSI.reset)\n")
    }
    
    static func renderHeatmapGrid(days: [ContributionDay], weeksToShow: Int) {
        guard !days.isEmpty else { return }
        
        let maxWeekIndex = days.map { $0.weekIndex }.max() ?? 0
        let minWeekIndex = max(0, maxWeekIndex - weeksToShow + 1)
        
        var weeks: [[ContributionDay?]] = []
        for w in minWeekIndex...maxWeekIndex {
            var weekDays: [ContributionDay?] = Array(repeating: nil, count: 7)
            let weekItems = days.filter { $0.weekIndex == w }
            for item in weekItems {
                let dayIdx = (item.weekday - 1) % 7
                if dayIdx >= 0 && dayIdx < 7 {
                    weekDays[dayIdx] = item
                }
            }
            weeks.append(weekDays)
        }
        
        let dayLabels = ["Mon", "Wed", "Fri"]
        let rowIndices = [1, 3, 5]
        
        for row in 0..<7 {
            var line = "  "
            if rowIndices.contains(row) {
                let labelIdx = rowIndices.firstIndex(of: row)!
                line += "\(ANSI.dim)\(dayLabels[labelIdx]) \(ANSI.reset)"
            } else {
                line += "    "
            }
            
            for w in 0..<weeks.count {
                if let day = weeks[w][row] {
                    let color = day.level.ansiColor
                    if day.isToday {
                        line += "\(ANSI.bold)\(color)■\(ANSI.reset)"
                    } else {
                        line += "\(color)■\(ANSI.reset)"
                    }
                } else {
                    line += "\(ContributionDay.IntensityLevel.zero.ansiColor)·\(ANSI.reset)"
                }
                line += " "
            }
            print(line)
        }
    }
    
    static func timeAgo(from date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 { return "just now" }
        let minutes = seconds / 60
        if minutes < 60 { return "\(minutes)m ago" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours)h ago" }
        let days = hours / 24
        return "\(days)d ago"
    }
}
