// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comments_list_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CommentsListModel _$CommentsListModelFromJson(Map<String, dynamic> json) {
  return _CommentsListModel.fromJson(json);
}

/// @nodoc
mixin _$CommentsListModel {
  @JsonKey(name: "_id")
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: "userId")
  UserId? get userId => throw _privateConstructorUsedError;
  @JsonKey(name: "replyUser")
  UserId? get replyToUser => throw _privateConstructorUsedError;
  @JsonKey(name: "postId")
  String? get postId => throw _privateConstructorUsedError;
  @JsonKey(name: "perantId")
  String? get parentId => throw _privateConstructorUsedError;
  @JsonKey(name: "content")
  String? get content => throw _privateConstructorUsedError;
  @JsonKey(name: "createdAt")
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: "updatedAt")
  String? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: "files")
  List<MediaFile>? get files => throw _privateConstructorUsedError;
  @JsonKey(name: "__v")
  int? get v => throw _privateConstructorUsedError;
  @JsonKey(name: "child")
  List<CommentsListModel>? get child => throw _privateConstructorUsedError;

  /// Serializes this CommentsListModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommentsListModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommentsListModelCopyWith<CommentsListModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentsListModelCopyWith<$Res> {
  factory $CommentsListModelCopyWith(
    CommentsListModel value,
    $Res Function(CommentsListModel) then,
  ) = _$CommentsListModelCopyWithImpl<$Res, CommentsListModel>;
  @useResult
  $Res call({
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
  });

  $UserIdCopyWith<$Res>? get userId;
  $UserIdCopyWith<$Res>? get replyToUser;
}

