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
    
    @Published public var showMenuBarItem: Bool = UserDefaults.standard.bool(forKey: "show_menu_bar_item") {
        didSet {
            UserDefaults.standard.set(showMenuBarItem, forKey: "show_menu_bar_item")
        }
    }
    
    public init() {
        self.username = WidgetDataStore.shared.getUsername()
        if let storedToken = KeychainManager.shared.getToken() {
            self.token = storedToken
            self.isTokenSavedInKeychain = true
        }
        self.contributionData = WidgetDataStore.shared.loadContributionData() ?? ContributionData.sample(username: username)
    }
    
    public func saveUsername() {
        let cleaned = username.trimmingCharacters(in: .whitespacesAndNewlines)
        WidgetDataStore.shared.saveUsername(cleaned)
        statusMessage = "Username updated to '@\(cleaned)'."
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
        isLoading = true
        errorMessage = nil
        statusMessage = nil
        
        saveUsername()
        if !token.isEmpty {
            saveToken()
        }
        
        do {
            let freshData = try await ContributionService.shared.fetchContributionData(username: username)
            self.contributionData = freshData
            
            let authStatus = freshData.isAuthenticated ? "GraphQL (Authenticated)" : "Public REST"
            self.statusMessage = "Successfully updated GitHub data via \(authStatus)."
        } catch {
            self.errorMessage = error.localizedDescription
            if self.contributionData == nil {
                self.contributionData = WidgetDataStore.shared.loadContributionData()
            }
        }
        
        isLoading = false
    }
}
