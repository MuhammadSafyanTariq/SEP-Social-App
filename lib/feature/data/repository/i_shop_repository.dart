import 'package:sep/feature/data/models/dataModels/responseDataModel.dart';
import 'package:sep/feature/data/models/dataModels/user_store/user_store_model.dart';
import 'package:sep/feature/domain/respository/shop_repository.dart';
import 'package:sep/services/networking/apiMethods.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/extensions.dart';

class IShopRepository implements ShopRepository {
  final IApiMethod _apiMethod = IApiMethod();

  @override
  Future<ResponseData<UserStoreModel>> createShop({
    required String name,
    required String description,
    String? logoUrl,
    String? address,
    String? contactEmail,
    String? contactPhone,
    String? ownerId,
  }) async {
    try {
      String? authToken = Preferences.authToken?.bearer;

      final body = {
        'name': name,
        'description': description,
        if (logoUrl != null && logoUrl.isNotEmpty) 'logoUrl': logoUrl,
        if (address != null && address.isNotEmpty) 'address': address,
        if (contactEmail != null && contactEmail.isNotEmpty)
          'contactEmail': contactEmail,
        if (contactPhone != null && contactPhone.isNotEmpty)
          'contactPhone': contactPhone,
        if (ownerId != null && ownerId.isNotEmpty) 'ownerId': ownerId,
      };

      AppUtils.log("Creating shop with body: $body");

      final response = await _apiMethod.post(
        url: Urls.createShop,
        body: body,
        headers: {'Content-Type': 'application/json'},
        authToken: authToken,
      );

      AppUtils.log("Create Shop Response isSuccess: ${response.isSuccess}");
      AppUtils.log("Create Shop Response data: ${response.data}");
      AppUtils.log("Create Shop Response statusCode: ${response.statusCode}");
      AppUtils.log("Create Shop Response error: ${response.error}");

      if (response.isSuccess && response.data != null) {
        final shopData = response.data?['data'];
        AppUtils.log("Shop data extracted: $shopData");

        if (shopData != null) {
          final shop = UserStoreModel.fromJson(shopData);
          AppUtils.log("Shop model created: ${shop.name}");
          return ResponseData<UserStoreModel>(isSuccess: true, data: shop);
        } else {
          AppUtils.log("Shop data is null in response.data");
        }
      } else {
        AppUtils.log(
          "Response failed - isSuccess: ${response.isSuccess}, data: ${response.data}",
        );
      }

      // Check if error message indicates user already has a store
      final errorMessage = response.error?.toString() ?? '';
      if (errorMessage.toLowerCase().contains('already has an active shop')) {
        AppUtils.log("User already has a shop, fetching existing shop...");
        // Fetch the existing shop
        return await getMyShop();
      }

      return ResponseData<UserStoreModel>(
        isSuccess: false,
        error: Exception(response.error?.toString() ?? 'Failed to create shop'),
      );
    } catch (e) {
      AppUtils.log("Error creating shop: $e");
      return ResponseData<UserStoreModel>(
        isSuccess: false,
        exception: Exception(e.toString()),
      );
    }
  }

  @override
  Future<ResponseData<UserStoreModel>> updateShop({
    required String shopId,
    required String name,
    required String description,
    String? logoUrl,
    String? address,
    String? contactEmail,
    String? contactPhone,
    String? ownerId,
  }) async {
    try {
      String? authToken = Preferences.authToken?.bearer;

      final body = {
        'name': name,
        'description': description,
        if (logoUrl != null && logoUrl.isNotEmpty) 'logoUrl': logoUrl,
        if (address != null && address.isNotEmpty) 'address': address,
        if (contactEmail != null && contactEmail.isNotEmpty)
          'contactEmail': contactEmail,
        if (contactPhone != null && contactPhone.isNotEmpty)
          'contactPhone': contactPhone,
        if (ownerId != null && ownerId.isNotEmpty) 'ownerId': ownerId,
      };

      AppUtils.log("Updating shop $shopId with body: $body");

      final response = await _apiMethod.put(
        url: '${Urls.updateShop}/$shopId',
        body: body,
        headers: {'Content-Type': 'application/json'},
        authToken: authToken,
      );

      AppUtils.log("Update Shop Response: ${response.data}");

      if (response.isSuccess && response.data != null) {
        final shopData = response.data?['data'];
        if (shopData != null) {
          final shop = UserStoreModel.fromJson(shopData);
          return ResponseData<UserStoreModel>(isSuccess: true, data: shop);
        }
      }

      return ResponseData<UserStoreModel>(
        isSuccess: false,
        error: Exception(response.error?.toString() ?? 'Failed to update shop'),
      );
    } catch (e) {
      AppUtils.log("Error updating shop: $e");
      return ResponseData<UserStoreModel>(
        isSuccess: false,
        exception: Exception(e.toString()),
      );
    }
  }

