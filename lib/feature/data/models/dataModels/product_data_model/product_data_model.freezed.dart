// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_data_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProductDataModel _$ProductDataModelFromJson(Map<String, dynamic> json) {
  return _ProductDataModel.fromJson(json);
}

/// @nodoc
mixin _$ProductDataModel {
  @JsonKey(name: "_id")
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: "image")
  List<String>? get images => throw _privateConstructorUsedError;
  @JsonKey(name: "title")
  String? get title => throw _privateConstructorUsedError;
  @JsonKey(name: "description")
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: "price")
  String? get price => throw _privateConstructorUsedError;
  @JsonKey(name: "createdAt")
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: "updatedAt")
  String? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: "checkouturl")
  String? get checkouturl => throw _privateConstructorUsedError;
  @JsonKey(name: "shippingType")
  String? get shippingType => throw _privateConstructorUsedError;
  @JsonKey(name: "__v")
  int? get v => throw _privateConstructorUsedError;

  /// Serializes this ProductDataModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductDataModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductDataModelCopyWith<ProductDataModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductDataModelCopyWith<$Res> {
  factory $ProductDataModelCopyWith(
    ProductDataModel value,
    $Res Function(ProductDataModel) then,
  ) = _$ProductDataModelCopyWithImpl<$Res, ProductDataModel>;
  @useResult
  $Res call({
    @JsonKey(name: "_id") String? id,
    @JsonKey(name: "image") List<String>? images,
    @JsonKey(name: "title") String? title,
    @JsonKey(name: "description") String? description,
    @JsonKey(name: "price") String? price,
    @JsonKey(name: "createdAt") String? createdAt,
    @JsonKey(name: "updatedAt") String? updatedAt,
    @JsonKey(name: "checkouturl") String? checkouturl,
    @JsonKey(name: "shippingType") String? shippingType,
    @JsonKey(name: "__v") int? v,
  });
}

/// @nodoc
class _$ProductDataModelCopyWithImpl<$Res, $Val extends ProductDataModel>
    implements $ProductDataModelCopyWith<$Res> {
  _$ProductDataModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductDataModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? images = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? price = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? checkouturl = freezed,
    Object? shippingType = freezed,
    Object? v = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            images: freezed == images
                ? _value.images
                : images // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            price: freezed == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            checkouturl: freezed == checkouturl
                ? _value.checkouturl
                : checkouturl // ignore: cast_nullable_to_non_nullable
                      as String?,
            shippingType: freezed == shippingType
                ? _value.shippingType
                : shippingType // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ProductDataModelImplCopyWith<$Res>
    implements $ProductDataModelCopyWith<$Res> {
  factory _$$ProductDataModelImplCopyWith(
    _$ProductDataModelImpl value,
    $Res Function(_$ProductDataModelImpl) then,
  ) = __$$ProductDataModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: "_id") String? id,
    @JsonKey(name: "image") List<String>? images,
    @JsonKey(name: "title") String? title,
    @JsonKey(name: "description") String? description,
    @JsonKey(name: "price") String? price,
    @JsonKey(name: "createdAt") String? createdAt,
    @JsonKey(name: "updatedAt") String? updatedAt,
    @JsonKey(name: "checkouturl") String? checkouturl,
    @JsonKey(name: "shippingType") String? shippingType,
    @JsonKey(name: "__v") int? v,
  });
}

