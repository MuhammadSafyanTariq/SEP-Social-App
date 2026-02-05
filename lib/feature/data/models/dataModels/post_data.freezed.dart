// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PostData _$PostDataFromJson(Map<String, dynamic> json) {
  return _PostData.fromJson(json);
}

/// @nodoc
mixin _$PostData {
  @JsonKey(name: '_id')
  String? get id => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String? get categoryId => throw _privateConstructorUsedError;
  String? get content => throw _privateConstructorUsedError;
  Location? get location => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;
  List<FileElement> get files => throw _privateConstructorUsedError;
  String? get fileType => throw _privateConstructorUsedError;
  int? get duration => throw _privateConstructorUsedError;
  @OptionFieldConverter()
  List<Option> get options => throw _privateConstructorUsedError;
  @VoteFieldConverter()
  List<Vote> get votes => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;
  int? get v => throw _privateConstructorUsedError;
  @UserFieldConverter()
  List<User> get user => throw _privateConstructorUsedError;
  int? get likeCount => throw _privateConstructorUsedError;
  int? get videoCount => throw _privateConstructorUsedError;
  int? get commentCount => throw _privateConstructorUsedError;
  bool? get isLikedByUser => throw _privateConstructorUsedError;
  bool? get isSaved => throw _privateConstructorUsedError;
  String? get savedAt =>
      throw _privateConstructorUsedError; // New fields for rich API response
  List<dynamic>? get likes => throw _privateConstructorUsedError;
  List<dynamic>? get comments => throw _privateConstructorUsedError;

  /// Serializes this PostData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PostData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PostDataCopyWith<PostData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostDataCopyWith<$Res> {
  factory $PostDataCopyWith(PostData value, $Res Function(PostData) then) =
      _$PostDataCopyWithImpl<$Res, PostData>;
  @useResult
  $Res call({
    @JsonKey(name: '_id') String? id,
    String? userId,
    String? categoryId,
    String? content,
    Location? location,
    String? country,
    List<FileElement> files,
    String? fileType,
    int? duration,
    @OptionFieldConverter() List<Option> options,
    @VoteFieldConverter() List<Vote> votes,
    String? createdAt,
    String? updatedAt,
    int? v,
    @UserFieldConverter() List<User> user,
    int? likeCount,
    int? videoCount,
    int? commentCount,
    bool? isLikedByUser,
    bool? isSaved,
    String? savedAt,
    List<dynamic>? likes,
    List<dynamic>? comments,
  });

  $LocationCopyWith<$Res>? get location;
}

/// @nodoc
class _$PostDataCopyWithImpl<$Res, $Val extends PostData>
    implements $PostDataCopyWith<$Res> {
  _$PostDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PostData
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
    Object? files = null,
    Object? fileType = freezed,
    Object? duration = freezed,
    Object? options = null,
    Object? votes = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? v = freezed,
    Object? user = null,
    Object? likeCount = freezed,
    Object? videoCount = freezed,
    Object? commentCount = freezed,
    Object? isLikedByUser = freezed,
    Object? isSaved = freezed,
    Object? savedAt = freezed,
    Object? likes = freezed,
    Object? comments = freezed,
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
            files: null == files
                ? _value.files
                : files // ignore: cast_nullable_to_non_nullable
                      as List<FileElement>,
            fileType: freezed == fileType
                ? _value.fileType
                : fileType // ignore: cast_nullable_to_non_nullable
                      as String?,
            duration: freezed == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as int?,
            options: null == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as List<Option>,
            votes: null == votes
                ? _value.votes
                : votes // ignore: cast_nullable_to_non_nullable
                      as List<Vote>,
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
            user: null == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as List<User>,
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
            isSaved: freezed == isSaved
                ? _value.isSaved
                : isSaved // ignore: cast_nullable_to_non_nullable
                      as bool?,
            savedAt: freezed == savedAt
                ? _value.savedAt
                : savedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            likes: freezed == likes
                ? _value.likes
                : likes // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>?,
            comments: freezed == comments
                ? _value.comments
                : comments // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>?,
          )
          as $Val,
    );
  }

  /// Create a copy of PostData
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
}