  @override
  Future<ResponseData<bool>> deleteShop({required String shopId}) async {
    try {
      String? authToken = Preferences.authToken?.bearer;

      AppUtils.log("Deleting shop with ID: $shopId");

      final response = await _apiMethod.delete(
        url: '${Urls.deleteShop}/$shopId',
        authToken: authToken,
      );

      AppUtils.log("Delete Shop Response: ${response.data}");

      if (response.isSuccess) {
        return ResponseData<bool>(isSuccess: true, data: true);
      }

      return ResponseData<bool>(
        isSuccess: false,
        error: Exception(response.error?.toString() ?? 'Failed to delete shop'),
      );
    } catch (e) {
      AppUtils.log("Error deleting shop: $e");
      return ResponseData<bool>(
        isSuccess: false,
        exception: Exception(e.toString()),
      );
    }
  }

  @override
  Future<ResponseData<UserStoreModel>> getMyShop() async {
    try {
      String? authToken = Preferences.authToken?.bearer;

      AppUtils.log(
        "Fetching my shop with token: ${authToken != null ? 'Present' : 'Missing'}",
      );

      final response = await _apiMethod.get(
        url: Urls.getMyShop,
        authToken: authToken,
      );

      AppUtils.log("Get My Shop Response: ${response.data}");
      AppUtils.log("Get My Shop IsSuccess: ${response.isSuccess}");
      AppUtils.log("Get My Shop Error: ${response.error}");

      if (response.isSuccess && response.data != null) {
        // The shop data is directly in 'data', not in 'data.data'
        final shopData = response.data?['data'];
        AppUtils.log("Shop data from response: $shopData");

        if (shopData != null && shopData is Map<String, dynamic>) {
          final shop = UserStoreModel.fromJson(shopData);
          AppUtils.log("Successfully parsed shop: ${shop.name}");
          return ResponseData<UserStoreModel>(isSuccess: true, data: shop);
        } else {
          AppUtils.log("Shop data is null or invalid format in response");
        }
      }

      return ResponseData<UserStoreModel>(
        isSuccess: false,
        error: Exception(response.error?.toString() ?? 'Failed to fetch shop'),
      );
    } catch (e, stackTrace) {
      AppUtils.log("Error fetching shop: $e");
      AppUtils.log("Stack trace: $stackTrace");
      return ResponseData<UserStoreModel>(
        isSuccess: false,
        exception: Exception(e.toString()),
      );
    }
  }

  @override
  Future<ResponseData<UserStoreListData>> getAllShops({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      AppUtils.log("Fetching all shops - page: $page, limit: $limit");

      final response = await _apiMethod.get(
        url: Urls.getAllShops,
        query: {'page': page.toString(), 'limit': limit.toString()},
      );

      AppUtils.log("Get All Shops Response: ${response.data}");

      if (response.isSuccess && response.data != null) {
        return ResponseData<UserStoreListData>(
          isSuccess: true,
          data: UserStoreListData.fromJson(response.data!),
        );
      }

      return ResponseData<UserStoreListData>(
        isSuccess: false,
        error: Exception(response.error?.toString() ?? 'Failed to fetch shops'),
      );
    } catch (e) {
      AppUtils.log("Error fetching all shops: $e");
      return ResponseData<UserStoreListData>(
        isSuccess: false,
        exception: Exception(e.toString()),
      );
    }
  }

  @override
  Future<ResponseData<UserStoreModel>> getShopById({
    required String shopId,
  }) async {
    try {
      String? authToken = Preferences.authToken?.bearer;

      AppUtils.log("Fetching shop by ID: $shopId");

      final response = await _apiMethod.get(
        url: '${Urls.getShopById}/$shopId',
        authToken: authToken,
      );

      AppUtils.log("Get Shop By ID Response: ${response.data}");

      if (response.isSuccess && response.data != null) {
        final shopData = response.data?['data'];
        if (shopData != null) {
          AppUtils.log("Shop data before parsing: $shopData");
          AppUtils.log("Shop data type: ${shopData.runtimeType}");
          final shop = UserStoreModel.fromJson(shopData);
          return ResponseData<UserStoreModel>(isSuccess: true, data: shop);
        }
      }

      return ResponseData<UserStoreModel>(
        isSuccess: false,
        error: Exception(response.error?.toString() ?? 'Failed to fetch shop'),
      );
    } catch (e, stackTrace) {
      AppUtils.log("Error fetching shop by ID: $e");
      AppUtils.log("Stack trace: $stackTrace");
      return ResponseData<UserStoreModel>(
        isSuccess: false,
        exception: Exception(e.toString()),
      );
    }
  }
}
