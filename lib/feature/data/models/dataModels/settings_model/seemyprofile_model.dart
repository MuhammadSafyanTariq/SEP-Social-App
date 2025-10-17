// To parse this JSON data, do
//
//     final seemyprofileModel = seemyprofileModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'seemyprofile_model.freezed.dart';
part 'seemyprofile_model.g.dart';

SeemyprofileModel seemyprofileModelFromJson(String str) =>
    SeemyprofileModel.fromJson(json.decode(str));

String seemyprofileModelToJson(SeemyprofileModel data) =>
    json.encode(data.toJson());

@freezed
class SeemyprofileModel with _$SeemyprofileModel {
  const factory SeemyprofileModel({
    bool? status,
    int? code,
    String? message,
    Data? data,
  }) = _SeemyprofileModel;

  factory SeemyprofileModel.fromJson(Map<String, dynamic> json) =>
      _$SeemyprofileModelFromJson(json);
}

@freezed
class Data with _$Data {
  const factory Data({
    String? id,
    String? name,
    String? email,
    String? password,
    String? role,
    String? phone,
    String? dob,
    String? gender,
    String? createdAt,
    String? updatedAt,
    int? v,
    dynamic otp,
    String? image,
    String? seeMyProfile,
    String? shareMyPost,
  }) = _Data;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
}
