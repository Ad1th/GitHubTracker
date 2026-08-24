import Foundation

#if canImport(WidgetKit)
import WidgetKit
#endif

public final class WidgetDataStore {
    public static let shared = WidgetDataStore()
    
    private var sharedDefaults: UserDefaults? {
        return UserDefaults(suiteName: AppGroupConstants.appGroupID) ?? UserDefaults.standard
    }
    
    private var fileLocations: [URL] {
        var urls: [URL] = []
        
        // 1. App Group Shared Container (WidgetKit <-> App)
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroupConstants.appGroupID) {
            urls.append(appGroupURL.appendingPathComponent("cached_contribution_data.json"))
        }
        
        // 2. Application Support Directory
        if let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let appDir = appSupport.appendingPathComponent("GitHubTracker")
            try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
            urls.append(appDir.appendingPathComponent("cached_contribution_data.json"))
        }
        
        // 3. User Config Directory (~/.config/github-tracker/)
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let configDir = homeDir.appendingPathComponent(".config/github-tracker")
        try? FileManager.default.createDirectory(at: configDir, withIntermediateDirectories: true)
        urls.append(configDir.appendingPathComponent("cached_contribution_data.json"))
        urls.append(configDir.appendingPathComponent("cached_data.json"))
        
        return urls
    }
    
    private init() {}
    
    // MARK: - Username Management
    public func saveUsername(_ username: String) {
        let cleaned = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }
        
        sharedDefaults?.set(cleaned, forKey: AppGroupConstants.usernameKey)
        UserDefaults.standard.set(cleaned, forKey: AppGroupConstants.usernameKey)
        
        // Also save to config file
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let configDir = homeDir.appendingPathComponent(".config/github-tracker")
        try? FileManager.default.createDirectory(at: configDir, withIntermediateDirectories: true)
        let configFileURL = configDir.appendingPathComponent("config.json")
        if let data = try? JSONEncoder().encode(["username": cleaned]) {
            try? data.write(to: configFileURL, options: .atomic)
        }
    }
    
    public func getUsername() -> String {
        // 1. Keychain
        if let kcUser = KeychainManager.shared.getUsername(), !kcUser.isEmpty {
            return kcUser
        }
        
        // 2. Shared App Group Defaults
        if let stored = sharedDefaults?.string(forKey: AppGroupConstants.usernameKey), !stored.isEmpty {
            return stored
        }
        
        // 3. Standard Defaults
        if let standard = UserDefaults.standard.string(forKey: AppGroupConstants.usernameKey), !standard.isEmpty {
            return standard
        }
        
        // 4. Config file (~/.config/github-tracker/config.json)
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let configFileURL = homeDir.appendingPathComponent(".config/github-tracker/config.json")
        if let data = try? Data(contentsOf: configFileURL),
           let dict = try? JSONDecoder().decode([String: String].self, from: data),
           let fileUser = dict["username"], !fileUser.isEmpty {
            return fileUser
        }
        
        return AppGroupConstants.defaultUsername
    }
    
    // MARK: - Contribution Data Storage
    public func saveContributionData(_ data: ContributionData) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        guard let encodedData = try? encoder.encode(data) else { return }
        
        // 1. Save in App Group / Standard UserDefaults
        sharedDefaults?.set(encodedData, forKey: AppGroupConstants.dataKey)
        sharedDefaults?.set(Date().timeIntervalSince1970, forKey: AppGroupConstants.lastRefreshKey)
        UserDefaults.standard.set(encodedData, forKey: AppGroupConstants.dataKey)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: AppGroupConstants.lastRefreshKey)
        
        // 2. Save across all shared file locations
        for url in fileLocations {
            try? encodedData.write(to: url, options: .atomic)
        }
    }
    
    public func loadContributionData() -> ContributionData? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // 1. Try reading from all shared file locations
        for url in fileLocations {
            if let fileData = try? Data(contentsOf: url),
               let decoded = try? decoder.decode(ContributionData.self, from: fileData) {
                return decoded
            }
        }
        
        // 2. Fall back to shared Defaults
        if let rawData = sharedDefaults?.data(forKey: AppGroupConstants.dataKey),
           let decoded = try? decoder.decode(ContributionData.self, from: rawData) {
            return decoded
        }
        
        // 3. Fall back to standard Defaults
        if let rawData = UserDefaults.standard.data(forKey: AppGroupConstants.dataKey),
           let decoded = try? decoder.decode(ContributionData.self, from: rawData) {
            return decoded
        }
        
        return nil
    }
    
    public func getLastRefreshDate() -> Date? {
        if let timestamp = sharedDefaults?.double(forKey: AppGroupConstants.lastRefreshKey), timestamp > 0 {
            return Date(timeIntervalSince1970: timestamp)
        }
        let stdTimestamp = UserDefaults.standard.double(forKey: AppGroupConstants.lastRefreshKey)
        if stdTimestamp > 0 {
            return Date(timeIntervalSince1970: stdTimestamp)
        }
        return nil
    }
    
    public func resetToSampleData(username: String? = nil) {
        let name = username ?? getUsername()
        saveContributionData(ContributionData.sample(username: name))
    }
}
