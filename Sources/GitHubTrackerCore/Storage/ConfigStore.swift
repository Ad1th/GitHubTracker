import Foundation

#if canImport(WidgetKit)
import WidgetKit
#endif

public final class ConfigStore {
    public static let shared = ConfigStore()
    
    private var configDirURL: URL {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let dir = home.appendingPathComponent(".config/github-tracker")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
    
    private var dataFileURL: URL {
        configDirURL.appendingPathComponent("cached_contribution_data.json")
    }
    
    private var legacyDataFileURL: URL {
        configDirURL.appendingPathComponent("cached_data.json")
    }
    
    private var configFileURL: URL {
        configDirURL.appendingPathComponent("config.json")
    }
    
    private var appSupportDataFileURL: URL? {
        if let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let appDir = appSupport.appendingPathComponent("GitHubTracker")
            try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
            return appDir.appendingPathComponent("cached_contribution_data.json")
        }
        return nil
    }
    
    private init() {}
    
    public func saveUsername(_ username: String) {
        let cleaned = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }
        
        let dict = ["username": cleaned]
        if let data = try? JSONEncoder().encode(dict) {
            try? data.write(to: configFileURL, options: .atomic)
        }
        
        // Save to Keychain if available
        TokenStorage.shared.saveUsername(cleaned)
    }
    
    public func getUsername() -> String {
        // 1. Keychain
        if let kcUser = TokenStorage.shared.getUsername(), !kcUser.isEmpty {
            return kcUser
        }
        
        // 2. Config file
        if let data = try? Data(contentsOf: configFileURL),
           let dict = try? JSONDecoder().decode([String: String].self, from: data),
           let username = dict["username"], !username.isEmpty {
            return username
        }
        
        return "Ad1th"
    }
    
    public func saveContributionData(_ data: ContributionData) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        if let encoded = try? encoder.encode(data) {
            try? encoded.write(to: dataFileURL, options: .atomic)
            try? encoded.write(to: legacyDataFileURL, options: .atomic)
            if let appSupportURL = appSupportDataFileURL {
                try? encoded.write(to: appSupportURL, options: .atomic)
            }
        }
    }
    
    public func loadContributionData() -> ContributionData? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let urlsToTry: [URL?] = [dataFileURL, legacyDataFileURL, appSupportDataFileURL]
        
        for url in urlsToTry.compactMap({ $0 }) {
            if let fileData = try? Data(contentsOf: url),
               let decoded = try? decoder.decode(ContributionData.self, from: fileData) {
                return decoded
            }
        }
        
        return nil
    }
}
