// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_product_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserProductModel _$UserProductModelFromJson(Map<String, dynamic> json) {
  return _UserProductModel.fromJson(json);
}

/// @nodoc
mixin _$UserProductModel {
  @JsonKey(name: "_id")
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: "name")
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: "description")
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: "price")
  double? get price => throw _privateConstructorUsedError;
  @JsonKey(name: "mediaUrls")
  List<String>? get mediaUrls => throw _privateConstructorUsedError;
  @JsonKey(name: "category")
  String? get category => throw _privateConstructorUsedError;
  @JsonKey(name: "isAvailable")
  bool get isAvailable => throw _privateConstructorUsedError;
  @JsonKey(name: "shopId")
  dynamic get shopId => throw _privateConstructorUsedError; // Can be String or ShopInfo
  @JsonKey(name: "createdAt")
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: "updatedAt")
  String? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: "__v")
  int? get v => throw _privateConstructorUsedError;

  /// Serializes this UserProductModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProductModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProductModelCopyWith<UserProductModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProductModelCopyWith<$Res> {
  factory $UserProductModelCopyWith(
    UserProductModel value,
    $Res Function(UserProductModel) then,
  ) = _$UserProductModelCopyWithImpl<$Res, UserProductModel>;
  @useResult
  $Res call({
    @JsonKey(name: "_id") String? id,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "description") String? description,
    @JsonKey(name: "price") double? price,
    @JsonKey(name: "mediaUrls") List<String>? mediaUrls,
    @JsonKey(name: "category") String? category,
    @JsonKey(name: "isAvailable") bool isAvailable,
    @JsonKey(name: "shopId") dynamic shopId,
    @JsonKey(name: "createdAt") String? createdAt,
    @JsonKey(name: "updatedAt") String? updatedAt,
    @JsonKey(name: "__v") int? v,
  });
}

/// @nodoc
class _$UserProductModelCopyWithImpl<$Res, $Val extends UserProductModel>
    implements $UserProductModelCopyWith<$Res> {
  _$UserProductModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProductModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? price = freezed,
    Object? mediaUrls = freezed,
    Object? category = freezed,
    Object? isAvailable = null,
    Object? shopId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? v = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            price: freezed == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double?,
            mediaUrls: freezed == mediaUrls
                ? _value.mediaUrls
                : mediaUrls // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String?,
            isAvailable: null == isAvailable
                ? _value.isAvailable
                : isAvailable // ignore: cast_nullable_to_non_nullable
                      as bool,
            shopId: freezed == shopId
                ? _value.shopId
                : shopId // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            v: freezed == v
                ? _value.v
                : v // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserProductModelImplCopyWith<$Res>
    implements $UserProductModelCopyWith<$Res> {
  factory _$$UserProductModelImplCopyWith(
    _$UserProductModelImpl value,
    $Res Function(_$UserProductModelImpl) then,
  ) = __$$UserProductModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: "_id") String? id,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "description") String? description,
    @JsonKey(name: "price") double? price,
    @JsonKey(name: "mediaUrls") List<String>? mediaUrls,
    @JsonKey(name: "category") String? category,
    @JsonKey(name: "isAvailable") bool isAvailable,
    @JsonKey(name: "shopId") dynamic shopId,
    @JsonKey(name: "createdAt") String? createdAt,
    @JsonKey(name: "updatedAt") String? updatedAt,
    @JsonKey(name: "__v") int? v,
  });
}

