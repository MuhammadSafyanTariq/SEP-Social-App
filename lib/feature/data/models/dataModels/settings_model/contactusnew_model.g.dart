// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contactusnew_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ContactusnewModelImpl _$$ContactusnewModelImplFromJson(
  Map<String, dynamic> json,
) => _$ContactusnewModelImpl(
  status: json['status'] as bool?,
  code: (json['code'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : Data.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$ContactusnewModelImplToJson(
  _$ContactusnewModelImpl instance,
) => <String, dynamic>{
  'status': instance.status,
  'code': instance.code,
  'message': instance.message,
  'data': instance.data,
};

_$DataImpl _$$DataImplFromJson(Map<String, dynamic> json) => _$DataImpl(
  email: json['email'] as String?,
  title: json['title'] as String?,
  description: json['description'] as String?,
  id: json['_id'] as String?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
  v: (json['__v'] as num?)?.toInt(),
);

Map<String, dynamic> _$$DataImplToJson(_$DataImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'title': instance.title,
      'description': instance.description,
      '_id': instance.id,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      '__v': instance.v,
    };
