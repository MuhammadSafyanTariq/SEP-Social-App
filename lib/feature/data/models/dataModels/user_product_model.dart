import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'user_product_model.freezed.dart';
part 'user_product_model.g.dart';

UserProductModel userProductModelFromJson(String str) =>
    UserProductModel.fromJson(json.decode(str));

String userProductModelToJson(UserProductModel data) =>
    json.encode(data.toJson());

@freezed
class UserProductModel with _$UserProductModel {
  const factory UserProductModel({
    @JsonKey(name: "_id") String? id,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "description") String? description,
    @JsonKey(name: "price") double? price,
    @JsonKey(name: "mediaUrls") List<String>? mediaUrls,
    @JsonKey(name: "category") String? category,
    @JsonKey(name: "isAvailable") @Default(true) bool isAvailable,
    @JsonKey(name: "shopId") dynamic shopId, // Can be String or ShopInfo
    @JsonKey(name: "createdAt") String? createdAt,
    @JsonKey(name: "updatedAt") String? updatedAt,
    @JsonKey(name: "__v") int? v,
  }) = _UserProductModel;

  factory UserProductModel.fromJson(Map<String, dynamic> json) =>
      _$UserProductModelFromJson(json);
}

@freezed
class ShopInfo with _$ShopInfo {
  const factory ShopInfo({
    @JsonKey(name: "_id") String? id,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "logoUrl") String? logoUrl,
  }) = _ShopInfo;

  factory ShopInfo.fromJson(Map<String, dynamic> json) =>
      _$ShopInfoFromJson(json);
}

@freezed
class UserProductResponse with _$UserProductResponse {
  const factory UserProductResponse({
    @JsonKey(name: "status") bool? status,
    @JsonKey(name: "code") int? code,
    @JsonKey(name: "message") String? message,
    @JsonKey(name: "data") UserProductModel? data,
  }) = _UserProductResponse;

  factory UserProductResponse.fromJson(Map<String, dynamic> json) =>
      _$UserProductResponseFromJson(json);
}
