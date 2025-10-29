// To parse this JSON data, do
//
//     final xyzModel = xyzModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'xyz_model.freezed.dart';
part 'xyz_model.g.dart';

XyzModel xyzModelFromJson(String str) => XyzModel.fromJson(json.decode(str));

String xyzModelToJson(XyzModel data) => json.encode(data.toJson());

@freezed
class XyzModel with _$XyzModel {
  const factory XyzModel({
    String? greeting,
    List<String>? instructions,
    int? newId,
  }) = _XyzModel;

  factory XyzModel.fromJson(Map<String, dynamic> json) =>
      _$XyzModelFromJson(json);
}
