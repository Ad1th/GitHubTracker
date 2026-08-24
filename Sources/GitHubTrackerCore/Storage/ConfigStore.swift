import Foundation

public final class ConfigStore {
    public static let shared = ConfigStore()
    
    private var configDirURL: URL {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let dir = home.appendingPathComponent(".config/github-tracker")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
    
    private var dataFileURL: URL {
        configDirURL.appendingPathComponent("cached_data.json")
    }
    
    private var configFileURL: URL {
        configDirURL.appendingPathComponent("config.json")
    }
    
    private init() {}
    
    public func saveUsername(_ username: String) {
        let cleaned = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let dict = ["username": cleaned]
        if let data = try? JSONEncoder().encode(dict) {
            try? data.write(to: configFileURL, options: .atomic)
        }
    }
    
    public func getUsername() -> String {
        if let data = try? Data(contentsOf: configFileURL),
           let dict = try? JSONDecoder().decode([String: String].self, from: data),
           let username = dict["username"], !username.isEmpty {
            return username
        }
        return "adith"
    }
    
    public func saveContributionData(_ data: ContributionData) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let encoded = try? encoder.encode(data) {
            try? encoded.write(to: dataFileURL, options: .atomic)
        }
    }
    
    public func loadContributionData() -> ContributionData? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let fileData = try? Data(contentsOf: dataFileURL),
           let decoded = try? decoder.decode(ContributionData.self, from: fileData) {
            return decoded
        }
        return nil
    }
}
