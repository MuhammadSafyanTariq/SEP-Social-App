import 'package:get/get.dart';
import 'package:sep/feature/data/models/dataModels/user_store/user_store_model.dart';
import 'package:sep/feature/data/models/dataModels/user_store/user_product_model.dart';
import 'package:sep/feature/data/models/dataModels/user_store/order_model.dart';
import 'package:sep/feature/data/repository/i_user_product_repository.dart';
import 'package:sep/feature/data/repository/i_shop_repository.dart';
import 'package:sep/feature/data/repository/i_order_repository.dart';
import 'package:sep/feature/domain/respository/user_product_repository.dart';
import 'package:sep/feature/domain/respository/shop_repository.dart';
import 'package:sep/feature/domain/respository/order_repository.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/utils/appUtils.dart';

class UserStoreController extends GetxController {
  static UserStoreController get find =>
      Get.put(UserStoreController(), permanent: true);

  // Repositories
  final UserProductRepository _productRepo = IUserProductRepository();
  final ShopRepository _shopRepo = IShopRepository();
  final OrderRepository _orderRepo = IOrderRepository();

  // Observable lists
  var userStores = <UserStoreModel>[].obs;
  var userProducts = <UserProductModel>[].obs;
  var userOrders = <OrderModel>[].obs;

  // Loading states
  var isLoadingStores = false.obs;
  var isLoadingProducts = false.obs;
  var isLoadingOrders = false.obs;

  // Current user's store
  var currentUserStore = Rxn<UserStoreModel>();

