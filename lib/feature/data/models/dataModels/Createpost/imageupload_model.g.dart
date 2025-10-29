// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'imageupload_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ImageuploadModelImpl _$$ImageuploadModelImplFromJson(
  Map<String, dynamic> json,
) => _$ImageuploadModelImpl(
  status: json['status'] as bool?,
  code: (json['code'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : Data.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$ImageuploadModelImplToJson(
  _$ImageuploadModelImpl instance,
) => <String, dynamic>{
  'status': instance.status,
  'code': instance.code,
  'message': instance.message,
  'data': instance.data,
};

_$DataImpl _$$DataImplFromJson(Map<String, dynamic> json) => _$DataImpl(
  urls: (json['urls'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$$DataImplToJson(_$DataImpl instance) =>
    <String, dynamic>{'urls': instance.urls};