/// @nodoc
abstract class _$$PostDataImplCopyWith<$Res>
    implements $PostDataCopyWith<$Res> {
  factory _$$PostDataImplCopyWith(
    _$PostDataImpl value,
    $Res Function(_$PostDataImpl) then,
  ) = __$$PostDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: '_id') String? id,
    String? userId,
    String? categoryId,
    String? content,
    Location? location,
    String? country,
    List<FileElement> files,
    String? fileType,
    int? duration,
    @OptionFieldConverter() List<Option> options,
    @VoteFieldConverter() List<Vote> votes,
    String? createdAt,
    String? updatedAt,
    int? v,
    @UserFieldConverter() List<User> user,
    int? likeCount,
    int? videoCount,
    int? commentCount,
    bool? isLikedByUser,
    bool? isSaved,
    String? savedAt,
    List<dynamic>? likes,
    List<dynamic>? comments,
  });

  @override
  $LocationCopyWith<$Res>? get location;
}

/// @nodoc
class __$$PostDataImplCopyWithImpl<$Res>
    extends _$PostDataCopyWithImpl<$Res, _$PostDataImpl>
    implements _$$PostDataImplCopyWith<$Res> {
  __$$PostDataImplCopyWithImpl(
    _$PostDataImpl _value,
    $Res Function(_$PostDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PostData
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
    Object? files = null,
    Object? fileType = freezed,
    Object? duration = freezed,
    Object? options = null,
    Object? votes = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? v = freezed,
    Object? user = null,
    Object? likeCount = freezed,
    Object? videoCount = freezed,
    Object? commentCount = freezed,
    Object? isLikedByUser = freezed,
    Object? isSaved = freezed,
    Object? savedAt = freezed,
    Object? likes = freezed,
    Object? comments = freezed,
  }) {
    return _then(
      _$PostDataImpl(
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
        files: null == files
            ? _value._files
            : files // ignore: cast_nullable_to_non_nullable
                  as List<FileElement>,
        fileType: freezed == fileType
            ? _value.fileType
            : fileType // ignore: cast_nullable_to_non_nullable
                  as String?,
        duration: freezed == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as int?,
        options: null == options
            ? _value._options
            : options // ignore: cast_nullable_to_non_nullable
                  as List<Option>,
        votes: null == votes
            ? _value._votes
            : votes // ignore: cast_nullable_to_non_nullable
                  as List<Vote>,
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
        user: null == user
            ? _value._user
            : user // ignore: cast_nullable_to_non_nullable
                  as List<User>,
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
        isSaved: freezed == isSaved
            ? _value.isSaved
            : isSaved // ignore: cast_nullable_to_non_nullable
                  as bool?,
        savedAt: freezed == savedAt
            ? _value.savedAt
            : savedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        likes: freezed == likes
            ? _value._likes
            : likes // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>?,
        comments: freezed == comments
            ? _value._comments
            : comments // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PostDataImpl implements _PostData {
  const _$PostDataImpl({
    @JsonKey(name: '_id') this.id,
    this.userId,
    this.categoryId,
    this.content,
    this.location,
    this.country,
    final List<FileElement> files = const [],
    this.fileType,
    this.duration,
    @OptionFieldConverter() final List<Option> options = const [],
    @VoteFieldConverter() final List<Vote> votes = const [],
    this.createdAt,
    this.updatedAt,
    this.v,
    @UserFieldConverter() final List<User> user = const [],
    this.likeCount,
    this.videoCount,
    this.commentCount,
    this.isLikedByUser,
    this.isSaved,
    this.savedAt,
    final List<dynamic>? likes = const [],
    final List<dynamic>? comments = const [],
  }) : _files = files,
       _options = options,
       _votes = votes,
       _user = user,
       _likes = likes,
       _comments = comments;

  factory _$PostDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostDataImplFromJson(json);

  @override
  @JsonKey(name: '_id')
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
  final List<FileElement> _files;
  @override
  @JsonKey()
  List<FileElement> get files {
    if (_files is EqualUnmodifiableListView) return _files;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_files);
  }

  @override
  final String? fileType;
  @override
  final int? duration;
  final List<Option> _options;
  @override
  @JsonKey()
  @OptionFieldConverter()
  List<Option> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  final List<Vote> _votes;
  @override
  @JsonKey()
  @VoteFieldConverter()
  List<Vote> get votes {
    if (_votes is EqualUnmodifiableListView) return _votes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_votes);
  }

  @override
  final String? createdAt;
  @override
  final String? updatedAt;
  @override
  final int? v;
  final List<User> _user;
  @override
  @JsonKey()
  @UserFieldConverter()
  List<User> get user {
    if (_user is EqualUnmodifiableListView) return _user;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_user);
  }

  @override
  final int? likeCount;
  @override
  final int? videoCount;
  @override
  final int? commentCount;
  @override
  final bool? isLikedByUser;
  @override
  final bool? isSaved;
  @override
  final String? savedAt;
  // New fields for rich API response
  final List<dynamic>? _likes;
  // New fields for rich API response
  @override
  @JsonKey()
  List<dynamic>? get likes {
    final value = _likes;
    if (value == null) return null;
    if (_likes is EqualUnmodifiableListView) return _likes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<dynamic>? _comments;
  @override
  @JsonKey()
  List<dynamic>? get comments {
    final value = _comments;
    if (value == null) return null;
    if (_comments is EqualUnmodifiableListView) return _comments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'PostData(id: $id, userId: $userId, categoryId: $categoryId, content: $content, location: $location, country: $country, files: $files, fileType: $fileType, duration: $duration, options: $options, votes: $votes, createdAt: $createdAt, updatedAt: $updatedAt, v: $v, user: $user, likeCount: $likeCount, videoCount: $videoCount, commentCount: $commentCount, isLikedByUser: $isLikedByUser, isSaved: $isSaved, savedAt: $savedAt, likes: $likes, comments: $comments)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostDataImpl &&
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
            const DeepCollectionEquality().equals(other._user, _user) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.videoCount, videoCount) ||
                other.videoCount == videoCount) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.isLikedByUser, isLikedByUser) ||
                other.isLikedByUser == isLikedByUser) &&
            (identical(other.isSaved, isSaved) || other.isSaved == isSaved) &&
            (identical(other.savedAt, savedAt) || other.savedAt == savedAt) &&
            const DeepCollectionEquality().equals(other._likes, _likes) &&
            const DeepCollectionEquality().equals(other._comments, _comments));
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
    const DeepCollectionEquality().hash(_user),
    likeCount,
    videoCount,
    commentCount,
    isLikedByUser,
    isSaved,
    savedAt,
    const DeepCollectionEquality().hash(_likes),
    const DeepCollectionEquality().hash(_comments),
  ]);

  /// Create a copy of PostData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PostDataImplCopyWith<_$PostDataImpl> get copyWith =>
      __$$PostDataImplCopyWithImpl<_$PostDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PostDataImplToJson(this);
  }
}

