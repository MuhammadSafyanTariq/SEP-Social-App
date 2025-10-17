// To parse this JSON data, do
//
//     final contactusnewModel = contactusnewModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'contactusnew_model.freezed.dart';
part 'contactusnew_model.g.dart';

ContactusnewModel contactusnewModelFromJson(String str) =>
    ContactusnewModel.fromJson(json.decode(str));

String contactusnewModelToJson(ContactusnewModel data) =>
    json.encode(data.toJson());

@freezed
class ContactusnewModel with _$ContactusnewModel {
  const factory ContactusnewModel({
    @JsonKey(name: "status") bool? status,
    @JsonKey(name: "code") int? code,
    @JsonKey(name: "message") String? message,
    @JsonKey(name: "data") Data? data,
  }) = _ContactusnewModel;

  factory ContactusnewModel.fromJson(Map<String, dynamic> json) =>
      _$ContactusnewModelFromJson(json);
}

@freezed
class Data with _$Data {
  const factory Data({
    @JsonKey(name: "email") String? email,
    @JsonKey(name: "title") String? title,
    @JsonKey(name: "description") String? description,
    @JsonKey(name: "_id") String? id,
    @JsonKey(name: "createdAt") String? createdAt,
    @JsonKey(name: "updatedAt") String? updatedAt,
    @JsonKey(name: "__v") int? v,
  }) = _Data;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
}
