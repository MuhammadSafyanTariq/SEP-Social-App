// To parse this JSON data, do
//
//     final imageuploadModel = imageuploadModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'imageupload_model.freezed.dart';
part 'imageupload_model.g.dart';

ImageuploadModel imageuploadModelFromJson(String str) =>
    ImageuploadModel.fromJson(json.decode(str));

String imageuploadModelToJson(ImageuploadModel data) =>
    json.encode(data.toJson());

@freezed
class ImageuploadModel with _$ImageuploadModel {
  const factory ImageuploadModel({
    @JsonKey(name: "status") bool? status,
    @JsonKey(name: "code") int? code,
    @JsonKey(name: "message") String? message,
    @JsonKey(name: "data") Data? data,
  }) = _ImageuploadModel;

  factory ImageuploadModel.fromJson(Map<String, dynamic> json) =>
      _$ImageuploadModelFromJson(json);
}

@freezed
class Data with _$Data {
  const factory Data({@JsonKey(name: "urls") List<String>? urls}) = _Data;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
}
