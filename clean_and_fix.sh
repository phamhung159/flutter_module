#!/bin/bash

# Wrapper script for flutter clean that automatically applies iOS fix

echo "🧹 Running flutter clean..."
flutter clean

echo ""
echo "📦 Running flutter pub get..."
flutter pub get

echo ""
echo "🔧 Applying iOS fix..."
./apply_ios_fix.sh

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Clean and fix completed successfully!"
    echo ""
    echo "You can now run:"
    echo "  cd .ios && pod install"
    echo "  flutter build ios --simulator --debug"
else
    echo ""
    echo "❌ Failed to apply fix"
    exit 1
fi

