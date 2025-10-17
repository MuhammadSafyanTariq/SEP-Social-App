// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seemyprofile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SeemyprofileModelImpl _$$SeemyprofileModelImplFromJson(
  Map<String, dynamic> json,
) => _$SeemyprofileModelImpl(
  status: json['status'] as bool?,
  code: (json['code'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : Data.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$SeemyprofileModelImplToJson(
  _$SeemyprofileModelImpl instance,
) => <String, dynamic>{
  'status': instance.status,
  'code': instance.code,
  'message': instance.message,
  'data': instance.data,
};

_$DataImpl _$$DataImplFromJson(Map<String, dynamic> json) => _$DataImpl(
  id: json['id'] as String?,
  name: json['name'] as String?,
  email: json['email'] as String?,
  password: json['password'] as String?,
  role: json['role'] as String?,
  phone: json['phone'] as String?,
  dob: json['dob'] as String?,
  gender: json['gender'] as String?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
  v: (json['v'] as num?)?.toInt(),
  otp: json['otp'],
  image: json['image'] as String?,
  seeMyProfile: json['seeMyProfile'] as String?,
  shareMyPost: json['shareMyPost'] as String?,
);

Map<String, dynamic> _$$DataImplToJson(_$DataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'role': instance.role,
      'phone': instance.phone,
      'dob': instance.dob,
      'gender': instance.gender,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'v': instance.v,
      'otp': instance.otp,
      'image': instance.image,
      'seeMyProfile': instance.seeMyProfile,
      'shareMyPost': instance.shareMyPost,
    };
