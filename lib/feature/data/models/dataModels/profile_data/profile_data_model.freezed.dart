// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_data_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProfileDataModel _$ProfileDataModelFromJson(Map<String, dynamic> json) {
  return _ProfileDataModel.fromJson(json);
}

/// @nodoc
mixin _$ProfileDataModel {
  @JsonKey(name: "stripeCustomerId")
  String? get stripeCustomerId => throw _privateConstructorUsedError;
  @JsonKey(name: "stripeAccountId")
  String? get stripeAccountId => throw _privateConstructorUsedError;
  @JsonKey(name: "walletBalance")
  double? get walletBalance => throw _privateConstructorUsedError;
  @JsonKey(name: "tokenBalance")
  int? get tokenBalance => throw _privateConstructorUsedError;
  @JsonKey(name: "walletTokens")
  int? get walletTokens => throw _privateConstructorUsedError;
  @JsonKey(name: "name")
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: "_id")
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: "email")
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: "password")
  String? get password => throw _privateConstructorUsedError;
  @JsonKey(name: "role")
  String? get role => throw _privateConstructorUsedError;
  @JsonKey(name: "phone")
  String? get phone => throw _privateConstructorUsedError;
  @JsonKey(name: "countryCode")
  String? get countryCode => throw _privateConstructorUsedError;
  @JsonKey(name: "dob")
  dynamic get dob => throw _privateConstructorUsedError;
  @JsonKey(name: "country")
  String? get country => throw _privateConstructorUsedError;
  @JsonKey(name: "gender")
  String? get gender => throw _privateConstructorUsedError;
  @JsonKey(name: "image")
  dynamic get image => throw _privateConstructorUsedError;
  @JsonKey(name: "coverPhoto")
  String? get coverPhoto => throw _privateConstructorUsedError;
  @JsonKey(name: "socialId")
  String? get socialId => throw _privateConstructorUsedError;
  @JsonKey(name: "socialType")
  String? get socialType => throw _privateConstructorUsedError;
  @JsonKey(name: "deviceType")
  String? get deviceType => throw _privateConstructorUsedError;
  @JsonKey(name: "deviceToken")
  String? get deviceToken => throw _privateConstructorUsedError;
  @JsonKey(name: "isActive")
  bool? get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: "isBlocked")
  bool? get isBlocked => throw _privateConstructorUsedError;
  @JsonKey(name: "isBlockedByAdmin")
  bool? get isBlockedByAdmin => throw _privateConstructorUsedError;
  @JsonKey(name: "isDelete")
  bool? get isDelete => throw _privateConstructorUsedError;
  @JsonKey(name: "isOnline")
  bool? get isOnline => throw _privateConstructorUsedError;
  @JsonKey(name: "createdAt")
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: "updatedAt")
  String? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: "seeMyProfile")
  String? get seeMyProfile => throw _privateConstructorUsedError;
  @JsonKey(name: "shareMyPost")
  String? get shareMyPost => throw _privateConstructorUsedError;
  @JsonKey(name: "isNotification")
  bool? get isNotification => throw _privateConstructorUsedError;
  @JsonKey(name: "followers")
  dynamic get followers => throw _privateConstructorUsedError;
  @JsonKey(name: "following")
  dynamic get following => throw _privateConstructorUsedError;
  @JsonKey(name: "blockUser")
  dynamic get blockUser => throw _privateConstructorUsedError;
  @JsonKey(name: "postCount")
  int? get postCount => throw _privateConstructorUsedError;
  @JsonKey(name: "bio")
  String? get bio => throw _privateConstructorUsedError;
  @JsonKey(name: "website")
  String? get website => throw _privateConstructorUsedError;
  @JsonKey(name: "username")
  String? get userName => throw _privateConstructorUsedError;
  @JsonKey(name: "__v")
  int? get v => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  AgoraUserLiveStatus? get agoraLiveStatus =>
      throw _privateConstructorUsedError;

  /// Serializes this ProfileDataModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProfileDataModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileDataModelCopyWith<ProfileDataModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileDataModelCopyWith<$Res> {
  factory $ProfileDataModelCopyWith(
    ProfileDataModel value,
    $Res Function(ProfileDataModel) then,
  ) = _$ProfileDataModelCopyWithImpl<$Res, ProfileDataModel>;
  @useResult
  $Res call({
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
  });
}

