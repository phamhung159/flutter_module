import 'package:flutter_module/data/models/call_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'call_model.freezed.dart';
part 'call_model.g.dart';

@freezed
abstract class CallModel with _$CallModel {
  const factory CallModel({
    required String callId,
    required String callerId,
    required String callerName,
    String? callerAvatar,
    required CallType callType,
    required CallStatus status,
    required DateTime timestamp,
    int? duration, // in seconds
  }) = _CallModel;

  factory CallModel.fromDto(CallDto dto) {
    return CallModel(
      callId: dto.callId,
      callerId: dto.callerId,
      callerName: dto.callerName,
      callerAvatar: dto.callerAvatar,
      callType: dto.callType,
      status: CallStatus.incoming,
      timestamp: dto.timestamp,
    );
  }

  factory CallModel.fromJson(Map<String, dynamic> json) => _$CallModelFromJson(json);
}

enum CallStatus {
  @JsonValue('idle')
  idle,
  @JsonValue('incoming')
  incoming,
  @JsonValue('outgoing')
  outgoing,
  @JsonValue('connecting')
  connecting,
  @JsonValue('connected')
  connected,
  @JsonValue('ended')
  ended,
  @JsonValue('declined')
  declined,
  @JsonValue('missed')
  missed,
  @JsonValue('failed')
  failed,
}

