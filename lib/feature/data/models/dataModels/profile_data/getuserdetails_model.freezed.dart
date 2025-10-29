// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'getuserdetails_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GetuserdetailsModel _$GetuserdetailsModelFromJson(Map<String, dynamic> json) {
  return _GetuserdetailsModel.fromJson(json);
}

/// @nodoc
mixin _$GetuserdetailsModel {
  @JsonKey(name: "_id")
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: "name")
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: "email")
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: "role")
  String? get role => throw _privateConstructorUsedError;
  @JsonKey(name: "phone")
  String? get phone => throw _privateConstructorUsedError;
  @JsonKey(name: "dob")
  String? get dob => throw _privateConstructorUsedError;
  @JsonKey(name: "gender")
  String? get gender => throw _privateConstructorUsedError;
  @JsonKey(name: "createdAt")
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: "updatedAt")
  String? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: "__v")
  int? get v => throw _privateConstructorUsedError;
  @JsonKey(name: "otp")
  dynamic get otp => throw _privateConstructorUsedError;

  /// Serializes this GetuserdetailsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GetuserdetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GetuserdetailsModelCopyWith<GetuserdetailsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetuserdetailsModelCopyWith<$Res> {
  factory $GetuserdetailsModelCopyWith(
    GetuserdetailsModel value,
    $Res Function(GetuserdetailsModel) then,
  ) = _$GetuserdetailsModelCopyWithImpl<$Res, GetuserdetailsModel>;
  @useResult
  $Res call({
    @JsonKey(name: "_id") String? id,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "email") String? email,
    @JsonKey(name: "role") String? role,
    @JsonKey(name: "phone") String? phone,
    @JsonKey(name: "dob") String? dob,
    @JsonKey(name: "gender") String? gender,
    @JsonKey(name: "createdAt") String? createdAt,
    @JsonKey(name: "updatedAt") String? updatedAt,
    @JsonKey(name: "__v") int? v,
    @JsonKey(name: "otp") dynamic otp,
  });
}

/// @nodoc
class _$GetuserdetailsModelCopyWithImpl<$Res, $Val extends GetuserdetailsModel>
    implements $GetuserdetailsModelCopyWith<$Res> {
  _$GetuserdetailsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GetuserdetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? email = freezed,
    Object? role = freezed,
    Object? phone = freezed,
    Object? dob = freezed,
    Object? gender = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? v = freezed,
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
abstract class _$$GetuserdetailsModelImplCopyWith<$Res>
    implements $GetuserdetailsModelCopyWith<$Res> {
  factory _$$GetuserdetailsModelImplCopyWith(
    _$GetuserdetailsModelImpl value,
    $Res Function(_$GetuserdetailsModelImpl) then,
  ) = __$$GetuserdetailsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: "_id") String? id,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "email") String? email,
    @JsonKey(name: "role") String? role,
    @JsonKey(name: "phone") String? phone,
    @JsonKey(name: "dob") String? dob,
    @JsonKey(name: "gender") String? gender,
    @JsonKey(name: "createdAt") String? createdAt,
    @JsonKey(name: "updatedAt") String? updatedAt,
    @JsonKey(name: "__v") int? v,
    @JsonKey(name: "otp") dynamic otp,
  });
}

/// @nodoc
class __$$GetuserdetailsModelImplCopyWithImpl<$Res>
    extends _$GetuserdetailsModelCopyWithImpl<$Res, _$GetuserdetailsModelImpl>
    implements _$$GetuserdetailsModelImplCopyWith<$Res> {
  __$$GetuserdetailsModelImplCopyWithImpl(
    _$GetuserdetailsModelImpl _value,
    $Res Function(_$GetuserdetailsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GetuserdetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? email = freezed,
    Object? role = freezed,
    Object? phone = freezed,
    Object? dob = freezed,
    Object? gender = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? v = freezed,
    Object? otp = freezed,
  }) {
    return _then(
      _$GetuserdetailsModelImpl(
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
class _$GetuserdetailsModelImpl implements _GetuserdetailsModel {
  const _$GetuserdetailsModelImpl({
    @JsonKey(name: "_id") this.id,
    @JsonKey(name: "name") this.name,
    @JsonKey(name: "email") this.email,
    @JsonKey(name: "role") this.role,
    @JsonKey(name: "phone") this.phone,
    @JsonKey(name: "dob") this.dob,
    @JsonKey(name: "gender") this.gender,
    @JsonKey(name: "createdAt") this.createdAt,
    @JsonKey(name: "updatedAt") this.updatedAt,
    @JsonKey(name: "__v") this.v,
    @JsonKey(name: "otp") this.otp,
  });

  factory _$GetuserdetailsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetuserdetailsModelImplFromJson(json);

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
  @JsonKey(name: "createdAt")
  final String? createdAt;
  @override
  @JsonKey(name: "updatedAt")
  final String? updatedAt;
  @override
  @JsonKey(name: "__v")
  final int? v;
  @override
  @JsonKey(name: "otp")
  final dynamic otp;

  @override
  String toString() {
    return 'GetuserdetailsModel(id: $id, name: $name, email: $email, role: $role, phone: $phone, dob: $dob, gender: $gender, createdAt: $createdAt, updatedAt: $updatedAt, v: $v, otp: $otp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetuserdetailsModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.dob, dob) || other.dob == dob) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.v, v) || other.v == v) &&
            const DeepCollectionEquality().equals(other.otp, otp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    email,
    role,
    phone,
    dob,
    gender,
    createdAt,
    updatedAt,
    v,
    const DeepCollectionEquality().hash(otp),
  );

  /// Create a copy of GetuserdetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GetuserdetailsModelImplCopyWith<_$GetuserdetailsModelImpl> get copyWith =>
      __$$GetuserdetailsModelImplCopyWithImpl<_$GetuserdetailsModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GetuserdetailsModelImplToJson(this);
  }
}

abstract class _GetuserdetailsModel implements GetuserdetailsModel {
  const factory _GetuserdetailsModel({
    @JsonKey(name: "_id") final String? id,
    @JsonKey(name: "name") final String? name,
    @JsonKey(name: "email") final String? email,
    @JsonKey(name: "role") final String? role,
    @JsonKey(name: "phone") final String? phone,
    @JsonKey(name: "dob") final String? dob,
    @JsonKey(name: "gender") final String? gender,
    @JsonKey(name: "createdAt") final String? createdAt,
    @JsonKey(name: "updatedAt") final String? updatedAt,
    @JsonKey(name: "__v") final int? v,
    @JsonKey(name: "otp") final dynamic otp,
  }) = _$GetuserdetailsModelImpl;

  factory _GetuserdetailsModel.fromJson(Map<String, dynamic> json) =
      _$GetuserdetailsModelImpl.fromJson;

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
  @JsonKey(name: "createdAt")
  String? get createdAt;
  @override
  @JsonKey(name: "updatedAt")
  String? get updatedAt;
  @override
  @JsonKey(name: "__v")
  int? get v;
  @override
  @JsonKey(name: "otp")
  dynamic get otp;

  /// Create a copy of GetuserdetailsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GetuserdetailsModelImplCopyWith<_$GetuserdetailsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
