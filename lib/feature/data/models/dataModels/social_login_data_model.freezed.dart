// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'social_login_data_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SocialLoginDataModel _$SocialLoginDataModelFromJson(Map<String, dynamic> json) {
  return _SocialLoginDataModel.fromJson(json);
}

/// @nodoc
mixin _$SocialLoginDataModel {
  bool? get status => throw _privateConstructorUsedError;
  int? get code => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  Data? get data => throw _privateConstructorUsedError;

  /// Serializes this SocialLoginDataModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SocialLoginDataModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SocialLoginDataModelCopyWith<SocialLoginDataModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SocialLoginDataModelCopyWith<$Res> {
  factory $SocialLoginDataModelCopyWith(
    SocialLoginDataModel value,
    $Res Function(SocialLoginDataModel) then,
  ) = _$SocialLoginDataModelCopyWithImpl<$Res, SocialLoginDataModel>;
  @useResult
  $Res call({bool? status, int? code, String? message, Data? data});

  $DataCopyWith<$Res>? get data;
}

/// @nodoc
class _$SocialLoginDataModelCopyWithImpl<
  $Res,
  $Val extends SocialLoginDataModel
>
    implements $SocialLoginDataModelCopyWith<$Res> {
  _$SocialLoginDataModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SocialLoginDataModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = freezed,
    Object? code = freezed,
    Object? message = freezed,
    Object? data = freezed,
  }) {
    return _then(
      _value.copyWith(
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as bool?,
            code: freezed == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as int?,
            message: freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String?,
            data: freezed == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as Data?,
          )
          as $Val,
    );
  }

  /// Create a copy of SocialLoginDataModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DataCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $DataCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SocialLoginDataModelImplCopyWith<$Res>
    implements $SocialLoginDataModelCopyWith<$Res> {
  factory _$$SocialLoginDataModelImplCopyWith(
    _$SocialLoginDataModelImpl value,
    $Res Function(_$SocialLoginDataModelImpl) then,
  ) = __$$SocialLoginDataModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool? status, int? code, String? message, Data? data});

  @override
  $DataCopyWith<$Res>? get data;
}

