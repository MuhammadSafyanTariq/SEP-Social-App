class UserStoreModel {
  final String? id;
  final String? name;
  final String? ownerId;
  final String? description;
  final String? logoUrl;
  final String? address;
  final String? contactEmail;
  final String? contactPhone;
  final List<String>? products;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserStoreModel({
    this.id,
    this.name,
    this.ownerId,
    this.description,
    this.logoUrl,
    this.address,
    this.contactEmail,
    this.contactPhone,
    this.products,
    this.createdAt,
    this.updatedAt,
  });

  factory UserStoreModel.fromJson(Map<String, dynamic> json) {
    return UserStoreModel(
      id: json['id'] ?? json['_id'],
      name: json['name'],
      // Handle ownerId which can be either a string or an object with _id
      ownerId: json['ownerId'] is String
          ? json['ownerId']
          : (json['ownerId'] is Map ? json['ownerId']['_id'] : null),
      description: json['description'],
      logoUrl: json['logoUrl'],
      address: json['address'],
      contactEmail: json['contactEmail'],
      contactPhone: json['contactPhone'],
      products: json['products'] != null
          ? List<String>.from(
              (json['products'] as List).map((product) {
                // Handle both String IDs and product objects with _id field
                return product is String ? product : product['_id'];
              }),
            )
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'description': description,
      'logoUrl': logoUrl,
      'address': address,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'products': products,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserStoreModel copyWith({
    String? id,
    String? name,
    String? ownerId,
    String? description,
    String? logoUrl,
    String? address,
    String? contactEmail,
    String? contactPhone,
    List<String>? products,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserStoreModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      address: address ?? this.address,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      products: products ?? this.products,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Response wrapper for API calls
class UserStoreResponse {
  final bool? status;
  final int? code;
  final String? message;
  final UserStoreModel? data;

  UserStoreResponse({this.status, this.code, this.message, this.data});

  factory UserStoreResponse.fromJson(Map<String, dynamic> json) {
    return UserStoreResponse(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null ? UserStoreModel.fromJson(json['data']) : null,
    );
  }
}

// List response for multiple stores
class UserStoreListResponse {
  final bool? status;
  final int? code;
  final String? message;
  final UserStoreListData? data;

  UserStoreListResponse({this.status, this.code, this.message, this.data});

  factory UserStoreListResponse.fromJson(Map<String, dynamic> json) {
    return UserStoreListResponse(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? UserStoreListData.fromJson(json['data'])
          : null,
    );
  }
}

class UserStoreListData {
  final List<UserStoreModel>? stores;
  final int? page;
  final int? limit;
  final int? totalCount;
  final int? totalPages;

  UserStoreListData({
    this.stores,
    this.page,
    this.limit,
    this.totalCount,
    this.totalPages,
  });

  factory UserStoreListData.fromJson(Map<String, dynamic> json) {
    return UserStoreListData(
      stores: json['data'] != null
          ? List<UserStoreModel>.from(
              json['data'].map((x) => UserStoreModel.fromJson(x)),
            )
          : null,
      page: json['page'],
      limit: json['limit'],
      totalCount: json['totalCount'],
      totalPages: json['totalPages'],
    );
  }
}
