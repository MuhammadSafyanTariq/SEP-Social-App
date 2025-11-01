// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProductModelImpl _$$UserProductModelImplFromJson(
  Map<String, dynamic> json,
) => _$UserProductModelImpl(
  id: json['_id'] as String?,
  name: json['name'] as String?,
  description: json['description'] as String?,
  price: (json['price'] as num?)?.toDouble(),
  mediaUrls: (json['mediaUrls'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  category: json['category'] as String?,
  isAvailable: json['isAvailable'] as bool? ?? true,
  shopId: json['shopId'],
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
  v: (json['__v'] as num?)?.toInt(),
);

Map<String, dynamic> _$$UserProductModelImplToJson(
  _$UserProductModelImpl instance,
) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'mediaUrls': instance.mediaUrls,
  'category': instance.category,
  'isAvailable': instance.isAvailable,
  'shopId': instance.shopId,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  '__v': instance.v,
};

_$ShopInfoImpl _$$ShopInfoImplFromJson(Map<String, dynamic> json) =>
    _$ShopInfoImpl(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      logoUrl: json['logoUrl'] as String?,
    );

Map<String, dynamic> _$$ShopInfoImplToJson(_$ShopInfoImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'logoUrl': instance.logoUrl,
    };

_$UserProductResponseImpl _$$UserProductResponseImplFromJson(
  Map<String, dynamic> json,
) => _$UserProductResponseImpl(
  status: json['status'] as bool?,
  code: (json['code'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : UserProductModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$UserProductResponseImplToJson(
  _$UserProductResponseImpl instance,
) => <String, dynamic>{
  'status': instance.status,
  'code': instance.code,
  'message': instance.message,
  'data': instance.data,
};
