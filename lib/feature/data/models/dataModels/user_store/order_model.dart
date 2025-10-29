class OrderModel {
  final String? id;
  final String? userId;
  final String? storeId;
  final String? productId;
  final int quantity;
  final double? totalAmount;
  final String status;
  final String? trackingNumber;
  final String? address;
  final String? sellerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Populated fields from API
  final String? storeName;
  final String? productName;
  final double? productPrice;
  final String? sellerName;
  final String? sellerEmail;
  final String? buyerName;
  final String? buyerEmail;
  final String? buyerPhone;
  final String? buyerImage;

  OrderModel({
    this.id,
    this.userId,
    this.storeId,
    this.productId,
    this.quantity = 1,
    this.totalAmount,
    this.status = "pending",
    this.trackingNumber,
    this.address,
    this.sellerId,
    this.createdAt,
    this.updatedAt,
    this.storeName,
    this.productName,
    this.productPrice,
    this.sellerName,
    this.sellerEmail,
    this.buyerName,
    this.buyerEmail,
    this.buyerPhone,
    this.buyerImage,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Log the incoming JSON for debugging
    print('==================== OrderModel.fromJson ====================');
    print('Raw JSON: $json');
    print('JSON keys: ${json.keys.toList()}');

    // Debug userId structure
    if (json['userId'] != null) {
      print('userId exists! Type: ${json['userId'].runtimeType}');
      print('userId value: ${json['userId']}');
      if (json['userId'] is Map) {
        print(
          'userId is a Map with keys: ${(json['userId'] as Map).keys.toList()}',
        );
      }
    } else {
      print('⚠️ userId is NULL in the response!');
    }

    // Extract storeId and storeName
    String? storeId;
    String? storeName;
    if (json['storeId'] != null) {
      if (json['storeId'] is Map) {
        storeId = json['storeId']['_id']?.toString();
        storeName = json['storeId']['name']?.toString();
        print('  - storeId (nested): $storeId, storeName: $storeName');
      } else {
        storeId = json['storeId'].toString();
        print('  - storeId (string): $storeId');
      }
    }

    // Extract productId, productName, and productPrice
    String? productId;
    String? productName;
    double? productPrice;
    if (json['productId'] != null) {
      if (json['productId'] is Map) {
        productId = json['productId']['_id']?.toString();
        productName = json['productId']['name']?.toString();

        // Handle productPrice which might be a number or string
        final priceValue = json['productId']['price'];
        if (priceValue != null) {
          if (priceValue is num) {
            productPrice = priceValue.toDouble();
          } else if (priceValue is String) {
            productPrice = double.tryParse(priceValue);
          }
        }

        print(
          '  - productId (nested): $productId, productName: $productName, productPrice: $productPrice',
        );
      } else {
        productId = json['productId'].toString();
        print('  - productId (string): $productId');
      }
    }

    // Extract sellerId, sellerName, and sellerEmail
    String? sellerId;
    String? sellerName;
    String? sellerEmail;
    if (json['sellerId'] != null) {
      if (json['sellerId'] is Map) {
        sellerId = json['sellerId']['_id']?.toString();
        sellerName = json['sellerId']['name']?.toString();
        sellerEmail = json['sellerId']['email']?.toString();
        print('  - sellerId (nested): $sellerId, sellerName: $sellerName');
      } else {
        sellerId = json['sellerId'].toString();
        print('  - sellerId (string): $sellerId');
      }
    }

    // Extract userId (buyer), buyerName, buyerEmail, buyerPhone, and buyerImage
    String? userId;
    String? buyerName;
    String? buyerEmail;
    String? buyerPhone;
    String? buyerImage;
    if (json['userId'] != null) {
      if (json['userId'] is Map) {
        userId = json['userId']['_id']?.toString();
        buyerName = json['userId']['name']?.toString();
        buyerEmail = json['userId']['email']?.toString();
        buyerPhone = json['userId']['phone']?.toString();
        buyerImage = json['userId']['image']?.toString();
        print(
          '  - userId (nested): $userId, buyerName: $buyerName, buyerEmail: $buyerEmail, buyerPhone: $buyerPhone',
        );
      } else {
        userId = json['userId'].toString();
        print('  - userId (string): $userId');
      }
    }

    // Extract dates safely
    DateTime? createdAt;
    DateTime? updatedAt;

    try {
      if (json['createdAt'] != null) {
        createdAt = DateTime.parse(json['createdAt']);
      }
    } catch (e) {
      print('  - Error parsing createdAt: $e');
    }

    try {
      if (json['updatedAt'] != null) {
        updatedAt = DateTime.parse(json['updatedAt']);
      }
    } catch (e) {
      print('  - Error parsing updatedAt: $e');
    }

    final order = OrderModel(
      id: json['id'] ?? json['_id'],
      userId: userId,
      storeId: storeId,
      productId: productId,
      quantity: json['quantity'] ?? 1,
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      status: json['status']?.toString() ?? 'pending',
      trackingNumber: json['trackingNumber']?.toString(),
      address: json['address']?.toString(),
      sellerId: sellerId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      storeName: storeName,
      productName: productName,
      productPrice: productPrice,
      sellerName: sellerName,
      sellerEmail: sellerEmail,
      buyerName: buyerName,
      buyerEmail: buyerEmail,
      buyerPhone: buyerPhone,
      buyerImage: buyerImage,
    );

    print('Created OrderModel:');
    print('  - id: ${order.id}');
    print('  - productName: ${order.productName}');
    print('  - productPrice: ${order.productPrice}');
    print('  - quantity: ${order.quantity}');
    print('  - totalAmount: ${order.totalAmount}');
    print('  - status: ${order.status}');
    print('  - buyerName: ${order.buyerName}');
    print('  - buyerEmail: ${order.buyerEmail}');
    print('  - buyerPhone: ${order.buyerPhone}');
    print('  - buyerImage: ${order.buyerImage}');
    print('================================================================');

    return order;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'storeId': storeId,
      'productId': productId,
      'quantity': quantity,
      'totalAmount': totalAmount,
      'status': status,
      'trackingNumber': trackingNumber,
      'address': address,
      'sellerId': sellerId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    String? storeId,
    String? productId,
    int? quantity,
    double? totalAmount,
    String? status,
    String? trackingNumber,
    String? address,
    String? sellerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? storeName,
    String? productName,
    double? productPrice,
    String? sellerName,
    String? sellerEmail,
    String? buyerName,
    String? buyerEmail,
    String? buyerPhone,
    String? buyerImage,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      storeId: storeId ?? this.storeId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      address: address ?? this.address,
      sellerId: sellerId ?? this.sellerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      storeName: storeName ?? this.storeName,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      sellerName: sellerName ?? this.sellerName,
      sellerEmail: sellerEmail ?? this.sellerEmail,
      buyerName: buyerName ?? this.buyerName,
      buyerEmail: buyerEmail ?? this.buyerEmail,
      buyerPhone: buyerPhone ?? this.buyerPhone,
      buyerImage: buyerImage ?? this.buyerImage,
    );
  }
}

