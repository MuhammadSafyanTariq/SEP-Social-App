import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_model.freezed.dart';
part 'store_model.g.dart';

@freezed
class StoreModel with _$StoreModel {
  const factory StoreModel({
    @JsonKey(name: '_id') String? id,
    required String name,
    required String ownerId,
    required String description,
    String? logoUrl,
    required String address,
    required String contactEmail,
    required String contactPhone,
    @Default([]) List<String> products,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    @JsonKey(name: '__v') int? v,
  }) = _StoreModel;

  factory StoreModel.fromJson(Map<String, dynamic> json) =>
      _$StoreModelFromJson(json);
}

@freezed
class StoreResponse with _$StoreResponse {
  const factory StoreResponse({
    required bool status,
    required int code,
    required String message,
    StoreModel? data,
  }) = _StoreResponse;

  factory StoreResponse.fromJson(Map<String, dynamic> json) =>
      _$StoreResponseFromJson(json);
}
