// To parse this JSON data, do
//
//     final languageModel = languageModelFromJson(jsonString);

import 'dart:convert';

LanguageModel languageModelFromJson(String str) => LanguageModel.fromJson(json.decode(str));

String languageModelToJson(LanguageModel data) => json.encode(data.toJson());

class LanguageModel {
  bool? status;
  String? en;
  String? hi;

  LanguageModel({
    this.status,
    this.en,
    this.hi,
  });

  LanguageModel copyWith({
    bool? status,
    String? en,
    String? hi,
  }) =>
      LanguageModel(
        status: status ?? this.status,
        en: en ?? this.en,
        hi: hi ?? this.hi,
      );

  factory LanguageModel.fromJson(Map<String, dynamic> json) => LanguageModel(
    status: json["status"],
    en: json["en"],
    hi: json["hi"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "en": en,
    "hi": hi,
  };
}
