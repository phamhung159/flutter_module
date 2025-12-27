// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CallDto _$CallDtoFromJson(Map<String, dynamic> json) => _CallDto(
  callId: json['callId'] as String,
  callerId: json['callerId'] as String,
  callerName: json['callerName'] as String,
  callerAvatar: json['callerAvatar'] as String?,
  callType: $enumDecode(_$CallTypeEnumMap, json['callType']),
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$CallDtoToJson(_CallDto instance) => <String, dynamic>{
  'callId': instance.callId,
  'callerId': instance.callerId,
  'callerName': instance.callerName,
  'callerAvatar': instance.callerAvatar,
  'callType': _$CallTypeEnumMap[instance.callType]!,
  'timestamp': instance.timestamp.toIso8601String(),
};

const _$CallTypeEnumMap = {CallType.audio: 'audio', CallType.video: 'video'};
