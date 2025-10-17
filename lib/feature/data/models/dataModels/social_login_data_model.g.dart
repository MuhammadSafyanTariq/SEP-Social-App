// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_login_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SocialLoginDataModelImpl _$$SocialLoginDataModelImplFromJson(
  Map<String, dynamic> json,
) => _$SocialLoginDataModelImpl(
  status: json['status'] as bool?,
  code: (json['code'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : Data.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$SocialLoginDataModelImplToJson(
  _$SocialLoginDataModelImpl instance,
) => <String, dynamic>{
  'status': instance.status,
  'code': instance.code,
  'message': instance.message,
  'data': instance.data,
};

_$DataImpl _$$DataImplFromJson(Map<String, dynamic> json) => _$DataImpl(
  userData: json['userData'] == null
      ? null
      : UserData.fromJson(json['userData'] as Map<String, dynamic>),
  token: json['token'] as String?,
);

Map<String, dynamic> _$$DataImplToJson(_$DataImpl instance) =>
    <String, dynamic>{'userData': instance.userData, 'token': instance.token};

_$UserDataImpl _$$UserDataImplFromJson(Map<String, dynamic> json) =>
    _$UserDataImpl(
      isProfileComplete: json['isProfileComplete'] as bool?,
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'],
      password: json['password'] as String?,
      otp: json['otp'],
      otpExpiry: json['otpExpiry'],
      deviceToken: json['deviceToken'],
      socialId: json['socialId'] as String?,
      socialType: json['socialType'] as String?,
      deviceType: json['deviceType'],
      image: json['image'],
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$$UserDataImplToJson(_$UserDataImpl instance) =>
    <String, dynamic>{
      'isProfileComplete': instance.isProfileComplete,
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'password': instance.password,
      'otp': instance.otp,
      'otpExpiry': instance.otpExpiry,
      'deviceToken': instance.deviceToken,
      'socialId': instance.socialId,
      'socialType': instance.socialType,
      'deviceType': instance.deviceType,
      'image': instance.image,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
