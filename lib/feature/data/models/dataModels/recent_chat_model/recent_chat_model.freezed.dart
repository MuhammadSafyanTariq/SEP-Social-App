// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recent_chat_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RecentChatModel _$RecentChatModelFromJson(Map<String, dynamic> json) {
  return _RecentChatModel.fromJson(json);
}

/// @nodoc
mixin _$RecentChatModel {
  @JsonKey(name: "_id")
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: "groupName")
  dynamic get groupName => throw _privateConstructorUsedError;
  @JsonKey(name: "archived")
  bool? get archived => throw _privateConstructorUsedError;
  @JsonKey(name: "users")
  List<String>? get users => throw _privateConstructorUsedError;
  @JsonKey(name: "isDeleted")
  dynamic get isDeleted => throw _privateConstructorUsedError;
  @JsonKey(name: "admins")
  List<dynamic>? get admins => throw _privateConstructorUsedError;
  @JsonKey(name: "userDetails")
  List<UserDetail>? get userDetails => throw _privateConstructorUsedError;
  @JsonKey(name: "latestMessage")
  LatestMessage? get latestMessage => throw _privateConstructorUsedError;
  @JsonKey(name: "updatedAt")
  String? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: "unreadCount")
  Map<String, int>? get unreadCount => throw _privateConstructorUsedError;
  @JsonKey(name: "lastSeen")
  LastSeen? get lastSeen => throw _privateConstructorUsedError;

  /// Serializes this RecentChatModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecentChatModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecentChatModelCopyWith<RecentChatModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecentChatModelCopyWith<$Res> {
  factory $RecentChatModelCopyWith(
    RecentChatModel value,
    $Res Function(RecentChatModel) then,
  ) = _$RecentChatModelCopyWithImpl<$Res, RecentChatModel>;
  @useResult
  $Res call({
    @JsonKey(name: "_id") String? id,
    @JsonKey(name: "groupName") dynamic groupName,
    @JsonKey(name: "archived") bool? archived,
    @JsonKey(name: "users") List<String>? users,
    @JsonKey(name: "isDeleted") dynamic isDeleted,
    @JsonKey(name: "admins") List<dynamic>? admins,
    @JsonKey(name: "userDetails") List<UserDetail>? userDetails,
    @JsonKey(name: "latestMessage") LatestMessage? latestMessage,
    @JsonKey(name: "updatedAt") String? updatedAt,
    @JsonKey(name: "unreadCount") Map<String, int>? unreadCount,
    @JsonKey(name: "lastSeen") LastSeen? lastSeen,
  });

  $LatestMessageCopyWith<$Res>? get latestMessage;
  $LastSeenCopyWith<$Res>? get lastSeen;
}

