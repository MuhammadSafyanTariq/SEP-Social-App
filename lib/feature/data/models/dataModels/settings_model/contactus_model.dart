// To parse this JSON data, do
//
//     final contactusModel = contactusModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'contactus_model.freezed.dart';
part 'contactus_model.g.dart';

ContactusModel contactusModelFromJson(String str) => ContactusModel.fromJson(json.decode(str));

String contactusModelToJson(ContactusModel data) => json.encode(data.toJson());

@freezed
class ContactusModel with _$ContactusModel {
  const factory ContactusModel({
    @JsonKey(name: "status")
     bool? status,
    @JsonKey(name: "code")
     int? code,
    @JsonKey(name: "message")
     String? message,
    @JsonKey(name: "data")
     Data? data,
  }) = _ContactusModel;

  factory ContactusModel.fromJson(Map<String, dynamic> json) => _$ContactusModelFromJson(json);
}

@freezed
class Data with _$Data {
  const factory Data({
    @JsonKey(name: "_id")
     String? id,
    @JsonKey(name: "title")
     String? title,
    @JsonKey(name: "description")
     String? description,
    @JsonKey(name: "type")
     String? type,
    @JsonKey(name: "createdAt")
     String? createdAt,
    @JsonKey(name: "updatedAt")
     String? updatedAt,
    @JsonKey(name: "__v")
     int? v,
  }) = _Data;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
}
