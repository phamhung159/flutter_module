// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CallModel _$CallModelFromJson(Map<String, dynamic> json) => _CallModel(
  callId: json['callId'] as String,
  callerId: json['callerId'] as String,
  callerName: json['callerName'] as String,
  callerAvatar: json['callerAvatar'] as String?,
  callType: $enumDecode(_$CallTypeEnumMap, json['callType']),
  status: $enumDecode(_$CallStatusEnumMap, json['status']),
  timestamp: DateTime.parse(json['timestamp'] as String),
  duration: (json['duration'] as num?)?.toInt(),
);

Map<String, dynamic> _$CallModelToJson(_CallModel instance) =>
    <String, dynamic>{
      'callId': instance.callId,
      'callerId': instance.callerId,
      'callerName': instance.callerName,
      'callerAvatar': instance.callerAvatar,
      'callType': _$CallTypeEnumMap[instance.callType]!,
      'status': _$CallStatusEnumMap[instance.status]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'duration': instance.duration,
    };

const _$CallTypeEnumMap = {CallType.audio: 'audio', CallType.video: 'video'};

const _$CallStatusEnumMap = {
  CallStatus.idle: 'idle',
  CallStatus.incoming: 'incoming',
  CallStatus.outgoing: 'outgoing',
  CallStatus.connecting: 'connecting',
  CallStatus.connected: 'connected',
  CallStatus.ended: 'ended',
  CallStatus.declined: 'declined',
  CallStatus.missed: 'missed',
  CallStatus.failed: 'failed',
};
