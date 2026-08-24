import Foundation
import AppIntents
import WidgetKit

@available(macOS 14.0, iOS 17.0, *)
public struct RefreshContributionsIntent: AppIntent {
    public static var title: LocalizedStringResource = "Refresh GitHub Contributions"
    public static var description = IntentDescription("Fetches fresh contribution data from GitHub and updates all widgets.")
    
    public init() {}
    
    public func perform() async throws -> some IntentResult {
        let username = WidgetDataStore.shared.getUsername()
        _ = try? await ContributionService.shared.fetchContributionData(username: username)
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