/// @nodoc
class _$RecentChatModelCopyWithImpl<$Res, $Val extends RecentChatModel>
    implements $RecentChatModelCopyWith<$Res> {
  _$RecentChatModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecentChatModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? groupName = freezed,
    Object? archived = freezed,
    Object? users = freezed,
    Object? isDeleted = freezed,
    Object? admins = freezed,
    Object? userDetails = freezed,
    Object? latestMessage = freezed,
    Object? updatedAt = freezed,
    Object? unreadCount = freezed,
    Object? lastSeen = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            groupName: freezed == groupName
                ? _value.groupName
                : groupName // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            archived: freezed == archived
                ? _value.archived
                : archived // ignore: cast_nullable_to_non_nullable
                      as bool?,
            users: freezed == users
                ? _value.users
                : users // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            isDeleted: freezed == isDeleted
                ? _value.isDeleted
                : isDeleted // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            admins: freezed == admins
                ? _value.admins
                : admins // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>?,
            userDetails: freezed == userDetails
                ? _value.userDetails
                : userDetails // ignore: cast_nullable_to_non_nullable
                      as List<UserDetail>?,
            latestMessage: freezed == latestMessage
                ? _value.latestMessage
                : latestMessage // ignore: cast_nullable_to_non_nullable
                      as LatestMessage?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            unreadCount: freezed == unreadCount
                ? _value.unreadCount
                : unreadCount // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>?,
            lastSeen: freezed == lastSeen
                ? _value.lastSeen
                : lastSeen // ignore: cast_nullable_to_non_nullable
                      as LastSeen?,
          )
          as $Val,
    );
  }

  /// Create a copy of RecentChatModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LatestMessageCopyWith<$Res>? get latestMessage {
    if (_value.latestMessage == null) {
      return null;
    }

    return $LatestMessageCopyWith<$Res>(_value.latestMessage!, (value) {
      return _then(_value.copyWith(latestMessage: value) as $Val);
    });
  }

  /// Create a copy of RecentChatModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LastSeenCopyWith<$Res>? get lastSeen {
    if (_value.lastSeen == null) {
      return null;
    }

    return $LastSeenCopyWith<$Res>(_value.lastSeen!, (value) {
      return _then(_value.copyWith(lastSeen: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RecentChatModelImplCopyWith<$Res>
    implements $RecentChatModelCopyWith<$Res> {
  factory _$$RecentChatModelImplCopyWith(
    _$RecentChatModelImpl value,
    $Res Function(_$RecentChatModelImpl) then,
  ) = __$$RecentChatModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: "_id") String? id,
    @JsonKey(name: "groupName") dynamic groupName,
    @JsonKey(name: "archived") bool? archived,
    @JsonKey(name: "users") List<String>? users,
    @JsonKey(name: "isDeleted") dynamic isDeleted,
    @JsonKey(name: "admins") List<dynamic>? admins,
    @JsonKey(name: "userDetails") List<UserDetail>? userDetails,
    @JsonKey(name: "latestMessage") LatestMessage? latestMessage,
    @JsonKey(name: "updatedAt") String? updatedAt,
    @JsonKey(name: "unreadCount") Map<String, int>? unreadCount,
    @JsonKey(name: "lastSeen") LastSeen? lastSeen,
  });

  @override
  $LatestMessageCopyWith<$Res>? get latestMessage;
  @override
  $LastSeenCopyWith<$Res>? get lastSeen;
}

/// @nodoc
class __$$RecentChatModelImplCopyWithImpl<$Res>
    extends _$RecentChatModelCopyWithImpl<$Res, _$RecentChatModelImpl>
    implements _$$RecentChatModelImplCopyWith<$Res> {
  __$$RecentChatModelImplCopyWithImpl(
    _$RecentChatModelImpl _value,
    $Res Function(_$RecentChatModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecentChatModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? groupName = freezed,
    Object? archived = freezed,
    Object? users = freezed,
    Object? isDeleted = freezed,
    Object? admins = freezed,
    Object? userDetails = freezed,
    Object? latestMessage = freezed,
    Object? updatedAt = freezed,
    Object? unreadCount = freezed,
    Object? lastSeen = freezed,
  }) {
    return _then(
      _$RecentChatModelImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        groupName: freezed == groupName
            ? _value.groupName
            : groupName // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        archived: freezed == archived
            ? _value.archived
            : archived // ignore: cast_nullable_to_non_nullable
                  as bool?,
        users: freezed == users
            ? _value._users
            : users // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        isDeleted: freezed == isDeleted
            ? _value.isDeleted
            : isDeleted // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        admins: freezed == admins
            ? _value._admins
            : admins // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>?,
        userDetails: freezed == userDetails
            ? _value._userDetails
            : userDetails // ignore: cast_nullable_to_non_nullable
                  as List<UserDetail>?,
        latestMessage: freezed == latestMessage
            ? _value.latestMessage
            : latestMessage // ignore: cast_nullable_to_non_nullable
                  as LatestMessage?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        unreadCount: freezed == unreadCount
            ? _value._unreadCount
            : unreadCount // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>?,
        lastSeen: freezed == lastSeen
            ? _value.lastSeen
            : lastSeen // ignore: cast_nullable_to_non_nullable
                  as LastSeen?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RecentChatModelImpl implements _RecentChatModel {
  const _$RecentChatModelImpl({
    @JsonKey(name: "_id") this.id,
    @JsonKey(name: "groupName") this.groupName,
    @JsonKey(name: "archived") this.archived,
    @JsonKey(name: "users") final List<String>? users,
    @JsonKey(name: "isDeleted") this.isDeleted,
    @JsonKey(name: "admins") final List<dynamic>? admins,
    @JsonKey(name: "userDetails") final List<UserDetail>? userDetails,
    @JsonKey(name: "latestMessage") this.latestMessage,
    @JsonKey(name: "updatedAt") this.updatedAt,
    @JsonKey(name: "unreadCount") final Map<String, int>? unreadCount,
    @JsonKey(name: "lastSeen") this.lastSeen,
  }) : _users = users,
       _admins = admins,
       _userDetails = userDetails,
       _unreadCount = unreadCount;

  factory _$RecentChatModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecentChatModelImplFromJson(json);

  @override
  @JsonKey(name: "_id")
  final String? id;
  @override
  @JsonKey(name: "groupName")
  final dynamic groupName;
  @override
  @JsonKey(name: "archived")
  final bool? archived;
  final List<String>? _users;
  @override
  @JsonKey(name: "users")
  List<String>? get users {
    final value = _users;
    if (value == null) return null;
    if (_users is EqualUnmodifiableListView) return _users;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: "isDeleted")
  final dynamic isDeleted;
  final List<dynamic>? _admins;
  @override
  @JsonKey(name: "admins")
  List<dynamic>? get admins {
    final value = _admins;
    if (value == null) return null;
    if (_admins is EqualUnmodifiableListView) return _admins;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<UserDetail>? _userDetails;
  @override
  @JsonKey(name: "userDetails")
  List<UserDetail>? get userDetails {
    final value = _userDetails;
    if (value == null) return null;
    if (_userDetails is EqualUnmodifiableListView) return _userDetails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: "latestMessage")
  final LatestMessage? latestMessage;
  @override
  @JsonKey(name: "updatedAt")
  final String? updatedAt;
  final Map<String, int>? _unreadCount;
  @override
  @JsonKey(name: "unreadCount")
  Map<String, int>? get unreadCount {
    final value = _unreadCount;
    if (value == null) return null;
    if (_unreadCount is EqualUnmodifiableMapView) return _unreadCount;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: "lastSeen")
  final LastSeen? lastSeen;

  @override
  String toString() {
    return 'RecentChatModel(id: $id, groupName: $groupName, archived: $archived, users: $users, isDeleted: $isDeleted, admins: $admins, userDetails: $userDetails, latestMessage: $latestMessage, updatedAt: $updatedAt, unreadCount: $unreadCount, lastSeen: $lastSeen)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecentChatModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other.groupName, groupName) &&
            (identical(other.archived, archived) ||
                other.archived == archived) &&
            const DeepCollectionEquality().equals(other._users, _users) &&
            const DeepCollectionEquality().equals(other.isDeleted, isDeleted) &&
            const DeepCollectionEquality().equals(other._admins, _admins) &&
            const DeepCollectionEquality().equals(
              other._userDetails,
              _userDetails,
            ) &&
            (identical(other.latestMessage, latestMessage) ||
                other.latestMessage == latestMessage) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(
              other._unreadCount,
              _unreadCount,
            ) &&
            (identical(other.lastSeen, lastSeen) ||
                other.lastSeen == lastSeen));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    const DeepCollectionEquality().hash(groupName),
    archived,
    const DeepCollectionEquality().hash(_users),
    const DeepCollectionEquality().hash(isDeleted),
    const DeepCollectionEquality().hash(_admins),
    const DeepCollectionEquality().hash(_userDetails),
    latestMessage,
    updatedAt,
    const DeepCollectionEquality().hash(_unreadCount),
    lastSeen,
  );

  /// Create a copy of RecentChatModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecentChatModelImplCopyWith<_$RecentChatModelImpl> get copyWith =>
      __$$RecentChatModelImplCopyWithImpl<_$RecentChatModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RecentChatModelImplToJson(this);
  }
}

abstract class _RecentChatModel implements RecentChatModel {
  const factory _RecentChatModel({
    @JsonKey(name: "_id") final String? id,
    @JsonKey(name: "groupName") final dynamic groupName,
    @JsonKey(name: "archived") final bool? archived,
    @JsonKey(name: "users") final List<String>? users,
    @JsonKey(name: "isDeleted") final dynamic isDeleted,
    @JsonKey(name: "admins") final List<dynamic>? admins,
    @JsonKey(name: "userDetails") final List<UserDetail>? userDetails,
    @JsonKey(name: "latestMessage") final LatestMessage? latestMessage,
    @JsonKey(name: "updatedAt") final String? updatedAt,
    @JsonKey(name: "unreadCount") final Map<String, int>? unreadCount,
    @JsonKey(name: "lastSeen") final LastSeen? lastSeen,
  }) = _$RecentChatModelImpl;

  factory _RecentChatModel.fromJson(Map<String, dynamic> json) =
      _$RecentChatModelImpl.fromJson;

  @override
  @JsonKey(name: "_id")
  String? get id;
  @override
  @JsonKey(name: "groupName")
  dynamic get groupName;
  @override
  @JsonKey(name: "archived")
  bool? get archived;
  @override
  @JsonKey(name: "users")
  List<String>? get users;
  @override
  @JsonKey(name: "isDeleted")
  dynamic get isDeleted;
  @override
  @JsonKey(name: "admins")
  List<dynamic>? get admins;
  @override
  @JsonKey(name: "userDetails")
  List<UserDetail>? get userDetails;
  @override
  @JsonKey(name: "latestMessage")
  LatestMessage? get latestMessage;
  @override
  @JsonKey(name: "updatedAt")
  String? get updatedAt;
  @override
  @JsonKey(name: "unreadCount")
  Map<String, int>? get unreadCount;
  @override
  @JsonKey(name: "lastSeen")
  LastSeen? get lastSeen;

  /// Create a copy of RecentChatModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecentChatModelImplCopyWith<_$RecentChatModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LastSeen _$LastSeenFromJson(Map<String, dynamic> json) {
  return _LastSeen.fromJson(json);
}

/// @nodoc
mixin _$LastSeen {
  @JsonKey(name: "67a4923ad27b11f5bb680d91")
  String? get the67A4923Ad27B11F5Bb680D91 => throw _privateConstructorUsedError;

  /// Serializes this LastSeen to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LastSeen
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LastSeenCopyWith<LastSeen> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LastSeenCopyWith<$Res> {
  factory $LastSeenCopyWith(LastSeen value, $Res Function(LastSeen) then) =
      _$LastSeenCopyWithImpl<$Res, LastSeen>;
  @useResult
  $Res call({
    @JsonKey(name: "67a4923ad27b11f5bb680d91")
    String? the67A4923Ad27B11F5Bb680D91,
  });
}

/// @nodoc
class _$LastSeenCopyWithImpl<$Res, $Val extends LastSeen>
    implements $LastSeenCopyWith<$Res> {
  _$LastSeenCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LastSeen
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? the67A4923Ad27B11F5Bb680D91 = freezed}) {
    return _then(
      _value.copyWith(
            the67A4923Ad27B11F5Bb680D91: freezed == the67A4923Ad27B11F5Bb680D91
                ? _value.the67A4923Ad27B11F5Bb680D91
                : the67A4923Ad27B11F5Bb680D91 // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LastSeenImplCopyWith<$Res>
    implements $LastSeenCopyWith<$Res> {
  factory _$$LastSeenImplCopyWith(
    _$LastSeenImpl value,
    $Res Function(_$LastSeenImpl) then,
  ) = __$$LastSeenImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: "67a4923ad27b11f5bb680d91")
    String? the67A4923Ad27B11F5Bb680D91,
  });
}

/// @nodoc
class __$$LastSeenImplCopyWithImpl<$Res>
    extends _$LastSeenCopyWithImpl<$Res, _$LastSeenImpl>
    implements _$$LastSeenImplCopyWith<$Res> {
  __$$LastSeenImplCopyWithImpl(
    _$LastSeenImpl _value,
    $Res Function(_$LastSeenImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LastSeen
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? the67A4923Ad27B11F5Bb680D91 = freezed}) {
    return _then(
      _$LastSeenImpl(
        the67A4923Ad27B11F5Bb680D91: freezed == the67A4923Ad27B11F5Bb680D91
            ? _value.the67A4923Ad27B11F5Bb680D91
            : the67A4923Ad27B11F5Bb680D91 // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LastSeenImpl implements _LastSeen {
  const _$LastSeenImpl({
    @JsonKey(name: "67a4923ad27b11f5bb680d91") this.the67A4923Ad27B11F5Bb680D91,
  });

  factory _$LastSeenImpl.fromJson(Map<String, dynamic> json) =>
      _$$LastSeenImplFromJson(json);

  @override
  @JsonKey(name: "67a4923ad27b11f5bb680d91")
  final String? the67A4923Ad27B11F5Bb680D91;

  @override
  String toString() {
    return 'LastSeen(the67A4923Ad27B11F5Bb680D91: $the67A4923Ad27B11F5Bb680D91)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LastSeenImpl &&
            (identical(
                  other.the67A4923Ad27B11F5Bb680D91,
                  the67A4923Ad27B11F5Bb680D91,
                ) ||
                other.the67A4923Ad27B11F5Bb680D91 ==
                    the67A4923Ad27B11F5Bb680D91));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, the67A4923Ad27B11F5Bb680D91);

  /// Create a copy of LastSeen
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LastSeenImplCopyWith<_$LastSeenImpl> get copyWith =>
      __$$LastSeenImplCopyWithImpl<_$LastSeenImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LastSeenImplToJson(this);
  }
}

abstract class _LastSeen implements LastSeen {
  const factory _LastSeen({
    @JsonKey(name: "67a4923ad27b11f5bb680d91")
    final String? the67A4923Ad27B11F5Bb680D91,
  }) = _$LastSeenImpl;

  factory _LastSeen.fromJson(Map<String, dynamic> json) =
      _$LastSeenImpl.fromJson;

  @override
  @JsonKey(name: "67a4923ad27b11f5bb680d91")
  String? get the67A4923Ad27B11F5Bb680D91;

  /// Create a copy of LastSeen
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LastSeenImplCopyWith<_$LastSeenImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LatestMessage _$LatestMessageFromJson(Map<String, dynamic> json) {
  return _LatestMessage.fromJson(json);
}

/// @nodoc
mixin _$LatestMessage {
  @JsonKey(name: "content")
  String? get content => throw _privateConstructorUsedError;
  @JsonKey(name: "senderTime")
  String? get senderTime => throw _privateConstructorUsedError;

  /// Serializes this LatestMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LatestMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LatestMessageCopyWith<LatestMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LatestMessageCopyWith<$Res> {
  factory $LatestMessageCopyWith(
    LatestMessage value,
    $Res Function(LatestMessage) then,
  ) = _$LatestMessageCopyWithImpl<$Res, LatestMessage>;
  @useResult
  $Res call({
    @JsonKey(name: "content") String? content,
    @JsonKey(name: "senderTime") String? senderTime,
  });
}

/// @nodoc
class _$LatestMessageCopyWithImpl<$Res, $Val extends LatestMessage>
    implements $LatestMessageCopyWith<$Res> {
  _$LatestMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LatestMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? content = freezed, Object? senderTime = freezed}) {
    return _then(
      _value.copyWith(
            content: freezed == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String?,
            senderTime: freezed == senderTime
                ? _value.senderTime
                : senderTime // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LatestMessageImplCopyWith<$Res>
    implements $LatestMessageCopyWith<$Res> {
  factory _$$LatestMessageImplCopyWith(
    _$LatestMessageImpl value,
    $Res Function(_$LatestMessageImpl) then,
  ) = __$$LatestMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: "content") String? content,
    @JsonKey(name: "senderTime") String? senderTime,
  });
}

/// @nodoc
class __$$LatestMessageImplCopyWithImpl<$Res>
    extends _$LatestMessageCopyWithImpl<$Res, _$LatestMessageImpl>
    implements _$$LatestMessageImplCopyWith<$Res> {
  __$$LatestMessageImplCopyWithImpl(
    _$LatestMessageImpl _value,
    $Res Function(_$LatestMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LatestMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? content = freezed, Object? senderTime = freezed}) {
    return _then(
      _$LatestMessageImpl(
        content: freezed == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$LatestMessageImpl implements _LatestMessage {
  const _$LatestMessageImpl({
    @JsonKey(name: "content") this.content,
    @JsonKey(name: "senderTime") this.senderTime,
  });

  factory _$LatestMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$LatestMessageImplFromJson(json);

  @override
  @JsonKey(name: "content")
  final String? content;
  @override
  @JsonKey(name: "senderTime")
  final String? senderTime;

  @override
  String toString() {
    return 'LatestMessage(content: $content, senderTime: $senderTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LatestMessageImpl &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.senderTime, senderTime) ||
                other.senderTime == senderTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, content, senderTime);

  /// Create a copy of LatestMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LatestMessageImplCopyWith<_$LatestMessageImpl> get copyWith =>
      __$$LatestMessageImplCopyWithImpl<_$LatestMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LatestMessageImplToJson(this);
  }
}

abstract class _LatestMessage implements LatestMessage {
  const factory _LatestMessage({
    @JsonKey(name: "content") final String? content,
    @JsonKey(name: "senderTime") final String? senderTime,
  }) = _$LatestMessageImpl;

  factory _LatestMessage.fromJson(Map<String, dynamic> json) =
      _$LatestMessageImpl.fromJson;

  @override
  @JsonKey(name: "content")
  String? get content;
  @override
  @JsonKey(name: "senderTime")
  String? get senderTime;

  /// Create a copy of LatestMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LatestMessageImplCopyWith<_$LatestMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UnreadCount _$UnreadCountFromJson(Map<String, dynamic> json) {
  return _UnreadCount.fromJson(json);
}

/// @nodoc
mixin _$UnreadCount {
  @JsonKey(name: "67a4923ad27b11f5bb680d91")
  int? get the67A4923Ad27B11F5Bb680D91 => throw _privateConstructorUsedError;
  @JsonKey(name: "67a34e3bc7aea8a744b35519")
  int? get the67A34E3Bc7Aea8A744B35519 => throw _privateConstructorUsedError;

  /// Serializes this UnreadCount to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UnreadCount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UnreadCountCopyWith<UnreadCount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UnreadCountCopyWith<$Res> {
  factory $UnreadCountCopyWith(
    UnreadCount value,
    $Res Function(UnreadCount) then,
  ) = _$UnreadCountCopyWithImpl<$Res, UnreadCount>;
  @useResult
  $Res call({
    @JsonKey(name: "67a4923ad27b11f5bb680d91") int? the67A4923Ad27B11F5Bb680D91,
    @JsonKey(name: "67a34e3bc7aea8a744b35519") int? the67A34E3Bc7Aea8A744B35519,
  });
}

/// @nodoc
class _$UnreadCountCopyWithImpl<$Res, $Val extends UnreadCount>
    implements $UnreadCountCopyWith<$Res> {
  _$UnreadCountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UnreadCount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? the67A4923Ad27B11F5Bb680D91 = freezed,
    Object? the67A34E3Bc7Aea8A744B35519 = freezed,
  }) {
    return _then(
      _value.copyWith(
            the67A4923Ad27B11F5Bb680D91: freezed == the67A4923Ad27B11F5Bb680D91
                ? _value.the67A4923Ad27B11F5Bb680D91
                : the67A4923Ad27B11F5Bb680D91 // ignore: cast_nullable_to_non_nullable
                      as int?,
            the67A34E3Bc7Aea8A744B35519: freezed == the67A34E3Bc7Aea8A744B35519
                ? _value.the67A34E3Bc7Aea8A744B35519
                : the67A34E3Bc7Aea8A744B35519 // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UnreadCountImplCopyWith<$Res>
    implements $UnreadCountCopyWith<$Res> {
  factory _$$UnreadCountImplCopyWith(
    _$UnreadCountImpl value,
    $Res Function(_$UnreadCountImpl) then,
  ) = __$$UnreadCountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: "67a4923ad27b11f5bb680d91") int? the67A4923Ad27B11F5Bb680D91,
    @JsonKey(name: "67a34e3bc7aea8a744b35519") int? the67A34E3Bc7Aea8A744B35519,
  });
}

/// @nodoc
class __$$UnreadCountImplCopyWithImpl<$Res>
    extends _$UnreadCountCopyWithImpl<$Res, _$UnreadCountImpl>
    implements _$$UnreadCountImplCopyWith<$Res> {
  __$$UnreadCountImplCopyWithImpl(
    _$UnreadCountImpl _value,
    $Res Function(_$UnreadCountImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UnreadCount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? the67A4923Ad27B11F5Bb680D91 = freezed,
    Object? the67A34E3Bc7Aea8A744B35519 = freezed,
  }) {
    return _then(
      _$UnreadCountImpl(
        the67A4923Ad27B11F5Bb680D91: freezed == the67A4923Ad27B11F5Bb680D91
            ? _value.the67A4923Ad27B11F5Bb680D91
            : the67A4923Ad27B11F5Bb680D91 // ignore: cast_nullable_to_non_nullable
                  as int?,
        the67A34E3Bc7Aea8A744B35519: freezed == the67A34E3Bc7Aea8A744B35519
            ? _value.the67A34E3Bc7Aea8A744B35519
            : the67A34E3Bc7Aea8A744B35519 // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UnreadCountImpl implements _UnreadCount {
  const _$UnreadCountImpl({
    @JsonKey(name: "67a4923ad27b11f5bb680d91") this.the67A4923Ad27B11F5Bb680D91,
    @JsonKey(name: "67a34e3bc7aea8a744b35519") this.the67A34E3Bc7Aea8A744B35519,
  });

  factory _$UnreadCountImpl.fromJson(Map<String, dynamic> json) =>
      _$$UnreadCountImplFromJson(json);

  @override
  @JsonKey(name: "67a4923ad27b11f5bb680d91")
  final int? the67A4923Ad27B11F5Bb680D91;
  @override
  @JsonKey(name: "67a34e3bc7aea8a744b35519")
  final int? the67A34E3Bc7Aea8A744B35519;

  @override
  String toString() {
    return 'UnreadCount(the67A4923Ad27B11F5Bb680D91: $the67A4923Ad27B11F5Bb680D91, the67A34E3Bc7Aea8A744B35519: $the67A34E3Bc7Aea8A744B35519)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnreadCountImpl &&
            (identical(
                  other.the67A4923Ad27B11F5Bb680D91,
                  the67A4923Ad27B11F5Bb680D91,
                ) ||
                other.the67A4923Ad27B11F5Bb680D91 ==
                    the67A4923Ad27B11F5Bb680D91) &&
            (identical(
                  other.the67A34E3Bc7Aea8A744B35519,
                  the67A34E3Bc7Aea8A744B35519,
                ) ||
                other.the67A34E3Bc7Aea8A744B35519 ==
                    the67A34E3Bc7Aea8A744B35519));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    the67A4923Ad27B11F5Bb680D91,
    the67A34E3Bc7Aea8A744B35519,
  );

  /// Create a copy of UnreadCount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnreadCountImplCopyWith<_$UnreadCountImpl> get copyWith =>
      __$$UnreadCountImplCopyWithImpl<_$UnreadCountImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UnreadCountImplToJson(this);
  }
}

abstract class _UnreadCount implements UnreadCount {
  const factory _UnreadCount({
    @JsonKey(name: "67a4923ad27b11f5bb680d91")
    final int? the67A4923Ad27B11F5Bb680D91,
    @JsonKey(name: "67a34e3bc7aea8a744b35519")
    final int? the67A34E3Bc7Aea8A744B35519,
  }) = _$UnreadCountImpl;

  factory _UnreadCount.fromJson(Map<String, dynamic> json) =
      _$UnreadCountImpl.fromJson;

  @override
  @JsonKey(name: "67a4923ad27b11f5bb680d91")
  int? get the67A4923Ad27B11F5Bb680D91;
  @override
  @JsonKey(name: "67a34e3bc7aea8a744b35519")
  int? get the67A34E3Bc7Aea8A744B35519;

  /// Create a copy of UnreadCount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnreadCountImplCopyWith<_$UnreadCountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserDetail _$UserDetailFromJson(Map<String, dynamic> json) {
  return _UserDetail.fromJson(json);
}

/// @nodoc
mixin _$UserDetail {
  @JsonKey(name: "_id")
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: "name")
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: "image")
  String? get image => throw _privateConstructorUsedError;

  /// Serializes this UserDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserDetailCopyWith<UserDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserDetailCopyWith<$Res> {
  factory $UserDetailCopyWith(
    UserDetail value,
    $Res Function(UserDetail) then,
  ) = _$UserDetailCopyWithImpl<$Res, UserDetail>;
  @useResult
  $Res call({
    @JsonKey(name: "_id") String? id,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "image") String? image,
  });
}

/// @nodoc
class _$UserDetailCopyWithImpl<$Res, $Val extends UserDetail>
    implements $UserDetailCopyWith<$Res> {
  _$UserDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserDetail
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
abstract class _$$UserDetailImplCopyWith<$Res>
    implements $UserDetailCopyWith<$Res> {
  factory _$$UserDetailImplCopyWith(
    _$UserDetailImpl value,
    $Res Function(_$UserDetailImpl) then,
  ) = __$$UserDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: "_id") String? id,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "image") String? image,
  });
}

/// @nodoc
class __$$UserDetailImplCopyWithImpl<$Res>
    extends _$UserDetailCopyWithImpl<$Res, _$UserDetailImpl>
    implements _$$UserDetailImplCopyWith<$Res> {
  __$$UserDetailImplCopyWithImpl(
    _$UserDetailImpl _value,
    $Res Function(_$UserDetailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? image = freezed,
  }) {
    return _then(
      _$UserDetailImpl(
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
class _$UserDetailImpl implements _UserDetail {
  const _$UserDetailImpl({
    @JsonKey(name: "_id") this.id,
    @JsonKey(name: "name") this.name,
    @JsonKey(name: "image") this.image,
  });

  factory _$UserDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserDetailImplFromJson(json);

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
    return 'UserDetail(id: $id, name: $name, image: $image)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.image, image) || other.image == image));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, image);

  /// Create a copy of UserDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserDetailImplCopyWith<_$UserDetailImpl> get copyWith =>
      __$$UserDetailImplCopyWithImpl<_$UserDetailImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserDetailImplToJson(this);
  }
}

abstract class _UserDetail implements UserDetail {
  const factory _UserDetail({
    @JsonKey(name: "_id") final String? id,
    @JsonKey(name: "name") final String? name,
    @JsonKey(name: "image") final String? image,
  }) = _$UserDetailImpl;

  factory _UserDetail.fromJson(Map<String, dynamic> json) =
      _$UserDetailImpl.fromJson;

  @override
  @JsonKey(name: "_id")
  String? get id;
  @override
  @JsonKey(name: "name")
  String? get name;
  @override
  @JsonKey(name: "image")
  String? get image;

  /// Create a copy of UserDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserDetailImplCopyWith<_$UserDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
