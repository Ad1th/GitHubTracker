import XCTest
@testable import GitHubTrackerCore

final class ContributionDayTests: XCTestCase {
    func testContributionDayInitialization() {
        let date = Date()
        let day = ContributionDay(date: date, count: 5, weekday: 2, weekIndex: 10, isToday: true)
        
        XCTAssertEqual(day.count, 5)
        XCTAssertEqual(day.level, .medium)
        XCTAssertEqual(day.weekday, 2)
        XCTAssertEqual(day.weekIndex, 10)
        XCTAssertTrue(day.isToday)
    }
    
    func testContributionDayDateFormatting() {
        var components = DateComponents()
        components.year = 2026
        components.month = 8
        components.day = 25
        let calendar = Calendar.current
        let date = calendar.date(from: components)!
        
        let day = ContributionDay(date: date, count: 3, weekday: 3, weekIndex: 34)
        XCTAssertEqual(day.dateString, "2026-08-25")
    }
}
