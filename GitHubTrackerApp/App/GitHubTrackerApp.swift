import SwiftUI

@main
public struct GitHubTrackerApp: App {
    public init() {}
    
    public var body: some Scene {
        WindowGroup {
            MainView()
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
    }
}
