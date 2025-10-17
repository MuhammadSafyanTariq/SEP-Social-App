// To parse this JSON data, do
//
//     final likeModel = likeModelFromJson(jsonString);

import 'dart:convert';

LikeModel likeModelFromJson(String str) => LikeModel.fromJson(json.decode(str));

String likeModelToJson(LikeModel data) => json.encode(data.toJson());

class LikeModel {
  String? id;
  String? userId;
  String? categoryId;
  String? content;
  dynamic location;
  dynamic files;
  String? fileType;
  DateTime? startTime;
  DateTime? endTime;
  List<Option>? options;
  List<dynamic>? votes;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  List<User>? user;
  int? likeCount;
  int? commentCount;
  bool? isLikedByUser;
  LikedUserId? likedUserId;
  List<LikedUserId>? latestComments;

  LikeModel({
    this.id,
    this.userId,
    this.categoryId,
    this.content,
    this.location,
    this.files,
    this.fileType,
    this.startTime,
    this.endTime,
    this.options,
    this.votes,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.user,
    this.likeCount,
    this.commentCount,
    this.isLikedByUser,
    this.likedUserId,
    this.latestComments,
  });

  factory LikeModel.fromJson(Map<String, dynamic> json) => LikeModel(
    id: json["_id"],
    userId: json["userId"],
    categoryId: json["categoryId"],
    content: json["content"],
    location: json["location"],
    files: json["files"],
    fileType: json["fileType"],
    startTime: json["startTime"] == null ? null : DateTime.parse(json["startTime"]),
    endTime: json["endTime"] == null ? null : DateTime.parse(json["endTime"]),
    options: json["options"] == null ? [] : List<Option>.from(json["options"]!.map((x) => Option.fromJson(x))),
    votes: json["votes"] == null ? [] : List<dynamic>.from(json["votes"]!.map((x) => x)),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    user: json["user"] == null ? [] : List<User>.from(json["user"]!.map((x) => User.fromJson(x))),
    likeCount: json["likeCount"],
    commentCount: json["commentCount"],
    isLikedByUser: json["isLikedByUser"],
    likedUserId: json["likedUserId"] == null ? null : LikedUserId.fromJson(json["likedUserId"]),
    latestComments: json["latestComments"] == null ? [] : List<LikedUserId>.from(json["latestComments"]!.map((x) => LikedUserId.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "categoryId": categoryId,
    "content": content,
    "location": location,
    "files": files,
    "fileType": fileType,
    "startTime": startTime?.toIso8601String(),
    "endTime": endTime?.toIso8601String(),
    "options": options == null ? [] : List<dynamic>.from(options!.map((x) => x.toJson())),
    "votes": votes == null ? [] : List<dynamic>.from(votes!.map((x) => x)),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "user": user == null ? [] : List<dynamic>.from(user!.map((x) => x.toJson())),
    "likeCount": likeCount,
    "commentCount": commentCount,
    "isLikedByUser": isLikedByUser,
    "likedUserId": likedUserId?.toJson(),
    "latestComments": latestComments == null ? [] : List<dynamic>.from(latestComments!.map((x) => x.toJson())),
  };
}

class LikedUserId {
  String? id;
  String? userId;
  String? postId;
  String? content;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  LikedUserId({
    this.id,
    this.userId,
    this.postId,
    this.content,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory LikedUserId.fromJson(Map<String, dynamic> json) => LikedUserId(
    id: json["_id"],
    userId: json["userId"],
    postId: json["postId"],
    content: json["content"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "postId": postId,
    "content": content,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class Option {
  String? id;
  String? name;
  String? image;
  int? voteCount;

  Option({
    this.id,
    this.name,
    this.image,
    this.voteCount,
  });

  factory Option.fromJson(Map<String, dynamic> json) => Option(
    id: json["_id"],
    name: json["name"],
    image: json["image"],
    voteCount: json["voteCount"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "image": image,
    "voteCount": voteCount,
  };
}

class User {
  String? id;
  String? name;
  String? email;
  String? password;
  String? role;
  String? phone;
  DateTime? dob;
  String? gender;
  String? seeMyProfile;
  String? shareMyPost;
  String? image;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  bool? isNotification;
  dynamic otp;

  User({
    this.id,
    this.name,
    this.email,
    this.password,
    this.role,
    this.phone,
    this.dob,
    this.gender,
    this.seeMyProfile,
    this.shareMyPost,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.isNotification,
    this.otp,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["_id"],
    name: json["name"],
    email: json["email"],
    password: json["password"],
    role: json["role"],
    phone: json["phone"],
    dob: json["dob"] == null ? null : DateTime.parse(json["dob"]),
    gender: json["gender"],
    seeMyProfile: json["seeMyProfile"],
    shareMyPost: json["shareMyPost"],
    image: json["image"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    isNotification: json["isNotification"],
    otp: json["otp"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "email": email,
    "password": password,
    "role": role,
    "phone": phone,
    "dob": dob?.toIso8601String(),
    "gender": gender,
    "seeMyProfile": seeMyProfile,
    "shareMyPost": shareMyPost,
    "image": image,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "isNotification": isNotification,
    "otp": otp,
  };
}
