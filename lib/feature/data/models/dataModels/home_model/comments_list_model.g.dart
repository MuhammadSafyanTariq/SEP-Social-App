// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comments_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommentsListModelImpl _$$CommentsListModelImplFromJson(
  Map<String, dynamic> json,
) => _$CommentsListModelImpl(
  id: json['_id'] as String?,
  userId: json['userId'] == null
      ? null
      : UserId.fromJson(json['userId'] as Map<String, dynamic>),
  replyToUser: json['replyUser'] == null
      ? null
      : UserId.fromJson(json['replyUser'] as Map<String, dynamic>),
  postId: json['postId'] as String?,
  parentId: json['perantId'] as String?,
  content: json['content'] as String?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
  files: (json['files'] as List<dynamic>?)
      ?.map((e) => MediaFile.fromJson(e as Map<String, dynamic>))
      .toList(),
  v: (json['__v'] as num?)?.toInt(),
  child: (json['child'] as List<dynamic>?)
      ?.map((e) => CommentsListModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$CommentsListModelImplToJson(
  _$CommentsListModelImpl instance,
) => <String, dynamic>{
  '_id': instance.id,
  'userId': instance.userId,
  'replyUser': instance.replyToUser,
  'postId': instance.postId,
  'perantId': instance.parentId,
  'content': instance.content,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'files': instance.files,
  '__v': instance.v,
  'child': instance.child,
};

_$UserIdImpl _$$UserIdImplFromJson(Map<String, dynamic> json) => _$UserIdImpl(
  id: json['_id'] as String?,
  name: json['name'] as String?,
  image: json['image'] as String?,
);

Map<String, dynamic> _$$UserIdImplToJson(_$UserIdImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'image': instance.image,
    };

_$MediaFileImpl _$$MediaFileImplFromJson(Map<String, dynamic> json) =>
    _$MediaFileImpl(
      file: json['file'] as String?,
      type: json['type'] as String?,
      id: json['_id'] as String?,
    );

Map<String, dynamic> _$$MediaFileImplToJson(_$MediaFileImpl instance) =>
    <String, dynamic>{
      'file': instance.file,
      'type': instance.type,
      '_id': instance.id,
    };
