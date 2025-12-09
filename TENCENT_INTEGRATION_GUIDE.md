# Hướng dẫn tích hợp Tencent Calls UIKit

## 📝 Tổng quan

File `tencent_call_service.dart` đã được implement đầy đủ với các tính năng:
- ✅ Login/Logout
- ✅ Make call (1-1 và nhóm)
- ✅ Answer/Reject call
- ✅ Hangup call
- ✅ Controls (camera, mic, speaker)
- ✅ Event listeners

## 🚀 Bước 1: Lấy credentials từ Tencent Cloud

### 1.1. Đăng ký tài khoản
1. Truy cập: https://console.cloud.tencent.com/
2. Đăng ký/Đăng nhập
3. Vào **Tencent Real-Time Communication**

### 1.2. Tạo Application
1. Tạo app mới trong console
2. Lấy `SDKAppID` (số nguyên, ví dụ: 1400000000)

### 1.3. Generate UserSig
**⚠️ QUAN TRỌNG:** UserSig PHẢI được generate từ **backend server**, KHÔNG generate ở client!

Trên server của bạn:
```javascript
// Node.js example
const TLSSigAPIv2 = require('tls-sig-api-v2');

const gen = new TLSSigAPIv2.Api(SDKAppID, secretKey);
const userSig = gen.genSig(userId, 86400 * 7); // 7 days
```

## 🔧 Bước 2: Initialize trong Flutter app

### 2.1. Khởi tạo khi user login

```dart
import 'package:flutter_module/data/services/tencent_call_service.dart';
import 'package:flutter_module/app/di/injection.dart';

// Lấy service từ DI
final tencentService = getIt<TencentCallService>();

// Khởi tạo với credentials từ server
await tencentService.initialize(
  sdkAppId: 1400000000,        // Từ Tencent Console
  userId: currentUser.id,       // User ID của bạn
  userSig: userSigFromServer,   // Lấy từ backend API
);
```

### 2.2. Lắng nghe events

```dart
// Lắng nghe các sự kiện từ Tencent
tencentService.eventStream.listen((event) {
  switch (event) {
    case TencentInitialized():
      print('✅ Tencent đã sẵn sàng');
      break;
      
    case TencentCallReceived(callerId: final id, isVideo: final video):
      print('📞 Nhận cuộc gọi từ $id');
      // Hiển thị UI incoming call
      Navigator.pushNamed(context, '/incall', arguments: {
        'callerId': id,
        'isVideo': video,
      });
      break;
      
    case TencentCallBegan():
      print('📞 Cuộc gọi đã bắt đầu');
      break;
      
    case TencentCallEnded(duration: final duration):
      print('📞 Cuộc gọi kết thúc sau $duration giây');
      break;
      
    case TencentError(code: final code, message: final msg):
      print('❌ Lỗi: $code - $msg');
      break;
      
    default:
      break;
  }
});
```

## 📞 Bước 3: Thực hiện các cuộc gọi

### 3.1. Gọi 1-1 (Audio)

```dart
await tencentService.call(
  userId: 'user123',
  isVideo: false,
);
```

### 3.2. Gọi 1-1 (Video)

```dart
await tencentService.call(
  userId: 'user456',
  isVideo: true,
);
```

### 3.3. Gọi nhóm

```dart
await tencentService.groupCall(
  groupId: 'group123',
  userIds: ['user1', 'user2', 'user3'],
  isVideo: true,
);
```

### 3.4. Trả lời cuộc gọi

```dart
// Khi nhận được cuộc gọi đến
await tencentService.acceptCall();
```

### 3.5. Từ chối cuộc gọi

```dart
await tencentService.rejectCall();
```

### 3.6. Kết thúc cuộc gọi

```dart
await tencentService.hangup();
```

## 🎛️ Bước 4: Sử dụng call controls

### 4.1. Bật/tắt microphone

```dart
// Tắt mic
await tencentService.setMicMute(true);

// Bật mic
await tencentService.setMicMute(false);
```

### 4.2. Bật/tắt loa ngoài

