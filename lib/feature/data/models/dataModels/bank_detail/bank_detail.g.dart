// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BankDetailImpl _$$BankDetailImplFromJson(Map<String, dynamic> json) =>
    _$BankDetailImpl(
      country: json['country'] as String?,
      currency: json['currency'] as String?,
      routingNumber: json['routingNumber'] as String?,
      accountNumber: json['accountNumber'] as String?,
      accountHolderName: json['accountHolderName'] as String?,
      accountHolderType: json['accountHolderType'] as String?,
    );

Map<String, dynamic> _$$BankDetailImplToJson(_$BankDetailImpl instance) =>
    <String, dynamic>{
      'country': instance.country,
      'currency': instance.currency,
      'routingNumber': instance.routingNumber,
      'accountNumber': instance.accountNumber,
      'accountHolderName': instance.accountHolderName,
      'accountHolderType': instance.accountHolderType,
    };
