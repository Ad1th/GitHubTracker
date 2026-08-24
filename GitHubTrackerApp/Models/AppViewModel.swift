import Foundation
import Combine
import SwiftUI

@MainActor
public final class AppViewModel: ObservableObject {
    @Published public var username: String = ""
    @Published public var token: String = ""
    @Published public var contributionData: ContributionData? = nil
    @Published public var isLoading: Bool = false
    @Published public var statusMessage: String? = nil
    @Published public var errorMessage: String? = nil
    @Published public var isTokenSavedInKeychain: Bool = false
    
    public init() {
        // Load username with Keychain priority, then AppGroup, then fallback
        let savedKeychainUsername = KeychainManager.shared.getUsername()
        let savedStoreUsername = WidgetDataStore.shared.getUsername()
        
        if let kcUser = savedKeychainUsername, !kcUser.isEmpty {
            self.username = kcUser
        } else if !savedStoreUsername.isEmpty && savedStoreUsername != AppGroupConstants.defaultUsername {
            self.username = savedStoreUsername
            KeychainManager.shared.saveUsername(savedStoreUsername)
        } else {
            self.username = AppGroupConstants.defaultUsername
        }
        
        if let storedToken = KeychainManager.shared.getToken() {
            self.token = storedToken
            self.isTokenSavedInKeychain = true
        }
        
        self.contributionData = WidgetDataStore.shared.loadContributionData() ?? ContributionData.sample(username: username)
    }
    
    public func saveUsername() {
        let cleaned = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }
        
        // Save across Keychain, AppGroup, and UserDefaults
        KeychainManager.shared.saveUsername(cleaned)
        WidgetDataStore.shared.saveUsername(cleaned)
        statusMessage = "Username '@\(cleaned)' saved in Keychain & App Storage."
    }
    
    public func saveToken() {
        let cleanedToken = token.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedToken.isEmpty else {
            KeychainManager.shared.deleteToken()
            isTokenSavedInKeychain = false
            statusMessage = "Token removed from Keychain."
            return
        }
        
        let success = KeychainManager.shared.saveToken(cleanedToken)
        if success {
            isTokenSavedInKeychain = true
            statusMessage = "Personal Access Token securely saved in Keychain."
            errorMessage = nil
        } else {
            errorMessage = "Failed to save token to macOS Keychain."
        }
    }
    
    public func removeToken() {
        KeychainManager.shared.deleteToken()
        token = ""
        isTokenSavedInKeychain = false
        statusMessage = "Token removed from Keychain."
    }
    
    public func refreshData() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        statusMessage = nil
        
        saveUsername()
        if !token.isEmpty {
            saveToken()
        }
        
        let targetUsername = username
        
        Task.detached(priority: .userInitiated) {
            do {
                let freshData = try await ContributionService.shared.fetchContributionData(username: targetUsername)
                await MainActor.run {
                    self.contributionData = freshData
                    let authStatus = freshData.isAuthenticated ? "GraphQL (Authenticated)" : "Public REST"
                    self.statusMessage = "Successfully updated GitHub data via \(authStatus)."
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    if self.contributionData == nil {
                        self.contributionData = WidgetDataStore.shared.loadContributionData()
                    }
                    self.isLoading = false
                }
            }
        }
    }
}
