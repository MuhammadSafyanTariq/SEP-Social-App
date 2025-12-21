import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/feature/data/models/dataModels/store_model.dart';
import 'package:sep/feature/presentation/store/create_store_screen.dart';
import 'package:sep/feature/presentation/products/product_details_screen.dart';
import 'package:sep/feature/presentation/products/upload_product_screen.dart';
import 'package:sep/feature/presentation/products/edit_product_screen.dart';
import 'package:sep/feature/presentation/real_estate/real_estate_detail_screen.dart';
import 'package:sep/feature/presentation/real_estate/edit_real_estate_screen.dart';
import 'package:sep/feature/presentation/real_estate/upload_real_estate_screen.dart';
import 'package:sep/feature/presentation/SportsProducts/sportsProduct.dart';
import 'package:sep/services/networking/apiMethods.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/coreComponents/appBar2.dart';

class StoreViewScreen extends StatefulWidget {
  final String?
  shopId; // If null, load current user's store. If provided, load specific store
  final String? ownerId; // Optional - to check if this is the owner's store

  const StoreViewScreen({Key? key, this.shopId, this.ownerId})
    : super(key: key);

  @override
  State<StoreViewScreen> createState() => _StoreViewScreenState();
}

class _StoreViewScreenState extends State<StoreViewScreen> {
  bool isLoading = true;
  StoreModel? myStore;
  final IApiMethod apiMethod = IApiMethod();
  bool isOwner = false;

  // Products data
  List<Map<String, dynamic>> products = [];
  int currentPage = 1;
  int totalPages = 1;
  int totalCount = 0;
  bool isLoadingProducts = false;
  final ScrollController _scrollController = ScrollController();

  // Orders data
  List<Map<String, dynamic>> orders = [];
  int ordersCurrentPage = 1;
  int ordersTotalPages = 1;
  int ordersTotalCount = 0;
  bool isLoadingOrders = false;
  final ScrollController _ordersScrollController = ScrollController();
  Set<String> expandedOrderIds = {};
  String selectedOrderStatus =
      'all'; // Filter for orders: all, pending, processing, shipped, completed, cancelled
  int currentTabIndex = 0; // Track current tab: 0 = Products, 1 = Real Estate

  // Product details cache for orders
  Map<String, Map<String, dynamic>> productCache = {};

