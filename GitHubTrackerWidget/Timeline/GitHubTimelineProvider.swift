import Foundation
import WidgetKit

public struct GitHubTimelineProvider: TimelineProvider {
    public typealias Entry = GitHubWidgetEntry
    
    public init() {}
    
    public func placeholder(in context: Context) -> GitHubWidgetEntry {
        let username = WidgetDataStore.shared.getUsername()
        return GitHubWidgetEntry(
            date: Date(),
            contributionData: ContributionData.sample(username: username),
            isPlaceholder: true
        )
    }
    
    public func getSnapshot(in context: Context, completion: @escaping (GitHubWidgetEntry) -> Void) {
        let username = WidgetDataStore.shared.getUsername()
        let data = WidgetDataStore.shared.loadContributionData() ?? ContributionData.sample(username: username)
        let entry = GitHubWidgetEntry(
            date: Date(),
            contributionData: data,
            isPlaceholder: context.isPreview
        )
        completion(entry)
    }
    
    public func getTimeline(in context: Context, completion: @escaping (Timeline<GitHubWidgetEntry>) -> Void) {
        let username = WidgetDataStore.shared.getUsername()
        let cachedData = WidgetDataStore.shared.loadContributionData()
        
        let currentDate = Date()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate) ?? currentDate.addingTimeInterval(900)
        
        // If we have cached data, immediately deliver timeline then refresh in background
        if let data = cachedData {
            let entry = GitHubWidgetEntry(
                date: currentDate,
                contributionData: data,
                isPlaceholder: false
            )
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
            
            // Asynchronously refresh in background
            Task.detached(priority: .background) {
                _ = try? await ContributionService.shared.fetchContributionData(username: username)
            }
        } else {
            // No cache: Fetch fresh live data asynchronously
            Task.detached(priority: .userInitiated) {
                do {
                    let freshData = try await ContributionService.shared.fetchContributionData(username: username)
                    let entry = GitHubWidgetEntry(
                        date: currentDate,
                        contributionData: freshData,
                        isPlaceholder: false
                    )
                    let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                    completion(timeline)
                } catch {
                    let fallbackData = ContributionData.sample(username: username)
                    let entry = GitHubWidgetEntry(
                        date: currentDate,
                        contributionData: fallbackData,
                        isPlaceholder: false
                    )
                    let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                    completion(timeline)
                }
            }
        }
    }
}
