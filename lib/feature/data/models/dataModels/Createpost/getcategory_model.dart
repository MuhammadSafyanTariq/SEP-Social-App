// To parse this JSON data, do
//
//     final getcategoryModel = getcategoryModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'getcategory_model.freezed.dart';
part 'getcategory_model.g.dart';

GetcategoryModel getcategoryModelFromJson(String str) =>
    GetcategoryModel.fromJson(json.decode(str));

String getcategoryModelToJson(GetcategoryModel data) =>
    json.encode(data.toJson());

@freezed
class GetcategoryModel with _$GetcategoryModel {
  const factory GetcategoryModel({
    bool? status,
    int? code,
    String? message,
    Data? data,
  }) = _GetcategoryModel;

  factory GetcategoryModel.fromJson(Map<String, dynamic> json) =>
      _$GetcategoryModelFromJson(json);
}

@freezed
class Data with _$Data {
  const factory Data({
    List<Categories>? data,
    int? page,
    int? limit,
    int? totalCount,
    int? totalPages,
  }) = _Data;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
}

@freezed
class Categories with _$Categories {
  const factory Categories({
    String? id,
    String? name,
    String? description,
    String? image,
    String? createdAt,
    String? updatedAt,
    int? v,
  }) = _Categories;

  factory Categories.fromJson(Map<String, dynamic> json) =>
      _$CategoriesFromJson(json);
}
