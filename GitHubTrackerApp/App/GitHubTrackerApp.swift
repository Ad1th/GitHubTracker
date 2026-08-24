import SwiftUI

@main
public struct GitHubTrackerApp: App {
    @StateObject private var viewModel = AppViewModel()
    
    public init() {}
    
    public var body: some Scene {
        WindowGroup {
            MainView()
        }
        .windowStyle(.titleBar)
        
        MenuBarExtra(isInserted: $viewModel.showMenuBarItem) {
            VStack(alignment: .leading, spacing: 12) {
                if let data = viewModel.contributionData {
                    MediumWidgetView(entry: GitHubWidgetEntry(date: Date(), contributionData: data))
                        .frame(width: 345, height: 168)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                } else {
                    ProgressView("Loading GitHub statistics...")
                        .padding()
                }
                
                Divider()
                
                HStack {
                    Button(action: {
                        Task { await viewModel.refreshData() }
                    }) {
                        Label("Sync Now", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    
                    Spacer()
                    
                    Button("Quit") {
                        NSApplication.shared.terminate(nil)
                    }
                    .buttonStyle(.borderless)
                    .controlSize(.small)
                }
            }
            .padding(12)
        } label: {
            Image(systemName: "chevron.left.forwardslash.chevron.right")
        }
        .menuBarExtraStyle(.window)
    }
}
