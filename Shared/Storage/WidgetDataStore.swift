import Foundation

public final class WidgetDataStore {
    public static let shared = WidgetDataStore()
    
    private var sharedDefaults: UserDefaults? {
        return UserDefaults(suiteName: AppGroupConstants.appGroupID) ?? UserDefaults.standard
    }
    
    private var sharedContainerURL: URL? {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroupConstants.appGroupID)
            ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.appendingPathComponent("GitHubTracker")
    }
    
    private var fileURL: URL? {
        guard let container = sharedContainerURL else { return nil }
        try? FileManager.default.createDirectory(at: container, withIntermediateDirectories: true)
        return container.appendingPathComponent("cached_contribution_data.json")
    }
    
    private init() {}
    
    // MARK: - Username Management
    public func saveUsername(_ username: String) {
        let cleaned = username.trimmingCharacters(in: .whitespacesAndNewlines)
        sharedDefaults?.set(cleaned, forKey: AppGroupConstants.usernameKey)
        UserDefaults.standard.set(cleaned, forKey: AppGroupConstants.usernameKey)
    }
    
    public func getUsername() -> String {
        if let stored = sharedDefaults?.string(forKey: AppGroupConstants.usernameKey), !stored.isEmpty {
            return stored
        }
        if let standard = UserDefaults.standard.string(forKey: AppGroupConstants.usernameKey), !standard.isEmpty {
            return standard
        }
        return AppGroupConstants.defaultUsername
    }
    
    // MARK: - Contribution Data Storage
    public func saveContributionData(_ data: ContributionData) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let encodedData = try encoder.encode(data)
            
            // 1. Save in App Group / Standard UserDefaults
            sharedDefaults?.set(encodedData, forKey: AppGroupConstants.dataKey)
            sharedDefaults?.set(Date().timeIntervalSince1970, forKey: AppGroupConstants.lastRefreshKey)
            
            // 2. Save as JSON file in shared container for fast file reading
            if let fileURL = fileURL {
                try encodedData.write(to: fileURL, options: .atomic)
            }
        } catch {
            print("WidgetDataStore: Failed to encode contribution data: \(error)")
        }
    }
    
    public func loadContributionData() -> ContributionData? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // 1. Try reading from shared JSON file
        if let fileURL = fileURL, let fileData = try? Data(contentsOf: fileURL) {
            if let decoded = try? decoder.decode(ContributionData.self, from: fileData) {
                return decoded
            }
        }
        
        // 2. Fall back to UserDefaults
        if let rawData = sharedDefaults?.data(forKey: AppGroupConstants.dataKey) {
            if let decoded = try? decoder.decode(ContributionData.self, from: rawData) {
                return decoded
            }
        }
        
        return nil
    }
    
    public func getLastRefreshDate() -> Date? {
        if let timestamp = sharedDefaults?.double(forKey: AppGroupConstants.lastRefreshKey), timestamp > 0 {
            return Date(timeIntervalSince1970: timestamp)
        }
        return nil
    }
    
    /// Reset stored data to fresh sample data for previews and testing
    public func resetToSampleData(username: String? = nil) {
        let name = username ?? getUsername()
        saveContributionData(ContributionData.sample(username: name))
    }
}
