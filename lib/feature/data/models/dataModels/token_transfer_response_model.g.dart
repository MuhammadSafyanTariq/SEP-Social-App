// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_transfer_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TokenTransferResponseModelImpl _$$TokenTransferResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$TokenTransferResponseModelImpl(
  status: json['status'] as bool?,
  code: (json['code'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : TokenTransferData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$TokenTransferResponseModelImplToJson(
  _$TokenTransferResponseModelImpl instance,
) => <String, dynamic>{
  'status': instance.status,
  'code': instance.code,
  'message': instance.message,
  'data': instance.data,
};

_$TokenTransferDataImpl _$$TokenTransferDataImplFromJson(
  Map<String, dynamic> json,
) => _$TokenTransferDataImpl(
  tokenAmount: (json['tokenAmount'] as num?)?.toInt(),
  commissionTokens: (json['commissionTokens'] as num?)?.toInt(),
  dollarValue: (json['dollarValue'] as num?)?.toDouble(),
  dollarCommission: (json['dollarCommission'] as num?)?.toDouble(),
  senderNewBalance: (json['senderNewBalance'] as num?)?.toDouble(),
  receiverNewBalance: (json['receiverNewBalance'] as num?)?.toDouble(),
  netTokensToReceiver: (json['netTokensToReceiver'] as num?)?.toInt(),
);

Map<String, dynamic> _$$TokenTransferDataImplToJson(
  _$TokenTransferDataImpl instance,
) => <String, dynamic>{
  'tokenAmount': instance.tokenAmount,
  'commissionTokens': instance.commissionTokens,
  'dollarValue': instance.dollarValue,
  'dollarCommission': instance.dollarCommission,
  'senderNewBalance': instance.senderNewBalance,
  'receiverNewBalance': instance.receiverNewBalance,
  'netTokensToReceiver': instance.netTokensToReceiver,
};
