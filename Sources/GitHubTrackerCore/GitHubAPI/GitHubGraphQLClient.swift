import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public final class GitHubGraphQLClient {
    private let urlSession: URLSession
    
    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    public func fetchContributionData(username: String, token: String) async throws -> ContributionData {
        guard let url = URL(string: "https://api.github.com/graphql") else {
            throw GitHubAPIError.invalidURL
        }
        
        let query = """
        query($username: String!) {
          user(login: $username) {
            name
            login
            avatarUrl
            repositories(first: 20, ownerAffiliations: OWNER, orderBy: {field: PUSHED_AT, direction: DESC}) {
              totalCount
              nodes {
                name
                primaryLanguage {
                  name
                  color
                }
                languages(first: 5, orderBy: {field: SIZE, direction: DESC}) {
                  edges {
                    size
                    node {
                      name
                      color
                    }
                  }
                }
              }
            }
            contributionsCollection {
              startedAt
              endedAt
              totalCommitContributions
              totalIssueContributions
              totalPullRequestContributions
              totalPullRequestReviewContributions
              contributionCalendar {
                totalContributions
                weeks {
                  contributionDays {
                    date
                    contributionCount
                    contributionLevel
                    weekday
                  }
                }
              }
            }
          }
        }
        """
        
        let payload: [String: Any] = [
            "query": query,
            "variables": ["username": username]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 10.0
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("GitHubTracker-CLI/1.0", forHTTPHeaderField: "User-Agent")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubAPIError.networkError("Invalid HTTP response")
        }
        
        if httpResponse.statusCode == 401 {
            throw GitHubAPIError.unauthorized
        } else if httpResponse.statusCode == 403 {
            throw GitHubAPIError.rateLimited
        } else if httpResponse.statusCode >= 500 {
            throw GitHubAPIError.serverError(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        let graphQLResponse: GraphQLResponse
        do {
            graphQLResponse = try decoder.decode(GraphQLResponse.self, from: data)
        } catch {
            throw GitHubAPIError.decodingError(error.localizedDescription)
        }
        
        guard let user = graphQLResponse.data?.user else {
            if let firstError = graphQLResponse.errors?.first?.message {
                if firstError.lowercased().contains("could not resolve to a user") {
                    throw GitHubAPIError.userNotFound(username)
                }
                throw GitHubAPIError.networkError(firstError)
            }
            throw GitHubAPIError.userNotFound(username)
        }
        
        return processGraphQLUser(user, username: username)
    }
    
    private func processGraphQLUser(_ user: GraphQLUser, username: String) -> ContributionData {
        let calendar = Calendar.current
        let dateForm: DateFormatter = {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            df.timeZone = TimeZone(secondsFromGMT: 0)
            return df
        }()
        
        var days: [ContributionDay] = []
        let total = user.contributionsCollection.contributionCalendar.totalContributions
        var todayCount = 0
        var thisWeekCount = 0
        var thisMonthCount = 0
        let thisYearCount = total
        
        let currentYear = calendar.component(.year, from: Date())
        let currentMonth = calendar.component(.month, from: Date())
        
        for (weekIdx, week) in user.contributionsCollection.contributionCalendar.weeks.enumerated() {
            for dayData in week.contributionDays {
                guard let date = dateForm.date(from: dayData.date) else { continue }
                let isToday = calendar.isDateInToday(date)
                
                let dayCount = dayData.contributionCount
                if isToday {
                    todayCount = dayCount
                }
                
                let dayYear = calendar.component(.year, from: date)
                let dayMonth = calendar.component(.month, from: date)
                
                if dayYear == currentYear && dayMonth == currentMonth {
                    thisMonthCount += dayCount
                }
                
                if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
                    thisWeekCount += dayCount
                }
                
                let level = ContributionDay.IntensityLevel.from(count: dayCount)
                let day = ContributionDay(
                    date: date,
                    count: dayCount,
                    level: level,
                    weekday: dayData.weekday,
                    weekIndex: weekIdx,
                    isToday: isToday
                )
                days.append(day)
            }
        }
        
        var currentStreak = 0
        var longestStreak = 0
        var runningStreak = 0
        
        let sortedDays = days.sorted { $0.date < $1.date }
        for day in sortedDays {
            if day.count > 0 {
                runningStreak += 1
                longestStreak = max(longestStreak, runningStreak)
            } else {
                runningStreak = 0
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
        
        var languageTotals: [String: (count: Int, color: String?)] = [:]
        for repo in user.repositories.nodes {
            for edge in repo.languages.edges {
                let name = edge.node.name
                let size = edge.size
                let color = edge.node.color
                let existing = languageTotals[name] ?? (0, color)
                languageTotals[name] = (existing.count + size, color ?? existing.color)
            }
        }
        
        let overallSize = Double(languageTotals.values.reduce(0) { $0 + $1.count })
        let languageStats: [LanguageStat] = languageTotals.map { (key, value) in
            let percentage = overallSize > 0 ? (Double(value.count) / overallSize) * 100.0 : 0.0
            return LanguageStat(name: key, count: value.count, percentage: percentage, colorHex: value.color)
        }.sorted { $0.percentage > $1.percentage }
        
        let mostActiveRepo = user.repositories.nodes.first?.name
        
        let profile = UserProfile(
            username: user.login,
            name: user.name,
            avatarUrl: user.avatarUrl,
            publicRepos: user.repositories.totalCount
        )
        
        return ContributionData(
            userProfile: profile,
            totalContributions: total,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            contributionsToday: todayCount,
            contributionsThisWeek: thisWeekCount,
            contributionsThisMonth: thisMonthCount,
            contributionsThisYear: thisYearCount,
            mostActiveDay: "Most Active",
            mostActiveRepo: mostActiveRepo,
            repoCount: user.repositories.totalCount,
            heatmapDays: days,
            languageStats: Array(languageStats.prefix(5)),
            recentActivities: [],
            lastUpdated: Date(),
            isAuthenticated: true
        )
    }
}

private struct GraphQLResponse: Decodable {
    let data: GraphQLData?
    let errors: [GraphQLErrorItem]?
}

private struct GraphQLErrorItem: Decodable {
    let message: String
}

private struct GraphQLData: Decodable {
    let user: GraphQLUser?
}

private struct GraphQLUser: Decodable {
    let name: String?
    let login: String
    let avatarUrl: String?
    let repositories: GraphQLRepoConnection
    let contributionsCollection: GraphQLContributionsCollection
}

private struct GraphQLRepoConnection: Decodable {
    let totalCount: Int
    let nodes: [GraphQLRepoNode]
}

private struct GraphQLRepoNode: Decodable {
    let name: String
    let primaryLanguage: GraphQLLanguageNode?
    let languages: GraphQLLanguageConnection
}

private struct GraphQLLanguageNode: Decodable {
    let name: String
    let color: String?
}

private struct GraphQLLanguageConnection: Decodable {
    let edges: [GraphQLLanguageEdge]
}

private struct GraphQLLanguageEdge: Decodable {
    let size: Int
    let node: GraphQLLanguageNode
}

private struct GraphQLContributionsCollection: Decodable {
    let totalCommitContributions: Int
    let totalIssueContributions: Int
    let totalPullRequestContributions: Int
    let totalPullRequestReviewContributions: Int
    let contributionCalendar: GraphQLContributionCalendar
}

private struct GraphQLContributionCalendar: Decodable {
    let totalContributions: Int
    let weeks: [GraphQLContributionWeek]
}

private struct GraphQLContributionWeek: Decodable {
    let contributionDays: [GraphQLContributionDay]
}

private struct GraphQLContributionDay: Decodable {
    let date: String
    let contributionCount: Int
    let contributionLevel: String
    let weekday: Int
}
