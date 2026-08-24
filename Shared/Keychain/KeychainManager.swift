import Foundation
import Security

/// Thread-safe manager for securely storing and retrieving GitHub API tokens in macOS Keychain.
public final class KeychainManager {
    public static let shared = KeychainManager()
    
    private let service = "com.githubtracker.app.token"
    private let defaultAccount = "github_personal_access_token"
    
    private init() {}
    
    /// Save Personal Access Token securely in Keychain
    @discardableResult
    public func saveToken(_ token: String, for account: String = "default") -> Bool {
        guard let data = token.data(using: .utf8) else { return false }
        
        let accountKey = account == "default" ? defaultAccount : "token_\(account)"
        
        // Build search query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountKey
        ]
        
        // Delete existing token if present
        SecItemDelete(query as CFDictionary)
        
        // Attributes to add
        var newAttributes = query
        newAttributes[kSecValueData as String] = data
        newAttributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        
        let status = SecItemAdd(newAttributes as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// Retrieve Personal Access Token from Keychain
    public func getToken(for account: String = "default") -> String? {
        let accountKey = account == "default" ? defaultAccount : "token_\(account)"
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess, let data = dataTypeRef as? Data, let token = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return token.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Delete Personal Access Token from Keychain
    @discardableResult
    public func deleteToken(for account: String = "default") -> Bool {
        let accountKey = account == "default" ? defaultAccount : "token_\(account)"
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountKey
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
