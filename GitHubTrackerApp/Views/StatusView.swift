import SwiftUI

public struct StatusView: View {
    @ObservedObject var viewModel: AppViewModel
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Status Card
            HStack(spacing: 12) {
                // Connection Indicator
                Circle()
                    .fill(connectionColor)
                    .frame(width: 10, height: 10)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(connectionTitle)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(connectionSubtitle)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    Task {
                        await viewModel.refreshData()
                    }
                }) {
                    HStack(spacing: 6) {
                        if viewModel.isLoading {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        Text(viewModel.isLoading ? "Refreshing..." : "Refresh Now")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)
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
            
            // Status & Feedback Messages
            if let statusMsg = viewModel.statusMessage {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(statusMsg)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .transition(.opacity)
            }
            
            if let errorMsg = viewModel.errorMessage {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(errorMsg)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .transition(.opacity)
            }
        }
    }
    
    private var connectionColor: Color {
        guard let data = viewModel.contributionData else { return .gray }
        return data.isAuthenticated ? .green : .blue
    }
    
    private var connectionTitle: String {
        guard let data = viewModel.contributionData else { return "Not Connected" }
        return data.isAuthenticated ? "Connected (Authenticated)" : "Connected (Public Data)"
    }
    
    private var connectionSubtitle: String {
        if let lastRefresh = WidgetDataStore.shared.getLastRefreshDate() {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            return "Last synced \(formatter.localizedString(for: lastRefresh, relativeTo: Date()))"
        }
        return "Not synced yet"
    }
}
