// To parse this JSON data, do
//
//     final getuserdetailsModel = getuserdetailsModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'getuserdetails_model.freezed.dart';
part 'getuserdetails_model.g.dart';

GetuserdetailsModel getuserdetailsModelFromJson(String str) => GetuserdetailsModel.fromJson(json.decode(str));

String getuserdetailsModelToJson(GetuserdetailsModel data) => json.encode(data.toJson());

@freezed
class GetuserdetailsModel with _$GetuserdetailsModel {
  const factory GetuserdetailsModel({
    @JsonKey(name: "_id")
     String? id,
    @JsonKey(name: "name")
     String? name,
    @JsonKey(name: "email")
     String? email,
    @JsonKey(name: "role")
     String? role,
    @JsonKey(name: "phone")
     String? phone,
    @JsonKey(name: "dob")
     String? dob,
    @JsonKey(name: "gender")
     String? gender,
    @JsonKey(name: "createdAt")
     String? createdAt,
    @JsonKey(name: "updatedAt")
     String? updatedAt,
    @JsonKey(name: "__v")
     int? v,
    @JsonKey(name: "otp")
     dynamic otp,
  }) = _GetuserdetailsModel;

  factory GetuserdetailsModel.fromJson(Map<String, dynamic> json) => _$GetuserdetailsModelFromJson(json);
}