/// @nodoc
class _$ProfileDataModelCopyWithImpl<$Res, $Val extends ProfileDataModel>
    implements $ProfileDataModelCopyWith<$Res> {
  _$ProfileDataModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileDataModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stripeCustomerId = freezed,
    Object? stripeAccountId = freezed,
    Object? walletBalance = freezed,
    Object? tokenBalance = freezed,
    Object? walletTokens = freezed,
    Object? name = freezed,
    Object? id = freezed,
    Object? email = freezed,
    Object? password = freezed,
    Object? role = freezed,
    Object? phone = freezed,
    Object? countryCode = freezed,
    Object? dob = freezed,
    Object? country = freezed,
    Object? gender = freezed,
    Object? image = freezed,
    Object? coverPhoto = freezed,
    Object? socialId = freezed,
    Object? socialType = freezed,
    Object? deviceType = freezed,
    Object? deviceToken = freezed,
    Object? isActive = freezed,
    Object? isBlocked = freezed,
    Object? isBlockedByAdmin = freezed,
    Object? isDelete = freezed,
    Object? isOnline = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? seeMyProfile = freezed,
    Object? shareMyPost = freezed,
    Object? isNotification = freezed,
    Object? followers = freezed,
    Object? following = freezed,
    Object? blockUser = freezed,
    Object? postCount = freezed,
    Object? bio = freezed,
    Object? website = freezed,
    Object? userName = freezed,
    Object? v = freezed,
    Object? agoraLiveStatus = freezed,
  }) {
    return _then(
      _value.copyWith(
            stripeCustomerId: freezed == stripeCustomerId
                ? _value.stripeCustomerId
                : stripeCustomerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            stripeAccountId: freezed == stripeAccountId
                ? _value.stripeAccountId
                : stripeAccountId // ignore: cast_nullable_to_non_nullable
                      as String?,
            walletBalance: freezed == walletBalance
                ? _value.walletBalance
                : walletBalance // ignore: cast_nullable_to_non_nullable
                      as double?,
            tokenBalance: freezed == tokenBalance
                ? _value.tokenBalance
                : tokenBalance // ignore: cast_nullable_to_non_nullable
                      as int?,
            walletTokens: freezed == walletTokens
                ? _value.walletTokens
                : walletTokens // ignore: cast_nullable_to_non_nullable
                      as int?,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            password: freezed == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String?,
            role: freezed == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            countryCode: freezed == countryCode
                ? _value.countryCode
                : countryCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            dob: freezed == dob
                ? _value.dob
                : dob // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            country: freezed == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                      as String?,
            gender: freezed == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as String?,
            image: freezed == image
                ? _value.image
                : image // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            coverPhoto: freezed == coverPhoto
                ? _value.coverPhoto
                : coverPhoto // ignore: cast_nullable_to_non_nullable
                      as String?,
            socialId: freezed == socialId
                ? _value.socialId
                : socialId // ignore: cast_nullable_to_non_nullable
                      as String?,
            socialType: freezed == socialType
                ? _value.socialType
                : socialType // ignore: cast_nullable_to_non_nullable
                      as String?,
            deviceType: freezed == deviceType
                ? _value.deviceType
                : deviceType // ignore: cast_nullable_to_non_nullable
                      as String?,
            deviceToken: freezed == deviceToken
                ? _value.deviceToken
                : deviceToken // ignore: cast_nullable_to_non_nullable
                      as String?,
            isActive: freezed == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool?,
            isBlocked: freezed == isBlocked
                ? _value.isBlocked
                : isBlocked // ignore: cast_nullable_to_non_nullable
                      as bool?,
            isBlockedByAdmin: freezed == isBlockedByAdmin
                ? _value.isBlockedByAdmin
                : isBlockedByAdmin // ignore: cast_nullable_to_non_nullable
                      as bool?,
            isDelete: freezed == isDelete
                ? _value.isDelete
                : isDelete // ignore: cast_nullable_to_non_nullable
                      as bool?,
            isOnline: freezed == isOnline
                ? _value.isOnline
                : isOnline // ignore: cast_nullable_to_non_nullable
                      as bool?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            seeMyProfile: freezed == seeMyProfile
                ? _value.seeMyProfile
                : seeMyProfile // ignore: cast_nullable_to_non_nullable
                      as String?,
            shareMyPost: freezed == shareMyPost
                ? _value.shareMyPost
                : shareMyPost // ignore: cast_nullable_to_non_nullable
                      as String?,
            isNotification: freezed == isNotification
                ? _value.isNotification
                : isNotification // ignore: cast_nullable_to_non_nullable
                      as bool?,
            followers: freezed == followers
                ? _value.followers
                : followers // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            following: freezed == following
                ? _value.following
                : following // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            blockUser: freezed == blockUser
                ? _value.blockUser
                : blockUser // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            postCount: freezed == postCount
                ? _value.postCount
                : postCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            bio: freezed == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                      as String?,
            website: freezed == website
                ? _value.website
                : website // ignore: cast_nullable_to_non_nullable
                      as String?,
            userName: freezed == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String?,
            v: freezed == v
                ? _value.v
                : v // ignore: cast_nullable_to_non_nullable
                      as int?,
            agoraLiveStatus: freezed == agoraLiveStatus
                ? _value.agoraLiveStatus
                : agoraLiveStatus // ignore: cast_nullable_to_non_nullable
                      as AgoraUserLiveStatus?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProfileDataModelImplCopyWith<$Res>
    implements $ProfileDataModelCopyWith<$Res> {
  factory _$$ProfileDataModelImplCopyWith(
    _$ProfileDataModelImpl value,
    $Res Function(_$ProfileDataModelImpl) then,
  ) = __$$ProfileDataModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
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
  });
}

/// @nodoc
class __$$ProfileDataModelImplCopyWithImpl<$Res>
    extends _$ProfileDataModelCopyWithImpl<$Res, _$ProfileDataModelImpl>
    implements _$$ProfileDataModelImplCopyWith<$Res> {
  __$$ProfileDataModelImplCopyWithImpl(
    _$ProfileDataModelImpl _value,
    $Res Function(_$ProfileDataModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProfileDataModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stripeCustomerId = freezed,
    Object? stripeAccountId = freezed,
    Object? walletBalance = freezed,
    Object? tokenBalance = freezed,
    Object? walletTokens = freezed,
    Object? name = freezed,
    Object? id = freezed,
    Object? email = freezed,
    Object? password = freezed,
    Object? role = freezed,
    Object? phone = freezed,
    Object? countryCode = freezed,
    Object? dob = freezed,
    Object? country = freezed,
    Object? gender = freezed,
    Object? image = freezed,
    Object? coverPhoto = freezed,
    Object? socialId = freezed,
    Object? socialType = freezed,
    Object? deviceType = freezed,
    Object? deviceToken = freezed,
    Object? isActive = freezed,
    Object? isBlocked = freezed,
    Object? isBlockedByAdmin = freezed,
    Object? isDelete = freezed,
    Object? isOnline = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? seeMyProfile = freezed,
    Object? shareMyPost = freezed,
    Object? isNotification = freezed,
    Object? followers = freezed,
    Object? following = freezed,
    Object? blockUser = freezed,
    Object? postCount = freezed,
    Object? bio = freezed,
    Object? website = freezed,
    Object? userName = freezed,
    Object? v = freezed,
    Object? agoraLiveStatus = freezed,
  }) {
    return _then(
      _$ProfileDataModelImpl(
        stripeCustomerId: freezed == stripeCustomerId
            ? _value.stripeCustomerId
            : stripeCustomerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        stripeAccountId: freezed == stripeAccountId
            ? _value.stripeAccountId
            : stripeAccountId // ignore: cast_nullable_to_non_nullable
                  as String?,
        walletBalance: freezed == walletBalance
            ? _value.walletBalance
            : walletBalance // ignore: cast_nullable_to_non_nullable
                  as double?,
        tokenBalance: freezed == tokenBalance
            ? _value.tokenBalance
            : tokenBalance // ignore: cast_nullable_to_non_nullable
                  as int?,
        walletTokens: freezed == walletTokens
            ? _value.walletTokens
            : walletTokens // ignore: cast_nullable_to_non_nullable
                  as int?,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        password: freezed == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String?,
        role: freezed == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        countryCode: freezed == countryCode
            ? _value.countryCode
            : countryCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        dob: freezed == dob
            ? _value.dob
            : dob // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        country: freezed == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as String?,
        gender: freezed == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as String?,
        image: freezed == image
            ? _value.image
            : image // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        coverPhoto: freezed == coverPhoto
            ? _value.coverPhoto
            : coverPhoto // ignore: cast_nullable_to_non_nullable
                  as String?,
        socialId: freezed == socialId
            ? _value.socialId
            : socialId // ignore: cast_nullable_to_non_nullable
                  as String?,
        socialType: freezed == socialType
            ? _value.socialType
            : socialType // ignore: cast_nullable_to_non_nullable
                  as String?,
        deviceType: freezed == deviceType
            ? _value.deviceType
            : deviceType // ignore: cast_nullable_to_non_nullable
                  as String?,
        deviceToken: freezed == deviceToken
            ? _value.deviceToken
            : deviceToken // ignore: cast_nullable_to_non_nullable
                  as String?,
        isActive: freezed == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isBlocked: freezed == isBlocked
            ? _value.isBlocked
            : isBlocked // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isBlockedByAdmin: freezed == isBlockedByAdmin
            ? _value.isBlockedByAdmin
            : isBlockedByAdmin // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isDelete: freezed == isDelete
            ? _value.isDelete
            : isDelete // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isOnline: freezed == isOnline
            ? _value.isOnline
            : isOnline // ignore: cast_nullable_to_non_nullable
                  as bool?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        seeMyProfile: freezed == seeMyProfile
            ? _value.seeMyProfile
            : seeMyProfile // ignore: cast_nullable_to_non_nullable
                  as String?,
        shareMyPost: freezed == shareMyPost
            ? _value.shareMyPost
            : shareMyPost // ignore: cast_nullable_to_non_nullable
                  as String?,
        isNotification: freezed == isNotification
            ? _value.isNotification
            : isNotification // ignore: cast_nullable_to_non_nullable
                  as bool?,
        followers: freezed == followers
            ? _value.followers
            : followers // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        following: freezed == following
            ? _value.following
            : following // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        blockUser: freezed == blockUser
            ? _value.blockUser
            : blockUser // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        postCount: freezed == postCount
            ? _value.postCount
            : postCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        bio: freezed == bio
            ? _value.bio
            : bio // ignore: cast_nullable_to_non_nullable
                  as String?,
        website: freezed == website
            ? _value.website
            : website // ignore: cast_nullable_to_non_nullable
                  as String?,
        userName: freezed == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String?,
        v: freezed == v
            ? _value.v
            : v // ignore: cast_nullable_to_non_nullable
                  as int?,
        agoraLiveStatus: freezed == agoraLiveStatus
            ? _value.agoraLiveStatus
            : agoraLiveStatus // ignore: cast_nullable_to_non_nullable
                  as AgoraUserLiveStatus?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileDataModelImpl implements _ProfileDataModel {
  const _$ProfileDataModelImpl({
    @JsonKey(name: "stripeCustomerId") this.stripeCustomerId,
    @JsonKey(name: "stripeAccountId") this.stripeAccountId,
    @JsonKey(name: "walletBalance") this.walletBalance,
    @JsonKey(name: "tokenBalance") this.tokenBalance,
    @JsonKey(name: "walletTokens") this.walletTokens,
    @JsonKey(name: "name") this.name,
    @JsonKey(name: "_id") this.id,
    @JsonKey(name: "email") this.email,
    @JsonKey(name: "password") this.password,
    @JsonKey(name: "role") this.role,
    @JsonKey(name: "phone") this.phone,
    @JsonKey(name: "countryCode") this.countryCode,
    @JsonKey(name: "dob") this.dob,
    @JsonKey(name: "country") this.country,
    @JsonKey(name: "gender") this.gender,
    @JsonKey(name: "image") this.image,
    @JsonKey(name: "coverPhoto") this.coverPhoto,
    @JsonKey(name: "socialId") this.socialId,
    @JsonKey(name: "socialType") this.socialType,
    @JsonKey(name: "deviceType") this.deviceType,
    @JsonKey(name: "deviceToken") this.deviceToken,
    @JsonKey(name: "isActive") this.isActive,
    @JsonKey(name: "isBlocked") this.isBlocked,
    @JsonKey(name: "isBlockedByAdmin") this.isBlockedByAdmin,
    @JsonKey(name: "isDelete") this.isDelete,
    @JsonKey(name: "isOnline") this.isOnline,
    @JsonKey(name: "createdAt") this.createdAt,
    @JsonKey(name: "updatedAt") this.updatedAt,
    @JsonKey(name: "seeMyProfile") this.seeMyProfile,
    @JsonKey(name: "shareMyPost") this.shareMyPost,
    @JsonKey(name: "isNotification") this.isNotification,
    @JsonKey(name: "followers") this.followers,
    @JsonKey(name: "following") this.following,
    @JsonKey(name: "blockUser") this.blockUser,
    @JsonKey(name: "postCount") this.postCount,
    @JsonKey(name: "bio") this.bio,
    @JsonKey(name: "website") this.website,
    @JsonKey(name: "username") this.userName,
    @JsonKey(name: "__v") this.v,
    @JsonKey(includeFromJson: false, includeToJson: false) this.agoraLiveStatus,
  });

  factory _$ProfileDataModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileDataModelImplFromJson(json);

  @override
  @JsonKey(name: "stripeCustomerId")
  final String? stripeCustomerId;
  @override
  @JsonKey(name: "stripeAccountId")
  final String? stripeAccountId;
  @override
  @JsonKey(name: "walletBalance")
  final double? walletBalance;
  @override
  @JsonKey(name: "tokenBalance")
  final int? tokenBalance;
  @override
  @JsonKey(name: "walletTokens")
  final int? walletTokens;
  @override
  @JsonKey(name: "name")
  final String? name;
  @override
  @JsonKey(name: "_id")
  final String? id;
  @override
  @JsonKey(name: "email")
  final String? email;
  @override
  @JsonKey(name: "password")
  final String? password;
  @override
  @JsonKey(name: "role")
  final String? role;
  @override
  @JsonKey(name: "phone")
  final String? phone;
  @override
  @JsonKey(name: "countryCode")
  final String? countryCode;
  @override
  @JsonKey(name: "dob")
  final dynamic dob;
  @override
  @JsonKey(name: "country")
  final String? country;
  @override
  @JsonKey(name: "gender")
  final String? gender;
  @override
  @JsonKey(name: "image")
  final dynamic image;
  @override
  @JsonKey(name: "coverPhoto")
  final String? coverPhoto;
  @override
  @JsonKey(name: "socialId")
  final String? socialId;
  @override
  @JsonKey(name: "socialType")
  final String? socialType;
  @override
  @JsonKey(name: "deviceType")
  final String? deviceType;
  @override
  @JsonKey(name: "deviceToken")
  final String? deviceToken;
  @override
  @JsonKey(name: "isActive")
  final bool? isActive;
  @override
  @JsonKey(name: "isBlocked")
  final bool? isBlocked;
  @override
  @JsonKey(name: "isBlockedByAdmin")
  final bool? isBlockedByAdmin;
  @override
  @JsonKey(name: "isDelete")
  final bool? isDelete;
  @override
  @JsonKey(name: "isOnline")
  final bool? isOnline;
  @override
  @JsonKey(name: "createdAt")
  final String? createdAt;
  @override
  @JsonKey(name: "updatedAt")
  final String? updatedAt;
  @override
  @JsonKey(name: "seeMyProfile")
  final String? seeMyProfile;
  @override
  @JsonKey(name: "shareMyPost")
  final String? shareMyPost;
  @override
  @JsonKey(name: "isNotification")
  final bool? isNotification;
  @override
  @JsonKey(name: "followers")
  final dynamic followers;
  @override
  @JsonKey(name: "following")
  final dynamic following;
  @override
  @JsonKey(name: "blockUser")
  final dynamic blockUser;
  @override
  @JsonKey(name: "postCount")
  final int? postCount;
  @override
  @JsonKey(name: "bio")
  final String? bio;
  @override
  @JsonKey(name: "website")
  final String? website;
  @override
  @JsonKey(name: "username")
  final String? userName;
  @override
  @JsonKey(name: "__v")
  final int? v;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final AgoraUserLiveStatus? agoraLiveStatus;

  @override
  String toString() {
    return 'ProfileDataModel(stripeCustomerId: $stripeCustomerId, stripeAccountId: $stripeAccountId, walletBalance: $walletBalance, tokenBalance: $tokenBalance, walletTokens: $walletTokens, name: $name, id: $id, email: $email, password: $password, role: $role, phone: $phone, countryCode: $countryCode, dob: $dob, country: $country, gender: $gender, image: $image, coverPhoto: $coverPhoto, socialId: $socialId, socialType: $socialType, deviceType: $deviceType, deviceToken: $deviceToken, isActive: $isActive, isBlocked: $isBlocked, isBlockedByAdmin: $isBlockedByAdmin, isDelete: $isDelete, isOnline: $isOnline, createdAt: $createdAt, updatedAt: $updatedAt, seeMyProfile: $seeMyProfile, shareMyPost: $shareMyPost, isNotification: $isNotification, followers: $followers, following: $following, blockUser: $blockUser, postCount: $postCount, bio: $bio, website: $website, userName: $userName, v: $v, agoraLiveStatus: $agoraLiveStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileDataModelImpl &&
            (identical(other.stripeCustomerId, stripeCustomerId) ||
                other.stripeCustomerId == stripeCustomerId) &&
            (identical(other.stripeAccountId, stripeAccountId) ||
                other.stripeAccountId == stripeAccountId) &&
            (identical(other.walletBalance, walletBalance) ||
                other.walletBalance == walletBalance) &&
            (identical(other.tokenBalance, tokenBalance) ||
                other.tokenBalance == tokenBalance) &&
            (identical(other.walletTokens, walletTokens) ||
                other.walletTokens == walletTokens) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.countryCode, countryCode) ||
                other.countryCode == countryCode) &&
            const DeepCollectionEquality().equals(other.dob, dob) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            const DeepCollectionEquality().equals(other.image, image) &&
            (identical(other.coverPhoto, coverPhoto) ||
                other.coverPhoto == coverPhoto) &&
            (identical(other.socialId, socialId) ||
                other.socialId == socialId) &&
            (identical(other.socialType, socialType) ||
                other.socialType == socialType) &&
            (identical(other.deviceType, deviceType) ||
                other.deviceType == deviceType) &&
            (identical(other.deviceToken, deviceToken) ||
                other.deviceToken == deviceToken) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isBlocked, isBlocked) ||
                other.isBlocked == isBlocked) &&
            (identical(other.isBlockedByAdmin, isBlockedByAdmin) ||
                other.isBlockedByAdmin == isBlockedByAdmin) &&
            (identical(other.isDelete, isDelete) ||
                other.isDelete == isDelete) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.seeMyProfile, seeMyProfile) ||
                other.seeMyProfile == seeMyProfile) &&
            (identical(other.shareMyPost, shareMyPost) ||
                other.shareMyPost == shareMyPost) &&
            (identical(other.isNotification, isNotification) ||
                other.isNotification == isNotification) &&
            const DeepCollectionEquality().equals(other.followers, followers) &&
            const DeepCollectionEquality().equals(other.following, following) &&
            const DeepCollectionEquality().equals(other.blockUser, blockUser) &&
            (identical(other.postCount, postCount) ||
                other.postCount == postCount) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.website, website) || other.website == website) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.v, v) || other.v == v) &&
            (identical(other.agoraLiveStatus, agoraLiveStatus) ||
                other.agoraLiveStatus == agoraLiveStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    stripeCustomerId,
    stripeAccountId,
    walletBalance,
    tokenBalance,
    walletTokens,
    name,
    id,
    email,
    password,
    role,
    phone,
    countryCode,
    const DeepCollectionEquality().hash(dob),
    country,
    gender,
    const DeepCollectionEquality().hash(image),
    coverPhoto,
    socialId,
    socialType,
    deviceType,
    deviceToken,
    isActive,
    isBlocked,
    isBlockedByAdmin,
    isDelete,
    isOnline,
    createdAt,
    updatedAt,
    seeMyProfile,
    shareMyPost,
    isNotification,
    const DeepCollectionEquality().hash(followers),
    const DeepCollectionEquality().hash(following),
    const DeepCollectionEquality().hash(blockUser),
    postCount,
    bio,
    website,
    userName,
    v,
    agoraLiveStatus,
  ]);

  /// Create a copy of ProfileDataModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileDataModelImplCopyWith<_$ProfileDataModelImpl> get copyWith =>
      __$$ProfileDataModelImplCopyWithImpl<_$ProfileDataModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileDataModelImplToJson(this);
  }
}