// Response wrapper for API calls
class OrderResponse {
  final bool? status;
  final int? code;
  final String? message;
  final OrderModel? data;

  OrderResponse({this.status, this.code, this.message, this.data});

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null ? OrderModel.fromJson(json['data']) : null,
    );
  }
}

// List response for multiple orders
class OrderListResponse {
  final bool? status;
  final int? code;
  final String? message;
  final OrderListData? data;

  OrderListResponse({this.status, this.code, this.message, this.data});

  factory OrderListResponse.fromJson(Map<String, dynamic> json) {
    return OrderListResponse(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null ? OrderListData.fromJson(json['data']) : null,
    );
  }
}

class OrderListData {
  final List<OrderModel>? orders;
  final int? page;
  final int? limit;
  final int? totalCount;
  final int? totalPages;

  OrderListData({
    this.orders,
    this.page,
    this.limit,
    this.totalCount,
    this.totalPages,
  });

  factory OrderListData.fromJson(Map<String, dynamic> json) {
    print('==================== OrderListData.fromJson ====================');
    print('Raw JSON: $json');
    print('JSON keys: ${json.keys.toList()}');
    print('orders key exists: ${json.containsKey('orders')}');

    // Try to find orders in different possible locations
    List<OrderModel>? ordersList;

    if (json.containsKey('orders') && json['orders'] != null) {
      print('Found orders at json["orders"]');
      print('orders type: ${json['orders'].runtimeType}');
      print('orders value: ${json['orders']}');

      if (json['orders'] is List) {
        ordersList = List<OrderModel>.from(
          json['orders'].map((x) => OrderModel.fromJson(x)),
        );
      }
    } else if (json.containsKey('data') && json['data'] is Map) {
      print('Checking nested data for orders');
      final nestedData = json['data'] as Map<String, dynamic>;
      if (nestedData.containsKey('orders') && nestedData['orders'] != null) {
        print('Found orders at json["data"]["orders"]');
        if (nestedData['orders'] is List) {
          ordersList = List<OrderModel>.from(
            nestedData['orders'].map((x) => OrderModel.fromJson(x)),
          );
        }
      }
    } else {
      print('Orders not found in expected locations');
    }

    print('Parsed ${ordersList?.length ?? 0} orders');
    print('================================================================');

    return OrderListData(
      orders: ordersList,
      page: json['pagination']?['page'] ?? json['data']?['pagination']?['page'],
      limit:
          json['pagination']?['limit'] ?? json['data']?['pagination']?['limit'],
      totalCount:
          json['pagination']?['totalCount'] ??
          json['data']?['pagination']?['totalCount'],
      totalPages:
          json['pagination']?['totalPages'] ??
          json['data']?['pagination']?['totalPages'],
    );
  }
}
