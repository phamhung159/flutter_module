import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Service to communicate with Native iOS Float Window for Picture-in-Picture call display.
/// 
/// This allows the call to continue displaying in a small floating window
/// even when the user navigates back to native iOS screens.
class NativeFloatWindowService {
  static const _channel = MethodChannel('flutter_module/float_window');
  
  static final NativeFloatWindowService _instance = NativeFloatWindowService._internal();
  factory NativeFloatWindowService() => _instance;
  NativeFloatWindowService._internal() {
    _setupMethodCallHandler();
  }
  
  // Stream controllers for events from native
  final _onFloatWindowTappedController = StreamController<FloatWindowTapEvent>.broadcast();
  final _onFloatWindowClosedController = StreamController<void>.broadcast();
  
  /// Stream of events when float window is tapped (user wants to return to call)
  Stream<FloatWindowTapEvent> get onFloatWindowTapped => _onFloatWindowTappedController.stream;
  
  /// Stream of events when float window is closed (user ended call from float window)
  Stream<void> get onFloatWindowClosed => _onFloatWindowClosedController.stream;
  
  void _setupMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onFloatWindowTapped':
          final args = call.arguments as Map<dynamic, dynamic>?;
          _onFloatWindowTappedController.add(FloatWindowTapEvent(
            userId: args?['userId'] as String? ?? '',
            duration: args?['duration'] as int? ?? 0,
            isVideo: args?['isVideo'] as bool? ?? false,
          ));
          break;
        case 'onFloatWindowClosed':
          _onFloatWindowClosedController.add(null);
          break;
        default:
          debugPrint('⚠️ Unknown method from native: ${call.method}');
      }
    });
  }
  
  /// Show float window with call information.
  /// 
  /// [userId] - The remote user ID in the call
  /// [duration] - Current call duration in seconds
  /// [isVideo] - Whether this is a video call
  /// [avatarUrl] - Optional avatar URL for the remote user
  Future<bool> showFloatWindow({
    required String userId,
    int duration = 0,
    bool isVideo = false,
    String? avatarUrl,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('showFloatWindow', {
        'userId': userId,
        'duration': duration,
        'isVideo': isVideo,
        'avatarUrl': avatarUrl,
      });
      debugPrint('🖼️ Show float window: $result');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('❌ Failed to show float window: ${e.message}');
      return false;
    }
  }
  
  /// Hide the float window.
  Future<bool> hideFloatWindow() async {
    try {
      final result = await _channel.invokeMethod<bool>('hideFloatWindow');
      debugPrint('🖼️ Hide float window: $result');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('❌ Failed to hide float window: ${e.message}');
      return false;
    }
  }
  
  /// Update the float window with new information.
  /// 
  /// [duration] - Updated call duration in seconds
  /// [status] - Status text (e.g., "Connected", "On Hold")
  /// [isMuted] - Whether the call is muted
  /// [isSpeakerOn] - Whether speaker is on
  Future<void> updateFloatWindow({
    int? duration,
    String? status,
    bool? isMuted,
    bool? isSpeakerOn,
  }) async {
    try {
      await _channel.invokeMethod('updateFloatWindow', {
        if (duration != null) 'duration': duration,
        if (status != null) 'status': status,
        if (isMuted != null) 'isMuted': isMuted,
        if (isSpeakerOn != null) 'isSpeakerOn': isSpeakerOn,
      });
    } on PlatformException catch (e) {
      debugPrint('❌ Failed to update float window: ${e.message}');
    }
  }
  
  /// Check if float window is currently visible.
  Future<bool> isFloatWindowVisible() async {
    try {
      final result = await _channel.invokeMethod<bool>('isFloatWindowVisible');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('❌ Failed to check float window visibility: ${e.message}');
      return false;
    }
  }
  
  /// Dispose of the service and clean up resources.
  void dispose() {
    _onFloatWindowTappedController.close();
    _onFloatWindowClosedController.close();
  }
}

/// Event data when float window is tapped.
class FloatWindowTapEvent {
  final String userId;
  final int duration;
  final bool isVideo;
  
  FloatWindowTapEvent({
    required this.userId,
    required this.duration,
    required this.isVideo,
  });
  
  @override
  String toString() => 'FloatWindowTapEvent(userId: $userId, duration: $duration, isVideo: $isVideo)';
}

