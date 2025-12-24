import 'dart:async';
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
import 'package:sep/feature/presentation/SportsProducts/productDetailScreen.dart';
import 'package:sep/feature/presentation/products/product_details_screen.dart';
import 'package:sep/feature/data/models/dataModels/user_product_model.dart';
import 'package:sep/feature/presentation/real_estate/real_estate_list_screen.dart';
import 'package:sep/services/networking/apiMethods.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/auth_Controller/product_ctrl.dart';

class SportsProduct extends StatefulWidget {
  const SportsProduct({super.key});

  @override
  State<SportsProduct> createState() => _SportsProductState();
}

class _SportsProductState extends State<SportsProduct>
    with SingleTickerProviderStateMixin {
  final ProductCtrl ctrl = ProductCtrl.find;
  final _refreshCtrl = RefreshController(initialRefresh: false);
  final _communityRefreshCtrl = RefreshController(initialRefresh: false);
  final _search = TextEditingController();
  final _communitySearch = TextEditingController();
  final IApiMethod _apiMethod = IApiMethod();

  int pageNo = 1;
  int communityPageNo = 1;
  late TabController _tabController;

  final RxList<UserProductModel> communityProducts = RxList([]);
  final RxList<UserProductModel> allCommunityProducts = RxList(
    [],
  ); // Store all products for filtering
  final RxBool isLoadingCommunity = RxBool(false);
  String? myShopId; // Store user's shop ID to filter out their shop's products

  Timer? _debounce;
  Timer? _adTimer;
  bool _showAd = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && communityProducts.isEmpty) {
        loadCommunityProducts(isRefresh: true);
      }
    });
    _fetchMyShopId(); // Fetch user's shop ID
    _startAdTimer(); // Start ad timer
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadData(isRefresh: true).applyLoader;
    });
  }

  void _startAdTimer() {
    // Show ad every 2 minutes
    _adTimer = Timer.periodic(Duration(minutes: 2), (timer) {
      if (mounted) {
        setState(() {
          _showAd = true;
        });

        // Hide ad after 30 seconds
        Future.delayed(Duration(seconds: 30), () {
          if (mounted) {
            setState(() {
              _showAd = false;
            });
          }
        });
      }
    });

    // Show ad immediately on first load
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showAd = true;
        });

        // Hide after 30 seconds
        Future.delayed(Duration(seconds: 30), () {
          if (mounted) {
            setState(() {
              _showAd = false;
            });
          }
        });
      }
    });
  }

  Future<void> _fetchMyShopId() async {
    try {
      final token = Preferences.authToken;
      final response = await _apiMethod.get(
        url: Urls.getMyShop,
        authToken: token,
        headers: {},
      );

      AppUtils.log("Fetch my shop response: ${response.data}");

      if (response.isSuccess && response.data?['data'] != null) {
        final shopData = response.data!['data'];
        myShopId = shopData['_id'] as String?;
        AppUtils.log("My shop ID loaded: $myShopId");
      } else {
        AppUtils.log("No shop found or failed to fetch: ${response.getError}");
        myShopId = null;
      }
    } catch (e) {
      AppUtils.log("Error fetching my shop ID: $e");
      myShopId = null;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tabController.dispose();
    _search.dispose();
    _communitySearch.dispose();
    _refreshCtrl.dispose();
    _communityRefreshCtrl.dispose();
    super.dispose();
  }

  Future loadData({bool isRefresh = false, bool isLoadMore = false}) async {
    if (isRefresh) {
      pageNo = 1;
    } else if (isLoadMore) {
      pageNo = pageNo + 1;
    }

    await ctrl.getProducts(
      page: pageNo,
      isLoadMore: isLoadMore,
      isRefresh: isRefresh,
      search: _search.getText,
    );
  }

  Future<void> loadCommunityProducts({
    bool isRefresh = false,
    bool isLoadMore = false,
  }) async {
    if (isLoadingCommunity.value) return;

    // Ensure we have the user's shop ID before filtering
    if (myShopId == null) {
      await _fetchMyShopId();
    }

    isLoadingCommunity.value = true;

    try {
      int page = communityPageNo;
      if (isRefresh) page = 1;
      if (isLoadMore) page = communityPageNo + 1;

      final token = Preferences.authToken;
      final response = await _apiMethod.get(
        url: Urls.getAllUserProducts,
        authToken: token,
        query: {'page': page.toString(), 'limit': '10'},
        headers: {},
      );

      if (response.isSuccess) {
        final data = response.data?['data'];
        final productsJson = data?['products'] as List?;

        if (productsJson != null) {
          final products = productsJson
              .map((json) => UserProductModel.fromJson(json))
              .toList();

          AppUtils.log(
            "Before filtering - Total products from API: ${products.length}",
          );
          AppUtils.log("My shop ID to filter: $myShopId");

          // Filter out products from user's own shop by checking shopId
          final filteredProducts = products.where((product) {
            // Filter out real estate products (category contains "+realestate+")
            final category = product.category ?? '';
            if (category.contains('+realestate+')) {
              AppUtils.log(
                "  ✓ FILTERING OUT real estate product: ${product.name} (Category: $category)",
              );
              return false; // Exclude real estate products
            }

            final productShopId = _extractShopId(product.shopId);
            AppUtils.log(
              "Checking product: ${product.name} (Shop ID: $productShopId)",
            );

            if (myShopId != null && productShopId != null) {
              final isMyShop = myShopId == productShopId;
              AppUtils.log("  - Is from my shop? $isMyShop");
              if (isMyShop) {
                AppUtils.log(
                  "  ✓ FILTERING OUT product from my shop: ${product.name} (Shop ID: $productShopId)",
                );
              }
              return !isMyShop; // Exclude products from user's own shop
            }
            AppUtils.log(
              "  - Shop ID is null or unknown, including by default",
            );
            return true; // Include product if we can't determine shop ID
          }).toList();

          AppUtils.log(
            "After filtering - Total: ${products.length}, Filtered (excluding my shop): ${filteredProducts.length}, My shop ID: $myShopId",
          );

          if (isRefresh) {
            allCommunityProducts.assignAll(filteredProducts);
            communityProducts.assignAll(filteredProducts);
          } else {
            allCommunityProducts.addAll(filteredProducts);
            communityProducts.addAll(filteredProducts);
          }

          // Apply search filter if search text is not empty
          if (_communitySearch.text.isNotEmpty) {
            _filterCommunityProducts();
          }

          if (filteredProducts.isNotEmpty) {
            communityPageNo = page;
          }
        }
      } else {
        AppUtils.toastError(response.getError ?? "Failed to load products");
      }
    } catch (e) {
      AppUtils.toastError("Error: ${e.toString()}");
    } finally {
      isLoadingCommunity.value = false;
    }
  }

  // Filter community products based on search query in product title
  void _filterCommunityProducts() {
    final searchQuery = _communitySearch.text.toLowerCase().trim();

    if (searchQuery.isEmpty) {
      // If search is empty, show all products
      communityProducts.assignAll(allCommunityProducts);
    } else {
      // Filter products where title contains the search query
      final filtered = allCommunityProducts.where((product) {
        final productName = product.name?.toLowerCase() ?? '';
        return productName.contains(searchQuery);
      }).toList();

      communityProducts.assignAll(filtered);

      AppUtils.log(
        "Search filter applied - Query: '$searchQuery', Results: ${filtered.length}/${allCommunityProducts.length}",
      );
    }
  }

  // Helper method to extract shop ID from dynamic shopId field
  String? _extractShopId(dynamic shopId) {
    if (shopId == null) return null;

    if (shopId is String) {
      return shopId;
    } else if (shopId is Map) {
      return shopId['_id'] as String?;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Tab Bar
            Container(
              margin: EdgeInsets.all(16.sdp),
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25.sdp),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.center,
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
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelPadding: EdgeInsets.symmetric(horizontal: 16.sdp),
                tabs: const [
                  Tab(text: "SEP Shop"),
                  Tab(text: "Community Shops"),
                  Tab(text: "Real Estate"),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSEPShopTab(),
                  _buildComingSoonTab(),
                  _buildRealEstateTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSEPShopTab() {
    return Padding(
      padding: 12.all,
      child: Column(
        children: [
          // // Banner Ad (conditionally shown)
          // // if (_showAd) ...[
          //   Row(
          //     children: [
          //       Expanded(
          //         child: CommonBannerAdWidget(
          //           adUnitId: Platform.isAndroid
          //               ? 'ca-app-pub-3940256099942544/6300978111'
          //               : 'ca-app-pub-3940256099942544/2934735716',
          //         ),
          //       ),
          //       SizedBox(width: 8),
          //       GestureDetector(
          //         onTap: () {
          //           setState(() {
          //             _showAd = false;
          //           });
          //         },
          //         child: Container(
          //           padding: EdgeInsets.all(4),
          //           decoration: BoxDecoration(
          //             color: Colors.grey.shade200,
          //             shape: BoxShape.circle,
          //           ),
          //           child: Icon(
          //             Icons.close,
          //             size: 16,
          //             color: Colors.grey.shade600,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          //   8.height,
          // ],
          EditText(
            controller: _search,
            hint: AppStrings.search.tr,
            radius: 20.sdp,
            prefixIcon: Icon(Icons.search, color: AppColors.grey),
            onChange: (value) {
              // Debounce search to avoid too many API calls
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                loadData(isRefresh: true);
              });
            },
          ),
          20.height,
          Expanded(
            child: SmartRefresher(
              // physics: NeverScrollableScrollPhysics(),
              controller: _refreshCtrl,
              enablePullDown: true,
              enablePullUp: true,
              onLoading: () => loadData(isLoadMore: true).then((value) {
                _refreshCtrl.loadComplete();
              }),
              onRefresh: () => loadData(isRefresh: true).then((value) {
                _refreshCtrl.refreshCompleted();
              }),
              footer: CustomFooter(
                builder: (context, mode) {
                  Widget? body;

                  if (mode == LoadStatus.loading) {
                    body = CupertinoActivityIndicator();
                    return Container(height: 55.0, child: Center(child: body));
                  }
                  return SizedBox();
                },
              ),
              child: Obx(
                () => ctrl.productListing.isEmpty
                    ? Center(
                        child: TextView(
                          text: 'Not Product found',
                          style: 16.txtBoldBlack,
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
                        itemCount: ctrl.productListing.length,

                        itemBuilder: (context, index) {
                          final product = ctrl.productListing[index];

                          final hasImage =
                              product.images != null &&
                              product.images!.isNotEmpty &&
                              product.images![0].isNotEmpty;

                          final rawImageUrl = hasImage
                              ? product.images![0]
                              : '';

                          final fullImageUrl = hasImage
                              ? Urls.getFullImageUrl(rawImageUrl)
                              : AppImages.dummyProfile;

                          AppUtils.log("Raw Image URL: $rawImageUrl");
                          AppUtils.log("Full Image URL: $fullImageUrl");

                          final imageType =
                              hasImage &&
                                  fullImageUrl.isNotEmpty &&
                                  !fullImageUrl.contains(AppImages.dummyProfile)
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
                            onTap: () {
                              context.pushNavigator(
                                Productdetailscreen(data: product),
                              );
                            },
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonTab() {
    return Padding(
      padding: 16.all,
      child: Column(
        children: [
          // Banner Ad (conditionally shown)
          // if (_showAd) ...[
          //   Row(
          //     children: [
          //       Expanded(
          //         child: CommonBannerAdWidget(
          //           adUnitId: Platform.isAndroid
          //               ? 'ca-app-pub-3940256099942544/6300978111'
          //               : 'ca-app-pub-3940256099942544/2934735716',
          //         ),
          //       ),
          //       SizedBox(width: 8),
          //       GestureDetector(
          //         onTap: () {
          //           setState(() {
          //             _showAd = false;
          //           });
          //         },
          //         child: Container(
          //           padding: EdgeInsets.all(4),
          //           decoration: BoxDecoration(
          //             color: Colors.grey.shade200,
          //             shape: BoxShape.circle,
          //           ),
          //           child: Icon(
          //             Icons.close,
          //             size: 16,
          //             color: Colors.grey.shade600,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          //   16.height,
          // ],
          // Search Bar
          EditText(
            controller: _communitySearch,
            hint: "Search community products...",
            radius: 20.sdp,
            prefixIcon: Icon(Icons.search, color: AppColors.grey),
            onChange: (value) {
              // Filter products locally based on search query
              _filterCommunityProducts();
            },
          ),
          16.height,

          // Products Grid
          Expanded(
            child: SmartRefresher(
              controller: _communityRefreshCtrl,
              enablePullDown: true,
              enablePullUp: true,
              onLoading: () =>
                  loadCommunityProducts(isLoadMore: true).then((value) {
                    _communityRefreshCtrl.loadComplete();
                  }),
              onRefresh: () =>
                  loadCommunityProducts(isRefresh: true).then((value) {
                    _communityRefreshCtrl.refreshCompleted();
                  }),
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
              child: Obx(() {
                if (isLoadingCommunity.value && communityProducts.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.btnColor),
                  );
                }

                if (communityProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 60.sdp,
                          color: AppColors.grey,
                        ),
                        16.height,
                        TextView(
                          text: 'No community products found',
                          style: TextStyle(fontSize: 16, color: AppColors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.52,
                  ),
                  itemCount: communityProducts.length,
                  itemBuilder: (context, index) {
                    final product = communityProducts[index];
                    final hasImage =
                        product.mediaUrls != null &&
                        product.mediaUrls!.isNotEmpty;
                    String imageUrl = hasImage ? product.mediaUrls!.first : '';

                    // Convert relative URL to full URL if needed
                    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
                      imageUrl = '${Urls.appApiBaseUrl}$imageUrl';
                    }

                    // Extract category (before '+' symbol)
                    String category = product.category ?? '';
                    if (category.contains('+')) {
                      category = category.split('+')[0];
                    }

                    return ProductCard(
                      title: product.name ?? 'Product',
                      type: category,
                      link: '',
                      image: imageUrl,
                      price: '${product.price?.toStringAsFixed(2) ?? '0.00'}',
                      desc: product.description ?? '',
                      imageType: ImageType.network,
                      productType: 'user-product',
                      showOwnerActions: false,
                      onTap: () {
                        Get.to(
                          () => ProductDetailsScreen(
                            productId: product.id ?? '',
                            productType: 'user-product',
                          ),
                        );
                      },
                      onBuyNow: () {
                        // Navigate to product details screen on "Buy Now" button click
                        Get.to(
                          () => ProductDetailsScreen(
                            productId: product.id ?? '',
                            productType: 'user-product',
                          ),
                        );
                      },
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealEstateTab() {
    return const RealEstateListScreen();
  }
}

class ProductCard extends StatelessWidget {
  final String title;
  final String type; // Shipping type
  final String link;
  final String image;
  final String price;
  final String desc;
  final VoidCallback onTap;
  final ImageType imageType;
  final String?
  productType; // Product source type: 'user-product', 'dropship', etc.
  final bool showOwnerActions; // Show edit/delete instead of buy now
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onBuyNow; // Custom buy now action

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
    this.productType,
    this.showOwnerActions = false,
    this.onEdit,
    this.onDelete,
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
                  child: ImageView(
                    url: image.isNotEmpty
                        ? image
                        : "https://via.placeholder.com/150",
                    fit: BoxFit.cover,
                    width: 138.sdp,
                    height: 138.sdp,
                    imageType: imageType,
                    defaultImage: AppImages.dummyProfile,
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

            // Buy Now Button or Edit/Delete Buttons
            if (showOwnerActions)
              Row(
                children: [
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
                          Icons.edit_outlined,
                          size: 20.sdp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.sdp),
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
                          Icons.delete_outline,
                          size: 20.sdp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              // Buy Now / Contact Button - More Rounded
              SizedBox(
                width: double.infinity,
                height: 40.sdp,
                child: ElevatedButton.icon(
                  onPressed:
                      onBuyNow ??
                      () async {
                        if (link.isNotEmpty && link.startsWith('http')) {
                          // Valid URL - launch it
                          final url = Uri.parse(link);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.inAppWebView);
                          } else {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        } else {
                          // No URL - show contact message
                          debugPrint('No URL available - Contact seller');
                          // You can add contact functionality here
                        }
                      },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.greenlight,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        20.sdp,
                      ), // More rounded
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16.sdp),
                  ),
                  icon: Icon(
                    (link.isNotEmpty && link.startsWith('http'))
                        ? Icons.shopping_cart
                        : Icons.contact_phone,
                    size: 18.sdp,
                    color: Colors.white,
                  ),
                  label: TextView(
                    text: (link.isNotEmpty && link.startsWith('http'))
                        ? "Buy Now"
                        : "Contact",
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
