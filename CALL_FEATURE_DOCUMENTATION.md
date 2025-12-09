# Call Feature Documentation

## Overview
This Flutter module now includes a comprehensive call system with support for:
- **Incoming/Outgoing Calls**: Audio and video call support
- **CallKit Integration**: Native iOS CallKit support for incoming calls
- **Background/Killed App Support**: Receive calls even when app is not running
- **Tencent Calls UIKit**: Real-time communication using Tencent Cloud
- **BLoC Pattern**: Testable architecture with unit tests included

## Architecture

### Components

#### 1. **Models**
- `CallDto` - Data transfer object for API calls
- `CallModel` - Domain model with call state management
- `CallStatus` - Enum for call states (incoming, outgoing, connected, etc.)
- `CallType` - Enum for call types (audio, video)

#### 2. **Services**
- `CallKitService` - Manages CallKit integration for iOS
- `TencentCallService` - Integrates Tencent Calls UIKit for real-time communication

#### 3. **BLoC**
- `CallBloc` - Manages call state and business logic
- `CallEvent` - All call-related events
- `CallState` - Current call state with helpers

#### 4. **UI Screens**
- `InCallScreen` - Active call interface
- `OutgoingScreen` - Outgoing call interface

## Setup Instructions

### 1. iOS Configuration

Add to `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>voip</string>
</array>

<key>NSMicrophoneUsageDescription</key>
<string>We need access to your microphone for voice calls</string>

<key>NSCameraUsageDescription</key>
<string>We need access to your camera for video calls</string>
```

### 2. Android Configuration

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.CALL_PHONE" />
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

### 3. Tencent Cloud Setup

1. Create account at: https://console.cloud.tencent.com/
2. Get your `SDKAppID` and generate `UserSig`
3. Initialize in your app:

```dart
final tencentService = getIt<TencentCallService>();
await tencentService.initialize(
  sdkAppId: YOUR_SDK_APP_ID,
  userId: 'current_user_id',
  userSig: 'generated_user_sig',
);
```

## Usage

### Making a Call

#### From Native iOS:

```swift
import Flutter
import FlutterCallkitIncoming

// Navigate to outgoing call screen
let flutterViewController = FlutterViewController(...)
let route = "/outgoing?data=" + encodeData([
    "calleeId": "user123",
    "calleeName": "John Doe",
    "calleeAvatar": "https://...",
    "isVideo": false
])

flutterViewController.pushRoute(route)
```

#### From Native Android:

```kotlin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

val intent = FlutterActivity
    .withNewEngine()
    .initialRoute("/outgoing?data=" + encodeData(mapOf(
        "calleeId" to "user123",
        "calleeName" to "John Doe",
        "calleeAvatar" to "https://...",
        "isVideo" to false
    )))
    .build(context)

startActivity(intent)
```

#### From Flutter:

```dart
// Audio call
Navigator.of(context).pushNamed(
  '/outgoing',
  arguments: {
    'calleeId': 'user123',
    'calleeName': 'John Doe',
    'calleeAvatar': 'https://...',
    'isVideo': false,
  },
);

// Video call
Navigator.of(context).pushNamed(
  '/outgoing',
  arguments: {
    'calleeId': 'user456',
    'calleeName': 'Jane Smith',
    'isVideo': true,
  },
);
```

### Receiving a Call

#### Push Notification Handler (Background/Killed App)

When receiving a push notification for incoming call:

```dart
// In your push notification handler
final callKitService = getIt<CallKitService>();

await callKitService.showIncomingCall(
  callId: 'unique-call-id',
  callerId: 'caller-user-id',
  callerName: 'John Doe',
  callerAvatar: 'https://...',
  isVideo: false,
);

// The CallKit UI will show automatically
// When user accepts, navigate to incall screen
```

#### Navigate to InCall Screen:

```dart
Navigator.of(context).pushNamed(
  '/incall',
  arguments: {
    'callId': 'unique-call-id',
    'callerId': 'caller-user-id',
    'callerName': 'John Doe',
    'callerAvatar': 'https://...',
    'isVideo': false,
  },
);
```

### Using the CallBloc Directly

```dart
// Create bloc
final callBloc = getIt<CallBloc>();
callBloc.add(const CallEvent.initEvent());

// Make a call
callBloc.add(CallEvent.makeCall(
  calleeId: 'user123',
  calleeName: 'John Doe',
  callType: CallType.audio,
));

// Receive a call
callBloc.add(CallEvent.receiveCall(
  callId: 'call-id',
  callerId: 'user456',
  callerName: 'Jane Smith',
  callType: CallType.video,
));

// Accept call
callBloc.add(const CallEvent.acceptCall());

// Decline call
callBloc.add(const CallEvent.declineCall());

// End call
callBloc.add(const CallEvent.endCall());

// Toggle mute
callBloc.add(const CallEvent.toggleMute());

// Toggle speaker
callBloc.add(const CallEvent.toggleSpeaker());

// Toggle video (video calls only)
callBloc.add(const CallEvent.toggleVideo());

// Listen to state
callBloc.stream.listen((state) {
  if (state.isInCall) {
    print('Call duration: ${state.callDuration} seconds');
  }
});
```

## Call Flow

### Outgoing Call Flow
1. User initiates call → `MakeCall` event
2. Bloc creates call with `outgoing` status
3. CallKit shows outgoing call UI (iOS)
4. Status changes: `outgoing` → `connecting` → `connected`
5. Timer starts tracking call duration
6. User can end call → `EndCall` event
7. Call status becomes `ended`
8. UI navigates back

