// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'poll_list_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PollListModel _$PollListModelFromJson(Map<String, dynamic> json) {
  return _PollListModel.fromJson(json);
}

/// @nodoc
mixin _$PollListModel {
  String? get id => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String? get categoryId => throw _privateConstructorUsedError;
  String? get content => throw _privateConstructorUsedError;
  Location? get location => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;
  List<FileElement>? get files => throw _privateConstructorUsedError;
  String? get fileType => throw _privateConstructorUsedError;
  int? get duration => throw _privateConstructorUsedError;
  List<Option>? get options => throw _privateConstructorUsedError;
  List<Vote>? get votes => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;
  int? get v => throw _privateConstructorUsedError;
  User? get user => throw _privateConstructorUsedError;
  int? get likeCount => throw _privateConstructorUsedError;
  int? get videoCount => throw _privateConstructorUsedError;
  int? get commentCount => throw _privateConstructorUsedError;
  bool? get isLikedByUser => throw _privateConstructorUsedError;

  /// Serializes this PollListModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PollListModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PollListModelCopyWith<PollListModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PollListModelCopyWith<$Res> {
  factory $PollListModelCopyWith(
    PollListModel value,
    $Res Function(PollListModel) then,
  ) = _$PollListModelCopyWithImpl<$Res, PollListModel>;
  @useResult
  $Res call({
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
  });

  $LocationCopyWith<$Res>? get location;
  $UserCopyWith<$Res>? get user;
}

/// @nodoc
class _$PollListModelCopyWithImpl<$Res, $Val extends PollListModel>
    implements $PollListModelCopyWith<$Res> {
  _$PollListModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PollListModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? categoryId = freezed,
    Object? content = freezed,
    Object? location = freezed,
    Object? country = freezed,
    Object? files = freezed,
    Object? fileType = freezed,
    Object? duration = freezed,
    Object? options = freezed,
    Object? votes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? v = freezed,
    Object? user = freezed,
    Object? likeCount = freezed,
    Object? videoCount = freezed,
    Object? commentCount = freezed,
    Object? isLikedByUser = freezed,
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
                      as String?,
            categoryId: freezed == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String?,
            content: freezed == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String?,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as Location?,
            country: freezed == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                      as String?,
            files: freezed == files
                ? _value.files
                : files // ignore: cast_nullable_to_non_nullable
                      as List<FileElement>?,
            fileType: freezed == fileType
                ? _value.fileType
                : fileType // ignore: cast_nullable_to_non_nullable
                      as String?,
            duration: freezed == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as int?,
            options: freezed == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as List<Option>?,
            votes: freezed == votes
                ? _value.votes
                : votes // ignore: cast_nullable_to_non_nullable
                      as List<Vote>?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            v: freezed == v
                ? _value.v
                : v // ignore: cast_nullable_to_non_nullable
                      as int?,
            user: freezed == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as User?,
            likeCount: freezed == likeCount
                ? _value.likeCount
                : likeCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            videoCount: freezed == videoCount
                ? _value.videoCount
                : videoCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            commentCount: freezed == commentCount
                ? _value.commentCount
                : commentCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            isLikedByUser: freezed == isLikedByUser
                ? _value.isLikedByUser
                : isLikedByUser // ignore: cast_nullable_to_non_nullable
                      as bool?,
          )
          as $Val,
    );
  }

  /// Create a copy of PollListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationCopyWith<$Res>? get location {
    if (_value.location == null) {
      return null;
    }

    return $LocationCopyWith<$Res>(_value.location!, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }

  /// Create a copy of PollListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PollListModelImplCopyWith<$Res>
    implements $PollListModelCopyWith<$Res> {
  factory _$$PollListModelImplCopyWith(
    _$PollListModelImpl value,
    $Res Function(_$PollListModelImpl) then,
  ) = __$$PollListModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
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
  });

  @override
  $LocationCopyWith<$Res>? get location;
  @override
  $UserCopyWith<$Res>? get user;
}

