// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'token_transfer_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TokenTransferResponseModel _$TokenTransferResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _TokenTransferResponseModel.fromJson(json);
}

/// @nodoc
mixin _$TokenTransferResponseModel {
  bool? get status => throw _privateConstructorUsedError;
  int? get code => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  TokenTransferData? get data => throw _privateConstructorUsedError;

  /// Serializes this TokenTransferResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TokenTransferResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TokenTransferResponseModelCopyWith<TokenTransferResponseModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokenTransferResponseModelCopyWith<$Res> {
  factory $TokenTransferResponseModelCopyWith(
    TokenTransferResponseModel value,
    $Res Function(TokenTransferResponseModel) then,
  ) =
      _$TokenTransferResponseModelCopyWithImpl<
        $Res,
        TokenTransferResponseModel
      >;
  @useResult
  $Res call({
    bool? status,
    int? code,
    String? message,
    TokenTransferData? data,
  });

  $TokenTransferDataCopyWith<$Res>? get data;
}

/// @nodoc
class _$TokenTransferResponseModelCopyWithImpl<
  $Res,
  $Val extends TokenTransferResponseModel
>
    implements $TokenTransferResponseModelCopyWith<$Res> {
  _$TokenTransferResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TokenTransferResponseModel
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
                      as TokenTransferData?,
          )
          as $Val,
    );
  }

  /// Create a copy of TokenTransferResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TokenTransferDataCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $TokenTransferDataCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TokenTransferResponseModelImplCopyWith<$Res>
    implements $TokenTransferResponseModelCopyWith<$Res> {
  factory _$$TokenTransferResponseModelImplCopyWith(
    _$TokenTransferResponseModelImpl value,
    $Res Function(_$TokenTransferResponseModelImpl) then,
  ) = __$$TokenTransferResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool? status,
    int? code,
    String? message,
    TokenTransferData? data,
  });

  @override
  $TokenTransferDataCopyWith<$Res>? get data;
}

