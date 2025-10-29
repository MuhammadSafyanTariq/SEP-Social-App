// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bank_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BankDetail _$BankDetailFromJson(Map<String, dynamic> json) {
  return _BankDetail.fromJson(json);
}

/// @nodoc
mixin _$BankDetail {
  String? get country => throw _privateConstructorUsedError;
  String? get currency => throw _privateConstructorUsedError;
  String? get routingNumber => throw _privateConstructorUsedError;
  String? get accountNumber => throw _privateConstructorUsedError;
  String? get accountHolderName => throw _privateConstructorUsedError;
  String? get accountHolderType => throw _privateConstructorUsedError;

  /// Serializes this BankDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BankDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BankDetailCopyWith<BankDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BankDetailCopyWith<$Res> {
  factory $BankDetailCopyWith(
    BankDetail value,
    $Res Function(BankDetail) then,
  ) = _$BankDetailCopyWithImpl<$Res, BankDetail>;
  @useResult
  $Res call({
    String? country,
    String? currency,
    String? routingNumber,
    String? accountNumber,
    String? accountHolderName,
    String? accountHolderType,
  });
}

/// @nodoc
class _$BankDetailCopyWithImpl<$Res, $Val extends BankDetail>
    implements $BankDetailCopyWith<$Res> {
  _$BankDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BankDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? country = freezed,
    Object? currency = freezed,
    Object? routingNumber = freezed,
    Object? accountNumber = freezed,
    Object? accountHolderName = freezed,
    Object? accountHolderType = freezed,
  }) {
    return _then(
      _value.copyWith(
            country: freezed == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                      as String?,
            currency: freezed == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String?,
            routingNumber: freezed == routingNumber
                ? _value.routingNumber
                : routingNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            accountNumber: freezed == accountNumber
                ? _value.accountNumber
                : accountNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            accountHolderName: freezed == accountHolderName
                ? _value.accountHolderName
                : accountHolderName // ignore: cast_nullable_to_non_nullable
                      as String?,
            accountHolderType: freezed == accountHolderType
                ? _value.accountHolderType
                : accountHolderType // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BankDetailImplCopyWith<$Res>
    implements $BankDetailCopyWith<$Res> {
  factory _$$BankDetailImplCopyWith(
    _$BankDetailImpl value,
    $Res Function(_$BankDetailImpl) then,
  ) = __$$BankDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? country,
    String? currency,
    String? routingNumber,
    String? accountNumber,
    String? accountHolderName,
    String? accountHolderType,
  });
}

/// @nodoc
class __$$BankDetailImplCopyWithImpl<$Res>
    extends _$BankDetailCopyWithImpl<$Res, _$BankDetailImpl>
    implements _$$BankDetailImplCopyWith<$Res> {
  __$$BankDetailImplCopyWithImpl(
    _$BankDetailImpl _value,
    $Res Function(_$BankDetailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BankDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? country = freezed,
    Object? currency = freezed,
    Object? routingNumber = freezed,
    Object? accountNumber = freezed,
    Object? accountHolderName = freezed,
    Object? accountHolderType = freezed,
  }) {
    return _then(
      _$BankDetailImpl(
        country: freezed == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as String?,
        currency: freezed == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String?,
        routingNumber: freezed == routingNumber
            ? _value.routingNumber
            : routingNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        accountNumber: freezed == accountNumber
            ? _value.accountNumber
            : accountNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        accountHolderName: freezed == accountHolderName
            ? _value.accountHolderName
            : accountHolderName // ignore: cast_nullable_to_non_nullable
                  as String?,
        accountHolderType: freezed == accountHolderType
            ? _value.accountHolderType
            : accountHolderType // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BankDetailImpl implements _BankDetail {
  const _$BankDetailImpl({
    this.country,
    this.currency,
    this.routingNumber,
    this.accountNumber,
    this.accountHolderName,
    this.accountHolderType,
  });

  factory _$BankDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$BankDetailImplFromJson(json);

  @override
  final String? country;
  @override
  final String? currency;
  @override
  final String? routingNumber;
  @override
  final String? accountNumber;
  @override
  final String? accountHolderName;
  @override
  final String? accountHolderType;

  @override
  String toString() {
    return 'BankDetail(country: $country, currency: $currency, routingNumber: $routingNumber, accountNumber: $accountNumber, accountHolderName: $accountHolderName, accountHolderType: $accountHolderType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BankDetailImpl &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.routingNumber, routingNumber) ||
                other.routingNumber == routingNumber) &&
            (identical(other.accountNumber, accountNumber) ||
                other.accountNumber == accountNumber) &&
            (identical(other.accountHolderName, accountHolderName) ||
                other.accountHolderName == accountHolderName) &&
            (identical(other.accountHolderType, accountHolderType) ||
                other.accountHolderType == accountHolderType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    country,
    currency,
    routingNumber,
    accountNumber,
    accountHolderName,
    accountHolderType,
  );

  /// Create a copy of BankDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BankDetailImplCopyWith<_$BankDetailImpl> get copyWith =>
      __$$BankDetailImplCopyWithImpl<_$BankDetailImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BankDetailImplToJson(this);
  }
}

abstract class _BankDetail implements BankDetail {
  const factory _BankDetail({
    final String? country,
    final String? currency,
    final String? routingNumber,
    final String? accountNumber,
    final String? accountHolderName,
    final String? accountHolderType,
  }) = _$BankDetailImpl;

  factory _BankDetail.fromJson(Map<String, dynamic> json) =
      _$BankDetailImpl.fromJson;

  @override
  String? get country;
  @override
  String? get currency;
  @override
  String? get routingNumber;
  @override
  String? get accountNumber;
  @override
  String? get accountHolderName;
  @override
  String? get accountHolderType;

  /// Create a copy of BankDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BankDetailImplCopyWith<_$BankDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
