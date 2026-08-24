import Foundation
import Security

/// Thread-safe manager for securely storing and retrieving GitHub API tokens and usernames in macOS Keychain.
public final class KeychainManager {
    public static let shared = KeychainManager()
    
    private let service = "com.adith.GitHubTracker.credentials"
    private let defaultTokenAccount = "github_personal_access_token"
    private let defaultUsernameAccount = "github_username"
    
    private init() {}
    
    // MARK: - Token Management
    
    /// Save Personal Access Token securely in Keychain
    @discardableResult
    public func saveToken(_ token: String, for account: String = "default") -> Bool {
        guard let data = token.data(using: .utf8) else { return false }
        
        let accountKey = account == "default" ? defaultTokenAccount : "token_\(account)"
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountKey
        ]
        
        SecItemDelete(query as CFDictionary)
        
        var newAttributes = query
        newAttributes[kSecValueData as String] = data
        newAttributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        
        let status = SecItemAdd(newAttributes as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// Retrieve Personal Access Token from Keychain
    public func getToken(for account: String = "default") -> String? {
        let accountKey = account == "default" ? defaultTokenAccount : "token_\(account)"
        
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
        let accountKey = account == "default" ? defaultTokenAccount : "token_\(account)"
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountKey
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    // MARK: - Username Management
    
    /// Save GitHub Username securely in Keychain
    @discardableResult
    public func saveUsername(_ username: String) -> Bool {
        let cleaned = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = cleaned.data(using: .utf8) else { return false }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: defaultUsernameAccount
        ]
        
        SecItemDelete(query as CFDictionary)
        
        var newAttributes = query
        newAttributes[kSecValueData as String] = data
        newAttributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        
        let status = SecItemAdd(newAttributes as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// Retrieve GitHub Username from Keychain
    public func getUsername() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: defaultUsernameAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess, let data = dataTypeRef as? Data, let user = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        let cleaned = user.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? nil : cleaned
    }
    
    /// Delete GitHub Username from Keychain
    @discardableResult
    public func deleteUsername() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: defaultUsernameAccount
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
