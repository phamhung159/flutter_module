import 'dart:async';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:tencent_calls_uikit/tencent_calls_uikit.dart';

@lazySingleton
class TencentCallService {
  final StreamController<TencentCallEvent> _eventController =
      StreamController.broadcast();

  Stream<TencentCallEvent> get eventStream => _eventController.stream;

  bool _isInitialized = false;

  Future<void> initialize({
    required int sdkAppId,
    required String userId,
    required String userSig,
  }) async {
    if (_isInitialized) {
      debugPrint('⚠️ TencentCallService already initialized');
      return;
    }

    try {
      debugPrint('🚀 Initializing Tencent Calls UIKit...');
      debugPrint('   SDKAppID: $sdkAppId');
      debugPrint('   UserID: $userId');

      await TUICallKit.instance.login(sdkAppId, userId, userSig);

      debugPrint('✅ Tencent login successful');
      _isInitialized = true;
      _eventController.add(const TencentCallEvent.initialized());

      _setupCallObserver();
    } catch (e) {
      debugPrint('❌ Failed to initialize Tencent: $e');
      _eventController.add(TencentCallEvent.error(-1, e.toString()));
    }
  }

  void _setupCallObserver() {
    debugPrint('📞 Setting up Tencent call observer...');

    TUICallEngine.instance.addObserver(
      TUICallObserver(
        onError: (code, message) {
          debugPrint('❌ Tencent call error: $code - $message');
          _eventController.add(TencentCallEvent.error(code, message));
        },

        onCallReceived:
            (callerId, calleeIdList, groupId, callMediaType, userData) {
              debugPrint('📞 Call received from: $callerId');
              debugPrint('   Call type: ${callMediaType.name}');
              debugPrint('   Group ID: $groupId');

              final isVideo = callMediaType == TUICallMediaType.video;
              _eventController.add(
                TencentCallEvent.callReceived(
                  callerId: callerId,
                  isVideo: isVideo,
                ),
              );
            },

        onCallCancelled: (callerId) {
          debugPrint('📞 Call cancelled by: $callerId');
          _eventController.add(TencentCallEvent.callCancelled(callerId));
        },

        onCallBegin: (roomId, callMediaType, callRole) {
          debugPrint('📞 Call began in room: ${roomId.intRoomId}');
          debugPrint('   Role: ${callRole.name}');
          _eventController.add(const TencentCallEvent.callBegan());
        },

        onCallEnd: (roomId, callMediaType, callRole, totalTime) {
          debugPrint('📞 Call ended. Duration: $totalTime seconds');
          _eventController.add(TencentCallEvent.callEnded(totalTime.toInt()));
        },

        onUserReject: (userId) {
          debugPrint('📞 User rejected: $userId');
          _eventController.add(TencentCallEvent.userRejected(userId));
        },

        onUserNoResponse: (userId) {
          debugPrint('📞 User no response: $userId');
          _eventController.add(TencentCallEvent.userNoResponse(userId));
        },

        onUserLineBusy: (userId) {
          debugPrint('📞 User line busy: $userId');
          _eventController.add(TencentCallEvent.userBusy(userId));
        },

        onUserJoin: (userId) {
          debugPrint('📞 User joined: $userId');
          _eventController.add(TencentCallEvent.userJoined(userId));
        },

        onUserLeave: (userId) {
          debugPrint('📞 User left: $userId');
          _eventController.add(TencentCallEvent.userLeft(userId));
        },

        onUserVideoAvailable: (userId, isVideoAvailable) {
          debugPrint('📞 User video available: $userId - $isVideoAvailable');
          _eventController.add(
            TencentCallEvent.videoAvailable(userId, isVideoAvailable),
          );
        },

        onUserAudioAvailable: (userId, isAudioAvailable) {
          debugPrint('📞 User audio available: $userId - $isAudioAvailable');
          _eventController.add(
            TencentCallEvent.audioAvailable(userId, isAudioAvailable),
          );
        },

      ),
    );

    debugPrint('✅ Tencent call observer setup complete');
  }