abstract class _ProfileDataModel implements ProfileDataModel {
  const factory _ProfileDataModel({
    @JsonKey(name: "stripeCustomerId") final String? stripeCustomerId,
    @JsonKey(name: "stripeAccountId") final String? stripeAccountId,
    @JsonKey(name: "walletBalance") final double? walletBalance,
    @JsonKey(name: "tokenBalance") final int? tokenBalance,
    @JsonKey(name: "walletTokens") final int? walletTokens,
    @JsonKey(name: "name") final String? name,
    @JsonKey(name: "_id") final String? id,
    @JsonKey(name: "email") final String? email,
    @JsonKey(name: "password") final String? password,
    @JsonKey(name: "role") final String? role,
    @JsonKey(name: "phone") final String? phone,
    @JsonKey(name: "countryCode") final String? countryCode,
    @JsonKey(name: "dob") final dynamic dob,
    @JsonKey(name: "country") final String? country,
    @JsonKey(name: "gender") final String? gender,
    @JsonKey(name: "image") final dynamic image,
    @JsonKey(name: "coverPhoto") final String? coverPhoto,
    @JsonKey(name: "socialId") final String? socialId,
    @JsonKey(name: "socialType") final String? socialType,
    @JsonKey(name: "deviceType") final String? deviceType,
    @JsonKey(name: "deviceToken") final String? deviceToken,
    @JsonKey(name: "isActive") final bool? isActive,
    @JsonKey(name: "isBlocked") final bool? isBlocked,
    @JsonKey(name: "isBlockedByAdmin") final bool? isBlockedByAdmin,
    @JsonKey(name: "isDelete") final bool? isDelete,
    @JsonKey(name: "isOnline") final bool? isOnline,
    @JsonKey(name: "createdAt") final String? createdAt,
    @JsonKey(name: "updatedAt") final String? updatedAt,
    @JsonKey(name: "seeMyProfile") final String? seeMyProfile,
    @JsonKey(name: "shareMyPost") final String? shareMyPost,
    @JsonKey(name: "isNotification") final bool? isNotification,
    @JsonKey(name: "followers") final dynamic followers,
    @JsonKey(name: "following") final dynamic following,
    @JsonKey(name: "blockUser") final dynamic blockUser,
    @JsonKey(name: "postCount") final int? postCount,
    @JsonKey(name: "bio") final String? bio,
    @JsonKey(name: "website") final String? website,
    @JsonKey(name: "username") final String? userName,
    @JsonKey(name: "__v") final int? v,
    @JsonKey(includeFromJson: false, includeToJson: false)
    final AgoraUserLiveStatus? agoraLiveStatus,
  }) = _$ProfileDataModelImpl;

