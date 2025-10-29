// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationModelImpl _$$NotificationModelImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationModelImpl(
  id: json['id'] as String?,
  name: json['name'] as String?,
  email: json['email'] as String?,
  password: json['password'] as String?,
  role: json['role'] as String?,
  phone: json['phone'] as String?,
  dob: json['dob'] as String?,
  gender: json['gender'] as String?,
  seeMyProfile: json['seeMyProfile'] as String?,
  shareMyPost: json['shareMyPost'] as String?,
  image: json['image'] as String?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
  v: (json['v'] as num?)?.toInt(),
  isNotification: json['isNotification'] as bool?,
);

Map<String, dynamic> _$$NotificationModelImplToJson(
  _$NotificationModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'password': instance.password,
  'role': instance.role,
  'phone': instance.phone,
  'dob': instance.dob,
  'gender': instance.gender,
  'seeMyProfile': instance.seeMyProfile,
  'shareMyPost': instance.shareMyPost,
  'image': instance.image,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'v': instance.v,
  'isNotification': instance.isNotification,
};
