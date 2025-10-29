import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/feature/data/models/dataModels/user_store/user_store_model.dart';
import 'package:sep/feature/data/models/dataModels/user_store/order_model.dart';

import 'package:sep/feature/presentation/controller/user_store_controller.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/feature/presentation/user_store/add_edit_product_screen.dart';
import 'package:sep/feature/presentation/user_store/create_store_screen.dart';
import 'package:sep/feature/presentation/user_store/product_detail_screen.dart';
import 'package:sep/feature/presentation/SportsProducts/sportsProduct.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/widget.dart';
import 'package:sep/services/networking/urls.dart';

class StoreViewScreen extends StatefulWidget {
  final UserStoreModel store;

  const StoreViewScreen({Key? key, required this.store}) : super(key: key);

  @override
  State<StoreViewScreen> createState() => _StoreViewScreenState();
}

class _StoreViewScreenState extends State<StoreViewScreen>
    with SingleTickerProviderStateMixin {
  final UserStoreController _storeController = Get.find<UserStoreController>();
  late UserStoreModel _store;
  late TabController _tabController;
  String _selectedOrderFilter = 'all';
  final Set<String> _expandedOrderIds = {};
  final Map<String, String> _productImageCache = {}; // Cache for product images
  final Map<String, Map<String, dynamic>> _buyerDetailsCache =
      {}; // Cache for buyer details

  bool get _isOwner {
    final currentUserId = ProfileCtrl.find.profileData.value.id;
    return currentUserId == _store.ownerId;
  }

  // Fetch buyer details by user ID
  Future<Map<String, dynamic>?> _getBuyerDetails(String? userId) async {
    if (userId == null || userId.isEmpty) return null;

    // Check cache first
    if (_buyerDetailsCache.containsKey(userId)) {
      return _buyerDetailsCache[userId];
    }

    try {
      final profileCtrl = Get.find<ProfileCtrl>();
      final userDetails = await profileCtrl.getFriendProfileDetails(userId);

      final details = {
        'name': userDetails.name ?? '',
        'email': userDetails.email ?? '',
        'phone': userDetails.phone ?? '',
        'image': userDetails.image ?? '',
      };

      // Cache the details
      _buyerDetailsCache[userId] = details;
      return details;
    } catch (e) {
      AppUtils.log('Error fetching buyer details: $e');
      return null;
    }
  }

  void _toggleOrderExpansion(String orderId) {
    AppUtils.log('Toggling order expansion for ID: $orderId');
    AppUtils.log('Current expanded IDs: $_expandedOrderIds');
    setState(() {
      if (_expandedOrderIds.contains(orderId)) {
        _expandedOrderIds.remove(orderId);
        AppUtils.log('Removed from expanded set');
      } else {
        _expandedOrderIds.add(orderId);
        AppUtils.log('Added to expanded set');
      }
    });
    AppUtils.log('After toggle expanded IDs: $_expandedOrderIds');
  }

  Future<String> _getProductImage(String? productId) async {
    if (productId == null || productId.isEmpty) return '';

    // Check cache first
    if (_productImageCache.containsKey(productId)) {
      return _productImageCache[productId]!;
    }

    // Fetch product details
    try {
      final product = await _storeController.loadProductDetails(productId);
      if (product != null &&
          product.mediaUrls != null &&
          product.mediaUrls!.isNotEmpty) {
        final imageUrl = Urls.getFullImageUrl(product.mediaUrls!.first);
        _productImageCache[productId] = imageUrl;
        return imageUrl;
      }
    } catch (e) {
      AppUtils.log('Error fetching product image: $e');
    }

    return '';
  }

  @override
  void initState() {
    super.initState();
    _store = widget.store;

    // Debug logging
    final currentUserId = ProfileCtrl.find.profileData.value.id;
    AppUtils.log(
      '==================== STORE VIEW SCREEN INIT ====================',
    );
    AppUtils.log('Store ID: ${_store.id}');
    AppUtils.log('Store Name: ${_store.name}');
    AppUtils.log('Store Owner ID: ${_store.ownerId}');
    AppUtils.log('Current User ID: $currentUserId');
    AppUtils.log('Is Owner: $_isOwner');
    AppUtils.log(
      '================================================================',
    );

    // Initialize tab controller with 2 tabs if owner, 1 tab if not owner
    final tabCount = _isOwner ? 2 : 1;
    _tabController = TabController(length: tabCount, vsync: this);

    // Schedule ALL data loading after the build phase completes
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadStoreDetails();
      if (_isOwner) {
        AppUtils.log('User is owner, loading seller orders...');
        await _loadSellerOrders();
      } else {
        AppUtils.log('User is NOT owner, skipping seller orders load');
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStoreDetails() async {
    // If store only has ID, load full details
    if (_store.id != null && _store.id!.isNotEmpty) {
      await _storeController.loadShopById(_store.id!);

      // Update local store with loaded data
      if (_storeController.selectedShopForViewing.value != null) {
        if (mounted) {
          setState(() {
            _store = _storeController.selectedShopForViewing.value!;
          });
        }
      }
    }
  }

  Future<void> _refreshStoreData() async {
    // Refresh both store details and products
    await _loadStoreDetails();
    if (_isOwner) {
      await _loadSellerOrders();
    }
  }

  Future<void> _loadSellerOrders() async {
    AppUtils.log('StoreViewScreen: Calling loadSellerOrders...');
    await _storeController.loadSellerOrders();
    AppUtils.log('StoreViewScreen: loadSellerOrders completed');
    AppUtils.log(
      'StoreViewScreen: userOrders count = ${_storeController.userOrders.length}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          AppBar2(
            title: _store.name,
            titleStyle: 18.txtMediumBlack,
            prefixImage: "back",
            onPrefixTap: () => Navigator.pop(context),
            backgroundColor: AppColors.white,
            hasTopSafe: true,
            suffixWidget: _isOwner
                ? PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.black),
                    onSelected: _handleMenuAction,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            8.width,
                            Text('Edit Store'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            8.width,
                            Text(
                              'Delete Store',
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
            child: SingleChildScrollView(
              padding: 16.allSide,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStoreHeaderAndInfo(),
                  24.height,
                  // Tab Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25.sdp),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.sdp),
                        color: AppColors.btnColor,
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.grey,
                      labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      tabs: _isOwner
                          ? [Tab(text: "Products"), Tab(text: "Orders")]
                          : [Tab(text: "Products")],
                    ),
                  ),
                  24.height,
                  // Tab Content (without TabBarView)
                  SizedBox(
                    height: 600.sdp, // Adjust height as needed
                    child: TabBarView(
                      controller: _tabController,
                      children: _isOwner
                          ? [_buildProductsTab(), _buildOrdersTab()]
                          : [_buildProductsTab()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreHeaderAndInfo() {
    return Container(
      width: double.infinity,
      padding: 20.allSide,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store Logo - Left Side
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 100.sdp,
              height: 100.sdp,
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Builder(
                  builder: (context) {
                    final fullLogoUrl = Urls.getFullImageUrl(_store.logoUrl);
                    final hasLogo = (_store.logoUrl ?? '').isNotEmpty;

                    return ImageView(
                      url: hasLogo ? fullLogoUrl : '',
                      fit: BoxFit.fill,
                      width: 100,
                      height: 98,
                      imageType: hasLogo ? ImageType.network : ImageType.asset,
                      defaultImage: AppImages.dummyProfile,
                    );
                  },
                ),
              ),
            ),
          ),
          16.width,

          // Store Info - Right Side
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Store Name
                TextView(text: _store.name ?? '', style: 20.txtMediumBlack),
                8.height,

                // Store Description
                TextView(
                  text: _store.description ?? '',
                  style: 14.txtRegularGrey,
                  maxlines: 2,
                ),
                16.height,

                // Store Information
                _buildInfoRow(
                  Icons.location_on,
                  'Address',
                  _store.address ?? '',
                ),
                8.height,
                _buildInfoRow(Icons.email, 'Email', _store.contactEmail ?? ''),
                8.height,
                _buildInfoRow(Icons.phone, 'Phone', _store.contactPhone ?? ''),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.sdp, color: AppColors.btnColor),
        8.width,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextView(text: label, style: 12.txtRegularGrey),
              2.height,
              TextView(text: value, style: 14.txtMediumBlack),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductsTab() {
    return RefreshIndicator(
      onRefresh: _refreshStoreData,
      color: AppColors.btnColor,
      child: SingleChildScrollView(
        padding: 16.allSide,
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add Product Button at top right - only for own store
            if (_storeController.currentUserStore.value?.id == _store.id) ...[
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _navigateToAddProduct,
                  child: Container(
                    width: 130.sdp,
                    height: 40.sdp,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.btnColor, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Add Product',
                      style: 14.txtMediumBlack.copyWith(
                        color: AppColors.btnColor,
                      ),
                    ),
                  ),
                ),
              ),
              16.height,
            ],

            // Products List
            Obx(() {
              final products = _storeController.shopProducts;
              final isLoading = _storeController.isLoadingProducts.value;

              if (isLoading && products.isEmpty) {
                return Center(
                  child: Padding(
                    padding: 40.allSide,
                    child: CircularProgressIndicator(color: AppColors.btnColor),
                  ),
                );
              }

              if (products.isEmpty) {
                return _buildEmptyProductsState();
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                  mainAxisExtent: 330,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _buildProductCard(product);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab() {
    final orderStatuses = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Pending', 'value': 'pending'},
      {'label': 'Accepted', 'value': 'accepted'},
      {'label': 'Shipped', 'value': 'shipped'},
      {'label': 'Completed', 'value': 'completed'},
      {'label': 'Canceled', 'value': 'canceled'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: orderStatuses.map((status) {
              final isSelected = _selectedOrderFilter == status['value'];
              return Padding(
                padding: EdgeInsets.only(right: 8.sdp),
                child: FilterChip(
                  label: Text(status['label']!),
                  selected: isSelected,
                  showCheckmark: false,
                  onSelected: (selected) {
                    setState(() {
                      _selectedOrderFilter = status['value']!;
                    });
                  },
                  selectedColor: AppColors.btnColor,
                  backgroundColor: AppColors.grey.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.sdp,
                    vertical: 8.sdp,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.btnColor
                          : AppColors.grey.withOpacity(0.3),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        16.height,

        // Orders List
        Expanded(
          child: Obx(() {
            final allOrders = _storeController.userOrders;
            final isLoading = _storeController.isLoadingOrders.value;

            // Apply filter
            List<OrderModel> filteredOrders;
            if (_selectedOrderFilter == 'all') {
              filteredOrders = allOrders;
            } else if (_selectedOrderFilter == 'accepted') {
              // For 'accepted' filter, show both 'accepted' and 'processing' orders
              filteredOrders = allOrders
                  .where(
                    (order) =>
                        order.status.toLowerCase() == 'accepted' ||
                        order.status.toLowerCase() == 'processing',
                  )
                  .toList();
            } else if (_selectedOrderFilter == 'canceled') {
              // For 'canceled' filter, show both 'canceled' and 'rejected' orders
              filteredOrders = allOrders
                  .where(
                    (order) =>
                        order.status.toLowerCase() == 'canceled' ||
                        order.status.toLowerCase() == 'cancelled' ||
                        order.status.toLowerCase() == 'rejected',
                  )
                  .toList();
            } else {
              // For other filters, match exact status
              filteredOrders = allOrders
                  .where(
                    (order) =>
                        order.status.toLowerCase() ==
                        _selectedOrderFilter.toLowerCase(),
                  )
                  .toList();
            }

            if (isLoading && allOrders.isEmpty) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.btnColor),
              );
            }

            if (filteredOrders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48.sdp,
                      color: AppColors.grey,
                    ),
                    16.height,
                    TextView(
                      text: _selectedOrderFilter == 'all'
                          ? 'No Orders Yet'
                          : 'No ${_selectedOrderFilter.capitalize} Orders',
                      style: 16.txtMediumBlack,
                    ),
                    8.height,
                    TextView(
                      text: 'Orders will appear here',
                      style: 14.txtRegularGrey,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _loadSellerOrders,
              color: AppColors.btnColor,
              child: ListView.builder(
                padding: 16.allSide,
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = filteredOrders[index];
                  return _buildOrderCard(order);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildProductCard(product) {
    final hasImage = product.mediaUrls != null && product.mediaUrls!.isNotEmpty;
    final rawImageUrl = hasImage ? product.mediaUrls!.first : '';
    final imageUrl = Urls.getFullImageUrl(rawImageUrl);
    final imageType = hasImage && imageUrl.isNotEmpty
        ? ImageType.network
        : ImageType.asset;
    final availabilityStatus = (product.isAvailable ?? false)
        ? 'In Stock'
        : 'Out of Stock';

    // Debug logging
    AppUtils.log("Store Product Card - Name: ${product.name}");
    AppUtils.log("Store Product Card - Media URLs: ${product.mediaUrls}");
    AppUtils.log("Store Product Card - Raw Image URL: $rawImageUrl");
    AppUtils.log("Store Product Card - Full Image URL: $imageUrl");
    AppUtils.log("Store Product Card - Image Type: $imageType");

    return ProductCard(
      title: product.name ?? '',
      image: imageUrl.isNotEmpty ? imageUrl : AppImages.dummyProfile,
      imageType: imageType,
      price: product.price?.toStringAsFixed(2) ?? '0.00',
      desc: product.description ?? '',
      type: availabilityStatus,
      link: '', // No external link for store products
      isSepProduct: false, // Mark as app product
      showActions: _isOwner, // Show edit/delete for owner, buy now for others
      onTap: () async {
        // Load full product details and navigate to detail screen
        final details = await _storeController.loadProductDetails(
          product.id ?? '',
        );
        if (details != null) {
          Get.to(() => ProductDetailScreen(product: details));
        } else {
          AppUtils.toast('Failed to load product details');
        }
      },
      onBuyNow: !_isOwner
          ? () async {
              // For non-owners, navigate to product detail screen
              final details = await _storeController.loadProductDetails(
                product.id ?? '',
              );
              if (details != null) {
                Get.to(() => ProductDetailScreen(product: details));
              } else {
                AppUtils.toast('Failed to load product details');
              }
            }
          : null,
      onEdit: _isOwner
          ? () async {
              final result = await Get.to(
                () => AddEditProductScreen(product: product),
              );
              if (result == true) {
                // Refresh products list
                await _storeController.loadProductsByShop(_store.id ?? '');
                if (mounted) {
                  setState(() {
                    // Force rebuild to show updated products
                  });
                }
              }
            }
          : null,
      onDelete: _isOwner ? () => _showDeleteProductConfirmation(product) : null,
    );
  }

  Widget _buildEmptyProductsState() {
    return Container(
      width: double.infinity,
      padding: 40.allSide,
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 48.sdp, color: AppColors.grey),
          16.height,
          TextView(text: 'No Products Yet', style: 16.txtMediumBlack),
          8.height,
          TextView(
            text: 'Start adding products to your store',
            style: 14.txtRegularGrey,
            textAlign: TextAlign.center,
          ),
          24.height,
          GestureDetector(
            onTap: _navigateToAddProduct,
            child: Container(
              width: 200.sdp,
              height: 48.sdp,
              decoration: BoxDecoration(
                color: AppColors.btnColor,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text('Add Your First Product', style: 14.txtMediumWhite),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        _navigateToEditStore();
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  void _navigateToEditStore() async {
    final result = await Get.to(() => CreateStoreScreen(store: _store));
    if (result == true) {
      // Refresh store data from API
      await _loadStoreDetails();
    }
  }

  void _navigateToAddProduct() async {
    final result = await Get.to(() => AddEditProductScreen());
    if (result == true) {
      // Refresh products list from API
      await _storeController.loadProductsByShop(_store.id ?? '');
      if (mounted) {
        setState(() {
          // Force rebuild to show updated products
        });
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Store'),
        content: Text(
          'Are you sure you want to delete this store? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteStore();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteStore() async {
    try {
      await _storeController.deleteStore(_store.id ?? '');
      // Wait a bit for the store to be properly deleted and reloaded
      await Future.delayed(const Duration(milliseconds: 500));
      AppUtils.toast('Store deleted successfully');
      // Navigate back and signal refresh
      Get.back(result: true);
    } catch (e) {
      AppUtils.toast('Failed to delete store: $e');
    }
  }

  void _showDeleteProductConfirmation(product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProduct(product);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(product) async {
    try {
      await _storeController.deleteProduct(product.id ?? '');
      // Refresh products list
      await _storeController.loadProductsByShop(_store.id ?? '');
      AppUtils.toast('Product deleted successfully');
    } catch (e) {
      AppUtils.toast('Failed to delete product: $e');
    }
  }

  Widget _buildOrderCard(order) {
    // Use a unique identifier - prefer id, but fallback to productId + createdAt
    final orderId =
        order.id ??
        '${order.productId}_${order.createdAt?.millisecondsSinceEpoch ?? 0}';
    final isExpanded = _expandedOrderIds.contains(orderId);

    AppUtils.log(
      'Building seller order card for ID: $orderId, isExpanded: $isExpanded',
    );

    return GestureDetector(
      onTap: () {
        _toggleOrderExpansion(orderId);
      },
      child: Container(
        margin: 12.bottom,
        padding: 16.allSide,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main order info - Always visible
            Row(
              children: [
                // Product image with FutureBuilder
                FutureBuilder<String>(
                  future: _getProductImage(order.productId),
                  builder: (context, snapshot) {
                    final hasImage =
                        snapshot.hasData && snapshot.data!.isNotEmpty;

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 60.sdp,
                        height: 60.sdp,
                        decoration: BoxDecoration(
                          color: AppColors.btnColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: hasImage
                            ? ImageView(
                                url: snapshot.data!,
                                fit: BoxFit.cover,
                                width: 60,
                                height: 60,
                                imageType: ImageType.network,
                                defaultImage: AppImages.dummyProfile,
                              )
                            : Icon(
                                Icons.shopping_bag,
                                color: AppColors.btnColor,
                                size: 30.sdp,
                              ),
                      ),
                    );
                  },
                ),
                16.width,

                // Product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextView(
                        text: order.productName ?? 'Unknown Product',
                        style: 16.txtMediumBlack,
                        maxlines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      4.height,
                      TextView(
                        text:
                            'Qty: ${order.quantity} × \$${(order.productPrice ?? 0.0).toStringAsFixed(2)}',
                        style: 14.txtRegularGrey,
                      ),
                      4.height,
                      TextView(
                        text:
                            'Total: \$${(order.totalAmount ?? 0.0).toStringAsFixed(2)}',
                        style: 16.txtMediumBlack.copyWith(
                          color: AppColors.btnColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildOrderStatus(order.status),
                    8.height,
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.grey,
                      size: 24.sdp,
                    ),
                  ],
                ),
              ],
            ),

            // Expanded details
            if (isExpanded) ...[
              16.height,
              Divider(color: AppColors.grey.withOpacity(0.3)),
              16.height,
              _buildExpandedDetails(order),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedDetails(order) {
    return Container(
      padding: 12.allSide,
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextView(text: 'Order Details', style: 14.txtMediumBlack),
          12.height,

          // Buyer Information Section with FutureBuilder
          FutureBuilder<Map<String, dynamic>?>(
            future: _getBuyerDetails(order.userId),
            builder: (context, snapshot) {
              // Use basic info from order while loading, or full details when loaded
              final buyerName = snapshot.hasData && snapshot.data != null
                  ? (snapshot.data!['name']?.toString() ??
                        order.buyerName ??
                        'N/A')
                  : (order.buyerName ?? 'N/A');

              final buyerEmail = snapshot.hasData && snapshot.data != null
                  ? (snapshot.data!['email']?.toString() ??
                        order.buyerEmail ??
                        '')
                  : (order.buyerEmail ?? '');

              final buyerPhone = snapshot.hasData && snapshot.data != null
                  ? (snapshot.data!['phone']?.toString() ?? '')
                  : '';

              final buyerImage = snapshot.hasData && snapshot.data != null
                  ? (snapshot.data!['image']?.toString() ?? '')
                  : '';

              final fullBuyerImageUrl = Urls.getFullImageUrl(buyerImage);
              final hasBuyerImage = buyerImage.isNotEmpty;

              return Container(
                padding: 12.allSide,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextView(
                      text: 'Buyer Information',
                      style: 13.txtMediumBlack,
                    ),
                    12.height,
                    Row(
                      children: [
                        // Buyer profile image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            width: 50.sdp,
                            height: 50.sdp,
                            decoration: BoxDecoration(
                              color: AppColors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: hasBuyerImage
                                ? ImageView(
                                    url: fullBuyerImageUrl,
                                    fit: BoxFit.cover,
                                    width: 50,
                                    height: 50,
                                    imageType: ImageType.network,
                                    defaultImage: AppImages.dummyProfile,
                                  )
                                : Icon(
                                    Icons.person,
                                    color: AppColors.grey,
                                    size: 25.sdp,
                                  ),
                          ),
                        ),
                        12.width,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextView(
                                text: buyerName,
                                style: 14.txtMediumBlack,
                              ),
                              4.height,
                              if (buyerEmail.isNotEmpty) ...[
                                Row(
                                  children: [
                                    Icon(
                                      Icons.email,
                                      size: 14,
                                      color: AppColors.grey,
                                    ),
                                    4.width,
                                    Expanded(
                                      child: TextView(
                                        text: buyerEmail,
                                        style: 12.txtRegularGrey,
                                        maxlines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                4.height,
                              ],
                              if (buyerPhone.isNotEmpty)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      size: 14,
                                      color: AppColors.grey,
                                    ),
                                    4.width,
                                    TextView(
                                      text: buyerPhone,
                                      style: 12.txtRegularGrey,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          12.height,

          if (order.address != null && order.address!.isNotEmpty)
            _buildDetailRow('Address', order.address!),

          if (order.trackingNumber != null && order.trackingNumber!.isNotEmpty)
            _buildDetailRow('Tracking', order.trackingNumber!),

          if (order.createdAt != null)
            _buildDetailRow(
              'Ordered',
              '${order.createdAt!.day.toString().padLeft(2, '0')}/${order.createdAt!.month.toString().padLeft(2, '0')}/${order.createdAt!.year} at ${order.createdAt!.hour.toString().padLeft(2, '0')}:${order.createdAt!.minute.toString().padLeft(2, '0')}',
            ),

          if (order.updatedAt != null && order.status != 'pending')
            _buildDetailRow(
              'Updated',
              '${order.updatedAt!.day.toString().padLeft(2, '0')}/${order.updatedAt!.month.toString().padLeft(2, '0')}/${order.updatedAt!.year} at ${order.updatedAt!.hour.toString().padLeft(2, '0')}:${order.updatedAt!.minute.toString().padLeft(2, '0')}',
            ),

          // Action buttons for pending orders
          if (order.status.toLowerCase() == 'pending') ...[
            16.height,
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40.sdp,
                    child: ElevatedButton(
                      onPressed: () => _acceptOrder(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.greenlight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: TextView(text: 'Accept', style: 14.txtMediumWhite),
                    ),
                  ),
                ),
                12.width,
                Expanded(
                  child: Container(
                    height: 40.sdp,
                    child: OutlinedButton(
                      onPressed: () => _rejectOrder(order),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: TextView(
                        text: 'Reject',
                        style: 14.txtMediumBlack.copyWith(color: AppColors.red),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Action button for accepted orders
          if (order.status.toLowerCase() == 'accepted' ||
              order.status.toLowerCase() == 'processing') ...[
            16.height,
            Container(
              width: double.infinity,
              height: 40.sdp,
              child: ElevatedButton.icon(
                onPressed: () => _markAsShipped(order),
                icon: Icon(Icons.local_shipping, size: 18),
                label: TextView(
                  text: 'Mark as Shipped',
                  style: 14.txtMediumWhite,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.btnColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderStatus(String status) {
    Color statusColor;
    String statusText;

    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = AppColors.orange;
        statusText = 'Pending';
        break;
      case 'accepted':
        statusColor = Colors.yellow;
        statusText = 'Accepted';
        break;
      case 'rejected':
        statusColor = AppColors.red;
        statusText = 'Rejected';
        break;
      case 'processing':
        statusColor = AppColors.btnColor;
        statusText = 'Processing';
        break;
      case 'shipped':
        statusColor = AppColors.green;
        statusText = 'Shipped';
        break;
      case 'delivered':
        statusColor = AppColors.green;
        statusText = 'Delivered';
        break;
      case 'completed':
        statusColor = AppColors.greenlight;
        statusText = 'Completed';
        break;
      case 'cancelled':
      case 'canceled':
        statusColor = AppColors.red;
        statusText = 'Canceled';
        break;
      default:
        statusColor = AppColors.grey;
        statusText = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: TextView(
        text: statusText,
        style: 12.txtMediumBlack.copyWith(color: statusColor),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: 6.bottom,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.sdp,
            child: TextView(text: '$label:', style: 12.txtRegularGrey),
          ),
          8.width,
          Expanded(
            child: TextView(
              text: value,
              style: 12.txtMediumBlack,
              maxlines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _acceptOrder(order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.greenlight),
            8.width,
            Text('Accept Order'),
          ],
        ),
        content: Text('Are you sure you want to accept this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Call accept order API
              final success = await _storeController.acceptOrder(order.id);

              // Reload orders if successful
              if (success) {
                await _loadSellerOrders();
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.greenlight),
            child: Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _rejectOrder(order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.cancel, color: AppColors.red),
            8.width,
            Text('Reject Order'),
          ],
        ),
        content: Text(
          'Are you sure you want to reject this order? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Call reject order API
              final success = await _storeController.rejectOrder(order.id);

              // Reload orders if successful
              if (success) {
                await _loadSellerOrders();
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _markAsShipped(order) {
    final trackingController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.local_shipping, color: AppColors.btnColor),
            8.width,
            Text('Mark as Shipped'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter tracking number for this shipment:'),
            16.height,
            TextField(
              controller: trackingController,
              decoration: InputDecoration(
                labelText: 'Tracking Number',
                hintText: 'e.g., TRK123456789',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.numbers),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final trackingNumber = trackingController.text.trim();

              if (trackingNumber.isEmpty) {
                AppUtils.toastError('Please enter a tracking number');
                return;
              }

              Navigator.pop(context);

              // Call mark as shipped API
              final success = await _storeController.markAsShipped(
                order.id,
                trackingNumber,
              );

              // Reload orders if successful
              if (success) {
                await _loadSellerOrders();
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.btnColor),
            child: Text('Mark as Shipped'),
          ),
        ],
      ),
    );
  }
}
