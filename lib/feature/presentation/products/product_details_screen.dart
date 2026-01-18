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
import 'package:sep/feature/presentation/profileScreens/friend_profile_screen.dart';
import 'package:sep/feature/data/models/dataModels/profile_data/profile_data_model.dart';
// import 'package:sep/feature/presentation/products/checkout_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  final String? productType;
  final Map<String, dynamic>? productData; // Pre-loaded product data

  const ProductDetailsScreen({
    Key? key,
    required this.productId,
    this.productType,
    this.productData,
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
    // Use provided data if available, otherwise fetch from API
    if (widget.productData != null) {
      AppUtils.log("Using pre-loaded product data for: ${widget.productId}");
      productData = widget.productData;

      // Check if current user is the owner
      final currentUserId = Preferences.uid;
      final shop = productData!['shopId'] as Map<String, dynamic>?;
      // Handle ownerId - it might be a String or a Map with _id field
      final ownerIdField = shop?['ownerId'];
      final ownerId = ownerIdField is String
          ? ownerIdField
          : (ownerIdField is Map ? ownerIdField['_id'] as String? : null);
      isOwner = currentUserId == ownerId;

      setState(() => isLoading = false);
    } else {
      AppUtils.log("Fetching product data from API for: ${widget.productId}");
      _loadProductDetails();
    }
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
      final url = '${Urls.userProduct}/${widget.productId}';
      AppUtils.log("Loading product details from: $url");
      AppUtils.log("Product ID: ${widget.productId}");

      final response = await _apiMethod.get(
        url: url,
        authToken: token,
        headers: {},
      );

      AppUtils.log("Product details response status: ${response.isSuccess}");
      AppUtils.log("Product details response: ${response.data}");

      if (response.isSuccess && response.data?['data'] != null) {
        final data = response.data!['data'];

        // Check if current user is the owner
        final currentUserId = Preferences.uid;
        final shop = data['shopId'] as Map<String, dynamic>?;
        // Handle ownerId - it might be a String or a Map with _id field
        final ownerIdField = shop?['ownerId'];
        final ownerId = ownerIdField is String
            ? ownerIdField
            : (ownerIdField is Map ? ownerIdField['_id'] as String? : null);

        setState(() {
          productData = data;
          isOwner = currentUserId == ownerId;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        final errorMsg = response.getError ?? "Failed to load product details";
        AppUtils.log("Failed to load product: $errorMsg");
        AppUtils.toastError(errorMsg);
      }
    } catch (e, stackTrace) {
      setState(() => isLoading = false);
      AppUtils.log("Error loading product details: $e");
      AppUtils.log("Stack trace: $stackTrace");
      AppUtils.toastError("Error loading product details: ${e.toString()}");
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
      // Handle ownerId - it might be a String or a Map with _id field
      final ownerIdField = shop['ownerId'];
      final ownerId = ownerIdField is String
          ? ownerIdField
          : (ownerIdField is Map ? ownerIdField['_id'] as String? : null);

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

  bool _isValidUrl(String? text) {
    if (text == null || text.isEmpty) return false;
    try {
      final uri = Uri.parse(text);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  void _showSellerContactDialog(String contactDetails) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.contact_phone,
                    size: 40,
                    color: Colors.orange[700],
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  "Seller Contact Information",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Info message
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Contact the seller directly to purchase this product.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[900],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Contact details box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            "Contact Details",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        contactDetails,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.btnColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Got it",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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

                // Dropship link button or seller contact details
                if (isDropship &&
                    dropshipLink != null &&
                    dropshipLink.isNotEmpty) ...[
                  const SizedBox(height: 28),

                  // Check if dropshipLink is a valid URL or seller contact details
                  if (_isValidUrl(dropshipLink))
                    // Show button to open URL
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
                    )
                  else
                    // Show seller contact details in a box
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.contact_phone,
                              color: AppColors.btnColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Seller Contact Information",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange[200]!,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.orange[700],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "This is a dropship product. Contact the seller directly using the information below:",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.orange[900],
                                        fontWeight: FontWeight.w500,
                                        height: 1.4,
                                      ),
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
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.orange[100]!,
                                  ),
                                ),
                                child: Text(
                                  dropshipLink,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
    final shop = productData!['shopId'] as Map<String, dynamic>?;
    final contactEmail = shop?['contactEmail'] ?? '';
    final contactPhone = shop?['contactPhone'] ?? '';

    // Parse category to check if dropship
    final isDropship = categoryFull.contains('+drop+');
    String? dropshipLink;

    if (isDropship) {
      final parts = categoryFull.split('+drop+');
      if (parts.length > 1) dropshipLink = parts[1];
    }

    // Determine if this is in-app product without URL (show Contact)
    final showContactButton =
        !isDropship || (dropshipLink != null && !_isValidUrl(dropshipLink));

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
            // Total price display (only for dropship products with external URL)
            // if (!isDropship && isAvailable) ...[
            // if (false) ...[
            //   Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       const Text(
            //         "Total:",
            //         style: TextStyle(
            //           fontSize: 16,
            //           fontWeight: FontWeight.w500,
            //           color: Colors.black54,
            //         ),
            //       ),
            //       Text(
            //         "\$${totalPrice.toStringAsFixed(2)}",
            //         style: TextStyle(
            //           fontSize: 24,
            //           fontWeight: FontWeight.w700,
            //           color: AppColors.btnColor,
            //           letterSpacing: -0.5,
            //         ),
            //       ),
            //     ],
            //   ),
            //   const SizedBox(height: 16),
            // ],

            // Buy/Contact button
            ElevatedButton(
              onPressed: isAvailable
                  ? () {
                      if (showContactButton) {
                        // For in-app products or dropship without URL, navigate to seller profile
                        final shop =
                            productData!['shopId'] as Map<String, dynamic>?;
                        // Handle ownerId - it might be a String or a Map with _id field
                        final ownerIdField = shop?['ownerId'];
                        String? ownerId = ownerIdField is String
                            ? ownerIdField
                            : (ownerIdField is Map
                                  ? ownerIdField['_id'] as String?
                                  : null);
                        String ownerName = shop?['name'] ?? 'Seller';

                        if (ownerId != null && ownerId.isNotEmpty) {
                          // Create a minimal ProfileDataModel with available shop data
                          final profileData = ProfileDataModel(
                            id: ownerId,
                            name: ownerName,
                            email: contactEmail.isNotEmpty
                                ? contactEmail
                                : null,
                            phone: contactPhone.isNotEmpty
                                ? contactPhone
                                : null,
                          );

                          Get.to(() => FriendProfileScreen(data: profileData));
                        } else {
                          AppUtils.toastError('Seller profile not available');
                        }
                      } else {
                        // For dropship products with URL, open the external link
                        _openDropshipLink(dropshipLink!);
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
                    showContactButton ? Icons.contact_phone : Icons.open_in_new,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isAvailable
                        ? (showContactButton
                              ? "Contact Seller"
                              : "Visit Supplier Site")
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

  // void _navigateToPaymentScreen() {
  //   final price =
  //       double.tryParse(productData!['price']?.toString() ?? '0') ?? 0.0;
  //   final totalPrice = price * quantity;

  //   // Navigate to checkout screen
  //   Get.to(
  //     () => CheckoutScreen(
  //       productData: productData!,
  //       quantity: quantity,
  //       totalAmount: totalPrice,
  //     ),
  //   );
  // }
}
