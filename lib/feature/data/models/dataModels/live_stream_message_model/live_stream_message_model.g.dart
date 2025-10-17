// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_stream_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LiveStreamMessageModelImpl _$$LiveStreamMessageModelImplFromJson(
  Map<String, dynamic> json,
) => _$LiveStreamMessageModelImpl(
  id: json['id'] as String?,
  type: json['type'] as String?,
  message: json['message'] as String?,
  timestamp: json['timestamp'] as String?,
  userId: json['userId'] as String?,
  userName: json['userName'] as String?,
  userRole: json['userRole'] as String?,
  participantCount: (json['participantCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$$LiveStreamMessageModelImplToJson(
  _$LiveStreamMessageModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'message': instance.message,
  'timestamp': instance.timestamp,
  'userId': instance.userId,
  'userName': instance.userName,
  'userRole': instance.userRole,
  'participantCount': instance.participantCount,
};
