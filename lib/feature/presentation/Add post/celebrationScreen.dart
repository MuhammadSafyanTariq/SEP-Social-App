import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/feature/data/models/dataModels/Createpost/address_model.dart';
import 'package:sep/feature/presentation/controller/createpost/createpost_ctrl.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import '../../../components/coreComponents/ImageView.dart';
import '../../../components/coreComponents/AppButton.dart';
import '../../../components/styles/appImages.dart';
import '../../../components/styles/app_strings.dart';
import '../../../utils/appUtils.dart';
import '../../data/models/dataModels/Createpost/getcategory_model.dart';
import '../Home/homeScreen.dart';
import '../controller/auth_Controller/get_stripe_ctrl.dart';

class CelebrationScreen extends StatefulWidget {
  const CelebrationScreen({super.key});

  @override
  State<CelebrationScreen> createState() => _CelebrationScreenState();
}

class _CelebrationScreenState extends State<CelebrationScreen> {
  final TextEditingController _textController = TextEditingController();
  final int _maxCharacters = 120;

  List<Categories> categories = [];
  Categories? selectedCategory;

  // Advertisement category tracking
  bool showAdvertisementWarning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) => fetchCategories(),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> fetchCategories() async {
    try {
      await CreatePostCtrl.find.getPostCategories().applyLoaderWithOption(
        CreatePostCtrl.find.getCategories.isEmpty,
      );

      setState(() {
        categories = CreatePostCtrl.find.getCategories.isNotEmpty
            ? CreatePostCtrl.find.getCategories
            : [];
      });

      AppUtils.log("Fetched Categories: ${categories.toString()}");
    } catch (e) {
      AppUtils.log("Error fetching categories: $e");
    }
  }

  // Check if category is advertisement related
  // Payment logic removed - advertisements are now free
  bool _isAdvertisementCategory(String? categoryName) {
    return false; // Always return false to bypass payment logic
  }

  String _getCategoryDisplayName(String? categoryName) {
    if (categoryName == null) return 'No Category Available';
    // Map "Politics" to "Perception" for display
    if (categoryName == 'Politics') return 'Perception';

    // Capitalize category names that start with lowercase
    if (categoryName.isNotEmpty &&
        categoryName[0].toLowerCase() == categoryName[0]) {
      return categoryName[0].toUpperCase() + categoryName.substring(1);
    }

    return categoryName;
  }

  Future<bool> _showAdvertisementPaymentDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(Icons.campaign, color: Colors.orange),
                  SizedBox(width: 8),
                  TextView(
                    text: "Advertisement Boost",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextView(
                    text:
                        "You're about to boost your celebration as an advertisement.",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextView(
                          text: "• Cost: \$5.00 USD",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        TextView(
                          text: "• Duration: 24 hours boost",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        TextView(
                          text: "• Benefits: Higher visibility and reach",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: TextView(
                    text: "Cancel",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: TextView(
                    text: "Pay \$5 & Boost",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Widget _buildAdvertisementWarning() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.campaign, color: Colors.orange.shade600, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextView(
                  text: "Advertisement Category",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade800,
                  ),
                ),
                SizedBox(height: 4),
                TextView(
                  text:
                      "Selecting advertisement as category will charge you \$5 and your celebration will be boosted for 24 hours",
                  style: TextStyle(fontSize: 14, color: Colors.orange.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get _isValidForm {
    bool hasText = _textController.text.trim().isNotEmpty;
    bool withinLimit = _textController.text.trim().length <= _maxCharacters;
    bool hasCategory = selectedCategory != null;

    AppUtils.log("=== FORM VALIDATION ===");
    AppUtils.log(
      "Has Text: $hasText (${_textController.text.trim().length} chars)",
    );
    AppUtils.log("Within Limit: $withinLimit (max: $_maxCharacters)");
    AppUtils.log(
      "Has Category: $hasCategory (${selectedCategory?.name ?? 'NULL'})",
    );
    AppUtils.log("Is Valid: ${hasText && withinLimit && hasCategory}");

    return hasText && withinLimit && hasCategory;
  }

  Future<void> _submitCelebration() async {
    if (!_isValidForm) {
      AppUtils.toastError('Please fill all required fields');
      return;
    }

    // Check if advertisement category is selected and handle payment
    if (_isAdvertisementCategory(selectedCategory?.name)) {
      AppUtils.log("Advertisement category selected, processing payment...");

      // Show confirmation dialog first
      final shouldProceed = await _showAdvertisementPaymentDialog(context);
      if (!shouldProceed) {
        AppUtils.log("User canceled advertisement payment");
        return;
      }

      try {
        final stripeCtrl = Get.find<GetStripeCtrl>();

        // Check if user has cards and customer ID before proceeding
        await stripeCtrl.fetchCards();
        if (stripeCtrl.cardList.isEmpty ||
            stripeCtrl.selectedCardId.value.isEmpty) {
          AppUtils.toastError(
            "No payment method found. Please add a card first.",
          );
          return;
        }

        final customerId =
            stripeCtrl.profileCtrl.profileData.value.stripeCustomerId;
        if (customerId == null || customerId.isEmpty) {
          AppUtils.toastError(
            "Customer information not found. Please contact support.",
          );
          return;
        }

        // Process $5 payment for advertisement boost
        await stripeCtrl
            .makePayment(
              amount: "500", // $5.00 in cents
              currency: "usd",
            )
            .applyLoader;

        // Payment success is handled inside makePayment method
        AppUtils.log("Advertisement payment completed successfully");
      } catch (e) {
        AppUtils.log("Advertisement payment failed: $e");
        AppUtils.toastError(
          "Payment failed. Please try again or select a different category.",
        );
        return;
      }
    }

    try {
      // Format the caption with special identifier for celebration posts
      String celebrationCaption =
          "SEP#Celebrate+${_textController.text.trim()}";

      // Debug logging
      AppUtils.log("=== CELEBRATION POST DEBUG ===");
      AppUtils.log("User ID: ${Preferences.uid ?? 'NULL'}");
      AppUtils.log("Category ID: ${selectedCategory!.id ?? 'NULL'}");
      AppUtils.log("Category Name: ${selectedCategory!.name ?? 'NULL'}");
      AppUtils.log("Original Caption: ${_textController.text.trim()}");
      AppUtils.log("Formatted Caption: $celebrationCaption");
      AppUtils.log("Caption Length: ${celebrationCaption.length}");
      AppUtils.log("Address Model: ${AddressModel().toString()}");
      AppUtils.log("=== STARTING POST CREATION ===");

      await CreatePostCtrl.find
          .createPosts(
            Preferences.uid ?? '',
            selectedCategory!.id ?? '',
            celebrationCaption, // Use formatted caption
            AddressModel(),
            {
              "latitude": 0.0,
              "longitude": 0.0,
              "country": "",
            }, // Provide empty location data
            [], // No uploaded files - just text
            null, // No poll options
            'post', // Use 'post' type like regular posts
            null,
            null,
            null,
          )
          .applyLoader;

      AppUtils.log("=== POST CREATION SUCCESS ===");

      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(20),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ImageView(url: AppImages.Done),
                SizedBox(height: 10),
                Center(
                  child: TextView(
                    text: "Celebration posted successfully!",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.btnColor,
                    ),
                    textAlign: TextAlign.center,
                    margin: EdgeInsets.only(top: 20, bottom: 20),
                  ),
                ),
                TextView(
                  text:
                      "Your celebration has been shared! Go to home to continue your journey.",
                  style: TextStyle(fontSize: 20, color: AppColors.btnColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppButton(
                  margin: EdgeInsets.only(top: 20),
                  label: AppStrings.gotohome,
                  labelStyle: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  buttonColor: AppColors.btnColor,
                  onTap: () {
                    context.pushAndClearNavigator(HomeScreen());
                  },
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      AppUtils.log("=== CELEBRATION POST ERROR ===");
      AppUtils.log("Error Type: ${e.runtimeType}");
      AppUtils.log("Error Message: $e");
      AppUtils.log("Stack Trace: $stackTrace");
      AppUtils.log("=== END ERROR DEBUG ===");

      AppUtils.toastError('Failed to post celebration: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: TextView(
          text: "Celebrate",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: GestureDetector(
                onTap: _isValidForm ? _submitCelebration : null,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isValidForm ? AppColors.greenlight : Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextView(
                    text: "Share",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Selection
            TextView(
              text: "Select Category",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextView(
                          text: "Select Category",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 20),
                        ...categories
                            .map(
                              (category) => ListTile(
                                title: Text(
                                  _getCategoryDisplayName(category.name),
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedCategory = category;
                                    // Check if advertisement category is selected
                                    showAdvertisementWarning =
                                        _isAdvertisementCategory(category.name);
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedCategory != null
                          ? _getCategoryDisplayName(selectedCategory!.name)
                          : 'Choose Category',
                      style: TextStyle(
                        color: selectedCategory != null
                            ? Colors.black87
                            : Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.greenlight,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),

            // Advertisement warning
            if (showAdvertisementWarning) ...[
              SizedBox(height: 16),
              _buildAdvertisementWarning(),
            ],

            SizedBox(height: 24),

            // Celebration Image with Text Overlay
            Container(
              width: double.infinity,
              height: MediaQuery.of(
                context,
              ).size.width, // Responsive height based on width
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Background Image
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: Image.asset(
                        'assets/images/celebrateBack.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          AppUtils.log(
                            "Failed to load celebration background: $error",
                          );
                          // Fallback UI with gradient and celebration design
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF1B5E20),
                                  Color(0xFF2E7D32),
                                  Color(0xFF388E3C),
                                  Color(0xFF4CAF50),
                                ],
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Celebration particles effect
                                ...List.generate(
                                  15,
                                  (index) => Positioned(
                                    left: (index * 30.0) % 280,
                                    top: (index * 20.0) % 320,
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                                // Central celebration elements
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.celebration,
                                        size: 80,
                                        color: Colors.white.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        '🎉 CELEBRATION 🎉',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.6,
                                          ),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Text Overlay in Fixed Position (center)
                    Positioned(
                      left: 20,
                      right: 20,
                      top:
                          MediaQuery.of(context).size.width *
                          0.6, // Responsive positioning
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          controller: _textController,
                          maxLength: _maxCharacters,
                          maxLines: 5,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.greenlight,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.8),
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          decoration: InputDecoration(
                            hintText: "What are you celebrating?",
                            hintStyle: TextStyle(
                              color: AppColors.greenlight,
                              fontSize: 12,
                            ),
                            border: InputBorder.none,
                            counterText: "", // Hide the default counter
                          ),
                          onChanged: (value) {
                            // Enforce character limit by preventing input beyond limit
                            if (value.length > _maxCharacters) {
                              _textController.text = value.substring(
                                0,
                                _maxCharacters,
                              );
                              _textController.selection =
                                  TextSelection.fromPosition(
                                    TextPosition(offset: _maxCharacters),
                                  );
                            }
                            setState(() {}); // Refresh to update button state
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Character Count Display
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _textController.text.length >= _maxCharacters
                      ? Colors.red.withValues(alpha: 0.1)
                      : _textController.text.length >= _maxCharacters - 10
                      ? Colors.orange.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${_textController.text.length}/$_maxCharacters characters",
                  style: TextStyle(
                    color: _textController.text.length >= _maxCharacters
                        ? Colors.red
                        : _textController.text.length >= _maxCharacters - 10
                        ? Colors.orange
                        : Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
