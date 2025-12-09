# Tính năng Cuộc gọi - Hướng dẫn Tiếng Việt

## Tổng quan
Module Flutter này đã được tích hợp hệ thống cuộc gọi hoàn chỉnh với các tính năng:
- **Cuộc gọi đến/đi**: Hỗ trợ cả audio và video
- **CallKit iOS**: Tích hợp CallKit native cho iOS
- **Hỗ trợ app ẩn/đã tắt**: Nhận cuộc gọi ngay cả khi app không chạy
- **Tencent Calls UIKit**: Giao tiếp thời gian thực sử dụng Tencent Cloud
- **BLoC Pattern**: Kiến trúc dễ test với unit tests đi kèm

## Cấu trúc

### Các thành phần chính

#### 1. **Models** (lib/repositories/models/)
- `CallModel` - Model domain với quản lý trạng thái cuộc gọi
- `CallStatus` - Enum các trạng thái (incoming, outgoing, connected, v.v.)
- `CallType` - Loại cuộc gọi (audio, video)

#### 2. **Services** (lib/data/services/)
- `CallKitService` - Quản lý CallKit cho iOS
- `TencentCallService` - Tích hợp Tencent Calls UIKit

#### 3. **BLoC** (lib/presentation/call/bloc/)
- `CallBloc` - Quản lý trạng thái và logic cuộc gọi
- `CallEvent` - Các sự kiện liên quan đến cuộc gọi
- `CallState` - Trạng thái hiện tại của cuộc gọi

#### 4. **UI Screens** (lib/presentation/call/)
- `InCallScreen` - Màn hình đang trong cuộc gọi
- `OutgoingScreen` - Màn hình gọi đi

## Hướng dẫn cài đặt

### 1. Cấu hình iOS

Thêm vào `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>voip</string>
</array>

<key>NSMicrophoneUsageDescription</key>
<string>Cần quyền truy cập microphone để thực hiện cuộc gọi</string>

<key>NSCameraUsageDescription</key>
<string>Cần quyền truy cập camera để thực hiện video call</string>
```

### 2. Cấu hình Android

Thêm vào `android/app/src/main/AndroidManifest.xml`:

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

### 3. Cài đặt Tencent Cloud

1. Tạo tài khoản tại: https://console.cloud.tencent.com/
2. Lấy `SDKAppID` và tạo `UserSig`
3. Khởi tạo trong app:

```dart
final tencentService = getIt<TencentCallService>();
await tencentService.initialize(
  sdkAppId: YOUR_SDK_APP_ID,
  userId: 'current_user_id',
  userSig: 'generated_user_sig',
);
```

## Cách sử dụng

### Thực hiện cuộc gọi đi

#### Từ Native iOS:

```swift
import Flutter

// Chuyển đến màn hình gọi đi
let flutterViewController = FlutterViewController(...)
let data = [
    "calleeId": "user123",
    "calleeName": "John Doe",
    "isVideo": false
]
let route = "/outgoing?data=" + encodeJSON(data)
flutterViewController.pushRoute(route)
```

#### Từ Native Android:

```kotlin
import io.flutter.embedding.android.FlutterActivity

val data = mapOf(
    "calleeId" to "user123",
    "calleeName" to "John Doe",
    "isVideo" to false
)
val intent = FlutterActivity
    .withNewEngine()
    .initialRoute("/outgoing?data=" + encodeJSON(data))
    .build(context)

startActivity(intent)
```

#### Từ Flutter:

```dart
// Gọi thoại
Navigator.of(context).pushNamed(
  '/outgoing',
  arguments: {
    'calleeId': 'user123',
    'calleeName': 'John Doe',
    'isVideo': false,
  },
);

// Gọi video
Navigator.of(context).pushNamed(
  '/outgoing',
  arguments: {
    'calleeId': 'user456',
    'calleeName': 'Jane Smith',
    'isVideo': true,
  },
);
```

### Nhận cuộc gọi đến

#### Xử lý Push Notification (Background/App bị tắt)

Khi nhận push notification cho cuộc gọi đến:

```dart
// Trong handler push notification của bạn
final callKitService = getIt<CallKitService>();

await callKitService.showIncomingCall(
  callId: 'unique-call-id',
  callerId: 'caller-user-id',
  callerName: 'John Doe',
  callerAvatar: 'https://...',
  isVideo: false,
);

// CallKit UI sẽ tự động hiển thị
// Khi user nhấn chấp nhận, chuyển đến màn hình incall
```

#### Chuyển đến màn hình InCall:

```dart
Navigator.of(context).pushNamed(
  '/incall',
  arguments: {
    'callId': 'unique-call-id',
    'callerId': 'caller-user-id',
    'callerName': 'John Doe',
    'isVideo': false,
  },
);
```

### Sử dụng CallBloc trực tiếp

```dart
// Tạo bloc
final callBloc = getIt<CallBloc>();
callBloc.add(const CallEvent.initEvent());

// Thực hiện cuộc gọi
callBloc.add(CallEvent.makeCall(
  calleeId: 'user123',
  calleeName: 'John Doe',
  callType: CallType.audio,
));

// Nhận cuộc gọi
callBloc.add(CallEvent.receiveCall(
  callId: 'call-id',
  callerId: 'user456',
  callerName: 'Jane Smith',
  callType: CallType.video,
));

// Chấp nhận cuộc gọi
callBloc.add(const CallEvent.acceptCall());

// Từ chối cuộc gọi
callBloc.add(const CallEvent.declineCall());

// Kết thúc cuộc gọi
callBloc.add(const CallEvent.endCall());

// Tắt/bật microphone
callBloc.add(const CallEvent.toggleMute());

// Bật loa ngoài
callBloc.add(const CallEvent.toggleSpeaker());

// Bật/tắt video (chỉ cho video call)
callBloc.add(const CallEvent.toggleVideo());
```

## Luồng cuộc gọi

### Luồng cuộc gọi đi
1. User bắt đầu gọi → `MakeCall` event
2. Bloc tạo cuộc gọi với status `outgoing`
3. CallKit hiển thị UI gọi đi (iOS)
4. Trạng thái thay đổi: `outgoing` → `connecting` → `connected`
5. Timer bắt đầu đếm thời gian
6. User kết thúc → `EndCall` event
7. Status chuyển thành `ended`
8. UI quay về màn hình trước

### Luồng cuộc gọi đến (App đang mở)
1. App nhận thông báo cuộc gọi
2. `ReceiveCall` event được trigger
3. CallKit hiển thị UI cuộc gọi đến
4. User chấp nhận → `AcceptCall` event
5. Trạng thái: `incoming` → `connecting` → `connected`
6. Timer bắt đầu đếm thời gian
7. UI hiển thị các controls

### Luồng cuộc gọi đến (App ẩn/đã tắt)
1. Push notification đến
2. Hệ thống hiển thị CallKit UI (iOS) hoặc Notification (Android)
3. User nhấn "Chấp nhận"
4. App khởi động tới route `/incall`
5. CallBloc nhận `HandleCallKitEvent.accepted`
6. Status: `incoming` → `connecting` → `connected`
7. Cuộc gọi tiếp tục bình thường

## Testing

### Unit Tests
Có sẵn unit tests trong `test/blocs/call_bloc_test.dart`

Chạy tests:
```bash
flutter test test/blocs/call_bloc_test.dart
```

### Test bao gồm:
- ✅ Trạng thái khởi tạo
- ✅ Thực hiện cuộc gọi (audio/video)
- ✅ Nhận cuộc gọi
- ✅ Chấp nhận/từ chối cuộc gọi
- ✅ Kết thúc cuộc gọi
- ✅ Các toggle actions (mute, speaker, video)
- ✅ Cập nhật trạng thái cuộc gọi
- ✅ Theo dõi thời lượng cuộc gọi
- ✅ Xử lý CallKit events
- ✅ Xử lý lỗi
- ✅ Các trường hợp đặc biệt

### Test thủ công

1. **Test gọi đi:**
   - Mở màn hình home
   - Nhấn icon điện thoại trên app bar
   - Kiểm tra màn hình gọi đi hiển thị
   - Kiểm tra cuộc gọi kết nối sau 3 giây
   - Test các nút mute/speaker
   - Kết thúc cuộc gọi

2. **Test gọi đến (App đang mở):**
   - Trigger cuộc gọi đến từ backend/simulator
   - Kiểm tra CallKit UI hiển thị (iOS)
   - Chấp nhận cuộc gọi
   - Kiểm tra màn hình in-call hiển thị
   - Test các controls
   - Kết thúc cuộc gọi

3. **Test gọi đến (App ẩn):**
   - Tắt app hoàn toàn
   - Trigger cuộc gọi đến
   - Kiểm tra CallKit notification hiển thị
   - Chấp nhận cuộc gọi
   - Kiểm tra app mở đến màn hình in-call

## Routes có sẵn

Module hỗ trợ các routes sau:

- `/` - Home screen
- `/detail` - Detail screen (có sẵn)
- `/form` - Form screen (có sẵn)
- **`/incall`** - Màn hình trong cuộc gọi (MỚI)
- **`/outgoing`** - Màn hình gọi đi (MỚI)

