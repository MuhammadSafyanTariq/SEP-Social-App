// To parse this JSON data, do
//
//     final notificationModel = notificationModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

NotificationModel notificationModelFromJson(String str) =>
    NotificationModel.fromJson(json.decode(str));

String notificationModelToJson(NotificationModel data) =>
    json.encode(data.toJson());

@freezed
class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    String? id,
    String? name,
    String? email,
    String? password,
    String? role,
    String? phone,
    String? dob,
    String? gender,
    String? seeMyProfile,
    String? shareMyPost,
    String? image,
    String? createdAt,
    String? updatedAt,
    int? v,
    bool? isNotification,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}
