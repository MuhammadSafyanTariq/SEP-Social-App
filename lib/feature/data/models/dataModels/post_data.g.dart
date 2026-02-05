// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PostDataImpl _$$PostDataImplFromJson(Map<String, dynamic> json) =>
    _$PostDataImpl(
      id: json['_id'] as String?,
      userId: json['userId'] as String?,
      categoryId: json['categoryId'] as String?,
      content: json['content'] as String?,
      location: json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
      country: json['country'] as String?,
      files:
          (json['files'] as List<dynamic>?)
              ?.map((e) => FileElement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      fileType: json['fileType'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      options: json['options'] == null
          ? const []
          : const OptionFieldConverter().fromJson(json['options']),
      votes: json['votes'] == null
          ? const []
          : const VoteFieldConverter().fromJson(json['votes']),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      v: (json['v'] as num?)?.toInt(),
      user: json['user'] == null
          ? const []
          : const UserFieldConverter().fromJson(json['user']),
      likeCount: (json['likeCount'] as num?)?.toInt(),
      videoCount: (json['videoCount'] as num?)?.toInt(),
      commentCount: (json['commentCount'] as num?)?.toInt(),
      isLikedByUser: json['isLikedByUser'] as bool?,
      isSaved: json['isSaved'] as bool?,
      savedAt: json['savedAt'] as String?,
      likes: json['likes'] as List<dynamic>? ?? const [],
      comments: json['comments'] as List<dynamic>? ?? const [],
    );

Map<String, dynamic> _$$PostDataImplToJson(_$PostDataImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'userId': instance.userId,
      'categoryId': instance.categoryId,
      'content': instance.content,
      'location': instance.location,
      'country': instance.country,
      'files': instance.files,
      'fileType': instance.fileType,
      'duration': instance.duration,
      'options': const OptionFieldConverter().toJson(instance.options),
      'votes': const VoteFieldConverter().toJson(instance.votes),
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'v': instance.v,
      'user': const UserFieldConverter().toJson(instance.user),
      'likeCount': instance.likeCount,
      'videoCount': instance.videoCount,
      'commentCount': instance.commentCount,
      'isLikedByUser': instance.isLikedByUser,
      'isSaved': instance.isSaved,
      'savedAt': instance.savedAt,
      'likes': instance.likes,
      'comments': instance.comments,
    };

_$OptionImpl _$$OptionImplFromJson(Map<String, dynamic> json) => _$OptionImpl(
  id: json['_id'] as String?,
  name: json['name'] as String?,
  image: json['image'] as String?,
  voteCount: (json['voteCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$$OptionImplToJson(_$OptionImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'image': instance.image,
      'voteCount': instance.voteCount,
    };

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: json['_id'] as String?,
  name: json['name'] as String?,
  email: json['email'] as String?,
  password: json['password'] as String?,
  role: json['role'] as String?,
  phone: json['phone'] as String?,
  dob: json['dob'] as String?,
  gender: json['gender'] as String?,
  seeMyProfile: json['seeMyProfile'] as String?,
  shareMyPost: json['shareMyPost'] as String?,
  image: json['image'] as String?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
  v: (json['__v'] as num?)?.toInt(),
  isNotification: json['isNotification'] as bool?,
  otp: json['otp'],
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'role': instance.role,
      'phone': instance.phone,
      'dob': instance.dob,
      'gender': instance.gender,
      'seeMyProfile': instance.seeMyProfile,
      'shareMyPost': instance.shareMyPost,
      'image': instance.image,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      '__v': instance.v,
      'isNotification': instance.isNotification,
      'otp': instance.otp,
    };

_$FileElementImpl _$$FileElementImplFromJson(Map<String, dynamic> json) =>
    _$FileElementImpl(
      file: json['file'] as String?,
      type: json['type'] as String?,
      id: json['_id'] as String?,
      thumbnail: json['thumbnail'] as String?,
      x: (json['x'] as num?)?.toDouble(),
      y: (json['y'] as num?)?.toDouble(),
      qualities: (json['qualities'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      availableQualities: (json['availableQualities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$FileElementImplToJson(_$FileElementImpl instance) =>
    <String, dynamic>{
      'file': instance.file,
      'type': instance.type,
      '_id': instance.id,
      'thumbnail': instance.thumbnail,
      'x': instance.x,
      'y': instance.y,
      'qualities': instance.qualities,
      'availableQualities': instance.availableQualities,
    };

_$LocationImpl _$$LocationImplFromJson(Map<String, dynamic> json) =>
    _$LocationImpl(
      type: json['type'] as String?,
      coordinates: (json['coordinates'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$$LocationImplToJson(_$LocationImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'coordinates': instance.coordinates,
    };

_$VoteImpl _$$VoteImplFromJson(Map<String, dynamic> json) => _$VoteImpl(
  id: _voteListItemToString(json['_id']),
  userId: _voteListItemToString(json['userId']),
  postId: _voteListItemToString(json['postId']),
  optionId: _voteListItemToString(json['optionId']),
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
  v: (json['__v'] as num?)?.toInt(),
);

Map<String, dynamic> _$$VoteImplToJson(_$VoteImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'userId': instance.userId,
      'postId': instance.postId,
      'optionId': instance.optionId,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      '__v': instance.v,
    };
