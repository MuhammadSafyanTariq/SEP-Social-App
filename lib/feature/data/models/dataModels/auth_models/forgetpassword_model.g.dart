// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forgetpassword_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ForgetpasswordModelImpl _$$ForgetpasswordModelImplFromJson(
  Map<String, dynamic> json,
) => _$ForgetpasswordModelImpl(
  status: json['status'] as bool?,
  code: (json['code'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : Data.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$ForgetpasswordModelImplToJson(
  _$ForgetpasswordModelImpl instance,
) => <String, dynamic>{
  'status': instance.status,
  'code': instance.code,
  'message': instance.message,
  'data': instance.data,
};

_$DataImpl _$$DataImplFromJson(Map<String, dynamic> json) =>
    _$DataImpl(id: json['id'] as String?, otp: (json['otp'] as num?)?.toInt());

Map<String, dynamic> _$$DataImplToJson(_$DataImpl instance) =>
    <String, dynamic>{'id': instance.id, 'otp': instance.otp};
