// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'emailvalid_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

EmailvalidModel _$EmailvalidModelFromJson(Map<String, dynamic> json) {
  return _EmailvalidModel.fromJson(json);
}

/// @nodoc
mixin _$EmailvalidModel {
  bool? get status => throw _privateConstructorUsedError;
  int? get code => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  Data get data => throw _privateConstructorUsedError;

  /// Serializes this EmailvalidModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EmailvalidModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EmailvalidModelCopyWith<EmailvalidModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmailvalidModelCopyWith<$Res> {
  factory $EmailvalidModelCopyWith(
    EmailvalidModel value,
    $Res Function(EmailvalidModel) then,
  ) = _$EmailvalidModelCopyWithImpl<$Res, EmailvalidModel>;
  @useResult
  $Res call({bool? status, int? code, String? message, Data data});

  $DataCopyWith<$Res> get data;
}

/// @nodoc
class _$EmailvalidModelCopyWithImpl<$Res, $Val extends EmailvalidModel>
    implements $EmailvalidModelCopyWith<$Res> {
  _$EmailvalidModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EmailvalidModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = freezed,
    Object? code = freezed,
    Object? message = freezed,
    Object? data = null,
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
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as Data,
          )
          as $Val,
    );
  }

  /// Create a copy of EmailvalidModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DataCopyWith<$Res> get data {
    return $DataCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$EmailvalidModelImplCopyWith<$Res>
    implements $EmailvalidModelCopyWith<$Res> {
  factory _$$EmailvalidModelImplCopyWith(
    _$EmailvalidModelImpl value,
    $Res Function(_$EmailvalidModelImpl) then,
  ) = __$$EmailvalidModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool? status, int? code, String? message, Data data});

  @override
  $DataCopyWith<$Res> get data;
}

/// @nodoc
class __$$EmailvalidModelImplCopyWithImpl<$Res>
    extends _$EmailvalidModelCopyWithImpl<$Res, _$EmailvalidModelImpl>
    implements _$$EmailvalidModelImplCopyWith<$Res> {
  __$$EmailvalidModelImplCopyWithImpl(
    _$EmailvalidModelImpl _value,
    $Res Function(_$EmailvalidModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EmailvalidModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = freezed,
    Object? code = freezed,
    Object? message = freezed,
    Object? data = null,
  }) {
    return _then(
      _$EmailvalidModelImpl(
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
        data: null == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as Data,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EmailvalidModelImpl implements _EmailvalidModel {
  const _$EmailvalidModelImpl({
    this.status,
    this.code,
    this.message,
    required this.data,
  });

  factory _$EmailvalidModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmailvalidModelImplFromJson(json);

  @override
  final bool? status;
  @override
  final int? code;
  @override
  final String? message;
  @override
  final Data data;

  @override
  String toString() {
    return 'EmailvalidModel(status: $status, code: $code, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmailvalidModelImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status, code, message, data);

  /// Create a copy of EmailvalidModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmailvalidModelImplCopyWith<_$EmailvalidModelImpl> get copyWith =>
      __$$EmailvalidModelImplCopyWithImpl<_$EmailvalidModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EmailvalidModelImplToJson(this);
  }
}

abstract class _EmailvalidModel implements EmailvalidModel {
  const factory _EmailvalidModel({
    final bool? status,
    final int? code,
    final String? message,
    required final Data data,
  }) = _$EmailvalidModelImpl;

  factory _EmailvalidModel.fromJson(Map<String, dynamic> json) =
      _$EmailvalidModelImpl.fromJson;

  @override
  bool? get status;
  @override
  int? get code;
  @override
  String? get message;
  @override
  Data get data;

  /// Create a copy of EmailvalidModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmailvalidModelImplCopyWith<_$EmailvalidModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Data _$DataFromJson(Map<String, dynamic> json) {
  return _Data.fromJson(json);
}

/// @nodoc
mixin _$Data {
  /// Serializes this Data to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DataCopyWith<$Res> {
  factory $DataCopyWith(Data value, $Res Function(Data) then) =
      _$DataCopyWithImpl<$Res, Data>;
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
}

/// @nodoc
abstract class _$$DataImplCopyWith<$Res> {
  factory _$$DataImplCopyWith(
    _$DataImpl value,
    $Res Function(_$DataImpl) then,
  ) = __$$DataImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$DataImplCopyWithImpl<$Res>
    extends _$DataCopyWithImpl<$Res, _$DataImpl>
    implements _$$DataImplCopyWith<$Res> {
  __$$DataImplCopyWithImpl(_$DataImpl _value, $Res Function(_$DataImpl) _then)
    : super(_value, _then);

  /// Create a copy of Data
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
@JsonSerializable()
class _$DataImpl implements _Data {
  const _$DataImpl();

  factory _$DataImpl.fromJson(Map<String, dynamic> json) =>
      _$$DataImplFromJson(json);

  @override
  String toString() {
    return 'Data()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$DataImpl);
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => runtimeType.hashCode;

  @override
  Map<String, dynamic> toJson() {
    return _$$DataImplToJson(this);
  }
}

abstract class _Data implements Data {
  const factory _Data() = _$DataImpl;

  factory _Data.fromJson(Map<String, dynamic> json) = _$DataImpl.fromJson;
}
