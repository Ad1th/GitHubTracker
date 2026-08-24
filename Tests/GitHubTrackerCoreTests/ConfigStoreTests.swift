import XCTest
@testable import GitHubTrackerCore

final class ConfigStoreTests: XCTestCase {
    func testConfigStoreSaveAndLoad() {
        let sample = ContributionData.sample(username: "config_test_user")
        let saved = ConfigStore.shared.saveContributionData(sample)
        XCTAssertTrue(saved)
        
        let loaded = ConfigStore.shared.loadContributionData()
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.userProfile.username, "config_test_user")
    }
}
