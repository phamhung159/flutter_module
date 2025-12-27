# Flutter Module Build Guide

## 🎯 **Hiểu về Flutter Module**

### **Flutter Module ≠ Flutter App**

**Flutter Module** (Project này):
- ✅ Được thiết kế để **embed vào native iOS/Android app**
- ✅ Build thành **frameworks** (.xcframework)
- ❌ **KHÔNG có** `ios/Runner.xcodeproj`
- ❌ **KHÔNG thể** chạy `flutter run` trực tiếp
- ✅ Có `pubspec.yaml` với section `module:`

**Flutter App** (Thông thường):
- ✅ Standalone application
- ✅ Có `ios/Runner.xcodeproj`
- ✅ Chạy được `flutter run`
- ❌ Không có section `module:` trong `pubspec.yaml`

---

## ✅ **Cách Build Flutter Module cho iOS**

### **Bước 1: Build Frameworks**

```bash
cd /Users/mac/Documents/Flutter/Projects/flutter_module
flutter build ios-framework
```

**Output:**
```
Building frameworks for com.example.flutterModule in debug mode...
Building frameworks for com.example.flutterModule in profile mode...
Building frameworks for com.example.flutterModule in release mode...
Frameworks written to /Users/mac/Documents/Flutter/Projects/flutter_module/build/ios/framework.
```

**Kết quả:**
- ✅ `build/ios/framework/Debug/` - Debug frameworks
- ✅ `build/ios/framework/Profile/` - Profile frameworks
- ✅ `build/ios/framework/Release/` - Release frameworks

Mỗi folder chứa:
- `Flutter.xcframework`
- `App.xcframework`
- `FlutterPluginRegistrant.xcframework`
- Các plugin frameworks (tencent_calls_uikit, flutter_callkit_incoming, etc.)

---

### **Bước 2: Embed vào Native iOS App**

#### **Option A: Sử dụng CocoaPods (Recommended)**

**1. Trong iOS project, tạo/update `Podfile`:**

```ruby
# ios/Podfile

flutter_application_path = '../flutter_module'
load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')

target 'YourApp' do
  use_frameworks!
  
  install_all_flutter_pods(flutter_application_path)
end

post_install do |installer|
  flutter_post_install(installer) if defined?(flutter_post_install)
end
```

**2. Run pod install:**

```bash
cd ios
pod install
```

**3. Mở `.xcworkspace` và build:**

```bash
open ios/YourApp.xcworkspace
```

---

#### **Option B: Manual Framework Integration**

**1. Copy frameworks vào iOS project:**

```bash
# Copy Debug frameworks
cp -R build/ios/framework/Debug/*.xcframework ios/Frameworks/

# Hoặc Release frameworks
cp -R build/ios/framework/Release/*.xcframework ios/Frameworks/
```

**2. Trong Xcode:**

- Open project settings
- Select target
- Go to **"General" > "Frameworks, Libraries, and Embedded Content"**
- Click **"+"** và add tất cả `.xcframework` files
- Set to **"Embed & Sign"**

**3. Add Build Phase:**

- Go to **"Build Phases"**
- Click **"+"** > **"New Run Script Phase"**
- Add script:

```bash
"$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh" embed_and_thin
```

---

### **Bước 3: Khởi chạy Flutter từ Native Code**

#### **Swift Example:**

```swift
import UIKit
import Flutter

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func showFlutter(_ sender: Any) {
        let flutterEngine = (UIApplication.shared.delegate as! AppDelegate).flutterEngine
        let flutterViewController = FlutterViewController(
            engine: flutterEngine,
            nibName: nil,
            bundle: nil
        )
        
        present(flutterViewController, animated: true, completion: nil)
    }
}
```

#### **AppDelegate.swift:**

```swift
import UIKit
import Flutter

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
    lazy var flutterEngine = FlutterEngine(name: "my flutter engine")
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Khởi tạo Flutter engine
        flutterEngine.run()
        
        // Optional: Khởi tạo với route cụ thể
        // flutterEngine.run(withEntrypoint: nil, initialRoute: "/home")
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

---

## 🔧 **Các Lệnh Hữu Ích**

### **Build Commands:**

```bash
# Build tất cả configurations (Debug, Profile, Release)
flutter build ios-framework

# Build chỉ Debug
flutter build ios-framework --debug

# Build chỉ Release
flutter build ios-framework --release

# Build với output path tùy chỉnh
flutter build ios-framework --output=./ios/Flutter/Frameworks

