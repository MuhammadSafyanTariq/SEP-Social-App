import 'package:sep/feature/data/models/dataModels/responseDataModel.dart';
import 'package:sep/feature/data/models/dataModels/user_store/order_model.dart';

abstract class OrderRepository {
  Future<ResponseData<OrderModel>> createOrder({
    required String userId,
    required String storeId,
    required String productId,
    required int quantity,
    required double totalAmount,
    required String status,
    String? trackingNumber,
    String? address,
  });

  Future<ResponseData<OrderListData>> getMyOrders({
    int page = 1,
    int limit = 20,
  });

  Future<ResponseData<OrderListData>> getSellerOrders({
    int page = 1,
    int limit = 20,
  });

  Future<ResponseData<OrderModel>> updateOrderStatus({
    required String orderId,
    required String status,
    String? trackingNumber,
  });

  Future<ResponseData<OrderModel>> cancelOrder({required String orderId});

  Future<ResponseData<OrderModel>> markOrderAsCompleted({
    required String orderId,
  });

  Future<ResponseData<OrderModel>> acceptOrder({required String orderId});

  Future<ResponseData<OrderModel>> rejectOrder({required String orderId});

  Future<ResponseData<OrderModel>> markAsShipped({
    required String orderId,
    required String trackingNumber,
  });

  Future<ResponseData<OrderModel>> getOrderById({required String orderId});
}
