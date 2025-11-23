import 'package:flutter/material.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../components/coreComponents/TextView.dart';
import '../../data/models/dataModels/product_data_model/product_data_model.dart';
import '../../../services/networking/urls.dart';

class Productdetailscreen extends StatefulWidget {
  final ProductDataModel data;

  const Productdetailscreen({super.key, required this.data});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<Productdetailscreen> {
  late ProductDataModel data;
  final PageController _pageController = PageController();
  int _currentIndex = 0; // Used in PageView onPageChanged callback
  bool isAddedToCart = false;
  int cartCount = 0;

  @override
  void initState() {
    super.initState();

    data = widget.data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // Custom AppBar2
          AppBar2(
            title: 'Product Details',
            titleStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            prefixImage: 'back',
            onPrefixTap: () => context.pop(),
            backgroundColor: Colors.white,
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image Section
                  Container(
                    width: double.infinity,
                    height: 400.sdp,
                    color: Colors.grey[50],
                    child: Stack(
                      children: [
                        Center(
                          child: SizedBox(
                            width: double.infinity,
                            height: 350.sdp,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: data.images?.length ?? 0,
                              onPageChanged: (index) {
                                setState(() => _currentIndex = index);
                              },
                              itemBuilder: (context, index) {
                                final rawImageUrl = data.images?[index] ?? '';
                                final fullImageUrl = rawImageUrl.isNotEmpty
                                    ? Urls.getFullImageUrl(rawImageUrl)
                                    : '';

                                AppUtils.log(
                                  'Product Detail - Raw Image: $rawImageUrl',
                                );
                                AppUtils.log(
                                  'Product Detail - Full Image: $fullImageUrl',
                                );

                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.sdp,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        16.sdp,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        16.sdp,
                                      ),
                                      child: ImageView(
                                        url: fullImageUrl.isNotEmpty
                                            ? fullImageUrl
                                            : AppImages.dummyProfile,
                                        height: 350.sdp,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        imageType:
                                            fullImageUrl.isNotEmpty &&
                                                fullImageUrl.startsWith('http')
                                            ? ImageType.network
                                            : ImageType.asset,
                                        defaultImage: AppImages.dummyProfile,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        // Share Button
                        Positioned(
                          top: 40.sdp,
                          right: 40.sdp,
                          child: Container(
                            padding: EdgeInsets.all(12.sdp),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: GestureDetector(
                              onTap: () async {
                                final productUrl = data.checkouturl ?? "";
                                if (productUrl.isEmpty) {
                                  AppUtils.toast("No product link available");
                                  return;
                                }

                                String textToShare =
                                    '''
Check out this amazing product: ${data.title}
Price: \$${data.price}
Buy now: $productUrl
                                  ''';

                                try {
                                  await Share.share(textToShare);
                                } catch (e) {
                                  AppUtils.log("Error sharing: $e");
                                  AppUtils.toast("Failed to share product");
                                }
                              },
                              child: Icon(
                                Icons.share,
                                color: AppColors.primaryColor,
                                size: 16.sdp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Page Indicator
                        if ((data.images?.length ?? 0) > 1)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: 16.sdp,
                                bottom: 24.sdp,
                              ),
                              child: SmoothPageIndicator(
                                controller: _pageController,
                                count: data.images?.length ?? 0,
                                effect: ExpandingDotsEffect(
                                  activeDotColor: AppColors.greenlight,
                                  dotColor: AppColors.grey.withOpacity(0.4),
                                  dotHeight: 6.sdp,
                                  dotWidth: 8.sdp,
                                  expansionFactor: 3,
                                ),
                              ),
                            ),
                          ),

                        // Product Title
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.sdp),
                          child: TextView(
                            text: data.title ?? '',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        // Product Price
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.sdp,
                            vertical: 12.sdp,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.greenlight.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.sdp),
                            border: Border.all(
                              color: AppColors.greenlight.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.attach_money,
                                color: AppColors.greenlight,
                                size: 28.sdp,
                              ),
                              TextView(
                                text: "${data.price}",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.greenlight,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24.sdp),

                        // Product Details Section
                        Container(
                          padding: EdgeInsets.all(20.sdp),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.sdp),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppColors.primaryColor,
                                    size: 24.sdp,
                                  ),
                                  SizedBox(width: 8.sdp),
                                  TextView(
                                    text: "Product Details",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 16.sdp),

                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.sdp),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12.sdp),
                                ),
                                child: TextView(
                                  text: data.description?.isNotEmpty == true
                                      ? data.description!
                                      : 'No description available for this product.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[700],
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 32.sdp),
                        // Buy Now Button
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 4.sdp),
                          child: AppButton(
                            radius: 20.sdp,
                            label: "Buy Now",
                            buttonColor: AppColors.greenlight,
                            labelStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            isFilledButton: true,
                            onTap: () async {
                              if (data.checkouturl == null ||
                                  data.checkouturl!.isEmpty ||
                                  !data.checkouturl!.startsWith('http')) {
                                AppUtils.toast('Product link not available');
                                return;
                              }

                              final url = Uri.parse(data.checkouturl ?? "");

                              try {
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(
                                    url,
                                    mode: LaunchMode.inAppWebView,
                                  );
                                } else {
                                  await launchUrl(
                                    url,
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              } catch (e) {
                                AppUtils.toast('Failed to open product link');
                                debugPrint('Error launching URL: $e');
                              }
                            },
                          ),
                        ),

                        SizedBox(height: 20.sdp),
                        // else
                        // AppButton(
                        //   margin: 20.top + 20.bottom,
                        //   radius: 10.sdp,
                        //   label: "Go to Cart",
                        //   buttonColor: AppColors.btnColor,
                        //   labelStyle: 18.txtMediumWhite,
                        //   onTap: () {
                        //     context.pushNavigator(Cartscreen());
                        //   },
                        // ),
                      ],
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
}
