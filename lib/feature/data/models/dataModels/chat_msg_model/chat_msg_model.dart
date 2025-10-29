// To parse this JSON data, do
//
//     final chatMsgModel = chatMsgModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

import '../../../../presentation/controller/agora_chat_ctrl.dart';

part 'chat_msg_model.freezed.dart';
part 'chat_msg_model.g.dart';

ChatMsgModel chatMsgModelFromJson(String str) =>
    ChatMsgModel.fromJson(json.decode(str));

String chatMsgModelToJson(ChatMsgModel data) => json.encode(data.toJson());

@freezed
class ChatMsgModel with _$ChatMsgModel {
  const factory ChatMsgModel({
    @JsonKey(name: '_id') String? id,
    String? chat,
    Sender? sender,
    String? content,
    dynamic isDeleted,
    String? mediaType,
    List<dynamic>? readBy,
    List<dynamic>? mediaUrl,
    String? channelId,
    String? createdAt,
    String? updatedAt,
    @JsonKey(name: '__v') int? v,
    String? senderTime,
  }) = _ChatMsgModel;

  factory ChatMsgModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMsgModelFromJson(json);
}

extension OnChatMsgModel on ChatMsgModel {
  bool get isLiveInvitation =>
      mediaType == LiveRequestStatus.inviteForLive.name;
}

@freezed
class Sender with _$Sender {
  const factory Sender({@JsonKey(name: '_id') String? id, String? name}) =
      _Sender;

  factory Sender.fromJson(Map<String, dynamic> json) => _$SenderFromJson(json);
}
