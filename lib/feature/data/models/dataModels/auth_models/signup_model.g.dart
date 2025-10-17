// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signup_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SignupModelImpl _$$SignupModelImplFromJson(Map<String, dynamic> json) =>
    _$SignupModelImpl(
      status: json['status'] as bool?,
      code: (json['code'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : Data.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$SignupModelImplToJson(_$SignupModelImpl instance) =>
    <String, dynamic>{
      'status': instance.status,
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };

_$DataImpl _$$DataImplFromJson(Map<String, dynamic> json) => _$DataImpl(
  name: json['name'] as String?,
  email: json['email'] as String?,
  password: json['password'] as String?,
  role: json['role'] as String?,
  phone: json['phone'] as String?,
  dob: json['dob'] as String?,
  gender: json['gender'] as String?,
  id: json['id'] as String?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
  v: (json['v'] as num?)?.toInt(),
);

Map<String, dynamic> _$$DataImplToJson(_$DataImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'role': instance.role,
      'phone': instance.phone,
      'dob': instance.dob,
      'gender': instance.gender,
      'id': instance.id,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'v': instance.v,
    };
