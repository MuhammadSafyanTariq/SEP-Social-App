// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'createpost_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreatepostModelImpl _$$CreatepostModelImplFromJson(
  Map<String, dynamic> json,
) => _$CreatepostModelImpl(
  status: json['status'] as bool?,
  code: (json['code'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : Data.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$CreatepostModelImplToJson(
  _$CreatepostModelImpl instance,
) => <String, dynamic>{
  'status': instance.status,
  'code': instance.code,
  'message': instance.message,
  'data': instance.data,
};

_$DataImpl _$$DataImplFromJson(Map<String, dynamic> json) => _$DataImpl(
  userId: json['userId'] as String?,
  categoryId: json['categoryId'] as String?,
  content: json['content'] as String?,
  location: json['location'] == null
      ? null
      : Location.fromJson(json['location'] as Map<String, dynamic>),
  files: (json['files'] as List<dynamic>?)
      ?.map((e) => FileElement.fromJson(e as Map<String, dynamic>))
      .toList(),
  fileType: json['fileType'] as String?,
  id: json['_id'] as String?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
  v: (json['__v'] as num?)?.toInt(),
);

Map<String, dynamic> _$$DataImplToJson(_$DataImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'categoryId': instance.categoryId,
      'content': instance.content,
      'location': instance.location,
      'files': instance.files,
      'fileType': instance.fileType,
      '_id': instance.id,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      '__v': instance.v,
    };

_$FileElementImpl _$$FileElementImplFromJson(Map<String, dynamic> json) =>
    _$FileElementImpl(
      file: json['file'] as String?,
      type: json['type'] as String?,
      id: json['_id'] as String?,
    );

Map<String, dynamic> _$$FileElementImplToJson(_$FileElementImpl instance) =>
    <String, dynamic>{
      'file': instance.file,
      'type': instance.type,
      '_id': instance.id,
    };

_$LocationImpl _$$LocationImplFromJson(Map<String, dynamic> json) =>
    _$LocationImpl(
      type: json['type'] as String?,
      coordinates: (json['coordinates'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$$LocationImplToJson(_$LocationImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'coordinates': instance.coordinates,
    };
