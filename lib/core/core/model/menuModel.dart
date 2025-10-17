// To parse this JSON data, do
//
//     final menuModel = menuModelFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sep/utils/extensions/extensions.dart';


MenuModel menuModelFromJson(String str) => MenuModel.fromJson(json.decode(str));

String menuModelToJson(MenuModel data) => json.encode(data.toJson());

class MenuModel {
  bool? status;
  String? active;
  String? inActive;
  String? nameEn;
  String? nameHi;
  int? id;
  String? idString;

  String? label;
  bool? hasSuffixArrow;
  Widget? child;
  var key;

  MenuModel({
    this.status,
    this.active,
    this.inActive,
    this.nameEn,
    this.nameHi,
    this.id,
    this.label,
    this.hasSuffixArrow,
    this.child,
    this.key,
    this.idString
  });

  MenuModel copyWith({
    bool? status,
    String? active,
    String? inActive,
    String? nameEn,
    String? nameHi,
    int? id,
    String? idString,
    String? label,
    bool? hasSuffixArrow,
    Widget? child,
  }) =>
      MenuModel(
        status: status ?? this.status,
        active: active ?? this.active,
        inActive: inActive ?? this.inActive,
        nameEn: nameEn ?? this.nameEn,
        nameHi: nameHi ?? this.nameHi,
        id: id ?? this.id,
        label: label ?? this.label,
        hasSuffixArrow: hasSuffixArrow ?? this.hasSuffixArrow,
        child: child ?? this.child,
        idString: idString ?? this.idString,
      );

  factory MenuModel.fromJson(Map<String, dynamic> json) => MenuModel(
    status: json["status"],
    active: json["active"],
    inActive: json["inActive"],
    nameEn: json["nameEn"],
    nameHi: json["nameHi"],
    id: json["id"],
    label: json["label"],
    hasSuffixArrow: json["hasSuffixArrow"],
    child: json["child"],
    idString: json["idString"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "active": active,
    "inActive": inActive,
    "nameEn": nameEn,
    "nameHi": nameHi,
    "id": id,
    "label": label,
    "hasSuffixArrow": hasSuffixArrow,
    "child": child,
    "idString": idString,
  };


  Map<String, dynamic> sendFeedbackJsonRequest() => {
    "title": label,
    "message": nameEn,
  };

  Map<String, dynamic> updateNotificationSettingJsonRequest() => {
    key:status ?? false
    // "pushNotification": label,
    // "chatAndMessages": nameEn,
    // "agentAndBrokerNotifications": nameEn,
    // "feedBackAndSupport": nameEn,
    // "propertyAlerts": nameEn,
  };

  bool get isFeedbackValid => label.isNotNullEmpty && nameEn.isNotNullEmpty;

  MenuModel get feedBackEr => MenuModel(
    label: label!.isNotNullEmpty ? null : 'Please select feedback type',
    nameEn: nameEn.isNotNullEmpty ? null :'Please enter feedback message'
  );





}
