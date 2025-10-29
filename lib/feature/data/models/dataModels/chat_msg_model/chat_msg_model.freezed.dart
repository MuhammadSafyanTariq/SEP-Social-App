// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_msg_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChatMsgModel _$ChatMsgModelFromJson(Map<String, dynamic> json) {
  return _ChatMsgModel.fromJson(json);
}

/// @nodoc
mixin _$ChatMsgModel {
  @JsonKey(name: '_id')
  String? get id => throw _privateConstructorUsedError;
  String? get chat => throw _privateConstructorUsedError;
  Sender? get sender => throw _privateConstructorUsedError;
  String? get content => throw _privateConstructorUsedError;
  dynamic get isDeleted => throw _privateConstructorUsedError;
  String? get mediaType => throw _privateConstructorUsedError;
  List<dynamic>? get readBy => throw _privateConstructorUsedError;
  List<dynamic>? get mediaUrl => throw _privateConstructorUsedError;
  String? get channelId => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: '__v')
  int? get v => throw _privateConstructorUsedError;
  String? get senderTime => throw _privateConstructorUsedError;

  /// Serializes this ChatMsgModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatMsgModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatMsgModelCopyWith<ChatMsgModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMsgModelCopyWith<$Res> {
  factory $ChatMsgModelCopyWith(
    ChatMsgModel value,
    $Res Function(ChatMsgModel) then,
  ) = _$ChatMsgModelCopyWithImpl<$Res, ChatMsgModel>;
  @useResult
  $Res call({
    @JsonKey(name: '_id') String? id,
    String? chat,
    Sender? sender,
    String? content,
    dynamic isDeleted,
    String? mediaType,
    List<dynamic>? readBy,
    List<dynamic>? mediaUrl,
    String? channelId,
    String? createdAt,
    String? updatedAt,
    @JsonKey(name: '__v') int? v,
    String? senderTime,
  });

  $SenderCopyWith<$Res>? get sender;
}

