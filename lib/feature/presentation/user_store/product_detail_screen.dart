import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/feature/data/models/dataModels/user_store/user_product_model.dart';
import 'package:sep/feature/data/models/dataModels/user_store/user_store_model.dart';
import 'package:sep/feature/presentation/user_store/payment_screen.dart';
import 'package:sep/feature/presentation/user_store/store_view_screen.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/widget.dart';
import 'package:sep/services/networking/urls.dart';

class ProductDetailScreen extends StatefulWidget {
  final UserProductModel product;

  const ProductDetailScreen({Key? key, required this.product})
    : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _pageController = PageController();

  late UserProductModel _product;
  int _currentImageIndex = 0;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          AppBar2(
            title: _product.name ?? 'Product Details',
            titleStyle: 18.txtMediumBlack,
            prefixImage: "back",
            onPrefixTap: () => Navigator.pop(context),
            backgroundColor: AppColors.white,
            hasTopSafe: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductImages(),
                  _buildProductInfo(),
                  _buildStoreDetails(),
                  _buildQuantitySelector(),
                  _buildDescription(),
                  _buildPurchaseSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImages() {
    final imageUrls = _product.mediaUrls ?? [];

    // Debug logging
    AppUtils.log("Product Detail - Name: ${_product.name}");
    AppUtils.log("Product Detail - Raw Media URLs: $imageUrls");
    AppUtils.log("Product Detail - Media URLs Count: ${imageUrls.length}");

    if (imageUrls.isEmpty) {
      return Container(
        width: double.infinity,
        height: 300.sdp,
        color: AppColors.grey.withOpacity(0.1),
        child: Icon(Icons.image, size: 80.sdp, color: AppColors.grey),
      );
    }

    return Container(
      height: 300.sdp,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              final rawImageUrl = imageUrls[index];
              final fullImageUrl = Urls.getFullImageUrl(rawImageUrl);
              AppUtils.log("Building image at index $index:");
              AppUtils.log("  - Raw URL: $rawImageUrl");
              AppUtils.log("  - Full URL: $fullImageUrl");

              return ImageView(
                url: fullImageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 300.sdp,
                imageType: ImageType.network,
                defaultImage: AppImages.dummyProfile,
              );
            },
          ),

          // Image indicators
          if (imageUrls.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: imageUrls.asMap().entries.map((entry) {
                  int index = entry.key;
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: 8.sdp,
                    height: 8.sdp,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == index
                          ? AppColors.btnColor
                          : AppColors.white.withOpacity(0.5),
                    ),
                  );
                }).toList(),
              ),
            ),

          // Availability badge
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _product.isAvailable
                    ? AppColors.btnColor
                    : AppColors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextView(
                text: _product.isAvailable ? 'Available' : 'Unavailable',
                style: 12.txtBoldWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: 16.allSide,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextView(text: _product.name ?? '', style: 24.txtMediumBlack),
          8.height,

          if (_product.category?.isNotEmpty ?? false)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              margin: 8.bottom,
              decoration: BoxDecoration(
                color: AppColors.btnColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextView(
                text: _product.category!,
                style: 12.txtRegularbtncolor,
              ),
            ),

          TextView(
            text: '\$${(_product.price ?? 0).toStringAsFixed(2)}',
            style: 28.txtMediumBlack,
          ),
        ],
      ),
    );
  }

  Widget _buildStoreDetails() {
    final shopInfo = _product.shopInfo;

    // Only show if store info is available
    if (shopInfo == null) return SizedBox.shrink();

    final storeName = shopInfo.name ?? 'Unknown Store';
    final logoUrl = shopInfo.logoUrl ?? '';
    final fullLogoUrl = Urls.getFullImageUrl(logoUrl);
    final hasLogo = logoUrl.isNotEmpty;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: 16.allSide,
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
        children: [
          // Store Logo
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 60.sdp,
              height: 60.sdp,
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ImageView(
                  url: hasLogo ? fullLogoUrl : '',
                  width: 60.sdp,
                  height: 58.sdp,
                  fit: BoxFit.cover,
                  imageType: hasLogo ? ImageType.network : ImageType.asset,
                  defaultImage: AppImages.dummyProfile,
                ),
              ),
            ),
          ),
          16.width,

          // Store Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextView(text: 'Sold by', style: 12.txtRegularGrey),
                4.height,
                TextView(
                  text: storeName,
                  style: 16.txtMediumBlack,
                  maxlines: 1,
                ),
              ],
            ),
          ),

          // Visit Store Button
          GestureDetector(
            onTap: () {
              if (shopInfo.id != null && shopInfo.id!.isNotEmpty) {
                // Create a minimal store model with available info
                final storeModel = UserStoreModel(
                  id: shopInfo.id,
                  name: shopInfo.name,
                  logoUrl: shopInfo.logoUrl,
                );

                // Navigate to store view screen
                Get.to(() => StoreViewScreen(store: storeModel));
              } else {
                AppUtils.toast('Store information not available');
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.btnColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.btnColor, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextView(
                    text: 'Visit Store',
                    style: 12.txtMediumBlack.copyWith(
                      color: AppColors.btnColor,
                    ),
                  ),
                  4.width,
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: AppColors.btnColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      margin: 16.allSide,
      padding: 16.allSide,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          TextView(text: 'Quantity:', style: 16.txtMediumBlack),
          Spacer(),

          // Quantity controls
          GestureDetector(
            onTap: () {
              if (_quantity > 1) {
                setState(() {
                  _quantity--;
                });
              }
            },
            child: Container(
              width: 36.sdp,
              height: 36.sdp,
              decoration: BoxDecoration(
                color: _quantity > 1
                    ? AppColors.btnColor
                    : AppColors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.remove, color: AppColors.white, size: 20.sdp),
            ),
          ),
          16.width,

          TextView(text: _quantity.toString(), style: 18.txtMediumBlack),
          16.width,

          GestureDetector(
            onTap: () {
              setState(() {
                _quantity++;
              });
            },
            child: Container(
              width: 36.sdp,
              height: 36.sdp,
              decoration: BoxDecoration(
                color: AppColors.btnColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.add, color: AppColors.white, size: 20.sdp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: 16.allSide,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextView(
            text: 'Description',
            style: 18.txtMediumBlack,
            margin: 8.bottom,
          ),

          TextView(
            text: _product.description ?? 'No description available.',
            style: 14.txtRegularGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseSection() {
    final totalPrice = (_product.price ?? 0) * _quantity;

    return Container(
      padding: 16.allSide,
      child: Column(
        children: [
          Container(
            padding: 16.allSide,
            margin: 16.bottom,
            decoration: BoxDecoration(
              color: AppColors.btnColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.btnColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextView(text: 'Total Price:', style: 16.txtMediumBlack),
                TextView(
                  text: '\$${totalPrice.toStringAsFixed(2)}',
                  style: 20.txtMediumBlack,
                ),
              ],
            ),
          ),

          AppButton(
            label: _product.isAvailable ? 'Buy Now' : 'Currently Unavailable',
            onTap: _product.isAvailable ? _handlePurchase : null,
            width: double.infinity,
            buttonColor: _product.isAvailable
                ? AppColors.btnColor
                : AppColors.grey,
          ),
        ],
      ),
    );
  }

  Future<void> _handlePurchase() async {
    if (!_product.isAvailable) {
      AppUtils.toast('Product is currently unavailable');
      return;
    }

    // Navigate to payment screen
    Get.to(() => PaymentScreen(product: _product, initialQuantity: _quantity));
  }
}
