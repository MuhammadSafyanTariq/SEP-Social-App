// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'getuserdetails_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GetuserdetailsModelImpl _$$GetuserdetailsModelImplFromJson(
  Map<String, dynamic> json,
) => _$GetuserdetailsModelImpl(
  id: json['_id'] as String?,
  name: json['name'] as String?,
  email: json['email'] as String?,
  role: json['role'] as String?,
  phone: json['phone'] as String?,
  dob: json['dob'] as String?,
  gender: json['gender'] as String?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
  v: (json['__v'] as num?)?.toInt(),
  otp: json['otp'],
);

Map<String, dynamic> _$$GetuserdetailsModelImplToJson(
  _$GetuserdetailsModelImpl instance,
) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'role': instance.role,
  'phone': instance.phone,
  'dob': instance.dob,
  'gender': instance.gender,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  '__v': instance.v,
  'otp': instance.otp,
};