  Future<void> call({required String userId, required bool isVideo}) async {
    if (!_isInitialized) {
      debugPrint('⚠️ TencentCallService chưa được khởi tạo');
      _eventController.add(
        TencentCallEvent.error(-1, 'Service not initialized'),
      );
      return;
    }

    try {
      debugPrint('📞 Đang gọi ${isVideo ? "video" : "audio"} đến $userId...');

      final callMediaType = isVideo
          ? TUICallMediaType.video
          : TUICallMediaType.audio;

      await TUICallKit.instance.calls([userId], callMediaType);

      debugPrint('✅ Call initiated successfully to $userId');
      _eventController.add(const TencentCallEvent.callBegan());
    } catch (e) {
      debugPrint('❌ Exception when making call: $e');
      _eventController.add(TencentCallEvent.error(-1, e.toString()));
    }
  }

  Future<void> acceptCall() async {
    if (!_isInitialized) {
      debugPrint('⚠️ TencentCallService chưa được khởi tạo');
      return;
    }

    try {
      debugPrint('📞 Đang chấp nhận cuộc gọi...');

      await TUICallEngine.instance.accept();

      debugPrint('✅ Call accepted successfully');
      _eventController.add(const TencentCallEvent.callBegan());
    } catch (e) {
      debugPrint('❌ Exception when accepting call: $e');
      _eventController.add(TencentCallEvent.error(-1, e.toString()));
    }
  }

  Future<void> rejectCall() async {
    if (!_isInitialized) {
      debugPrint('⚠️ TencentCallService chưa được khởi tạo');
      return;
    }

    try {
      debugPrint('📞 Đang từ chối cuộc gọi...');

      await TUICallEngine.instance.reject();

      debugPrint('✅ Call rejected successfully');
    } catch (e) {
      debugPrint('❌ Exception when rejecting call: $e');
      _eventController.add(TencentCallEvent.error(-1, e.toString()));
    }
  }

  Future<void> hangup() async {
    if (!_isInitialized) {
      debugPrint('⚠️ TencentCallService chưa được khởi tạo');
      return;
    }

    try {
      debugPrint('📞 Đang kết thúc cuộc gọi...');

      await TUICallEngine.instance.hangup();

      debugPrint('✅ Call ended successfully');
    } catch (e) {
      debugPrint('❌ Exception when ending call: $e');
      _eventController.add(TencentCallEvent.error(-1, e.toString()));
    }
  }

  Future<void> groupCall({
    required String groupId,
    required List<String> userIds,
    required bool isVideo,
  }) async {
    if (!_isInitialized) {
      debugPrint('⚠️ TencentCallService chưa được khởi tạo');
      _eventController.add(
        TencentCallEvent.error(-1, 'Service not initialized'),
      );
      return;
    }

    try {
      debugPrint('📞 Đang gọi nhóm $groupId với ${userIds.length} users...');
      debugPrint('   Users: $userIds');

      final callMediaType = isVideo
          ? TUICallMediaType.video
          : TUICallMediaType.audio;

      await TUICallKit.instance.calls(userIds, callMediaType);

      debugPrint('✅ Group call initiated successfully');
      _eventController.add(const TencentCallEvent.callBegan());
    } catch (e) {
      debugPrint('❌ Exception when making group call: $e');
      _eventController.add(TencentCallEvent.error(-1, e.toString()));
    }
  }

  Future<void> switchCamera() async {
    if (!_isInitialized) {
      debugPrint('⚠️ TencentCallService chưa được khởi tạo');
      return;
    }

    try {
      debugPrint('📷 Đang chuyển đổi camera...');

      await TUICallEngine.instance.switchCamera(
        TUICamera.front,
      );

      debugPrint('✅ Camera switched successfully');
    } catch (e) {
      debugPrint('❌ Failed to switch camera: $e');
    }
  }

  Future<void> setMicMute(bool isMute) async {
    if (!_isInitialized) {
      debugPrint('⚠️ TencentCallService chưa được khởi tạo');
      return;
    }

    try {
      debugPrint('🎤 ${isMute ? "Tắt" : "Bật"} microphone...');

      await TUICallEngine.instance.closeMicrophone();

      debugPrint('✅ Microphone ${isMute ? "muted" : "unmuted"}');
    } catch (e) {
      debugPrint('❌ Failed to set mic mute: $e');
    }
  }