abstract class _PostData implements PostData {
  const factory _PostData({
    @JsonKey(name: '_id') final String? id,
    final String? userId,
    final String? categoryId,
    final String? content,
    final Location? location,
    final String? country,
    final List<FileElement> files,
    final String? fileType,
    final int? duration,
    @OptionFieldConverter() final List<Option> options,
    @VoteFieldConverter() final List<Vote> votes,
    final String? createdAt,
    final String? updatedAt,
    final int? v,
    @UserFieldConverter() final List<User> user,
    final int? likeCount,
    final int? videoCount,
    final int? commentCount,
    final bool? isLikedByUser,
    final bool? isSaved,
    final String? savedAt,
    final List<dynamic>? likes,
    final List<dynamic>? comments,
  }) = _$PostDataImpl;

  factory _PostData.fromJson(Map<String, dynamic> json) =
      _$PostDataImpl.fromJson;

  @override
  @JsonKey(name: '_id')
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
  List<FileElement> get files;
  @override
  String? get fileType;
  @override
  int? get duration;
  @override
  @OptionFieldConverter()
  List<Option> get options;
  @override
  @VoteFieldConverter()
  List<Vote> get votes;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;
  @override
  int? get v;
  @override
  @UserFieldConverter()
  List<User> get user;
  @override
  int? get likeCount;
  @override
  int? get videoCount;
  @override
  int? get commentCount;
  @override
  bool? get isLikedByUser;
  @override
  bool? get isSaved;
  @override
  String? get savedAt; // New fields for rich API response
  @override
  List<dynamic>? get likes;
  @override
  List<dynamic>? get comments;

  /// Create a copy of PostData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PostDataImplCopyWith<_$PostDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Option _$OptionFromJson(Map<String, dynamic> json) {
  return _Option.fromJson(json);
}

