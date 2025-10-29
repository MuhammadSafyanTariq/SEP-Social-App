// To parse this JSON data, do
//
//     final liveStreamMessageModel = liveStreamMessageModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'live_stream_message_model.freezed.dart';
part 'live_stream_message_model.g.dart';

LiveStreamMessageModel liveStreamMessageModelFromJson(String str) =>
    LiveStreamMessageModel.fromJson(json.decode(str));

String liveStreamMessageModelToJson(LiveStreamMessageModel data) =>
    json.encode(data.toJson());

@freezed
class LiveStreamMessageModel with _$LiveStreamMessageModel {
  const factory LiveStreamMessageModel({
    String? id,
    String? type,
    String? message,
    String? timestamp,
    String? userId,
    String? userName,
    String? userRole,
    int? participantCount,
  }) = _LiveStreamMessageModel;

  factory LiveStreamMessageModel.fromJson(Map<String, dynamic> json) =>
      _$LiveStreamMessageModelFromJson(json);
}
