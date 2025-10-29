// To parse this JSON data, do
//
//     final socialloginModel = socialloginModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

import '../profile_data/profile_data_model.dart';

part 'sociallogin_model.freezed.dart';
part 'sociallogin_model.g.dart';

SocialloginModel socialloginModelFromJson(String str) =>
    SocialloginModel.fromJson(json.decode(str));

String socialloginModelToJson(SocialloginModel data) =>
    json.encode(data.toJson());

@freezed
class SocialloginModel with _$SocialloginModel {
  const factory SocialloginModel({
    bool? status,
    int? code,
    String? message,
    Data? data,
  }) = _SocialloginModel;

  factory SocialloginModel.fromJson(Map<String, dynamic> json) =>
      _$SocialloginModelFromJson(json);
}

@freezed
class Data with _$Data {
  const factory Data({ProfileDataModel? user, String? token}) = _Data;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
}
