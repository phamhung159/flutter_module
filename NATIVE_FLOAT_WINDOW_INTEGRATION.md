# Native Float Window Integration Guide

Hướng dẫn tích hợp Native iOS Floating Window để hiển thị Picture-in-Picture call khi quay về native app.

## Overview

Khi user ở trong Flutter module và click nút Float Window:
1. Flutter gửi message qua platform channel `flutter_module/float_window`
2. Native iOS tạo floating UIWindow hiển thị mini call view
3. Float window tồn tại trên tất cả screens (cả native và Flutter)
4. Khi user tap float window → quay lại Flutter module với InCallDemoScreen

## iOS Native Implementation

### 1. Tạo FloatWindowManager.swift

```swift
import UIKit
import Flutter

class FloatWindowManager: NSObject {
    static let shared = FloatWindowManager()
    
    private var floatWindow: UIWindow?
    private var floatViewController: FloatCallViewController?
    private var methodChannel: FlutterMethodChannel?
    
    private override init() {
        super.init()
    }
    
    // MARK: - Setup
    
    func setup(with flutterEngine: FlutterEngine) {
        methodChannel = FlutterMethodChannel(
            name: "flutter_module/float_window",
            binaryMessenger: flutterEngine.binaryMessenger
        )
        
        methodChannel?.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }
    }
    
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "showFloatWindow":
            guard let args = call.arguments as? [String: Any],
                  let userId = args["userId"] as? String,
                  let duration = args["duration"] as? Int,
                  let isVideo = args["isVideo"] as? Bool else {
                result(false)
                return
            }
            showFloatWindow(userId: userId, duration: duration, isVideo: isVideo)
            result(true)
            
        case "hideFloatWindow":
            hideFloatWindow()
            result(true)
            
        case "updateFloatWindow":
            if let args = call.arguments as? [String: Any] {
                updateFloatWindow(
                    duration: args["duration"] as? Int,
                    status: args["status"] as? String
                )
            }
            result(nil)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Float Window Management
    
    func showFloatWindow(userId: String, duration: Int, isVideo: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Remove existing float window if any
            self.hideFloatWindow()
            
            // Create float window
            let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
            
            guard let scene = windowScene else { return }
            
            let window = UIWindow(windowScene: scene)
            window.windowLevel = .alert + 1 // Above all other windows
            window.backgroundColor = .clear
            
            // Set initial frame (bottom right corner)
            let screenBounds = UIScreen.main.bounds
            let floatSize = CGSize(width: 120, height: 160)
            window.frame = CGRect(
                x: screenBounds.width - floatSize.width - 16,
                y: screenBounds.height - floatSize.height - 100,
                width: floatSize.width,
                height: floatSize.height
            )
            
            // Create float view controller
            let floatVC = FloatCallViewController()
            floatVC.userId = userId
            floatVC.duration = duration
            floatVC.isVideo = isVideo
            floatVC.onTap = { [weak self] in
                self?.onFloatWindowTapped()
            }
            floatVC.onClose = { [weak self] in
                self?.onFloatWindowClosed()
            }
            
            window.rootViewController = floatVC
            window.isHidden = false
            
            self.floatWindow = window
            self.floatViewController = floatVC
            
            // Add pan gesture for dragging
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
            window.addGestureRecognizer(panGesture)
        }
    }
    
    func hideFloatWindow() {
        DispatchQueue.main.async { [weak self] in
            self?.floatWindow?.isHidden = true
            self?.floatWindow = nil
            self?.floatViewController = nil
        }
    }
    
    func updateFloatWindow(duration: Int?, status: String?) {
        DispatchQueue.main.async { [weak self] in
            if let duration = duration {
                self?.floatViewController?.duration = duration
            }
            if let status = status {
                self?.floatViewController?.status = status
            }
        }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let window = floatWindow else { return }
        
        let translation = gesture.translation(in: window)
        
        switch gesture.state {
        case .changed:
            var newFrame = window.frame
            newFrame.origin.x += translation.x
            newFrame.origin.y += translation.y
            
            // Keep within screen bounds
            let screenBounds = UIScreen.main.bounds
            newFrame.origin.x = max(0, min(screenBounds.width - newFrame.width, newFrame.origin.x))
            newFrame.origin.y = max(50, min(screenBounds.height - newFrame.height - 50, newFrame.origin.y))
            
            window.frame = newFrame
            gesture.setTranslation(.zero, in: window)
            
        case .ended:
            // Snap to nearest edge
            snapToEdge()
            
        default:
            break
        }
    }
    
    private func snapToEdge() {
        guard let window = floatWindow else { return }
        
        let screenBounds = UIScreen.main.bounds
        let center = window.center
        
        UIView.animate(withDuration: 0.3) {
            var newFrame = window.frame
            if center.x < screenBounds.width / 2 {
                // Snap to left
                newFrame.origin.x = 16
            } else {
                // Snap to right
                newFrame.origin.x = screenBounds.width - newFrame.width - 16
            }
            window.frame = newFrame
        }
    }
    
    // MARK: - Callbacks to Flutter
    
    private func onFloatWindowTapped() {
        hideFloatWindow()
        methodChannel?.invokeMethod("onFloatWindowTapped", arguments: nil)
        
        // Re-open Flutter module with InCallDemoScreen
        // This depends on your app architecture
        NotificationCenter.default.post(
            name: NSNotification.Name("OpenFlutterInCallScreen"),
            object: nil
        )
    }
    
    private func onFloatWindowClosed() {
        hideFloatWindow()
        methodChannel?.invokeMethod("onFloatWindowClosed", arguments: nil)
    }
}
```

