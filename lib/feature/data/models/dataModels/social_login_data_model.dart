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
    @JsonKey(name: '_id') String? id,
    String? name,
    String? username,
    String? email,
    String? role,
    String? gender,
    dynamic dob,
    String? countryCode,
    String? country,
    String? phone,
    String? website,
    String? bio,
    String? socialType,
    String? socialId,
    String? deviceType,
    String? deviceToken,
    String? stripeCustomerId,
    String? stripeAccountId,
    double? walletBalance,
    List<dynamic>? followers,
    List<dynamic>? following,
    List<dynamic>? blockUser,
    bool? isNotification,
    bool? isOnline,
    bool? isActive,
    bool? isBlocked,
    bool? isBlockedByAdmin,
    String? seeMyProfile,
    String? shareMyPost,
    bool? isDelete,
    String? createdAt,
    String? updatedAt,
    @JsonKey(name: '__v') int? v,
    dynamic image,
    // Legacy fields for backwards compatibility
    bool? isProfileComplete,
    String? password,
    dynamic otp,
    dynamic otpExpiry,
  }) = _UserData;

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);
}
