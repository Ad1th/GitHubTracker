import SwiftUI
import WidgetKit

@main
public struct GitHubTrackerWidgetBundle: WidgetBundle {
    public init() {}
    
    public var body: some Widget {
        GitHubTrackerWidget()
    }
}

public struct GitHubTrackerWidget: Widget {
    public let kind: String = "GitHubTrackerWidget"
    
    public init() {}
    
    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GitHubTimelineProvider()) { entry in
            GitHubTrackerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("GitHub Contributions")
        .description("Track your GitHub contribution calendar, streaks, and activity at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

public struct GitHubTrackerWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    public let entry: GitHubWidgetEntry
    
    public init(entry: GitHubWidgetEntry) {
        self.entry = entry
    }
    
    public var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge, .systemExtraLarge:
            LargeWidgetView(entry: entry)
        @unknown default:
            MediumWidgetView(entry: entry)
        }
    }
}
