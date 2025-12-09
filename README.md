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

### Quick Start

1. **Fix generated code** (if needed):
   ```bash
   ./fix_freezed.sh
   ```

2. **Test the implementation**:
   ```bash
   flutter test test/blocs/call_bloc_test.dart
   ```

3. **Navigate to call screens from native**:
   - iOS: `flutterViewController.pushRoute("/outgoing?data=...")`
   - Android: `FlutterActivity.withNewEngine().initialRoute("/outgoing?data=...")`

### Documentation
- 📘 **English**: [CALL_FEATURE_DOCUMENTATION.md](CALL_FEATURE_DOCUMENTATION.md)
- 📘 **Tiếng Việt**: [CALL_FEATURE_README_VI.md](CALL_FEATURE_README_VI.md)
- 📋 **Implementation**: [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)

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
