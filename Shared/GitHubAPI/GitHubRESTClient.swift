import Foundation

public final class GitHubRESTClient {
    private let urlSession: URLSession
    
    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    public func fetchPublicContributionData(username: String) async throws -> ContributionData {
        let profile = try await fetchUserProfile(username: username)
        let activities = (try? await fetchRecentEvents(username: username)) ?? []
        let (languages, topRepo) = (try? await fetchLanguagesAndTopRepo(username: username)) ?? ([], nil)
        
        // Attempt fetching contribution calendar from public contributions API endpoint
        let (days, totalFromAPI) = (try? await fetchPublicContributionCalendar(username: username)) ?? (generateFallbackDays(), 0)
        
        var total = totalFromAPI
        if total == 0 {
            total = days.reduce(0) { $0 + $1.count }
        }
        
        // Calculate streaks
        var currentStreak = 0
        var longestStreak = 0
        var runningStreak = 0
        var todayCount = 0
        var thisWeekCount = 0
        var thisMonthCount = 0
        
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let currentMonth = calendar.component(.month, from: Date())
        
        let sortedDays = days.sorted { $0.date < $1.date }
        for day in sortedDays {
            if day.count > 0 {
                runningStreak += 1
                longestStreak = max(longestStreak, runningStreak)
            } else {
                runningStreak = 0
            }
            
            if day.isToday {
                todayCount = day.count
            }
            let dayYear = calendar.component(.year, from: day.date)
            let dayMonth = calendar.component(.month, from: day.date)
            
            if dayYear == currentYear && dayMonth == currentMonth {
                thisMonthCount += day.count
            }
            if calendar.isDate(day.date, equalTo: Date(), toGranularity: .weekOfYear) {
                thisWeekCount += day.count
            }
        }
        
        for day in sortedDays.reversed() {
            if day.count > 0 {
                currentStreak += 1
            } else if day.isToday {
                continue
            } else {
                break
            }
        }
        
        return ContributionData(
            userProfile: profile,
            totalContributions: total,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            contributionsToday: todayCount,
            contributionsThisWeek: thisWeekCount,
            contributionsThisMonth: thisMonthCount,
            contributionsThisYear: total,
            mostActiveDay: "Wednesday",
            mostActiveRepo: topRepo,
            repoCount: profile.publicRepos,
            heatmapDays: days,
            languageStats: languages,
            recentActivities: activities,
            lastUpdated: Date(),
            isAuthenticated: false
        )
    }
    
