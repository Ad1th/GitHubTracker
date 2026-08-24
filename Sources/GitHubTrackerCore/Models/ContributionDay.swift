import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

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
        
        public var ansiColor: String {
            switch self {
            case .zero: return "\u{001B}[38;5;238m"
            case .low: return "\u{001B}[38;5;28m"
            case .medium: return "\u{001B}[38;5;34m"
            case .high: return "\u{001B}[38;5;40m"
            case .max: return "\u{001B}[38;5;46m"
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