```dart
// Bật loa ngoài
await tencentService.setSpeaker(true);

// Tắt loa ngoài (dùng loa trong/tai nghe)
await tencentService.setSpeaker(false);
```

### 4.3. Bật/tắt camera

```dart
// Tắt camera
await tencentService.setVideoMute(true);

// Bật camera
await tencentService.setVideoMute(false);
```

### 4.4. Chuyển đổi camera (front/back)

```dart
await tencentService.switchCamera();
```

## 🚪 Bước 5: Logout

```dart
// Khi user logout khỏi app
await tencentService.logout();
```

## 📱 Tích hợp với CallBloc

Bạn có thể tích hợp Tencent service với CallBloc:

```dart
// Trong CallBloc
class CallBloc extends Bloc<CallEvent, CallState> {
  final TencentCallService _tencentService;
  
  CallBloc(this._tencentService, ...) : super(...) {
    // Lắng nghe Tencent events
    _tencentService.eventStream.listen((event) {
      if (event is TencentCallReceived) {
        add(CallEvent.receiveCall(
          callId: 'tencent-${event.callerId}',
          callerId: event.callerId,
          callerName: event.callerId, // Get from your user database
          callType: event.isVideo ? CallType.video : CallType.audio,
        ));
      }
    });
  }
  
  // Trong các event handlers
  Future<void> _onAcceptCallEvent(...) async {
    await _tencentService.acceptCall();
    // ...
  }
  
  Future<void> _onDeclineCallEvent(...) async {
    await _tencentService.rejectCall();
    // ...
  }
  
  Future<void> _onToggleMuteEvent(...) async {
    await _tencentService.setMicMute(!state.isMuted);
    // ...
  }
}
```

## ⚙️ Cấu hình iOS

Thêm vào `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Cần microphone để thực hiện cuộc gọi</string>

<key>NSCameraUsageDescription</key>
<string>Cần camera để thực hiện video call</string>

<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>voip</string>
</array>
```

## ⚙️ Cấu hình Android

Thêm vào `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android:name.permission.CAMERA" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.BLUETOOTH" />
```

## 🧪 Testing

### Test với 2 devices

1. **Device 1:**
   ```dart
   await tencentService.initialize(
     sdkAppId: YOUR_SDK_APP_ID,
     userId: 'user1',
     userSig: userSig1,
   );
   
   // Gọi đến user2
   await tencentService.call(
     userId: 'user2',
     isVideo: false,
   );
   ```

2. **Device 2:**
   ```dart
   await tencentService.initialize(
     sdkAppId: YOUR_SDK_APP_ID,
     userId: 'user2',
     userSig: userSig2,
   );
   
   // Lắng nghe event và accept
   tencentService.eventStream.listen((event) {
     if (event is TencentCallReceived) {
       tencentService.acceptCall();
     }
   });
   ```

## 🐛 Troubleshooting

### Lỗi login failed
- Kiểm tra SDKAppID có đúng không
- Kiểm tra UserSig có được generate đúng không
- UserSig có expired không (thường là 7 days)

### Không nhận được cuộc gọi
- Kiểm tra observer đã được setup chưa
- Kiểm tra userId có đúng không
- Kiểm tra network connection

### Audio/Video không hoạt động
- Kiểm tra permissions đã được grant chưa
- Kiểm tra device có camera/microphone không
- Test trên real device, không phải simulator

## 📚 Resources

- Tencent Console: https://console.cloud.tencent.com/
- Documentation: https://www.tencentcloud.com/document/product/647
- Flutter Package: https://pub.dev/packages/tencent_calls_uikit
- UserSig Generator: https://www.tencentcloud.com/document/product/647/35166

## ✅ Checklist

- [ ] Đã có tài khoản Tencent Cloud
- [ ] Đã tạo Application và lấy SDKAppID
- [ ] Đã implement UserSig generation trên backend
- [ ] Đã thêm permissions vào iOS/Android
- [ ] Đã test login thành công
- [ ] Đã test call 1-1
- [ ] Đã test accept/reject call
- [ ] Đã test call controls (mute, speaker, camera)
- [ ] Đã test trên real devices

---

**Last Updated:** December 2025  
**Status:** ✅ Ready for Production

