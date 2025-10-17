// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'login_model.freezed.dart';
part 'login_model.g.dart';

LoginModel loginModelFromJson(String str) =>
    LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

@freezed
class LoginModel with _$LoginModel {
  const factory LoginModel({
    bool? status,
    int? code,
    String? message,
    Data? data,
  }) = _LoginModel;

  factory LoginModel.fromJson(Map<String, dynamic> json) =>
      _$LoginModelFromJson(json);
}

@freezed
class Data with _$Data {
  const factory Data({User? user, String? token}) = _Data;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
}

@freezed
class User with _$User {
  const factory User({
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
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