## Gọi từ Native App

### iOS (Swift)

```swift
// Trong ViewController của bạn
import Flutter

func makeCallFromNative() {
    let flutterVC = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
    
    let params: [String: Any] = [
        "calleeId": "user123",
        "calleeName": "Test User",
        "isVideo": false
    ]
    
    let jsonData = try? JSONSerialization.data(withJSONObject: params)
    let jsonString = String(data: jsonData!, encoding: .utf8)!
    let route = "/outgoing?data=\(jsonString)"
    
    flutterVC.setInitialRoute(route)
    navigationController?.pushViewController(flutterVC, animated: true)
}
```

### Android (Kotlin)

```kotlin
// Trong Activity của bạn
import io.flutter.embedding.android.FlutterActivity
import org.json.JSONObject

fun makeCallFromNative() {
    val params = JSONObject().apply {
        put("calleeId", "user123")
        put("calleeName", "Test User")
        put("isVideo", false)
    }
    
    val route = "/outgoing?data=${params.toString()}"
    
    val intent = FlutterActivity
        .withNewEngine()
        .initialRoute(route)
        .build(this)
        
    startActivity(intent)
}
```

## Xử lý sự cố thường gặp

### iOS CallKit không hiển thị:
- Kiểm tra Info.plist có đúng permissions
- Kiểm tra background modes đã được bật
- Đảm bảo VoIP push certificate đã được cấu hình

### Android notifications không hiện:
- Kiểm tra AndroidManifest.xml permissions
- Kiểm tra notification channel đã được tạo
- Đảm bảo FCM đã được cấu hình đúng

### Cuộc gọi không kết nối:
- Kiểm tra thông tin Tencent Cloud
- Kiểm tra kết nối mạng
- Đảm bảo UserSig còn hiệu lực

### Không có âm thanh/video:
- Yêu cầu quyền runtime trước
- Kiểm tra quyền device trong Settings
- Đảm bảo micro/camera không bị app khác sử dụng

## Các file quan trọng

```
lib/
├── presentation/
│   └── call/
│       ├── bloc/
│       │   ├── call_bloc.dart          # BLoC chính
│       │   ├── call_event.dart         # Events
│       │   └── call_state.dart         # States
│       ├── incall_screen.dart          # Màn hình trong cuộc gọi
│       └── outgoing_screen.dart        # Màn hình gọi đi
├── data/
│   ├── models/
│   │   └── call_dto.dart               # DTO cho API
│   └── services/
│       ├── callkit_service.dart        # CallKit service
│       └── tencent_call_service.dart   # Tencent service
└── repositories/
    └── models/
        └── call_model.dart             # Domain model

test/
└── blocs/
    └── call_bloc_test.dart             # Unit tests
```

## Lưu ý quan trọng

1. **Khởi tạo CallKit sớm nhất có thể:**
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     setupServiceLocator(() {});
     
     final callKit = getIt<CallKitService>();
     await callKit.initialize();
     
     runApp(MyApp());
   }
   ```

2. **Xin quyền đúng cách:**
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

3. **Test button đã được thêm vào Home screen:**
   - Icon điện thoại: Test audio call
   - Icon video: Test video call

## Tích hợp với Tencent

Để sử dụng tính năng call thực tế với Tencent:

```dart
// Khởi tạo Tencent (thực hiện một lần khi app start)
final tencentService = getIt<TencentCallService>();
await tencentService.initialize(
  sdkAppId: YOUR_SDK_APP_ID,        // Lấy từ Tencent Console
  userId: 'current_user_id',         // User ID hiện tại
  userSig: 'generated_user_sig',     // Tạo từ server
);

// Lắng nghe events
tencentService.eventStream.listen((event) {
  switch (event) {
    case TencentCallReceived(callerId: final id, isVideo: final video):
      // Nhận cuộc gọi từ user $id
      // Hiển thị UI incoming call
      break;
    case TencentCallEnded(duration: final duration):
      // Cuộc gọi kết thúc sau $duration giây
      break;
    // ... các events khác
  }
});
```

## Hỗ trợ

Nếu có vấn đề:
1. Xem tài liệu Tencent: https://www.tencentcloud.com/document/product/647
2. Xem tài liệu flutter_callkit_incoming: https://pub.dev/packages/flutter_callkit_incoming
3. Tham khảo unit tests để xem ví dụ sử dụng
4. Kiểm tra logs: `flutter logs`

Chúc bạn tích hợp thành công! 🎉

