// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationModelImpl _$$NotificationModelImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationModelImpl(
  status: json['status'] as bool?,
  code: (json['code'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : NotificationData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$NotificationModelImplToJson(
  _$NotificationModelImpl instance,
) => <String, dynamic>{
  'status': instance.status,
  'code': instance.code,
  'message': instance.message,
  'data': instance.data,
};

_$NotificationDataImpl _$$NotificationDataImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationDataImpl(
  notifications: (json['notifications'] as List<dynamic>?)
      ?.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  pagination: json['pagination'] == null
      ? null
      : Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$NotificationDataImplToJson(
  _$NotificationDataImpl instance,
) => <String, dynamic>{
  'notifications': instance.notifications,
  'pagination': instance.pagination,
};

_$NotificationItemImpl _$$NotificationItemImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationItemImpl(
  id: json['id'] as String?,
  senderId: json['senderId'] == null
      ? null
      : Sender.fromJson(json['senderId'] as Map<String, dynamic>),
  receiverId: json['receiverId'] as String?,
  notificationType: json['notificationType'] as String?,
  title: json['title'] as String?,
  message: json['message'] as String?,
  roomId: json['roomId'] as String?,
  postId: json['postId'] as String?,
  status: json['status'] as String?,
  isRead: json['isRead'] as bool?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
  v: (json['v'] as num?)?.toInt(),
);

Map<String, dynamic> _$$NotificationItemImplToJson(
  _$NotificationItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'senderId': instance.senderId,
  'receiverId': instance.receiverId,
  'notificationType': instance.notificationType,
  'title': instance.title,
  'message': instance.message,
  'roomId': instance.roomId,
  'postId': instance.postId,
  'status': instance.status,
  'isRead': instance.isRead,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'v': instance.v,
};

_$SenderImpl _$$SenderImplFromJson(Map<String, dynamic> json) => _$SenderImpl(
  id: json['id'] as String?,
  name: json['name'] as String?,
  image: json['image'] as String?,
);

Map<String, dynamic> _$$SenderImplToJson(_$SenderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
    };

_$PaginationImpl _$$PaginationImplFromJson(Map<String, dynamic> json) =>
    _$PaginationImpl(
      currentPage: (json['currentPage'] as num?)?.toInt(),
      totalPages: (json['totalPages'] as num?)?.toInt(),
      totalNotifications: (json['totalNotifications'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$PaginationImplToJson(_$PaginationImpl instance) =>
    <String, dynamic>{
      'currentPage': instance.currentPage,
      'totalPages': instance.totalPages,
      'totalNotifications': instance.totalNotifications,
    };
