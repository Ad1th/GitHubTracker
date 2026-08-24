import SwiftUI

public struct MainView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var selectedPreviewTab: WidgetSize = .medium
    @State private var hasInitiallyLoaded = false
    
    enum WidgetSize: String, CaseIterable, Identifiable {
        case small = "Small"
        case medium = "Medium"
        case large = "Large"
        var id: String { rawValue }
    }
    
    public init(viewModel: AppViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with Prominent Sync Button
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("GitHub Contribution Tracker")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        Text("Real-time macOS Menu Bar & Desktop Widget")
                            .font(.system(size: 12, weight: .regular))
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
                                    .font(.system(size: 12, weight: .bold))
                            }
                            Text(viewModel.isLoading ? "Syncing..." : "Sync GitHub")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(viewModel.isLoading)
                }
                
                // Connection Status
                StatusView(viewModel: viewModel)
                
                // Live Widget Preview Container
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Live Widget Preview")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Picker("", selection: $selectedPreviewTab) {
                            ForEach(WidgetSize.allCases) { size in
                                Text(size.rawValue).tag(size)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                        .frame(width: 220)
                    }
                    
                    VStack {
                        if let data = viewModel.contributionData {
                            let entry = GitHubWidgetEntry(date: Date(), contributionData: data)
                            switch selectedPreviewTab {
                            case .small:
                                SmallWidgetView(entry: entry)
                                    .frame(width: 155, height: 155)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                            case .medium:
                                MediumWidgetView(entry: entry)
                                    .frame(width: 325, height: 155)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                            case .large:
                                LargeWidgetView(entry: entry)
                                    .frame(width: 325, height: 345)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                            }
                        } else {
                            ProgressView("Loading GitHub statistics...")
                                .padding()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(nsColor: .windowBackgroundColor))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                            )
                    )
                }
                
                // Settings
                SettingsView(viewModel: viewModel)
                
                // Setup Guide
                SetupGuideView()
            }
            .padding(24)
        }
        .frame(minWidth: 540, minHeight: 680)
        .onAppear {
            if !hasInitiallyLoaded {
                hasInitiallyLoaded = true
                Task {
                    await viewModel.refreshData()
                }
            }
        }
    }
}
