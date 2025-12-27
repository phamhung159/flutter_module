import 'package:flutter/material.dart';
import 'package:flutter_module/presentation/lib/src/login_widget.dart';
import 'package:tencent_calls_uikit/tencent_calls_uikit.dart';

void setObserverFunction({required TUICallEngine callsEnginePlugin}) {
  callsEnginePlugin.addObserver(
    TUICallObserver(
      onError: (int code, String message) {
        debugPrint(
          '------------------------------------------------onError: $code - $message',
        );
      },
      onCallBegin:
          (TUIRoomId roomId, TUICallMediaType mediaType, TUICallRole role) {
            debugPrint(
              '------------------------------------------------onCallBegin',
            );
          },
      onCallEnd:
          (
            TUIRoomId roomId,
            TUICallMediaType mediaType,
            TUICallRole role,
            double totalTime,
          ) {
            debugPrint(
              '------------------------------------------------onCallEnd: $totalTime seconds',
            );
          },
      onCallMediaTypeChanged:
          (
            TUICallMediaType oldCallMediaType,
            TUICallMediaType newCallMediaType,
          ) {
            debugPrint(
              '------------------------------------------------onCallMediaTypeChanged',
            );
          },
      onUserReject: (String userId) {
        debugPrint(
          '+++------------------------------------------------onUserReject: $userId',
        );
      },
      onUserNoResponse: (String userId) {
        debugPrint(
          '+++------------------------------------------------onUserNoResponse: $userId',
        );
      },
      onUserLineBusy: (String userId) {
        debugPrint(
          '+++------------------------------------------------onUserLineBusy: $userId',
        );
      },
      onUserJoin: (String userId) {
        debugPrint(
          '+++------------------------------------------------onUserJoin: $userId',
        );
      },
      onUserLeave: (String userId) {
        debugPrint(
          '+++------------------------------------------------onUserLeave: $userId',
        );
      },
      onUserVideoAvailable: (String userId, bool isVideoAvailable) {
        debugPrint(
          '------------------------------------------------onUserVideoAvailable: $userId - $isVideoAvailable',
        );
      },
      onUserAudioAvailable: (String userId, bool isAudioAvailable) {
        debugPrint(
          '------------------------------------------------onUserAudioAvailable: $userId - $isAudioAvailable',
        );
      },
      onUserNetworkQualityChanged:
          (List<TUINetworkQualityInfo> networkQualityList) {
            debugPrint(
              '------------------------------------------------onUserNetworkQualityChanged',
            );
          },
      onCallReceived:
          (
            String callerId,
            List<String> calleeIdList,
            String groupId,
            TUICallMediaType mediaType,
            String? userData,
          ) {
            debugPrint(
              '------------------------------------------------onCallReceived from: $callerId',
            );
          },
      onUserVoiceVolumeChanged: (Map<String, int> volumeMap) {
        debugPrint(
          '------------------------------------------------onUserVoiceVolumeChanged',
        );
      },
      onKickedOffline: () {
        debugPrint(
          '------------------------------------------------onKickedOffline',
        );
        TUICallKit.navigatorObserver.navigator?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (widget) => const LoginWidget()),
          (route) => false,
        );
      },
      onUserSigExpired: () {
        debugPrint(
          '------------------------------------------------onUserSigExpired',
        );
        TUICallKit.navigatorObserver.navigator?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (widget) => const LoginWidget()),
          (route) => false,
        );
      },
    ),
  );
}
