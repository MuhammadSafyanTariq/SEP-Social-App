// To parse this JSON data, do
//
//     final emailvalidModel = emailvalidModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'emailvalid_model.freezed.dart';
part 'emailvalid_model.g.dart';

EmailvalidModel emailvalidModelFromJson(String str) =>
    EmailvalidModel.fromJson(json.decode(str));

String emailvalidModelToJson(EmailvalidModel data) =>
    json.encode(data.toJson());

@freezed
class EmailvalidModel with _$EmailvalidModel {
  const factory EmailvalidModel({
    bool? status,
    int? code,
    String? message,
    required Data data,
  }) = _EmailvalidModel;

  factory EmailvalidModel.fromJson(Map<String, dynamic> json) =>
      _$EmailvalidModelFromJson(json);
}

@freezed
class Data with _$Data {
  const factory Data() = _Data;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
}