/// @nodoc
mixin _$Option {
  @JsonKey(name: "_id")
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: "name")
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: "image")
  String? get image => throw _privateConstructorUsedError;
  @JsonKey(name: "voteCount")
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
  $Res call({
    @JsonKey(name: "_id") String? id,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "image") String? image,
    @JsonKey(name: "voteCount") int? voteCount,
  });
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
  $Res call({
    @JsonKey(name: "_id") String? id,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "image") String? image,
    @JsonKey(name: "voteCount") int? voteCount,
  });
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
  const _$OptionImpl({
    @JsonKey(name: "_id") this.id,
    @JsonKey(name: "name") this.name,
    @JsonKey(name: "image") this.image,
    @JsonKey(name: "voteCount") this.voteCount,
  });

  factory _$OptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$OptionImplFromJson(json);

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
  @JsonKey(name: "voteCount")
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
    @JsonKey(name: "_id") final String? id,
    @JsonKey(name: "name") final String? name,
    @JsonKey(name: "image") final String? image,
    @JsonKey(name: "voteCount") final int? voteCount,
  }) = _$OptionImpl;

  factory _Option.fromJson(Map<String, dynamic> json) = _$OptionImpl.fromJson;

  @override
  @JsonKey(name: "_id")
  String? get id;
  @override
  @JsonKey(name: "name")
  String? get name;
  @override
  @JsonKey(name: "image")
  String? get image;
  @override
  @JsonKey(name: "voteCount")
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
  @JsonKey(name: "_id")
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: "name")
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: "email")
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: "password")
  String? get password => throw _privateConstructorUsedError;
  @JsonKey(name: "role")
  String? get role => throw _privateConstructorUsedError;
  @JsonKey(name: "phone")
  String? get phone => throw _privateConstructorUsedError;
  @JsonKey(name: "dob")
  String? get dob => throw _privateConstructorUsedError;
  @JsonKey(name: "gender")
  String? get gender => throw _privateConstructorUsedError;
  @JsonKey(name: "seeMyProfile")
  String? get seeMyProfile => throw _privateConstructorUsedError;
  @JsonKey(name: "shareMyPost")
  String? get shareMyPost => throw _privateConstructorUsedError;
  @JsonKey(name: "image")
  String? get image => throw _privateConstructorUsedError;
  @JsonKey(name: "createdAt")
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: "updatedAt")
  String? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: "__v")
  int? get v => throw _privateConstructorUsedError;
  @JsonKey(name: "isNotification")
  bool? get isNotification => throw _privateConstructorUsedError;
  @JsonKey(name: "otp")
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
    @JsonKey(name: "_id") this.id,
    @JsonKey(name: "name") this.name,
    @JsonKey(name: "email") this.email,
    @JsonKey(name: "password") this.password,
    @JsonKey(name: "role") this.role,
    @JsonKey(name: "phone") this.phone,
    @JsonKey(name: "dob") this.dob,
    @JsonKey(name: "gender") this.gender,
    @JsonKey(name: "seeMyProfile") this.seeMyProfile,
    @JsonKey(name: "shareMyPost") this.shareMyPost,
    @JsonKey(name: "image") this.image,
    @JsonKey(name: "createdAt") this.createdAt,
    @JsonKey(name: "updatedAt") this.updatedAt,
    @JsonKey(name: "__v") this.v,
    @JsonKey(name: "isNotification") this.isNotification,
    @JsonKey(name: "otp") this.otp,
  });

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  @JsonKey(name: "_id")
  final String? id;
  @override
  @JsonKey(name: "name")
  final String? name;
  @override
  @JsonKey(name: "email")
  final String? email;
  @override
  @JsonKey(name: "password")
  final String? password;
  @override
  @JsonKey(name: "role")
  final String? role;
  @override
  @JsonKey(name: "phone")
  final String? phone;
  @override
  @JsonKey(name: "dob")
  final String? dob;
  @override
  @JsonKey(name: "gender")
  final String? gender;
  @override
  @JsonKey(name: "seeMyProfile")
  final String? seeMyProfile;
  @override
  @JsonKey(name: "shareMyPost")
  final String? shareMyPost;
  @override
  @JsonKey(name: "image")
  final String? image;
  @override
  @JsonKey(name: "createdAt")
  final String? createdAt;
  @override
  @JsonKey(name: "updatedAt")
  final String? updatedAt;
  @override
  @JsonKey(name: "__v")
  final int? v;
  @override
  @JsonKey(name: "isNotification")
  final bool? isNotification;
  @override
  @JsonKey(name: "otp")
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
    @JsonKey(name: "_id") final String? id,
    @JsonKey(name: "name") final String? name,
    @JsonKey(name: "email") final String? email,
    @JsonKey(name: "password") final String? password,
    @JsonKey(name: "role") final String? role,
    @JsonKey(name: "phone") final String? phone,
    @JsonKey(name: "dob") final String? dob,
    @JsonKey(name: "gender") final String? gender,
    @JsonKey(name: "seeMyProfile") final String? seeMyProfile,
    @JsonKey(name: "shareMyPost") final String? shareMyPost,
    @JsonKey(name: "image") final String? image,
    @JsonKey(name: "createdAt") final String? createdAt,
    @JsonKey(name: "updatedAt") final String? updatedAt,
    @JsonKey(name: "__v") final int? v,
    @JsonKey(name: "isNotification") final bool? isNotification,
    @JsonKey(name: "otp") final dynamic otp,
  }) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  @JsonKey(name: "_id")
  String? get id;
  @override
  @JsonKey(name: "name")
  String? get name;
  @override
  @JsonKey(name: "email")
  String? get email;
  @override
  @JsonKey(name: "password")
  String? get password;
  @override
  @JsonKey(name: "role")
  String? get role;
  @override
  @JsonKey(name: "phone")
  String? get phone;
  @override
  @JsonKey(name: "dob")
  String? get dob;
  @override
  @JsonKey(name: "gender")
  String? get gender;
  @override
  @JsonKey(name: "seeMyProfile")
  String? get seeMyProfile;
  @override
  @JsonKey(name: "shareMyPost")
  String? get shareMyPost;
  @override
  @JsonKey(name: "image")
  String? get image;
  @override
  @JsonKey(name: "createdAt")
  String? get createdAt;
  @override
  @JsonKey(name: "updatedAt")
  String? get updatedAt;
  @override
  @JsonKey(name: "__v")
  int? get v;
  @override
  @JsonKey(name: "isNotification")
  bool? get isNotification;
  @override
  @JsonKey(name: "otp")
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
  @JsonKey(name: "file")
  String? get file => throw _privateConstructorUsedError;
  @JsonKey(name: "type")
  String? get type => throw _privateConstructorUsedError;
  @JsonKey(name: "_id")
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: "thumbnail")
  String? get thumbnail => throw _privateConstructorUsedError;
  @JsonKey(name: "x")
  double? get x => throw _privateConstructorUsedError;
  @JsonKey(name: "y")
  double? get y => throw _privateConstructorUsedError; // NEW: Multiple quality URLs for videos
  // Format: {"1080p": "url1", "720p": "url2", "480p": "url3", "360p": "url4"}
  @JsonKey(name: "qualities")
  Map<String, String>? get qualities => throw _privateConstructorUsedError;
  @JsonKey(name: "availableQualities")
  List<String>? get availableQualities => throw _privateConstructorUsedError;

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
  $Res call({
    @JsonKey(name: "file") String? file,
    @JsonKey(name: "type") String? type,
    @JsonKey(name: "_id") String? id,
    @JsonKey(name: "thumbnail") String? thumbnail,
    @JsonKey(name: "x") double? x,
    @JsonKey(name: "y") double? y,
    @JsonKey(name: "qualities") Map<String, String>? qualities,
    @JsonKey(name: "availableQualities") List<String>? availableQualities,
  });
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
    Object? thumbnail = freezed,
    Object? x = freezed,
    Object? y = freezed,
    Object? qualities = freezed,
    Object? availableQualities = freezed,
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
            thumbnail: freezed == thumbnail
                ? _value.thumbnail
                : thumbnail // ignore: cast_nullable_to_non_nullable
                      as String?,
            x: freezed == x
                ? _value.x
                : x // ignore: cast_nullable_to_non_nullable
                      as double?,
            y: freezed == y
                ? _value.y
                : y // ignore: cast_nullable_to_non_nullable
                      as double?,
            qualities: freezed == qualities
                ? _value.qualities
                : qualities // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>?,
            availableQualities: freezed == availableQualities
                ? _value.availableQualities
                : availableQualities // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
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
  $Res call({
    @JsonKey(name: "file") String? file,
    @JsonKey(name: "type") String? type,
    @JsonKey(name: "_id") String? id,
    @JsonKey(name: "thumbnail") String? thumbnail,
    @JsonKey(name: "x") double? x,
    @JsonKey(name: "y") double? y,
    @JsonKey(name: "qualities") Map<String, String>? qualities,
    @JsonKey(name: "availableQualities") List<String>? availableQualities,
  });
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
    Object? thumbnail = freezed,
    Object? x = freezed,
    Object? y = freezed,
    Object? qualities = freezed,
    Object? availableQualities = freezed,
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
        thumbnail: freezed == thumbnail
            ? _value.thumbnail
            : thumbnail // ignore: cast_nullable_to_non_nullable
                  as String?,
        x: freezed == x
            ? _value.x
            : x // ignore: cast_nullable_to_non_nullable
                  as double?,
        y: freezed == y
            ? _value.y
            : y // ignore: cast_nullable_to_non_nullable
                  as double?,
        qualities: freezed == qualities
            ? _value._qualities
            : qualities // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>?,
        availableQualities: freezed == availableQualities
            ? _value._availableQualities
            : availableQualities // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FileElementImpl implements _FileElement {
  const _$FileElementImpl({
    @JsonKey(name: "file") this.file,
    @JsonKey(name: "type") this.type,
    @JsonKey(name: "_id") this.id,
    @JsonKey(name: "thumbnail") this.thumbnail,
    @JsonKey(name: "x") this.x,
    @JsonKey(name: "y") this.y,
    @JsonKey(name: "qualities") final Map<String, String>? qualities,
    @JsonKey(name: "availableQualities") final List<String>? availableQualities,
  }) : _qualities = qualities,
       _availableQualities = availableQualities;

  factory _$FileElementImpl.fromJson(Map<String, dynamic> json) =>
      _$$FileElementImplFromJson(json);

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
  @JsonKey(name: "thumbnail")
  final String? thumbnail;
  @override
  @JsonKey(name: "x")
  final double? x;
  @override
  @JsonKey(name: "y")
  final double? y;
  // NEW: Multiple quality URLs for videos
  // Format: {"1080p": "url1", "720p": "url2", "480p": "url3", "360p": "url4"}
  final Map<String, String>? _qualities;
  // NEW: Multiple quality URLs for videos
  // Format: {"1080p": "url1", "720p": "url2", "480p": "url3", "360p": "url4"}
  @override
  @JsonKey(name: "qualities")
  Map<String, String>? get qualities {
    final value = _qualities;
    if (value == null) return null;
    if (_qualities is EqualUnmodifiableMapView) return _qualities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<String>? _availableQualities;
  @override
  @JsonKey(name: "availableQualities")
  List<String>? get availableQualities {
    final value = _availableQualities;
    if (value == null) return null;
    if (_availableQualities is EqualUnmodifiableListView)
      return _availableQualities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'FileElement(file: $file, type: $type, id: $id, thumbnail: $thumbnail, x: $x, y: $y, qualities: $qualities, availableQualities: $availableQualities)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FileElementImpl &&
            (identical(other.file, file) || other.file == file) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.thumbnail, thumbnail) ||
                other.thumbnail == thumbnail) &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y) &&
            const DeepCollectionEquality().equals(
              other._qualities,
              _qualities,
            ) &&
            const DeepCollectionEquality().equals(
              other._availableQualities,
              _availableQualities,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    file,
    type,
    id,
    thumbnail,
    x,
    y,
    const DeepCollectionEquality().hash(_qualities),
    const DeepCollectionEquality().hash(_availableQualities),
  );

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
    @JsonKey(name: "file") final String? file,
    @JsonKey(name: "type") final String? type,
    @JsonKey(name: "_id") final String? id,
    @JsonKey(name: "thumbnail") final String? thumbnail,
    @JsonKey(name: "x") final double? x,
    @JsonKey(name: "y") final double? y,
    @JsonKey(name: "qualities") final Map<String, String>? qualities,
    @JsonKey(name: "availableQualities") final List<String>? availableQualities,
  }) = _$FileElementImpl;

  factory _FileElement.fromJson(Map<String, dynamic> json) =
      _$FileElementImpl.fromJson;

  @override
  @JsonKey(name: "file")
  String? get file;
  @override
  @JsonKey(name: "type")
  String? get type;
  @override
  @JsonKey(name: "_id")
  String? get id;
  @override
  @JsonKey(name: "thumbnail")
  String? get thumbnail;
  @override
  @JsonKey(name: "x")
  double? get x;
  @override
  @JsonKey(name: "y")
  double? get y; // NEW: Multiple quality URLs for videos
  // Format: {"1080p": "url1", "720p": "url2", "480p": "url3", "360p": "url4"}
  @override
  @JsonKey(name: "qualities")
  Map<String, String>? get qualities;
  @override
  @JsonKey(name: "availableQualities")
  List<String>? get availableQualities;

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
  @JsonKey(name: "_id", fromJson: _voteListItemToString)
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: "userId", fromJson: _voteListItemToString)
  String? get userId => throw _privateConstructorUsedError;
  @JsonKey(name: "postId", fromJson: _voteListItemToString)
  String? get postId => throw _privateConstructorUsedError;
  @JsonKey(name: "optionId", fromJson: _voteListItemToString)
  String? get optionId => throw _privateConstructorUsedError;
  @JsonKey(name: "createdAt")
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: "updatedAt")
  String? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: "__v")
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
    @JsonKey(name: "_id", fromJson: _voteListItemToString) String? id,
    @JsonKey(name: "userId", fromJson: _voteListItemToString) String? userId,
    @JsonKey(name: "postId", fromJson: _voteListItemToString) String? postId,
    @JsonKey(name: "optionId", fromJson: _voteListItemToString)
    String? optionId,
    @JsonKey(name: "createdAt") String? createdAt,
    @JsonKey(name: "updatedAt") String? updatedAt,
    @JsonKey(name: "__v") int? v,
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
    @JsonKey(name: "_id", fromJson: _voteListItemToString) String? id,
    @JsonKey(name: "userId", fromJson: _voteListItemToString) String? userId,
    @JsonKey(name: "postId", fromJson: _voteListItemToString) String? postId,
    @JsonKey(name: "optionId", fromJson: _voteListItemToString)
    String? optionId,
    @JsonKey(name: "createdAt") String? createdAt,
    @JsonKey(name: "updatedAt") String? updatedAt,
    @JsonKey(name: "__v") int? v,
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
    @JsonKey(name: "_id", fromJson: _voteListItemToString) this.id,
    @JsonKey(name: "userId", fromJson: _voteListItemToString) this.userId,
    @JsonKey(name: "postId", fromJson: _voteListItemToString) this.postId,
    @JsonKey(name: "optionId", fromJson: _voteListItemToString) this.optionId,
    @JsonKey(name: "createdAt") this.createdAt,
    @JsonKey(name: "updatedAt") this.updatedAt,
    @JsonKey(name: "__v") this.v,
  });

  factory _$VoteImpl.fromJson(Map<String, dynamic> json) =>
      _$$VoteImplFromJson(json);

  @override
  @JsonKey(name: "_id", fromJson: _voteListItemToString)
  final String? id;
  @override
  @JsonKey(name: "userId", fromJson: _voteListItemToString)
  final String? userId;
  @override
  @JsonKey(name: "postId", fromJson: _voteListItemToString)
  final String? postId;
  @override
  @JsonKey(name: "optionId", fromJson: _voteListItemToString)
  final String? optionId;
  @override
  @JsonKey(name: "createdAt")
  final String? createdAt;
  @override
  @JsonKey(name: "updatedAt")
  final String? updatedAt;
  @override
  @JsonKey(name: "__v")
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
    @JsonKey(name: "_id", fromJson: _voteListItemToString) final String? id,
    @JsonKey(name: "userId", fromJson: _voteListItemToString)
    final String? userId,
    @JsonKey(name: "postId", fromJson: _voteListItemToString)
    final String? postId,
    @JsonKey(name: "optionId", fromJson: _voteListItemToString)
    final String? optionId,
    @JsonKey(name: "createdAt") final String? createdAt,
    @JsonKey(name: "updatedAt") final String? updatedAt,
    @JsonKey(name: "__v") final int? v,
  }) = _$VoteImpl;

  factory _Vote.fromJson(Map<String, dynamic> json) = _$VoteImpl.fromJson;

  @override
  @JsonKey(name: "_id", fromJson: _voteListItemToString)
  String? get id;
  @override
  @JsonKey(name: "userId", fromJson: _voteListItemToString)
  String? get userId;
  @override
  @JsonKey(name: "postId", fromJson: _voteListItemToString)
  String? get postId;
  @override
  @JsonKey(name: "optionId", fromJson: _voteListItemToString)
  String? get optionId;
  @override
  @JsonKey(name: "createdAt")
  String? get createdAt;
  @override
  @JsonKey(name: "updatedAt")
  String? get updatedAt;
  @override
  @JsonKey(name: "__v")
  int? get v;

  /// Create a copy of Vote
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VoteImplCopyWith<_$VoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
