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
import '../controller/chat_ctrl.dart';
import '../controller/auth_Controller/profileCtrl.dart';
import '../../data/models/dataModels/profile_data/profile_data_model.dart';

// Template model class
class CelebrationTemplate {
  final String id;
  final String name;
  final String assetPath;
  final double textTopPosition; // Position from top as ratio (0.0 to 1.0)
  final double? textBottomPosition; // Optional: Position from bottom
  final double textLeftPadding; // Left padding
  final double textRightPadding; // Right padding
  final Alignment textAlignment; // Horizontal alignment

  CelebrationTemplate({
    required this.id,
    required this.name,
    required this.assetPath,
    this.textTopPosition = 0.45, // Default center position
    this.textBottomPosition,
    this.textLeftPadding = 20,
    this.textRightPadding = 20,
    this.textAlignment = Alignment.center, // Default center alignment
  });
}

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

  // Template selection
  int selectedTemplateIndex = 0;

  // Text color selection
  int selectedColorIndex = 2;
  final List<Color> textColorPresets = [
    Color(0xFF4CAF50), // Green (default)
    Colors.white,
    Colors.black,
    Color(0xFFFF5722), // Orange
    Color(0xFFF44336), // Red
    Color(0xFF2196F3), // Blue
    Color(0xFFFFEB3B), // Yellow
    Color(0xFF9C27B0), // Purple
    Color(0xFFFF4081), // Pink
    Color(0xFF00BCD4), // Cyan
  ];

  // Draggable text position (as ratio 0.0 to 1.0)
  double textPositionX = 0.5; // Center horizontally
  double textPositionY = 0.5; // Center vertically

  final List<CelebrationTemplate> templates = [
    CelebrationTemplate(
      id: 'default',
      name: 'Default',
      assetPath: AppImages.celebrateBack,
      textTopPosition: 0.45,
      textAlignment: Alignment.center,
    ),
    CelebrationTemplate(
      id: 'template1',
      name: 'Template 1',
      assetPath: AppImages.celebrateTemplate1,
      textTopPosition: 0.15,
      textLeftPadding: 220,
      textRightPadding: 20,
      textAlignment: Alignment.center,
    ),
    CelebrationTemplate(
      id: 'template2',
      name: 'Template 2',
      assetPath: AppImages.celebrateTemplate2,
      textTopPosition: 0.29,
      textLeftPadding: 60,
      textRightPadding: 60,
      textAlignment: Alignment.center,
    ),
    CelebrationTemplate(
      id: 'template3',
      name: 'Template 3',
      assetPath: AppImages.celebrateTemplate3,
      textTopPosition: 0.12,
      textLeftPadding: 40,
      textRightPadding: 40,
      textAlignment: Alignment.center,
    ),
    CelebrationTemplate(
      id: 'template4',
      name: 'Template 4',
      assetPath: AppImages.celebrateTemplate4,
      textTopPosition: 0.275,
      textLeftPadding: 50,
      textRightPadding: 100,
      textAlignment: Alignment.center,
    ),
    CelebrationTemplate(
      id: 'template5',
      name: 'Template 5',
      assetPath: AppImages.celebrateTemplate5,
      textTopPosition: 0.32,
      textLeftPadding: 30,
      textRightPadding: 30,
      textAlignment: Alignment.center,
    ),
    CelebrationTemplate(
      id: 'template6',
      name: 'Template 6',
      assetPath: AppImages.celebrateTemplate6,
      textTopPosition: 0.2,
      textLeftPadding: 20,
      textRightPadding: 20,
      textAlignment: Alignment.center,
    ),
    CelebrationTemplate(
      id: 'template7',
      name: 'Template 7',
      assetPath: AppImages.celebrateTemplate7,
      textTopPosition: 0.15,
      textLeftPadding: 80,
      textRightPadding: 20,
      textAlignment: Alignment.center,
    ),
    CelebrationTemplate(
      id: 'template8',
      name: 'Template 8',
      assetPath: AppImages.celebrateTemplate8,
      textTopPosition: 0.55,
      textLeftPadding: 20,
      textRightPadding: 20,
      textAlignment: Alignment.center,
    ),
    CelebrationTemplate(
      id: 'template9',
      name: 'Template 9',
      assetPath: AppImages.celebrateTemplate9,
      textTopPosition: 0.38,
      textLeftPadding: 30,
      textRightPadding: 30,
      textAlignment: Alignment.center,
    ),
  ];

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

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              SizedBox(height: 20),
              TextView(
                text: "Choose Upload Option",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 30),

              // Upload as Post option
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.greenlight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.public,
                    color: AppColors.greenlight,
                    size: 24,
                  ),
                ),
                title: TextView(
                  text: "Upload as Post",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                subtitle: TextView(
                  text: "Share your celebration with everyone",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _submitCelebration();
                },
              ),

              SizedBox(height: 10),

              // Send as DM option
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.btnColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.send, color: AppColors.btnColor, size: 24),
                ),
                title: TextView(
                  text: "Send as DM",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                subtitle: TextView(
                  text: "Send privately to your friends",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showContactSelection();
                },
              ),

              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showContactSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return _ContactSelectionWidget(
              scrollController: scrollController,
              onContactsSelected: _sendCelebrationAsDM,
            );
          },
        );
      },
    );
  }

  void _sendCelebrationAsDM(List<ProfileDataModel> selectedContacts) async {
    if (selectedContacts.isEmpty) {
      AppUtils.toastError("Please select at least one contact");
      return;
    }

    try {
      // Create celebration card content
      final celebrationCard = _createCelebrationCard();
      AppUtils.log("Generated celebration card: $celebrationCard");

      final chatCtrl = ChatCtrl.find;
      int successCount = 0;

      // Send to each selected contact
      for (final contact in selectedContacts) {
        try {
          AppUtils.log(
            "Initializing chat with ${contact.name} (${contact.id})",
          );

          // Initialize chat with the contact
          chatCtrl.joinSingleChat(contact.id!, null);

          // Wait for chat initialization and verify singleChatId is set
          int attempts = 0;
          while (chatCtrl.singleChatId == null && attempts < 20) {
            await Future.delayed(Duration(milliseconds: 250));
            attempts++;
            AppUtils.log(
              "Waiting for chat initialization... attempt $attempts, chatId: ${chatCtrl.singleChatId}",
            );
          }

          if (chatCtrl.singleChatId == null) {
            AppUtils.log(
              "Failed to initialize chat with ${contact.name} - no chatId received",
            );
            continue;
          }

          AppUtils.log(
            "Chat initialized successfully with chatId: ${chatCtrl.singleChatId}",
          );
          AppUtils.log("Sending celebration message: $celebrationCard");

          // Send the celebration card
          chatCtrl.sendMessage(type: 'text', msg: celebrationCard);

          AppUtils.log("Message send method called for ${contact.name}");

          successCount++;
          AppUtils.log("Celebration sent to ${contact.name}");
        } catch (e) {
          AppUtils.log("Failed to send celebration to ${contact.name}: $e");
        }
      }

      // Clean up chat state
      chatCtrl.onLeaveChatRoom();

      if (successCount > 0) {
        _showSuccessDialog(successCount);
      } else {
        AppUtils.toastError("Failed to send celebration to contacts");
      }
    } catch (e) {
      AppUtils.log("Error sending celebration as DM: $e");
      AppUtils.toastError("Failed to send celebration. Please try again.");
    }
  }

  String _createCelebrationCard() {
    final templateId = templates[selectedTemplateIndex].id;
    final colorHex = textColorPresets[selectedColorIndex].value
        .toRadixString(16)
        .padLeft(8, '0');
    final posX = textPositionX.toStringAsFixed(3);
    final posY = textPositionY.toStringAsFixed(3);
    final message = _textController.text.trim();

    AppUtils.log(
      "Creating celebration card - Template: $templateId, selectedTemplateIndex: $selectedTemplateIndex",
    );
    AppUtils.log("Template list: ${templates.map((t) => t.id).toList()}");

    // Create celebration card content that can be displayed properly in chat
    return 'SEP#Celebrate+$templateId+$colorHex+$posX+$posY+$message';
  }

  void _showSuccessDialog(int successCount) {
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
                  text: "Celebration sent successfully!",
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
                    "Your celebration has been sent to $successCount friend${successCount > 1 ? 's' : ''}!",
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
                  Navigator.of(context).pop(); // Close dialog
                  context.pushAndClearNavigator(
                    HomeScreen(),
                  ); // Navigate to home
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
      // Include template ID, color, and position: SEP#Celebrate+[templateId]+[colorHex]+[posX]+[posY]+[message]
      String templateId = templates[selectedTemplateIndex].id;
      String colorHex = textColorPresets[selectedColorIndex].value
          .toRadixString(16)
          .padLeft(8, '0');
      String posX = textPositionX.toStringAsFixed(3);
      String posY = textPositionY.toStringAsFixed(3);
      String celebrationCaption =
          "SEP#Celebrate+$templateId+$colorHex+$posX+$posY+${_textController.text.trim()}";

      // Debug logging
      AppUtils.log("=== CELEBRATION POST DEBUG ===");
      AppUtils.log("User ID: ${Preferences.uid ?? 'NULL'}");
      AppUtils.log("Category ID: ${selectedCategory!.id ?? 'NULL'}");
      AppUtils.log("Category Name: ${selectedCategory!.name ?? 'NULL'}");
      AppUtils.log("Template ID: $templateId");
      AppUtils.log("Text Color: $colorHex");
      AppUtils.log("Text Position: X=$posX, Y=$posY");
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
                    Navigator.of(context).pop(); // Close dialog first
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
                onTap: _isValidForm ? _showUploadOptions : null,
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

            // Template Selection
            TextView(
              text: "Choose Template",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Container(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  final isSelected = selectedTemplateIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTemplateIndex = index;
                      });
                    },
                    child: Container(
                      width: 140,
                      margin: EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.greenlight
                              : Colors.grey[300]!,
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.greenlight.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : [],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            Image.asset(
                              templates[index].assetPath,
                              fit: BoxFit.cover,
                              width: 160,
                              height: 100,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey[400],
                                  ),
                                );
                              },
                            ),
                            if (isSelected)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: AppColors.greenlight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  templates[index].name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 24),

            // Text Color Selection
            TextView(
              text: "Text Color",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Container(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: textColorPresets.length,
                itemBuilder: (context, index) {
                  final isSelected = selectedColorIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColorIndex = index;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: textColorPresets[index],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.greenlight
                              : Colors.grey[300]!,
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: textColorPresets[index].withOpacity(
                                    0.4,
                                  ),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : [],
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color:
                                  textColorPresets[index].computeLuminance() >
                                      0.5
                                  ? Colors.black
                                  : Colors.white,
                              size: 24,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 24),

            // Celebration Image with Text Overlay
            Container(
              width: double.infinity,
              height:
                  MediaQuery.of(context).size.width *
                  0.6, // 4:3 aspect ratio (rectangular)
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
                        templates[selectedTemplateIndex].assetPath,
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

                    // Draggable Text Overlay
                    Positioned(
                      left:
                          MediaQuery.of(context).size.width * textPositionX -
                          150,
                      top:
                          MediaQuery.of(context).size.width *
                              0.6 *
                              textPositionY -
                          60,
                      child: Draggable(
                        feedback: Material(
                          color: Colors.transparent,
                          child: Container(
                            width: 300,
                            height: 120,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _textController.text.isEmpty
                                  ? "What are you celebrating?"
                                  : _textController.text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textColorPresets[selectedColorIndex],
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: Container(
                            width: 300,
                            height: 120,
                            padding: EdgeInsets.all(16),
                            child: TextField(
                              controller: _textController,
                              maxLength: _maxCharacters,
                              maxLines: 5,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textColorPresets[selectedColorIndex],
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                hintText: "What are you celebrating?",
                                hintStyle: TextStyle(
                                  color: textColorPresets[selectedColorIndex]
                                      .withOpacity(0.6),
                                  fontSize: 12,
                                ),
                                border: InputBorder.none,
                                counterText: "",
                              ),
                            ),
                          ),
                        ),
                        onDragEnd: (details) {
                          setState(() {
                            // Calculate position as ratio (0.0 to 1.0) relative to container
                            final containerWidth = MediaQuery.of(
                              context,
                            ).size.width;
                            final containerHeight = containerWidth * 0.6;

                            // Get the drag position and clamp to container bounds
                            double newX =
                                (details.offset.dx + 150) / containerWidth;
                            double newY =
                                (details.offset.dy + 60) / containerHeight;

                            // Clamp values between 0.1 and 0.9 to keep text visible
                            textPositionX = newX.clamp(0.1, 0.9);
                            textPositionY = newY.clamp(0.1, 0.9);

                            AppUtils.log(
                              "Text position updated: X=$textPositionX, Y=$textPositionY",
                            );
                          });
                        },
                        child: Container(
                          width: 300,
                          height: 120,
                          padding: EdgeInsets.all(16),
                          child: TextField(
                            controller: _textController,
                            maxLength: _maxCharacters,
                            maxLines: 5,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: textColorPresets[selectedColorIndex],
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              hintText: "What are you celebrating?",
                              hintStyle: TextStyle(
                                color: textColorPresets[selectedColorIndex]
                                    .withOpacity(0.6),
                                fontSize: 12,
                              ),
                              border: InputBorder.none,
                              counterText: "",
                            ),
                            onChanged: (value) {
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
                              setState(() {});
                            },
                          ),
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

class _ContactSelectionWidget extends StatefulWidget {
  final ScrollController scrollController;
  final Function(List<ProfileDataModel>) onContactsSelected;

  const _ContactSelectionWidget({
    Key? key,
    required this.scrollController,
    required this.onContactsSelected,
  }) : super(key: key);

  @override
  State<_ContactSelectionWidget> createState() =>
      _ContactSelectionWidgetState();
}

class _ContactSelectionWidgetState extends State<_ContactSelectionWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<ProfileDataModel> _allContacts = [];
  List<ProfileDataModel> _filteredContacts = [];
  final Set<String> _selectedContactIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadContacts() async {
    try {
      final profileCtrl = ProfileCtrl.find;

      // Load both followers and following
      await profileCtrl.getMyFollowings();

      setState(() {
        _allContacts = profileCtrl.myFollowingList.toList();
        _filteredContacts = _allContacts;
        _isLoading = false;
      });
    } catch (e) {
      AppUtils.log("Error loading contacts: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = _allContacts;
      } else {
        _filteredContacts = _allContacts
            .where(
              (contact) => contact.name?.toLowerCase().contains(query) ?? false,
            )
            .toList();
      }
    });
  }

  void _toggleContactSelection(ProfileDataModel contact) {
    setState(() {
      if (_selectedContactIds.contains(contact.id)) {
        _selectedContactIds.remove(contact.id);
      } else {
        _selectedContactIds.add(contact.id!);
      }
    });
  }

  void _sendToSelectedContacts() {
    final selectedContacts = _allContacts
        .where((contact) => _selectedContactIds.contains(contact.id))
        .toList();
    widget.onContactsSelected(selectedContacts);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12, bottom: 20),
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextView(
                  text: "Select Friends",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: _selectedContactIds.isEmpty
                      ? null
                      : _sendToSelectedContacts,
                  child: TextView(
                    text: "Send (${_selectedContactIds.length})",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _selectedContactIds.isEmpty
                          ? Colors.grey
                          : AppColors.btnColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search friends...",
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.btnColor),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Contacts list
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredContacts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        TextView(
                          text: _allContacts.isEmpty
                              ? "No friends found.\nConnect with people to send celebrations!"
                              : "No friends match your search",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: widget.scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = _filteredContacts[index];
                      final isSelected = _selectedContactIds.contains(
                        contact.id,
                      );

                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          tileColor: isSelected
                              ? AppColors.btnColor.withOpacity(0.1)
                              : Colors.transparent,
                          leading: ImageView(
                            url: AppUtils.configImageUrl(contact.image ?? ''),
                            size: 50,
                            imageType: ImageType.network,
                            defaultImage: AppImages.dummyProfile,
                            radius: 25,
                            fit: BoxFit.cover,
                          ),
                          title: TextView(
                            text: contact.name ?? "Unknown",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          trailing: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.btnColor
                                    : Colors.grey[400]!,
                                width: 2,
                              ),
                              color: isSelected
                                  ? AppColors.btnColor
                                  : Colors.transparent,
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : null,
                          ),
                          onTap: () => _toggleContactSelection(contact),
                        ),
                      );
                    },
                  ),
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
