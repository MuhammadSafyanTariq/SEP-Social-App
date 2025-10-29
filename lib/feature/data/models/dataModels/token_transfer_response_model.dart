import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_transfer_response_model.freezed.dart';
part 'token_transfer_response_model.g.dart';

@freezed
class TokenTransferResponseModel with _$TokenTransferResponseModel {
  const factory TokenTransferResponseModel({
    bool? status,
    int? code,
    String? message,
    TokenTransferData? data,
  }) = _TokenTransferResponseModel;

  factory TokenTransferResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TokenTransferResponseModelFromJson(json);
}

@freezed
class TokenTransferData with _$TokenTransferData {
  const factory TokenTransferData({
    int? tokenAmount,
    int? commissionTokens,
    double? dollarValue,
    double? dollarCommission,
    double? senderNewBalance,
    double? receiverNewBalance,
    int? netTokensToReceiver,
  }) = _TokenTransferData;

  factory TokenTransferData.fromJson(Map<String, dynamic> json) =>
      _$TokenTransferDataFromJson(json);
}
