import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/services/networking/apiMethods.dart';
import 'package:sep/services/networking/urls.dart';
import 'CreatePost.dart';
import 'polladd.dart';
import 'celebrationScreen.dart';
import '../jobs/post_job_screen.dart';
import '../products/upload_product_screen.dart';
import '../game_screens/game_screen.dart';
import '../real_estate/upload_real_estate_screen.dart';
import '../../../components/styles/appImages.dart';

class TypeSelectionScreen extends StatefulWidget {
  const TypeSelectionScreen({super.key});

  @override
  State<TypeSelectionScreen> createState() => _TypeSelectionScreenState();
}

class _TypeSelectionScreenState extends State<TypeSelectionScreen> {
  final IApiMethod _apiMethod = IApiMethod();

  Future<void> _checkStoreAndNavigate(BuildContext context) async {
    try {
      final token = Preferences.authToken;

      if (token == null) {
        _showCreateStoreAlert(context);
        return;
      }

      final response = await _apiMethod.get(
        url: Urls.getMyShop,
        authToken: token,
        headers: {},
      );

      AppUtils.log("Check store response: ${response.data}");

      // Check if user has a store - same logic as SportsProduct screen
      if (response.isSuccess && response.data?['data'] != null) {
        final shopData = response.data!['data'];
        final shopId = shopData['_id'] as String?;

        if (!mounted) return;

        if (shopId != null && shopId.isNotEmpty) {
          // User has a store, navigate to upload product
          AppUtils.log("User has store with ID: $shopId");
          Navigator.pop(context);
          context.pushNavigator(const UploadProductScreen());
        } else {
          // Shop data exists but no ID
          _showCreateStoreAlert(context);
        }
      } else {
        // User doesn't have a store
        if (!mounted) return;
        AppUtils.log("No shop found: ${response.getError}");
        _showCreateStoreAlert(context);
      }
    } catch (e) {
      // Error or no store found
      AppUtils.log('Error checking store: $e');
      if (!mounted) return;
      _showCreateStoreAlert(context);
    }
  }

  void _showCreateStoreAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create a Shop First'),
          content: const Text(
            'You need to create a shop before you can add products. Please create your shop from the Profile Settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkStoreAndNavigateToRealEstate(BuildContext context) async {
    try {
      final token = Preferences.authToken;

      if (token == null) {
        _showCreateStoreAlert(context);
        return;
      }

      final response = await _apiMethod.get(
        url: Urls.getMyShop,
        authToken: token,
        headers: {},
      );

      AppUtils.log("Check store response: ${response.data}");

      // Check if user has a store - same logic as SportsProduct screen
      if (response.isSuccess && response.data?['data'] != null) {
        final shopData = response.data!['data'];
        final shopId = shopData['_id'] as String?;

        if (!mounted) return;

        if (shopId != null && shopId.isNotEmpty) {
          // User has a store, navigate to upload real estate
          AppUtils.log("User has store with ID: $shopId");
          Navigator.pop(context);
          context.pushNavigator(const UploadRealEstateScreen());
        } else {
          // Shop data exists but no ID
          _showCreateStoreAlert(context);
        }
      } else {
        // User doesn't have a store
        if (!mounted) return;
        AppUtils.log("No shop found: ${response.getError}");
        _showCreateStoreAlert(context);
      }
    } catch (e) {
      // Error or no store found
      AppUtils.log('Error checking store: $e');
      if (!mounted) return;
      _showCreateStoreAlert(context);
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
          onPressed: () => Navigator.pop(context),
        ),
        title: TextView(
          text: "Post",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            TextView(
              text: "Select Type",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            // Center the options vertically
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildOptionItem(
                              title: "Media",
                              iconPath: 'assets/icons/photo.png',
                              onTap: () {
                                Navigator.pop(context);
                                context.pushNavigator(
                                  CreatePost(categoryid: ''),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildOptionItem(
                              title: "Poll",
                              iconPath: 'assets/icons/poll.png',
                              onTap: () {
                                Navigator.pop(context);
                                context.pushNavigator(AddPoll());
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: _buildOptionItem(
                              title: "Celebrate",
                              iconPath: 'assets/icons/celebrate.png',
                              onTap: () {
                                Navigator.pop(context);
                                context.pushNavigator(CelebrationScreen());
                              },
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildOptionItem(
                              title: "Job",
                              iconPath: 'assets/icons/bag.png',
                              onTap: () {
                                Navigator.pop(context);
                                context.pushNavigator(const PostJobScreen());
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: _buildOptionItem(
                              title: "Product",
                              iconPath: 'assets/icons/carnival.png',
                              onTap: () => _checkStoreAndNavigate(context),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildOptionItem(
                              title: "Refer",
                              iconPath: 'assets/icons/gift.png',
                              onTap: () {
                                Navigator.pop(context);
                                // Navigate to GameScreen's Refer a Friend tab (index 1)
                                context.pushNavigator(
                                  const GameScreen(initialTab: 1),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: _buildOptionItem(
                              title: "Real Estate",
                              iconPath: AppImages.realEstate,
                              onTap: () =>
                                  _checkStoreAndNavigateToRealEstate(context),
                            ),
                          ),
                          SizedBox(width: 12),
                          // Empty space for grid alignment
                          Expanded(child: SizedBox()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required String title,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Image.asset(iconPath, width: 36, height: 36, fit: BoxFit.contain),
          SizedBox(width: 12),
          Expanded(
            child: TextView(
              text: title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