/// @nodoc
class __$$PollListModelImplCopyWithImpl<$Res>
    extends _$PollListModelCopyWithImpl<$Res, _$PollListModelImpl>
    implements _$$PollListModelImplCopyWith<$Res> {
  __$$PollListModelImplCopyWithImpl(
    _$PollListModelImpl _value,
    $Res Function(_$PollListModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PollListModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? categoryId = freezed,
    Object? content = freezed,
    Object? location = freezed,
    Object? country = freezed,
    Object? files = freezed,
    Object? fileType = freezed,
    Object? duration = freezed,
    Object? options = freezed,
    Object? votes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? v = freezed,
    Object? user = freezed,
    Object? likeCount = freezed,
    Object? videoCount = freezed,
    Object? commentCount = freezed,
    Object? isLikedByUser = freezed,
  }) {
    return _then(
      _$PollListModelImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        categoryId: freezed == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String?,
        content: freezed == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String?,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as Location?,
        country: freezed == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as String?,
        files: freezed == files
            ? _value._files
            : files // ignore: cast_nullable_to_non_nullable
                  as List<FileElement>?,
        fileType: freezed == fileType
            ? _value.fileType
            : fileType // ignore: cast_nullable_to_non_nullable
                  as String?,
        duration: freezed == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as int?,
        options: freezed == options
            ? _value._options
            : options // ignore: cast_nullable_to_non_nullable
                  as List<Option>?,
        votes: freezed == votes
            ? _value._votes
            : votes // ignore: cast_nullable_to_non_nullable
                  as List<Vote>?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        v: freezed == v
            ? _value.v
            : v // ignore: cast_nullable_to_non_nullable
                  as int?,
        user: freezed == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as User?,
        likeCount: freezed == likeCount
            ? _value.likeCount
            : likeCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        videoCount: freezed == videoCount
            ? _value.videoCount
            : videoCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        commentCount: freezed == commentCount
            ? _value.commentCount
            : commentCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        isLikedByUser: freezed == isLikedByUser
            ? _value.isLikedByUser
            : isLikedByUser // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PollListModelImpl implements _PollListModel {
  const _$PollListModelImpl({
    this.id,
    this.userId,
    this.categoryId,
    this.content,
    this.location,
    this.country,
    final List<FileElement>? files,
    this.fileType,
    this.duration,
    final List<Option>? options,
    final List<Vote>? votes,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.user,
    this.likeCount,
    this.videoCount,
    this.commentCount,
    this.isLikedByUser,
  }) : _files = files,
       _options = options,
       _votes = votes;

  factory _$PollListModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PollListModelImplFromJson(json);

  @override
  final String? id;
  @override
  final String? userId;
  @override
  final String? categoryId;
  @override
  final String? content;
  @override
  final Location? location;
  @override
  final String? country;
  final List<FileElement>? _files;
  @override
  List<FileElement>? get files {
    final value = _files;
    if (value == null) return null;
    if (_files is EqualUnmodifiableListView) return _files;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? fileType;
  @override
  final int? duration;
  final List<Option>? _options;
  @override
  List<Option>? get options {
    final value = _options;
    if (value == null) return null;
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Vote>? _votes;
  @override
  List<Vote>? get votes {
    final value = _votes;
    if (value == null) return null;
    if (_votes is EqualUnmodifiableListView) return _votes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? createdAt;
  @override
  final String? updatedAt;
  @override
  final int? v;
  @override
  final User? user;
  @override
  final int? likeCount;
  @override
  final int? videoCount;
  @override
  final int? commentCount;
  @override
  final bool? isLikedByUser;

  @override
  String toString() {
    return 'PollListModel(id: $id, userId: $userId, categoryId: $categoryId, content: $content, location: $location, country: $country, files: $files, fileType: $fileType, duration: $duration, options: $options, votes: $votes, createdAt: $createdAt, updatedAt: $updatedAt, v: $v, user: $user, likeCount: $likeCount, videoCount: $videoCount, commentCount: $commentCount, isLikedByUser: $isLikedByUser)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PollListModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.country, country) || other.country == country) &&
            const DeepCollectionEquality().equals(other._files, _files) &&
            (identical(other.fileType, fileType) ||
                other.fileType == fileType) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            const DeepCollectionEquality().equals(other._votes, _votes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.v, v) || other.v == v) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.videoCount, videoCount) ||
                other.videoCount == videoCount) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.isLikedByUser, isLikedByUser) ||
                other.isLikedByUser == isLikedByUser));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    userId,
    categoryId,
    content,
    location,
    country,
    const DeepCollectionEquality().hash(_files),
    fileType,
    duration,
    const DeepCollectionEquality().hash(_options),
    const DeepCollectionEquality().hash(_votes),
    createdAt,
    updatedAt,
    v,
    user,
    likeCount,
    videoCount,
    commentCount,
    isLikedByUser,
  ]);

  /// Create a copy of PollListModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PollListModelImplCopyWith<_$PollListModelImpl> get copyWith =>
      __$$PollListModelImplCopyWithImpl<_$PollListModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PollListModelImplToJson(this);
  }
}

