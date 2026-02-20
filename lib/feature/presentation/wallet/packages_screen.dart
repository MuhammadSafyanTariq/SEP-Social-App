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
  final TextEditingController customAmountController = TextEditingController();

  // Backend: $10 → 1,000 tokens, $20 → 2,500, $50 → 10,000 (1¢ per token); valid amounts: 10, 20, 50
  final List<Package> packages = [
    Package(
      id: '1',
      name: 'Basic',
      description: 'Perfect for getting started',
      price: 10,
      tokens: 1000,
      features: ['1,000 Tokens', 'Basic Support', 'Standard Features'],
    ),
    Package(
      id: '2',
      name: 'Popular',
      description: 'Most popular choice',
      price: 20,
      tokens: 2500,
      features: [
        '2,500 Tokens',
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
      price: 50,
      tokens: 10000,
      features: [
        '10,000 Tokens',
        '24/7 Support',
        'All Premium Features',
        'Exclusive Content',
        'Extra Bonuses',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    customAmountController.dispose();
    super.dispose();
  }

  void _selectPackage(Package package) {
    setState(() {
      selectedPackage = package;
      // Clear custom amount when selecting a package
      customAmountController.clear();
    });
  }

  void _onCustomAmountChanged(String value) {
    setState(() {
      // Clear package selection when entering custom amount
      if (value.isNotEmpty) {
        selectedPackage = null;
      }
    });
  }

  // Backend: 1¢ per token; tokens = floor(customAmount × 100)
  int _calculateTokensFromAmount(double amount) {
    return (amount * 100).floor();
  }

  Future<void> _payNow() async {
    double? amount;
    String purchaseType;
    bool useCustomPurchase = false;

    // Check if custom amount is entered
    if (customAmountController.text.isNotEmpty) {
      amount = double.tryParse(customAmountController.text);
      if (amount == null || amount <= 0) {
        AppUtils.toast("Please enter a valid amount");
        return;
      }
      if (amount < 0.01) {
        AppUtils.toast("Minimum purchase amount is \$0.01");
        return;
      }
      purchaseType = "Custom Amount";
      useCustomPurchase = true; // Use custom API for custom amounts
    } else if (selectedPackage != null) {
      amount = selectedPackage!.price;
      purchaseType = selectedPackage!.name;
      useCustomPurchase = false; // Use regular API for packages
    } else {
      AppUtils.toast("Please select a package or enter a custom amount");
      return;
    }

    AppUtils.log("=== TOKEN PURCHASE STARTED ===");
    AppUtils.log("Type: $purchaseType - \$$amount");
    AppUtils.log(
      "Using ${useCustomPurchase ? 'Custom' : 'Regular'} Purchase API",
    );

    try {
      // Use appropriate API based on purchase type
      if (useCustomPurchase) {
        await stripeCtrl.purchaseCustomTokens(customAmount: amount);
      } else {
        await stripeCtrl.purchaseTokens(amount: amount);
      }

      AppUtils.log("=== TOKEN PURCHASE COMPLETED SUCCESSFULLY ===");

      // Show success message and close screen
      AppUtils.toast("Tokens added successfully!");

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
              padding: EdgeInsets.symmetric(horizontal: 20.sdp, vertical: 16.sdp),
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

                  SizedBox(height: 20.sdp),

                  // Custom Amount Section
                  Container(
                    padding: EdgeInsets.all(16.sdp),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.sdp),
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
                        Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              color: AppColors.greenlight,
                              size: 24,
                            ),
                            SizedBox(width: 8.sdp),
                            TextView(
                              text: 'Custom Amount',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.sdp),
                        TextView(
                          text: 'Enter your preferred amount',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 12.sdp),
                        TextField(
                          controller: customAmountController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: _onCustomAmountChanged,
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.sdp,
                                vertical: 12.sdp,
                              ),
                              child: TextView(
                                text: '\$',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.greenlight,
                                ),
                              ),
                            ),
                            hintText: 'Enter amount (e.g., 25.00)',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.sdp),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.sdp),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.sdp),
                              borderSide: BorderSide(
                                color: AppColors.greenlight,
                                width: 2,
                              ),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        // Show estimated tokens for custom amount
                        if (customAmountController.text.isNotEmpty) ...[
                          SizedBox(height: 12.sdp),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.sdp,
                              vertical: 8.sdp,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.greenlight.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10.sdp),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/icons/token.png',
                                  width: 18,
                                  height: 18,
                                ),
                                SizedBox(width: 8.sdp),
                                TextView(
                                  text:
                                      '≈ ${_calculateTokensFromAmount(double.tryParse(customAmountController.text) ?? 0)} tokens',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.greenlight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 20.sdp),

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
                              width: isSelected ? 1 : 1,
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
                                            color: AppColors.txtfieldtext,
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
                  if (selectedPackage != null ||
                      customAmountController.text.isNotEmpty) ...[
                    SizedBox(height: 20.sdp),

                    // Purchase Button
                    AppButton(
                      radius: 25.sdp,
                      buttonColor: AppColors.greenlight,
                      label: customAmountController.text.isNotEmpty
                          ? "Purchase Tokens for \$${customAmountController.text}"
                          : "Purchase ${selectedPackage!.tokens} Tokens for \$${selectedPackage!.price.toStringAsFixed(2)}",
                      labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      isFilledButton: true,
                      onTap: _payNow,
                    ),

                    SizedBox(height: 12.sdp),

                    // Note about token purchase
                    Container(
                      padding: EdgeInsets.all(16.sdp),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.sdp),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.primaryBlue,
                            size: 20,
                          ),
                          SizedBox(width: 12.sdp),
                          Expanded(
                            child: TextView(
                              text:
                                  "Tokens will be added to your account instantly after purchase.",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.primaryBlue,
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
