import SwiftUI
import AppKit

@MainActor
public final class MenuBarManager: NSObject {
    public static let shared = MenuBarManager()
    
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var viewModel: AppViewModel?
    
    private override init() {
        super.init()
    }
    
    public func setupMenuBar(viewModel: AppViewModel) {
        self.viewModel = viewModel
        guard statusItem == nil else { return }
        
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .bold)
            let image = NSImage(systemSymbolName: "chevron.left.forwardslash.chevron.right", accessibilityDescription: "GitHub Tracker")?.withSymbolConfiguration(config)
            button.image = image
            button.target = self
            button.action = #selector(togglePopover(_:))
        }
        self.statusItem = item
    }
    
    @objc private func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem?.button, let viewModel = viewModel else { return }
        
        if popover == nil {
            let popover = NSPopover()
            popover.contentSize = NSSize(width: 345, height: 215)
            popover.behavior = .transient
            popover.animates = true
            let popoverView = MenuBarPopoverView(viewModel: viewModel)
            popover.contentViewController = NSHostingController(rootView: popoverView)
            self.popover = popover
        }
        
        guard let popover = popover else { return }
        
        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}

private struct MenuBarPopoverView: View {
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let data = viewModel.contributionData {
                MediumWidgetView(entry: GitHubWidgetEntry(date: Date(), contributionData: data))
                    .frame(width: 325, height: 155)
            } else {
                Text("Loading GitHub statistics...")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
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
    }
}
