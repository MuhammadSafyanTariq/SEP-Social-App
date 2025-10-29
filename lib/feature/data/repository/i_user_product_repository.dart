import 'package:sep/feature/data/models/dataModels/responseDataModel.dart';
import 'package:sep/feature/data/models/dataModels/user_store/user_product_model.dart';
import 'package:sep/feature/domain/respository/user_product_repository.dart';
import 'package:sep/services/networking/apiMethods.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/extensions/extensions.dart';

class IUserProductRepository implements UserProductRepository {
  final IApiMethod _apiMethod = IApiMethod();

  @override
  Future<ResponseData<UserProductModel>> createUserProduct({
    required String name,
    required String description,
    required double price,
    required List<String> mediaUrls,
    String? category,
    bool isAvailable = true,
    String? shopId,
  }) async {
    try {
      String? authToken = Preferences.authToken?.bearer;

      final body = {
        'name': name,
        'description': description,
        'price': price,
        'mediaUrls': mediaUrls,
        if (category != null) 'category': category,
        'isAvailable': isAvailable,
        if (shopId != null) 'shopId': shopId,
      };

      AppUtils.log('Creating user product with body: $body');

      final result = await _apiMethod.post(
        url: Urls.createUserProduct,
        body: body,
        headers: {'Content-Type': 'application/json'},
        authToken: authToken,
      );

      AppUtils.log('Create user product response: ${result.toJson()}');

      if (result.isSuccess) {
        final productData = result.data;
        if (productData != null) {
          return ResponseData(
            isSuccess: true,
            data: UserProductModel.fromJson(productData),
          );
        } else {
          return ResponseData(
            isSuccess: false,
            error: Exception('Product data is null'),
          );
        }
      } else {
        return ResponseData(
          isSuccess: false,
          error: result.getError ?? Exception('Unknown error'),
        );
      }
    } catch (e) {
      AppUtils.log('Exception in createUserProduct: $e');
      return ResponseData(isSuccess: false, error: Exception(e.toString()));
    }
  }

