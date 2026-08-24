import Foundation

public final class ContributionService {
    public static let shared = ContributionService()
    
    private let graphQLClient: GitHubGraphQLClient
    private let restClient: GitHubRESTClient
    
    public init(
        graphQLClient: GitHubGraphQLClient = GitHubGraphQLClient(),
        restClient: GitHubRESTClient = GitHubRESTClient()
    ) {
        self.graphQLClient = graphQLClient
        self.restClient = restClient
    }
    
    public func fetchContributionData(username: String? = nil) async throws -> ContributionData {
        let targetUsername = username ?? ConfigStore.shared.getUsername()
        let token = TokenStorage.shared.getToken()
        
        let data: ContributionData
        
        if let token = token, !token.isEmpty {
            do {
                data = try await graphQLClient.fetchContributionData(username: targetUsername, token: token)
            } catch {
                data = try await restClient.fetchPublicContributionData(username: targetUsername)
            }
        } else {
            data = try await restClient.fetchPublicContributionData(username: targetUsername)
        }
        
        ConfigStore.shared.saveContributionData(data)
        ConfigStore.shared.saveUsername(targetUsername)
        
        return data
    }
}
