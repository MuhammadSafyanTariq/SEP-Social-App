// To parse this JSON data, do
//
//     final signupModel = signupModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'signup_model.freezed.dart';
part 'signup_model.g.dart';

SignupModel signupModelFromJson(String str) =>
    SignupModel.fromJson(json.decode(str));

String signupModelToJson(SignupModel data) => json.encode(data.toJson());

@freezed
class SignupModel with _$SignupModel {
  const factory SignupModel({
    bool? status,
    int? code,
    String? message,
    Data? data,
  }) = _SignupModel;

  factory SignupModel.fromJson(Map<String, dynamic> json) =>
      _$SignupModelFromJson(json);
}

@freezed
class Data with _$Data {
  const factory Data({
    String? name,
    String? email,
    String? password,
    String? role,
    String? phone,
    String? dob,
    String? gender,
    String? id,
    String? createdAt,
    String? updatedAt,
    int? v,
  }) = _Data;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
}
