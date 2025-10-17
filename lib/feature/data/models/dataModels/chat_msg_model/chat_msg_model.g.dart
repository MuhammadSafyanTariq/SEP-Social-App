// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_msg_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMsgModelImpl _$$ChatMsgModelImplFromJson(Map<String, dynamic> json) =>
    _$ChatMsgModelImpl(
      id: json['_id'] as String?,
      chat: json['chat'] as String?,
      sender: json['sender'] == null
          ? null
          : Sender.fromJson(json['sender'] as Map<String, dynamic>),
      content: json['content'] as String?,
      isDeleted: json['isDeleted'],
      mediaType: json['mediaType'] as String?,
      readBy: json['readBy'] as List<dynamic>?,
      mediaUrl: json['mediaUrl'] as List<dynamic>?,
      channelId: json['channelId'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      v: (json['__v'] as num?)?.toInt(),
      senderTime: json['senderTime'] as String?,
    );

Map<String, dynamic> _$$ChatMsgModelImplToJson(_$ChatMsgModelImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'chat': instance.chat,
      'sender': instance.sender,
      'content': instance.content,
      'isDeleted': instance.isDeleted,
      'mediaType': instance.mediaType,
      'readBy': instance.readBy,
      'mediaUrl': instance.mediaUrl,
      'channelId': instance.channelId,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      '__v': instance.v,
      'senderTime': instance.senderTime,
    };

_$SenderImpl _$$SenderImplFromJson(Map<String, dynamic> json) =>
    _$SenderImpl(id: json['_id'] as String?, name: json['name'] as String?);

Map<String, dynamic> _$$SenderImplToJson(_$SenderImpl instance) =>
    <String, dynamic>{'_id': instance.id, 'name': instance.name};