abstract class _PollListModel implements PollListModel {
  const factory _PollListModel({
    final String? id,
    final String? userId,
    final String? categoryId,
    final String? content,
    final Location? location,
    final String? country,
    final List<FileElement>? files,
    final String? fileType,
    final int? duration,
    final List<Option>? options,
    final List<Vote>? votes,
    final String? createdAt,
    final String? updatedAt,
    final int? v,
    final User? user,
    final int? likeCount,
    final int? videoCount,
    final int? commentCount,
    final bool? isLikedByUser,
  }) = _$PollListModelImpl;

  factory _PollListModel.fromJson(Map<String, dynamic> json) =
      _$PollListModelImpl.fromJson;

  @override
  String? get id;
  @override
  String? get userId;
  @override
  String? get categoryId;
  @override
  String? get content;
  @override
  Location? get location;
  @override
  String? get country;
  @override
  List<FileElement>? get files;
  @override
  String? get fileType;
  @override
  int? get duration;
  @override
  List<Option>? get options;
  @override
  List<Vote>? get votes;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;
  @override
  int? get v;
  @override
  User? get user;
  @override
  int? get likeCount;
  @override
  int? get videoCount;
  @override
  int? get commentCount;
  @override
  bool? get isLikedByUser;

  /// Create a copy of PollListModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PollListModelImplCopyWith<_$PollListModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Option _$OptionFromJson(Map<String, dynamic> json) {
  return _Option.fromJson(json);
}

/// @nodoc
mixin _$Option {
  String? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;
  int? get voteCount => throw _privateConstructorUsedError;

  /// Serializes this Option to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Option
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OptionCopyWith<Option> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OptionCopyWith<$Res> {
  factory $OptionCopyWith(Option value, $Res Function(Option) then) =
      _$OptionCopyWithImpl<$Res, Option>;
  @useResult
  $Res call({String? id, String? name, String? image, int? voteCount});
}

/// @nodoc
class _$OptionCopyWithImpl<$Res, $Val extends Option>
    implements $OptionCopyWith<$Res> {
  _$OptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Option
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? image = freezed,
    Object? voteCount = freezed,
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
            voteCount: freezed == voteCount
                ? _value.voteCount
                : voteCount // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OptionImplCopyWith<$Res> implements $OptionCopyWith<$Res> {
  factory _$$OptionImplCopyWith(
    _$OptionImpl value,
    $Res Function(_$OptionImpl) then,
  ) = __$$OptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? id, String? name, String? image, int? voteCount});
}

