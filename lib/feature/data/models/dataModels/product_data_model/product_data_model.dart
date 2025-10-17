// To parse this JSON data, do
//
//     final productDataModel = productDataModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'product_data_model.freezed.dart';
part 'product_data_model.g.dart';

ProductDataModel productDataModelFromJson(String str) => ProductDataModel.fromJson(json.decode(str));

String productDataModelToJson(ProductDataModel data) => json.encode(data.toJson());

@freezed
class ProductDataModel with _$ProductDataModel {
  const factory ProductDataModel({
    @JsonKey(name: "_id")
    String? id,
    @JsonKey(name: "image")
    List<String>? images,
    @JsonKey(name: "title")
    String? title,
    @JsonKey(name: "description")
    String? description,
    @JsonKey(name: "price")
    String? price,
    @JsonKey(name: "createdAt")
    String? createdAt,
    @JsonKey(name: "updatedAt")
    String? updatedAt,
    @JsonKey(name: "checkouturl")
    String? checkouturl,
    @JsonKey(name: "shippingType")
    String? shippingType,
    @JsonKey(name: "__v")
    int? v,
  }) = _ProductDataModel;

  factory ProductDataModel.fromJson(Map<String, dynamic> json) => _$ProductDataModelFromJson(json);
}