### 2. Tạo FloatCallViewController.swift

```swift
import UIKit

class FloatCallViewController: UIViewController {
    
    var userId: String = ""
    var duration: Int = 0 {
        didSet {
            updateDurationLabel()
        }
    }
    var isVideo: Bool = true
    var status: String = "Connected" {
        didSet {
            statusLabel.text = status
        }
    }
    
    var onTap: (() -> Void)?
    var onClose: (() -> Void)?
    
    private let containerView = UIView()
    private let avatarView = UIView()
    private let avatarLabel = UILabel()
    private let nameLabel = UILabel()
    private let durationLabel = UILabel()
    private let statusLabel = UILabel()
    private let closeButton = UIButton()
    
    private var durationTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startDurationTimer()
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        // Container with rounded corners and shadow
        containerView.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0)
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOpacity = 0.3
        containerView.clipsToBounds = false
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Avatar
        avatarView.backgroundColor = UIColor(red: 0.4, green: 0.3, blue: 0.6, alpha: 1.0)
        avatarView.layer.cornerRadius = 25
        containerView.addSubview(avatarView)
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        
        avatarLabel.text = String(userId.prefix(1)).uppercased()
        avatarLabel.textColor = .white
        avatarLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        avatarLabel.textAlignment = .center
        avatarView.addSubview(avatarLabel)
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            avatarView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            avatarView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            avatarView.widthAnchor.constraint(equalToConstant: 50),
            avatarView.heightAnchor.constraint(equalToConstant: 50),
            
            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor)
        ])
        
        // Name label
        nameLabel.text = userId
        nameLabel.textColor = .white
        nameLabel.font = .systemFont(ofSize: 12, weight: .medium)
        nameLabel.textAlignment = .center
        containerView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8)
        ])
        
        // Duration label
        durationLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        durationLabel.font = .monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        durationLabel.textAlignment = .center
        updateDurationLabel()
        containerView.addSubview(durationLabel)
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            durationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            durationLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        // Close button
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = UIColor.red.withAlphaComponent(0.8)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        containerView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // Tap gesture for container
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(containerTapped))
        containerView.addGestureRecognizer(tapGesture)
    }
    
    private func startDurationTimer() {
        durationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.duration += 1
        }
    }
    
    private func updateDurationLabel() {
        let minutes = duration / 60
        let seconds = duration % 60
        durationLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    @objc private func containerTapped() {
        onTap?()
    }
    
    @objc private func closeTapped() {
        onClose?()
    }
    
    deinit {
        durationTimer?.invalidate()
    }
}
```

### 3. Setup trong AppDelegate.swift