  Future<void> setVideoMute(bool isMute) async {
    if (!_isInitialized) {
      debugPrint('⚠️ TencentCallService chưa được khởi tạo');
      return;
    }

    try {
      debugPrint('📷 ${isMute ? "Tắt" : "Bật"} camera...');

      if (isMute) {
        await TUICallEngine.instance.closeCamera();
      } else {
        await TUICallEngine.instance.openCamera(
          TUICamera.front,
          0,
        );
      }

      debugPrint('✅ Camera ${isMute ? "disabled" : "enabled"}');
    } catch (e) {
      debugPrint('❌ Failed to set video mute: $e');
    }
  }

  Future<void> setSpeaker(bool useSpeaker) async {
    if (!_isInitialized) {
      debugPrint('⚠️ TencentCallService chưa được khởi tạo');
      return;
    }

    try {
      debugPrint('🔊 ${useSpeaker ? "Bật" : "Tắt"} loa ngoài...');

      await TUICallEngine.instance.selectAudioPlaybackDevice(
        useSpeaker
            ? TUIAudioPlaybackDevice.speakerphone
            : TUIAudioPlaybackDevice.earpiece,
      );

      debugPrint('✅ Speaker ${useSpeaker ? "enabled" : "disabled"}');
    } catch (e) {
      debugPrint('❌ Failed to set speaker: $e');
    }
  }

  Future<void> logout() async {
    if (!_isInitialized) {
      return;
    }

    try {
      debugPrint('👋 Đang logout khỏi Tencent...');

      await TUICallKit.instance.logout();

      debugPrint('✅ Logout successful');
      _isInitialized = false;
    } catch (e) {
      debugPrint('❌ Exception during logout: $e');
    }
  }

  void dispose() {
    _eventController.close();
  }
}

sealed class TencentCallEvent {
  const TencentCallEvent();

  const factory TencentCallEvent.initialized() = TencentInitialized;
  const factory TencentCallEvent.error(int code, String message) = TencentError;
  const factory TencentCallEvent.callReceived({
    required String callerId,
    required bool isVideo,
  }) = TencentCallReceived;
  const factory TencentCallEvent.callCancelled(String callerId) =
      TencentCallCancelled;
  const factory TencentCallEvent.callBegan() = TencentCallBegan;
  const factory TencentCallEvent.callEnded(int duration) = TencentCallEnded;
  const factory TencentCallEvent.userRejected(String userId) =
      TencentUserRejected;
  const factory TencentCallEvent.userNoResponse(String userId) =
      TencentUserNoResponse;
  const factory TencentCallEvent.userBusy(String userId) = TencentUserBusy;
  const factory TencentCallEvent.userJoined(String userId) = TencentUserJoined;
  const factory TencentCallEvent.userLeft(String userId) = TencentUserLeft;
  const factory TencentCallEvent.videoAvailable(String userId, bool available) =
      TencentVideoAvailable;
  const factory TencentCallEvent.audioAvailable(String userId, bool available) =
      TencentAudioAvailable;
}

class TencentInitialized extends TencentCallEvent {
  const TencentInitialized();
}

class TencentError extends TencentCallEvent {
  final int code;
  final String message;
  const TencentError(this.code, this.message);
}

class TencentCallReceived extends TencentCallEvent {
  final String callerId;
  final bool isVideo;
  const TencentCallReceived({required this.callerId, required this.isVideo});
}

class TencentCallCancelled extends TencentCallEvent {
  final String callerId;
  const TencentCallCancelled(this.callerId);
}

class TencentCallBegan extends TencentCallEvent {
  const TencentCallBegan();
}

class TencentCallEnded extends TencentCallEvent {
  final int duration;
  const TencentCallEnded(this.duration);
}

class TencentUserRejected extends TencentCallEvent {
  final String userId;
  const TencentUserRejected(this.userId);
}

class TencentUserNoResponse extends TencentCallEvent {
  final String userId;
  const TencentUserNoResponse(this.userId);
}

class TencentUserBusy extends TencentCallEvent {
  final String userId;
  const TencentUserBusy(this.userId);
}

class TencentUserJoined extends TencentCallEvent {
  final String userId;
  const TencentUserJoined(this.userId);
}

class TencentUserLeft extends TencentCallEvent {
  final String userId;
  const TencentUserLeft(this.userId);
}

class TencentVideoAvailable extends TencentCallEvent {
  final String userId;
  final bool available;
  const TencentVideoAvailable(this.userId, this.available);
}

class TencentAudioAvailable extends TencentCallEvent {
  final String userId;
  final bool available;
  const TencentAudioAvailable(this.userId, this.available);
}
