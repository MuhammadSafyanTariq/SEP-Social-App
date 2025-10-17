import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'poll_list_model.freezed.dart';
part 'poll_list_model.g.dart';

PollListModel pollListModelFromJson(String str) =>
    PollListModel.fromJson(json.decode(str));

String pollListModelToJson(PollListModel data) => json.encode(data.toJson());

@freezed
class PollListModel with _$PollListModel {
  const factory PollListModel({
    String? id,
    String? userId,
    String? categoryId,
    String? content,
    Location? location,
    String? country,
    List<FileElement>? files,
    String? fileType,
    int? duration,
    List<Option>? options,
    List<Vote>? votes,
    String? createdAt,
    String? updatedAt,
    int? v,
    User? user,
    int? likeCount,
    int? videoCount,
    int? commentCount,
    bool? isLikedByUser,
  }) = _PollListModel;

  factory PollListModel.fromJson(Map<String, dynamic> json) =>
      _$PollListModelFromJson(json);
}

@freezed
class Option with _$Option {
  const factory Option({
    String? id,
    String? name,
    String? image,
    int? voteCount,
  }) = _Option;

  factory Option.fromJson(Map<String, dynamic> json) => _$OptionFromJson(json);
}

@freezed
class User with _$User {
  const factory User({
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
    dynamic otp,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
class FileElement with _$FileElement {
  const factory FileElement({String? file, String? type, String? id}) =
      _FileElement;

  factory FileElement.fromJson(Map<String, dynamic> json) =>
      _$FileElementFromJson(json);
}

@freezed
class Location with _$Location {
  const factory Location({String? type, List<double>? coordinates}) = _Location;

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
}

@freezed
class Vote with _$Vote {
  const factory Vote({
    String? id,
    String? userId,
    String? postId,
    String? optionId,
    String? createdAt,
    String? updatedAt,
    int? v,
  }) = _Vote;

  factory Vote.fromJson(Map<String, dynamic> json) => _$VoteFromJson(json);
}
