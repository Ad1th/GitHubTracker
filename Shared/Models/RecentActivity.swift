import Foundation

public struct RecentActivity: Codable, Identifiable, Equatable {
    public var id: String
    public let type: ActivityType
    public let repositoryName: String
    public let details: String
    public let date: Date
    
    public enum ActivityType: String, Codable {
        case push = "Pushed to"
        case pullRequest = "Opened PR in"
        case issue = "Opened issue in"
        case create = "Created repository"
        case star = "Starred"
        case fork = "Forked"
        
        public var iconName: String {
            switch self {
            case .push: return "arrow.up.circle.fill"
            case .pullRequest: return "arrow.triangle.pull"
            case .issue: return "exclamationmark.circle.fill"
            case .create: return "folder.fill.badge.plus"
            case .star: return "star.fill"
            case .fork: return "tuningfork"
            }
        }
    }
    
    public init(id: String = UUID().uuidString, type: ActivityType, repositoryName: String, details: String, date: Date) {
        self.id = id
        self.type = type
        self.repositoryName = repositoryName
        self.details = details
        self.date = date
    }
}

public struct UserProfile: Codable, Equatable {
    public let username: String
    public let name: String?
    public let avatarUrl: String?
    public let publicRepos: Int
    
    public init(username: String, name: String? = nil, avatarUrl: String? = nil, publicRepos: Int = 0) {
        self.username = username
        self.name = name
        self.avatarUrl = avatarUrl
        self.publicRepos = publicRepos
    }
}
