// To parse this JSON data, do
//
//     final recentChatModel = recentChatModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'recent_chat_model.freezed.dart';
part 'recent_chat_model.g.dart';

RecentChatModel recentChatModelFromJson(String str) => RecentChatModel.fromJson(json.decode(str));

String recentChatModelToJson(RecentChatModel data) => json.encode(data.toJson());

@freezed
class RecentChatModel with _$RecentChatModel {
  const factory RecentChatModel({
    @JsonKey(name: "_id")
    String? id,
    @JsonKey(name: "groupName")
    dynamic groupName,
    @JsonKey(name: "archived")
    bool? archived,
    @JsonKey(name: "users")
    List<String>? users,
    @JsonKey(name: "isDeleted")
    dynamic isDeleted,
    @JsonKey(name: "admins")
    List<dynamic>? admins,
    @JsonKey(name: "userDetails")
    List<UserDetail>? userDetails,
    @JsonKey(name: "latestMessage")
    LatestMessage? latestMessage,
    @JsonKey(name: "updatedAt")
    String? updatedAt,
    @JsonKey(name: "unreadCount") Map<String, int>? unreadCount,
    @JsonKey(name: "lastSeen")
    LastSeen? lastSeen,
  }) = _RecentChatModel;

  factory RecentChatModel.fromJson(Map<String, dynamic> json) => _$RecentChatModelFromJson(json);
}

@freezed
class LastSeen with _$LastSeen {
  const factory LastSeen({
    @JsonKey(name: "67a4923ad27b11f5bb680d91")
    String? the67A4923Ad27B11F5Bb680D91,
  }) = _LastSeen;

  factory LastSeen.fromJson(Map<String, dynamic> json) => _$LastSeenFromJson(json);
}

@freezed
class LatestMessage with _$LatestMessage {
  const factory LatestMessage({
    @JsonKey(name: "content")
    String? content,
    @JsonKey(name: "senderTime")
    String? senderTime,
  }) = _LatestMessage;

  factory LatestMessage.fromJson(Map<String, dynamic> json) => _$LatestMessageFromJson(json);
}

@freezed
class UnreadCount with _$UnreadCount {
  const factory UnreadCount({
    @JsonKey(name: "67a4923ad27b11f5bb680d91")
    int? the67A4923Ad27B11F5Bb680D91,
    @JsonKey(name: "67a34e3bc7aea8a744b35519")
    int? the67A34E3Bc7Aea8A744B35519,
  }) = _UnreadCount;

  factory UnreadCount.fromJson(Map<String, dynamic> json) => _$UnreadCountFromJson(json);
}

@freezed
class UserDetail with _$UserDetail {
  const factory UserDetail({
    @JsonKey(name: "_id")
    String? id,
    @JsonKey(name: "name")
    String? name,
    @JsonKey(name: "image")
    String? image,
  }) = _UserDetail;

  factory UserDetail.fromJson(Map<String, dynamic> json) => _$UserDetailFromJson(json);
}