  factory _ProfileDataModel.fromJson(Map<String, dynamic> json) =
      _$ProfileDataModelImpl.fromJson;

  @override
  @JsonKey(name: "stripeCustomerId")
  String? get stripeCustomerId;
  @override
  @JsonKey(name: "stripeAccountId")
  String? get stripeAccountId;
  @override
  @JsonKey(name: "walletBalance")
  double? get walletBalance;
  @override
  @JsonKey(name: "tokenBalance")
  int? get tokenBalance;
  @override
  @JsonKey(name: "walletTokens")
  int? get walletTokens;
  @override
  @JsonKey(name: "name")
  String? get name;
  @override
  @JsonKey(name: "_id")
  String? get id;
  @override
  @JsonKey(name: "email")
  String? get email;
  @override
  @JsonKey(name: "password")
  String? get password;
  @override
  @JsonKey(name: "role")
  String? get role;
  @override
  @JsonKey(name: "phone")
  String? get phone;
  @override
  @JsonKey(name: "countryCode")
  String? get countryCode;
  @override
  @JsonKey(name: "dob")
  dynamic get dob;
  @override
  @JsonKey(name: "country")
  String? get country;
  @override
  @JsonKey(name: "gender")
  String? get gender;
  @override
  @JsonKey(name: "image")
  dynamic get image;
  @override
  @JsonKey(name: "coverPhoto")
  String? get coverPhoto;
  @override
  @JsonKey(name: "socialId")
  String? get socialId;
  @override
  @JsonKey(name: "socialType")
  String? get socialType;
  @override
  @JsonKey(name: "deviceType")
  String? get deviceType;
  @override
  @JsonKey(name: "deviceToken")
  String? get deviceToken;
  @override
  @JsonKey(name: "isActive")
  bool? get isActive;
  @override
  @JsonKey(name: "isBlocked")
  bool? get isBlocked;
  @override
  @JsonKey(name: "isBlockedByAdmin")
  bool? get isBlockedByAdmin;
  @override
  @JsonKey(name: "isDelete")
  bool? get isDelete;
  @override
  @JsonKey(name: "isOnline")
  bool? get isOnline;
  @override
  @JsonKey(name: "createdAt")
  String? get createdAt;
  @override
  @JsonKey(name: "updatedAt")
  String? get updatedAt;
  @override
  @JsonKey(name: "seeMyProfile")
  String? get seeMyProfile;
  @override
  @JsonKey(name: "shareMyPost")
  String? get shareMyPost;
  @override
  @JsonKey(name: "isNotification")
  bool? get isNotification;
  @override
  @JsonKey(name: "followers")
  dynamic get followers;
  @override
  @JsonKey(name: "following")
  dynamic get following;
  @override
  @JsonKey(name: "blockUser")
  dynamic get blockUser;
  @override
  @JsonKey(name: "postCount")
  int? get postCount;
  @override
  @JsonKey(name: "bio")
  String? get bio;
  @override
  @JsonKey(name: "website")
  String? get website;
  @override
  @JsonKey(name: "username")
  String? get userName;
  @override
  @JsonKey(name: "__v")
  int? get v;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  AgoraUserLiveStatus? get agoraLiveStatus;

  /// Create a copy of ProfileDataModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileDataModelImplCopyWith<_$ProfileDataModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
