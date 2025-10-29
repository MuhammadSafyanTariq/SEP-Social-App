import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/coreComponents/TextView.dart';

import 'package:sep/components/coreComponents/editText.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/components/styles/app_strings.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import 'package:sep/feature/presentation/SportsProducts/productDetailScreen.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';

import 'package:sep/utils/extensions/widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sep/feature/presentation/controller/user_store_controller.dart';
import 'package:sep/feature/presentation/user_store/create_store_screen.dart';
import 'package:sep/feature/presentation/user_store/store_view_screen.dart';
import 'package:sep/feature/presentation/user_store/product_detail_screen.dart';
import 'package:sep/feature/presentation/user_store/buyer_orders_screen.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/services/networking/urls.dart';

import '../controller/auth_Controller/product_ctrl.dart';

class SportsProduct extends StatefulWidget {
  const SportsProduct({super.key});

  @override
  State<SportsProduct> createState() => _SportsProductState();
}

class _SportsProductState extends State<SportsProduct>
    with SingleTickerProviderStateMixin {
  final ProductCtrl ctrl = ProductCtrl.find;
  final _refreshCtrlSepShop = RefreshController(initialRefresh: false);
  final _refreshCtrlAllProducts = RefreshController(initialRefresh: false);
  final _search = TextEditingController();
  String _searchQuery = '';
  int pageNo = 1;
  late TabController _tabController;
  bool _hasLoadedAllProducts = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Listen for tab changes to load products when switching to "All Products" tab
    _tabController.addListener(() {
      if (_tabController.index == 1 && !_hasLoadedAllProducts) {
        _hasLoadedAllProducts = true;
        // Schedule state updates after current frame to avoid build conflicts
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final storeController = UserStoreController.find;
          // Reload store to ensure we have latest data
          storeController.loadUserStore();
          storeController.loadMyProducts(page: 1, limit: 20);
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await loadData(isRefresh: true);
      // Load user's store status without blocking
      final storeController = UserStoreController.find;
      storeController.loadUserStore();
    });
  }

  @override
  void dispose() {
    _refreshCtrlSepShop.dispose();
    _refreshCtrlAllProducts.dispose();
    _tabController.dispose();
    _search.dispose();
    super.dispose();
  }

  // Calculate similarity between two strings (0-100%)
  double _calculateSimilarity(String str1, String str2) {
    if (str1.isEmpty || str2.isEmpty) return 0;

    str1 = str1.toLowerCase();
    str2 = str2.toLowerCase();

    // Exact match
    if (str1 == str2) return 100;

    // Contains check
    if (str1.contains(str2) || str2.contains(str1)) {
      return 80;
    }

    // Levenshtein distance for fuzzy matching
    final maxLen = str1.length > str2.length ? str1.length : str2.length;
    final distance = _levenshteinDistance(str1, str2);
    final similarity = ((maxLen - distance) / maxLen) * 100;

    return similarity;
  }

  // Levenshtein distance algorithm
  int _levenshteinDistance(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;

    final matrix = List.generate(len1 + 1, (i) => List.filled(len2 + 1, 0));

    for (var i = 0; i <= len1; i++) {
      matrix[i][0] = i;
    }

    for (var j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i <= len1; i++) {
      for (var j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[len1][len2];
  }

  // Filter SEP Shop products by search query
  List<dynamic> _filterSepShopProducts(List<dynamic> products) {
    if (_searchQuery.isEmpty) return products;

    return products.where((product) {
      final productName = (product.name ?? '').toLowerCase();
      final similarity = _calculateSimilarity(productName, _searchQuery);
      return similarity >= 60; // 60% similarity threshold
    }).toList();
  }

  // Filter All Products (user store products) by search query
  List<T> _filterAllProducts<T>(List<T> products) {
    if (_searchQuery.isEmpty) return products;

    return products.where((product) {
      final productName = (product as dynamic).name ?? '';
      final similarity = _calculateSimilarity(
        productName.toLowerCase(),
        _searchQuery,
      );
      return similarity >= 60; // 60% similarity threshold
    }).toList();
  }

  Future loadData({bool isRefresh = false, bool isLoadMore = false}) async {
    await ctrl.getProducts(
      page: pageNo,
      isLoadMore: isLoadMore,
      isRefresh: isRefresh,
      search: _search.getText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: 12.horizontal,
              child: EditText(
                controller: _search,
                hint: AppStrings.search.tr,
                radius: 20.sdp,
                prefixIcon: Icon(Icons.search, color: AppColors.grey),
                onChange: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase().trim();
                  });
                },
              ),
            ),
            12.height,
            // Tab Bar
            Container(
              margin: 12.horizontal,
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25.sdp),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.sdp),
                  color: AppColors.greenlight,
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
                tabs: [
                  Tab(text: "SEP Shop"),
                  Tab(text: "All Products"),
                ],
              ),
            ),
            20.height,
            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // SEP Shop Tab - Current Logic
                  Padding(
                    padding: 12.horizontal,
                    child: SmartRefresher(
                      controller: _refreshCtrlSepShop,
                      enablePullDown: true,
                      enablePullUp: true,
                      onLoading: () => loadData().then((value) {
                        _refreshCtrlSepShop.loadComplete();
                      }),
                      onRefresh: () => loadData().then((value) {
                        _refreshCtrlSepShop.refreshCompleted();
                      }),
                      footer: CustomFooter(
                        builder: (context, mode) {
                          Widget? body;

                          if (mode == LoadStatus.loading) {
                            body = CupertinoActivityIndicator();
                            return Container(
                              height: 55.0,
                              child: Center(child: body),
                            );
                          }
                          return SizedBox();
                        },
                      ),
                      child: Obx(() {
                        final allProducts = ctrl.productListing;
                        final filteredProducts = _filterSepShopProducts(
                          allProducts,
                        );
                        final isLoading = ctrl.isLoadingProducts.value;

                        if (isLoading && filteredProducts.isEmpty) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: AppColors.btnColor,
                            ),
                          );
                        }

                        return filteredProducts.isEmpty
                            ? Center(
                                child: TextView(
                                  text: _searchQuery.isEmpty
                                      ? 'No Product found'
                                      : 'No products match "$_searchQuery"',
                                  style: 16.txtBoldBlack,
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 0.8,
                                      mainAxisExtent: 330,
                                    ),
                                itemCount: filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = filteredProducts[index];

                                  final hasImage =
                                      product.images != null &&
                                      product.images!.isNotEmpty &&
                                      product.images![0].isNotEmpty;

                                  final rawImageUrl = hasImage
                                      ? product.images![0]
                                      : AppImages.dummyProfile;

                                  final fullImageUrl = hasImage
                                      ? Urls.getFullImageUrl(rawImageUrl)
                                      : rawImageUrl;

                                  AppUtils.log("image>>>>>>${rawImageUrl}");
                                  final imageType = hasImage
                                      ? ImageType.network
                                      : ImageType.asset;

                                  return ProductCard(
                                    link: product.checkouturl ?? "",
                                    title: product.title ?? '',
                                    image: fullImageUrl,
                                    imageType: imageType,
                                    price: product.price ?? '',
                                    desc: product.description ?? '',
                                    type: product.shippingType ?? "",
                                    isSepProduct:
                                        true, // Explicitly mark as SEP product
                                    onTap: () {
                                      context.pushNavigator(
                                        Productdetailscreen(data: product),
                                      );
                                    },
                                  );
                                },
                              );
                      }),
                    ),
                  ),
                  // All Products Tab - Store Creation
                  _buildAllProductsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllProductsTab() {
    final storeController = UserStoreController.find;

    return Column(
      children: [
        // Store Action Button at the top
        Obx(() {
          final hasStore = storeController.hasStore;
          final isLoadingStore = storeController.isLoadingStores.value;

          return Container(
            margin: 16.allSide,
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: isLoadingStore
                        ? 'Loading...'
                        : hasStore
                        ? 'My Store'
                        : 'Create Store',
                    onTap: isLoadingStore
                        ? null
                        : hasStore
                        ? () {
                            // Navigate immediately if we have store data
                            if (storeController.currentUserStore.value !=
                                null) {
                              _navigateToStoreView(
                                storeController.currentUserStore.value!,
                              );
                            } else {
                              // Schedule reload after current frame to avoid build conflicts
                              WidgetsBinding.instance.addPostFrameCallback((
                                _,
                              ) async {
                                await storeController.loadUserStore();
                                if (storeController.currentUserStore.value !=
                                    null) {
                                  _navigateToStoreView(
                                    storeController.currentUserStore.value!,
                                  );
                                }
                              });
                            }
                          }
                        : _navigateToCreateStore,
                    height: 48.sdp,
                    buttonColor: hasStore
                        ? AppColors.btnColor
                        : AppColors.greenlight,
                    isLoading: isLoadingStore,
                  ),
                ),
                12.width,
                Container(
                  height: 48.sdp,
                  width: 48.sdp,
                  decoration: BoxDecoration(
                    color: AppColors.btnColor,
                    borderRadius: BorderRadius.circular(16.sdp),
                  ),
                  child: IconButton(
                    onPressed: () {
                      // Navigate to buyer order history
                      Get.to(() => BuyerOrdersScreen());
                    },
                    icon: Icon(
                      Icons.receipt_long,
                      color: Colors.white,
                      size: 24.sdp,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          );
        }),

        // Products Grid
        Expanded(
          child: Obx(() {
            final allProducts = storeController.allProducts;
            final currentUserStoreId =
                storeController.currentUserStore.value?.id;

            // Filter out products from current user's store
            var filteredProducts = allProducts.where((product) {
              final isOwnProduct = product.storeId == currentUserStoreId;
              return !isOwnProduct;
            }).toList();

            // Apply search filter
            filteredProducts = _filterAllProducts(filteredProducts);

            final isLoading = storeController.isLoadingAllProducts.value;

            if (isLoading && filteredProducts.isEmpty) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.btnColor),
              );
            }

            if (filteredProducts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 80.sdp,
                      color: AppColors.grey,
                    ),
                    16.height,
                    TextView(
                      text: 'No Products Available',
                      style: 18.txtMediumBlack,
                    ),
                    8.height,
                    TextView(
                      text: 'Check back later for new products',
                      style: 14.txtRegularGrey,
                    ),
                  ],
                ),
              );
            }

            return SmartRefresher(
              controller: _refreshCtrlAllProducts,
              enablePullDown: true,
              enablePullUp: true,
              onLoading: () {
                final currentPage = (allProducts.length / 20).ceil() + 1;
                storeController
                    .loadMyProducts(page: currentPage, limit: 20)
                    .then((_) {
                      _refreshCtrlAllProducts.loadComplete();
                    });
              },
              onRefresh: () async {
                _hasLoadedAllProducts =
                    true; // Mark as loaded to prevent infinite loop
                // Refresh both store status and products
                await Future.wait([
                  storeController.loadUserStore(),
                  storeController.loadMyProducts(page: 1, limit: 20),
                ]);
                _refreshCtrlAllProducts.refreshCompleted();
              },
              footer: CustomFooter(
                builder: (context, mode) {
                  if (mode == LoadStatus.loading) {
                    return Container(
                      height: 55.0,
                      child: Center(child: CupertinoActivityIndicator()),
                    );
                  }
                  return SizedBox();
                },
              ),
              child: GridView.builder(
                padding: 16.allSide,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                  mainAxisExtent: 330,
                ),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return _buildUserProductCard(product);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildUserProductCard(product) {
    final hasImage = product.mediaUrls != null && product.mediaUrls!.isNotEmpty;
    final rawImageUrl = hasImage ? product.mediaUrls!.first : '';
    final imageUrl = Urls.getFullImageUrl(rawImageUrl);
    final imageType = hasImage && imageUrl.isNotEmpty
        ? ImageType.network
        : ImageType.asset;
    final availabilityStatus = (product.isAvailable ?? false)
        ? 'In Stock'
        : 'Out of Stock';

    // Debug logging for user product images
    AppUtils.log("User Product: ${product.name}");
    AppUtils.log("Media URLs: ${product.mediaUrls}");
    AppUtils.log("Raw Image URL: $rawImageUrl");
    AppUtils.log("Full Image URL: $imageUrl");
    AppUtils.log("Image Type: $imageType");

    return ProductCard(
      title: product.name ?? '',
      image: imageUrl.isNotEmpty ? imageUrl : AppImages.dummyProfile,
      imageType: imageType,
      price: product.price?.toStringAsFixed(2) ?? '0.00',
      desc: product.description ?? '',
      type: availabilityStatus,
      link: '', // No external link for user products
      isSepProduct: false, // This is an app product
      onTap: () async {
        // Load full product details and navigate to detail screen
        final details = await UserStoreController.find.loadProductDetails(
          product.id ?? '',
        );
        if (details != null) {
          Get.to(() => ProductDetailScreen(product: details));
        } else {
          AppUtils.toast('Failed to load product details');
        }
      },
      onBuyNow: () async {
        // Buy Now action for app products - navigate to product detail
        final details = await UserStoreController.find.loadProductDetails(
          product.id ?? '',
        );
        if (details != null) {
          Get.to(() => ProductDetailScreen(product: details));
        } else {
          AppUtils.toast('Failed to load product details');
        }
      },
    );
  }

  void _navigateToCreateStore() async {
    final storeController = Get.find<UserStoreController>();
    final result = await Get.to(() => CreateStoreScreen());
    if (result == true) {
      // Reload the store to update the button
      await storeController.loadUserStore();
      if (mounted) {
        setState(() {
          // Refresh UI - force rebuild to show updated button
        });
      }
    }
  }

  void _navigateToStoreView(store) async {
    final result = await Get.to(() => StoreViewScreen(store: store));

    // Reload store if something changed (like deletion)
    if (result == true) {
      final storeController = Get.find<UserStoreController>();
      await storeController.loadUserStore();
      if (mounted) {
        setState(() {
          // Refresh UI - force rebuild to show updated button
        });
      }
    }
  }
}