  @override
  Future<ResponseData<UserProductModel>> updateUserProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    required List<String> mediaUrls,
    String? category,
    bool isAvailable = true,
  }) async {
    try {
      String? authToken = Preferences.authToken?.bearer;

      final body = {
        'title': name, // Based on your API endpoint showing 'title'
        'name': name,
        'description': description,
        'price': price,
        'mediaUrls': mediaUrls,
        if (category != null) 'category': category,
        'isAvailable': isAvailable,
      };

      AppUtils.log('Updating user product $productId with body: $body');

      final result = await _apiMethod.put(
        url: '${Urls.updateUserProduct}/$productId',
        body: body,
        headers: {'Content-Type': 'application/json'},
        authToken: authToken,
      );

      AppUtils.log('Update user product response: ${result.toJson()}');

      if (result.isSuccess) {
        final productData = result.data;
        if (productData != null) {
          return ResponseData(
            isSuccess: true,
            data: UserProductModel.fromJson(productData),
          );
        } else {
          return ResponseData(
            isSuccess: false,
            error: Exception('Product data is null'),
          );
        }
      } else {
        return ResponseData(
          isSuccess: false,
          error: result.getError ?? Exception('Unknown error'),
        );
      }
    } catch (e) {
      AppUtils.log('Exception in updateUserProduct: $e');
      return ResponseData(isSuccess: false, error: Exception(e.toString()));
    }
  }

  @override
  Future<ResponseData<Map<String, dynamic>>> deleteUserProduct({
    required String productId,
  }) async {
    try {
      String? authToken = Preferences.authToken?.bearer;

      AppUtils.log('Deleting user product: $productId');

      final result = await _apiMethod.delete(
        url: '${Urls.deleteUserProduct}/$productId',
        authToken: authToken,
      );

      AppUtils.log('Delete user product response: ${result.toJson()}');

      if (result.isSuccess) {
        return ResponseData(
          isSuccess: true,
          data: result.data ?? {'message': 'Product deleted successfully'},
        );
      } else {
        return ResponseData(
          isSuccess: false,
          error: result.getError ?? Exception('Unknown error'),
        );
      }
    } catch (e) {
      AppUtils.log('Exception in deleteUserProduct: $e');
      return ResponseData(isSuccess: false, error: Exception(e.toString()));
    }
  }

  @override
  Future<ResponseData<UserProductListData>> getUserProducts({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      String? authToken = Preferences.authToken?.bearer;

      AppUtils.log('Getting user products - page: $page, limit: $limit');

      final result = await _apiMethod.get(
        url: Urls.getUserProducts,
        query: {'page': page.toString(), 'limit': limit.toString()},
        authToken: authToken,
      );

      AppUtils.log('Get user products response: ${result.toJson()}');

      if (result.isSuccess) {
        final data = result.data;
        if (data != null) {
          return ResponseData(
            isSuccess: true,
            data: UserProductListData.fromJson(data),
          );
        } else {
          return ResponseData(
            isSuccess: false,
            error: Exception('Products data is null'),
          );
        }
      } else {
        return ResponseData(
          isSuccess: false,
          error: result.getError ?? Exception('Unknown error'),
        );
      }
    } catch (e) {
      AppUtils.log('Exception in getUserProducts: $e');
      return ResponseData(isSuccess: false, error: Exception(e.toString()));
    }
  }

  // Get all products from all users
  Future<ResponseData<UserProductListData>> getAllProducts({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      String? authToken = Preferences.authToken?.bearer;

      AppUtils.log('Getting all products - page: $page, limit: $limit');

      final query = {'page': page.toString(), 'limit': limit.toString()};

      final result = await _apiMethod.get(
        url: Urls.getAllProducts,
        query: query,
        authToken: authToken,
      );

      AppUtils.log('Get all products response: ${result.toJson()}');

      if (result.isSuccess) {
        final data = result.data;
        if (data != null) {
          return ResponseData(
            isSuccess: true,
            data: UserProductListData.fromJson(data),
          );
        } else {
          return ResponseData(
            isSuccess: false,
            error: Exception('Products data is null'),
          );
        }
      } else {
        return ResponseData(
          isSuccess: false,
          error: result.getError ?? Exception('Unknown error'),
        );
      }
    } catch (e) {
      AppUtils.log('Exception in getAllProducts: $e');
      return ResponseData(isSuccess: false, error: Exception(e.toString()));
    }
  }

  @override
  Future<ResponseData<UserProductListData>> getMyProducts({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      String? authToken = Preferences.authToken?.bearer;

      AppUtils.log(
        'Getting my products - page: $page, limit: $limit, search: $search',
      );

      final query = {'page': page.toString(), 'limit': limit.toString()};

      if (search != null && search.isNotEmpty) {
        query['search'] = search;
      }

      final result = await _apiMethod.get(
        url: Urls.getMyProducts,
        query: query,
        authToken: authToken,
      );

      AppUtils.log('Get my products response: ${result.toJson()}');

      if (result.isSuccess) {
        final data = result.data;
        if (data != null) {
          return ResponseData(
            isSuccess: true,
            data: UserProductListData.fromJson(data),
          );
        } else {
          return ResponseData(
            isSuccess: false,
            error: Exception('Products data is null'),
          );
        }
      } else {
        return ResponseData(
          isSuccess: false,
          error: result.getError ?? Exception('Unknown error'),
        );
      }
    } catch (e) {
      AppUtils.log('Exception in getMyProducts: $e');
      return ResponseData(isSuccess: false, error: Exception(e.toString()));
    }
  }

  @override
  Future<ResponseData<UserProductListData>> getProductsByShop({
    required String shopId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      String? authToken = Preferences.authToken?.bearer;

      AppUtils.log(
        'Getting products by shop: $shopId - page: $page, limit: $limit',
      );

      final result = await _apiMethod.get(
        url: '${Urls.getProductsByShop}/$shopId',
        query: {'page': page.toString(), 'limit': limit.toString()},
        authToken: authToken,
      );

      AppUtils.log('Get products by shop response: ${result.toJson()}');

      if (result.isSuccess) {
        final data = result.data;
        if (data != null) {
          return ResponseData(
            isSuccess: true,
            data: UserProductListData.fromJson(data),
          );
        } else {
          return ResponseData(
            isSuccess: false,
            error: Exception('Products data is null'),
          );
        }
      } else {
        return ResponseData(
          isSuccess: false,
          error: result.getError ?? Exception('Unknown error'),
        );
      }
    } catch (e) {
      AppUtils.log('Exception in getProductsByShop: $e');
      return ResponseData(isSuccess: false, error: Exception(e.toString()));
    }
  }

  @override
  Future<ResponseData<UserProductModel>> getProductDetails({
    required String productId,
  }) async {
    try {
      String? authToken = Preferences.authToken?.bearer;

      AppUtils.log('Getting product details: $productId');

      final result = await _apiMethod.get(
        url: '${Urls.getProductDetails}/$productId',
        authToken: authToken,
      );

      AppUtils.log('Get product details response: ${result.toJson()}');

      if (result.isSuccess) {
        final productData = result.data?['data'];
        if (productData != null) {
          return ResponseData(
            isSuccess: true,
            data: UserProductModel.fromJson(productData),
          );
        } else {
          return ResponseData(
            isSuccess: false,
            error: Exception('Product data is null'),
          );
        }
      } else {
        return ResponseData(
          isSuccess: false,
          error: result.getError ?? Exception('Unknown error'),
        );
      }
    } catch (e) {
      AppUtils.log('Exception in getProductDetails: $e');
      return ResponseData(isSuccess: false, error: Exception(e.toString()));
    }
  }
}
