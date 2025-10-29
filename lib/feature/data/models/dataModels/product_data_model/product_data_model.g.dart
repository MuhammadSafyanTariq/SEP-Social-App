// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductDataModelImpl _$$ProductDataModelImplFromJson(
  Map<String, dynamic> json,
) => _$ProductDataModelImpl(
  id: json['_id'] as String?,
  images: (json['image'] as List<dynamic>?)?.map((e) => e as String).toList(),
  title: json['title'] as String?,
  description: json['description'] as String?,
  price: json['price'] as String?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
  checkouturl: json['checkouturl'] as String?,
  shippingType: json['shippingType'] as String?,
  v: (json['__v'] as num?)?.toInt(),
);

Map<String, dynamic> _$$ProductDataModelImplToJson(
  _$ProductDataModelImpl instance,
) => <String, dynamic>{
  '_id': instance.id,
  'image': instance.images,
  'title': instance.title,
  'description': instance.description,
  'price': instance.price,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'checkouturl': instance.checkouturl,
  'shippingType': instance.shippingType,
  '__v': instance.v,
};