```swift
import UIKit
import Flutter
import FlutterPluginRegistrant

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var flutterEngine: FlutterEngine?
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Setup Flutter engine
        flutterEngine = FlutterEngine(name: "flutter_engine")
        flutterEngine?.run()
        
        if let engine = flutterEngine {
            GeneratedPluginRegistrant.register(with: engine)
            
            // Setup FloatWindowManager with Flutter engine
            FloatWindowManager.shared.setup(with: engine)
        }
        
        // Listen for notification to re-open Flutter InCallScreen
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(openFlutterInCallScreen),
            name: NSNotification.Name("OpenFlutterInCallScreen"),
            object: nil
        )
        
        return true
    }
    
    @objc func openFlutterInCallScreen() {
        guard let engine = flutterEngine else { return }
        
        let flutterVC = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
        
        // Send message to Flutter to navigate to InCallDemoScreen
        let channel = FlutterMethodChannel(
            name: "flutter_module/navigation",
            binaryMessenger: engine.binaryMessenger
        )
        channel.invokeMethod("navigateToInCallScreen", arguments: nil)
        
        // Present Flutter VC
        if let topVC = UIApplication.shared.topViewController() {
            topVC.present(flutterVC, animated: true)
        }
    }
}

// Helper extension to get top view controller
extension UIApplication {
    func topViewController(_ base: UIViewController? = nil) -> UIViewController? {
        let base = base ?? UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
        
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(selected)
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}
```

### 4. Handle Navigation trong Flutter

Thêm navigation channel handler trong Flutter để navigate khi user tap float window:

```dart
// Trong main.dart hoặc app initialization
import 'package:flutter/services.dart';

void setupNavigationChannel() {
  const channel = MethodChannel('flutter_module/navigation');
  
  channel.setMethodCallHandler((call) async {
    if (call.method == 'navigateToInCallScreen') {
      // Navigate to InCallDemoScreen
      // This requires access to navigator context
      // You may need to use a global navigator key
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => InCallDemoScreen(
            remoteUserId: CallEngineManager().currentCallerId ?? '',
            mediaType: CallEngineManager().currentMediaType,
          ),
        ),
      );
    }
  });
}
```

## Architecture Flow

```
┌──────────────────────────────────────────────────────────────────┐
│                        Flutter Module                             │
├──────────────────────────────────────────────────────────────────┤
│  InCallDemoScreen                                                 │
│       │                                                           │
│       ▼ [Click Float Button]                                      │
│  NativeFloatWindowChannel.showFloatWindow()                       │
│       │                                                           │
│       ▼ (Platform Channel: flutter_module/float_window)           │
└───────┼──────────────────────────────────────────────────────────┘
        │
        ▼
┌──────────────────────────────────────────────────────────────────┐
│                      Native iOS App                               │
├──────────────────────────────────────────────────────────────────┤
│  FloatWindowManager                                               │
│       │                                                           │
│       ▼ [Create UIWindow with .alert+1 windowLevel]               │
│  FloatCallViewController                                          │
│       │                                                           │
│       │ ◄──── [Float window visible on ALL screens]               │
│       │                                                           │
│       ▼ [User taps float window]                                  │
│  onFloatWindowTapped()                                            │
│       │                                                           │
│       ▼ (Post Notification: OpenFlutterInCallScreen)              │
│       │                                                           │
│       ▼ (Platform Channel: flutter_module/navigation)             │
└───────┼──────────────────────────────────────────────────────────┘
        │
        ▼
┌──────────────────────────────────────────────────────────────────┐
│                        Flutter Module                             │
├──────────────────────────────────────────────────────────────────┤
│  Navigate to InCallDemoScreen (call still active)                 │
└──────────────────────────────────────────────────────────────────┘
```

## Key Points

1. **UIWindow với windowLevel cao**: Float window sử dụng `UIWindow.Level.alert + 1` để hiển thị trên tất cả windows khác, kể cả khi navigate giữa native screens.

2. **Call state giữ nguyên**: `CallEngineManager` vẫn giữ call state, duration counter, và video streams khi float window hiển thị.

3. **Draggable**: Float window có thể kéo di chuyển và snap vào cạnh màn hình.

4. **Fallback**: Nếu native không implement float window, Flutter sẽ fallback về Flutter Overlay (chỉ hoạt động trong Flutter screens).

## Testing

1. Build native iOS app với FloatWindowManager
2. Chạy Flutter module, make call
3. Click Float Window button
4. Verify: Native float window xuất hiện
5. Navigate về native screen
6. Verify: Float window vẫn hiển thị
7. Tap float window
8. Verify: Quay lại Flutter InCallDemoScreen với call đang chạy


