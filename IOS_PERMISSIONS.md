# iOS Permissions Setup

## 🔐 Required Permissions for Call Feature

App cần các permissions sau để hoạt động đúng:

### 1. Camera Permission ✅
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to the camera for video calls.</string>
```
**Khi nào cần:** Video calls

### 2. Microphone Permission ✅
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to the microphone for audio and video calls.</string>
```
**Khi nào cần:** Tất cả calls (audio & video)

### 3. Photo Library Permission ✅
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to your photo library to share images during calls.</string>
```
**Khi nào cần:** Share ảnh trong call

### 4. Photo Library Add Permission ✅
```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>This app needs permission to save photos from calls to your photo library.</string>
```
**Khi nào cần:** Save screenshots/photos từ call

### 5. Contacts Permission ✅
```xml
<key>NSContactsUsageDescription</key>
<string>This app needs access to your contacts to help you make calls.</string>
```
**Khi nào cần:** Hiển thị contacts để gọi

### 6. Background Modes ✅
```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>voip</string>
</array>
```
**Khi nào cần:** 
- `audio`: Maintain audio trong background
- `voip`: Receive incoming calls khi app ở background/killed

---

## 📍 File Location

Permissions được config trong:
```
.ios/Runner/Info.plist
```

---

## 🚨 Common Errors

### Error: "This app has crashed because it attempted to access privacy-sensitive data"

**Nguyên nhân:** Thiếu usage description trong Info.plist

**Fix:** Đã được thêm tất cả permissions cần thiết vào Info.plist

### Error: "User denied permission"

**Cách xử lý trong code:**
```dart
// Check permission before using
final status = await Permission.camera.status;
if (status.isDenied) {
  // Request permission
  await Permission.camera.request();
}
```

---

## 🔧 Testing Permissions

### 1. Reset Permissions (Simulator)

```bash
# Reset all permissions for app
xcrun simctl privacy booted reset all com.example.flutterModule

# Reset specific permission
xcrun simctl privacy booted reset camera com.example.flutterModule
xcrun simctl privacy booted reset microphone com.example.flutterModule
```

### 2. Grant Permissions (Simulator)

```bash
# Grant camera permission
xcrun simctl privacy booted grant camera com.example.flutterModule

# Grant microphone permission
xcrun simctl privacy booted grant microphone com.example.flutterModule
```

### 3. Check Current Permissions

```bash
# List all privacy settings
xcrun simctl privacy booted
```

---

## 📱 User Experience

### Permission Request Flow

1. **First Launch:**
   - User opens app
   - Tries to make a call
   - System shows permission dialog
   - User grants/denies

2. **Permission Dialog Text:**
   - **Title:** "[App Name] Would Like to Access the Camera"
   - **Message:** "This app needs access to the camera for video calls."
   - **Buttons:** "Don't Allow" | "OK"

3. **After Denial:**
   - Show custom alert
   - Guide user to Settings
   - Provide deep link: `App-Prefs:root=Privacy&path=CAMERA`

---

## 🎯 Best Practices

### 1. Request at Right Time
```dart
// ❌ BAD: Request on app launch
void initState() {
  Permission.camera.request();
}

// ✅ GOOD: Request when user tries to use feature
void startVideoCall() async {
  if (await Permission.camera.isDenied) {
    final result = await Permission.camera.request();
    if (result.isGranted) {
      // Start call
    }
  }
}
```

### 2. Handle All States
```dart
final status = await Permission.camera.status;

if (status.isGranted) {
  // Permission granted
} else if (status.isDenied) {
  // Permission denied, can request again
  await Permission.camera.request();
} else if (status.isPermanentlyDenied) {
  // User denied permanently, must go to Settings
  openAppSettings();
} else if (status.isRestricted) {
  // Restricted by parental controls
  showRestrictedDialog();
}
```

### 3. Provide Context
```dart
// Show explanation before requesting
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Camera Access Needed'),
    content: Text('We need camera access to enable video calls.'),
    actions: [
      TextButton(
        onPressed: () async {
          Navigator.pop(context);
          await Permission.camera.request();
        },
        child: Text('Grant Access'),
      ),
    ],
  ),
);
```

---

## 🔗 Related Files

- `.ios/Runner/Info.plist` - Permission configurations
- `lib/data/services/callkit_service.dart` - CallKit integration
- `lib/data/services/tencent_call_service.dart` - Call service

---

## 📚 References

- [Apple Privacy Guidelines](https://developer.apple.com/documentation/uikit/protecting_the_user_s_privacy)
- [Permission Handler Plugin](https://pub.dev/packages/permission_handler)
- [CallKit Framework](https://developer.apple.com/documentation/callkit)

---

## ✅ Verification

Sau khi thêm permissions, verify bằng cách:

1. **Build app:**
   ```bash
   flutter build ios --simulator --debug
   ```

2. **Run app và test:**
   - Mở app
   - Thử make video call
   - Verify permission dialog xuất hiện
   - Grant permission
   - Verify call hoạt động

3. **Check Info.plist:**
   ```bash
   cat .ios/Runner/Info.plist | grep -A 1 "NSCameraUsageDescription"
   ```

**Expected output:**
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to the camera for video calls.</string>
```

---

## 🆘 Troubleshooting

### App still crashes after adding permissions

1. **Clean build:**
   ```bash
   ./clean_and_fix.sh
   cd .ios && pod install
   flutter build ios --simulator --debug
   ```

2. **Verify Info.plist was updated:**
   ```bash
   cat .ios/Runner/Info.plist
   ```

3. **Check Xcode:**
   - Open `.ios/Runner.xcworkspace` in Xcode
   - Select Runner target
   - Go to Info tab
   - Verify all usage descriptions are present

### Permission dialog not showing

1. **Reset permissions:**
   ```bash
   xcrun simctl privacy booted reset all com.example.flutterModule
   ```

2. **Reinstall app:**
   ```bash
   flutter clean
   flutter build ios --simulator --debug
   ```

---

## 📝 Checklist

- ✅ NSCameraUsageDescription added
- ✅ NSMicrophoneUsageDescription added
- ✅ NSPhotoLibraryUsageDescription added
- ✅ NSPhotoLibraryAddUsageDescription added
- ✅ NSContactsUsageDescription added
- ✅ UIBackgroundModes configured (audio, voip)
- ✅ App builds successfully
- ✅ Permissions work in runtime

