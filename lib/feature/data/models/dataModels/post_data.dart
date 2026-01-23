import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'post_data.freezed.dart';
part 'post_data.g.dart';

PostData postDataFromJson(String str) => PostData.fromJson(json.decode(str));
String postDataToJson(PostData data) => json.encode(data.toJson());

@freezed
class PostData with _$PostData {
  const factory PostData({
    @JsonKey(name: '_id') String? id,
    String? userId,
    String? categoryId,
    String? content,
    Location? location,
    String? country,

    @Default([]) List<FileElement> files,
    String? fileType,
    int? duration,

    @OptionFieldConverter() @Default([]) List<Option> options,

    @VoteFieldConverter() @Default([]) List<Vote> votes,

    String? createdAt,
    String? updatedAt,
    int? v,

    @UserFieldConverter() @Default([]) List<User> user,

    int? likeCount,
    int? videoCount,
    int? commentCount,
    bool? isLikedByUser,
    bool? isSaved,
    String? savedAt,

    // New fields for rich API response
    @Default([]) List<dynamic>? likes,
    @Default([]) List<dynamic>? comments,
  }) = _PostData;

  factory PostData.fromJson(Map<String, dynamic> json) =>
      _$PostDataFromJson(json);
}

@freezed
class Option with _$Option {
  const factory Option({
    @JsonKey(name: "_id") String? id,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "image") String? image,
    @JsonKey(name: "voteCount") int? voteCount,
  }) = _Option;

  factory Option.fromJson(Map<String, dynamic> json) => _$OptionFromJson(json);
}

@freezed
class User with _$User {
  const factory User({
    @JsonKey(name: "_id") String? id,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "email") String? email,
    @JsonKey(name: "password") String? password,
    @JsonKey(name: "role") String? role,
    @JsonKey(name: "phone") String? phone,
    @JsonKey(name: "dob") String? dob,
    @JsonKey(name: "gender") String? gender,
    @JsonKey(name: "seeMyProfile") String? seeMyProfile,
    @JsonKey(name: "shareMyPost") String? shareMyPost,
    @JsonKey(name: "image") String? image,
    @JsonKey(name: "createdAt") String? createdAt,
    @JsonKey(name: "updatedAt") String? updatedAt,
    @JsonKey(name: "__v") int? v,
    @JsonKey(name: "isNotification") bool? isNotification,
    @JsonKey(name: "otp") dynamic otp,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
class FileElement with _$FileElement {
  const factory FileElement({
    @JsonKey(name: "file") String? file,
    @JsonKey(name: "type") String? type,
    @JsonKey(name: "_id") String? id,
    @JsonKey(name: "thumbnail") String? thumbnail,
    @JsonKey(name: "x") double? x,
    @JsonKey(name: "y") double? y,
  }) = _FileElement;

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
    @JsonKey(name: "_id", fromJson: _voteListItemToString) String? id,
    @JsonKey(name: "userId", fromJson: _voteListItemToString) String? userId,
    @JsonKey(name: "postId", fromJson: _voteListItemToString) String? postId,
    @JsonKey(name: "optionId", fromJson: _voteListItemToString)
    String? optionId,
    @JsonKey(name: "createdAt") String? createdAt,
    @JsonKey(name: "updatedAt") String? updatedAt,
    @JsonKey(name: "__v") int? v,
  }) = _Vote;

  factory Vote.fromJson(Map<String, dynamic> json) => _$VoteFromJson(json);
}

/// Convert dynamic vote field into String safely
String _voteListItemToString(dynamic data) {
  if (data == null) return '';
  if (data is List && data.isNotEmpty) return data.first.toString();
  return data.toString();
}

class OptionFieldConverter implements JsonConverter<List<Option>, dynamic> {
  const OptionFieldConverter();

  @override
  List<Option> fromJson(dynamic json) {
    if (json == null) return [];
    if (json is List) {
      return json
          .map((e) {
            if (e is Map<String, dynamic>) return Option.fromJson(e);
            if (e is Option) return e;
            return null;
          })
          .whereType<Option>()
          .toList();
    }
    if (json is Map<String, dynamic>) return [Option.fromJson(json)];
    if (json is Option) return [json];
    return [];
  }

  @override
  dynamic toJson(List<Option> options) =>
      options.map((e) => e.toJson()).toList();
}

class VoteFieldConverter implements JsonConverter<List<Vote>, dynamic> {
  const VoteFieldConverter();

  @override
  List<Vote> fromJson(dynamic json) {
    if (json == null) return [];
    if (json is List) {
      return json
          .map((e) {
            if (e is Map<String, dynamic>) return Vote.fromJson(e);
            if (e is Vote) return e;
            return null;
          })
          .whereType<Vote>()
          .toList();
    }
    if (json is Map<String, dynamic>) return [Vote.fromJson(json)];
    if (json is Vote) return [json];
    return [];
  }

  @override
  dynamic toJson(List<Vote> votes) => votes.map((e) => e.toJson()).toList();
}

class UserFieldConverter implements JsonConverter<List<User>, dynamic> {
  const UserFieldConverter();

  @override
  List<User> fromJson(dynamic json) {
    if (json == null) return [];
    if (json is List) {
      return json
          .map((e) {
            if (e is Map<String, dynamic>) return User.fromJson(e);
            if (e is String) return User(id: e);
            if (e is User) return e;
            return null;
          })
          .whereType<User>()
          .toList();
    }
    if (json is Map<String, dynamic>) return [User.fromJson(json)];
    if (json is String) return [User(id: json)];
    if (json is User) return [json];
    return [];
  }

  @override
  dynamic toJson(List<User> users) => users.map((e) => e.toJson()).toList();
}
