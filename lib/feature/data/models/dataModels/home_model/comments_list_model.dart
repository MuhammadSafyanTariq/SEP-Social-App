// To parse this JSON data, do
//
//     final commentsListModel = commentsListModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'comments_list_model.freezed.dart';

part 'comments_list_model.g.dart';

CommentsListModel commentsListModelFromJson(String str) =>
    CommentsListModel.fromJson(json.decode(str));

String commentsListModelToJson(CommentsListModel data) =>
    json.encode(data.toJson());

@freezed
class CommentsListModel with _$CommentsListModel {
  const factory CommentsListModel({
    @JsonKey(name: "_id") String? id,
    @JsonKey(name: "userId") UserId? userId,
    @JsonKey(name: "replyUser") UserId? replyToUser,
    @JsonKey(name: "postId") String? postId,
    @JsonKey(name: "perantId") String? parentId,
    @JsonKey(name: "content") String? content,
    @JsonKey(name: "createdAt") String? createdAt,
    @JsonKey(name: "updatedAt") String? updatedAt,
    @JsonKey(name: "files") List<MediaFile>? files,
    @JsonKey(name: "__v") int? v,
    @JsonKey(name: "child") List<CommentsListModel>? child,
  }) = _CommentsListModel;


//   flutter: │ 🐛     },
// flutter: │ 🐛     "replyUser": {
// flutter: │ 🐛       "_id": "683958e23639c18d1202e381",
// flutter: │ 🐛       "name": "test",
// flutter: │ 🐛       "username": "",
// flutter: │ 🐛       "image": ""
// flutter: │ 🐛     },
// flutter: │ 🐛     "postId": "6844c6e7333df0d42544b9a9",
// flutter: │ 🐛     "perantId": "68481199c27cf0601dbe1948",




  factory CommentsListModel.fromJson(Map<String, dynamic> json) =>
      _$CommentsListModelFromJson(json);
}

@freezed
class UserId with _$UserId {
  const factory UserId({
    @JsonKey(name: "_id") String? id,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "image") String? image,
  }) = _UserId;

  factory UserId.fromJson(Map<String, dynamic> json) => _$UserIdFromJson(json);
}

@freezed
class MediaFile with _$MediaFile {
  const factory MediaFile({
    @JsonKey(name: "file") String? file,
    @JsonKey(name: "type") String? type,
    @JsonKey(name: "_id") String? id,
  }) = _MediaFile;

  factory MediaFile.fromJson(Map<String, dynamic> json) =>
      _$MediaFileFromJson(json);
}

// flutter: │ 🐛           {
// flutter: │ 🐛             "file": "/public/uploads/image_picker_F74D0A59-7DEC-4667-A3A2-DE72EBA6C64F-4231-000000C35646771E.jpg",
// flutter: │ 🐛             "type": "image",
// flutter: │ 🐛             "_id": "67caf99c6573b1a19ee44051"
// flutter: │ 🐛           }
