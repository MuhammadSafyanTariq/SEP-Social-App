// To parse this JSON data, do
//
//     final feedbackModel = feedbackModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'feedback_model.freezed.dart';
part 'feedback_model.g.dart';

FeedbackModel feedbackModelFromJson(String str) =>
    FeedbackModel.fromJson(json.decode(str));

String feedbackModelToJson(FeedbackModel data) => json.encode(data.toJson());

@freezed
class FeedbackModel with _$FeedbackModel {
  const factory FeedbackModel({
    bool? status,
    int? code,
    String? message,
    Data? data,
  }) = _FeedbackModel;

  factory FeedbackModel.fromJson(Map<String, dynamic> json) =>
      _$FeedbackModelFromJson(json);
}

@freezed
class Data with _$Data {
  const factory Data({
    String? title,
    String? description,
    String? image,
    String? id,
    String? createdAt,
    String? updatedAt,
    int? v,
  }) = _Data;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
}
