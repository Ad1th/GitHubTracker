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
            popover.contentSize = NSSize(width: 350, height: 235)
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
            // Header Bar
            HStack {
                Text("@\(viewModel.username)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let lastRefresh = WidgetDataStore.shared.getLastRefreshDate() {
                    let formatter = RelativeDateTimeFormatter()
                    Text(formatter.localizedString(for: lastRefresh, relativeTo: Date()))
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.secondary)
                }
            }
            
            // Heatmap Widget View
            if let data = viewModel.contributionData {
                MediumWidgetView(entry: GitHubWidgetEntry(date: Date(), contributionData: data))
                    .frame(width: 325, height: 155)
            } else {
                VStack(spacing: 8) {
                    ProgressView()
                    Text("Fetching GitHub data...")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .frame(width: 325, height: 155)
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                .cornerRadius(12)
            }
            
            Divider()
            
            // Action Buttons
            HStack {
                Button(action: {
                    Task { await viewModel.refreshData() }
                }) {
                    HStack(spacing: 5) {
                        if viewModel.isLoading {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        Text(viewModel.isLoading ? "Syncing..." : "Sync Now")
                            .font(.system(size: 12, weight: .medium))
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .disabled(viewModel.isLoading)
                
                Spacer()
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.borderless)
                .controlSize(.small)
                .foregroundColor(.secondary)
            }
        }
        .padding(12)
    }
}
