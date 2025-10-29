import 'package:sep/feature/data/models/dataModels/responseDataModel.dart';
import 'package:sep/feature/data/models/dataModels/user_store/order_model.dart';
import 'package:sep/feature/domain/respository/order_repository.dart';
import 'package:sep/services/networking/apiMethods.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/extensions/extensions.dart';

class IOrderRepository implements OrderRepository {
  final IApiMethod _apiMethod = IApiMethod();

  @override
  Future<ResponseData<OrderModel>> createOrder({
    required String userId,
    required String storeId,
    required String productId,
    required int quantity,
    required double totalAmount,
    required String status,
    String? trackingNumber,
    String? address,
  }) async {
    try {
      String? authToken = Preferences.authToken?.bearer;

      final body = {
        'userId': userId,
        'storeId': storeId,
        'productId': productId,
        'quantity': quantity,
        'totalAmount': totalAmount,
        'status': status,
        if (trackingNumber != null) 'trackingNumber': trackingNumber,
        if (address != null) 'address': address,
      };

      AppUtils.log('Creating order with body: $body');

      final result = await _apiMethod.post(
        url: Urls.createOrder,
        body: body,
        headers: {'Content-Type': 'application/json'},
        authToken: authToken,
      );

      AppUtils.log('Create order response: ${result.toJson()}');

      if (result.isSuccess) {
        final orderData = result.data;
        if (orderData != null) {
          return ResponseData(
            isSuccess: true,
            data: OrderModel.fromJson(orderData),
          );
        } else {
          return ResponseData(
            isSuccess: false,
            error: Exception('Order data is null'),
          );
        }
      } else {
        return ResponseData(
          isSuccess: false,
          error: result.getError ?? Exception('Unknown error'),
        );
      }
    } catch (e) {
      AppUtils.log('Exception in createOrder: $e');
      return ResponseData(isSuccess: false, error: Exception(e.toString()));
    }
  }

  @override
  Future<ResponseData<OrderListData>> getMyOrders({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      String? authToken = Preferences.authToken?.bearer;

      final queryParams = {'page': page.toString(), 'limit': limit.toString()};

      final result = await _apiMethod.get(
        url: Urls.getMyOrders,
        query: queryParams,
        authToken: authToken,
      );

      AppUtils.log(
        '==================== GET MY ORDERS RESPONSE ====================',
      );
      AppUtils.log('Full response JSON: ${result.toJson()}');
      AppUtils.log('Response isSuccess: ${result.isSuccess}');
      AppUtils.log('Response data type: ${result.data.runtimeType}');
      AppUtils.log('Response data: ${result.data}');

      // Check if response has nested 'data' key
      if (result.data != null && result.data is Map) {
        final responseMap = result.data as Map<String, dynamic>;
        AppUtils.log('Response map keys: ${responseMap.keys.toList()}');

        if (responseMap.containsKey('data')) {
          AppUtils.log('Response has nested "data" key');
          AppUtils.log('Nested data: ${responseMap['data']}');
        }
      }
      AppUtils.log(
        '================================================================',
      );

      if (result.isSuccess) {
        final ordersData = result.data;
        if (ordersData != null) {
          AppUtils.log('Parsing OrderListData from: $ordersData');

          // Check if data is wrapped in a 'data' key
          Map<String, dynamic> dataToUse = ordersData;
          if (ordersData.containsKey('data') && ordersData['data'] is Map) {
            AppUtils.log('Unwrapping nested data object');
            dataToUse = ordersData['data'] as Map<String, dynamic>;
          }

          final orderListData = OrderListData.fromJson(dataToUse);
          AppUtils.log('Parsed ${orderListData.orders?.length ?? 0} orders');

          // Log each order's details
          orderListData.orders?.forEach((order) {
            AppUtils.log('Order ID: ${order.id}');
            AppUtils.log('  - productName: ${order.productName}');
            AppUtils.log('  - productPrice: ${order.productPrice}');
            AppUtils.log('  - quantity: ${order.quantity}');
            AppUtils.log('  - totalAmount: ${order.totalAmount}');
          });

          return ResponseData(isSuccess: true, data: orderListData);
        } else {
          return ResponseData(
            isSuccess: false,
            error: Exception('Orders data is null'),
          );
        }
      } else {
        return ResponseData(
          isSuccess: false,
          error: result.getError ?? Exception('Unknown error'),
        );
      }
    } catch (e) {
      AppUtils.log('Exception in getMyOrders: $e');
      return ResponseData(isSuccess: false, error: Exception(e.toString()));
    }
  }

