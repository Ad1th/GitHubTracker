import XCTest
@testable import GitHubTrackerCore

final class LanguageStatTests: XCTestCase {
    func testLanguageStatInitialization() {
        let stat = LanguageStat(name: "Swift", percentage: 75.5, colorHex: "#F05138")
        
        XCTAssertEqual(stat.name, "Swift")
        XCTAssertEqual(stat.percentage, 75.5)
        XCTAssertEqual(stat.colorHex, "#F05138")
    }
}
