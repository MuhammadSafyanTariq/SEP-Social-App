// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emailvalid_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EmailvalidModelImpl _$$EmailvalidModelImplFromJson(
  Map<String, dynamic> json,
) => _$EmailvalidModelImpl(
  status: json['status'] as bool?,
  code: (json['code'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: Data.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$EmailvalidModelImplToJson(
  _$EmailvalidModelImpl instance,
) => <String, dynamic>{
  'status': instance.status,
  'code': instance.code,
  'message': instance.message,
  'data': instance.data,
};

_$DataImpl _$$DataImplFromJson(Map<String, dynamic> json) => _$DataImpl();

Map<String, dynamic> _$$DataImplToJson(_$DataImpl instance) =>
    <String, dynamic>{};
