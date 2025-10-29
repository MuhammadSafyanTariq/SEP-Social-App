// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'poll_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PollItemModel _$PollItemModelFromJson(Map<String, dynamic> json) {
  return _PollItemModel.fromJson(json);
}

/// @nodoc
mixin _$PollItemModel {
  String? get name => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;
  String? get file => throw _privateConstructorUsedError;
  bool? get isValid => throw _privateConstructorUsedError;

  /// Serializes this PollItemModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PollItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PollItemModelCopyWith<PollItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PollItemModelCopyWith<$Res> {
  factory $PollItemModelCopyWith(
    PollItemModel value,
    $Res Function(PollItemModel) then,
  ) = _$PollItemModelCopyWithImpl<$Res, PollItemModel>;
  @useResult
  $Res call({String? name, String? image, String? file, bool? isValid});
}

/// @nodoc
class _$PollItemModelCopyWithImpl<$Res, $Val extends PollItemModel>
    implements $PollItemModelCopyWith<$Res> {
  _$PollItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PollItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? image = freezed,
    Object? file = freezed,
    Object? isValid = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            image: freezed == image
                ? _value.image
                : image // ignore: cast_nullable_to_non_nullable
                      as String?,
            file: freezed == file
                ? _value.file
                : file // ignore: cast_nullable_to_non_nullable
                      as String?,
            isValid: freezed == isValid
                ? _value.isValid
                : isValid // ignore: cast_nullable_to_non_nullable
                      as bool?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PollItemModelImplCopyWith<$Res>
    implements $PollItemModelCopyWith<$Res> {
  factory _$$PollItemModelImplCopyWith(
    _$PollItemModelImpl value,
    $Res Function(_$PollItemModelImpl) then,
  ) = __$$PollItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? name, String? image, String? file, bool? isValid});
}

/// @nodoc
class __$$PollItemModelImplCopyWithImpl<$Res>
    extends _$PollItemModelCopyWithImpl<$Res, _$PollItemModelImpl>
    implements _$$PollItemModelImplCopyWith<$Res> {
  __$$PollItemModelImplCopyWithImpl(
    _$PollItemModelImpl _value,
    $Res Function(_$PollItemModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PollItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? image = freezed,
    Object? file = freezed,
    Object? isValid = freezed,
  }) {
    return _then(
      _$PollItemModelImpl(
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        image: freezed == image
            ? _value.image
            : image // ignore: cast_nullable_to_non_nullable
                  as String?,
        file: freezed == file
            ? _value.file
            : file // ignore: cast_nullable_to_non_nullable
                  as String?,
        isValid: freezed == isValid
            ? _value.isValid
            : isValid // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PollItemModelImpl implements _PollItemModel {
  const _$PollItemModelImpl({this.name, this.image, this.file, this.isValid});

  factory _$PollItemModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PollItemModelImplFromJson(json);

  @override
  final String? name;
  @override
  final String? image;
  @override
  final String? file;
  @override
  final bool? isValid;

  @override
  String toString() {
    return 'PollItemModel(name: $name, image: $image, file: $file, isValid: $isValid)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PollItemModelImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.file, file) || other.file == file) &&
            (identical(other.isValid, isValid) || other.isValid == isValid));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, image, file, isValid);

  /// Create a copy of PollItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PollItemModelImplCopyWith<_$PollItemModelImpl> get copyWith =>
      __$$PollItemModelImplCopyWithImpl<_$PollItemModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PollItemModelImplToJson(this);
  }
}

abstract class _PollItemModel implements PollItemModel {
  const factory _PollItemModel({
    final String? name,
    final String? image,
    final String? file,
    final bool? isValid,
  }) = _$PollItemModelImpl;

  factory _PollItemModel.fromJson(Map<String, dynamic> json) =
      _$PollItemModelImpl.fromJson;

  @override
  String? get name;
  @override
  String? get image;
  @override
  String? get file;
  @override
  bool? get isValid;

  /// Create a copy of PollItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PollItemModelImplCopyWith<_$PollItemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
