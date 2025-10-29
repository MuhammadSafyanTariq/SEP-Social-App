// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sociallogin_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SocialloginModelImpl _$$SocialloginModelImplFromJson(
  Map<String, dynamic> json,
) => _$SocialloginModelImpl(
  status: json['status'] as bool?,
  code: (json['code'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : Data.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$SocialloginModelImplToJson(
  _$SocialloginModelImpl instance,
) => <String, dynamic>{
  'status': instance.status,
  'code': instance.code,
  'message': instance.message,
  'data': instance.data,
};

_$DataImpl _$$DataImplFromJson(Map<String, dynamic> json) => _$DataImpl(
  user: json['user'] == null
      ? null
      : ProfileDataModel.fromJson(json['user'] as Map<String, dynamic>),
  token: json['token'] as String?,
);

Map<String, dynamic> _$$DataImplToJson(_$DataImpl instance) =>
    <String, dynamic>{'user': instance.user, 'token': instance.token};