/// @nodoc
class __$$UserProductModelImplCopyWithImpl<$Res>
    extends _$UserProductModelCopyWithImpl<$Res, _$UserProductModelImpl>
    implements _$$UserProductModelImplCopyWith<$Res> {
  __$$UserProductModelImplCopyWithImpl(
    _$UserProductModelImpl _value,
    $Res Function(_$UserProductModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserProductModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? description = freezed,
    Object? price = freezed,
    Object? mediaUrls = freezed,
    Object? category = freezed,
    Object? isAvailable = null,
    Object? shopId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? v = freezed,
  }) {
    return _then(
      _$UserProductModelImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        price: freezed == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double?,
        mediaUrls: freezed == mediaUrls
            ? _value._mediaUrls
            : mediaUrls // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String?,
        isAvailable: null == isAvailable
            ? _value.isAvailable
            : isAvailable // ignore: cast_nullable_to_non_nullable
                  as bool,
        shopId: freezed == shopId
            ? _value.shopId
            : shopId // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        v: freezed == v
            ? _value.v
            : v // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProductModelImpl implements _UserProductModel {
  const _$UserProductModelImpl({
    @JsonKey(name: "_id") this.id,
    @JsonKey(name: "name") this.name,
    @JsonKey(name: "description") this.description,
    @JsonKey(name: "price") this.price,
    @JsonKey(name: "mediaUrls") final List<String>? mediaUrls,
    @JsonKey(name: "category") this.category,
    @JsonKey(name: "isAvailable") this.isAvailable = true,
    @JsonKey(name: "shopId") this.shopId,
    @JsonKey(name: "createdAt") this.createdAt,
    @JsonKey(name: "updatedAt") this.updatedAt,
    @JsonKey(name: "__v") this.v,
  }) : _mediaUrls = mediaUrls;

  factory _$UserProductModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProductModelImplFromJson(json);

  @override
  @JsonKey(name: "_id")
  final String? id;
  @override
  @JsonKey(name: "name")
  final String? name;
  @override
  @JsonKey(name: "description")
  final String? description;
  @override
  @JsonKey(name: "price")
  final double? price;
  final List<String>? _mediaUrls;
  @override
  @JsonKey(name: "mediaUrls")
  List<String>? get mediaUrls {
    final value = _mediaUrls;
    if (value == null) return null;
    if (_mediaUrls is EqualUnmodifiableListView) return _mediaUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: "category")
  final String? category;
  @override
  @JsonKey(name: "isAvailable")
  final bool isAvailable;
  @override
  @JsonKey(name: "shopId")
  final dynamic shopId;
  // Can be String or ShopInfo
  @override
  @JsonKey(name: "createdAt")
  final String? createdAt;
  @override
  @JsonKey(name: "updatedAt")
  final String? updatedAt;
  @override
  @JsonKey(name: "__v")
  final int? v;

  @override
  String toString() {
    return 'UserProductModel(id: $id, name: $name, description: $description, price: $price, mediaUrls: $mediaUrls, category: $category, isAvailable: $isAvailable, shopId: $shopId, createdAt: $createdAt, updatedAt: $updatedAt, v: $v)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProductModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price) &&
            const DeepCollectionEquality().equals(
              other._mediaUrls,
              _mediaUrls,
            ) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            const DeepCollectionEquality().equals(other.shopId, shopId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.v, v) || other.v == v));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    price,
    const DeepCollectionEquality().hash(_mediaUrls),
    category,
    isAvailable,
    const DeepCollectionEquality().hash(shopId),
    createdAt,
    updatedAt,
    v,
  );

  /// Create a copy of UserProductModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProductModelImplCopyWith<_$UserProductModelImpl> get copyWith =>
      __$$UserProductModelImplCopyWithImpl<_$UserProductModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProductModelImplToJson(this);
  }
}

abstract class _UserProductModel implements UserProductModel {
  const factory _UserProductModel({
    @JsonKey(name: "_id") final String? id,
    @JsonKey(name: "name") final String? name,
    @JsonKey(name: "description") final String? description,
    @JsonKey(name: "price") final double? price,
    @JsonKey(name: "mediaUrls") final List<String>? mediaUrls,
    @JsonKey(name: "category") final String? category,
    @JsonKey(name: "isAvailable") final bool isAvailable,
    @JsonKey(name: "shopId") final dynamic shopId,
    @JsonKey(name: "createdAt") final String? createdAt,
    @JsonKey(name: "updatedAt") final String? updatedAt,
    @JsonKey(name: "__v") final int? v,
  }) = _$UserProductModelImpl;

  factory _UserProductModel.fromJson(Map<String, dynamic> json) =
      _$UserProductModelImpl.fromJson;

  @override
  @JsonKey(name: "_id")
  String? get id;
  @override
  @JsonKey(name: "name")
  String? get name;
  @override
  @JsonKey(name: "description")
  String? get description;
  @override
  @JsonKey(name: "price")
  double? get price;
  @override
  @JsonKey(name: "mediaUrls")
  List<String>? get mediaUrls;
  @override
  @JsonKey(name: "category")
  String? get category;
  @override
  @JsonKey(name: "isAvailable")
  bool get isAvailable;
  @override
  @JsonKey(name: "shopId")
  dynamic get shopId; // Can be String or ShopInfo
  @override
  @JsonKey(name: "createdAt")
  String? get createdAt;
  @override
  @JsonKey(name: "updatedAt")
  String? get updatedAt;
  @override
  @JsonKey(name: "__v")
  int? get v;

