import Foundation

#if os(macOS)
import Security
#endif

public final class TokenStorage {
    public static let shared = TokenStorage()
    
    private init() {}
    
    // MARK: - Token Storage
    
    public func getToken() -> String? {
        // 1. Check environment variables (GITHUB_TOKEN or GH_TOKEN)
        if let envToken = ProcessInfo.processInfo.environment["GITHUB_TOKEN"] ?? ProcessInfo.processInfo.environment["GH_TOKEN"], !envToken.isEmpty {
            return envToken.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // 2. Check local config file (~/.config/github-tracker/token)
        let configPath = getConfigTokenURL()
        if let fileData = try? Data(contentsOf: configPath), let token = String(data: fileData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), !token.isEmpty {
            return token
        }
        
        // 3. Check macOS Keychain if running on macOS
        #if os(macOS)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.adith.GitHubTracker.credentials",
            kSecAttrAccount as String: "github_personal_access_token",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == errSecSuccess, let data = dataTypeRef as? Data, let token = String(data: data, encoding: .utf8) {
            return token.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        #endif
        
        return nil
    }
    
    @discardableResult
    public func saveToken(_ token: String) -> Bool {
        let cleaned = token.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Save to config file
        let configPath = getConfigTokenURL()
        let dir = configPath.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        
        if let data = cleaned.data(using: .utf8) {
            try? data.write(to: configPath, options: .atomic)
        }
        
        #if os(macOS)
        if let data = cleaned.data(using: .utf8) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: "com.adith.GitHubTracker.credentials",
                kSecAttrAccount as String: "github_personal_access_token"
            ]
            SecItemDelete(query as CFDictionary)
            var attributes = query
            attributes[kSecValueData as String] = data
            SecItemAdd(attributes as CFDictionary, nil)
        }
        #endif
        
        return true
    }
    
    // MARK: - Username Storage
    
    public func getUsername() -> String? {
        // 1. Check local config file (~/.config/github-tracker/username)
        let configPath = getConfigUsernameURL()
        if let fileData = try? Data(contentsOf: configPath), let user = String(data: fileData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), !user.isEmpty {
            return user
        }
        
        // 2. Check macOS Keychain
        #if os(macOS)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.adith.GitHubTracker.credentials",
            kSecAttrAccount as String: "github_username",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == errSecSuccess, let data = dataTypeRef as? Data, let user = String(data: data, encoding: .utf8) {
            let cleaned = user.trimmingCharacters(in: .whitespacesAndNewlines)
            if !cleaned.isEmpty { return cleaned }
        }
        #endif
        
        return nil
    }
    
    @discardableResult
    public func saveUsername(_ username: String) -> Bool {
        let cleaned = username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let configPath = getConfigUsernameURL()
        let dir = configPath.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        
        if let data = cleaned.data(using: .utf8) {
            try? data.write(to: configPath, options: .atomic)
        }
        
        #if os(macOS)
        if let data = cleaned.data(using: .utf8) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: "com.adith.GitHubTracker.credentials",
                kSecAttrAccount as String: "github_username"
            ]
            SecItemDelete(query as CFDictionary)
            var attributes = query
            attributes[kSecValueData as String] = data
            SecItemAdd(attributes as CFDictionary, nil)
        }
        #endif
        
        return true
    }
    
    private func getConfigTokenURL() -> URL {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        return homeDir.appendingPathComponent(".config/github-tracker/token")
    }
    
    private func getConfigUsernameURL() -> URL {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        return homeDir.appendingPathComponent(".config/github-tracker/username")
    }
}
