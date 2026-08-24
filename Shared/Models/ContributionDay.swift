import Foundation
import SwiftUI

/// Represents a single day in the contribution graph.
public struct ContributionDay: Codable, Identifiable, Equatable {
    public var id: String { dateString }
    
    public let date: Date
    public let dateString: String
    public let count: Int
    public let level: IntensityLevel
    public let weekday: Int
    public let weekIndex: Int
    public let isToday: Bool
    
    public enum IntensityLevel: Int, Codable, Comparable {
        case zero = 0
        case low = 1
        case medium = 2
        case high = 3
        case max = 4
        
        public static func < (lhs: IntensityLevel, rhs: IntensityLevel) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
        
        public static func from(count: Int) -> IntensityLevel {
            switch count {
            case 0: return .zero
            case 1...3: return .low
            case 4...7: return .medium
            case 8...12: return .high
            default: return .max
            }
        }
        
        /// Fast static color representations to prevent dynamic NSColor allocation memory leaks during grid rendering.
        public var color: Color {
            switch self {
            case .zero:
                return Color(white: 0.18)
            case .low:
                return Color(red: 14/255.0, green: 68/255.0, blue: 41/255.0)
            case .medium:
                return Color(red: 0/255.0, green: 109/255.0, blue: 50/255.0)
            case .high:
                return Color(red: 38/255.0, green: 166/255.0, blue: 65/255.0)
            case .max:
                return Color(red: 57/255.0, green: 211/255.0, blue: 83/255.0)
            }
        }
    }
    
    public init(date: Date, count: Int, level: IntensityLevel? = nil, weekday: Int, weekIndex: Int, isToday: Bool = false) {
        self.date = date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.dateString = formatter.string(from: date)
        self.count = count
        self.level = level ?? IntensityLevel.from(count: count)
        self.weekday = weekday
        self.weekIndex = weekIndex
        self.isToday = isToday
    }
}
