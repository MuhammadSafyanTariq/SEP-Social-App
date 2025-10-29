// To parse this JSON data, do
//
//     final getTemplateInfoModel = getTemplateInfoModelFromJson(jsonString);

import 'dart:convert';

GetTemplateInfoModel getTemplateInfoModelFromJson(String str) => GetTemplateInfoModel.fromJson(json.decode(str));

String getTemplateInfoModelToJson(GetTemplateInfoModel data) => json.encode(data.toJson());

class GetTemplateInfoModel {
  bool? status;
  int? code;
  String? message;
  List<Datum>? data;

  GetTemplateInfoModel({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory GetTemplateInfoModel.fromJson(Map<String, dynamic> json) => GetTemplateInfoModel(
    status: json["status"],
    code: json["code"],
    message: json["message"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "code": code,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  int? id;
  String? name;
  String? description;
  String? htmlContent;
  String? type;
  String? createdAt;
  String? updatedAt;

  Datum({
    this.id,
    this.name,
    this.description,
    this.htmlContent,
    this.type,
    this.createdAt,
    this.updatedAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    htmlContent: json["htmlContent"],
    type: json["type"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "htmlContent": htmlContent,
    "type": type,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}
