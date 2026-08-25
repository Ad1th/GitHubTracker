#!/bin/bash
set -e

echo "Building GitHubTracker macOS App & WidgetKit Extension..."
SDK=$(xcrun --show-sdk-path)

# 1. Compile Main App Binary
xcrun swiftc -sdk "$SDK" -target arm64-apple-macosx14.0 -framework SwiftUI -framework WidgetKit -framework AppIntents -framework Security \
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
  -o GitHubTrackerApp

# 2. Compile WidgetKit Extension Binary
xcrun swiftc -sdk "$SDK" -target arm64-apple-macosx14.0 -framework SwiftUI -framework WidgetKit -framework AppIntents -framework Security \
  Shared/Models/*.swift \
  Shared/Keychain/*.swift \
  Shared/Storage/*.swift \
  Shared/GitHubAPI/*.swift \
  GitHubTrackerWidget/Models/*.swift \
  GitHubTrackerWidget/Timeline/*.swift \
  GitHubTrackerWidget/Views/*.swift \
  GitHubTrackerWidget/Widget/*.swift \
  -o GitHubTrackerWidgetExtension

# 3. Construct .app bundle structure
rm -rf /Applications/GitHubTracker.app GitHubTracker.app
mkdir -p GitHubTracker.app/Contents/MacOS
mkdir -p GitHubTracker.app/Contents/Resources
mkdir -p GitHubTracker.app/Contents/PlugIns/GitHubTrackerWidgetExtension.appex/Contents/MacOS

cp GitHubTrackerApp GitHubTracker.app/Contents/MacOS/GitHubTrackerApp
chmod +x GitHubTracker.app/Contents/MacOS/GitHubTrackerApp

cp GitHubTrackerWidgetExtension GitHubTracker.app/Contents/PlugIns/GitHubTrackerWidgetExtension.appex/Contents/MacOS/GitHubTrackerWidgetExtension
chmod +x GitHubTracker.app/Contents/PlugIns/GitHubTrackerWidgetExtension.appex/Contents/MacOS/GitHubTrackerWidgetExtension

# App Info.plist
cat << 'EOF' > GitHubTracker.app/Contents/Info.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleDisplayName</key>
	<string>GitHub Tracker</string>
	<key>CFBundleExecutable</key>
	<string>GitHubTrackerApp</string>
	<key>CFBundleIdentifier</key>
	<string>com.adith.GitHubTracker</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>GitHubTrackerApp</string>
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
	<key>CFBundleDisplayName</key>
	<string>GitHub Tracker</string>
	<key>CFBundleExecutable</key>
	<string>GitHubTrackerWidgetExtension</string>
	<key>CFBundleIdentifier</key>
	<string>com.adith.GitHubTracker.widget</string>
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
	<key>CFBundleSupportedPlatforms</key>
	<array>
		<string>MacOSX</string>
	</array>
	<key>LSMinimumSystemVersion</key>
	<string>14.0</string>
	<key>NSExtension</key>
	<dict>
		<key>NSExtensionPointIdentifier</key>
		<string>com.apple.widgetkit-extension</string>
		<key>NSExtensionPointVersion</key>
		<string>1.0</string>
	</dict>
</dict>
</plist>
EOF

# 4. Code Signing
DEV_IDENTITY=$(security find-identity -p codesigning -v | grep "Apple Development" | head -n 1 | awk -F'"' '{print $2}' || true)
if [ -z "$DEV_IDENTITY" ]; then
  DEV_IDENTITY="-"
fi

echo "Signing with identity: $DEV_IDENTITY"
codesign --force --sign "$DEV_IDENTITY" --entitlements GitHubTrackerWidget/GitHubTrackerWidget.entitlements GitHubTracker.app/Contents/PlugIns/GitHubTrackerWidgetExtension.appex
codesign --force --sign "$DEV_IDENTITY" --entitlements GitHubTrackerApp/GitHubTrackerApp.entitlements GitHubTracker.app

cp -R GitHubTracker.app /Applications/
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f -R -trusted /Applications/GitHubTracker.app
pluginkit -r /Applications/GitHubTracker.app/Contents/PlugIns/GitHubTrackerWidgetExtension.appex 2>/dev/null || true
pluginkit -a /Applications/GitHubTracker.app/Contents/PlugIns/GitHubTrackerWidgetExtension.appex
pluginkit -e use -i com.adith.GitHubTracker.widget

rm -rf GitHubTrackerApp GitHubTrackerWidgetExtension

echo "Successfully built and registered GitHubTracker.app with Widget Extension!"
