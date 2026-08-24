import SwiftUI

public struct MainView: View {
    @StateObject private var viewModel = AppViewModel()
    @State private var selectedPreviewTab: WidgetSize = .medium
    
    enum WidgetSize: String, CaseIterable, Identifiable {
        case small = "Small"
        case medium = "Medium"
        case large = "Large"
        var id: String { rawValue }
    }
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("GitHub Contribution Tracker")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                        Text("Native macOS App & WidgetKit Extension")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
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
                        
                        Picker("Size", selection: $selectedPreviewTab) {
                            ForEach(WidgetSize.allCases) { size in
                                Text(size.rawValue).tag(size)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 200)
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
                            ProgressView("Loading preview...")
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
            Task {
                await viewModel.refreshData()
            }
        }
    }
}
