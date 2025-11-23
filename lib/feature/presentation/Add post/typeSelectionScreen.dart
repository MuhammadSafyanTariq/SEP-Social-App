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
            'You need to create a shop before you can add products. Please create your shop from the SEP Shop section.',
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
                              icon: Icons.image,
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
                              icon: Icons.poll_outlined,
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
                              icon: Icons.celebration,
                              onTap: () {
                                Navigator.pop(context);
                                context.pushNavigator(CelebrationScreen());
                              },
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildOptionItem(
                              title: "Add Job",
                              icon: Icons.work_outline,
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
                              title: "Add Product",
                              icon: Icons.shopping_bag_outlined,
                              onTap: () => _checkStoreAndNavigate(context),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildOptionItem(
                              title: "Invite Friend",
                              icon: Icons.person_add_outlined,
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
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Icon(icon, size: 24, color: Colors.grey[600]),
          ),
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
