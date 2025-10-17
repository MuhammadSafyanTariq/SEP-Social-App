// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'getcategory_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GetcategoryModelImpl _$$GetcategoryModelImplFromJson(
  Map<String, dynamic> json,
) => _$GetcategoryModelImpl(
  status: json['status'] as bool?,
  code: (json['code'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : Data.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$GetcategoryModelImplToJson(
  _$GetcategoryModelImpl instance,
) => <String, dynamic>{
  'status': instance.status,
  'code': instance.code,
  'message': instance.message,
  'data': instance.data,
};

_$DataImpl _$$DataImplFromJson(Map<String, dynamic> json) => _$DataImpl(
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => Categories.fromJson(e as Map<String, dynamic>))
      .toList(),
  page: (json['page'] as num?)?.toInt(),
  limit: (json['limit'] as num?)?.toInt(),
  totalCount: (json['totalCount'] as num?)?.toInt(),
  totalPages: (json['totalPages'] as num?)?.toInt(),
);

Map<String, dynamic> _$$DataImplToJson(_$DataImpl instance) =>
    <String, dynamic>{
      'data': instance.data,
      'page': instance.page,
      'limit': instance.limit,
      'totalCount': instance.totalCount,
      'totalPages': instance.totalPages,
    };

_$CategoriesImpl _$$CategoriesImplFromJson(Map<String, dynamic> json) =>
    _$CategoriesImpl(
      id: json['id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      image: json['image'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      v: (json['v'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$CategoriesImplToJson(_$CategoriesImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'image': instance.image,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'v': instance.v,
    };
