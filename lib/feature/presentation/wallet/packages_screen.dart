import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/appUtils.dart';
import '../controller/auth_Controller/get_stripe_ctrl.dart';

class Package {
  final String id;
  final String name;
  final String description;
  final double price;
  final int tokens;
  final List<String> features;
  final bool isPopular;

  Package({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.tokens,
    required this.features,
    this.isPopular = false,
  });
}

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  final GetStripeCtrl stripeCtrl = Get.put(GetStripeCtrl());
  Package? selectedPackage;

  final List<Package> packages = [
    Package(
      id: '1',
      name: 'Basic',
      description: 'Perfect for getting started',
      price: 9.99,
      tokens: 100,
      features: ['100 Tokens', 'Basic Support', 'Standard Features'],
    ),
    Package(
      id: '2',
      name: 'Popular',
      description: 'Most popular choice',
      price: 19.99,
      tokens: 250,
      features: [
        '250 Tokens',
        'Priority Support',
        'Premium Features',
        'Bonus Tokens',
      ],
      isPopular: true,
    ),
    Package(
      id: '3',
      name: 'Premium',
      description: 'Best value for power users',
      price: 39.99,
      tokens: 600,
      features: [
        '600 Tokens',
        '24/7 Support',
        'All Premium Features',
        'Exclusive Content',
        'Extra Bonuses',
      ],
    ),
    Package(
      id: '4',
      name: 'Enterprise',
      description: 'For businesses and teams',
      price: 99.99,
      tokens: 1500,
      features: [
        '1500 Tokens',
        'Dedicated Support',
        'Enterprise Features',
        'Team Management',
        'Custom Solutions',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  void _selectPackage(Package package) {
    setState(() {
      selectedPackage = package;
    });
  }

  Future<void> _payNow() async {
    if (selectedPackage == null) {
      AppUtils.toast("Please select a package");
      return;
    }

    AppUtils.log("=== TOKEN PURCHASE STARTED ===");
    AppUtils.log(
      "Package: ${selectedPackage!.name} - \$${selectedPackage!.price} for ${selectedPackage!.tokens} tokens",
    );

    try {
      // Use the new token purchase API
      await stripeCtrl.purchaseTokens(amount: selectedPackage!.price);

      AppUtils.log("=== TOKEN PURCHASE COMPLETED SUCCESSFULLY ===");

      // Show success message and close screen
      AppUtils.toast("${selectedPackage!.tokens} tokens added successfully!");

      // Small delay to ensure toast is shown and profile data is fully updated
      await Future.delayed(const Duration(milliseconds: 500));

      context.pop();
    } catch (e) {
      AppUtils.log("=== TOKEN PURCHASE FAILED ===");
      AppUtils.log("Error details: $e");

      // Show specific error message
      AppUtils.toastError("Failed to purchase tokens. Please try again.");
      // Don't close the screen on error, let user try again
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Custom AppBar2
          AppBar2(
            title: 'Token Packages',
            titleStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            prefixImage: 'back',
            onPrefixTap: () => context.pop(),
            backgroundColor: Colors.white,
          ),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.sdp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  TextView(
                    text: 'Choose Your Package',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.sdp),
                  TextView(
                    text: 'Select the perfect token package for your needs',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),

                  SizedBox(height: 24.sdp),

                  // Packages Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.sdp,
                      mainAxisSpacing: 16.sdp,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: packages.length,
                    itemBuilder: (context, index) {
                      final package = packages[index];
                      final isSelected = selectedPackage?.id == package.id;

                      return GestureDetector(
                        onTap: () => _selectPackage(package),
                        child: Container(
                          padding: EdgeInsets.all(16.sdp),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.sdp),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.greenlight
                                  : Colors.grey[300]!,
                              width: isSelected ? 3 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Popular badge
                              if (package.isPopular)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.sdp,
                                    vertical: 4.sdp,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.greenlight,
                                    borderRadius: BorderRadius.circular(12.sdp),
                                  ),
                                  child: TextView(
                                    text: 'POPULAR',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),

                              if (package.isPopular) SizedBox(height: 8.sdp),

                              // Package name
                              TextView(
                                text: package.name,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),

                              SizedBox(height: 4.sdp),

                              // Price
                              Row(
                                children: [
                                  TextView(
                                    text:
                                        '\$${package.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.greenlight,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 4.sdp),

                              // Tokens
                              TextView(
                                text: '${package.tokens} Tokens',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),

                              SizedBox(height: 8.sdp),

                              // Description
                              TextView(
                                text: package.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),

                              Spacer(),

                              // Features (show first 2)
                              ...package.features
                                  .take(2)
                                  .map(
                                    (feature) => Padding(
                                      padding: EdgeInsets.only(bottom: 4.sdp),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            size: 12,
                                            color: AppColors.greenlight,
                                          ),
                                          SizedBox(width: 4.sdp),
                                          Expanded(
                                            child: TextView(
                                              text: feature,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey[600],
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
                    },
                  ),

                  // Purchase Button Section
                  if (selectedPackage != null) ...[
                    SizedBox(height: 32.sdp),

                    // Purchase Button
                    AppButton(
                      radius: 25.sdp,
                      buttonColor: AppColors.greenlight,
                      label:
                          "Purchase ${selectedPackage!.tokens} Tokens for \$${selectedPackage!.price.toStringAsFixed(2)}",
                      labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      isFilledButton: true,
                      onTap: _payNow,
                    ),

                    SizedBox(height: 16.sdp),

                    // Note about token purchase
                    Container(
                      padding: EdgeInsets.all(16.sdp),
                      decoration: BoxDecoration(
                        color: AppColors.greenlight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.sdp),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.greenlight,
                            size: 20,
                          ),
                          SizedBox(width: 12.sdp),
                          Expanded(
                            child: TextView(
                              text:
                                  "Tokens will be added to your account instantly after purchase.",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.greenlight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
