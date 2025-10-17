// To parse this JSON data, do
//
//     final faqModel = faqModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'faq_model.freezed.dart';
part 'faq_model.g.dart';

FaqModel faqModelFromJson(String str) => FaqModel.fromJson(json.decode(str));

String faqModelToJson(FaqModel data) => json.encode(data.toJson());

@freezed
class FaqModel with _$FaqModel {
  const factory FaqModel({
    bool? status,
    int? code,
    String? message,
    Data? data,
  }) = _FaqModel;

  factory FaqModel.fromJson(Map<String, dynamic> json) =>
      _$FaqModelFromJson(json);
}

@freezed
class Data with _$Data {
  const factory Data({List<Datum>? data, int? totalItems}) = _Data;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
}

@freezed
class Datum with _$Datum {
  const factory Datum({
    String? id,
    String? question,
    String? answer,
    String? createdAt,
    String? updatedAt,
    int? v,
  }) = _Datum;

  factory Datum.fromJson(Map<String, dynamic> json) => _$DatumFromJson(json);
}
