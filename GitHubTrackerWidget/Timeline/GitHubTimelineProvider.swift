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
        let cachedData = WidgetDataStore.shared.loadContributionData() ?? ContributionData.sample(username: username)
        
        let currentDate = Date()
        let entry = GitHubWidgetEntry(
            date: currentDate,
            contributionData: cachedData,
            isPlaceholder: false
        )
        
        // Schedule next update in 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate) ?? currentDate.addingTimeInterval(1800)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
}
