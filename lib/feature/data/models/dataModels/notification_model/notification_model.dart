// To parse this JSON data, do
//
//     final notificationModel = notificationModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sep/utils/extensions/dateTimeUtils.dart';
import 'dart:convert';

import 'package:sep/utils/extensions/extensions.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

NotificationModel notificationModelFromJson(String str) =>
    NotificationModel.fromJson(json.decode(str));

String notificationModelToJson(NotificationModel data) =>
    json.encode(data.toJson());

@freezed
class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    bool? status,
    int? code,
    String? message,
    NotificationData? data,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}

@freezed
class NotificationData with _$NotificationData {
  const factory NotificationData({
    List<NotificationItem>? notifications,
    Pagination? pagination,
  }) = _NotificationData;

  factory NotificationData.fromJson(Map<String, dynamic> json) =>
      _$NotificationDataFromJson(json);
}

@freezed
class NotificationItem with _$NotificationItem {
  const factory NotificationItem({
    String? id,
    Sender? senderId,
    String? receiverId,
    String? notificationType,
    String? title,
    String? message,
    String? roomId,
    String? postId, // Keep postId field for post-related notifications
    String? status,
    bool? isRead,
    String? createdAt,
    String? updatedAt,
    int? v,
  }) = _NotificationItem;

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);
}

@freezed
class Sender with _$Sender {
  const factory Sender({String? id, String? name, String? image}) = _Sender;

  factory Sender.fromJson(Map<String, dynamic> json) => _$SenderFromJson(json);
}

@freezed
class Pagination with _$Pagination {
  const factory Pagination({
    int? currentPage,
    int? totalPages,
    int? totalNotifications,
  }) = _Pagination;

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);
}

extension NotificationItems on NotificationItem {
  DateTime? get localDate {
    if (!createdAt.isNotNullEmpty) return null;
    return createdAt!.yyyy_MM_ddTHH_mm_ssZ.toLocal();
  }
}
