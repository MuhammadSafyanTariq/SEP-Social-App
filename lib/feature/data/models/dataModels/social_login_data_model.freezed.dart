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
  bool? get isProfileComplete => throw _privateConstructorUsedError;
  int? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  dynamic get phone => throw _privateConstructorUsedError;
  String? get password => throw _privateConstructorUsedError;
  dynamic get otp => throw _privateConstructorUsedError;
  dynamic get otpExpiry => throw _privateConstructorUsedError;
  dynamic get deviceToken => throw _privateConstructorUsedError;
  String? get socialId => throw _privateConstructorUsedError;
  String? get socialType => throw _privateConstructorUsedError;
  dynamic get deviceType => throw _privateConstructorUsedError;
  dynamic get image => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;

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
    bool? isProfileComplete,
    int? id,
    String? name,
    String? email,
    dynamic phone,
    String? password,
    dynamic otp,
    dynamic otpExpiry,
    dynamic deviceToken,
    String? socialId,
    String? socialType,
    dynamic deviceType,
    dynamic image,
    String? createdAt,
    String? updatedAt,
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
    Object? isProfileComplete = freezed,
    Object? id = freezed,
    Object? name = freezed,
    Object? email = freezed,
    Object? phone = freezed,
    Object? password = freezed,
    Object? otp = freezed,
    Object? otpExpiry = freezed,
    Object? deviceToken = freezed,
    Object? socialId = freezed,
    Object? socialType = freezed,
    Object? deviceType = freezed,
    Object? image = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            isProfileComplete: freezed == isProfileComplete
                ? _value.isProfileComplete
                : isProfileComplete // ignore: cast_nullable_to_non_nullable
                      as bool?,
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as dynamic,
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
            deviceToken: freezed == deviceToken
                ? _value.deviceToken
                : deviceToken // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            socialId: freezed == socialId
                ? _value.socialId
                : socialId // ignore: cast_nullable_to_non_nullable
                      as String?,
            socialType: freezed == socialType
                ? _value.socialType
                : socialType // ignore: cast_nullable_to_non_nullable
                      as String?,
            deviceType: freezed == deviceType
                ? _value.deviceType
                : deviceType // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            image: freezed == image
                ? _value.image
                : image // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
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
    bool? isProfileComplete,
    int? id,
    String? name,
    String? email,
    dynamic phone,
    String? password,
    dynamic otp,
    dynamic otpExpiry,
    dynamic deviceToken,
    String? socialId,
    String? socialType,
    dynamic deviceType,
    dynamic image,
    String? createdAt,
    String? updatedAt,
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
    Object? isProfileComplete = freezed,
    Object? id = freezed,
    Object? name = freezed,
    Object? email = freezed,
    Object? phone = freezed,
    Object? password = freezed,
    Object? otp = freezed,
    Object? otpExpiry = freezed,
    Object? deviceToken = freezed,
    Object? socialId = freezed,
    Object? socialType = freezed,
    Object? deviceType = freezed,
    Object? image = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$UserDataImpl(
        isProfileComplete: freezed == isProfileComplete
            ? _value.isProfileComplete
            : isProfileComplete // ignore: cast_nullable_to_non_nullable
                  as bool?,
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as dynamic,
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
        deviceToken: freezed == deviceToken
            ? _value.deviceToken
            : deviceToken // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        socialId: freezed == socialId
            ? _value.socialId
            : socialId // ignore: cast_nullable_to_non_nullable
                  as String?,
        socialType: freezed == socialType
            ? _value.socialType
            : socialType // ignore: cast_nullable_to_non_nullable
                  as String?,
        deviceType: freezed == deviceType
            ? _value.deviceType
            : deviceType // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        image: freezed == image
            ? _value.image
            : image // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserDataImpl implements _UserData {
  const _$UserDataImpl({
    this.isProfileComplete,
    this.id,
    this.name,
    this.email,
    this.phone,
    this.password,
    this.otp,
    this.otpExpiry,
    this.deviceToken,
    this.socialId,
    this.socialType,
    this.deviceType,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory _$UserDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserDataImplFromJson(json);

  @override
  final bool? isProfileComplete;
  @override
  final int? id;
  @override
  final String? name;
  @override
  final String? email;
  @override
  final dynamic phone;
  @override
  final String? password;
  @override
  final dynamic otp;
  @override
  final dynamic otpExpiry;
  @override
  final dynamic deviceToken;
  @override
  final String? socialId;
  @override
  final String? socialType;
  @override
  final dynamic deviceType;
  @override
  final dynamic image;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;

  @override
  String toString() {
    return 'UserData(isProfileComplete: $isProfileComplete, id: $id, name: $name, email: $email, phone: $phone, password: $password, otp: $otp, otpExpiry: $otpExpiry, deviceToken: $deviceToken, socialId: $socialId, socialType: $socialType, deviceType: $deviceType, image: $image, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserDataImpl &&
            (identical(other.isProfileComplete, isProfileComplete) ||
                other.isProfileComplete == isProfileComplete) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            const DeepCollectionEquality().equals(other.phone, phone) &&
            (identical(other.password, password) ||
                other.password == password) &&
            const DeepCollectionEquality().equals(other.otp, otp) &&
            const DeepCollectionEquality().equals(other.otpExpiry, otpExpiry) &&
            const DeepCollectionEquality().equals(
              other.deviceToken,
              deviceToken,
            ) &&
            (identical(other.socialId, socialId) ||
                other.socialId == socialId) &&
            (identical(other.socialType, socialType) ||
                other.socialType == socialType) &&
            const DeepCollectionEquality().equals(
              other.deviceType,
              deviceType,
            ) &&
            const DeepCollectionEquality().equals(other.image, image) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    isProfileComplete,
    id,
    name,
    email,
    const DeepCollectionEquality().hash(phone),
    password,
    const DeepCollectionEquality().hash(otp),
    const DeepCollectionEquality().hash(otpExpiry),
    const DeepCollectionEquality().hash(deviceToken),
    socialId,
    socialType,
    const DeepCollectionEquality().hash(deviceType),
    const DeepCollectionEquality().hash(image),
    createdAt,
    updatedAt,
  );

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
    final bool? isProfileComplete,
    final int? id,
    final String? name,
    final String? email,
    final dynamic phone,
    final String? password,
    final dynamic otp,
    final dynamic otpExpiry,
    final dynamic deviceToken,
    final String? socialId,
    final String? socialType,
    final dynamic deviceType,
    final dynamic image,
    final String? createdAt,
    final String? updatedAt,
  }) = _$UserDataImpl;

  factory _UserData.fromJson(Map<String, dynamic> json) =
      _$UserDataImpl.fromJson;

  @override
  bool? get isProfileComplete;
  @override
  int? get id;
  @override
  String? get name;
  @override
  String? get email;
  @override
  dynamic get phone;
  @override
  String? get password;
  @override
  dynamic get otp;
  @override
  dynamic get otpExpiry;
  @override
  dynamic get deviceToken;
  @override
  String? get socialId;
  @override
  String? get socialType;
  @override
  dynamic get deviceType;
  @override
  dynamic get image;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;

  /// Create a copy of UserData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserDataImplCopyWith<_$UserDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