  /// Create a copy of UserProductModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProductModelImplCopyWith<_$UserProductModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ShopInfo _$ShopInfoFromJson(Map<String, dynamic> json) {
  return _ShopInfo.fromJson(json);
}

/// @nodoc
mixin _$ShopInfo {
  @JsonKey(name: "_id")
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: "name")
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: "logoUrl")
  String? get logoUrl => throw _privateConstructorUsedError;

  /// Serializes this ShopInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShopInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShopInfoCopyWith<ShopInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShopInfoCopyWith<$Res> {
  factory $ShopInfoCopyWith(ShopInfo value, $Res Function(ShopInfo) then) =
      _$ShopInfoCopyWithImpl<$Res, ShopInfo>;
  @useResult
  $Res call({
    @JsonKey(name: "_id") String? id,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "logoUrl") String? logoUrl,
  });
}

/// @nodoc
class _$ShopInfoCopyWithImpl<$Res, $Val extends ShopInfo>
    implements $ShopInfoCopyWith<$Res> {
  _$ShopInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShopInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? logoUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            logoUrl: freezed == logoUrl
                ? _value.logoUrl
                : logoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ShopInfoImplCopyWith<$Res>
    implements $ShopInfoCopyWith<$Res> {
  factory _$$ShopInfoImplCopyWith(
    _$ShopInfoImpl value,
    $Res Function(_$ShopInfoImpl) then,
  ) = __$$ShopInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: "_id") String? id,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "logoUrl") String? logoUrl,
  });
}

/// @nodoc
class __$$ShopInfoImplCopyWithImpl<$Res>
    extends _$ShopInfoCopyWithImpl<$Res, _$ShopInfoImpl>
    implements _$$ShopInfoImplCopyWith<$Res> {
  __$$ShopInfoImplCopyWithImpl(
    _$ShopInfoImpl _value,
    $Res Function(_$ShopInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShopInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? logoUrl = freezed,
  }) {
    return _then(
      _$ShopInfoImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        logoUrl: freezed == logoUrl
            ? _value.logoUrl
            : logoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ShopInfoImpl implements _ShopInfo {
  const _$ShopInfoImpl({
    @JsonKey(name: "_id") this.id,
    @JsonKey(name: "name") this.name,
    @JsonKey(name: "logoUrl") this.logoUrl,
  });

  factory _$ShopInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShopInfoImplFromJson(json);

  @override
  @JsonKey(name: "_id")
  final String? id;
  @override
  @JsonKey(name: "name")
  final String? name;
  @override
  @JsonKey(name: "logoUrl")
  final String? logoUrl;

  @override
  String toString() {
    return 'ShopInfo(id: $id, name: $name, logoUrl: $logoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShopInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, logoUrl);

  /// Create a copy of ShopInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShopInfoImplCopyWith<_$ShopInfoImpl> get copyWith =>
      __$$ShopInfoImplCopyWithImpl<_$ShopInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShopInfoImplToJson(this);
  }
}

abstract class _ShopInfo implements ShopInfo {
  const factory _ShopInfo({
    @JsonKey(name: "_id") final String? id,
    @JsonKey(name: "name") final String? name,
    @JsonKey(name: "logoUrl") final String? logoUrl,
  }) = _$ShopInfoImpl;

  factory _ShopInfo.fromJson(Map<String, dynamic> json) =
      _$ShopInfoImpl.fromJson;

  @override
  @JsonKey(name: "_id")
  String? get id;
  @override
  @JsonKey(name: "name")
  String? get name;
  @override
  @JsonKey(name: "logoUrl")
  String? get logoUrl;

  /// Create a copy of ShopInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShopInfoImplCopyWith<_$ShopInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserProductResponse _$UserProductResponseFromJson(Map<String, dynamic> json) {
  return _UserProductResponse.fromJson(json);
}

/// @nodoc
mixin _$UserProductResponse {
  @JsonKey(name: "status")
  bool? get status => throw _privateConstructorUsedError;
  @JsonKey(name: "code")
  int? get code => throw _privateConstructorUsedError;
  @JsonKey(name: "message")
  String? get message => throw _privateConstructorUsedError;
  @JsonKey(name: "data")
  UserProductModel? get data => throw _privateConstructorUsedError;

  /// Serializes this UserProductResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProductResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProductResponseCopyWith<UserProductResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProductResponseCopyWith<$Res> {
  factory $UserProductResponseCopyWith(
    UserProductResponse value,
    $Res Function(UserProductResponse) then,
  ) = _$UserProductResponseCopyWithImpl<$Res, UserProductResponse>;
  @useResult
  $Res call({
    @JsonKey(name: "status") bool? status,
    @JsonKey(name: "code") int? code,
    @JsonKey(name: "message") String? message,
    @JsonKey(name: "data") UserProductModel? data,
  });

  $UserProductModelCopyWith<$Res>? get data;
}

/// @nodoc
class _$UserProductResponseCopyWithImpl<$Res, $Val extends UserProductResponse>
    implements $UserProductResponseCopyWith<$Res> {
  _$UserProductResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProductResponse
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
                      as UserProductModel?,
          )
          as $Val,
    );
  }

  /// Create a copy of UserProductResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserProductModelCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $UserProductModelCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserProductResponseImplCopyWith<$Res>
    implements $UserProductResponseCopyWith<$Res> {
  factory _$$UserProductResponseImplCopyWith(
    _$UserProductResponseImpl value,
    $Res Function(_$UserProductResponseImpl) then,
  ) = __$$UserProductResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: "status") bool? status,
    @JsonKey(name: "code") int? code,
    @JsonKey(name: "message") String? message,
    @JsonKey(name: "data") UserProductModel? data,
  });

  @override
  $UserProductModelCopyWith<$Res>? get data;
}

