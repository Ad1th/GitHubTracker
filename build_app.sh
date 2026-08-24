#!/bin/bash
set -e

echo "Building GitHubTracker macOS App & WidgetKit Extension..."
SDK=$(xcrun --show-sdk-path)

# 1. Compile Main App Binary
xcrun swiftc -sdk "$SDK" -target arm64-apple-macosx14.0 -framework SwiftUI -framework WidgetKit -framework Security \
  Shared/Models/*.swift \
  Shared/Keychain/*.swift \
  Shared/Storage/*.swift \
  Shared/GitHubAPI/*.swift \
  GitHubTrackerWidget/Models/*.swift \
  GitHubTrackerWidget/Views/*.swift \
  GitHubTrackerApp/Models/*.swift \
  GitHubTrackerApp/Services/*.swift \
  GitHubTrackerApp/Views/*.swift \
  GitHubTrackerApp/App/*.swift \
  -o GitHubTrackerAppExecutable

# 2. Compile WidgetKit Extension Binary
xcrun swiftc -sdk "$SDK" -target arm64-apple-macosx14.0 -framework SwiftUI -framework WidgetKit -framework Security \
  Shared/Models/*.swift \
  Shared/Keychain/*.swift \
  Shared/Storage/*.swift \
  GitHubTrackerWidget/Models/*.swift \
  GitHubTrackerWidget/Timeline/*.swift \
  GitHubTrackerWidget/Views/*.swift \
  GitHubTrackerWidget/Widget/*.swift \
  -o GitHubTrackerWidgetExecutable

# 3. Construct .app bundle structure
mkdir -p GitHubTracker.app/Contents/MacOS
mkdir -p GitHubTracker.app/Contents/Resources
mkdir -p GitHubTracker.app/Contents/PlugIns/GitHubTrackerWidgetExtension.appex/Contents/MacOS

cp GitHubTrackerAppExecutable GitHubTracker.app/Contents/MacOS/GitHubTracker
chmod +x GitHubTracker.app/Contents/MacOS/GitHubTracker

cp GitHubTrackerWidgetExecutable GitHubTracker.app/Contents/PlugIns/GitHubTrackerWidgetExtension.appex/Contents/MacOS/GitHubTrackerWidgetExtension
chmod +x GitHubTracker.app/Contents/PlugIns/GitHubTrackerWidgetExtension.appex/Contents/MacOS/GitHubTrackerWidgetExtension

# App Info.plist
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

# Widget Extension Info.plist
cat << 'EOF' > GitHubTracker.app/Contents/PlugIns/GitHubTrackerWidgetExtension.appex/Contents/Info.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>GitHubTrackerWidgetExtension</string>
	<key>CFBundleIdentifier</key>
	<string>com.githubtracker.app.widget</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>GitHubTrackerWidgetExtension</string>
	<key>CFBundlePackageType</key>
	<string>XPC!</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSMinimumSystemVersion</key>
	<string>14.0</string>
	<key>NSExtension</key>
	<dict>
		<key>NSExtensionPointIdentifier</key>
		<string>com.apple.widgetkit-extension</string>
	</dict>
</dict>
EOF

# 4. Codesign & Register with macOS LaunchServices
codesign --force --deep --sign - GitHubTracker.app
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f GitHubTracker.app

echo "Successfully compiled GitHubTracker.app with Desktop Widget Window Manager!"