  @override
  Future<ResponseData<OrderListData>> getSellerOrders({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      String? authToken = Preferences.authToken?.bearer;

      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'populate':
            'userId,productId,storeId,sellerId', // Request populated fields
      };

      AppUtils.log(
        '==================== GET SELLER ORDERS REQUEST ====================',
      );
      AppUtils.log('URL: ${Urls.getSellerOrders}');
      AppUtils.log('Query Params: $queryParams');
      AppUtils.log('Auth Token: ${authToken != null ? "Present" : "Missing"}');

      final result = await _apiMethod.get(
        url: Urls.getSellerOrders,
        query: queryParams,
        authToken: authToken,
      );

      AppUtils.log(
        '==================== GET SELLER ORDERS RESPONSE ====================',
      );
      AppUtils.log('Full response JSON: ${result.toJson()}');
      AppUtils.log('Response isSuccess: ${result.isSuccess}');
      AppUtils.log('Response status code: ${result.statusCode}');
      AppUtils.log('Response data type: ${result.data.runtimeType}');
      AppUtils.log('Response data: ${result.data}');

      // Check if response has nested 'data' key
      if (result.data != null && result.data is Map) {
        final responseMap = result.data as Map<String, dynamic>;
        AppUtils.log('Response map keys: ${responseMap.keys.toList()}');

        if (responseMap.containsKey('data')) {
          AppUtils.log('Response has nested "data" key');
          AppUtils.log('Nested data: ${responseMap['data']}');
        }
      }
      AppUtils.log(
        '================================================================',
      );

      if (result.isSuccess) {
        final ordersData = result.data;
        if (ordersData != null) {
          AppUtils.log('Parsing OrderListData from: $ordersData');

          // Check if data is wrapped in a 'data' key
          Map<String, dynamic> dataToUse = ordersData;
          if (ordersData.containsKey('data') && ordersData['data'] is Map) {
            AppUtils.log('Unwrapping nested data object');
            dataToUse = ordersData['data'] as Map<String, dynamic>;
          }

          final orderListData = OrderListData.fromJson(dataToUse);
          AppUtils.log(
            'Parsed ${orderListData.orders?.length ?? 0} seller orders',
          );

          // Log each order's details
          orderListData.orders?.forEach((order) {
            AppUtils.log('Seller Order ID: ${order.id}');
            AppUtils.log('  - productName: ${order.productName}');
            AppUtils.log('  - buyerName: ${order.sellerName}');
            AppUtils.log('  - quantity: ${order.quantity}');
            AppUtils.log('  - totalAmount: ${order.totalAmount}');
            AppUtils.log('  - status: ${order.status}');
          });

          return ResponseData(isSuccess: true, data: orderListData);
        } else {
          AppUtils.log('ERROR: Orders data is null');
          return ResponseData(
            isSuccess: false,
            error: Exception('Orders data is null'),
          );
        }
      } else {
        AppUtils.log('ERROR: API call failed - ${result.getError}');
        return ResponseData(
          isSuccess: false,
          error: result.getError ?? Exception('Unknown error'),
        );
      }
    } catch (e, stackTrace) {
      AppUtils.log('EXCEPTION in getSellerOrders: $e');
      AppUtils.log('Stack trace: $stackTrace');
      return ResponseData(isSuccess: false, error: Exception(e.toString()));
    }
  }

  @override
  Future<ResponseData<OrderModel>> updateOrderStatus({
    required String orderId,
    required String status,
    String? trackingNumber,
  }) async {
    try {
      String? authToken = Preferences.authToken?.bearer;

      final body = {
        'status': status,
        if (trackingNumber != null) 'trackingNumber': trackingNumber,
      };

      AppUtils.log('Updating order $orderId with body: $body');

      final result = await _apiMethod.put(
        url: '${Urls.updateOrder}/$orderId',
        body: body,
        headers: {'Content-Type': 'application/json'},
        authToken: authToken,
      );

      AppUtils.log('Update order response: ${result.toJson()}');

      if (result.isSuccess) {
        final orderData = result.data;
        if (orderData != null) {
          return ResponseData(
            isSuccess: true,
            data: OrderModel.fromJson(orderData),
          );
        } else {
          return ResponseData(
            isSuccess: false,
            error: Exception('Order data is null'),
          );
        }
      } else {
        return ResponseData(
          isSuccess: false,
          error: result.getError ?? Exception('Unknown error'),
        );
      }
    } catch (e) {
      AppUtils.log('Exception in updateOrderStatus: $e');
      return ResponseData(isSuccess: false, error: Exception(e.toString()));
    }
  }

  @override
  Future<ResponseData<OrderModel>> cancelOrder({
    required String orderId,
  }) async {
    try {
      String? authToken = Preferences.authToken?.bearer;

      AppUtils.log('Cancelling order: $orderId');
      AppUtils.log('Cancel URL: ${Urls.cancelOrder}');

      final body = {'orderId': orderId};

      AppUtils.log('Cancel order body: $body');

      final result = await _apiMethod.post(
        url: Urls.cancelOrder,
        body: body,
        headers: {'Content-Type': 'application/json'},
        authToken: authToken,
      );

      AppUtils.log('Cancel order response: ${result.toJson()}');
      AppUtils.log('Response status code: ${result.statusCode}');

      if (result.isSuccess) {
        final responseData = result.data;
        if (responseData != null) {
          // Check if response has nested 'data' key
          final orderData = responseData.containsKey('data')
              ? responseData['data']
              : responseData;

          return ResponseData(
            isSuccess: true,
            data: OrderModel.fromJson(orderData),
          );
        } else {
          return ResponseData(
            isSuccess: false,
            error: Exception('Order data is null'),
          );
        }
      } else {
        return ResponseData(
          isSuccess: false,
          error: result.getError ?? Exception('Unknown error'),
        );
      }
    } catch (e) {
      AppUtils.log('Exception in cancelOrder: $e');
      return ResponseData(isSuccess: false, error: Exception(e.toString()));
    }
  }

  @override
  Future<ResponseData<OrderModel>> markOrderAsCompleted({
    required String orderId,
  }) async {
    try {
      String? authToken = Preferences.authToken?.bearer;

      AppUtils.log('Marking order as completed: $orderId');
      AppUtils.log('Mark completed URL: ${Urls.markOrderCompleted}');

      final body = {'orderId': orderId};

      AppUtils.log('Mark order as completed body: $body');

      final result = await _apiMethod.post(
        url: Urls.markOrderCompleted,
        body: body,
        headers: {'Content-Type': 'application/json'},
        authToken: authToken,
      );

      AppUtils.log('Mark order as completed response: ${result.toJson()}');
      AppUtils.log('Response status code: ${result.statusCode}');

      if (result.isSuccess) {
        final responseData = result.data;
        if (responseData != null) {
          // Check if response has nested 'data' key
          final orderData = responseData.containsKey('data')
              ? responseData['data']
              : responseData;

          return ResponseData(
            isSuccess: true,
            data: OrderModel.fromJson(orderData),
          );
        } else {
          return ResponseData(
            isSuccess: false,
            error: Exception('Order data is null'),
          );
        }
      } else {
        return ResponseData(
          isSuccess: false,
          error: result.getError ?? Exception('Unknown error'),
        );
      }
    } catch (e) {
      AppUtils.log('Exception in markOrderAsCompleted: $e');
      return ResponseData(isSuccess: false, error: Exception(e.toString()));
    }
  }

  @override
  Future<ResponseData<OrderModel>> getOrderById({
    required String orderId,
  }) async {
    try {
      String? authToken = Preferences.authToken?.bearer;

      final result = await _apiMethod.get(
        url: '${Urls.getOrderById}/$orderId',
        authToken: authToken,
      );

      AppUtils.log('Get order by ID response: ${result.toJson()}');

      if (result.isSuccess) {
        final orderData = result.data;
        if (orderData != null) {
          return ResponseData(
            isSuccess: true,
            data: OrderModel.fromJson(orderData),
          );
        } else {
          return ResponseData(
            isSuccess: false,
            error: Exception('Order data is null'),
          );
        }
      } else {
        return ResponseData(
          isSuccess: false,
          error: result.getError ?? Exception('Unknown error'),
        );
      }
    } catch (e) {
      AppUtils.log('Exception in getOrderById: $e');
      return ResponseData(isSuccess: false, error: Exception(e.toString()));
    }
  }

  @override
  Future<ResponseData<OrderModel>> acceptOrder({
    required String orderId,
  }) async {
    try {
      String? authToken = Preferences.authToken?.bearer;

      AppUtils.log('Accepting order: $orderId');
      AppUtils.log('Accept URL: ${Urls.acceptOrder}');

      final body = {'orderId': orderId};

      AppUtils.log('Accept order body: $body');

      final result = await _apiMethod.post(
        url: Urls.acceptOrder,
        body: body,
        headers: {'Content-Type': 'application/json'},
        authToken: authToken,
      );

      AppUtils.log('Accept order response: ${result.toJson()}');
      AppUtils.log('Response status code: ${result.statusCode}');

      if (result.isSuccess) {
        final responseData = result.data;
        if (responseData != null) {
          // Check if response has nested 'data' key
          final orderData = responseData.containsKey('data')
              ? responseData['data']
              : responseData;

          return ResponseData(
            isSuccess: true,
            data: OrderModel.fromJson(orderData),
          );
        } else {
          return ResponseData(
            isSuccess: false,
            error: Exception('Order data is null'),
          );
        }
      } else {
        return ResponseData(
          isSuccess: false,
          error: result.getError ?? Exception('Unknown error'),
        );
      }
    } catch (e) {
      AppUtils.log('Exception in acceptOrder: $e');
      return ResponseData(isSuccess: false, error: Exception(e.toString()));
    }
  }

  @override
  Future<ResponseData<OrderModel>> rejectOrder({
    required String orderId,
  }) async {
    try {
      String? authToken = Preferences.authToken?.bearer;

      AppUtils.log('Rejecting order: $orderId');
      AppUtils.log('Reject URL: ${Urls.rejectOrder}');

      final body = {'orderId': orderId};

      AppUtils.log('Reject order body: $body');

      final result = await _apiMethod.post(
        url: Urls.rejectOrder,
        body: body,
        headers: {'Content-Type': 'application/json'},
        authToken: authToken,
      );

      AppUtils.log('Reject order response: ${result.toJson()}');
      AppUtils.log('Response status code: ${result.statusCode}');

      if (result.isSuccess) {
        final responseData = result.data;
        if (responseData != null) {
          // Check if response has nested 'data' key
          final orderData = responseData.containsKey('data')
              ? responseData['data']
              : responseData;

          return ResponseData(
            isSuccess: true,
            data: OrderModel.fromJson(orderData),
          );
        } else {
          return ResponseData(
            isSuccess: false,
            error: Exception('Order data is null'),
          );
        }
      } else {
        return ResponseData(
          isSuccess: false,
          error: result.getError ?? Exception('Unknown error'),
        );
      }
    } catch (e) {
      AppUtils.log('Exception in rejectOrder: $e');
      return ResponseData(isSuccess: false, error: Exception(e.toString()));
    }
  }

  @override
  Future<ResponseData<OrderModel>> markAsShipped({
    required String orderId,
    required String trackingNumber,
  }) async {
    try {
      String? authToken = Preferences.authToken?.bearer;

      AppUtils.log('Marking order as shipped: $orderId');
      AppUtils.log('Mark shipped URL: ${Urls.markShipped}');
      AppUtils.log('Tracking number: $trackingNumber');

      final body = {'orderId': orderId, 'trackingNumber': trackingNumber};

      AppUtils.log('Mark shipped body: $body');

      final result = await _apiMethod.post(
        url: Urls.markShipped,
        body: body,
        headers: {'Content-Type': 'application/json'},
        authToken: authToken,
      );

      AppUtils.log('Mark shipped response: ${result.toJson()}');
      AppUtils.log('Response status code: ${result.statusCode}');

      if (result.isSuccess) {
        final responseData = result.data;
        if (responseData != null) {
          // Check if response has nested 'data' key
          final orderData = responseData.containsKey('data')
              ? responseData['data']
              : responseData;

          return ResponseData(
            isSuccess: true,
            data: OrderModel.fromJson(orderData),
          );
        } else {
          return ResponseData(
            isSuccess: false,
            error: Exception('Order data is null'),
          );
        }
      } else {
        return ResponseData(
          isSuccess: false,
          error: result.getError ?? Exception('Unknown error'),
        );
      }
    } catch (e) {
      AppUtils.log('Exception in markAsShipped: $e');
      return ResponseData(isSuccess: false, error: Exception(e.toString()));
    }
  }
}
