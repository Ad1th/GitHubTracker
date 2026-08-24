#!/bin/bash
set -e

echo "Building GitHubTracker standalone macOS App..."
SDK=$(xcrun --show-sdk-path)

# Compile Swift sources into executable binary
xcrun swiftc -sdk "$SDK" -target arm64-apple-macosx14.0 -framework SwiftUI -framework WidgetKit -framework Security \
  Shared/Models/*.swift \
  Shared/Keychain/*.swift \
  Shared/Storage/*.swift \
  Shared/GitHubAPI/*.swift \
  GitHubTrackerWidget/Models/*.swift \
  GitHubTrackerWidget/Views/*.swift \
  GitHubTrackerApp/Models/*.swift \
  GitHubTrackerApp/Views/*.swift \
  GitHubTrackerApp/App/*.swift \
  -o GitHubTrackerAppExecutable

# Construct .app bundle
mkdir -p GitHubTracker.app/Contents/MacOS
mkdir -p GitHubTracker.app/Contents/Resources
cp GitHubTrackerAppExecutable GitHubTracker.app/Contents/MacOS/GitHubTracker
chmod +x GitHubTracker.app/Contents/MacOS/GitHubTracker

cat << 'EOF' > GitHubTracker.app/Contents/Info.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>GitHubTracker</string>
	<key>CFBundleIdentifier</key>
	<string>com.githubtracker.app</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>GitHubTracker</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSMinimumSystemVersion</key>
	<string>14.0</string>
	<key>NSPrincipalClass</key>
	<string>NSApplication</string>
</dict>
</plist>
EOF

echo "Successfully built GitHubTracker.app!"
echo "Run 'open GitHubTracker.app' to launch the app."
