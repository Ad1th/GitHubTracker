// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GitHubTracker",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "ghtracker", targets: ["ghtracker"]),
        .library(name: "GitHubTrackerCore", targets: ["GitHubTrackerCore"])
    ],
    targets: [
        .target(
            name: "GitHubTrackerCore",
            path: "Sources/GitHubTrackerCore"
        ),
        .executableTarget(
            name: "ghtracker",
            dependencies: ["GitHubTrackerCore"],
            path: "Sources/ghtracker"
        )
    ]
)
