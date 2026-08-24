import SwiftUI
import AppKit

public final class DesktopWidgetManager: NSWindowController {
    public static let shared = DesktopWidgetManager()
    
    private init() {
        let window = NSWindow(
            contentRect: NSRect(x: 150, y: 150, width: 340, height: 170),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window.level = NSWindow.Level(Int(CGWindowLevelForKey(.desktopWindow)) + 1)
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.isMovableByWindowBackground = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        
        super.init(window: window)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateDesktopWidget(data: ContributionData) {
        let entry = GitHubWidgetEntry(date: Date(), contributionData: data)
        let widgetView = MediumWidgetView(entry: entry)
            .frame(width: 325, height: 155)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 4)
            .padding(6)
        
        self.window?.contentView = NSHostingView(rootView: widgetView)
    }
    
    public func show() {
        guard let window = self.window else { return }
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
    }
    
    public func hide() {
        self.window?.orderOut(nil)
    }
}
