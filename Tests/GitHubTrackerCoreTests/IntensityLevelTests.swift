import XCTest
@testable import GitHubTrackerCore

final class IntensityLevelTests: XCTestCase {
    func testIntensityLevelsFromCount() {
        XCTAssertEqual(ContributionDay.IntensityLevel.from(count: 0), .zero)
        XCTAssertEqual(ContributionDay.IntensityLevel.from(count: 1), .low)
        XCTAssertEqual(ContributionDay.IntensityLevel.from(count: 3), .low)
        XCTAssertEqual(ContributionDay.IntensityLevel.from(count: 4), .medium)
        XCTAssertEqual(ContributionDay.IntensityLevel.from(count: 7), .medium)
        XCTAssertEqual(ContributionDay.IntensityLevel.from(count: 8), .high)
        XCTAssertEqual(ContributionDay.IntensityLevel.from(count: 12), .high)
        XCTAssertEqual(ContributionDay.IntensityLevel.from(count: 13), .max)
        XCTAssertEqual(ContributionDay.IntensityLevel.from(count: 50), .max)
    }
    
    func testANSIColors() {
        XCTAssertFalse(ContributionDay.IntensityLevel.zero.ansiColor.isEmpty)
        XCTAssertFalse(ContributionDay.IntensityLevel.low.ansiColor.isEmpty)
        XCTAssertFalse(ContributionDay.IntensityLevel.medium.ansiColor.isEmpty)
        XCTAssertFalse(ContributionDay.IntensityLevel.high.ansiColor.isEmpty)
        XCTAssertFalse(ContributionDay.IntensityLevel.max.ansiColor.isEmpty)
    }
}
