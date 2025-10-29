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
      id: json['_id'] as String?,
      name: json['name'] as String?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      gender: json['gender'] as String?,
      dob: json['dob'],
      countryCode: json['countryCode'] as String?,
      country: json['country'] as String?,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      bio: json['bio'] as String?,
      socialType: json['socialType'] as String?,
      socialId: json['socialId'] as String?,
      deviceType: json['deviceType'] as String?,
      deviceToken: json['deviceToken'] as String?,
      stripeCustomerId: json['stripeCustomerId'] as String?,
      stripeAccountId: json['stripeAccountId'] as String?,
      walletBalance: (json['walletBalance'] as num?)?.toDouble(),
      followers: json['followers'] as List<dynamic>?,
      following: json['following'] as List<dynamic>?,
      blockUser: json['blockUser'] as List<dynamic>?,
      isNotification: json['isNotification'] as bool?,
      isOnline: json['isOnline'] as bool?,
      isActive: json['isActive'] as bool?,
      isBlocked: json['isBlocked'] as bool?,
      isBlockedByAdmin: json['isBlockedByAdmin'] as bool?,
      seeMyProfile: json['seeMyProfile'] as String?,
      shareMyPost: json['shareMyPost'] as String?,
      isDelete: json['isDelete'] as bool?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      v: (json['__v'] as num?)?.toInt(),
      image: json['image'],
      isProfileComplete: json['isProfileComplete'] as bool?,
      password: json['password'] as String?,
      otp: json['otp'],
      otpExpiry: json['otpExpiry'],
    );

Map<String, dynamic> _$$UserDataImplToJson(_$UserDataImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'username': instance.username,
      'email': instance.email,
      'role': instance.role,
      'gender': instance.gender,
      'dob': instance.dob,
      'countryCode': instance.countryCode,
      'country': instance.country,
      'phone': instance.phone,
      'website': instance.website,
      'bio': instance.bio,
      'socialType': instance.socialType,
      'socialId': instance.socialId,
      'deviceType': instance.deviceType,
      'deviceToken': instance.deviceToken,
      'stripeCustomerId': instance.stripeCustomerId,
      'stripeAccountId': instance.stripeAccountId,
      'walletBalance': instance.walletBalance,
      'followers': instance.followers,
      'following': instance.following,
      'blockUser': instance.blockUser,
      'isNotification': instance.isNotification,
      'isOnline': instance.isOnline,
      'isActive': instance.isActive,
      'isBlocked': instance.isBlocked,
      'isBlockedByAdmin': instance.isBlockedByAdmin,
      'seeMyProfile': instance.seeMyProfile,
      'shareMyPost': instance.shareMyPost,
      'isDelete': instance.isDelete,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      '__v': instance.v,
      'image': instance.image,
      'isProfileComplete': instance.isProfileComplete,
      'password': instance.password,
      'otp': instance.otp,
      'otpExpiry': instance.otpExpiry,
    };
