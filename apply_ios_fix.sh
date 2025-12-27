#!/bin/bash

# Script to apply Xcode 16 Swift compatibility fix to .ios/Podfile
# Run this after flutter clean or when Podfile is regenerated

PODFILE=".ios/Podfile"

echo "🔧 Applying Xcode 16 Swift compatibility fix to $PODFILE..."

# Check if Podfile exists
if [ ! -f "$PODFILE" ]; then
    echo "❌ Error: $PODFILE not found!"
    echo "   Run 'flutter pub get' first to generate the Podfile."
    exit 1
fi

# Check if fix is already applied
if grep -q "use_frameworks! :linkage => :static" "$PODFILE"; then
    echo "✅ Fix already applied!"
    exit 0
fi

# Backup original Podfile
cp "$PODFILE" "$PODFILE.backup"
echo "📦 Backup created: $PODFILE.backup"

# Apply the fix using Python (more reliable than sed for multiline replacement)
python3 << 'EOF'
import re

# Read the Podfile
with open('.ios/Podfile', 'r') as f:
    content = f.read()

# Replace use_frameworks!
content = content.replace(
    "target 'Runner' do\n  use_frameworks!",
    "target 'Runner' do\n  # ✅ FIX: Use static linkage for Xcode 16 Swift 6 compatibility\n  use_frameworks! :linkage => :static"
)

# Replace post_install block
old_post_install = """post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end"""

new_post_install = """post_install do |installer|
  # Xcode toolchain path for Swift compatibility libraries
  xcode_swift_libs = '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift'
  
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      # ✅ FIX: Force Swift 5 mode for Xcode 16 beta
      config.build_settings['SWIFT_VERSION'] = '5.0'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      
      # Add Swift library search paths
      config.build_settings['LIBRARY_SEARCH_PATHS'] = [
        '$(inherited)',
        "#{xcode_swift_libs}/iphonesimulator",
        "#{xcode_swift_libs}/iphoneos",
        '$(SDKROOT)/usr/lib/swift'
      ]
      
      # Force load Swift compatibility libraries
      config.build_settings['OTHER_LDFLAGS'] = [
        '$(inherited)',
        "-Wl,-force_load,#{xcode_swift_libs}/$(PLATFORM_NAME)/libswiftCompatibility50.a",
        "-Wl,-force_load,#{xcode_swift_libs}/$(PLATFORM_NAME)/libswiftCompatibility51.a",
        "-Wl,-force_load,#{xcode_swift_libs}/$(PLATFORM_NAME)/libswiftCompatibility56.a",
        "-Wl,-force_load,#{xcode_swift_libs}/$(PLATFORM_NAME)/libswiftCompatibilityConcurrency.a",
        "-Wl,-force_load,#{xcode_swift_libs}/$(PLATFORM_NAME)/libswiftCompatibilityDynamicReplacements.a"
      ]
      
      # Ensure Swift runtime paths
      config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = [
        '$(inherited)',
        '/usr/lib/swift',
        '@executable_path/Frameworks',
        '@loader_path/Frameworks'
      ]
    end
  end
  
  # ✅ FIX: Modify xcconfig files directly to add Swift compatibility flags
  ['Debug', 'Profile', 'Release'].each do |config_name|
    config_file = "#{installer.sandbox.root}/Target Support Files/Pods-Runner/Pods-Runner.#{config_name.downcase}.xcconfig"
    if File.exist?(config_file)
      content = File.read(config_file)
      force_load_flags = [
        "-Wl,-force_load,#{xcode_swift_libs}/$(PLATFORM_NAME)/libswiftCompatibility50.a",
        "-Wl,-force_load,#{xcode_swift_libs}/$(PLATFORM_NAME)/libswiftCompatibility51.a",
        "-Wl,-force_load,#{xcode_swift_libs}/$(PLATFORM_NAME)/libswiftCompatibility56.a",
        "-Wl,-force_load,#{xcode_swift_libs}/$(PLATFORM_NAME)/libswiftCompatibilityConcurrency.a",
        "-Wl,-force_load,#{xcode_swift_libs}/$(PLATFORM_NAME)/libswiftCompatibilityDynamicReplacements.a"
      ].join(' ')
      
      # Add to OTHER_LDFLAGS if not already present
      unless content.include?('libswiftCompatibility56')
        content.gsub!(/^OTHER_LDFLAGS = (.*)$/, "OTHER_LDFLAGS = \\\\1 #{force_load_flags}")
        File.write(config_file, content)
      end
    end
  end
end"""

content = content.replace(old_post_install, new_post_install)

# Write back
with open('.ios/Podfile', 'w') as f:
    f.write(content)

print("✅ Fix applied successfully!")
EOF

if [ $? -eq 0 ]; then
    echo "✅ Xcode 16 Swift compatibility fix applied!"
    echo ""
    echo "Next steps:"
    echo "  1. cd .ios && pod install"
    echo "  2. flutter build ios --simulator --debug"
else
    echo "❌ Failed to apply fix"
    echo "   Restoring backup..."
    mv "$PODFILE.backup" "$PODFILE"
    exit 1
fi