class ProductCard extends StatelessWidget {
  final String title;
  final String type;
  final String link;
  final String image;
  final String price;
  final String desc;
  final VoidCallback onTap;
  final ImageType imageType;
  final bool showActions; // Show edit/delete instead of buy button
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isSepProduct; // New parameter to distinguish product type
  final VoidCallback? onBuyNow; // New callback for Buy Now action

  const ProductCard({
    super.key,
    required this.title,
    required this.type,
    required this.link,
    required this.image,
    required this.price,
    required this.onTap,
    required this.desc,
    required this.imageType,
    this.showActions = false,
    this.onEdit,
    this.onDelete,
    this.isSepProduct =
        true, // Default to SEP product for backward compatibility
    this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.sdp),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.sdp),
          border: Border.all(color: Colors.grey[300]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image - Small Square
            Center(
              child: Container(
                width: 140.sdp,
                height: 140.sdp,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.sdp),
                  border: Border.all(color: Colors.grey[200]!, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.sdp),
                  child: Builder(
                    builder: (context) {
                      // Debug logging
                      debugPrint('ProductCard - Image URL: $image');
                      debugPrint('ProductCard - Image Type: $imageType');

                      return ImageView(
                        url: image.isNotEmpty ? image : AppImages.dummyProfile,
                        fit: BoxFit.cover,
                        width: 138.sdp,
                        height: 138.sdp,
                        imageType: imageType,
                        defaultImage: AppImages.dummyProfile,
                      );
                    },
                  ),
                ),
              ),
            ),

            SizedBox(height: 12.sdp),

            // Product Title
            TextView(
              text: title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxlines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 6.sdp),

            // Specification (Description)
            TextView(
              text: desc.isNotEmpty ? desc : "Specifications not available",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
              maxlines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 6.sdp),

            // Shipping Type
            TextView(
              text: "${type.isNotEmpty ? type : 'Standard'}",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              maxlines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 8.sdp),

            // Price
            TextView(
              text: "\$ $price",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.greenlight,
              ),
              maxlines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 8.sdp),

            // Action Buttons - Conditional: Edit/Delete for owners, Buy Now for others
            showActions
                ? Row(
                    children: [
                      // Edit Button
                      Expanded(
                        child: SizedBox(
                          height: 40.sdp,
                          child: ElevatedButton(
                            onPressed: onEdit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.btnColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.sdp),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 18.sdp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      8.width,
                      // Delete Button
                      Expanded(
                        child: SizedBox(
                          height: 40.sdp,
                          child: ElevatedButton(
                            onPressed: onDelete,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.sdp),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Icon(
                              Icons.delete,
                              size: 18.sdp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    width: double.infinity,
                    height: 40.sdp,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // If it's an app product, use the onBuyNow callback
                        if (!isSepProduct && onBuyNow != null) {
                          onBuyNow!();
                          return;
                        }

                        // Otherwise, it's a SEP product - open in browser
                        if (link.isEmpty || !link.startsWith('http')) {
                          debugPrint('Invalid URL: $link');
                          return;
                        }

                        final url = Uri.parse(link);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.inAppWebView);
                        } else {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.greenlight,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.sdp),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16.sdp),
                      ),
                      icon: Icon(
                        Icons.shopping_bag_outlined,
                        size: 18.sdp,
                        color: Colors.white,
                      ),
                      label: TextView(
                        text: "Buy Now",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