/// @nodoc
class _$CommentsListModelCopyWithImpl<$Res, $Val extends CommentsListModel>
    implements $CommentsListModelCopyWith<$Res> {
  _$CommentsListModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommentsListModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? replyToUser = freezed,
    Object? postId = freezed,
    Object? parentId = freezed,
    Object? content = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? files = freezed,
    Object? v = freezed,
    Object? child = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as UserId?,
            replyToUser: freezed == replyToUser
                ? _value.replyToUser
                : replyToUser // ignore: cast_nullable_to_non_nullable
                      as UserId?,
            postId: freezed == postId
                ? _value.postId
                : postId // ignore: cast_nullable_to_non_nullable
                      as String?,
            parentId: freezed == parentId
                ? _value.parentId
                : parentId // ignore: cast_nullable_to_non_nullable
                      as String?,
            content: freezed == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            files: freezed == files
                ? _value.files
                : files // ignore: cast_nullable_to_non_nullable
                      as List<MediaFile>?,
            v: freezed == v
                ? _value.v
                : v // ignore: cast_nullable_to_non_nullable
                      as int?,
            child: freezed == child
                ? _value.child
                : child // ignore: cast_nullable_to_non_nullable
                      as List<CommentsListModel>?,
          )
          as $Val,
    );
  }

  /// Create a copy of CommentsListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserIdCopyWith<$Res>? get userId {
    if (_value.userId == null) {
      return null;
    }

    return $UserIdCopyWith<$Res>(_value.userId!, (value) {
      return _then(_value.copyWith(userId: value) as $Val);
    });
  }

  /// Create a copy of CommentsListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserIdCopyWith<$Res>? get replyToUser {
    if (_value.replyToUser == null) {
      return null;
    }

    return $UserIdCopyWith<$Res>(_value.replyToUser!, (value) {
      return _then(_value.copyWith(replyToUser: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CommentsListModelImplCopyWith<$Res>
    implements $CommentsListModelCopyWith<$Res> {
  factory _$$CommentsListModelImplCopyWith(
    _$CommentsListModelImpl value,
    $Res Function(_$CommentsListModelImpl) then,
  ) = __$$CommentsListModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
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
  });

  @override
  $UserIdCopyWith<$Res>? get userId;
  @override
  $UserIdCopyWith<$Res>? get replyToUser;
}

/// @nodoc
class __$$CommentsListModelImplCopyWithImpl<$Res>
    extends _$CommentsListModelCopyWithImpl<$Res, _$CommentsListModelImpl>
    implements _$$CommentsListModelImplCopyWith<$Res> {
  __$$CommentsListModelImplCopyWithImpl(
    _$CommentsListModelImpl _value,
    $Res Function(_$CommentsListModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommentsListModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? replyToUser = freezed,
    Object? postId = freezed,
    Object? parentId = freezed,
    Object? content = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? files = freezed,
    Object? v = freezed,
    Object? child = freezed,
  }) {
    return _then(
      _$CommentsListModelImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as UserId?,
        replyToUser: freezed == replyToUser
            ? _value.replyToUser
            : replyToUser // ignore: cast_nullable_to_non_nullable
                  as UserId?,
        postId: freezed == postId
            ? _value.postId
            : postId // ignore: cast_nullable_to_non_nullable
                  as String?,
        parentId: freezed == parentId
            ? _value.parentId
            : parentId // ignore: cast_nullable_to_non_nullable
                  as String?,
        content: freezed == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        files: freezed == files
            ? _value._files
            : files // ignore: cast_nullable_to_non_nullable
                  as List<MediaFile>?,
        v: freezed == v
            ? _value.v
            : v // ignore: cast_nullable_to_non_nullable
                  as int?,
        child: freezed == child
            ? _value._child
            : child // ignore: cast_nullable_to_non_nullable
                  as List<CommentsListModel>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommentsListModelImpl implements _CommentsListModel {
  const _$CommentsListModelImpl({
    @JsonKey(name: "_id") this.id,
    @JsonKey(name: "userId") this.userId,
    @JsonKey(name: "replyUser") this.replyToUser,
    @JsonKey(name: "postId") this.postId,
    @JsonKey(name: "perantId") this.parentId,
    @JsonKey(name: "content") this.content,
    @JsonKey(name: "createdAt") this.createdAt,
    @JsonKey(name: "updatedAt") this.updatedAt,
    @JsonKey(name: "files") final List<MediaFile>? files,
    @JsonKey(name: "__v") this.v,
    @JsonKey(name: "child") final List<CommentsListModel>? child,
  }) : _files = files,
       _child = child;

  factory _$CommentsListModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommentsListModelImplFromJson(json);

  @override
  @JsonKey(name: "_id")
  final String? id;
  @override
  @JsonKey(name: "userId")
  final UserId? userId;
  @override
  @JsonKey(name: "replyUser")
  final UserId? replyToUser;
  @override
  @JsonKey(name: "postId")
  final String? postId;
  @override
  @JsonKey(name: "perantId")
  final String? parentId;
  @override
  @JsonKey(name: "content")
  final String? content;
  @override
  @JsonKey(name: "createdAt")
  final String? createdAt;
  @override
  @JsonKey(name: "updatedAt")
  final String? updatedAt;
  final List<MediaFile>? _files;
  @override
  @JsonKey(name: "files")
  List<MediaFile>? get files {
    final value = _files;
    if (value == null) return null;
    if (_files is EqualUnmodifiableListView) return _files;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: "__v")
  final int? v;
  final List<CommentsListModel>? _child;
  @override
  @JsonKey(name: "child")
  List<CommentsListModel>? get child {
    final value = _child;
    if (value == null) return null;
    if (_child is EqualUnmodifiableListView) return _child;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'CommentsListModel(id: $id, userId: $userId, replyToUser: $replyToUser, postId: $postId, parentId: $parentId, content: $content, createdAt: $createdAt, updatedAt: $updatedAt, files: $files, v: $v, child: $child)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentsListModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.replyToUser, replyToUser) ||
                other.replyToUser == replyToUser) &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._files, _files) &&
            (identical(other.v, v) || other.v == v) &&
            const DeepCollectionEquality().equals(other._child, _child));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    replyToUser,
    postId,
    parentId,
    content,
    createdAt,
    updatedAt,
    const DeepCollectionEquality().hash(_files),
    v,
    const DeepCollectionEquality().hash(_child),
  );

  /// Create a copy of CommentsListModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentsListModelImplCopyWith<_$CommentsListModelImpl> get copyWith =>
      __$$CommentsListModelImplCopyWithImpl<_$CommentsListModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CommentsListModelImplToJson(this);
  }
}

abstract class _CommentsListModel implements CommentsListModel {
  const factory _CommentsListModel({
    @JsonKey(name: "_id") final String? id,
    @JsonKey(name: "userId") final UserId? userId,
    @JsonKey(name: "replyUser") final UserId? replyToUser,
    @JsonKey(name: "postId") final String? postId,
    @JsonKey(name: "perantId") final String? parentId,
    @JsonKey(name: "content") final String? content,
    @JsonKey(name: "createdAt") final String? createdAt,
    @JsonKey(name: "updatedAt") final String? updatedAt,
    @JsonKey(name: "files") final List<MediaFile>? files,
    @JsonKey(name: "__v") final int? v,
    @JsonKey(name: "child") final List<CommentsListModel>? child,
  }) = _$CommentsListModelImpl;

  factory _CommentsListModel.fromJson(Map<String, dynamic> json) =
      _$CommentsListModelImpl.fromJson;

  @override
  @JsonKey(name: "_id")
  String? get id;
  @override
  @JsonKey(name: "userId")
  UserId? get userId;
  @override
  @JsonKey(name: "replyUser")
  UserId? get replyToUser;
  @override
  @JsonKey(name: "postId")
  String? get postId;
  @override
  @JsonKey(name: "perantId")
  String? get parentId;
  @override
  @JsonKey(name: "content")
  String? get content;
  @override
  @JsonKey(name: "createdAt")
  String? get createdAt;
  @override
  @JsonKey(name: "updatedAt")
  String? get updatedAt;
  @override
  @JsonKey(name: "files")
  List<MediaFile>? get files;
  @override
  @JsonKey(name: "__v")
  int? get v;
  @override
  @JsonKey(name: "child")
  List<CommentsListModel>? get child;

  /// Create a copy of CommentsListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommentsListModelImplCopyWith<_$CommentsListModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserId _$UserIdFromJson(Map<String, dynamic> json) {
  return _UserId.fromJson(json);
}

/// @nodoc
mixin _$UserId {
  @JsonKey(name: "_id")
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: "name")
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: "image")
  String? get image => throw _privateConstructorUsedError;

  /// Serializes this UserId to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserId
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserIdCopyWith<UserId> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserIdCopyWith<$Res> {
  factory $UserIdCopyWith(UserId value, $Res Function(UserId) then) =
      _$UserIdCopyWithImpl<$Res, UserId>;
  @useResult
  $Res call({
    @JsonKey(name: "_id") String? id,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "image") String? image,
  });
}