/// @nodoc
class __$$OptionImplCopyWithImpl<$Res>
    extends _$OptionCopyWithImpl<$Res, _$OptionImpl>
    implements _$$OptionImplCopyWith<$Res> {
  __$$OptionImplCopyWithImpl(
    _$OptionImpl _value,
    $Res Function(_$OptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Option
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? image = freezed,
    Object? voteCount = freezed,
  }) {
    return _then(
      _$OptionImpl(
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
        voteCount: freezed == voteCount
            ? _value.voteCount
            : voteCount // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OptionImpl implements _Option {
  const _$OptionImpl({this.id, this.name, this.image, this.voteCount});

  factory _$OptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$OptionImplFromJson(json);

  @override
  final String? id;
  @override
  final String? name;
  @override
  final String? image;
  @override
  final int? voteCount;

  @override
  String toString() {
    return 'Option(id: $id, name: $name, image: $image, voteCount: $voteCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.voteCount, voteCount) ||
                other.voteCount == voteCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, image, voteCount);

  /// Create a copy of Option
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OptionImplCopyWith<_$OptionImpl> get copyWith =>
      __$$OptionImplCopyWithImpl<_$OptionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OptionImplToJson(this);
  }
}

abstract class _Option implements Option {
  const factory _Option({
    final String? id,
    final String? name,
    final String? image,
    final int? voteCount,
  }) = _$OptionImpl;

  factory _Option.fromJson(Map<String, dynamic> json) = _$OptionImpl.fromJson;

  @override
  String? get id;
  @override
  String? get name;
  @override
  String? get image;
  @override
  int? get voteCount;

  /// Create a copy of Option
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OptionImplCopyWith<_$OptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  String? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get password => throw _privateConstructorUsedError;
  String? get role => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get dob => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  String? get seeMyProfile => throw _privateConstructorUsedError;
  String? get shareMyPost => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;
  int? get v => throw _privateConstructorUsedError;
  bool? get isNotification => throw _privateConstructorUsedError;
  dynamic get otp => throw _privateConstructorUsedError;

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call({
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
  });
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? email = freezed,
    Object? password = freezed,
    Object? role = freezed,
    Object? phone = freezed,
    Object? dob = freezed,
    Object? gender = freezed,
    Object? seeMyProfile = freezed,
    Object? shareMyPost = freezed,
    Object? image = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? v = freezed,
    Object? isNotification = freezed,
    Object? otp = freezed,
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
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            password: freezed == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String?,
            role: freezed == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            dob: freezed == dob
                ? _value.dob
                : dob // ignore: cast_nullable_to_non_nullable
                      as String?,
            gender: freezed == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as String?,
            seeMyProfile: freezed == seeMyProfile
                ? _value.seeMyProfile
                : seeMyProfile // ignore: cast_nullable_to_non_nullable
                      as String?,
            shareMyPost: freezed == shareMyPost
                ? _value.shareMyPost
                : shareMyPost // ignore: cast_nullable_to_non_nullable
                      as String?,
            image: freezed == image
                ? _value.image
                : image // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            v: freezed == v
                ? _value.v
                : v // ignore: cast_nullable_to_non_nullable
                      as int?,
            isNotification: freezed == isNotification
                ? _value.isNotification
                : isNotification // ignore: cast_nullable_to_non_nullable
                      as bool?,
            otp: freezed == otp
                ? _value.otp
                : otp // ignore: cast_nullable_to_non_nullable
                      as dynamic,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
    _$UserImpl value,
    $Res Function(_$UserImpl) then,
  ) = __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
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
  });
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
    : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? email = freezed,
    Object? password = freezed,
    Object? role = freezed,
    Object? phone = freezed,
    Object? dob = freezed,
    Object? gender = freezed,
    Object? seeMyProfile = freezed,
    Object? shareMyPost = freezed,
    Object? image = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? v = freezed,
    Object? isNotification = freezed,
    Object? otp = freezed,
  }) {
    return _then(
      _$UserImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        password: freezed == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String?,
        role: freezed == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        dob: freezed == dob
            ? _value.dob
            : dob // ignore: cast_nullable_to_non_nullable
                  as String?,
        gender: freezed == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as String?,
        seeMyProfile: freezed == seeMyProfile
            ? _value.seeMyProfile
            : seeMyProfile // ignore: cast_nullable_to_non_nullable
                  as String?,
        shareMyPost: freezed == shareMyPost
            ? _value.shareMyPost
            : shareMyPost // ignore: cast_nullable_to_non_nullable
                  as String?,
        image: freezed == image
            ? _value.image
            : image // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        v: freezed == v
            ? _value.v
            : v // ignore: cast_nullable_to_non_nullable
                  as int?,
        isNotification: freezed == isNotification
            ? _value.isNotification
            : isNotification // ignore: cast_nullable_to_non_nullable
                  as bool?,
        otp: freezed == otp
            ? _value.otp
            : otp // ignore: cast_nullable_to_non_nullable
                  as dynamic,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl({
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

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  final String? id;
  @override
  final String? name;
  @override
  final String? email;
  @override
  final String? password;
  @override
  final String? role;
  @override
  final String? phone;
  @override
  final String? dob;
  @override
  final String? gender;
  @override
  final String? seeMyProfile;
  @override
  final String? shareMyPost;
  @override
  final String? image;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;
  @override
  final int? v;
  @override
  final bool? isNotification;
  @override
  final dynamic otp;

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, password: $password, role: $role, phone: $phone, dob: $dob, gender: $gender, seeMyProfile: $seeMyProfile, shareMyPost: $shareMyPost, image: $image, createdAt: $createdAt, updatedAt: $updatedAt, v: $v, isNotification: $isNotification, otp: $otp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.dob, dob) || other.dob == dob) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.seeMyProfile, seeMyProfile) ||
                other.seeMyProfile == seeMyProfile) &&
            (identical(other.shareMyPost, shareMyPost) ||
                other.shareMyPost == shareMyPost) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.v, v) || other.v == v) &&
            (identical(other.isNotification, isNotification) ||
                other.isNotification == isNotification) &&
            const DeepCollectionEquality().equals(other.otp, otp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    email,
    password,
    role,
    phone,
    dob,
    gender,
    seeMyProfile,
    shareMyPost,
    image,
    createdAt,
    updatedAt,
    v,
    isNotification,
    const DeepCollectionEquality().hash(otp),
  );

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(this);
  }
}

