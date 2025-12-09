#!/bin/bash
# Fix freezed mixin formatting

# Fix CallState
sed -i '' 's/ CallModel? get currentCall; bool get isMuted; bool get isSpeakerOn; bool get isVideoEnabled; int get callDuration; bool get isLoading; String? get error;/  CallModel? get currentCall;\n  bool get isMuted;\n  bool get isSpeakerOn;\n  bool get isVideoEnabled;\n  int get callDuration;\n  bool get isLoading;\n  String? get error;/' lib/presentation/call/bloc/call_bloc.freezed.dart

# Fix CallDto
sed -i '' 's/ String get callId; String get callerId; String get callerName; String? get callerAvatar; CallType get callType; DateTime get timestamp;/  String get callId;\n  String get callerId;\n  String get callerName;\n  String? get callerAvatar;\n  CallType get callType;\n  DateTime get timestamp;/' lib/data/models/call_dto.freezed.dart

# Fix CallModel
sed -i '' 's/ String get callId; String get callerId; String get callerName; String? get callerAvatar; CallType get callType; CallStatus get status; DateTime get timestamp; int? get duration;/  String get callId;\n  String get callerId;\n  String get callerName;\n  String? get callerAvatar;\n  CallType get callType;\n  CallStatus get status;\n  DateTime get timestamp;\n  int? get duration;/' lib/repositories/models/call_model.freezed.dart

echo "Fixed freezed files"