/// @nodoc
class __$$TokenTransferResponseModelImplCopyWithImpl<$Res>
    extends
        _$TokenTransferResponseModelCopyWithImpl<
          $Res,
          _$TokenTransferResponseModelImpl
        >
    implements _$$TokenTransferResponseModelImplCopyWith<$Res> {
  __$$TokenTransferResponseModelImplCopyWithImpl(
    _$TokenTransferResponseModelImpl _value,
    $Res Function(_$TokenTransferResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TokenTransferResponseModel
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
      _$TokenTransferResponseModelImpl(
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
                  as TokenTransferData?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenTransferResponseModelImpl implements _TokenTransferResponseModel {
  const _$TokenTransferResponseModelImpl({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory _$TokenTransferResponseModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$TokenTransferResponseModelImplFromJson(json);

  @override
  final bool? status;
  @override
  final int? code;
  @override
  final String? message;
  @override
  final TokenTransferData? data;

  @override
  String toString() {
    return 'TokenTransferResponseModel(status: $status, code: $code, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenTransferResponseModelImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status, code, message, data);

  /// Create a copy of TokenTransferResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenTransferResponseModelImplCopyWith<_$TokenTransferResponseModelImpl>
  get copyWith =>
      __$$TokenTransferResponseModelImplCopyWithImpl<
        _$TokenTransferResponseModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenTransferResponseModelImplToJson(this);
  }
}

abstract class _TokenTransferResponseModel
    implements TokenTransferResponseModel {
  const factory _TokenTransferResponseModel({
    final bool? status,
    final int? code,
    final String? message,
    final TokenTransferData? data,
  }) = _$TokenTransferResponseModelImpl;

  factory _TokenTransferResponseModel.fromJson(Map<String, dynamic> json) =
      _$TokenTransferResponseModelImpl.fromJson;

  @override
  bool? get status;
  @override
  int? get code;
  @override
  String? get message;
  @override
  TokenTransferData? get data;

  /// Create a copy of TokenTransferResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokenTransferResponseModelImplCopyWith<_$TokenTransferResponseModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

TokenTransferData _$TokenTransferDataFromJson(Map<String, dynamic> json) {
  return _TokenTransferData.fromJson(json);
}

/// @nodoc
mixin _$TokenTransferData {
  int? get tokenAmount => throw _privateConstructorUsedError;
  int? get commissionTokens => throw _privateConstructorUsedError;
  double? get dollarValue => throw _privateConstructorUsedError;
  double? get dollarCommission => throw _privateConstructorUsedError;
  double? get senderNewBalance => throw _privateConstructorUsedError;
  double? get receiverNewBalance => throw _privateConstructorUsedError;
  int? get netTokensToReceiver => throw _privateConstructorUsedError;

  /// Serializes this TokenTransferData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TokenTransferData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TokenTransferDataCopyWith<TokenTransferData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokenTransferDataCopyWith<$Res> {
  factory $TokenTransferDataCopyWith(
    TokenTransferData value,
    $Res Function(TokenTransferData) then,
  ) = _$TokenTransferDataCopyWithImpl<$Res, TokenTransferData>;
  @useResult
  $Res call({
    int? tokenAmount,
    int? commissionTokens,
    double? dollarValue,
    double? dollarCommission,
    double? senderNewBalance,
    double? receiverNewBalance,
    int? netTokensToReceiver,
  });
}

/// @nodoc
class _$TokenTransferDataCopyWithImpl<$Res, $Val extends TokenTransferData>
    implements $TokenTransferDataCopyWith<$Res> {
  _$TokenTransferDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TokenTransferData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tokenAmount = freezed,
    Object? commissionTokens = freezed,
    Object? dollarValue = freezed,
    Object? dollarCommission = freezed,
    Object? senderNewBalance = freezed,
    Object? receiverNewBalance = freezed,
    Object? netTokensToReceiver = freezed,
  }) {
    return _then(
      _value.copyWith(
            tokenAmount: freezed == tokenAmount
                ? _value.tokenAmount
                : tokenAmount // ignore: cast_nullable_to_non_nullable
                      as int?,
            commissionTokens: freezed == commissionTokens
                ? _value.commissionTokens
                : commissionTokens // ignore: cast_nullable_to_non_nullable
                      as int?,
            dollarValue: freezed == dollarValue
                ? _value.dollarValue
                : dollarValue // ignore: cast_nullable_to_non_nullable
                      as double?,
            dollarCommission: freezed == dollarCommission
                ? _value.dollarCommission
                : dollarCommission // ignore: cast_nullable_to_non_nullable
                      as double?,
            senderNewBalance: freezed == senderNewBalance
                ? _value.senderNewBalance
                : senderNewBalance // ignore: cast_nullable_to_non_nullable
                      as double?,
            receiverNewBalance: freezed == receiverNewBalance
                ? _value.receiverNewBalance
                : receiverNewBalance // ignore: cast_nullable_to_non_nullable
                      as double?,
            netTokensToReceiver: freezed == netTokensToReceiver
                ? _value.netTokensToReceiver
                : netTokensToReceiver // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TokenTransferDataImplCopyWith<$Res>
    implements $TokenTransferDataCopyWith<$Res> {
  factory _$$TokenTransferDataImplCopyWith(
    _$TokenTransferDataImpl value,
    $Res Function(_$TokenTransferDataImpl) then,
  ) = __$$TokenTransferDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? tokenAmount,
    int? commissionTokens,
    double? dollarValue,
    double? dollarCommission,
    double? senderNewBalance,
    double? receiverNewBalance,
    int? netTokensToReceiver,
  });
}

/// @nodoc
class __$$TokenTransferDataImplCopyWithImpl<$Res>
    extends _$TokenTransferDataCopyWithImpl<$Res, _$TokenTransferDataImpl>
    implements _$$TokenTransferDataImplCopyWith<$Res> {
  __$$TokenTransferDataImplCopyWithImpl(
    _$TokenTransferDataImpl _value,
    $Res Function(_$TokenTransferDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TokenTransferData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tokenAmount = freezed,
    Object? commissionTokens = freezed,
    Object? dollarValue = freezed,
    Object? dollarCommission = freezed,
    Object? senderNewBalance = freezed,
    Object? receiverNewBalance = freezed,
    Object? netTokensToReceiver = freezed,
  }) {
    return _then(
      _$TokenTransferDataImpl(
        tokenAmount: freezed == tokenAmount
            ? _value.tokenAmount
            : tokenAmount // ignore: cast_nullable_to_non_nullable
                  as int?,
        commissionTokens: freezed == commissionTokens
            ? _value.commissionTokens
            : commissionTokens // ignore: cast_nullable_to_non_nullable
                  as int?,
        dollarValue: freezed == dollarValue
            ? _value.dollarValue
            : dollarValue // ignore: cast_nullable_to_non_nullable
                  as double?,
        dollarCommission: freezed == dollarCommission
            ? _value.dollarCommission
            : dollarCommission // ignore: cast_nullable_to_non_nullable
                  as double?,
        senderNewBalance: freezed == senderNewBalance
            ? _value.senderNewBalance
            : senderNewBalance // ignore: cast_nullable_to_non_nullable
                  as double?,
        receiverNewBalance: freezed == receiverNewBalance
            ? _value.receiverNewBalance
            : receiverNewBalance // ignore: cast_nullable_to_non_nullable
                  as double?,
        netTokensToReceiver: freezed == netTokensToReceiver
            ? _value.netTokensToReceiver
            : netTokensToReceiver // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenTransferDataImpl implements _TokenTransferData {
  const _$TokenTransferDataImpl({
    this.tokenAmount,
    this.commissionTokens,
    this.dollarValue,
    this.dollarCommission,
    this.senderNewBalance,
    this.receiverNewBalance,
    this.netTokensToReceiver,
  });

  factory _$TokenTransferDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenTransferDataImplFromJson(json);

  @override
  final int? tokenAmount;
  @override
  final int? commissionTokens;
  @override
  final double? dollarValue;
  @override
  final double? dollarCommission;
  @override
  final double? senderNewBalance;
  @override
  final double? receiverNewBalance;
  @override
  final int? netTokensToReceiver;

  @override
  String toString() {
    return 'TokenTransferData(tokenAmount: $tokenAmount, commissionTokens: $commissionTokens, dollarValue: $dollarValue, dollarCommission: $dollarCommission, senderNewBalance: $senderNewBalance, receiverNewBalance: $receiverNewBalance, netTokensToReceiver: $netTokensToReceiver)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenTransferDataImpl &&
            (identical(other.tokenAmount, tokenAmount) ||
                other.tokenAmount == tokenAmount) &&
            (identical(other.commissionTokens, commissionTokens) ||
                other.commissionTokens == commissionTokens) &&
            (identical(other.dollarValue, dollarValue) ||
                other.dollarValue == dollarValue) &&
            (identical(other.dollarCommission, dollarCommission) ||
                other.dollarCommission == dollarCommission) &&
            (identical(other.senderNewBalance, senderNewBalance) ||
                other.senderNewBalance == senderNewBalance) &&
            (identical(other.receiverNewBalance, receiverNewBalance) ||
                other.receiverNewBalance == receiverNewBalance) &&
            (identical(other.netTokensToReceiver, netTokensToReceiver) ||
                other.netTokensToReceiver == netTokensToReceiver));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    tokenAmount,
    commissionTokens,
    dollarValue,
    dollarCommission,
    senderNewBalance,
    receiverNewBalance,
    netTokensToReceiver,
  );

  /// Create a copy of TokenTransferData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenTransferDataImplCopyWith<_$TokenTransferDataImpl> get copyWith =>
      __$$TokenTransferDataImplCopyWithImpl<_$TokenTransferDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenTransferDataImplToJson(this);
  }
}

abstract class _TokenTransferData implements TokenTransferData {
  const factory _TokenTransferData({
    final int? tokenAmount,
    final int? commissionTokens,
    final double? dollarValue,
    final double? dollarCommission,
    final double? senderNewBalance,
    final double? receiverNewBalance,
    final int? netTokensToReceiver,
  }) = _$TokenTransferDataImpl;

  factory _TokenTransferData.fromJson(Map<String, dynamic> json) =
      _$TokenTransferDataImpl.fromJson;

  @override
  int? get tokenAmount;
  @override
  int? get commissionTokens;
  @override
  double? get dollarValue;
  @override
  double? get dollarCommission;
  @override
  double? get senderNewBalance;
  @override
  double? get receiverNewBalance;
  @override
  int? get netTokensToReceiver;

  /// Create a copy of TokenTransferData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokenTransferDataImplCopyWith<_$TokenTransferDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
