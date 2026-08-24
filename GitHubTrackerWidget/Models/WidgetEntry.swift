import Foundation
import WidgetKit

public struct GitHubWidgetEntry: TimelineEntry {
    public let date: Date
    public let contributionData: ContributionData
    public let isPlaceholder: Bool
    public let errorMessage: String?
    
    public init(
        date: Date = Date(),
        contributionData: ContributionData,
        isPlaceholder: Bool = false,
        errorMessage: String? = nil
    ) {
        self.date = date
        self.contributionData = contributionData
        self.isPlaceholder = isPlaceholder
        self.errorMessage = errorMessage
    }
}
