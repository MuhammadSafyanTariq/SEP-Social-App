class UserProductModel {
  final String? id;
  final String? name;
  final String? description;
  final double? price;
  final List<String>? mediaUrls;
  final String? category;
  final bool isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? storeId;
  final String? ownerId;
  final ShopInfo? shopInfo; // For populated shopId from API

  UserProductModel({
    this.id,
    this.name,
    this.description,
    this.price,
    this.mediaUrls,
    this.category,
    this.isAvailable = true,
    this.createdAt,
    this.updatedAt,
    this.storeId,
    this.ownerId,
    this.shopInfo,
  });

  factory UserProductModel.fromJson(Map<String, dynamic> json) {
    // Handle shopId which can be either a String or an Object
    String? storeIdValue;
    ShopInfo? shopInfoValue;

    if (json['shopId'] != null) {
      if (json['shopId'] is String) {
        storeIdValue = json['shopId'];
      } else if (json['shopId'] is Map) {
        shopInfoValue = ShopInfo.fromJson(json['shopId']);
        storeIdValue = shopInfoValue.id;
      }
    } else {
      storeIdValue = json['storeId'];
    }

    return UserProductModel(
      id: json['id'] ?? json['_id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num?)?.toDouble(),
      mediaUrls: json['mediaUrls'] != null
          ? List<String>.from(json['mediaUrls'])
          : null,
      category: json['category'],
      isAvailable: json['isAvailable'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      storeId: storeIdValue,
      ownerId: json['ownerId'],
      shopInfo: shopInfoValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'mediaUrls': mediaUrls,
      'category': category,
      'isAvailable': isAvailable,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'storeId': storeId,
      'ownerId': ownerId,
    };
  }

  UserProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    List<String>? mediaUrls,
    String? category,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? storeId,
    String? ownerId,
    ShopInfo? shopInfo,
  }) {
    return UserProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      storeId: storeId ?? this.storeId,
      ownerId: ownerId ?? this.ownerId,
      shopInfo: shopInfo ?? this.shopInfo,
    );
  }
}

// Response wrapper for API calls
class UserProductResponse {
  final bool? status;
  final int? code;
  final String? message;
  final UserProductModel? data;

  UserProductResponse({this.status, this.code, this.message, this.data});

  factory UserProductResponse.fromJson(Map<String, dynamic> json) {
    return UserProductResponse(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? UserProductModel.fromJson(json['data'])
          : null,
    );
  }
}

// List response for multiple products
class UserProductListResponse {
  final bool? status;
  final int? code;
  final String? message;
  final UserProductListData? data;

  UserProductListResponse({this.status, this.code, this.message, this.data});

  factory UserProductListResponse.fromJson(Map<String, dynamic> json) {
    return UserProductListResponse(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? UserProductListData.fromJson(json['data'])
          : null,
    );
  }
}

class UserProductListData {
  final List<UserProductModel>? products;
  final int? page;
  final int? limit;
  final int? totalCount;
  final int? totalPages;

  UserProductListData({
    this.products,
    this.page,
    this.limit,
    this.totalCount,
    this.totalPages,
  });

  factory UserProductListData.fromJson(Map<String, dynamic> json) {
    // Handle nested structure where API returns: {data: {products: [...], pagination: {...}}}
    final dataWrapper = json['data'];

    // If json['data'] exists and is a Map, extract products and pagination from it
    final productsData = dataWrapper != null && dataWrapper is Map
        ? dataWrapper['products']
        : json['products'];

    final paginationData = dataWrapper != null && dataWrapper is Map
        ? dataWrapper['pagination']
        : json['pagination'] ?? json;

    return UserProductListData(
      products: productsData != null && productsData is List
          ? List<UserProductModel>.from(
              productsData.map((x) => UserProductModel.fromJson(x)),
            )
          : null,
      page: paginationData['page'],
      limit: paginationData['limit'],
      totalCount: paginationData['totalCount'],
      totalPages: paginationData['totalPages'],
    );
  }
}

// Shop info from populated shopId
class ShopInfo {
  final String? id;
  final String? name;
  final String? logoUrl;

  ShopInfo({this.id, this.name, this.logoUrl});

  factory ShopInfo.fromJson(Map<String, dynamic> json) {
    return ShopInfo(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      logoUrl: json['logoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'logoUrl': logoUrl};
  }
}
