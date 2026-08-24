import SwiftUI

public struct SettingsView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var isShowingToken: Bool = false
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings & Authentication")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 12) {
                // Username Section
                VStack(alignment: .leading, spacing: 4) {
                    Text("GitHub Username")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("@")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.secondary)
                        TextField("username", text: $viewModel.username)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: viewModel.username) {
                                viewModel.saveUsername()
                            }
                    }
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                // Personal Access Token Section
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Personal Access Token (PAT)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if viewModel.isTokenSavedInKeychain {
                            HStack(spacing: 4) {
                                Image(systemName: "lock.shield.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.green)
                                Text("Secured in Keychain")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    
                    HStack {
                        if isShowingToken {
                            TextField("ghp_xxxxxxxxxxxxxxxxxxxx", text: $viewModel.token)
                                .textFieldStyle(.roundedBorder)
                        } else {
                            SecureField("ghp_xxxxxxxxxxxxxxxxxxxx", text: $viewModel.token)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        Button(action: { isShowingToken.toggle() }) {
                            Image(systemName: isShowingToken ? "eye.slash" : "eye")
                                .font(.system(size: 12))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 4)
                        
                        if viewModel.isTokenSavedInKeychain {
                            Button("Remove") {
                                viewModel.removeToken()
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        } else {
                            Button("Save") {
                                viewModel.saveToken()
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                            .disabled(viewModel.token.isEmpty)
                        }
                    }
                    
                    Text("Stored safely in macOS Keychain. Used only for fetching private contributions & exact stats via GitHub GraphQL API.")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                // Menu Bar Option Toggle
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Show Menu Bar Icon", isOn: $viewModel.showMenuBarItem)
                        .font(.system(size: 12, weight: .medium))
                    
                    Text("Adds a quick-access '</>' GitHub contribution icon to your macOS top Menu Bar.")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.secondary)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(nsColor: .controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                    )
            )
        }
    }
}
