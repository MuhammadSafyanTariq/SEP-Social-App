// To parse this JSON data, do
//
//     final faqItemModel = faqItemModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'faq_item_model.freezed.dart';
part 'faq_item_model.g.dart';

FaqItemModel faqItemModelFromJson(String str) =>
    FaqItemModel.fromJson(json.decode(str));

String faqItemModelToJson(FaqItemModel data) => json.encode(data.toJson());

@freezed
class FaqItemModel with _$FaqItemModel {
  const factory FaqItemModel({
    String? id,
    String? question,
    String? answer,
    String? createdAt,
    String? updatedAt,
    int? v,
    bool? isExpanded,
    bool? showFullAnswer,
  }) = _FaqItemModel;

  factory FaqItemModel.fromJson(Map<String, dynamic> json) =>
      _$FaqItemModelFromJson(json);
}
