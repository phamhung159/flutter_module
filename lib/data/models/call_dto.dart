import 'package:freezed_annotation/freezed_annotation.dart';

part 'call_dto.freezed.dart';
part 'call_dto.g.dart';

@freezed
abstract class CallDto with _$CallDto {
  const factory CallDto({
    required String callId,
    required String callerId,
    required String callerName,
    String? callerAvatar,
    required CallType callType,
    required DateTime timestamp,
  }) = _CallDto;

  factory CallDto.fromJson(Map<String, dynamic> json) => _$CallDtoFromJson(json);
}

enum CallType {
  @JsonValue('audio')
  audio,
  @JsonValue('video')
  video,
}