/// @nodoc
class __$$ProductDataModelImplCopyWithImpl<$Res>
    extends _$ProductDataModelCopyWithImpl<$Res, _$ProductDataModelImpl>
    implements _$$ProductDataModelImplCopyWith<$Res> {
  __$$ProductDataModelImplCopyWithImpl(
    _$ProductDataModelImpl _value,
    $Res Function(_$ProductDataModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductDataModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? images = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? price = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? checkouturl = freezed,
    Object? shippingType = freezed,
    Object? v = freezed,
  }) {
    return _then(
      _$ProductDataModelImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        images: freezed == images
            ? _value._images
            : images // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        price: freezed == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        checkouturl: freezed == checkouturl
            ? _value.checkouturl
            : checkouturl // ignore: cast_nullable_to_non_nullable
                  as String?,
        shippingType: freezed == shippingType
            ? _value.shippingType
            : shippingType // ignore: cast_nullable_to_non_nullable
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
class _$ProductDataModelImpl implements _ProductDataModel {
  const _$ProductDataModelImpl({
    @JsonKey(name: "_id") this.id,
    @JsonKey(name: "image") final List<String>? images,
    @JsonKey(name: "title") this.title,
    @JsonKey(name: "description") this.description,
    @JsonKey(name: "price") this.price,
    @JsonKey(name: "createdAt") this.createdAt,
    @JsonKey(name: "updatedAt") this.updatedAt,
    @JsonKey(name: "checkouturl") this.checkouturl,
    @JsonKey(name: "shippingType") this.shippingType,
    @JsonKey(name: "__v") this.v,
  }) : _images = images;

  factory _$ProductDataModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductDataModelImplFromJson(json);

  @override
  @JsonKey(name: "_id")
  final String? id;
  final List<String>? _images;
  @override
  @JsonKey(name: "image")
  List<String>? get images {
    final value = _images;
    if (value == null) return null;
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: "title")
  final String? title;
  @override
  @JsonKey(name: "description")
  final String? description;
  @override
  @JsonKey(name: "price")
  final String? price;
  @override
  @JsonKey(name: "createdAt")
  final String? createdAt;
  @override
  @JsonKey(name: "updatedAt")
  final String? updatedAt;
  @override
  @JsonKey(name: "checkouturl")
  final String? checkouturl;
  @override
  @JsonKey(name: "shippingType")
  final String? shippingType;
  @override
  @JsonKey(name: "__v")
  final int? v;

  @override
  String toString() {
    return 'ProductDataModel(id: $id, images: $images, title: $title, description: $description, price: $price, createdAt: $createdAt, updatedAt: $updatedAt, checkouturl: $checkouturl, shippingType: $shippingType, v: $v)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductDataModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.checkouturl, checkouturl) ||
                other.checkouturl == checkouturl) &&
            (identical(other.shippingType, shippingType) ||
                other.shippingType == shippingType) &&
            (identical(other.v, v) || other.v == v));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    const DeepCollectionEquality().hash(_images),
    title,
    description,
    price,
    createdAt,
    updatedAt,
    checkouturl,
    shippingType,
    v,
  );

  /// Create a copy of ProductDataModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductDataModelImplCopyWith<_$ProductDataModelImpl> get copyWith =>
      __$$ProductDataModelImplCopyWithImpl<_$ProductDataModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductDataModelImplToJson(this);
  }
}

abstract class _ProductDataModel implements ProductDataModel {
  const factory _ProductDataModel({
    @JsonKey(name: "_id") final String? id,
    @JsonKey(name: "image") final List<String>? images,
    @JsonKey(name: "title") final String? title,
    @JsonKey(name: "description") final String? description,
    @JsonKey(name: "price") final String? price,
    @JsonKey(name: "createdAt") final String? createdAt,
    @JsonKey(name: "updatedAt") final String? updatedAt,
    @JsonKey(name: "checkouturl") final String? checkouturl,
    @JsonKey(name: "shippingType") final String? shippingType,
    @JsonKey(name: "__v") final int? v,
  }) = _$ProductDataModelImpl;

  factory _ProductDataModel.fromJson(Map<String, dynamic> json) =
      _$ProductDataModelImpl.fromJson;

  @override
  @JsonKey(name: "_id")
  String? get id;
  @override
  @JsonKey(name: "image")
  List<String>? get images;
  @override
  @JsonKey(name: "title")
  String? get title;
  @override
  @JsonKey(name: "description")
  String? get description;
  @override
  @JsonKey(name: "price")
  String? get price;
  @override
  @JsonKey(name: "createdAt")
  String? get createdAt;
  @override
  @JsonKey(name: "updatedAt")
  String? get updatedAt;
  @override
  @JsonKey(name: "checkouturl")
  String? get checkouturl;
  @override
  @JsonKey(name: "shippingType")
  String? get shippingType;
  @override
  @JsonKey(name: "__v")
  int? get v;

  /// Create a copy of ProductDataModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductDataModelImplCopyWith<_$ProductDataModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
