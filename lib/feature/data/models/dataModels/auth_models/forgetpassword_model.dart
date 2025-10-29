// To parse this JSON data, do
//
//     final forgetpasswordModel = forgetpasswordModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'forgetpassword_model.freezed.dart';
part 'forgetpassword_model.g.dart';

ForgetpasswordModel forgetpasswordModelFromJson(String str) =>
    ForgetpasswordModel.fromJson(json.decode(str));

String forgetpasswordModelToJson(ForgetpasswordModel data) =>
    json.encode(data.toJson());

@freezed
class ForgetpasswordModel with _$ForgetpasswordModel {
  const factory ForgetpasswordModel({
    bool? status,
    int? code,
    String? message,
    Data? data,
  }) = _ForgetpasswordModel;

  factory ForgetpasswordModel.fromJson(Map<String, dynamic> json) =>
      _$ForgetpasswordModelFromJson(json);
}

@freezed
class Data with _$Data {
  const factory Data({String? id, int? otp}) = _Data;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
}
