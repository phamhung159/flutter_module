# Native iOS Integration Guide

## 🚨 Problem: MissingPluginException

When embedding Flutter module in native iOS app, you get:
```
MissingPluginException(No implementation found for method apiLog on channel tuicall_kit)
PlatformException(channel-error, Unable to establish connection on channel...)
```

**Root Cause:** Plugins are not registered with the FlutterEngine.

---

## ✅ Solution: Register Plugins in Native iOS

### Step 1: Update Podfile in Native iOS App

Add the Flutter module and its plugins to your native iOS app's `Podfile`:

```ruby
# Add at the beginning of your Podfile
flutter_application_path = '../flutter_module'  # Path to Flutter module
load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')

target 'YourNativeApp' do
  use_frameworks!
  
  # Install Flutter pods
  install_all_flutter_pods(flutter_application_path)
  
  # Your other pods...
end

post_install do |installer|
  flutter_post_install(installer)
  
  # Your other post_install configurations...
end
```

### Step 2: Register Plugins with FlutterEngine

In your native iOS code where you create the FlutterEngine, register plugins:

#### Option A: Using AppDelegate (Recommended)

**AppDelegate.swift:**
```swift
import UIKit
import Flutter
import FlutterPluginRegistrant  // ← Add this import

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
    lazy var flutterEngine = FlutterEngine(name: "flutter_module_engine")
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Start the Flutter engine
        flutterEngine.run()
        
        // ⚠️ CRITICAL: Register all plugins with the engine
        GeneratedPluginRegistrant.register(with: self.flutterEngine)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

#### Option B: Using FlutterEngineGroup (For Multiple Engines)

**AppDelegate.swift:**
```swift
import UIKit
import Flutter
import FlutterPluginRegistrant

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var engineGroup = FlutterEngineGroup(name: "flutter_engines", project: nil)
    var flutterEngine: FlutterEngine?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Create engine from group
        flutterEngine = engineGroup.makeEngine(withEntrypoint: nil, libraryURI: nil)
        
        // ⚠️ CRITICAL: Register plugins
        if let engine = flutterEngine {
            GeneratedPluginRegistrant.register(with: engine)
            engine.run()
        }
        
        return true
    }
}
```

### Step 3: Show Flutter View Controller

When presenting the Flutter module:

```swift
import Flutter

class ViewController: UIViewController {
    @IBAction func showFlutterModule(_ sender: Any) {
        // Get the FlutterEngine from AppDelegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let flutterViewController = FlutterViewController(
            engine: appDelegate.flutterEngine,
            nibName: nil,
            bundle: nil
        )
        
        // Present the Flutter view
        flutterViewController.modalPresentationStyle = .fullScreen
        present(flutterViewController, animated: true)
    }
}
```

---

## 📦 Complete Example: Native iOS Project Setup

### 1. Podfile (Native iOS App)

```ruby
platform :ios, '13.0'

# Path to your Flutter module
flutter_application_path = '../flutter_module'
load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')

target 'MyNativeApp' do
  use_frameworks! :linkage => :static  # Required for Xcode 16
  
  # Install all Flutter pods including plugins
  install_all_flutter_pods(flutter_application_path)
end

post_install do |installer|
  flutter_post_install(installer)
  
  # Xcode 16 Swift compatibility fix (copy from flutter_module if needed)
  xcode_swift_libs = '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift'
  
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '5.0'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
```

### 2. AppDelegate.swift

```swift
import UIKit
import Flutter
import FlutterPluginRegistrant

@main
class AppDelegate: FlutterAppDelegate {
    lazy var flutterEngine: FlutterEngine = {
        let engine = FlutterEngine(name: "flutter_module_engine")
        engine.run()
        // ⚠️ Register all plugins
        GeneratedPluginRegistrant.register(with: engine)
        return engine
    }()
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Engine is lazily initialized when first accessed
        _ = flutterEngine
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

### 3. ViewController.swift

```swift
import UIKit
import Flutter

class ViewController: UIViewController {
    
    @IBAction func openFlutterModule(_ sender: UIButton) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Error: Could not get AppDelegate")
            return
        }
        
        let flutterVC = FlutterViewController(
            engine: appDelegate.flutterEngine,
            nibName: nil,
            bundle: nil
        )
        
        // Optional: Set initial route
        // flutterVC.setInitialRoute("/login")
        
        flutterVC.modalPresentationStyle = .fullScreen
        present(flutterVC, animated: true)
    }
    
    // Navigate to specific route
    func openFlutterRoute(_ route: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let flutterVC = FlutterViewController(
            engine: appDelegate.flutterEngine,
            nibName: nil,
            bundle: nil
        )
        
        // Push a new route
        appDelegate.flutterEngine.navigationChannel.invokeMethod(
            "pushRoute",
            arguments: route
        )
        
        flutterVC.modalPresentationStyle = .fullScreen
        present(flutterVC, animated: true)
    }
}
```

---

## 🔧 Troubleshooting

### Error: "GeneratedPluginRegistrant not found"

**Fix:** Import the FlutterPluginRegistrant module:
```swift
import FlutterPluginRegistrant
```

Make sure your Podfile includes:
```ruby
install_all_flutter_pods(flutter_application_path)
```

### Error: "Unable to establish connection on channel"

**Fix:** Make sure plugins are registered BEFORE any Flutter code runs:
```swift
// ✅ Correct order
engine.run()
GeneratedPluginRegistrant.register(with: engine)

// ❌ Wrong - this will fail
GeneratedPluginRegistrant.register(with: engine)
engine.run()  // Plugins registered too late!
```

### Error: "MissingPluginException" persists

**Fix:** 
1. Clean and rebuild:
   ```bash
   # In Flutter module
   ./clean_and_fix.sh
   
   # In native iOS app
   cd ios
   pod deintegrate
   pod install
   ```

2. Verify GeneratedPluginRegistrant.m includes all plugins:
   ```bash
   cat flutter_module/.ios/Flutter/FlutterPluginRegistrant/Classes/GeneratedPluginRegistrant.m
   ```

### Error: Swift compatibility issues

**Fix:** Apply the Xcode 16 fix in your native iOS Podfile:
```ruby
post_install do |installer|
  flutter_post_install(installer)
  
  # Add Swift compatibility fix
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '5.0'
    end
  end
end
```

---

## 📋 Checklist

Before running the native iOS app:

- [ ] Flutter module built: `flutter build ios-framework`
- [ ] Podfile updated with `install_all_flutter_pods()`
- [ ] `pod install` run successfully
- [ ] `import FlutterPluginRegistrant` added to AppDelegate
- [ ] `GeneratedPluginRegistrant.register(with: engine)` called
- [ ] Engine started with `engine.run()`
- [ ] No compiler errors

---

## 🔗 References

- [Add-to-app iOS documentation](https://docs.flutter.dev/add-to-app/ios/project-setup)
- [Flutter plugins in add-to-app](https://docs.flutter.dev/add-to-app/ios/add-flutter-screen#using-the-flutterengine)
- [FlutterPluginRegistrant](https://api.flutter.dev/objcdoc/Protocols/FlutterPluginRegistrant.html)

---

## 📞 Quick Fix Summary

**In your native iOS app's AppDelegate.swift:**

```swift
import FlutterPluginRegistrant  // ← Add this

// In didFinishLaunchingWithOptions:
flutterEngine.run()
GeneratedPluginRegistrant.register(with: self.flutterEngine)  // ← Add this
```

**That's it!** Plugins will now work correctly.

