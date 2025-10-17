// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileDataModelImpl _$$ProfileDataModelImplFromJson(
  Map<String, dynamic> json,
) => _$ProfileDataModelImpl(
  stripeCustomerId: json['stripeCustomerId'] as String?,
  walletBalance: (json['walletBalance'] as num?)?.toInt(),
  tokenBalance: (json['tokenBalance'] as num?)?.toInt(),
  walletTokens: (json['walletTokens'] as num?)?.toInt(),
  name: json['name'] as String?,
  id: json['_id'] as String?,
  email: json['email'] as String?,
  password: json['password'] as String?,
  role: json['role'] as String?,
  phone: json['phone'] as String?,
  countryCode: json['countryCode'] as String?,
  dob: json['dob'] as String?,
  country: json['country'] as String?,
  gender: json['gender'] as String?,
  image: json['image'] as String?,
  coverPhoto: json['coverPhoto'] as String?,
  socialId: json['socialId'] as String?,
  isActive: json['isActive'] as bool?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
  seeMyProfile: json['seeMyProfile'] as String?,
  shareMyPost: json['shareMyPost'] as String?,
  isNotification: json['isNotification'] as bool?,
  followers: (json['followers'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  following: (json['following'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  postCount: (json['postCount'] as num?)?.toInt(),
  bio: json['bio'] as String?,
  website: json['website'] as String?,
  userName: json['username'] as String?,
  v: (json['__v'] as num?)?.toInt(),
);

Map<String, dynamic> _$$ProfileDataModelImplToJson(
  _$ProfileDataModelImpl instance,
) => <String, dynamic>{
  'stripeCustomerId': instance.stripeCustomerId,
  'walletBalance': instance.walletBalance,
  'tokenBalance': instance.tokenBalance,
  'walletTokens': instance.walletTokens,
  'name': instance.name,
  '_id': instance.id,
  'email': instance.email,
  'password': instance.password,
  'role': instance.role,
  'phone': instance.phone,
  'countryCode': instance.countryCode,
  'dob': instance.dob,
  'country': instance.country,
  'gender': instance.gender,
  'image': instance.image,
  'coverPhoto': instance.coverPhoto,
  'socialId': instance.socialId,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'seeMyProfile': instance.seeMyProfile,
  'shareMyPost': instance.shareMyPost,
  'isNotification': instance.isNotification,
  'followers': instance.followers,
  'following': instance.following,
  'postCount': instance.postCount,
  'bio': instance.bio,
  'website': instance.website,
  'username': instance.userName,
  '__v': instance.v,
};