/// @nodoc
class __$$SocialLoginDataModelImplCopyWithImpl<$Res>
    extends _$SocialLoginDataModelCopyWithImpl<$Res, _$SocialLoginDataModelImpl>
    implements _$$SocialLoginDataModelImplCopyWith<$Res> {
  __$$SocialLoginDataModelImplCopyWithImpl(
    _$SocialLoginDataModelImpl _value,
    $Res Function(_$SocialLoginDataModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SocialLoginDataModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = freezed,
    Object? code = freezed,
    Object? message = freezed,
    Object? data = freezed,
  }) {
    return _then(
      _$SocialLoginDataModelImpl(
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as bool?,
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as int?,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        data: freezed == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as Data?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SocialLoginDataModelImpl implements _SocialLoginDataModel {
  const _$SocialLoginDataModelImpl({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory _$SocialLoginDataModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SocialLoginDataModelImplFromJson(json);

  @override
  final bool? status;
  @override
  final int? code;
  @override
  final String? message;
  @override
  final Data? data;

  @override
  String toString() {
    return 'SocialLoginDataModel(status: $status, code: $code, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SocialLoginDataModelImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status, code, message, data);

  /// Create a copy of SocialLoginDataModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SocialLoginDataModelImplCopyWith<_$SocialLoginDataModelImpl>
  get copyWith =>
      __$$SocialLoginDataModelImplCopyWithImpl<_$SocialLoginDataModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SocialLoginDataModelImplToJson(this);
  }
}

abstract class _SocialLoginDataModel implements SocialLoginDataModel {
  const factory _SocialLoginDataModel({
    final bool? status,
    final int? code,
    final String? message,
    final Data? data,
  }) = _$SocialLoginDataModelImpl;

  factory _SocialLoginDataModel.fromJson(Map<String, dynamic> json) =
      _$SocialLoginDataModelImpl.fromJson;

  @override
  bool? get status;
  @override
  int? get code;
  @override
  String? get message;
  @override
  Data? get data;

  /// Create a copy of SocialLoginDataModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SocialLoginDataModelImplCopyWith<_$SocialLoginDataModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

Data _$DataFromJson(Map<String, dynamic> json) {
  return _Data.fromJson(json);
}

/// @nodoc
mixin _$Data {
  UserData? get userData => throw _privateConstructorUsedError;
  String? get token => throw _privateConstructorUsedError;

  /// Serializes this Data to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Data
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DataCopyWith<Data> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DataCopyWith<$Res> {
  factory $DataCopyWith(Data value, $Res Function(Data) then) =
      _$DataCopyWithImpl<$Res, Data>;
  @useResult
  $Res call({UserData? userData, String? token});

  $UserDataCopyWith<$Res>? get userData;
}

/// @nodoc
class _$DataCopyWithImpl<$Res, $Val extends Data>
    implements $DataCopyWith<$Res> {
  _$DataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Data
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userData = freezed, Object? token = freezed}) {
    return _then(
      _value.copyWith(
            userData: freezed == userData
                ? _value.userData
                : userData // ignore: cast_nullable_to_non_nullable
                      as UserData?,
            token: freezed == token
                ? _value.token
                : token // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of Data
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserDataCopyWith<$Res>? get userData {
    if (_value.userData == null) {
      return null;
    }

    return $UserDataCopyWith<$Res>(_value.userData!, (value) {
      return _then(_value.copyWith(userData: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DataImplCopyWith<$Res> implements $DataCopyWith<$Res> {
  factory _$$DataImplCopyWith(
    _$DataImpl value,
    $Res Function(_$DataImpl) then,
  ) = __$$DataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({UserData? userData, String? token});

  @override
  $UserDataCopyWith<$Res>? get userData;
}

/// @nodoc
class __$$DataImplCopyWithImpl<$Res>
    extends _$DataCopyWithImpl<$Res, _$DataImpl>
    implements _$$DataImplCopyWith<$Res> {
  __$$DataImplCopyWithImpl(_$DataImpl _value, $Res Function(_$DataImpl) _then)
    : super(_value, _then);

  /// Create a copy of Data
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userData = freezed, Object? token = freezed}) {
    return _then(
      _$DataImpl(
        userData: freezed == userData
            ? _value.userData
            : userData // ignore: cast_nullable_to_non_nullable
                  as UserData?,
        token: freezed == token
            ? _value.token
            : token // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DataImpl implements _Data {
  const _$DataImpl({this.userData, this.token});

  factory _$DataImpl.fromJson(Map<String, dynamic> json) =>
      _$$DataImplFromJson(json);

  @override
  final UserData? userData;
  @override
  final String? token;

  @override
  String toString() {
    return 'Data(userData: $userData, token: $token)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DataImpl &&
            (identical(other.userData, userData) ||
                other.userData == userData) &&
            (identical(other.token, token) || other.token == token));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userData, token);

  /// Create a copy of Data
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DataImplCopyWith<_$DataImpl> get copyWith =>
      __$$DataImplCopyWithImpl<_$DataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DataImplToJson(this);
  }
}

abstract class _Data implements Data {
  const factory _Data({final UserData? userData, final String? token}) =
      _$DataImpl;

  factory _Data.fromJson(Map<String, dynamic> json) = _$DataImpl.fromJson;

  @override
  UserData? get userData;
  @override
  String? get token;

  /// Create a copy of Data
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DataImplCopyWith<_$DataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserData _$UserDataFromJson(Map<String, dynamic> json) {
  return _UserData.fromJson(json);
}

/// @nodoc
mixin _$UserData {
  @JsonKey(name: '_id')
  String? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get role => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  dynamic get dob => throw _privateConstructorUsedError;
  String? get countryCode => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get website => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  String? get socialType => throw _privateConstructorUsedError;
  String? get socialId => throw _privateConstructorUsedError;
  String? get deviceType => throw _privateConstructorUsedError;
  String? get deviceToken => throw _privateConstructorUsedError;
  String? get stripeCustomerId => throw _privateConstructorUsedError;
  String? get stripeAccountId => throw _privateConstructorUsedError;
  double? get walletBalance => throw _privateConstructorUsedError;
  List<dynamic>? get followers => throw _privateConstructorUsedError;
  List<dynamic>? get following => throw _privateConstructorUsedError;
  List<dynamic>? get blockUser => throw _privateConstructorUsedError;
  bool? get isNotification => throw _privateConstructorUsedError;
  bool? get isOnline => throw _privateConstructorUsedError;
  bool? get isActive => throw _privateConstructorUsedError;
  bool? get isBlocked => throw _privateConstructorUsedError;
  bool? get isBlockedByAdmin => throw _privateConstructorUsedError;
  String? get seeMyProfile => throw _privateConstructorUsedError;
  String? get shareMyPost => throw _privateConstructorUsedError;
  bool? get isDelete => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: '__v')
  int? get v => throw _privateConstructorUsedError;
  dynamic get image =>
      throw _privateConstructorUsedError; // Legacy fields for backwards compatibility
  bool? get isProfileComplete => throw _privateConstructorUsedError;
  String? get password => throw _privateConstructorUsedError;
  dynamic get otp => throw _privateConstructorUsedError;
  dynamic get otpExpiry => throw _privateConstructorUsedError;

  /// Serializes this UserData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserDataCopyWith<UserData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserDataCopyWith<$Res> {
  factory $UserDataCopyWith(UserData value, $Res Function(UserData) then) =
      _$UserDataCopyWithImpl<$Res, UserData>;
  @useResult
  $Res call({
    @JsonKey(name: '_id') String? id,
    String? name,
    String? username,
    String? email,
    String? role,
    String? gender,
    dynamic dob,
    String? countryCode,
    String? country,
    String? phone,
    String? website,
    String? bio,
    String? socialType,
    String? socialId,
    String? deviceType,
    String? deviceToken,
    String? stripeCustomerId,
    String? stripeAccountId,
    double? walletBalance,
    List<dynamic>? followers,
    List<dynamic>? following,
    List<dynamic>? blockUser,
    bool? isNotification,
    bool? isOnline,
    bool? isActive,
    bool? isBlocked,
    bool? isBlockedByAdmin,
    String? seeMyProfile,
    String? shareMyPost,
    bool? isDelete,
    String? createdAt,
    String? updatedAt,
    @JsonKey(name: '__v') int? v,
    dynamic image,
    bool? isProfileComplete,
    String? password,
    dynamic otp,
    dynamic otpExpiry,
  });
}

/// @nodoc
class _$UserDataCopyWithImpl<$Res, $Val extends UserData>
    implements $UserDataCopyWith<$Res> {
  _$UserDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? username = freezed,
    Object? email = freezed,
    Object? role = freezed,
    Object? gender = freezed,
    Object? dob = freezed,
    Object? countryCode = freezed,
    Object? country = freezed,
    Object? phone = freezed,
    Object? website = freezed,
    Object? bio = freezed,
    Object? socialType = freezed,
    Object? socialId = freezed,
    Object? deviceType = freezed,
    Object? deviceToken = freezed,
    Object? stripeCustomerId = freezed,
    Object? stripeAccountId = freezed,
    Object? walletBalance = freezed,
    Object? followers = freezed,
    Object? following = freezed,
    Object? blockUser = freezed,
    Object? isNotification = freezed,
    Object? isOnline = freezed,
    Object? isActive = freezed,
    Object? isBlocked = freezed,
    Object? isBlockedByAdmin = freezed,
    Object? seeMyProfile = freezed,
    Object? shareMyPost = freezed,
    Object? isDelete = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? v = freezed,
    Object? image = freezed,
    Object? isProfileComplete = freezed,
    Object? password = freezed,
    Object? otp = freezed,
    Object? otpExpiry = freezed,
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
            username: freezed == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            role: freezed == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String?,
            gender: freezed == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as String?,
            dob: freezed == dob
                ? _value.dob
                : dob // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            countryCode: freezed == countryCode
                ? _value.countryCode
                : countryCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            country: freezed == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            website: freezed == website
                ? _value.website
                : website // ignore: cast_nullable_to_non_nullable
                      as String?,
            bio: freezed == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                      as String?,
            socialType: freezed == socialType
                ? _value.socialType
                : socialType // ignore: cast_nullable_to_non_nullable
                      as String?,
            socialId: freezed == socialId
                ? _value.socialId
                : socialId // ignore: cast_nullable_to_non_nullable
                      as String?,
            deviceType: freezed == deviceType
                ? _value.deviceType
                : deviceType // ignore: cast_nullable_to_non_nullable
                      as String?,
            deviceToken: freezed == deviceToken
                ? _value.deviceToken
                : deviceToken // ignore: cast_nullable_to_non_nullable
                      as String?,
            stripeCustomerId: freezed == stripeCustomerId
                ? _value.stripeCustomerId
                : stripeCustomerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            stripeAccountId: freezed == stripeAccountId
                ? _value.stripeAccountId
                : stripeAccountId // ignore: cast_nullable_to_non_nullable
                      as String?,
            walletBalance: freezed == walletBalance
                ? _value.walletBalance
                : walletBalance // ignore: cast_nullable_to_non_nullable
                      as double?,
            followers: freezed == followers
                ? _value.followers
                : followers // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>?,
            following: freezed == following
                ? _value.following
                : following // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>?,
            blockUser: freezed == blockUser
                ? _value.blockUser
                : blockUser // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>?,
            isNotification: freezed == isNotification
                ? _value.isNotification
                : isNotification // ignore: cast_nullable_to_non_nullable
                      as bool?,
            isOnline: freezed == isOnline
                ? _value.isOnline
                : isOnline // ignore: cast_nullable_to_non_nullable
                      as bool?,
            isActive: freezed == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool?,
            isBlocked: freezed == isBlocked
                ? _value.isBlocked
                : isBlocked // ignore: cast_nullable_to_non_nullable
                      as bool?,
            isBlockedByAdmin: freezed == isBlockedByAdmin
                ? _value.isBlockedByAdmin
                : isBlockedByAdmin // ignore: cast_nullable_to_non_nullable
                      as bool?,
            seeMyProfile: freezed == seeMyProfile
                ? _value.seeMyProfile
                : seeMyProfile // ignore: cast_nullable_to_non_nullable
                      as String?,
            shareMyPost: freezed == shareMyPost
                ? _value.shareMyPost
                : shareMyPost // ignore: cast_nullable_to_non_nullable
                      as String?,
            isDelete: freezed == isDelete
                ? _value.isDelete
                : isDelete // ignore: cast_nullable_to_non_nullable
                      as bool?,
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
            image: freezed == image
                ? _value.image
                : image // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            isProfileComplete: freezed == isProfileComplete
                ? _value.isProfileComplete
                : isProfileComplete // ignore: cast_nullable_to_non_nullable
                      as bool?,
            password: freezed == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String?,
            otp: freezed == otp
                ? _value.otp
                : otp // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            otpExpiry: freezed == otpExpiry
                ? _value.otpExpiry
                : otpExpiry // ignore: cast_nullable_to_non_nullable
                      as dynamic,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserDataImplCopyWith<$Res>
    implements $UserDataCopyWith<$Res> {
  factory _$$UserDataImplCopyWith(
    _$UserDataImpl value,
    $Res Function(_$UserDataImpl) then,
  ) = __$$UserDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: '_id') String? id,
    String? name,
    String? username,
    String? email,
    String? role,
    String? gender,
    dynamic dob,
    String? countryCode,
    String? country,
    String? phone,
    String? website,
    String? bio,
    String? socialType,
    String? socialId,
    String? deviceType,
    String? deviceToken,
    String? stripeCustomerId,
    String? stripeAccountId,
    double? walletBalance,
    List<dynamic>? followers,
    List<dynamic>? following,
    List<dynamic>? blockUser,
    bool? isNotification,
    bool? isOnline,
    bool? isActive,
    bool? isBlocked,
    bool? isBlockedByAdmin,
    String? seeMyProfile,
    String? shareMyPost,
    bool? isDelete,
    String? createdAt,
    String? updatedAt,
    @JsonKey(name: '__v') int? v,
    dynamic image,
    bool? isProfileComplete,
    String? password,
    dynamic otp,
    dynamic otpExpiry,
  });
}

/// @nodoc
class __$$UserDataImplCopyWithImpl<$Res>
    extends _$UserDataCopyWithImpl<$Res, _$UserDataImpl>
    implements _$$UserDataImplCopyWith<$Res> {
  __$$UserDataImplCopyWithImpl(
    _$UserDataImpl _value,
    $Res Function(_$UserDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? username = freezed,
    Object? email = freezed,
    Object? role = freezed,
    Object? gender = freezed,
    Object? dob = freezed,
    Object? countryCode = freezed,
    Object? country = freezed,
    Object? phone = freezed,
    Object? website = freezed,
    Object? bio = freezed,
    Object? socialType = freezed,
    Object? socialId = freezed,
    Object? deviceType = freezed,
    Object? deviceToken = freezed,
    Object? stripeCustomerId = freezed,
    Object? stripeAccountId = freezed,
    Object? walletBalance = freezed,
    Object? followers = freezed,
    Object? following = freezed,
    Object? blockUser = freezed,
    Object? isNotification = freezed,
    Object? isOnline = freezed,
    Object? isActive = freezed,
    Object? isBlocked = freezed,
    Object? isBlockedByAdmin = freezed,
    Object? seeMyProfile = freezed,
    Object? shareMyPost = freezed,
    Object? isDelete = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? v = freezed,
    Object? image = freezed,
    Object? isProfileComplete = freezed,
    Object? password = freezed,
    Object? otp = freezed,
    Object? otpExpiry = freezed,
  }) {
    return _then(
      _$UserDataImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        username: freezed == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        role: freezed == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String?,
        gender: freezed == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as String?,
        dob: freezed == dob
            ? _value.dob
            : dob // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        countryCode: freezed == countryCode
            ? _value.countryCode
            : countryCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        country: freezed == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        website: freezed == website
            ? _value.website
            : website // ignore: cast_nullable_to_non_nullable
                  as String?,
        bio: freezed == bio
            ? _value.bio
            : bio // ignore: cast_nullable_to_non_nullable
                  as String?,
        socialType: freezed == socialType
            ? _value.socialType
            : socialType // ignore: cast_nullable_to_non_nullable
                  as String?,
        socialId: freezed == socialId
            ? _value.socialId
            : socialId // ignore: cast_nullable_to_non_nullable
                  as String?,
        deviceType: freezed == deviceType
            ? _value.deviceType
            : deviceType // ignore: cast_nullable_to_non_nullable
                  as String?,
        deviceToken: freezed == deviceToken
            ? _value.deviceToken
            : deviceToken // ignore: cast_nullable_to_non_nullable
                  as String?,
        stripeCustomerId: freezed == stripeCustomerId
            ? _value.stripeCustomerId
            : stripeCustomerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        stripeAccountId: freezed == stripeAccountId
            ? _value.stripeAccountId
            : stripeAccountId // ignore: cast_nullable_to_non_nullable
                  as String?,
        walletBalance: freezed == walletBalance
            ? _value.walletBalance
            : walletBalance // ignore: cast_nullable_to_non_nullable
                  as double?,
        followers: freezed == followers
            ? _value._followers
            : followers // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>?,
        following: freezed == following
            ? _value._following
            : following // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>?,
        blockUser: freezed == blockUser
            ? _value._blockUser
            : blockUser // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>?,
        isNotification: freezed == isNotification
            ? _value.isNotification
            : isNotification // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isOnline: freezed == isOnline
            ? _value.isOnline
            : isOnline // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isActive: freezed == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isBlocked: freezed == isBlocked
            ? _value.isBlocked
            : isBlocked // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isBlockedByAdmin: freezed == isBlockedByAdmin
            ? _value.isBlockedByAdmin
            : isBlockedByAdmin // ignore: cast_nullable_to_non_nullable
                  as bool?,
        seeMyProfile: freezed == seeMyProfile
            ? _value.seeMyProfile
            : seeMyProfile // ignore: cast_nullable_to_non_nullable
                  as String?,
        shareMyPost: freezed == shareMyPost
            ? _value.shareMyPost
            : shareMyPost // ignore: cast_nullable_to_non_nullable
                  as String?,
        isDelete: freezed == isDelete
            ? _value.isDelete
            : isDelete // ignore: cast_nullable_to_non_nullable
                  as bool?,
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
        image: freezed == image
            ? _value.image
            : image // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        isProfileComplete: freezed == isProfileComplete
            ? _value.isProfileComplete
            : isProfileComplete // ignore: cast_nullable_to_non_nullable
                  as bool?,
        password: freezed == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String?,
        otp: freezed == otp
            ? _value.otp
            : otp // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        otpExpiry: freezed == otpExpiry
            ? _value.otpExpiry
            : otpExpiry // ignore: cast_nullable_to_non_nullable
                  as dynamic,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserDataImpl implements _UserData {
  const _$UserDataImpl({
    @JsonKey(name: '_id') this.id,
    this.name,
    this.username,
    this.email,
    this.role,
    this.gender,
    this.dob,
    this.countryCode,
    this.country,
    this.phone,
    this.website,
    this.bio,
    this.socialType,
    this.socialId,
    this.deviceType,
    this.deviceToken,
    this.stripeCustomerId,
    this.stripeAccountId,
    this.walletBalance,
    final List<dynamic>? followers,
    final List<dynamic>? following,
    final List<dynamic>? blockUser,
    this.isNotification,
    this.isOnline,
    this.isActive,
    this.isBlocked,
    this.isBlockedByAdmin,
    this.seeMyProfile,
    this.shareMyPost,
    this.isDelete,
    this.createdAt,
    this.updatedAt,
    @JsonKey(name: '__v') this.v,
    this.image,
    this.isProfileComplete,
    this.password,
    this.otp,
    this.otpExpiry,
  }) : _followers = followers,
       _following = following,
       _blockUser = blockUser;

  factory _$UserDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserDataImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String? id;
  @override
  final String? name;
  @override
  final String? username;
  @override
  final String? email;
  @override
  final String? role;
  @override
  final String? gender;
  @override
  final dynamic dob;
  @override
  final String? countryCode;
  @override
  final String? country;
  @override
  final String? phone;
  @override
  final String? website;
  @override
  final String? bio;
  @override
  final String? socialType;
  @override
  final String? socialId;
  @override
  final String? deviceType;
  @override
  final String? deviceToken;
  @override
  final String? stripeCustomerId;
  @override
  final String? stripeAccountId;
  @override
  final double? walletBalance;
  final List<dynamic>? _followers;
  @override
  List<dynamic>? get followers {
    final value = _followers;
    if (value == null) return null;
    if (_followers is EqualUnmodifiableListView) return _followers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<dynamic>? _following;
  @override
  List<dynamic>? get following {
    final value = _following;
    if (value == null) return null;
    if (_following is EqualUnmodifiableListView) return _following;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<dynamic>? _blockUser;
  @override
  List<dynamic>? get blockUser {
    final value = _blockUser;
    if (value == null) return null;
    if (_blockUser is EqualUnmodifiableListView) return _blockUser;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final bool? isNotification;
  @override
  final bool? isOnline;
  @override
  final bool? isActive;
  @override
  final bool? isBlocked;
  @override
  final bool? isBlockedByAdmin;
  @override
  final String? seeMyProfile;
  @override
  final String? shareMyPost;
  @override
  final bool? isDelete;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;
  @override
  @JsonKey(name: '__v')
  final int? v;
  @override
  final dynamic image;
  // Legacy fields for backwards compatibility
  @override
  final bool? isProfileComplete;
  @override
  final String? password;
  @override
  final dynamic otp;
  @override
  final dynamic otpExpiry;

  @override
  String toString() {
    return 'UserData(id: $id, name: $name, username: $username, email: $email, role: $role, gender: $gender, dob: $dob, countryCode: $countryCode, country: $country, phone: $phone, website: $website, bio: $bio, socialType: $socialType, socialId: $socialId, deviceType: $deviceType, deviceToken: $deviceToken, stripeCustomerId: $stripeCustomerId, stripeAccountId: $stripeAccountId, walletBalance: $walletBalance, followers: $followers, following: $following, blockUser: $blockUser, isNotification: $isNotification, isOnline: $isOnline, isActive: $isActive, isBlocked: $isBlocked, isBlockedByAdmin: $isBlockedByAdmin, seeMyProfile: $seeMyProfile, shareMyPost: $shareMyPost, isDelete: $isDelete, createdAt: $createdAt, updatedAt: $updatedAt, v: $v, image: $image, isProfileComplete: $isProfileComplete, password: $password, otp: $otp, otpExpiry: $otpExpiry)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            const DeepCollectionEquality().equals(other.dob, dob) &&
            (identical(other.countryCode, countryCode) ||
                other.countryCode == countryCode) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.website, website) || other.website == website) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.socialType, socialType) ||
                other.socialType == socialType) &&
            (identical(other.socialId, socialId) ||
                other.socialId == socialId) &&
            (identical(other.deviceType, deviceType) ||
                other.deviceType == deviceType) &&
            (identical(other.deviceToken, deviceToken) ||
                other.deviceToken == deviceToken) &&
            (identical(other.stripeCustomerId, stripeCustomerId) ||
                other.stripeCustomerId == stripeCustomerId) &&
            (identical(other.stripeAccountId, stripeAccountId) ||
                other.stripeAccountId == stripeAccountId) &&
            (identical(other.walletBalance, walletBalance) ||
                other.walletBalance == walletBalance) &&
            const DeepCollectionEquality().equals(
              other._followers,
              _followers,
            ) &&
            const DeepCollectionEquality().equals(
              other._following,
              _following,
            ) &&
            const DeepCollectionEquality().equals(
              other._blockUser,
              _blockUser,
            ) &&
            (identical(other.isNotification, isNotification) ||
                other.isNotification == isNotification) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isBlocked, isBlocked) ||
                other.isBlocked == isBlocked) &&
            (identical(other.isBlockedByAdmin, isBlockedByAdmin) ||
                other.isBlockedByAdmin == isBlockedByAdmin) &&
            (identical(other.seeMyProfile, seeMyProfile) ||
                other.seeMyProfile == seeMyProfile) &&
            (identical(other.shareMyPost, shareMyPost) ||
                other.shareMyPost == shareMyPost) &&
            (identical(other.isDelete, isDelete) ||
                other.isDelete == isDelete) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.v, v) || other.v == v) &&
            const DeepCollectionEquality().equals(other.image, image) &&
            (identical(other.isProfileComplete, isProfileComplete) ||
                other.isProfileComplete == isProfileComplete) &&
            (identical(other.password, password) ||
                other.password == password) &&
            const DeepCollectionEquality().equals(other.otp, otp) &&
            const DeepCollectionEquality().equals(other.otpExpiry, otpExpiry));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    name,
    username,
    email,
    role,
    gender,
    const DeepCollectionEquality().hash(dob),
    countryCode,
    country,
    phone,
    website,
    bio,
    socialType,
    socialId,
    deviceType,
    deviceToken,
    stripeCustomerId,
    stripeAccountId,
    walletBalance,
    const DeepCollectionEquality().hash(_followers),
    const DeepCollectionEquality().hash(_following),
    const DeepCollectionEquality().hash(_blockUser),
    isNotification,
    isOnline,
    isActive,
    isBlocked,
    isBlockedByAdmin,
    seeMyProfile,
    shareMyPost,
    isDelete,
    createdAt,
    updatedAt,
    v,
    const DeepCollectionEquality().hash(image),
    isProfileComplete,
    password,
    const DeepCollectionEquality().hash(otp),
    const DeepCollectionEquality().hash(otpExpiry),
  ]);

  /// Create a copy of UserData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserDataImplCopyWith<_$UserDataImpl> get copyWith =>
      __$$UserDataImplCopyWithImpl<_$UserDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserDataImplToJson(this);
  }
}

abstract class _UserData implements UserData {
  const factory _UserData({
    @JsonKey(name: '_id') final String? id,
    final String? name,
    final String? username,
    final String? email,
    final String? role,
    final String? gender,
    final dynamic dob,
    final String? countryCode,
    final String? country,
    final String? phone,
    final String? website,
    final String? bio,
    final String? socialType,
    final String? socialId,
    final String? deviceType,
    final String? deviceToken,
    final String? stripeCustomerId,
    final String? stripeAccountId,
    final double? walletBalance,
    final List<dynamic>? followers,
    final List<dynamic>? following,
    final List<dynamic>? blockUser,
    final bool? isNotification,
    final bool? isOnline,
    final bool? isActive,
    final bool? isBlocked,
    final bool? isBlockedByAdmin,
    final String? seeMyProfile,
    final String? shareMyPost,
    final bool? isDelete,
    final String? createdAt,
    final String? updatedAt,
    @JsonKey(name: '__v') final int? v,
    final dynamic image,
    final bool? isProfileComplete,
    final String? password,
    final dynamic otp,
    final dynamic otpExpiry,
  }) = _$UserDataImpl;

  factory _UserData.fromJson(Map<String, dynamic> json) =
      _$UserDataImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String? get id;
  @override
  String? get name;
  @override
  String? get username;
  @override
  String? get email;
  @override
  String? get role;
  @override
  String? get gender;
  @override
  dynamic get dob;
  @override
  String? get countryCode;
  @override
  String? get country;
  @override
  String? get phone;
  @override
  String? get website;
  @override
  String? get bio;
  @override
  String? get socialType;
  @override
  String? get socialId;
  @override
  String? get deviceType;
  @override
  String? get deviceToken;
  @override
  String? get stripeCustomerId;
  @override
  String? get stripeAccountId;
  @override
  double? get walletBalance;
  @override
  List<dynamic>? get followers;
  @override
  List<dynamic>? get following;
  @override
  List<dynamic>? get blockUser;
  @override
  bool? get isNotification;
  @override
  bool? get isOnline;
  @override
  bool? get isActive;
  @override
  bool? get isBlocked;
  @override
  bool? get isBlockedByAdmin;
  @override
  String? get seeMyProfile;
  @override
  String? get shareMyPost;
  @override
  bool? get isDelete;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;
  @override
  @JsonKey(name: '__v')
  int? get v;
  @override
  dynamic get image; // Legacy fields for backwards compatibility
  @override
  bool? get isProfileComplete;
  @override
  String? get password;
  @override
  dynamic get otp;
  @override
  dynamic get otpExpiry;

  /// Create a copy of UserData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserDataImplCopyWith<_$UserDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