### Incoming Call Flow (Foreground)
1. App receives call notification
2. `ReceiveCall` event triggered
3. CallKit shows incoming call UI
4. User accepts → `AcceptCall` event
5. Status changes: `incoming` → `connecting` → `connected`
6. Timer starts tracking call duration
7. UI shows in-call controls

### Incoming Call Flow (Background/Killed)
1. Push notification arrives
2. System shows CallKit UI (iOS) or Notification (Android)
3. User taps "Accept"
4. App launches to `/incall` route
5. CallBloc receives `HandleCallKitEvent.accepted`
6. Status changes: `incoming` → `connecting` → `connected`
7. Call proceeds normally

## Testing

### Unit Tests
Unit tests are provided in `test/blocs/call_bloc_test.dart`

Run tests:
```bash
flutter test test/blocs/call_bloc_test.dart
```

### Test Coverage Includes:
- ✅ Initial state
- ✅ Making calls (audio/video)
- ✅ Receiving calls
- ✅ Accepting/declining calls
- ✅ Ending calls
- ✅ Toggle actions (mute, speaker, video)
- ✅ Call status updates
- ✅ Call duration tracking
- ✅ CallKit event handling
- ✅ Error handling
- ✅ Edge cases

### Manual Testing

1. **Test Outgoing Call:**
   - Open home screen
   - Tap phone icon in app bar
   - Verify outgoing screen shows
   - Verify call connects after 3 seconds
   - Test mute/speaker controls
   - End call

2. **Test Incoming Call (Foreground):**
   - Trigger incoming call from backend/simulator
   - Verify CallKit UI shows (iOS)
   - Accept call
   - Verify in-call screen shows
   - Test controls
   - End call

3. **Test Incoming Call (Background):**
   - Kill app
   - Trigger incoming call
   - Verify CallKit notification shows
   - Accept call
   - Verify app opens to in-call screen

4. **Test Video Call:**
   - Tap video icon in app bar
   - Verify video controls appear
   - Test video toggle
   - End call

## State Management

### CallState Properties:
```dart
CallState(
  currentCall: CallModel?,      // Current active call
  isMuted: bool,                 // Microphone muted
  isSpeakerOn: bool,             // Speaker enabled
  isVideoEnabled: bool,          // Camera enabled (video calls)
  callDuration: int,             // Duration in seconds
  isLoading: bool,               // Loading state
  error: String?,                // Error message
)
```

### Helper Getters:
- `hasActiveCall` - True if call is active (incoming/outgoing/connecting/connected)
- `isInCall` - True if call is connected
- `isIncoming` - True if call is incoming
- `isOutgoing` - True if call is outgoing

## Integration with Tencent UIKit

The `TencentCallService` provides a wrapper around Tencent Calls UIKit:

```dart
final tencentService = getIt<TencentCallService>();

// Initialize (do this once at app start)
await tencentService.initialize(
  sdkAppId: YOUR_SDK_APP_ID,
  userId: 'current_user_id',
  userSig: 'generated_user_sig',
);

// Make call
await tencentService.call(
  userId: 'target_user_id',
  callType: TUICallMediaType.audio, // or .video
);

// Listen to events
tencentService.eventStream.listen((event) {
  switch (event) {
    case TencentCallReceived():
      // Handle incoming call
      break;
    case TencentCallEnded():
      // Handle call end
      break;
    // ... other events
  }
});
```

## Troubleshooting

### iOS CallKit not showing:
- Verify Info.plist has correct permissions
- Check background modes are enabled
- Ensure VoIP push certificate is configured

### Android notifications not appearing:
- Verify AndroidManifest.xml permissions
- Check notification channel is created
- Ensure FCM is properly configured

### Calls not connecting:
- Verify Tencent Cloud credentials
- Check network connectivity
- Ensure UserSig is valid and not expired

### Audio/Video not working:
- Request runtime permissions first
- Check device permissions in Settings
- Verify microphone/camera are not in use by other apps

## Best Practices

1. **Always initialize CallKit early:**
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     setupServiceLocator(() {});
     final callKit = getIt<CallKitService>();
     await callKit.initialize();
     runApp(MyApp());
   }
   ```

2. **Handle permissions properly:**
   ```dart
   import 'package:permission_handler/permission_handler.dart';
   
   Future<bool> requestCallPermissions(bool isVideo) async {
     var status = await Permission.microphone.request();
     if (isVideo) {
       status = await Permission.camera.request();
     }
     return status.isGranted;
   }
   ```

3. **Clean up resources:**
   ```dart
   @override
   void dispose() {
     callBloc.close();
     super.dispose();
   }
   ```

4. **Handle call interruptions:**
   - Listen to app lifecycle events
   - Handle phone calls from other apps
   - Manage audio session properly

## Future Enhancements

Potential improvements:
- [ ] Call history/logs
- [ ] Contact integration
- [ ] Group calls support
- [ ] Screen sharing
- [ ] Call recording
- [ ] Call quality indicators
- [ ] Network quality monitoring
- [ ] Call statistics/analytics
- [ ] Push-to-talk functionality
- [ ] Call transfer

## Support

For issues or questions:
1. Check Tencent documentation: https://www.tencentcloud.com/document/product/647
2. Check flutter_callkit_incoming: https://pub.dev/packages/flutter_callkit_incoming
3. Review unit tests for usage examples
4. Check logs with `flutter logs`

## License

This implementation follows the same license as the Flutter module project.

