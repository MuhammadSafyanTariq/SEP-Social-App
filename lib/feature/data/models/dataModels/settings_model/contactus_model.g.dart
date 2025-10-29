// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contactus_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ContactusModelImpl _$$ContactusModelImplFromJson(Map<String, dynamic> json) =>
    _$ContactusModelImpl(
      status: json['status'] as bool?,
      code: (json['code'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : Data.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ContactusModelImplToJson(
  _$ContactusModelImpl instance,
) => <String, dynamic>{
  'status': instance.status,
  'code': instance.code,
  'message': instance.message,
  'data': instance.data,
};

_$DataImpl _$$DataImplFromJson(Map<String, dynamic> json) => _$DataImpl(
  id: json['_id'] as String?,
  title: json['title'] as String?,
  description: json['description'] as String?,
  type: json['type'] as String?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
  v: (json['__v'] as num?)?.toInt(),
);

Map<String, dynamic> _$$DataImplToJson(_$DataImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': instance.type,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      '__v': instance.v,
    };
