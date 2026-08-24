# GitHub Tracker for macOS (App + WidgetKit Extension)

A native macOS application and WidgetKit extension built with modern Swift and SwiftUI for tracking GitHub contribution statistics, heatmaps, streaks, language statistics, and activity directly on your macOS Desktop and Notification Center.

---

## Key Features

- **100% Native macOS SwiftUI + WidgetKit App**: Built natively using modern Swift APIs and macOS SDK.
- **GitHub Contribution Heatmap**: Authentic GitHub-style contribution heatmap grid with intensity levels, light/dark mode adaptation, and today's activity highlighting.
- **Multiple Widget Sizes**:
  - **Small Widget (`.systemSmall`)**: Compact view with current streak, today's contributions, and total year count.
  - **Medium Widget (`.systemMedium`)**: Primary widget featuring GitHub header, 4 key stats (Total, Current Streak, Best Streak, Today), full contribution heatmap grid, and live refresh status.
  - **Large Widget (`.systemLarge`)**: Full activity dashboard including heatmap, language distribution bar, and recent event activity.
- **Secure Keychain Credential Storage**: Stores GitHub Personal Access Tokens securely using macOS Keychain (`Security` framework).
- **App Group & Offline Caching**: Uses App Group container (`group.com.githubtracker.app`) for instant offline widget rendering and periodic background updates.
- **Hybrid API Strategy**:
  - **GraphQL API**: Fetches exact contribution calendar, repository languages, and private contributions when authenticated.
  - **Public REST API Fallback**: Gracefully falls back to public profiles and contributions endpoints if no Personal Access Token is set.

---

## Project Architecture

```
GitHubTracker/
├── GitHubTracker.xcodeproj/             # Native Xcode project file
│   └── project.pbxproj
│
├── Shared/                             # Code shared between App and Widget
│   ├── Models/
│   │   ├── ContributionDay.swift       # Heatmap square & intensity levels
│   │   ├── ContributionData.swift      # Primary data payload & mock sample
│   │   ├── LanguageStat.swift          # Programming language usage
│   │   ├── RecentActivity.swift        # Push/PR/Issue events
│   │   └── UserProfile.swift           # User profile info
│   ├── Keychain/
│   │   └── KeychainManager.swift       # Security framework Keychain wrapper
│   ├── Storage/
│   │   ├── AppGroupConstants.swift     # Shared suite & key definitions
│   │   └── WidgetDataStore.swift       # Shared App Group data persistence
│   └── GitHubAPI/
│       ├── GitHubAPIError.swift        # Unified error type
│       ├── GitHubGraphQLClient.swift   # Authenticated GraphQL query client
│       ├── GitHubRESTClient.swift      # Public REST & fallback parser client
│       └── ContributionService.swift   # High-level coordinator
│
├── GitHubTrackerWidget/                # WidgetKit Extension Target
│   ├── Widget/
│   │   └── GitHubTrackerWidget.swift   # @main Widget bundle definition
│   ├── Views/
│   │   ├── HeatmapView.swift           # Heatmap grid component
│   │   ├── StatsHeaderView.swift       # Clean header stats component
│   │   ├── SmallWidgetView.swift       # Compact widget view
│   │   ├── MediumWidgetView.swift      # Primary medium widget view
│   │   └── LargeWidgetView.swift       # Extended dashboard view
│   ├── Models/
│   │   └── WidgetEntry.swift           # WidgetKit timeline entry
│   ├── Timeline/
│   │   └── GitHubTimelineProvider.swift# Timeline provider
│   ├── Info.plist
│   └── GitHubTrackerWidget.entitlements
│
└── GitHubTrackerApp/                   # Companion macOS App Target
    ├── App/
    │   └── GitHubTrackerApp.swift      # @main SwiftUI App entry point
    ├── Views/
    │   ├── MainView.swift              # App window & live widget previews
    │   ├── StatusView.swift            # Connection status & sync trigger
    │   ├── SettingsView.swift          # Username & Keychain token configuration
    │   └── SetupGuideView.swift        # Widget installation guide
    ├── Models/
    │   └── AppViewModel.swift          # App state manager
    ├── Info.plist
    └── GitHubTrackerApp.entitlements
```

---

## How to Build & Run in Xcode

1. Open `/Users/adith/GitHubTracker/GitHubTracker.xcodeproj` in Xcode.
2. Select the `GitHubTrackerApp` target.
3. Select your development team under **Signing & Capabilities** if prompt requires signing.
4. Press **Run (⌘R)** to launch the companion macOS app.
5. In the app window, configure your GitHub username and optional Personal Access Token (stored in macOS Keychain).
6. Click **Refresh Now** to sync live GitHub data.
7. Open macOS Desktop or Notification Center, click **Edit Widgets**, and add the **GitHub Contributions** widget!

---

## Verification & Typechecking

All Swift files have been validated with `xcrun swiftc -typecheck` using the macOS SDK with 0 errors and 0 warnings.
