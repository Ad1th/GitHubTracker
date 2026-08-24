import Foundation

public enum GitHubAPIError: LocalizedError, Equatable {
    case invalidURL
    case unauthorized
    case rateLimited
    case userNotFound(String)
    case networkError(String)
    case serverError(Int)
    case decodingError(String)
    case noData
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid GitHub URL or request configuration."
        case .unauthorized:
            return "GitHub Personal Access Token is invalid or expired."
        case .rateLimited:
            return "GitHub API rate limit exceeded."
        case .userNotFound(let username):
            return "GitHub user '@\(username)' not found."
        case .networkError(let message):
            return "Network error: \(message)"
        case .serverError(let code):
            return "GitHub server error (HTTP status \(code))."
        case .decodingError(let details):
            return "Failed to parse GitHub response: \(details)"
        case .noData:
            return "No contribution data returned from GitHub."
        }
    }
}
