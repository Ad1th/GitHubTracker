// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GitHubTracker",
    platforms: [
        .macOS(.v14)
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
        ),
        .testTarget(
            name: "GitHubTrackerCoreTests",
            dependencies: ["GitHubTrackerCore"],
            path: "Tests/GitHubTrackerCoreTests"
        )
    ]
)
