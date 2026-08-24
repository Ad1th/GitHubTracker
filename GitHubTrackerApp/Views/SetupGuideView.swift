import SwiftUI

public struct SetupGuideView: View {
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Widget Setup Guide")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 10) {
                GuideStepRow(
                    stepNumber: "1",
                    title: "Open Notification Center or Desktop",
                    description: "Click the time/date in the top-right corner of your Mac menu bar or right-click your macOS desktop and select 'Edit Widgets'."
                )
                
                GuideStepRow(
                    stepNumber: "2",
                    title: "Search for 'GitHub Contributions'",
                    description: "In the widget gallery search bar, type 'GitHub' or scroll down to find the GitHub Tracker widget."
                )
                
                GuideStepRow(
                    stepNumber: "3",
                    title: "Choose Widget Size",
                    description: "Select Small, Medium (recommended), or Large size and drag it onto your desktop or Notification Center."
                )
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
        }
    }
}

private struct GuideStepRow: View {
    let stepNumber: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 22, height: 22)
                Text(stepNumber)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
                Text(description)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
