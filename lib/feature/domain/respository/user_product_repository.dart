import 'package:sep/feature/data/models/dataModels/responseDataModel.dart';
import 'package:sep/feature/data/models/dataModels/user_store/user_product_model.dart';

abstract class UserProductRepository {
  Future<ResponseData<UserProductModel>> createUserProduct({
    required String name,
    required String description,
    required double price,
    required List<String> mediaUrls,
    String? category,
    bool isAvailable = true,
    String? shopId,
  });

  Future<ResponseData<UserProductModel>> updateUserProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    required List<String> mediaUrls,
    String? category,
    bool isAvailable = true,
  });

  Future<ResponseData<Map<String, dynamic>>> deleteUserProduct({
    required String productId,
  });

  Future<ResponseData<UserProductListData>> getUserProducts({
    int page = 1,
    int limit = 10,
  });

  // Public product endpoints
  Future<ResponseData<UserProductListData>> getAllProducts({
    int page = 1,
    int limit = 20,
  });

  Future<ResponseData<UserProductListData>> getMyProducts({
    int page = 1,
    int limit = 20,
    String? search,
  });

  Future<ResponseData<UserProductListData>> getProductsByShop({
    required String shopId,
    int page = 1,
    int limit = 10,
  });

  Future<ResponseData<UserProductModel>> getProductDetails({
    required String productId,
  });
}
