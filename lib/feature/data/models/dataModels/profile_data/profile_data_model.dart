// To parse this JSON data, do
//
//     final profileDataModel = profileDataModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:sep/utils/extensions/extensions.dart';

import '../../../../presentation/liveStreaming_screen/live_stream_ctrl.dart';

part 'profile_data_model.freezed.dart';
part 'profile_data_model.g.dart';

ProfileDataModel profileDataModelFromJson(String str) =>
    ProfileDataModel.fromJson(json.decode(str));

String profileDataModelToJson(ProfileDataModel data) =>
    json.encode(data.toJson());

// Sample JSON structure commented for reference
// {
//   "username": "",
//   "countryCode": "",
//   "dob": null,
//   "isNotification": true,
//   "following": [],
//   "blockUser": [],
//   "seeMyProfile": "everyBody",
//   "shareMyPost": "everyBody",
//   "isActive": false,
//   "isBlocked": false,
//   "isBlockedByAdmin": false,
//   "_id": "679b081d3cdfb86bfb8d705f",
//   "name": "test",
//   "email": "test@gmail.com",
//   "password": "$2b$10$d4M2utbEN1oWUnCUttMehemwtpPKQPlvzLz8Y.kDXdZGpNpaoaGFa",
//   "role": "user",
//   "gender": "male",
//   "createdAt": "2025-01-30T05:03:25.279Z",
//   "updatedAt": "2025-03-12T09:42:39.842Z",
//   "__v": 0,
//   "otp": null,
//   "followers": []
// }

@freezed
class ProfileDataModel with _$ProfileDataModel {
  const factory ProfileDataModel({
    @JsonKey(name: "stripeCustomerId") String? stripeCustomerId,
    @JsonKey(name: "stripeAccountId") String? stripeAccountId,
    @JsonKey(name: "walletBalance") double? walletBalance,
    @JsonKey(name: "tokenBalance") int? tokenBalance,
    @JsonKey(name: "walletTokens") int? walletTokens,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "_id") String? id,
    @JsonKey(name: "email") String? email,
    @JsonKey(name: "password") String? password,
    @JsonKey(name: "role") String? role,
    @JsonKey(name: "phone") String? phone,
    @JsonKey(name: "countryCode") String? countryCode,
    @JsonKey(name: "dob") dynamic dob,
    @JsonKey(name: "country") String? country,
    @JsonKey(name: "gender") String? gender,
    @JsonKey(name: "image") dynamic image,
    @JsonKey(name: "coverPhoto") String? coverPhoto,
    @JsonKey(name: "socialId") String? socialId,
    @JsonKey(name: "socialType") String? socialType,
    @JsonKey(name: "deviceType") String? deviceType,
    @JsonKey(name: "deviceToken") String? deviceToken,
    @JsonKey(name: "isActive") bool? isActive,
    @JsonKey(name: "isBlocked") bool? isBlocked,
    @JsonKey(name: "isBlockedByAdmin") bool? isBlockedByAdmin,
    @JsonKey(name: "isDelete") bool? isDelete,
    @JsonKey(name: "isOnline") bool? isOnline,
    @JsonKey(name: "createdAt") String? createdAt,
    @JsonKey(name: "updatedAt") String? updatedAt,
    @JsonKey(name: "seeMyProfile") String? seeMyProfile,
    @JsonKey(name: "shareMyPost") String? shareMyPost,
    @JsonKey(name: "isNotification") bool? isNotification,
    @JsonKey(name: "followers") dynamic followers,
    @JsonKey(name: "following") dynamic following,
    @JsonKey(name: "blockUser") dynamic blockUser,
    @JsonKey(name: "postCount") int? postCount,
    @JsonKey(name: "bio") String? bio,
    @JsonKey(name: "website") String? website,
    @JsonKey(name: "username") String? userName,
    @JsonKey(name: "__v") int? v,
    @JsonKey(includeFromJson: false, includeToJson: false)
    AgoraUserLiveStatus? agoraLiveStatus,
  }) = _ProfileDataModel;

  factory ProfileDataModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileDataModelFromJson(json);
}

extension ProfileDataExt on ProfileDataModel {
  Future<PhoneNumber?> _phoneNumberData() async {
    final ph = phone;
    if (ph != null && ph.trim().isNotEmpty) {
      final phoneNumber = ph.contains('+') ? ph : '+$ph';
      return await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber);
    } else {
      return null;
    }
  }

  Future<String> get countryCode async {
    final data = await _phoneNumberData();
    return data?.dialCode ?? '';
  }

  Future<String> get getMobileNumber async {
    final data = await _phoneNumberData();
    return (data?.parseNumber() ?? '').replaceFirst('+', '');
  }

  int? get agoraId => id?.agoraToken;

  // Helper getter to handle both tokenBalance and walletTokens field names
  int get actualTokenBalance => walletTokens ?? tokenBalance ?? 0;
}

extension OnMap on Map<String, dynamic> {
  // flutter: │ 🐛     "userId": "683a8cc26a337827c39db2ef",
  // flutter: │ 🐛     "userName": "testing live",
  // flutter: │ 🐛     "participantCount": 1,
  // flutter: │ 🐛     "totalJoined": 2,
  // flutter: │ 🐛     "leftAt": "2025-07-23T09:12:04.475Z",
  // flutter: │ 🐛     "message": "testing live left the live session"

  ProfileDataModel get agoraLiveUserJsonToProfileModel =>
      ProfileDataModel(id: this['userId'], name: this['userName']);
}
