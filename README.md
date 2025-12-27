# Flutter Module with Call Feature

A Flutter module integrated into native iOS/Android apps with comprehensive call functionality.

## 🎉 New: Call Feature

This module now includes a complete call system with:
- ✅ Incoming/Outgoing calls (Audio & Video)
- ✅ iOS CallKit integration
- ✅ Background & killed app support
- ✅ Tencent Calls UIKit ready
- ✅ BLoC pattern with unit tests
- ✅ Beautiful call UI
- Them 111

### Quick Start

1. **iOS Build Fix** (Xcode 16 Swift compatibility):
   ```bash
   # After flutter clean, run:
   ./apply_ios_fix.sh
   
   # Or use the wrapper:
   ./clean_and_fix.sh
   ```
   
   See [IOS_FIX_SCRIPTS.md](IOS_FIX_SCRIPTS.md) for details.

2. **Fix generated code** (if needed):
   ```bash
   ./fix_freezed.sh
   ```

3. **Test the implementation**:
   ```bash
   flutter test test/blocs/call_bloc_test.dart
   ```

4. **Navigate to call screens from native**:
   - iOS: `flutterViewController.pushRoute("/outgoing?data=...")`
   - Android: `FlutterActivity.withNewEngine().initialRoute("/outgoing?data=...")`

### Documentation
- 📘 **English**: [CALL_FEATURE_DOCUMENTATION.md](CALL_FEATURE_DOCUMENTATION.md)
- 📘 **Tiếng Việt**: [CALL_FEATURE_README_VI.md](CALL_FEATURE_README_VI.md)
- 📋 **Implementation**: [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)
- 🔧 **iOS Fix**: [XCODE_16_SWIFT_ISSUE.md](XCODE_16_SWIFT_ISSUE.md) | [IOS_FIX_SCRIPTS.md](IOS_FIX_SCRIPTS.md)
- 🔐 **iOS Permissions**: [IOS_PERMISSIONS.md](IOS_PERMISSIONS.md)

### Routes
- `/` - Home screen
- `/detail` - Detail screen
- `/form` - Form screen
- `/incall` - In-call screen (NEW)
- `/outgoing` - Outgoing call screen (NEW)

## Getting Started

For help getting started with Flutter development, view the online
[documentation](https://flutter.dev/).

For instructions integrating Flutter modules to your existing applications,
see the [add-to-app documentation](https://flutter.dev/to/add-to-app).
