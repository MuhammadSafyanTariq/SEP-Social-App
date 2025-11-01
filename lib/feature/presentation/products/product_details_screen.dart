import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/services/networking/apiMethods.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/feature/presentation/store/store_view_screen.dart';
import 'package:sep/feature/presentation/products/checkout_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  final String? productType;

  const ProductDetailsScreen({
    Key? key,
    required this.productId,
    this.productType,
  }) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final IApiMethod _apiMethod = IApiMethod();
  bool isLoading = true;
  Map<String, dynamic>? productData;
  int currentImageIndex = 0;
  final PageController _pageController = PageController();
  VideoPlayerController? _videoController;
  int? _currentVideoIndex;
  int quantity = 1; // Product quantity counter
  bool isOwner = false; // Check if current user is store owner

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  bool _isVideoUrl(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.mp4') ||
        lowerUrl.endsWith('.mov') ||
        lowerUrl.endsWith('.avi') ||
        lowerUrl.endsWith('.mkv');
  }

  Future<void> _initializeVideo(String url, int index) async {
    if (_currentVideoIndex == index && _videoController != null) {
      return;
    }

    await _videoController?.dispose();
    _currentVideoIndex = index;

    _videoController = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize()
          .then((_) {
            if (mounted) setState(() {});
            _videoController?.play();
            _videoController?.setLooping(true);
          })
          .catchError((error) {
            AppUtils.log("Error initializing video: $error");
          });
  }

  Future<void> _loadProductDetails() async {
    setState(() => isLoading = true);

    try {
      final token = Preferences.authToken;
      final response = await _apiMethod.get(
        url: '${Urls.userProduct}/${widget.productId}',
        authToken: token,
        headers: {},
      );

      AppUtils.log("Product details response: ${response.data}");

      if (response.isSuccess && response.data?['data'] != null) {
        final data = response.data!['data'];

        // Check if current user is the owner
        final currentUserId = Preferences.uid;
        final shop = data['shopId'] as Map<String, dynamic>?;
        final ownerId = shop?['ownerId'] as String?;

        setState(() {
          productData = data;
          isOwner = currentUserId == ownerId;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        AppUtils.toastError("Failed to load product details");
      }
    } catch (e) {
      setState(() => isLoading = false);
      AppUtils.log("Error loading product details: $e");
      AppUtils.toastError("Error loading product details");
    }
  }

  String _getFullImageUrl(String url) {
    if (url.startsWith('http')) return url;
    return '${Urls.appApiBaseUrl}$url';
  }

  void _navigateToShop() {
    if (productData != null && productData!['shopId'] != null) {
      final shop = productData!['shopId'] as Map<String, dynamic>;
      final shopId = shop['_id'] as String?;
      final ownerId = shop['ownerId'] as String?;

      if (shopId != null) {
        Get.to(() => StoreViewScreen(shopId: shopId, ownerId: ownerId));
      }
    }
  }

  Future<void> _openDropshipLink(String link) async {
    final Uri url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      AppUtils.toastError("Could not open link");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppBar2(
              title: "Product Details",
              titleStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              prefixImage: "back",
              onPrefixTap: () => Navigator.pop(context),
              backgroundColor: Colors.white,
              hasTopSafe: false,
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : productData == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          TextView(
                            text: "Product not found",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildProductContent(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: !isLoading && productData != null && !isOwner
          ? _buildBottomBar()
          : null,
    );
  }

  Widget _buildProductContent() {
    final name = productData!['name'] ?? 'Product';
    final description = productData!['description'] ?? '';
    final price = productData!['price']?.toString() ?? '0.00';
    final mediaUrls =
        (productData!['mediaUrls'] as List?)?.cast<String>() ?? [];
    final categoryFull = productData!['category'] ?? '';
    final isAvailable = productData!['isAvailable'] ?? true;
    final shop = productData!['shopId'] as Map<String, dynamic>?;

    // Parse category to check if dropship
    final isDropship = categoryFull.contains('+drop+');
    String category = categoryFull;
    String? dropshipLink;

    if (isDropship) {
      final parts = categoryFull.split('+drop+');
      category = parts[0];
      if (parts.length > 1) dropshipLink = parts[1];
    } else if (categoryFull.contains('+simple')) {
      category = categoryFull.replaceAll('+simple', '');
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Media Section (Images/Videos)
          if (mediaUrls.isNotEmpty)
            Container(
              height: 400,
              color: Colors.grey[50],
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: mediaUrls.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentImageIndex = index;
                        _videoController?.pause();
                      });

                      final url = _getFullImageUrl(mediaUrls[index]);
                      if (_isVideoUrl(url)) {
                        _initializeVideo(url, index);
                      }
                    },
                    itemBuilder: (context, index) {
                      final url = _getFullImageUrl(mediaUrls[index]);
                      final isVideo = _isVideoUrl(url);

                      if (isVideo) {
                        if (_currentVideoIndex == index &&
                            _videoController != null &&
                            _videoController!.value.isInitialized) {
                          return Center(
                            child: AspectRatio(
                              aspectRatio: _videoController!.value.aspectRatio,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  VideoPlayer(_videoController!),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (_videoController!.value.isPlaying) {
                                          _videoController!.pause();
                                        } else {
                                          _videoController!.play();
                                        }
                                      });
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      width: double.infinity,
                                      height: double.infinity,
                                      child: Center(
                                        child: _videoController!.value.isPlaying
                                            ? const SizedBox.shrink()
                                            : Container(
                                                padding: const EdgeInsets.all(
                                                  20,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Colors.black54,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.play_arrow,
                                                  size: 50,
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return Container(
                            color: Colors.black,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          );
                        }
                      } else {
                        return ImageView(
                          url: url,
                          imageType: ImageType.network,
                          fit: BoxFit.contain,
                          height: 400,
                          width: double.infinity,
                        );
                      }
                    },
                  ),

                  // Media indicators
                  if (mediaUrls.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: mediaUrls.asMap().entries.map((entry) {
                          final isVideo = _isVideoUrl(mediaUrls[entry.key]);
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            child: Icon(
                              isVideo ? Icons.videocam : Icons.circle,
                              size: currentImageIndex == entry.key ? 10 : 8,
                              color: currentImageIndex == entry.key
                                  ? AppColors.btnColor
                                  : Colors.black38,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            )
          else
            Container(
              height: 400,
              color: Colors.grey[50],
              child: Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 80,
                  color: Colors.grey[300],
                ),
              ),
            ), // Product Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Availability Status
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isAvailable ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isAvailable ? "In Stock" : "Out of Stock",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isAvailable ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Product Name
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 12),

                // Category and Type
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isDropship) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.link,
                              size: 12,
                              color: Colors.orange[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Dropship",
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 20),

                // Price
                Text(
                  "\$$price",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.btnColor,
                    letterSpacing: -1,
                  ),
                ),

                const SizedBox(height: 24),

                // Quantity Counter
                Row(
                  children: [
                    const Text(
                      "Quantity:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          // Decrease button
                          InkWell(
                            onTap: () {
                              if (quantity > 1) {
                                setState(() {
                                  quantity--;
                                });
                              }
                            },
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: quantity > 1
                                    ? Colors.grey[50]
                                    : Colors.grey[100],
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(7),
                                  bottomLeft: Radius.circular(7),
                                ),
                              ),
                              child: Icon(
                                Icons.remove,
                                size: 18,
                                color: quantity > 1
                                    ? Colors.black87
                                    : Colors.grey[400],
                              ),
                            ),
                          ),

                          // Quantity display
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                left: BorderSide(color: Colors.grey.shade300),
                                right: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Text(
                              quantity.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),

                          // Increase button
                          InkWell(
                            onTap: () {
                              if (quantity < 99) {
                                // Max quantity limit
                                setState(() {
                                  quantity++;
                                });
                              }
                            },
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(7),
                                  bottomRight: Radius.circular(7),
                                ),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 18,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Divider
                Container(height: 1, color: Colors.grey[200]),

                const SizedBox(height: 28),

                // Description
                const Text(
                  "Description",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  description.isNotEmpty
                      ? description
                      : "No description available",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.6,
                    letterSpacing: 0.2,
                  ),
                ),

                // Dropship link button
                if (isDropship &&
                    dropshipLink != null &&
                    dropshipLink.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openDropshipLink(dropshipLink!),
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text(
                        "View on Supplier Website",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(
                          color: Colors.orange,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                // Divider
                Container(height: 1, color: Colors.grey[200]),

                const SizedBox(height: 28),

                // Shop Info
                if (shop != null) ...[
                  const Text(
                    "Sold by",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  InkWell(
                    onTap: _navigateToShop,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          // Shop logo
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.btnColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child:
                                shop['logoUrl'] != null &&
                                    shop['logoUrl'].toString().isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: ImageView(
                                      url: _getFullImageUrl(shop['logoUrl']),
                                      imageType: ImageType.network,
                                      fit: BoxFit.cover,
                                      width: 48,
                                      height: 48,
                                    ),
                                  )
                                : Icon(
                                    Icons.store,
                                    color: AppColors.btnColor,
                                    size: 26,
                                  ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  shop['name'] ?? 'Shop',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  "Visit store",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.btnColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final isAvailable = productData!['isAvailable'] ?? true;
    final categoryFull = productData!['category'] ?? '';
    final price =
        double.tryParse(productData!['price']?.toString() ?? '0') ?? 0.0;
    final totalPrice = price * quantity;

    // Parse category to check if dropship
    final isDropship = categoryFull.contains('+drop+');
    String? dropshipLink;

    if (isDropship) {
      final parts = categoryFull.split('+drop+');
      if (parts.length > 1) dropshipLink = parts[1];
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Total price display (only for simple products)
            if (!isDropship && isAvailable) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    "\$${totalPrice.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.btnColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Buy button
            ElevatedButton(
              onPressed: isAvailable
                  ? () {
                      if (isDropship &&
                          dropshipLink != null &&
                          dropshipLink.isNotEmpty) {
                        // For dropship products, open the external link
                        _openDropshipLink(dropshipLink);
                      } else {
                        // For simple products, navigate to payment screen
                        _navigateToPaymentScreen();
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isAvailable
                    ? AppColors.btnColor
                    : Colors.grey[300],
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                disabledForegroundColor: Colors.grey[500],
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                minimumSize: const Size(double.infinity, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isDropship
                        ? Icons.open_in_new
                        : Icons.shopping_bag_outlined,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isAvailable
                        ? (isDropship ? "View on Supplier Site" : "Buy Now")
                        : "Out of Stock",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPaymentScreen() {
    final price =
        double.tryParse(productData!['price']?.toString() ?? '0') ?? 0.0;
    final totalPrice = price * quantity;

    // Navigate to checkout screen
    Get.to(
      () => CheckoutScreen(
        productData: productData!,
        quantity: quantity,
        totalAmount: totalPrice,
      ),
    );
  }
}
