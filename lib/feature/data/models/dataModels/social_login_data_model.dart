// To parse this JSON data, do
//
//     final socialLoginDataModel = socialLoginDataModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'social_login_data_model.freezed.dart';
part 'social_login_data_model.g.dart';

SocialLoginDataModel socialLoginDataModelFromJson(String str) =>
    SocialLoginDataModel.fromJson(json.decode(str));

String socialLoginDataModelToJson(SocialLoginDataModel data) =>
    json.encode(data.toJson());

@freezed
class SocialLoginDataModel with _$SocialLoginDataModel {
  const factory SocialLoginDataModel({
    bool? status,
    int? code,
    String? message,
    Data? data,
  }) = _SocialLoginDataModel;

  factory SocialLoginDataModel.fromJson(Map<String, dynamic> json) =>
      _$SocialLoginDataModelFromJson(json);
}

@freezed
class Data with _$Data {
  const factory Data({UserData? userData, String? token}) = _Data;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
}

@freezed
class UserData with _$UserData {
  const factory UserData({
    bool? isProfileComplete,
    int? id,
    String? name,
    String? email,
    dynamic phone,
    String? password,
    dynamic otp,
    dynamic otpExpiry,
    dynamic deviceToken,
    String? socialId,
    String? socialType,
    dynamic deviceType,
    dynamic image,
    String? createdAt,
    String? updatedAt,
  }) = _UserData;

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);
}
