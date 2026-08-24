import XCTest
@testable import GitHubTrackerCore

final class ContributionDataTests: XCTestCase {
    func testSampleDataGeneration() {
        let sample = ContributionData.sample(username: "adith")
        
        XCTAssertEqual(sample.userProfile.username, "adith")
        XCTAssertGreaterThan(sample.totalContributions, 0)
        XCTAssertGreaterThan(sample.currentStreak, 0)
        XCTAssertGreaterThan(sample.longestStreak, 0)
        XCTAssertEqual(sample.heatmapDays.count, 364)
        XCTAssertFalse(sample.languageStats.isEmpty)
        XCTAssertFalse(sample.recentActivities.isEmpty)
    }
    
    func testContributionDataCodable() throws {
        let original = ContributionData.sample(username: "testuser")
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(ContributionData.self, from: data)
        
        XCTAssertEqual(decoded.userProfile.username, "testuser")
        XCTAssertEqual(decoded.totalContributions, original.totalContributions)
        XCTAssertEqual(decoded.currentStreak, original.currentStreak)
    }
}
