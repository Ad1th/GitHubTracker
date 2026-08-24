import Foundation

#if canImport(WidgetKit)
import WidgetKit
#endif

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
    
    /// Fetches fresh contribution data for the specified username, automatically choosing GraphQL (authenticated) or REST (public fallback).
    public func fetchContributionData(username: String? = nil) async throws -> ContributionData {
        let targetUsername = username ?? WidgetDataStore.shared.getUsername()
        let token = KeychainManager.shared.getToken()
        
        let data: ContributionData
        
        if let token = token, !token.isEmpty {
            do {
                data = try await graphQLClient.fetchContributionData(username: targetUsername, token: token)
            } catch {
                print("ContributionService: GraphQL failed (\(error.localizedDescription)). Falling back to public REST API.")
                data = try await restClient.fetchPublicContributionData(username: targetUsername)
            }
        } else {
            data = try await restClient.fetchPublicContributionData(username: targetUsername)
        }
        
        // Save fresh data to shared App Group container & local store
        WidgetDataStore.shared.saveContributionData(data)
        WidgetDataStore.shared.saveUsername(targetUsername)
        
        // Notify WidgetKit to refresh widgets
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
        
        return data
    }
}
