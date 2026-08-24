import SwiftUI
import AppKit

public final class DesktopWidgetManager: NSWindowController {
    public static let shared = DesktopWidgetManager()
    
    private init() {
        let window = NSWindow(
            contentRect: NSRect(x: 200, y: 300, width: 340, height: 170),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window.level = .floating
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.isMovable = true
        window.isMovableByWindowBackground = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        
        super.init(window: window)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateDesktopWidget(data: ContributionData) {
        let entry = GitHubWidgetEntry(date: Date(), contributionData: data)
        let widgetView = DraggableDesktopWidgetContainer(entry: entry)
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

private struct DraggableDesktopWidgetContainer: View {
    let entry: GitHubWidgetEntry
    
    var body: some View {
        MediumWidgetView(entry: entry)
            .frame(width: 325, height: 155)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            .background(WindowDragNSViewRepresentable())
            .padding(6)
    }
}

private struct WindowDragNSViewRepresentable: NSViewRepresentable {
    func makeNSView(context: Context) -> WindowDragNSView {
        return WindowDragNSView()
    }
    func updateNSView(_ nsView: WindowDragNSView, context: Context) {}
}

private class WindowDragNSView: NSView {
    override var mouseDownCanMoveWindow: Bool {
        return true
    }
}
