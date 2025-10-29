// To parse this JSON data, do
//
//     final addressModel = addressModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'address_model.freezed.dart';
part 'address_model.g.dart';

AddressModel addressModelFromJson(String str) =>
    AddressModel.fromJson(json.decode(str));

String addressModelToJson(AddressModel data) => json.encode(data.toJson());

@freezed
class AddressModel with _$AddressModel {
  const factory AddressModel({String? country}) = _AddressModel;

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);
}