abstract class _User implements User {
  const factory _User({
    final String? id,
    final String? name,
    final String? email,
    final String? password,
    final String? role,
    final String? phone,
    final String? dob,
    final String? gender,
    final String? seeMyProfile,
    final String? shareMyPost,
    final String? image,
    final String? createdAt,
    final String? updatedAt,
    final int? v,
    final bool? isNotification,
    final dynamic otp,
  }) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  String? get id;
  @override
  String? get name;
  @override
  String? get email;
  @override
  String? get password;
  @override
  String? get role;
  @override
  String? get phone;
  @override
  String? get dob;
  @override
  String? get gender;
  @override
  String? get seeMyProfile;
  @override
  String? get shareMyPost;
  @override
  String? get image;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;
  @override
  int? get v;
  @override
  bool? get isNotification;
  @override
  dynamic get otp;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FileElement _$FileElementFromJson(Map<String, dynamic> json) {
  return _FileElement.fromJson(json);
}

/// @nodoc
mixin _$FileElement {
  String? get file => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;
  String? get id => throw _privateConstructorUsedError;

  /// Serializes this FileElement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FileElement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FileElementCopyWith<FileElement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FileElementCopyWith<$Res> {
  factory $FileElementCopyWith(
    FileElement value,
    $Res Function(FileElement) then,
  ) = _$FileElementCopyWithImpl<$Res, FileElement>;
  @useResult
  $Res call({String? file, String? type, String? id});
}

/// @nodoc
class _$FileElementCopyWithImpl<$Res, $Val extends FileElement>
    implements $FileElementCopyWith<$Res> {
  _$FileElementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FileElement
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
abstract class _$$FileElementImplCopyWith<$Res>
    implements $FileElementCopyWith<$Res> {
  factory _$$FileElementImplCopyWith(
    _$FileElementImpl value,
    $Res Function(_$FileElementImpl) then,
  ) = __$$FileElementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? file, String? type, String? id});
}

