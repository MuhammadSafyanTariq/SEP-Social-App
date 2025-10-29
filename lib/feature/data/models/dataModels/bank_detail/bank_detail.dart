// To parse this JSON data, do
//
//     final bankDetail = bankDetailFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'bank_detail.freezed.dart';
part 'bank_detail.g.dart';

BankDetail bankDetailFromJson(String str) =>
    BankDetail.fromJson(json.decode(str));

String bankDetailToJson(BankDetail data) => json.encode(data.toJson());

@freezed
class BankDetail with _$BankDetail {
  const factory BankDetail({
    String? country,
    String? currency,
    String? routingNumber,
    String? accountNumber,
    String? accountHolderName,
    String? accountHolderType,
  }) = _BankDetail;

  factory BankDetail.fromJson(Map<String, dynamic> json) =>
      _$BankDetailFromJson(json);
}