  // Wallet balance
  var walletBalance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserStore();
    loadWalletBalance();
  }

  // Store Management
  Future<bool> createStore(UserStoreModel store) async {
    try {
      isLoadingStores.value = true;

      AppUtils.log("Creating store with name: ${store.name}");
      AppUtils.log("Store owner ID: ${store.ownerId}");

      final response = await _shopRepo.createShop(
        name: store.name ?? '',
        description: store.description ?? '',
        logoUrl: store.logoUrl,
        address: store.address,
        contactEmail: store.contactEmail,
        contactPhone: store.contactPhone,
        ownerId: store.ownerId,
      );

      AppUtils.log("Create store response - isSuccess: ${response.isSuccess}");

      if (response.isSuccess && response.data != null) {
        final newStore = response.data!;
        userStores.clear();
        userStores.add(newStore);
        currentUserStore.value = newStore;

        AppUtils.log("Store created successfully with ID: ${newStore.id}");

        // Load products after creating store
        await loadUserProducts();

        AppUtils.toast("Store created successfully!");
        return true;
      } else {
        final errorMsg = response.error?.toString() ?? 'Unknown error';
        AppUtils.log("Failed to create store: $errorMsg");
        AppUtils.toastError("Failed to create store: $errorMsg");
        return false;
      }
    } catch (e, stackTrace) {
      AppUtils.log("Exception in createStore: $e");
      AppUtils.log("Stack trace: $stackTrace");
      AppUtils.toastError("Failed to create store: $e");
      return false;
    } finally {
      isLoadingStores.value = false;
    }
  }

  Future<void> loadUserStore() async {
    try {
      isLoadingStores.value = true;

      AppUtils.log("Loading user store...");
      final response = await _shopRepo.getMyShop();

      AppUtils.log(
        "Load store response - isSuccess: ${response.isSuccess}, hasData: ${response.data != null}",
      );

      if (response.isSuccess && response.data != null) {
        currentUserStore.value = response.data!;
        userStores.clear();
        userStores.add(response.data!);

        // Load products after loading store
        await loadUserProducts();

        AppUtils.log("User store loaded successfully: ${response.data!.name}");
      } else {
        // User doesn't have a store yet
        currentUserStore.value = null;
        AppUtils.log("No store found for user - Error: ${response.error}");
      }
    } catch (e, stackTrace) {
      AppUtils.log("Error loading store: $e");
      AppUtils.log("Stack trace: $stackTrace");
      currentUserStore.value = null;
    } finally {
      isLoadingStores.value = false;
      AppUtils.log(
        "Store loading finished - hasStore: ${currentUserStore.value != null}",
      );
    }
  }

  Future<bool> updateStore(UserStoreModel store) async {
    try {
      isLoadingStores.value = true;

      if (store.id == null || store.id!.isEmpty) {
        AppUtils.toastError("Store ID is required for update");
        return false;
      }

      final response = await _shopRepo.updateShop(
        shopId: store.id!,
        name: store.name ?? '',
        description: store.description ?? '',
        logoUrl: store.logoUrl,
        address: store.address,
        contactEmail: store.contactEmail,
        contactPhone: store.contactPhone,
        ownerId: store.ownerId,
      );

      if (response.isSuccess && response.data != null) {
        final updatedStore = response.data!;
        final index = userStores.indexWhere((s) => s.id == store.id);
        if (index != -1) {
          userStores[index] = updatedStore;
        }
        currentUserStore.value = updatedStore;

        AppUtils.toast("Store updated successfully!");
        return true;
      } else {
        AppUtils.toastError("Failed to update store: ${response.error}");
        return false;
      }
    } catch (e) {
      AppUtils.toastError("Failed to update store: $e");
      return false;
    } finally {
      isLoadingStores.value = false;
    }
  }

  Future<void> deleteStore(String storeId) async {
    try {
      isLoadingStores.value = true;

      final response = await _shopRepo.deleteShop(shopId: storeId);

      if (response.isSuccess) {
        userStores.removeWhere((s) => s.id == storeId);

        // Clear current store if it's the one being deleted
        if (currentUserStore.value?.id == storeId) {
          currentUserStore.value = null;
          userProducts.clear(); // Clear products when store is deleted
        }

        AppUtils.toast("Store deleted successfully!");

        // Reload store status to ensure clean state
        await Future.delayed(const Duration(milliseconds: 300));
        await loadUserStore();
      } else {
        AppUtils.toastError("Failed to delete store: ${response.error}");
      }
    } catch (e) {
      AppUtils.toastError("Failed to delete store: $e");
    } finally {
      isLoadingStores.value = false;
    }
  }

  // Product Management
  Future<void> createProduct(UserProductModel product) async {
    try {
      isLoadingProducts.value = true;

      final response = await _productRepo.createUserProduct(
        name: product.name ?? '',
        description: product.description ?? '',
        price: product.price ?? 0.0,
        mediaUrls: product.mediaUrls ?? [],
        category: product.category,
        isAvailable: product.isAvailable,
        shopId: currentUserStore.value?.id,
      );

      if (response.isSuccess && response.data != null) {
        userProducts.add(response.data!);
        AppUtils.toast("Product created successfully!");
      } else {
        AppUtils.toastError("Failed to create product: ${response.error}");
      }
    } catch (e) {
      AppUtils.toastError("Failed to create product: $e");
    } finally {
      isLoadingProducts.value = false;
    }
  }

  Future<void> loadUserProducts() async {
    try {
      isLoadingProducts.value = true;

      final response = await _productRepo.getUserProducts(page: 1, limit: 50);

      if (response.isSuccess && response.data != null) {
        final products = response.data!.products ?? [];
        userProducts.assignAll(products);
        AppUtils.log("Loaded ${products.length} user products");
      } else {
        // Don't show error toast - user might not have products yet
        AppUtils.log("No user products found: ${response.error}");
        userProducts.clear();
      }
    } catch (e) {
      // Don't show error toast - just log it
      AppUtils.log("Failed to load user products: $e");
      userProducts.clear();
    } finally {
      isLoadingProducts.value = false;
    }
  }

  Future<void> updateProduct(UserProductModel product) async {
    try {
      isLoadingProducts.value = true;

      if (product.id == null) {
        AppUtils.toastError("Product ID is required for update");
        return;
      }

      final response = await _productRepo.updateUserProduct(
        productId: product.id!,
        name: product.name ?? '',
        description: product.description ?? '',
        price: product.price ?? 0.0,
        mediaUrls: product.mediaUrls ?? [],
        category: product.category,
        isAvailable: product.isAvailable,
      );

      if (response.isSuccess && response.data != null) {
        final index = userProducts.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          userProducts[index] = response.data!;
        }
        AppUtils.toast("Product updated successfully!");
      } else {
        AppUtils.toastError("Failed to update product: ${response.error}");
      }
    } catch (e) {
      AppUtils.toastError("Failed to update product: $e");
    } finally {
      isLoadingProducts.value = false;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      isLoadingProducts.value = true;

      final response = await _productRepo.deleteUserProduct(
        productId: productId,
      );

      if (response.isSuccess) {
        userProducts.removeWhere((p) => p.id == productId);
        AppUtils.toast("Product deleted successfully!");
      } else {
        AppUtils.toastError("Failed to delete product: ${response.error}");
      }
    } catch (e) {
      AppUtils.toastError("Failed to delete product: $e");
    } finally {
      isLoadingProducts.value = false;
    }
  }

  // Order Management
  Future<void> createOrder(OrderModel order) async {
    try {
      isLoadingOrders.value = true;

      AppUtils.log("Creating order for product: ${order.productId}");

      final response = await _orderRepo.createOrder(
        userId: order.userId ?? '',
        storeId: order.storeId ?? '',
        productId: order.productId ?? '',
        quantity: order.quantity,
        totalAmount: order.totalAmount ?? 0.0,
        status: order.status,
        trackingNumber: order.trackingNumber,
        address: order.address,
      );

      if (response.isSuccess && response.data != null) {
        final newOrder = response.data!;
        userOrders.add(newOrder);

        AppUtils.log("Order created successfully with ID: ${newOrder.id}");
        AppUtils.toast("Order placed successfully!");
      } else {
        final errorMsg = response.error?.toString() ?? 'Unknown error';
        AppUtils.log("Failed to create order: $errorMsg");
        AppUtils.toastError("Failed to place order: $errorMsg");
        throw Exception(errorMsg);
      }
    } catch (e) {
      AppUtils.log("Exception in createOrder: $e");
      AppUtils.toastError("Failed to place order: ${e.toString()}");
      rethrow;
    } finally {
      isLoadingOrders.value = false;
    }
  }

  Future<void> loadUserOrders() async {
    try {
      isLoadingOrders.value = true;

      // TODO: Replace with actual API call
      await Future.delayed(Duration(seconds: 1)); // Simulate API call

      // Load orders for current user
    } catch (e) {
      AppUtils.toastError("Failed to load orders: $e");
    } finally {
      isLoadingOrders.value = false;
    }
  }

  // Load buyer orders (orders placed by the current user)
  Future<void> loadBuyerOrders() async {
    try {
      isLoadingOrders.value = true;

      AppUtils.log(
        '==================== LOADING BUYER ORDERS ====================',
      );

      // Call API to get buyer orders
      final response = await _orderRepo.getMyOrders(page: 1, limit: 100);

      AppUtils.log('API response isSuccess: ${response.isSuccess}');
      AppUtils.log('API response data: ${response.data}');
      AppUtils.log('API response error: ${response.error}');

      if (response.isSuccess && response.data != null) {
        final orderData = response.data!;
        AppUtils.log('OrderListData received');
        AppUtils.log('  - orders count: ${orderData.orders?.length ?? 0}');

        if (orderData.orders != null) {
          userOrders.assignAll(orderData.orders!);
          AppUtils.log(
            'Assigned ${orderData.orders!.length} orders to userOrders',
          );

          // Detailed log of each order
          for (var i = 0; i < orderData.orders!.length; i++) {
            final order = orderData.orders![i];
            AppUtils.log('Order #${i + 1}:');
            AppUtils.log('  - ID: ${order.id}');
            AppUtils.log('  - Product Name: ${order.productName}');
            AppUtils.log('  - Product Price: ${order.productPrice}');
            AppUtils.log('  - Quantity: ${order.quantity}');
            AppUtils.log('  - Total Amount: ${order.totalAmount}');
            AppUtils.log('  - Status: ${order.status}');
            AppUtils.log('  - Store Name: ${order.storeName}');
            AppUtils.log('  - Seller Name: ${order.sellerName}');
          }
        } else {
          AppUtils.log('WARNING: orderData.orders is null!');
          userOrders.clear();
        }
      } else {
        final errorMsg = response.error?.toString() ?? 'Unknown error';
        AppUtils.log('Failed to load buyer orders: $errorMsg');
        AppUtils.toastError('Failed to load orders: $errorMsg');
        userOrders.clear();
      }

      AppUtils.log('Final userOrders count: ${userOrders.length}');
      AppUtils.log(
        '================================================================',
      );
    } catch (e, stackTrace) {
      AppUtils.log('EXCEPTION in loadBuyerOrders: $e');
      AppUtils.log('Stack trace: $stackTrace');
      AppUtils.toastError('Failed to load buyer orders: $e');
      userOrders.clear();
    } finally {
      isLoadingOrders.value = false;
    }
  }

  // Load seller orders (orders received by the current user's store)
  Future<void> loadSellerOrders() async {
    try {
      // Defer loading state update to avoid build phase conflicts
      Future.microtask(() => isLoadingOrders.value = true);

      AppUtils.log(
        '==================== LOADING SELLER ORDERS ====================',
      );

      // Call API to get seller orders
      final response = await _orderRepo.getSellerOrders(page: 1, limit: 100);

      AppUtils.log('API response isSuccess: ${response.isSuccess}');
      AppUtils.log('API response data: ${response.data}');
      AppUtils.log('API response error: ${response.error}');

      if (response.isSuccess && response.data != null) {
        final orderData = response.data!;
        AppUtils.log('OrderListData received');
        AppUtils.log('  - orders count: ${orderData.orders?.length ?? 0}');

        if (orderData.orders != null) {
          userOrders.assignAll(orderData.orders!);
          AppUtils.log(
            'Assigned ${orderData.orders!.length} orders to userOrders',
          );

          // Detailed log of each order
          for (var i = 0; i < orderData.orders!.length; i++) {
            final order = orderData.orders![i];
            AppUtils.log('Order #${i + 1}:');
            AppUtils.log('  - ID: ${order.id}');
            AppUtils.log('  - Product Name: ${order.productName}');
            AppUtils.log('  - Product Price: ${order.productPrice}');
            AppUtils.log('  - Quantity: ${order.quantity}');
            AppUtils.log('  - Total Amount: ${order.totalAmount}');
            AppUtils.log('  - Status: ${order.status}');
            AppUtils.log('  - Buyer Name: ${order.sellerName}');
          }
        } else {
          AppUtils.log('WARNING: orderData.orders is null!');
          userOrders.clear();
        }
      } else {
        final errorMsg = response.error?.toString() ?? 'Unknown error';
        AppUtils.log('Failed to load seller orders: $errorMsg');
        userOrders.clear();
      }

      AppUtils.log('Final userOrders count: ${userOrders.length}');
      AppUtils.log(
        '================================================================',
      );
    } catch (e, stackTrace) {
      AppUtils.log('EXCEPTION in loadSellerOrders: $e');
      AppUtils.log('Stack trace: $stackTrace');
      userOrders.clear();
    } finally {
      isLoadingOrders.value = false;
    }
  }

  // Update order status (for sellers)
  // Update order status (for sellers)
  Future<void> updateOrderStatus(
    String orderId,
    String status, {
    String? trackingNumber,
  }) async {
    try {
      isLoadingOrders.value = true;

      AppUtils.log('Updating order $orderId to status: $status');
      if (trackingNumber != null) {
        AppUtils.log('With tracking number: $trackingNumber');
      }

      // Call API to update order status
      final response = await _orderRepo.updateOrderStatus(
        orderId: orderId,
        status: status,
        trackingNumber: trackingNumber,
      );

      if (response.isSuccess && response.data != null) {
        final updatedOrder = response.data!;

        // Update the order in the list
        final index = userOrders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          userOrders[index] = updatedOrder;
        }

        AppUtils.log('Order status updated successfully');
        AppUtils.toast('Order status updated to $status');
      } else {
        final errorMsg = response.error?.toString() ?? 'Unknown error';
        AppUtils.log('Failed to update order status: $errorMsg');
        AppUtils.toastError('Failed to update order status: $errorMsg');
      }
    } catch (e) {
      AppUtils.log('Exception in updateOrderStatus: $e');
      AppUtils.toastError('Failed to update order status: $e');
    } finally {
      isLoadingOrders.value = false;
    }
  }

  // Accept order (for sellers)
  Future<bool> acceptOrder(String orderId) async {
    try {
      isLoadingOrders.value = true;
      AppUtils.log('Accepting order: $orderId');

      // Call API to accept order
      final response = await _orderRepo.acceptOrder(orderId: orderId);

      if (response.isSuccess && response.data != null) {
        final acceptedOrder = response.data!;

        // Update the order in the list
        final index = userOrders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          userOrders[index] = acceptedOrder;
        }

        AppUtils.log('Order accepted successfully');
        AppUtils.toast('Order accepted successfully');
        return true;
      } else {
        final errorMsg = response.error?.toString() ?? 'Unknown error';
        AppUtils.log('Failed to accept order: $errorMsg');
        AppUtils.toastError('Failed to accept order: $errorMsg');
        return false;
      }
    } catch (e) {
      AppUtils.log('Exception in acceptOrder: $e');
      AppUtils.toastError('Failed to accept order: $e');
      return false;
    } finally {
      isLoadingOrders.value = false;
    }
  }

  // Reject order (for sellers)
  Future<bool> rejectOrder(String orderId) async {
    try {
      isLoadingOrders.value = true;
      AppUtils.log('Rejecting order: $orderId');

      // Call API to reject order
      final response = await _orderRepo.rejectOrder(orderId: orderId);

      if (response.isSuccess && response.data != null) {
        final rejectedOrder = response.data!;

        // Update the order in the list
        final index = userOrders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          userOrders[index] = rejectedOrder;
        }

        AppUtils.log('Order rejected successfully');
        AppUtils.toast('Order rejected successfully');
        return true;
      } else {
        final errorMsg = response.error?.toString() ?? 'Unknown error';
        AppUtils.log('Failed to reject order: $errorMsg');
        AppUtils.toastError('Failed to reject order: $errorMsg');
        return false;
      }
    } catch (e) {
      AppUtils.log('Exception in rejectOrder: $e');
      AppUtils.toastError('Failed to reject order: $e');
      return false;
    } finally {
      isLoadingOrders.value = false;
    }
  }

  // Cancel order (for buyers)
  Future<bool> cancelOrder(String orderId) async {
    try {
      AppUtils.log('Cancelling order: $orderId');

      // Call API to cancel order
      final response = await _orderRepo.cancelOrder(orderId: orderId);

      if (response.isSuccess && response.data != null) {
        final cancelledOrder = response.data!;

        // Update the order in the list
        final index = userOrders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          userOrders[index] = cancelledOrder;
        }

        AppUtils.log('Order cancelled successfully');
        AppUtils.toast('Order cancelled successfully');
        return true;
      } else {
        final errorMsg = response.error?.toString() ?? 'Unknown error';
        AppUtils.log('Failed to cancel order: $errorMsg');
        AppUtils.toastError('Failed to cancel order: $errorMsg');
        return false;
      }
    } catch (e) {
      AppUtils.log('Exception in cancelOrder: $e');
      AppUtils.toastError('Failed to cancel order: $e');
      return false;
    }
  }

  // Mark order as completed (for buyers)
  Future<bool> markOrderAsCompleted(String orderId) async {
    try {
      AppUtils.log('Marking order as completed: $orderId');

      // Call API to mark order as completed
      final response = await _orderRepo.markOrderAsCompleted(orderId: orderId);

      if (response.isSuccess && response.data != null) {
        final completedOrder = response.data!;

        // Update the order in the list
        final index = userOrders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          userOrders[index] = completedOrder;
        }

        AppUtils.log('Order marked as completed successfully');
        AppUtils.toast('Order marked as completed successfully');
        return true;
      } else {
        final errorMsg = response.error?.toString() ?? 'Unknown error';
        AppUtils.log('Failed to mark order as completed: $errorMsg');
        AppUtils.toastError('Failed to mark order as completed: $errorMsg');
        return false;
      }
    } catch (e) {
      AppUtils.log('Exception in markOrderAsCompleted: $e');
      AppUtils.toastError('Failed to mark order as completed: $e');
      return false;
    }
  }

  // Mark order as shipped (for sellers)
  Future<bool> markAsShipped(String orderId, String trackingNumber) async {
    try {
      isLoadingOrders.value = true;
      AppUtils.log('Marking order as shipped: $orderId');
      AppUtils.log('Tracking number: $trackingNumber');

      // Call API to mark order as shipped
      final response = await _orderRepo.markAsShipped(
        orderId: orderId,
        trackingNumber: trackingNumber,
      );

      if (response.isSuccess && response.data != null) {
        final shippedOrder = response.data!;

        // Update the order in the list
        final index = userOrders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          userOrders[index] = shippedOrder;
        }

        AppUtils.log('Order marked as shipped successfully');
        AppUtils.toast('Order marked as shipped successfully');
        return true;
      } else {
        final errorMsg = response.error?.toString() ?? 'Unknown error';
        AppUtils.log('Failed to mark order as shipped: $errorMsg');
        AppUtils.toastError('Failed to mark order as shipped: $errorMsg');
        return false;
      }
    } catch (e) {
      AppUtils.log('Exception in markAsShipped: $e');
      AppUtils.toastError('Failed to mark order as shipped: $e');
      return false;
    } finally {
      isLoadingOrders.value = false;
    }
  }

  // Utility methods
  bool get hasStore => currentUserStore.value != null;

  List<UserProductModel> getProductsByStore(String storeId) {
    return userProducts.where((p) => p.storeId == storeId).toList();
  }

  List<OrderModel> getOrdersByStore(String storeId) {
    return userOrders.where((o) => o.storeId == storeId).toList();
  }

  // Get orders where current user is the buyer
  List<OrderModel> getBuyerOrders(String userId) {
    return userOrders.where((o) => o.userId == userId).toList();
  }

  // Get orders for current user's store (seller orders)
  List<OrderModel> getSellerOrders() {
    if (currentUserStore.value == null) return [];
    return userOrders
        .where((o) => o.storeId == currentUserStore.value!.id)
        .toList();
  }

  UserProductModel? getProductById(String productId) {
    try {
      return userProducts.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Public API Methods for browsing products and shops
  var allShops = <UserStoreModel>[].obs;
  var allProducts = <UserProductModel>[].obs;
  var isLoadingAllShops = false.obs;
  var isLoadingAllProducts = false.obs;
  var selectedShopForViewing = Rxn<UserStoreModel>();
  var shopProducts = <UserProductModel>[].obs;

  Future<void> loadAllShops({int page = 1, int limit = 20}) async {
    try {
      isLoadingAllShops.value = true;

      final response = await _shopRepo.getAllShops(page: page, limit: limit);

      if (response.isSuccess && response.data != null) {
        if (page == 1) {
          allShops.assignAll(response.data!.stores ?? []);
        } else {
          allShops.addAll(response.data!.stores ?? []);
        }
        AppUtils.log("Loaded ${response.data!.stores?.length ?? 0} shops");
      } else {
        AppUtils.log("Failed to load shops: ${response.error}");
      }
    } catch (e) {
      AppUtils.log("Error loading all shops: $e");
    } finally {
      isLoadingAllShops.value = false;
    }
  }

  Future<void> loadShopById(String shopId) async {
    try {
      isLoadingStores.value = true;

      final response = await _shopRepo.getShopById(shopId: shopId);

      if (response.isSuccess && response.data != null) {
        selectedShopForViewing.value = response.data!;
        AppUtils.log("Loaded shop: ${response.data!.name}");
        AppUtils.log("  - logoUrl: ${response.data!.logoUrl}");
        // Load products for this shop
        await loadProductsByShop(shopId);
      } else {
        AppUtils.toastError("Failed to load shop details");
      }
    } catch (e) {
      AppUtils.toastError("Error loading shop: $e");
    } finally {
      isLoadingStores.value = false;
    }
  }

  Future<void> loadProductsByShop(
    String shopId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // Defer loading state update to avoid build phase conflicts
      Future.microtask(() => isLoadingProducts.value = true);

      final response = await _productRepo.getProductsByShop(
        shopId: shopId,
        page: page,
        limit: limit,
      );

      if (response.isSuccess && response.data != null) {
        if (page == 1) {
          shopProducts.assignAll(response.data!.products ?? []);
        } else {
          shopProducts.addAll(response.data!.products ?? []);
        }
        AppUtils.log(
          "Loaded ${response.data!.products?.length ?? 0} products for shop",
        );

        // Log detailed product info including mediaUrls
        for (var product in response.data!.products ?? []) {
          AppUtils.log("  Product: ${product.name}");
          AppUtils.log(
            "    - mediaUrls count: ${product.mediaUrls?.length ?? 0}",
          );
          if (product.mediaUrls != null && product.mediaUrls!.isNotEmpty) {
            AppUtils.log("    - first mediaUrl: ${product.mediaUrls!.first}");
          }
        }
      } else {
        AppUtils.log("Failed to load shop products: ${response.error}");
      }
    } catch (e) {
      AppUtils.log("Error loading shop products: $e");
    } finally {
      isLoadingProducts.value = false;
    }
  }

  Future<UserProductModel?> loadProductDetails(String productId) async {
    try {
      isLoadingProducts.value = true;

      final response = await _productRepo.getProductDetails(
        productId: productId,
      );

      if (response.isSuccess && response.data != null) {
        AppUtils.log("Loaded product details: ${response.data!.name}");
        AppUtils.log(
          "  - mediaUrls count: ${response.data!.mediaUrls?.length ?? 0}",
        );
        if (response.data!.mediaUrls != null &&
            response.data!.mediaUrls!.isNotEmpty) {
          for (int i = 0; i < response.data!.mediaUrls!.length; i++) {
            AppUtils.log("  - mediaUrl[$i]: ${response.data!.mediaUrls![i]}");
          }
        }
        return response.data!;
      } else {
        AppUtils.toastError("Failed to load product details");
        return null;
      }
    } catch (e) {
      AppUtils.toastError("Error loading product: $e");
      return null;
    } finally {
      isLoadingProducts.value = false;
    }
  }

  Future<void> loadMyProducts({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      isLoadingAllProducts.value = true;

      // Use getAllProducts to get ALL products from all users
      final response = await _productRepo.getAllProducts(
        page: page,
        limit: limit,
      );

      if (response.isSuccess && response.data != null) {
        if (page == 1) {
          allProducts.assignAll(response.data!.products ?? []);
        } else {
          allProducts.addAll(response.data!.products ?? []);
        }
        AppUtils.log(
          "Loaded ${response.data!.products?.length ?? 0} products from all users",
        );

        // Log product details for debugging including mediaUrls
        for (var product in response.data!.products ?? []) {
          AppUtils.log(
            "Product: ${product.name}, shopId: ${product.storeId}, shopName: ${product.shopInfo?.name}",
          );
          AppUtils.log(
            "  - mediaUrls count: ${product.mediaUrls?.length ?? 0}",
          );
          if (product.mediaUrls != null && product.mediaUrls!.isNotEmpty) {
            AppUtils.log("  - first mediaUrl: ${product.mediaUrls!.first}");
          }
        }
      } else {
        AppUtils.log("Failed to load products: ${response.error}");
      }
    } catch (e) {
      AppUtils.log("Error loading all products: $e");
    } finally {
      isLoadingAllProducts.value = false;
    }
  }

  // Wallet Management
  Future<void> loadWalletBalance() async {
    try {
      // Fetch latest profile data in real-time
      await ProfileCtrl.find.getProfileDetails();

      // Get wallet balance from ProfileCtrl
      final profileData = ProfileCtrl.find.profileData.value;
      final balance = profileData.walletBalance;

      if (balance != null) {
        walletBalance.value = balance.toDouble();
        AppUtils.log(
          "Wallet balance loaded in real-time: \$${walletBalance.value}",
        );
      } else {
        walletBalance.value = 0.0;
        AppUtils.log(
          "No wallet balance found in profile, defaulting to \$0.00",
        );
      }
    } catch (e) {
      AppUtils.log("Error loading wallet balance: $e");
      walletBalance.value = 0.0;
    }
  }

  Future<void> deductFromWallet(double amount) async {
    try {
      // TODO: Replace with actual API call to deduct from wallet
      // final response = await _userRepo.deductFromWallet(amount);

      // Mock deduction - replace with actual API call
      if (walletBalance.value >= amount) {
        walletBalance.value -= amount;
        AppUtils.log(
          "Deducted \$$amount from wallet. New balance: \$${walletBalance.value}",
        );
      } else {
        throw Exception("Insufficient wallet balance");
      }
    } catch (e) {
      AppUtils.log("Error deducting from wallet: $e");
      throw e;
    }
  }

  Future<void> addToWallet(double amount) async {
    try {
      // TODO: Replace with actual API call to add to wallet
      // final response = await _userRepo.addToWallet(amount);

      // Mock addition - replace with actual API call
      walletBalance.value += amount;
      AppUtils.log(
        "Added \$$amount to wallet. New balance: \$${walletBalance.value}",
      );
    } catch (e) {
      AppUtils.log("Error adding to wallet: $e");
      throw e;
    }
  }
}