/// @nodoc
class _$UserIdCopyWithImpl<$Res, $Val extends UserId>
    implements $UserIdCopyWith<$Res> {
  _$UserIdCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserId
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? image = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            image: freezed == image
                ? _value.image
                : image // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserIdImplCopyWith<$Res> implements $UserIdCopyWith<$Res> {
  factory _$$UserIdImplCopyWith(
    _$UserIdImpl value,
    $Res Function(_$UserIdImpl) then,
  ) = __$$UserIdImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: "_id") String? id,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "image") String? image,
  });
}

/// @nodoc
class __$$UserIdImplCopyWithImpl<$Res>
    extends _$UserIdCopyWithImpl<$Res, _$UserIdImpl>
    implements _$$UserIdImplCopyWith<$Res> {
  __$$UserIdImplCopyWithImpl(
    _$UserIdImpl _value,
    $Res Function(_$UserIdImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserId
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? image = freezed,
  }) {
    return _then(
      _$UserIdImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        image: freezed == image
            ? _value.image
            : image // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserIdImpl implements _UserId {
  const _$UserIdImpl({
    @JsonKey(name: "_id") this.id,
    @JsonKey(name: "name") this.name,
    @JsonKey(name: "image") this.image,
  });

  factory _$UserIdImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserIdImplFromJson(json);

  @override
  @JsonKey(name: "_id")
  final String? id;
  @override
  @JsonKey(name: "name")
  final String? name;
  @override
  @JsonKey(name: "image")
  final String? image;

  @override
  String toString() {
    return 'UserId(id: $id, name: $name, image: $image)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserIdImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.image, image) || other.image == image));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, image);

  /// Create a copy of UserId
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserIdImplCopyWith<_$UserIdImpl> get copyWith =>
      __$$UserIdImplCopyWithImpl<_$UserIdImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserIdImplToJson(this);
  }
}

abstract class _UserId implements UserId {
  const factory _UserId({
    @JsonKey(name: "_id") final String? id,
    @JsonKey(name: "name") final String? name,
    @JsonKey(name: "image") final String? image,
  }) = _$UserIdImpl;

  factory _UserId.fromJson(Map<String, dynamic> json) = _$UserIdImpl.fromJson;

  @override
  @JsonKey(name: "_id")
  String? get id;
  @override
  @JsonKey(name: "name")
  String? get name;
  @override
  @JsonKey(name: "image")
  String? get image;

  /// Create a copy of UserId
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserIdImplCopyWith<_$UserIdImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MediaFile _$MediaFileFromJson(Map<String, dynamic> json) {
  return _MediaFile.fromJson(json);
}

/// @nodoc
mixin _$MediaFile {
  @JsonKey(name: "file")
  String? get file => throw _privateConstructorUsedError;
  @JsonKey(name: "type")
  String? get type => throw _privateConstructorUsedError;
  @JsonKey(name: "_id")
  String? get id => throw _privateConstructorUsedError;

  /// Serializes this MediaFile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MediaFile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MediaFileCopyWith<MediaFile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MediaFileCopyWith<$Res> {
  factory $MediaFileCopyWith(MediaFile value, $Res Function(MediaFile) then) =
      _$MediaFileCopyWithImpl<$Res, MediaFile>;
  @useResult
  $Res call({
    @JsonKey(name: "file") String? file,
    @JsonKey(name: "type") String? type,
    @JsonKey(name: "_id") String? id,
  });
}

/// @nodoc
class _$MediaFileCopyWithImpl<$Res, $Val extends MediaFile>
    implements $MediaFileCopyWith<$Res> {
  _$MediaFileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MediaFile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? file = freezed,
    Object? type = freezed,
    Object? id = freezed,
  }) {
    return _then(
      _value.copyWith(
            file: freezed == file
                ? _value.file
                : file // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String?,
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MediaFileImplCopyWith<$Res>
    implements $MediaFileCopyWith<$Res> {
  factory _$$MediaFileImplCopyWith(
    _$MediaFileImpl value,
    $Res Function(_$MediaFileImpl) then,
  ) = __$$MediaFileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: "file") String? file,
    @JsonKey(name: "type") String? type,
    @JsonKey(name: "_id") String? id,
  });
}

/// @nodoc
class __$$MediaFileImplCopyWithImpl<$Res>
    extends _$MediaFileCopyWithImpl<$Res, _$MediaFileImpl>
    implements _$$MediaFileImplCopyWith<$Res> {
  __$$MediaFileImplCopyWithImpl(
    _$MediaFileImpl _value,
    $Res Function(_$MediaFileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MediaFile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? file = freezed,
    Object? type = freezed,
    Object? id = freezed,
  }) {
    return _then(
      _$MediaFileImpl(
        file: freezed == file
            ? _value.file
            : file // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String?,
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MediaFileImpl implements _MediaFile {
  const _$MediaFileImpl({
    @JsonKey(name: "file") this.file,
    @JsonKey(name: "type") this.type,
    @JsonKey(name: "_id") this.id,
  });

  factory _$MediaFileImpl.fromJson(Map<String, dynamic> json) =>
      _$$MediaFileImplFromJson(json);

  @override
  @JsonKey(name: "file")
  final String? file;
  @override
  @JsonKey(name: "type")
  final String? type;
  @override
  @JsonKey(name: "_id")
  final String? id;

  @override
  String toString() {
    return 'MediaFile(file: $file, type: $type, id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MediaFileImpl &&
            (identical(other.file, file) || other.file == file) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, file, type, id);

  /// Create a copy of MediaFile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MediaFileImplCopyWith<_$MediaFileImpl> get copyWith =>
      __$$MediaFileImplCopyWithImpl<_$MediaFileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MediaFileImplToJson(this);
  }
}

abstract class _MediaFile implements MediaFile {
  const factory _MediaFile({
    @JsonKey(name: "file") final String? file,
    @JsonKey(name: "type") final String? type,
    @JsonKey(name: "_id") final String? id,
  }) = _$MediaFileImpl;

  factory _MediaFile.fromJson(Map<String, dynamic> json) =
      _$MediaFileImpl.fromJson;

  @override
  @JsonKey(name: "file")
  String? get file;
  @override
  @JsonKey(name: "type")
  String? get type;
  @override
  @JsonKey(name: "_id")
  String? get id;

  /// Create a copy of MediaFile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MediaFileImplCopyWith<_$MediaFileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