# Build với xcconfig tùy chỉnh
flutter build ios-framework --xcconfig=./ios/Flutter/CustomConfig.xcconfig
```

### **Clean & Rebuild:**

```bash
# Clean build cache
flutter clean

# Get dependencies
flutter pub get

# Rebuild frameworks
flutter build ios-framework
```

### **Check Flutter Doctor:**

```bash
flutter doctor -v
```

---

## 📁 **Cấu trúc Project**

```
flutter_module/
├── lib/                          # Flutter code
│   ├── main.dart
│   └── ...
├── .ios/                         # Hidden iOS config (auto-generated)
│   └── Flutter/
│       ├── Generated.xcconfig
│       └── FlutterPluginRegistrant/
├── build/
│   └── ios/
│       └── framework/            # Built frameworks
│           ├── Debug/
│           │   ├── Flutter.xcframework
│           │   ├── App.xcframework
│           │   └── [plugins].xcframework
│           ├── Profile/
│           └── Release/
├── pubspec.yaml                  # Dependencies
└── README.md
```

---

## ⚠️ **Common Issues & Solutions**

### **Issue 1: "Expected ios/Runner.xcodeproj but this file is missing"**

**Cause:** Đang cố chạy `flutter run` trên Flutter Module.

**Solution:** 
- ❌ KHÔNG dùng `flutter run`
- ✅ Dùng `flutter build ios-framework`
- ✅ Embed frameworks vào native iOS app

---

### **Issue 2: "Cannot open file AppFrameworkInfo.plist"**

**Cause:** `.ios` folder chưa được generate hoặc bị corrupt.

**Solution:**
```bash
flutter clean
flutter pub get
flutter build ios-framework
```

---

### **Issue 3: "unable to find directory entry: assets/images/"**

**Cause:** `pubspec.yaml` reference folder không tồn tại.

**Solution:**
```bash
mkdir -p assets/images
```

Hoặc remove khỏi `pubspec.yaml` nếu không cần:
```yaml
flutter:
  # assets:
  #   - assets/images/  # Comment out nếu không dùng
```

---

### **Issue 4: Build fails với CocoaPods errors**

**Solution:**
```bash
cd .ios
pod deintegrate
pod install
cd ..
flutter build ios-framework
```

---

## 🚀 **Testing Flutter Module**

### **Option 1: Tạo Host App (Recommended)**

```bash
# Tạo iOS host app để test
flutter make-host-app-editable ios

# Sau đó có thể chạy:
flutter run
```

**Lưu ý:** Command này sẽ tạo `ios/` folder (không phải `.ios/`) để test.

---

### **Option 2: Integrate vào Existing iOS App**

1. Build frameworks: `flutter build ios-framework`
2. Copy frameworks vào iOS project
3. Configure Xcode như hướng dẫn ở trên
4. Run iOS app từ Xcode

---

## 📚 **Tài liệu tham khảo**

- **Flutter Add-to-App**: https://docs.flutter.dev/add-to-app/ios
- **iOS Framework Integration**: https://docs.flutter.dev/add-to-app/ios/project-setup
- **Flutter Module Setup**: https://docs.flutter.dev/add-to-app/ios/add-flutter-screen

---

## ✅ **Summary**

### **Để build Flutter Module cho iOS:**

1. ✅ **KHÔNG** chạy `flutter run` (sẽ lỗi)
2. ✅ Chạy `flutter build ios-framework`
3. ✅ Frameworks được tạo trong `build/ios/framework/`
4. ✅ Embed frameworks vào native iOS app
5. ✅ Khởi chạy Flutter từ native code

### **Current Build Status:**

```
✅ Frameworks built successfully!
✅ Location: build/ios/framework/
✅ Configurations: Debug, Profile, Release
✅ Ready to integrate into iOS app
```

---

## 🎯 **Next Steps**

1. **Nếu bạn có native iOS app:**
   - Copy frameworks từ `build/ios/framework/Release/`
   - Integrate vào iOS project
   - Follow integration guide ở trên

2. **Nếu muốn test standalone:**
   - Run `flutter make-host-app-editable ios`
   - Sau đó có thể `flutter run`

3. **Nếu cần update code:**
   - Sửa code trong `lib/`
   - Run `flutter build ios-framework` lại
   - Update frameworks trong iOS app

---

**Flutter Module của bạn đã build thành công!** 🎉

Frameworks nằm ở: `/Users/mac/Documents/Flutter/Projects/flutter_module/build/ios/framework/`


