import Foundation

public struct ContributionData: Codable, Equatable {
    public let userProfile: UserProfile
    public let totalContributions: Int
    public let currentStreak: Int
    public let longestStreak: Int
    public let contributionsToday: Int
    public let contributionsThisWeek: Int
    public let contributionsThisMonth: Int
    public let contributionsThisYear: Int
    public let mostActiveDay: String?
    public let mostActiveRepo: String?
    public let repoCount: Int
    public let heatmapDays: [ContributionDay]
    public let languageStats: [LanguageStat]
    public let recentActivities: [RecentActivity]
    public let lastUpdated: Date
    public let isAuthenticated: Bool
    
    public init(
        userProfile: UserProfile,
        totalContributions: Int,
        currentStreak: Int,
        longestStreak: Int,
        contributionsToday: Int,
        contributionsThisWeek: Int,
        contributionsThisMonth: Int,
        contributionsThisYear: Int,
        mostActiveDay: String? = nil,
        mostActiveRepo: String? = nil,
        repoCount: Int = 0,
        heatmapDays: [ContributionDay],
        languageStats: [LanguageStat] = [],
        recentActivities: [RecentActivity] = [],
        lastUpdated: Date = Date(),
        isAuthenticated: Bool = false
    ) {
        self.userProfile = userProfile
        self.totalContributions = totalContributions
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.contributionsToday = contributionsToday
        self.contributionsThisWeek = contributionsThisWeek
        self.contributionsThisMonth = contributionsThisMonth
        self.contributionsThisYear = contributionsThisYear
        self.mostActiveDay = mostActiveDay
        self.mostActiveRepo = mostActiveRepo
        self.repoCount = repoCount
        self.heatmapDays = heatmapDays
        self.languageStats = languageStats
        self.recentActivities = recentActivities
        self.lastUpdated = lastUpdated
        self.isAuthenticated = isAuthenticated
    }
    
    public static func sample(username: String = "adith") -> ContributionData {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var days: [ContributionDay] = []
        var total = 0
        var currentStreak = 0
        var longestStreak = 0
        var tempStreak = 0
        var todayCount = 0
        
        let totalDays = 364
        guard let startDate = calendar.date(byAdding: .day, value: -(totalDays - 1), to: today) else {
            return ContributionData(
                userProfile: UserProfile(username: username),
                totalContributions: 0, currentStreak: 0, longestStreak: 0,
                contributionsToday: 0, contributionsThisWeek: 0,
                contributionsThisMonth: 0, contributionsThisYear: 0,
                heatmapDays: []
            )
        }
        
        for i in 0..<totalDays {
            guard let date = calendar.date(byAdding: .day, value: i, to: startDate) else { continue }
            let isToday = calendar.isDateInToday(date)
            let weekday = calendar.component(.weekday, from: date)
            let weekIndex = i / 7
            
            let isWeekend = weekday == 1 || weekday == 7
            let baseChance = isWeekend ? 0.4 : 0.85
            let seed = (i * 37 + username.hashValue) % 100
            let hasContribution = (Double(abs(seed)) / 100.0) < baseChance
            
            let count: Int
            if hasContribution {
                count = (abs(seed) % 12) + 1
            } else {
                count = 0
            }
            
            if isToday {
                todayCount = max(count, 5)
            }
            
            let dayCount = isToday ? todayCount : count
            total += dayCount
            
            if dayCount > 0 {
                tempStreak += 1
                longestStreak = max(longestStreak, tempStreak)
            } else {
                tempStreak = 0
            }
            
            let day = ContributionDay(
                date: date,
                count: dayCount,
                weekday: weekday,
                weekIndex: weekIndex,
                isToday: isToday
            )
            days.append(day)
        }
        
        var streak = 0
        for day in days.reversed() {
            if day.count > 0 {
                streak += 1
            } else if day.isToday {
                continue
            } else {
                break
            }
        }
        currentStreak = max(streak, 8)
        longestStreak = max(longestStreak, 20)
        
        let sampleLanguages = [
            LanguageStat(name: "Swift", count: 142, percentage: 42.0, colorHex: "#F05138"),
            LanguageStat(name: "TypeScript", count: 95, percentage: 28.0, colorHex: "#3178C6"),
            LanguageStat(name: "Python", count: 61, percentage: 18.0, colorHex: "#3572A5"),
            LanguageStat(name: "Rust", count: 40, percentage: 12.0, colorHex: "#DEA584")
        ]
        
        let sampleActivities = [
            RecentActivity(type: .push, repositoryName: "\(username)/GitHubTracker", details: "Pushed 4 commits to main", date: Date().addingTimeInterval(-3600 * 2)),
            RecentActivity(type: .pullRequest, repositoryName: "\(username)/GitHubTracker", details: "Opened PR #3 WidgetKit setup", date: Date().addingTimeInterval(-3600 * 18)),
            RecentActivity(type: .issue, repositoryName: "apple/swift-package-manager", details: "Opened issue #1402", date: Date().addingTimeInterval(-3600 * 48)),
            RecentActivity(type: .create, repositoryName: "\(username)/macos-utils", details: "Created repository", date: Date().addingTimeInterval(-3600 * 96))
        ]
        
        return ContributionData(
            userProfile: UserProfile(username: username, name: username.capitalized, avatarUrl: "https://github.com/\(username).png", publicRepos: 24),
            totalContributions: max(total, 2839),
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            contributionsToday: todayCount > 0 ? todayCount : 5,
            contributionsThisWeek: 48,
            contributionsThisMonth: 192,
            contributionsThisYear: max(total, 2839),
            mostActiveDay: "Tuesday",
            mostActiveRepo: "\(username)/GitHubTracker",
            repoCount: 18,
            heatmapDays: days,
            languageStats: sampleLanguages,
            recentActivities: sampleActivities,
            lastUpdated: Date(),
            isAuthenticated: true
        )
    }
}