/// @nodoc
class __$$FileElementImplCopyWithImpl<$Res>
    extends _$FileElementCopyWithImpl<$Res, _$FileElementImpl>
    implements _$$FileElementImplCopyWith<$Res> {
  __$$FileElementImplCopyWithImpl(
    _$FileElementImpl _value,
    $Res Function(_$FileElementImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FileElement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? file = freezed,
    Object? type = freezed,
    Object? id = freezed,
  }) {
    return _then(
      _$FileElementImpl(
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
class _$FileElementImpl implements _FileElement {
  const _$FileElementImpl({this.file, this.type, this.id});

  factory _$FileElementImpl.fromJson(Map<String, dynamic> json) =>
      _$$FileElementImplFromJson(json);

  @override
  final String? file;
  @override
  final String? type;
  @override
  final String? id;

  @override
  String toString() {
    return 'FileElement(file: $file, type: $type, id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FileElementImpl &&
            (identical(other.file, file) || other.file == file) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, file, type, id);

  /// Create a copy of FileElement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FileElementImplCopyWith<_$FileElementImpl> get copyWith =>
      __$$FileElementImplCopyWithImpl<_$FileElementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FileElementImplToJson(this);
  }
}

abstract class _FileElement implements FileElement {
  const factory _FileElement({
    final String? file,
    final String? type,
    final String? id,
  }) = _$FileElementImpl;

  factory _FileElement.fromJson(Map<String, dynamic> json) =
      _$FileElementImpl.fromJson;

  @override
  String? get file;
  @override
  String? get type;
  @override
  String? get id;

  /// Create a copy of FileElement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FileElementImplCopyWith<_$FileElementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Location _$LocationFromJson(Map<String, dynamic> json) {
  return _Location.fromJson(json);
}

/// @nodoc
mixin _$Location {
  String? get type => throw _privateConstructorUsedError;
  List<double>? get coordinates => throw _privateConstructorUsedError;

  /// Serializes this Location to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocationCopyWith<Location> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationCopyWith<$Res> {
  factory $LocationCopyWith(Location value, $Res Function(Location) then) =
      _$LocationCopyWithImpl<$Res, Location>;
  @useResult
  $Res call({String? type, List<double>? coordinates});
}

/// @nodoc
class _$LocationCopyWithImpl<$Res, $Val extends Location>
    implements $LocationCopyWith<$Res> {
  _$LocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? type = freezed, Object? coordinates = freezed}) {
    return _then(
      _value.copyWith(
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String?,
            coordinates: freezed == coordinates
                ? _value.coordinates
                : coordinates // ignore: cast_nullable_to_non_nullable
                      as List<double>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LocationImplCopyWith<$Res>
    implements $LocationCopyWith<$Res> {
  factory _$$LocationImplCopyWith(
    _$LocationImpl value,
    $Res Function(_$LocationImpl) then,
  ) = __$$LocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? type, List<double>? coordinates});
}

/// @nodoc
class __$$LocationImplCopyWithImpl<$Res>
    extends _$LocationCopyWithImpl<$Res, _$LocationImpl>
    implements _$$LocationImplCopyWith<$Res> {
  __$$LocationImplCopyWithImpl(
    _$LocationImpl _value,
    $Res Function(_$LocationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? type = freezed, Object? coordinates = freezed}) {
    return _then(
      _$LocationImpl(
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String?,
        coordinates: freezed == coordinates
            ? _value._coordinates
            : coordinates // ignore: cast_nullable_to_non_nullable
                  as List<double>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LocationImpl implements _Location {
  const _$LocationImpl({this.type, final List<double>? coordinates})
    : _coordinates = coordinates;

  factory _$LocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationImplFromJson(json);

  @override
  final String? type;
  final List<double>? _coordinates;
  @override
  List<double>? get coordinates {
    final value = _coordinates;
    if (value == null) return null;
    if (_coordinates is EqualUnmodifiableListView) return _coordinates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'Location(type: $type, coordinates: $coordinates)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationImpl &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(
              other._coordinates,
              _coordinates,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    const DeepCollectionEquality().hash(_coordinates),
  );

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationImplCopyWith<_$LocationImpl> get copyWith =>
      __$$LocationImplCopyWithImpl<_$LocationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationImplToJson(this);
  }
}

abstract class _Location implements Location {
  const factory _Location({
    final String? type,
    final List<double>? coordinates,
  }) = _$LocationImpl;

  factory _Location.fromJson(Map<String, dynamic> json) =
      _$LocationImpl.fromJson;

  @override
  String? get type;
  @override
  List<double>? get coordinates;

  /// Create a copy of Location
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationImplCopyWith<_$LocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Vote _$VoteFromJson(Map<String, dynamic> json) {
  return _Vote.fromJson(json);
}

/// @nodoc
mixin _$Vote {
  String? get id => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String? get postId => throw _privateConstructorUsedError;
  String? get optionId => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;
  int? get v => throw _privateConstructorUsedError;

  /// Serializes this Vote to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Vote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VoteCopyWith<Vote> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VoteCopyWith<$Res> {
  factory $VoteCopyWith(Vote value, $Res Function(Vote) then) =
      _$VoteCopyWithImpl<$Res, Vote>;
  @useResult
  $Res call({
    String? id,
    String? userId,
    String? postId,
    String? optionId,
    String? createdAt,
    String? updatedAt,
    int? v,
  });
}

/// @nodoc
class _$VoteCopyWithImpl<$Res, $Val extends Vote>
    implements $VoteCopyWith<$Res> {
  _$VoteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Vote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? postId = freezed,
    Object? optionId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? v = freezed,
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
                      as String?,
            postId: freezed == postId
                ? _value.postId
                : postId // ignore: cast_nullable_to_non_nullable
                      as String?,
            optionId: freezed == optionId
                ? _value.optionId
                : optionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            v: freezed == v
                ? _value.v
                : v // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VoteImplCopyWith<$Res> implements $VoteCopyWith<$Res> {
  factory _$$VoteImplCopyWith(
    _$VoteImpl value,
    $Res Function(_$VoteImpl) then,
  ) = __$$VoteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    String? userId,
    String? postId,
    String? optionId,
    String? createdAt,
    String? updatedAt,
    int? v,
  });
}

/// @nodoc
class __$$VoteImplCopyWithImpl<$Res>
    extends _$VoteCopyWithImpl<$Res, _$VoteImpl>
    implements _$$VoteImplCopyWith<$Res> {
  __$$VoteImplCopyWithImpl(_$VoteImpl _value, $Res Function(_$VoteImpl) _then)
    : super(_value, _then);

  /// Create a copy of Vote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? postId = freezed,
    Object? optionId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? v = freezed,
  }) {
    return _then(
      _$VoteImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        postId: freezed == postId
            ? _value.postId
            : postId // ignore: cast_nullable_to_non_nullable
                  as String?,
        optionId: freezed == optionId
            ? _value.optionId
            : optionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        v: freezed == v
            ? _value.v
            : v // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VoteImpl implements _Vote {
  const _$VoteImpl({
    this.id,
    this.userId,
    this.postId,
    this.optionId,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory _$VoteImpl.fromJson(Map<String, dynamic> json) =>
      _$$VoteImplFromJson(json);

  @override
  final String? id;
  @override
  final String? userId;
  @override
  final String? postId;
  @override
  final String? optionId;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;
  @override
  final int? v;

  @override
  String toString() {
    return 'Vote(id: $id, userId: $userId, postId: $postId, optionId: $optionId, createdAt: $createdAt, updatedAt: $updatedAt, v: $v)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VoteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.optionId, optionId) ||
                other.optionId == optionId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.v, v) || other.v == v));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    postId,
    optionId,
    createdAt,
    updatedAt,
    v,
  );

  /// Create a copy of Vote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VoteImplCopyWith<_$VoteImpl> get copyWith =>
      __$$VoteImplCopyWithImpl<_$VoteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VoteImplToJson(this);
  }
}

abstract class _Vote implements Vote {
  const factory _Vote({
    final String? id,
    final String? userId,
    final String? postId,
    final String? optionId,
    final String? createdAt,
    final String? updatedAt,
    final int? v,
  }) = _$VoteImpl;

  factory _Vote.fromJson(Map<String, dynamic> json) = _$VoteImpl.fromJson;

  @override
  String? get id;
  @override
  String? get userId;
  @override
  String? get postId;
  @override
  String? get optionId;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;
  @override
  int? get v;

  /// Create a copy of Vote
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VoteImplCopyWith<_$VoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