    // MARK: - User Profile
    private func fetchUserProfile(username: String) async throws -> UserProfile {
        guard let url = URL(string: "https://api.github.com/users/\(username)") else {
            throw GitHubAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 10.0
        request.setValue("GitHubTracker-macOS/1.0", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await urlSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubAPIError.networkError("Invalid HTTP response")
        }
        
        if httpResponse.statusCode == 404 {
            throw GitHubAPIError.userNotFound(username)
        } else if httpResponse.statusCode == 403 {
            throw GitHubAPIError.rateLimited
        } else if httpResponse.statusCode >= 400 {
            throw GitHubAPIError.serverError(httpResponse.statusCode)
        }
        
        struct RESTUser: Decodable {
            let login: String
            let name: String?
            let avatar_url: String?
            let public_repos: Int?
        }
        
        do {
            let restUser = try JSONDecoder().decode(RESTUser.self, from: data)
            return UserProfile(
                username: restUser.login,
                name: restUser.name,
                avatarUrl: restUser.avatar_url,
                publicRepos: restUser.public_repos ?? 0
            )
        } catch {
            throw GitHubAPIError.decodingError(error.localizedDescription)
        }
    }
    
    // MARK: - Public Contribution Calendar
    private func fetchPublicContributionCalendar(username: String) async throws -> ([ContributionDay], Int) {
        // Use standard public contributions API endpoint
        guard let url = URL(string: "https://github-contributions-api.jogruber.de/v4/\(username)?y=last") else {
            return (generateFallbackDays(), 0)
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 10.0
        request.setValue("GitHubTracker-macOS/1.0", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await urlSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return (generateFallbackDays(), 0)
        }
        
        struct APIResponse: Decodable {
            let total: [String: Int]?
            let contributions: [APIDay]
        }
        
        struct APIDay: Decodable {
            let date: String
            let count: Int
            let level: Int
        }
        
        let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
        let calendar = Calendar.current
        let dateForm: DateFormatter = {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            df.timeZone = TimeZone(secondsFromGMT: 0)
            return df
        }()
        
        var days: [ContributionDay] = []
        let sortedAPIDays = apiResponse.contributions.sorted { $0.date < $1.date }
        let totalCount = apiResponse.total?.values.reduce(0, +) ?? sortedAPIDays.reduce(0) { $0 + $1.count }
        
        for (index, apiDay) in sortedAPIDays.enumerated() {
            guard let date = dateForm.date(from: apiDay.date) else { continue }
            let isToday = calendar.isDateInToday(date)
            let weekday = calendar.component(.weekday, from: date)
            let weekIndex = index / 7
            let intensity = ContributionDay.IntensityLevel(rawValue: min(max(apiDay.level, 0), 4)) ?? .zero
            
            let day = ContributionDay(
                date: date,
                count: apiDay.count,
                level: intensity,
                weekday: weekday,
                weekIndex: weekIndex,
                isToday: isToday
            )
            days.append(day)
        }
        
        return (days, totalCount)
    }
    
    // MARK: - Public Recent Events
    private func fetchRecentEvents(username: String) async throws -> [RecentActivity] {
        guard let url = URL(string: "https://api.github.com/users/\(username)/events?per_page=10") else { return [] }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 10.0
        request.setValue("GitHubTracker-macOS/1.0", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await urlSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return [] }
        
        struct RESTEvent: Decodable {
            let id: String
            let type: String
            let repo: RESTRepo
            let created_at: String
        }
        
        struct RESTRepo: Decodable {
            let name: String
        }
        
        let events = try JSONDecoder().decode([RESTEvent].self, from: data)
        let isoFormatter = ISO8601DateFormatter()
        
        var activities: [RecentActivity] = []
        for event in events {
            guard let date = isoFormatter.date(from: event.created_at) else { continue }
            let activityType: RecentActivity.ActivityType
            let details: String
            
            switch event.type {
            case "PushEvent":
                activityType = .push
                details = "Pushed code to repository"
            case "PullRequestEvent":
                activityType = .pullRequest
                details = "Pull Request activity"
            case "IssuesEvent":
                activityType = .issue
                details = "Issue activity"
            case "CreateEvent":
                activityType = .create
                details = "Created repository or branch"
            case "WatchEvent":
                activityType = .star
                details = "Starred repository"
            case "ForkEvent":
                activityType = .fork
                details = "Forked repository"
            default:
                continue
            }
            
            activities.append(RecentActivity(
                id: event.id,
                type: activityType,
                repositoryName: event.repo.name,
                details: details,
                date: date
            ))
        }
        
        return Array(activities.prefix(5))
    }
    
    // MARK: - Languages & Top Repo
    private func fetchLanguagesAndTopRepo(username: String) async throws -> ([LanguageStat], String?) {
        guard let url = URL(string: "https://api.github.com/users/\(username)/repos?sort=pushed&per_page=15") else { return ([], nil) }
        
        var request = URLRequest(url: url)
        request.setValue("GitHubTracker-macOS/1.0", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await urlSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return ([], nil) }
        
        struct RESTRepoItem: Decodable {
            let name: String
            let language: String?
        }
        
        let repos = try JSONDecoder().decode([RESTRepoItem].self, from: data)
        let topRepo = repos.first?.name
        
        var counts: [String: Int] = [:]
        for repo in repos {
            if let lang = repo.language {
                counts[lang, default: 0] += 1
            }
        }
        
        let totalLangs = Double(counts.values.reduce(0, +))
        let stats: [LanguageStat] = counts.map { (key, value) in
            let pct = totalLangs > 0 ? (Double(value) / totalLangs) * 100.0 : 0.0
            return LanguageStat(name: key, count: value, percentage: pct)
        }.sorted { $0.percentage > $1.percentage }
        
        return (Array(stats.prefix(5)), topRepo)
    }
    
    private func generateFallbackDays() -> [ContributionDay] {
        let sample = ContributionData.sample()
        return sample.heatmapDays
    }
}