  @override
  void initState() {
    super.initState();
    _loadStore();
    _scrollController.addListener(_onScroll);
    _ordersScrollController.addListener(_onOrdersScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _ordersScrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingProducts && currentPage < totalPages) {
        _loadProducts(page: currentPage + 1);
      }
    }
  }

  void _onOrdersScroll() {
    if (_ordersScrollController.position.pixels >=
        _ordersScrollController.position.maxScrollExtent - 200) {
      if (!isLoadingOrders && ordersCurrentPage < ordersTotalPages) {
        _loadOrders(page: ordersCurrentPage + 1);
      }
    }
  }

  Future<void> _loadStore() async {
    setState(() => isLoading = true);

    try {
      final token = Preferences.authToken;
      final currentUserId = Preferences.uid;

      // Determine which endpoint to use
      String endpoint;
      if (widget.shopId != null) {
        // Load specific store by ID
        endpoint = Urls.getShopById(widget.shopId!);
      } else {
        // Load current user's store
        endpoint = Urls.getMyShop;
      }

      AppUtils.log("Loading store from endpoint: $endpoint");
      AppUtils.log("Current user ID: $currentUserId");

      final response = await apiMethod.get(
        url: endpoint,
        authToken: token,
        headers: {},
      );

      AppUtils.log("Response status: ${response.isSuccess}");
      AppUtils.log("Response data: ${response.data}");

      if (response.isSuccess && response.data?['data'] != null) {
        final storeData = response.data!['data'];

        AppUtils.log("Store data received: $storeData");

        // Extract owner ID
        String? storeOwnerId;
        if (storeData['ownerId'] is Map) {
          storeOwnerId = (storeData['ownerId'] as Map)['_id'] as String?;
          storeData['ownerId'] = storeOwnerId;
        } else if (storeData['ownerId'] is String) {
          storeOwnerId = storeData['ownerId'] as String;
        }

        AppUtils.log("Extracted owner ID: $storeOwnerId");

        // Extract product IDs from product objects
        if (storeData['products'] is List) {
          final productList = storeData['products'] as List;
          storeData['products'] = productList.map((product) {
            if (product is Map && product['_id'] != null) {
              return product['_id'] as String;
            }
            return product.toString();
          }).toList();
        }

        // Check if current user is the owner
        isOwner =
            (storeOwnerId == currentUserId) ||
            (widget.ownerId != null && widget.ownerId == currentUserId) ||
            (widget.shopId ==
                null); // If no shopId provided, it's definitely the owner's store

        AppUtils.log("Is owner: $isOwner");

        setState(() {
          myStore = StoreModel.fromJson(storeData);
          isLoading = false;
        });

        // Load products and orders after store is loaded
        if (myStore != null) {
          _loadProducts(page: 1);
          if (isOwner) {
            _loadOrders(page: 1);
          }
        }
      } else {
        AppUtils.log("No store data found or response unsuccessful");
        AppUtils.log("Response message: ${response.data?['message']}");
        setState(() {
          myStore = null;
          isLoading = false;
        });
      }
    } catch (e) {
      AppUtils.log("Error loading store: $e");
      setState(() {
        myStore = null;
        isLoading = false;
      });
    }
  }

  Future<void> _loadProducts({int page = 1, int limit = 10}) async {
    if (myStore == null || isLoadingProducts) return;

    setState(() => isLoadingProducts = true);

    try {
      final token = Preferences.authToken;
      final shopId = myStore!.id;

      AppUtils.log("Loading products for shop: $shopId, page: $page");

      final response = await apiMethod.get(
        url: '/api/user-product/shop/$shopId?page=$page&limit=$limit',
        authToken: token,
        headers: {},
      );

      AppUtils.log("Products response: ${response.data}");

      if (response.isSuccess && response.data?['data'] != null) {
        final data = response.data!['data'];
        final List<dynamic> productsList = data['products'] ?? [];
        final pagination = data['pagination'];

        setState(() {
          if (page == 1) {
            products = List<Map<String, dynamic>>.from(productsList);
          } else {
            products.addAll(List<Map<String, dynamic>>.from(productsList));
          }

          currentPage = pagination['page'] ?? 1;
          totalPages = pagination['totalPages'] ?? 1;
          totalCount = pagination['totalCount'] ?? 0;
          isLoadingProducts = false;
        });
      } else {
        setState(() => isLoadingProducts = false);
      }
    } catch (e) {
      AppUtils.log("Error loading products: $e");
      setState(() => isLoadingProducts = false);
    }
  }

  Future<void> _loadOrders({int page = 1, int limit = 10}) async {
    if (!isOwner || isLoadingOrders) return;

    setState(() => isLoadingOrders = true);

    try {
      final token = Preferences.authToken;

      AppUtils.log("Loading orders for seller, page: $page");

      final response = await apiMethod.get(
        url: '/api/order/seller-orders?page=$page&limit=$limit',
        authToken: token,
        headers: {},
      );

      AppUtils.log("Orders response: ${response.data}");

      if (response.isSuccess && response.data?['data'] != null) {
        final data = response.data!['data'];
        final List<dynamic> ordersList = data['orders'] ?? [];
        final pagination = data['pagination'];

        setState(() {
          if (page == 1) {
            orders = List<Map<String, dynamic>>.from(ordersList);
          } else {
            orders.addAll(List<Map<String, dynamic>>.from(ordersList));
          }

          ordersCurrentPage = pagination['page'] ?? 1;
          ordersTotalPages = pagination['totalPages'] ?? 1;
          ordersTotalCount = pagination['totalCount'] ?? 0;
          isLoadingOrders = false;
        });
      } else {
        setState(() => isLoadingOrders = false);
      }
    } catch (e) {
      AppUtils.log("Error loading orders: $e");
      setState(() => isLoadingOrders = false);
    }
  }

  // Method to fetch a specific store by ID (for viewing other stores)
  Future<StoreModel?> fetchStoreById(String shopId) async {
    try {
      final token = Preferences.authToken;
      final response = await apiMethod.get(
        url: Urls.getShopById(shopId),
        authToken: token,
        headers: {},
      );

      if (response.isSuccess && response.data?['data'] != null) {
        final storeData = response.data!['data'];

        // Handle ownerId - if it's an object, extract just the ID string
        if (storeData['ownerId'] is Map) {
          storeData['ownerId'] = (storeData['ownerId'] as Map)['_id'];
        }

        // Extract product IDs from product objects
        if (storeData['products'] is List) {
          final productList = storeData['products'] as List;
          storeData['products'] = productList.map((product) {
            if (product is Map && product['_id'] != null) {
              return product['_id'] as String;
            }
            return product.toString();
          }).toList();
        }

        return StoreModel.fromJson(storeData);
      }
      return null;
    } catch (e) {
      AppUtils.log("Error fetching store by ID: $e");
      return null;
    }
  }

  // Method to fetch product details by ID
  Future<Map<String, dynamic>?> fetchProductById(String productId) async {
    // Check cache first
    if (productCache.containsKey(productId)) {
      return productCache[productId];
    }

    try {
      final token = Preferences.authToken;
      final response = await apiMethod.get(
        url: '/api/user-product/$productId',
        authToken: token,
        headers: {},
      );

      if (response.isSuccess && response.data?['data'] != null) {
        final productData = response.data!['data'] as Map<String, dynamic>;
        // Cache the product data
        productCache[productId] = productData;
        return productData;
      }
      return null;
    } catch (e) {
      AppUtils.log("Error fetching product by ID: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: isOwner && myStore != null
          ? _buildFloatingActionButton()
          : null,
      body: SafeArea(
        child: Column(
          children: [
            AppBar2(
              title: isOwner ? "My Store" : "Store",
              titleStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              prefixImage: "back",
              onPrefixTap: () => Navigator.pop(context),
              backgroundColor: Colors.white,
              hasTopSafe: false,
              suffixWidget: isOwner && myStore != null
                  ? PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.black),
                      offset: const Offset(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          final result = await Get.to(
                            () => CreateStoreScreen(existingStore: myStore),
                          );
                          if (result == true) {
                            _loadStore();
                          }
                        } else if (value == 'delete') {
                          _showDeleteConfirmation();
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 20,
                                color: Colors.black87,
                              ),
                              SizedBox(width: 12),
                              Text('Edit Shop'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Colors.red,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Delete Shop',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : myStore == null
                  ? _buildCreateStoreView()
                  : _buildStoreDetailsView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateStoreView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_outlined, size: 120, color: Colors.grey[400]),
            const SizedBox(height: 24),
            TextView(
              text: "You don't have a store yet",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            TextView(
              text:
                  "Create your own store and start selling products to the community",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Get.to(() => const CreateStoreScreen());
                  if (result == true) {
                    _loadStore();
                  }
                },
                icon: const Icon(Icons.add_business, color: Colors.white),
                label: const Text(
                  "Create Store",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.btnColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreDetailsView() {
    return DefaultTabController(
      length: 2, // Products and Real Estate tabs
      child: Builder(
        builder: (context) {
          final TabController tabController = DefaultTabController.of(context);

          tabController.addListener(() {
            if (!tabController.indexIsChanging) {
              setState(() {
                currentTabIndex = tabController.index;
              });
            }
          });

          return SingleChildScrollView(
            controller: currentTabIndex == 0
                ? _scrollController
                : _ordersScrollController,
            child: Column(
              children: [
                // Store Header Card
                _buildStoreHeader(),

                // TabBar
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: AppColors.btnColor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.btnColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[600],
                    labelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: [
                      const Tab(
                        height: 44,
                        child: Center(child: Text("Products")),
                      ),
                      const Tab(
                        height: 44,
                        child: Center(child: Text("Real Estate")),
                      ),
                    ],
                  ),
                ),

                // Content based on selected tab
                AnimatedBuilder(
                  animation: tabController,
                  builder: (context, child) {
                    if (tabController.index == 0) {
                      // Products Tab
                      final filteredProducts = products.where((product) {
                        final category =
                            product['category']?.toString().toLowerCase() ?? '';
                        return !category.contains('realestate');
                      }).toList();

                      if (filteredProducts.isEmpty && !isLoadingProducts) {
                        return _buildEmptyProductsState();
                      } else {
                        return Column(
                          children: [
                            _buildProductsGrid(filteredProducts),
                            if (isLoadingProducts)
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                          ],
                        );
                      }
                    } else {
                      // Real Estate Tab
                      final realEstateListings = products.where((product) {
                        final category =
                            product['category']?.toString().toLowerCase() ?? '';
                        return category.contains('realestate');
                      }).toList();

                      if (realEstateListings.isEmpty && !isLoadingProducts) {
                        return _buildEmptyRealEstateState();
                      } else {
                        return Column(
                          children: [
                            _buildRealEstateGrid(realEstateListings),
                            if (isLoadingProducts)
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                          ],
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    // Show FAB only when there are items or on empty state with button
    return FloatingActionButton(
      onPressed: () async {
        if (currentTabIndex == 0) {
          // Products tab - navigate to upload product
          final result = await Get.to(() => const UploadProductScreen());
          if (result == true) {
            await _loadStore();
          }
        } else {
          // Real Estate tab - navigate to upload real estate
          final result = await Get.to(() => const UploadRealEstateScreen());
          if (result == true) {
            await _loadStore();
          }
        }
      },
      backgroundColor: AppColors.btnColor,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Widget _buildStoreHeader() {
    return Column(
      children: [
        // Store Header Card with Logo and Info
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey.shade50],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.btnColor.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Logo and Details Row
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo on Left with elevated design
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.btnColor.withOpacity(0.2),
                            spreadRadius: 0,
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child:
                            myStore!.logoUrl != null &&
                                myStore!.logoUrl!.isNotEmpty
                            ? Image.network(
                                myStore!.logoUrl!.startsWith('http')
                                    ? myStore!.logoUrl!
                                    : '${Urls.appApiBaseUrl}${myStore!.logoUrl}',
                                height: 110,
                                width: 110,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildDefaultLogo();
                                },
                              )
                            : _buildDefaultLogo(),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Details on Right
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Store Name with status badge
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  myStore!.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    letterSpacing: -0.5,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: myStore!.isActive
                                  ? Colors.green.withOpacity(0.15)
                                  : Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: myStore!.isActive
                                    ? Colors.green.withOpacity(0.3)
                                    : Colors.red.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: myStore!.isActive
                                        ? Colors.green
                                        : Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  myStore!.isActive ? "Active" : "Inactive",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: myStore!.isActive
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Contact Details
                          _buildDetailRow(
                            Icons.email_outlined,
                            myStore!.contactEmail,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            Icons.phone_outlined,
                            myStore!.contactPhone,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            Icons.location_on_outlined,
                            myStore!.address,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Description Section with better styling
              if (myStore!.description.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200, width: 1),
                      bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: AppColors.btnColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "About Store",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        myStore!.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.6,
                        ),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],

              // Statistics Row with enhanced design
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildEnhancedStatItem(
                      Icons.inventory_2_outlined,
                      myStore!.products.length.toString(),
                      "Products",
                    ),
                    Container(
                      height: 50,
                      width: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.grey.shade200,
                            Colors.grey.shade300,
                            Colors.grey.shade200,
                          ],
                        ),
                      ),
                    ),
                    _buildEnhancedStatItem(
                      Icons.calendar_today_outlined,
                      _formatDate(myStore!.createdAt),
                      "Joined",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyProductsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "No products yet",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isOwner) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Get.to(
                    () => const UploadProductScreen(),
                  );
                  if (result == true) {
                    await _loadStore();
                  }
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Add Product",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.btnColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGrid(List<Map<String, dynamic>> filteredProducts) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.52,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              final productId = product['_id'] ?? '';
              final name = product['name'] ?? 'Product ${index + 1}';
              final description = product['description'] ?? '';
              final price = product['price']?.toString() ?? '0.00';
              final mediaUrls = product['mediaUrls'] as List? ?? [];
              String imageUrl = '';
              if (mediaUrls.isNotEmpty) {
                final url = mediaUrls[0] as String;
                imageUrl = url.startsWith('http')
                    ? url
                    : '${Urls.appApiBaseUrl}$url';
              }
              final categoryFull = product['category'] ?? 'Standard';
              final category = categoryFull.contains('+')
                  ? categoryFull.split('+')[0]
                  : categoryFull;

              return ProductCard(
                title: name,
                type: category,
                link: "",
                image: imageUrl,
                price: price,
                desc: description,
                imageType: ImageType.network,
                productType: 'user-product',
                showOwnerActions: isOwner,
                onTap: () {
                  Get.to(
                    () => ProductDetailsScreen(
                      productId: productId,
                      productType: 'user-product',
                    ),
                  );
                },
                onEdit: isOwner
                    ? () async {
                        final result = await Get.to(
                          () => EditProductScreen(productId: productId),
                        );
                        if (result == true) {
                          await _loadStore();
                        }
                      }
                    : null,
                onDelete: isOwner
                    ? () {
                        _showDeleteProductConfirmation(productId);
                      }
                    : null,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRealEstateState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_work_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "No real estate listings yet",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isOwner) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Get.to(
                    () => const UploadRealEstateScreen(),
                  );
                  if (result == true) {
                    await _loadStore();
                  }
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Add Real Estate",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.btnColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRealEstateGrid(List<Map<String, dynamic>> realEstateListings) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.52,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: realEstateListings.length,
            itemBuilder: (context, index) {
              final realEstate = realEstateListings[index];
              final productId = realEstate['_id'] as String? ?? '';
              final category = realEstate['category'] as String? ?? '';

              // Extract property type from category if exists
              String propertyType = 'Real Estate';
              if (category.contains('+')) {
                final parts = category.split('+');
                if (parts.isNotEmpty) {
                  propertyType = parts[0];
                }
              }

              // Handle image URL properly
              final mediaUrls = realEstate['mediaUrls'] as List? ?? [];
              String imageUrl = '';
              if (mediaUrls.isNotEmpty) {
                final url = mediaUrls[0] as String;
                imageUrl = url.startsWith('http')
                    ? url
                    : '${Urls.appApiBaseUrl}$url';
              }

              return ProductCard(
                key: ValueKey(productId),
                title: realEstate['name'] as String? ?? 'Unnamed Property',
                price: '${(realEstate['price'] as num?)?.toDouble() ?? 0.0}',
                image: imageUrl,
                imageType: ImageType.network,
                type: propertyType,
                desc: realEstate['description'] as String? ?? '',
                link: '',
                showOwnerActions: isOwner,
                onEdit: () async {
                  final result = await Get.to(
                    () => EditRealEstateScreen(propertyId: productId),
                  );
                  if (result == true) {
                    await _loadStore();
                  }
                },
                onDelete: () => _showDeleteProductConfirmation(productId),
                onTap: () {
                  Get.to(() => RealEstateDetailScreen(propertyId: productId));
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOrdersState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              "No orders yet",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Orders will appear here when customers\nmake purchases from your store",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get filteredOrders {
    if (selectedOrderStatus == 'all') {
      return orders;
    }
    return orders.where((order) {
      final status = order['status']?.toString().toLowerCase() ?? '';
      if (selectedOrderStatus == 'in progress') {
        return status == 'processing';
      }
      return status == selectedOrderStatus.toLowerCase();
    }).toList();
  }

  Widget _buildOrderFilterChips() {
    final filters = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Pending', 'value': 'pending'},
      {'label': 'In Progress', 'value': 'in progress'},
      {'label': 'Shipped', 'value': 'shipped'},
      {'label': 'Completed', 'value': 'completed'},
      {'label': 'Canceled', 'value': 'cancelled'},
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedOrderStatus == filter['value'];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter['label']!),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedOrderStatus = filter['value']!;
                });
              },
              backgroundColor: Colors.grey[100],
              selectedColor: Colors.green.withOpacity(0.15),
              labelStyle: TextStyle(
                color: isSelected ? Colors.green.shade700 : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              showCheckmark: false,
              side: BorderSide(
                color: isSelected ? Colors.green.shade600 : Colors.grey[300]!,
                width: isSelected ? 1.5 : 1,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrdersList() {
    final displayOrders = filteredOrders;

    if (displayOrders.isEmpty && orders.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.filter_list_off, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                "No ${selectedOrderStatus == 'all' ? '' : selectedOrderStatus} orders found",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: displayOrders.map((order) => _buildOrderCard(order)).toList(),
      ),
    );
  }

  Widget _buildDefaultLogo() {
    return Container(
      height: 110,
      width: 110,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.btnColor.withOpacity(0.2),
            AppColors.btnColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(Icons.store_rounded, size: 55, color: AppColors.btnColor),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.btnColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: AppColors.btnColor),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedStatItem(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.grey.shade700, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final orderId = order['_id'] ?? '';
    final isExpanded = expandedOrderIds.contains(orderId);

    final userId = order['userId'] as Map<String, dynamic>?;
    final productIdField = order['productId'];

    // Extract product ID string
    String? productIdString;
    if (productIdField is String) {
      productIdString = productIdField;
    } else if (productIdField is Map<String, dynamic>) {
      productIdString = productIdField['_id'] as String?;
    }

    final userName = userId?['name'] ?? 'Unknown User';
    final userEmail = userId?['email'] ?? '';
    final quantity = order['quantity'] ?? 0;
    final totalAmount = order['totalAmount'] ?? 0.0;
    final status = order['status'] ?? 'pending';
    final trackingNumber = order['trackingNumber'] ?? '';
    final address = order['address'] ?? '';
    final createdAt = order['createdAt'] ?? '';

    return FutureBuilder<Map<String, dynamic>?>(
      future: productIdString != null
          ? fetchProductById(productIdString)
          : null,
      builder: (context, snapshot) {
        // Get product data from snapshot or use defaults
        final productData = snapshot.data;
        final productName = productData?['name'] ?? 'Product';
        final productMediaUrls = productData?['mediaUrls'] as List? ?? [];

        String productImageUrl = '';
        if (productMediaUrls.isNotEmpty) {
          final url = productMediaUrls[0] as String;
          productImageUrl = url.startsWith('http')
              ? url
              : '${Urls.appApiBaseUrl}$url';
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    if (isExpanded) {
                      expandedOrderIds.remove(orderId);
                    } else {
                      expandedOrderIds.add(orderId);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          // Product Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: productImageUrl.isNotEmpty
                                ? Image.network(
                                    productImageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildDefaultProductImage();
                                    },
                                  )
                                : _buildDefaultProductImage(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Order #${orderId.substring(orderId.length - 8)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _getStatusColor(status),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _getStatusColor(status),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Divider
                      Divider(
                        color: Colors.grey.shade200,
                        thickness: 1,
                        height: 1,
                      ),
                      const SizedBox(height: 12),

                      // Order Summary
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Qty: $quantity',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '\$$totalAmount',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatOrderDate(createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      // Accept/Reject Buttons for Pending Orders
                      if (status.toLowerCase() == 'pending') ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  _handleRejectOrder(orderId);
                                },
                                icon: const Icon(Icons.close, size: 18),
                                label: const Text('Reject'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: BorderSide(color: Colors.red.shade300),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _handleAcceptOrder(orderId);
                                },
                                icon: const Icon(Icons.check, size: 18),
                                label: const Text('Accept'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Mark as Shipped Button for Processing Orders
                      if (status.toLowerCase() == 'processing') ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _handleMarkAsShipped(orderId);
                            },
                            icon: const Icon(
                              Icons.local_shipping_outlined,
                              size: 18,
                            ),
                            label: const Text('Mark as Shipped'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.greenlight,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Expanded Details
              if (isExpanded) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Details Section
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 18,
                            color: AppColors.btnColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Customer Details',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[800],
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow2(Icons.person, 'Name', userName),
                            if (userEmail.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _buildDetailRow2(Icons.email, 'Email', userEmail),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Delivery Address Section
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: AppColors.btnColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Delivery Address',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[800],
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          address.isNotEmpty ? address : 'No address provided',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ),

                      // Tracking Number (if available)
                      if (trackingNumber.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.local_shipping_outlined,
                              size: 18,
                              color: AppColors.btnColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tracking Number',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[800],
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            trackingNumber,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow2(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF4CAF50); // Green
      case 'shipped':
        return const Color(0xFF2196F3); // Blue
      case 'processing':
        return const Color(0xFFFF9800); // Orange
      case 'cancelled':
        return const Color(0xFFF44336); // Red
      case 'pending':
        return const Color(0xFF9E9E9E); // Grey
      case 'all':
        return const Color(0xFF757575); // Dark Grey
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  String _formatOrderDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return '${difference.inMinutes} minutes ago';
        }
        return '${difference.inHours} hours ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return '${months[date.month - 1]} ${date.day}, ${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "N/A";
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${months[date.month - 1]} ${date.year}";
  }

  Widget _buildDefaultProductImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.image_outlined, size: 30, color: Colors.grey.shade400),
    );
  }

  Future<void> _handleAcceptOrder(String orderId) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final token = Preferences.authToken;
      final response = await apiMethod.post(
        url: '/api/order/accept',
        authToken: token,
        body: {'orderId': orderId},
        headers: {},
      );

      // Close loading dialog
      Navigator.pop(context);

      if (response.isSuccess) {
        AppUtils.toast("Order accepted successfully");
        // Reload orders to refresh the list
        _loadOrders(page: 1);
      } else {
        final errorMessage =
            response.data?['message'] ?? "Failed to accept order";
        AppUtils.toast(errorMessage);
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      AppUtils.log("Error accepting order: $e");
      AppUtils.toast("An error occurred while accepting the order");
    }
  }

  Future<void> _handleRejectOrder(String orderId) async {
    // Show confirmation dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Text('Reject Order'),
            ],
          ),
          content: const Text(
            'Are you sure you want to reject this order? This action cannot be undone.',
            style: TextStyle(fontSize: 15, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Reject',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final token = Preferences.authToken;
      final response = await apiMethod.post(
        url: '/api/order/reject',
        authToken: token,
        body: {'orderId': orderId},
        headers: {},
      );

      // Close loading dialog
      Navigator.pop(context);

      if (response.isSuccess) {
        AppUtils.toast("Order rejected and amount refunded");
        // Reload orders to refresh the list
        _loadOrders(page: 1);
      } else {
        final errorMessage =
            response.data?['message'] ?? "Failed to reject order";
        AppUtils.toast(errorMessage);
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      AppUtils.log("Error rejecting order: $e");
      AppUtils.toast("An error occurred while rejecting the order");
    }
  }

  Future<void> _handleMarkAsShipped(String orderId) async {
    // Show dialog to input tracking number
    final trackingController = TextEditingController();

    final trackingNumber = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                color: AppColors.greenlight,
                size: 28,
              ),
              SizedBox(width: 12),
              Text('Mark as Shipped'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the tracking number for this order:',
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: trackingController,
                decoration: InputDecoration(
                  hintText: 'e.g., TRK123456789',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.tag),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final tracking = trackingController.text.trim();
                if (tracking.isEmpty) {
                  AppUtils.toast("Please enter a tracking number");
                  return;
                }
                Navigator.pop(context, tracking);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greenlight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Mark as Shipped',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (trackingNumber == null || trackingNumber.isEmpty) return;

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final token = Preferences.authToken;
      final response = await apiMethod.post(
        url: '/api/order/mark-shipped',
        authToken: token,
        body: {'orderId': orderId, 'trackingNumber': trackingNumber},
        headers: {},
      );

      // Close loading dialog
      Navigator.pop(context);

      if (response.isSuccess) {
        AppUtils.toast("Order marked as shipped successfully");
        // Reload orders to refresh the list
        _loadOrders(page: 1);
      } else {
        final errorMessage =
            response.data?['message'] ?? "Failed to mark order as shipped";
        AppUtils.toast(errorMessage);
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      AppUtils.log("Error marking order as shipped: $e");
      AppUtils.toast("An error occurred while marking the order as shipped");
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              const SizedBox(width: 12),
              const Text('Delete Shop'),
            ],
          ),
          content: const Text(
            'Are you sure you want to delete your shop? This action cannot be undone and all your products will be removed.',
            style: TextStyle(fontSize: 15, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteShop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteShop() async {
    if (myStore == null || myStore!.id == null) {
      AppUtils.toast("Unable to delete shop: Invalid shop ID");
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final token = Preferences.authToken;
      final response = await apiMethod.delete(
        url: Urls.deleteShop(myStore!.id!),
        authToken: token,
      );

      // Close loading dialog
      Navigator.pop(context);

      AppUtils.log("Delete response - isSuccess: ${response.isSuccess}");
      AppUtils.log("Delete response - data: ${response.data}");

      if (response.isSuccess) {
        AppUtils.toast("Shop deleted successfully");
        // Navigate back to previous screen
        Navigator.pop(context);
      } else {
        // Show server error message
        final errorMessage =
            response.data?['message'] ??
            response.data?['error'] ??
            "Failed to delete shop";
        AppUtils.toast(errorMessage);
        AppUtils.log("Delete shop failed: ${response.data}");
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      AppUtils.log("Error deleting shop: $e");
      AppUtils.toast("An error occurred while deleting the shop");
    }
  }

  void _showDeleteProductConfirmation(String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              const SizedBox(width: 12),
              const Text('Delete Product'),
            ],
          ),
          content: const Text(
            'Are you sure you want to delete this product? This action cannot be undone.',
            style: TextStyle(fontSize: 15, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteProduct(productId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final token = Preferences.authToken;
      final response = await apiMethod.delete(
        url: '${Urls.userProduct}/$productId',
        authToken: token,
      );

      // Close loading dialog
      Navigator.pop(context);

      if (response.isSuccess) {
        AppUtils.toast("Product deleted successfully");
        // Reload store to refresh product list
        _loadStore();
      } else {
        final errorMessage =
            response.data?['message'] ??
            response.data?['error'] ??
            "Failed to delete product";
        AppUtils.toast(errorMessage);
        AppUtils.log("Delete product failed: ${response.data}");
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      AppUtils.log("Error deleting product: $e");
      AppUtils.toast("An error occurred while deleting the product");
    }
  }
}
