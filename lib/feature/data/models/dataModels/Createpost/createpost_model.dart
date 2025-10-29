// To parse this JSON data, do
//
//     final createpostModel = createpostModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'createpost_model.freezed.dart';
part 'createpost_model.g.dart';

CreatepostModel createpostModelFromJson(String str) =>
    CreatepostModel.fromJson(json.decode(str));

String createpostModelToJson(CreatepostModel data) =>
    json.encode(data.toJson());

@freezed
class CreatepostModel with _$CreatepostModel {
  const factory CreatepostModel({
    bool? status,
    int? code,
    String? message,
    Data? data,
  }) = _CreatepostModel;

  factory CreatepostModel.fromJson(Map<String, dynamic> json) =>
      _$CreatepostModelFromJson(json);
}

@freezed
class Data with _$Data {
  const factory Data({
    String? userId,
    String? categoryId,
    String? content,
    Location? location,
    List<FileElement>? files,
    String? fileType,
    @JsonKey(name: "_id") String? id,
    String? createdAt,
    String? updatedAt,
    @JsonKey(name: "__v") int? v,
  }) = _Data;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
}

@freezed
class FileElement with _$FileElement {
  const factory FileElement({
    String? file,
    String? type,
    @JsonKey(name: "_id") String? id,
  }) = _FileElement;

  factory FileElement.fromJson(Map<String, dynamic> json) =>
      _$FileElementFromJson(json);
}

@freezed
class Location with _$Location {
  const factory Location({String? type, List<double>? coordinates}) = _Location;

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
}
