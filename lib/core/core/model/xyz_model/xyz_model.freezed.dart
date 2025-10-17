// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'xyz_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

XyzModel _$XyzModelFromJson(Map<String, dynamic> json) {
  return _XyzModel.fromJson(json);
}

/// @nodoc
mixin _$XyzModel {
  String? get greeting => throw _privateConstructorUsedError;
  List<String>? get instructions => throw _privateConstructorUsedError;
  int? get newId => throw _privateConstructorUsedError;

  /// Serializes this XyzModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of XyzModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $XyzModelCopyWith<XyzModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $XyzModelCopyWith<$Res> {
  factory $XyzModelCopyWith(XyzModel value, $Res Function(XyzModel) then) =
      _$XyzModelCopyWithImpl<$Res, XyzModel>;
  @useResult
  $Res call({String? greeting, List<String>? instructions, int? newId});
}

/// @nodoc
class _$XyzModelCopyWithImpl<$Res, $Val extends XyzModel>
    implements $XyzModelCopyWith<$Res> {
  _$XyzModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of XyzModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? greeting = freezed,
    Object? instructions = freezed,
    Object? newId = freezed,
  }) {
    return _then(
      _value.copyWith(
            greeting: freezed == greeting
                ? _value.greeting
                : greeting // ignore: cast_nullable_to_non_nullable
                      as String?,
            instructions: freezed == instructions
                ? _value.instructions
                : instructions // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            newId: freezed == newId
                ? _value.newId
                : newId // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$XyzModelImplCopyWith<$Res>
    implements $XyzModelCopyWith<$Res> {
  factory _$$XyzModelImplCopyWith(
    _$XyzModelImpl value,
    $Res Function(_$XyzModelImpl) then,
  ) = __$$XyzModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? greeting, List<String>? instructions, int? newId});
}

/// @nodoc
class __$$XyzModelImplCopyWithImpl<$Res>
    extends _$XyzModelCopyWithImpl<$Res, _$XyzModelImpl>
    implements _$$XyzModelImplCopyWith<$Res> {
  __$$XyzModelImplCopyWithImpl(
    _$XyzModelImpl _value,
    $Res Function(_$XyzModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of XyzModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? greeting = freezed,
    Object? instructions = freezed,
    Object? newId = freezed,
  }) {
    return _then(
      _$XyzModelImpl(
        greeting: freezed == greeting
            ? _value.greeting
            : greeting // ignore: cast_nullable_to_non_nullable
                  as String?,
        instructions: freezed == instructions
            ? _value._instructions
            : instructions // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        newId: freezed == newId
            ? _value.newId
            : newId // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$XyzModelImpl implements _XyzModel {
  const _$XyzModelImpl({
    this.greeting,
    final List<String>? instructions,
    this.newId,
  }) : _instructions = instructions;

  factory _$XyzModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$XyzModelImplFromJson(json);

  @override
  final String? greeting;
  final List<String>? _instructions;
  @override
  List<String>? get instructions {
    final value = _instructions;
    if (value == null) return null;
    if (_instructions is EqualUnmodifiableListView) return _instructions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? newId;

  @override
  String toString() {
    return 'XyzModel(greeting: $greeting, instructions: $instructions, newId: $newId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$XyzModelImpl &&
            (identical(other.greeting, greeting) ||
                other.greeting == greeting) &&
            const DeepCollectionEquality().equals(
              other._instructions,
              _instructions,
            ) &&
            (identical(other.newId, newId) || other.newId == newId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    greeting,
    const DeepCollectionEquality().hash(_instructions),
    newId,
  );

  /// Create a copy of XyzModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$XyzModelImplCopyWith<_$XyzModelImpl> get copyWith =>
      __$$XyzModelImplCopyWithImpl<_$XyzModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$XyzModelImplToJson(this);
  }
}

abstract class _XyzModel implements XyzModel {
  const factory _XyzModel({
    final String? greeting,
    final List<String>? instructions,
    final int? newId,
  }) = _$XyzModelImpl;

  factory _XyzModel.fromJson(Map<String, dynamic> json) =
      _$XyzModelImpl.fromJson;

  @override
  String? get greeting;
  @override
  List<String>? get instructions;
  @override
  int? get newId;

  /// Create a copy of XyzModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$XyzModelImplCopyWith<_$XyzModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
