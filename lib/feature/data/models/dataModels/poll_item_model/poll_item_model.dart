// To parse this JSON data, do
//
//     final pollItemModel = pollItemModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

import 'package:sep/utils/extensions/extensions.dart';

part 'poll_item_model.freezed.dart';
part 'poll_item_model.g.dart';

PollItemModel pollItemModelFromJson(String str) =>
    PollItemModel.fromJson(json.decode(str));

String pollItemModelToJson(PollItemModel data) => json.encode(data.toJson());

@freezed
class PollItemModel with _$PollItemModel {
  const factory PollItemModel({
    String? name,
    String? image,
    String? file,
    bool? isValid,
  }) = _PollItemModel;

  factory PollItemModel.fromJson(Map<String, dynamic> json) =>
      _$PollItemModelFromJson(json);
}

extension PollItemModelExtension on PollItemModel {
  PollItemModel get updatedValidity => copyWith(
    isValid: name.isNotNullEmpty,
  ); // Only require text, image is optional
}
