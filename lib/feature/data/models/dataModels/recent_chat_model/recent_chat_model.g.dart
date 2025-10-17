// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecentChatModelImpl _$$RecentChatModelImplFromJson(
  Map<String, dynamic> json,
) => _$RecentChatModelImpl(
  id: json['_id'] as String?,
  groupName: json['groupName'],
  archived: json['archived'] as bool?,
  users: (json['users'] as List<dynamic>?)?.map((e) => e as String).toList(),
  isDeleted: json['isDeleted'],
  admins: json['admins'] as List<dynamic>?,
  userDetails: (json['userDetails'] as List<dynamic>?)
      ?.map((e) => UserDetail.fromJson(e as Map<String, dynamic>))
      .toList(),
  latestMessage: json['latestMessage'] == null
      ? null
      : LatestMessage.fromJson(json['latestMessage'] as Map<String, dynamic>),
  updatedAt: json['updatedAt'] as String?,
  unreadCount: (json['unreadCount'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toInt()),
  ),
  lastSeen: json['lastSeen'] == null
      ? null
      : LastSeen.fromJson(json['lastSeen'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$RecentChatModelImplToJson(
  _$RecentChatModelImpl instance,
) => <String, dynamic>{
  '_id': instance.id,
  'groupName': instance.groupName,
  'archived': instance.archived,
  'users': instance.users,
  'isDeleted': instance.isDeleted,
  'admins': instance.admins,
  'userDetails': instance.userDetails,
  'latestMessage': instance.latestMessage,
  'updatedAt': instance.updatedAt,
  'unreadCount': instance.unreadCount,
  'lastSeen': instance.lastSeen,
};

_$LastSeenImpl _$$LastSeenImplFromJson(Map<String, dynamic> json) =>
    _$LastSeenImpl(
      the67A4923Ad27B11F5Bb680D91: json['67a4923ad27b11f5bb680d91'] as String?,
    );

Map<String, dynamic> _$$LastSeenImplToJson(_$LastSeenImpl instance) =>
    <String, dynamic>{
      '67a4923ad27b11f5bb680d91': instance.the67A4923Ad27B11F5Bb680D91,
    };

_$LatestMessageImpl _$$LatestMessageImplFromJson(Map<String, dynamic> json) =>
    _$LatestMessageImpl(
      content: json['content'] as String?,
      senderTime: json['senderTime'] as String?,
    );

Map<String, dynamic> _$$LatestMessageImplToJson(_$LatestMessageImpl instance) =>
    <String, dynamic>{
      'content': instance.content,
      'senderTime': instance.senderTime,
    };

_$UnreadCountImpl _$$UnreadCountImplFromJson(Map<String, dynamic> json) =>
    _$UnreadCountImpl(
      the67A4923Ad27B11F5Bb680D91: (json['67a4923ad27b11f5bb680d91'] as num?)
          ?.toInt(),
      the67A34E3Bc7Aea8A744B35519: (json['67a34e3bc7aea8a744b35519'] as num?)
          ?.toInt(),
    );

Map<String, dynamic> _$$UnreadCountImplToJson(_$UnreadCountImpl instance) =>
    <String, dynamic>{
      '67a4923ad27b11f5bb680d91': instance.the67A4923Ad27B11F5Bb680D91,
      '67a34e3bc7aea8a744b35519': instance.the67A34E3Bc7Aea8A744B35519,
    };

_$UserDetailImpl _$$UserDetailImplFromJson(Map<String, dynamic> json) =>
    _$UserDetailImpl(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      image: json['image'] as String?,
    );

Map<String, dynamic> _$$UserDetailImplToJson(_$UserDetailImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'image': instance.image,
    };
