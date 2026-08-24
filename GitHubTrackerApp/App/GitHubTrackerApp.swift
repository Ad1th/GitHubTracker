import SwiftUI

@main
public struct GitHubTrackerApp: App {
    @StateObject private var viewModel = AppViewModel()
    
    public init() {}
    
    public var body: some Scene {
        WindowGroup {
            MainView(viewModel: viewModel)
                .onAppear {
                    MenuBarManager.shared.setupMenuBar(viewModel: viewModel)
                }
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
    }
}
