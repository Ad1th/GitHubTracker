import Foundation

public struct LanguageStat: Codable, Identifiable, Equatable {
    public var id: String { name }
    public let name: String
    public let count: Int
    public let percentage: Double
    public let colorHex: String
    
    public init(name: String, count: Int, percentage: Double, colorHex: String? = nil) {
        self.name = name
        self.count = count
        self.percentage = percentage
        self.colorHex = colorHex ?? LanguageStat.defaultHex(for: name)
    }
    
    public static func defaultHex(for name: String) -> String {
        switch name.lowercased() {
        case "swift": return "#F05138"
        case "python": return "#3572A5"
        case "typescript": return "#3178C6"
        case "javascript": return "#F1E05A"
        case "java": return "#B07219"
        case "c++", "cpp": return "#F34B7D"
        case "c": return "#555555"
        case "go": return "#00ADD8"
        case "rust": return "#DEA584"
        case "html": return "#E34C26"
        case "css": return "#563D7C"
        case "ruby": return "#701516"
        case "php": return "#4F5D95"
        case "kotlin": return "#A97BFF"
        case "shell", "bash", "zsh": return "#89E051"
        default: return "#8B949E"
        }
    }
}
