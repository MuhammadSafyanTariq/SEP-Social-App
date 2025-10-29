import 'package:sep/feature/data/models/dataModels/responseDataModel.dart';
import 'package:sep/feature/data/models/dataModels/user_store/user_store_model.dart';

abstract class ShopRepository {
  Future<ResponseData<UserStoreModel>> createShop({
    required String name,
    required String description,
    String? logoUrl,
    String? address,
    String? contactEmail,
    String? contactPhone,
    String? ownerId,
  });

  Future<ResponseData<UserStoreModel>> updateShop({
    required String shopId,
    required String name,
    required String description,
    String? logoUrl,
    String? address,
    String? contactEmail,
    String? contactPhone,
    String? ownerId,
  });

  Future<ResponseData<bool>> deleteShop({required String shopId});

  Future<ResponseData<UserStoreModel>> getMyShop();

  // Public shop endpoints
  Future<ResponseData<UserStoreListData>> getAllShops({
    int page = 1,
    int limit = 20,
  });

  Future<ResponseData<UserStoreModel>> getShopById({required String shopId});
}