/// @nodoc
class _$ChatMsgModelCopyWithImpl<$Res, $Val extends ChatMsgModel>
    implements $ChatMsgModelCopyWith<$Res> {
  _$ChatMsgModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatMsgModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? chat = freezed,
    Object? sender = freezed,
    Object? content = freezed,
    Object? isDeleted = freezed,
    Object? mediaType = freezed,
    Object? readBy = freezed,
    Object? mediaUrl = freezed,
    Object? channelId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? v = freezed,
    Object? senderTime = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            chat: freezed == chat
                ? _value.chat
                : chat // ignore: cast_nullable_to_non_nullable
                      as String?,
            sender: freezed == sender
                ? _value.sender
                : sender // ignore: cast_nullable_to_non_nullable
                      as Sender?,
            content: freezed == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String?,
            isDeleted: freezed == isDeleted
                ? _value.isDeleted
                : isDeleted // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            mediaType: freezed == mediaType
                ? _value.mediaType
                : mediaType // ignore: cast_nullable_to_non_nullable
                      as String?,
            readBy: freezed == readBy
                ? _value.readBy
                : readBy // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>?,
            mediaUrl: freezed == mediaUrl
                ? _value.mediaUrl
                : mediaUrl // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>?,
            channelId: freezed == channelId
                ? _value.channelId
                : channelId // ignore: cast_nullable_to_non_nullable
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
            senderTime: freezed == senderTime
                ? _value.senderTime
                : senderTime // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of ChatMsgModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SenderCopyWith<$Res>? get sender {
    if (_value.sender == null) {
      return null;
    }

    return $SenderCopyWith<$Res>(_value.sender!, (value) {
      return _then(_value.copyWith(sender: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChatMsgModelImplCopyWith<$Res>
    implements $ChatMsgModelCopyWith<$Res> {
  factory _$$ChatMsgModelImplCopyWith(
    _$ChatMsgModelImpl value,
    $Res Function(_$ChatMsgModelImpl) then,
  ) = __$$ChatMsgModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: '_id') String? id,
    String? chat,
    Sender? sender,
    String? content,
    dynamic isDeleted,
    String? mediaType,
    List<dynamic>? readBy,
    List<dynamic>? mediaUrl,
    String? channelId,
    String? createdAt,
    String? updatedAt,
    @JsonKey(name: '__v') int? v,
    String? senderTime,
  });

  @override
  $SenderCopyWith<$Res>? get sender;
}

/// @nodoc
class __$$ChatMsgModelImplCopyWithImpl<$Res>
    extends _$ChatMsgModelCopyWithImpl<$Res, _$ChatMsgModelImpl>
    implements _$$ChatMsgModelImplCopyWith<$Res> {
  __$$ChatMsgModelImplCopyWithImpl(
    _$ChatMsgModelImpl _value,
    $Res Function(_$ChatMsgModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatMsgModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? chat = freezed,
    Object? sender = freezed,
    Object? content = freezed,
    Object? isDeleted = freezed,
    Object? mediaType = freezed,
    Object? readBy = freezed,
    Object? mediaUrl = freezed,
    Object? channelId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? v = freezed,
    Object? senderTime = freezed,
  }) {
    return _then(
      _$ChatMsgModelImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        chat: freezed == chat
            ? _value.chat
            : chat // ignore: cast_nullable_to_non_nullable
                  as String?,
        sender: freezed == sender
            ? _value.sender
            : sender // ignore: cast_nullable_to_non_nullable
                  as Sender?,
        content: freezed == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String?,
        isDeleted: freezed == isDeleted
            ? _value.isDeleted
            : isDeleted // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        mediaType: freezed == mediaType
            ? _value.mediaType
            : mediaType // ignore: cast_nullable_to_non_nullable
                  as String?,
        readBy: freezed == readBy
            ? _value._readBy
            : readBy // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>?,
        mediaUrl: freezed == mediaUrl
            ? _value._mediaUrl
            : mediaUrl // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>?,
        channelId: freezed == channelId
            ? _value.channelId
            : channelId // ignore: cast_nullable_to_non_nullable
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
        senderTime: freezed == senderTime
            ? _value.senderTime
            : senderTime // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMsgModelImpl implements _ChatMsgModel {
  const _$ChatMsgModelImpl({
    @JsonKey(name: '_id') this.id,
    this.chat,
    this.sender,
    this.content,
    this.isDeleted,
    this.mediaType,
    final List<dynamic>? readBy,
    final List<dynamic>? mediaUrl,
    this.channelId,
    this.createdAt,
    this.updatedAt,
    @JsonKey(name: '__v') this.v,
    this.senderTime,
  }) : _readBy = readBy,
       _mediaUrl = mediaUrl;

  factory _$ChatMsgModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMsgModelImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String? id;
  @override
  final String? chat;
  @override
  final Sender? sender;
  @override
  final String? content;
  @override
  final dynamic isDeleted;
  @override
  final String? mediaType;
  final List<dynamic>? _readBy;
  @override
  List<dynamic>? get readBy {
    final value = _readBy;
    if (value == null) return null;
    if (_readBy is EqualUnmodifiableListView) return _readBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<dynamic>? _mediaUrl;
  @override
  List<dynamic>? get mediaUrl {
    final value = _mediaUrl;
    if (value == null) return null;
    if (_mediaUrl is EqualUnmodifiableListView) return _mediaUrl;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? channelId;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;
  @override
  @JsonKey(name: '__v')
  final int? v;
  @override
  final String? senderTime;

  @override
  String toString() {
    return 'ChatMsgModel(id: $id, chat: $chat, sender: $sender, content: $content, isDeleted: $isDeleted, mediaType: $mediaType, readBy: $readBy, mediaUrl: $mediaUrl, channelId: $channelId, createdAt: $createdAt, updatedAt: $updatedAt, v: $v, senderTime: $senderTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMsgModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.chat, chat) || other.chat == chat) &&
            (identical(other.sender, sender) || other.sender == sender) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other.isDeleted, isDeleted) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            const DeepCollectionEquality().equals(other._readBy, _readBy) &&
            const DeepCollectionEquality().equals(other._mediaUrl, _mediaUrl) &&
            (identical(other.channelId, channelId) ||
                other.channelId == channelId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.v, v) || other.v == v) &&
            (identical(other.senderTime, senderTime) ||
                other.senderTime == senderTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    chat,
    sender,
    content,
    const DeepCollectionEquality().hash(isDeleted),
    mediaType,
    const DeepCollectionEquality().hash(_readBy),
    const DeepCollectionEquality().hash(_mediaUrl),
    channelId,
    createdAt,
    updatedAt,
    v,
    senderTime,
  );

  /// Create a copy of ChatMsgModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMsgModelImplCopyWith<_$ChatMsgModelImpl> get copyWith =>
      __$$ChatMsgModelImplCopyWithImpl<_$ChatMsgModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMsgModelImplToJson(this);
  }
}

abstract class _ChatMsgModel implements ChatMsgModel {
  const factory _ChatMsgModel({
    @JsonKey(name: '_id') final String? id,
    final String? chat,
    final Sender? sender,
    final String? content,
    final dynamic isDeleted,
    final String? mediaType,
    final List<dynamic>? readBy,
    final List<dynamic>? mediaUrl,
    final String? channelId,
    final String? createdAt,
    final String? updatedAt,
    @JsonKey(name: '__v') final int? v,
    final String? senderTime,
  }) = _$ChatMsgModelImpl;

  factory _ChatMsgModel.fromJson(Map<String, dynamic> json) =
      _$ChatMsgModelImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String? get id;
  @override
  String? get chat;
  @override
  Sender? get sender;
  @override
  String? get content;
  @override
  dynamic get isDeleted;
  @override
  String? get mediaType;
  @override
  List<dynamic>? get readBy;
  @override
  List<dynamic>? get mediaUrl;
  @override
  String? get channelId;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;
  @override
  @JsonKey(name: '__v')
  int? get v;
  @override
  String? get senderTime;

  /// Create a copy of ChatMsgModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMsgModelImplCopyWith<_$ChatMsgModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Sender _$SenderFromJson(Map<String, dynamic> json) {
  return _Sender.fromJson(json);
}

/// @nodoc
mixin _$Sender {
  @JsonKey(name: '_id')
  String? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;

  /// Serializes this Sender to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Sender
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SenderCopyWith<Sender> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SenderCopyWith<$Res> {
  factory $SenderCopyWith(Sender value, $Res Function(Sender) then) =
      _$SenderCopyWithImpl<$Res, Sender>;
  @useResult
  $Res call({@JsonKey(name: '_id') String? id, String? name});
}

/// @nodoc
class _$SenderCopyWithImpl<$Res, $Val extends Sender>
    implements $SenderCopyWith<$Res> {
  _$SenderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Sender
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = freezed, Object? name = freezed}) {
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SenderImplCopyWith<$Res> implements $SenderCopyWith<$Res> {
  factory _$$SenderImplCopyWith(
    _$SenderImpl value,
    $Res Function(_$SenderImpl) then,
  ) = __$$SenderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: '_id') String? id, String? name});
}

/// @nodoc
class __$$SenderImplCopyWithImpl<$Res>
    extends _$SenderCopyWithImpl<$Res, _$SenderImpl>
    implements _$$SenderImplCopyWith<$Res> {
  __$$SenderImplCopyWithImpl(
    _$SenderImpl _value,
    $Res Function(_$SenderImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Sender
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = freezed, Object? name = freezed}) {
    return _then(
      _$SenderImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SenderImpl implements _Sender {
  const _$SenderImpl({@JsonKey(name: '_id') this.id, this.name});

  factory _$SenderImpl.fromJson(Map<String, dynamic> json) =>
      _$$SenderImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String? id;
  @override
  final String? name;

  @override
  String toString() {
    return 'Sender(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SenderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  /// Create a copy of Sender
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SenderImplCopyWith<_$SenderImpl> get copyWith =>
      __$$SenderImplCopyWithImpl<_$SenderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SenderImplToJson(this);
  }
}

abstract class _Sender implements Sender {
  const factory _Sender({
    @JsonKey(name: '_id') final String? id,
    final String? name,
  }) = _$SenderImpl;

  factory _Sender.fromJson(Map<String, dynamic> json) = _$SenderImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String? get id;
  @override
  String? get name;

  /// Create a copy of Sender
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SenderImplCopyWith<_$SenderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