/// @nodoc
class __$$UserProductResponseImplCopyWithImpl<$Res>
    extends _$UserProductResponseCopyWithImpl<$Res, _$UserProductResponseImpl>
    implements _$$UserProductResponseImplCopyWith<$Res> {
  __$$UserProductResponseImplCopyWithImpl(
    _$UserProductResponseImpl _value,
    $Res Function(_$UserProductResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserProductResponse
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
      _$UserProductResponseImpl(
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
                  as UserProductModel?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProductResponseImpl implements _UserProductResponse {
  const _$UserProductResponseImpl({
    @JsonKey(name: "status") this.status,
    @JsonKey(name: "code") this.code,
    @JsonKey(name: "message") this.message,
    @JsonKey(name: "data") this.data,
  });

  factory _$UserProductResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProductResponseImplFromJson(json);

  @override
  @JsonKey(name: "status")
  final bool? status;
  @override
  @JsonKey(name: "code")
  final int? code;
  @override
  @JsonKey(name: "message")
  final String? message;
  @override
  @JsonKey(name: "data")
  final UserProductModel? data;

  @override
  String toString() {
    return 'UserProductResponse(status: $status, code: $code, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProductResponseImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status, code, message, data);

  /// Create a copy of UserProductResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProductResponseImplCopyWith<_$UserProductResponseImpl> get copyWith =>
      __$$UserProductResponseImplCopyWithImpl<_$UserProductResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProductResponseImplToJson(this);
  }
}

abstract class _UserProductResponse implements UserProductResponse {
  const factory _UserProductResponse({
    @JsonKey(name: "status") final bool? status,
    @JsonKey(name: "code") final int? code,
    @JsonKey(name: "message") final String? message,
    @JsonKey(name: "data") final UserProductModel? data,
  }) = _$UserProductResponseImpl;

  factory _UserProductResponse.fromJson(Map<String, dynamic> json) =
      _$UserProductResponseImpl.fromJson;

  @override
  @JsonKey(name: "status")
  bool? get status;
  @override
  @JsonKey(name: "code")
  int? get code;
  @override
  @JsonKey(name: "message")
  String? get message;
  @override
  @JsonKey(name: "data")
  UserProductModel? get data;

  /// Create a copy of UserProductResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProductResponseImplCopyWith<_$UserProductResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
