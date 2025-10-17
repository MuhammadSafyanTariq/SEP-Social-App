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

class _SportsProductState extends State<SportsProduct> {
  final ProductCtrl ctrl = ProductCtrl.find;
  final _refreshCtrl = RefreshController(initialRefresh: false);
  final _search = TextEditingController();
  int pageNo = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadData(isRefresh: true).applyLoader;
    });
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
            // Custom AppBar2
            Expanded(
              child: Padding(
                padding: 12.all,
                child: Column(
                  children: [
                    EditText(
                      controller: _search,
                      hint: AppStrings.search.tr,
                      radius: 20.sdp,
                      prefixIcon: Icon(Icons.search, color: AppColors.grey),
                      onChange: (value) {
                        // Optional: implement real-time search
                      },
                    ),
                    20.height,
                    Expanded(
                      child: SmartRefresher(
                        // physics: NeverScrollableScrollPhysics(),
                        controller: _refreshCtrl,
                        enablePullDown: true,
                        enablePullUp: true,
                        onLoading: () => loadData().then((value) {
                          _refreshCtrl.loadComplete();
                        }),
                        onRefresh: () => loadData().then((value) {
                          _refreshCtrl.refreshCompleted();
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
                            // else if(mode == LoadStatus.failed){
                            //   body = Text("Load Failed!Click retry!");
                            // }
                            // else if(mode == LoadStatus.canLoading){
                            //   body = Text("release to load more");
                            // }
                            // else{
                            //   body = Text("No more Data");
                            // }
                            // return Container(
                            //   height: 55.0,
                            //   child: Center(child:body),
                            // );
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

                                    final imageUrl = hasImage
                                        ? product.images![0]
                                        : AppImages.dummyProfile;

                                    AppUtils.log("image>>>>>>${imageUrl}");
                                    final imageType = hasImage
                                        ? ImageType.network
                                        : ImageType.asset;

                                    return ProductCard(
                                      link: product.checkouturl ?? "",
                                      title: product.title ?? '',
                                      image: imageUrl,
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
              ),
            ),
          ],
        ),
      ),
    );
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
              text: "Shipping: ${type.isNotEmpty ? type : 'Standard'}",
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

            // Buy Now Button - More Rounded
            SizedBox(
              width: double.infinity,
              height: 40.sdp,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (link.isEmpty || !link.startsWith('http')) {
                    debugPrint('Invalid URL: $link');
                    return;
                  }

                  final url = Uri.parse(link);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.inAppWebView);
                  } else {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greenlight,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.sdp), // More rounded
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
