import 'package:flutter/material.dart';
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
      appBar: AppBar(
        backgroundColor: Color(0xFF1a1a1a),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextView(
          text: "Select Type",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFF2a2a2a), Color(0xFF0f0f0f)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 0,
                mainAxisSpacing: 0,
                childAspectRatio: 1.3,
              ),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 7,
              itemBuilder: (context, index) {
                final items = [
                  {
                    'title': 'Post',
                    'icon': 'assets/icons/photo.png',
                    'onTap': () {
                      Navigator.pop(context);
                      context.pushNavigator(CreatePost(categoryid: ''));
                    },
                  },
                  {
                    'title': 'Poll',
                    'icon': 'assets/icons/poll.png',
                    'onTap': () {
                      Navigator.pop(context);
                      context.pushNavigator(AddPoll());
                    },
                  },
                  {
                    'title': 'Announcement',
                    'icon': 'assets/icons/celebrate.png',
                    'onTap': () {
                      Navigator.pop(context);
                      context.pushNavigator(CelebrationScreen());
                    },
                  },
                  {
                    'title': 'Opportunity',
                    'icon': 'assets/icons/bag.png',
                    'onTap': () {
                      Navigator.pop(context);
                      context.pushNavigator(const PostJobScreen());
                    },
                  },
                  {
                    'title': 'Marketplace',
                    'icon': 'assets/icons/carnival.png',
                    'onTap': () => _checkStoreAndNavigate(context),
                  },
                  {
                    'title': 'Invite',
                    'icon': 'assets/icons/gift.png',
                    'onTap': () {
                      Navigator.pop(context);
                      context.pushNavigator(const GameScreen(initialTab: 1));
                    },
                  },
                  {
                    'title': 'Property',
                    'icon': AppImages.realEstate,
                    'onTap': () => _checkStoreAndNavigateToRealEstate(context),
                  },
                ];

                return _buildOptionItem(
                  title: items[index]['title'] as String,
                  iconPath: items[index]['icon'] as String,
                  onTap: items[index]['onTap'] as VoidCallback,
                  index: index,
                  totalItems: items.length,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required String title,
    required String iconPath,
    required VoidCallback onTap,
    required int index,
    required int totalItems,
  }) {
    // Calculate if borders should be shown
    final bool showRight = index % 2 == 0; // Show right border on left column

    // Calculate how many items are in the last row
    final int itemsInLastRow = totalItems % 2 == 0 ? 2 : totalItems % 2;
    final int lastRowStartIndex = totalItems - itemsInLastRow;
    final bool showBottom =
        index < lastRowStartIndex; // Show bottom for all except last row

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: showRight
                ? BorderSide(color: Colors.white.withOpacity(0.05), width: 0.5)
                : BorderSide.none,
            bottom: showBottom
                ? BorderSide(color: Colors.white.withOpacity(0.05), width: 0.5)
                : BorderSide.none,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(iconPath, width: 50, height: 50, fit: BoxFit.contain),
            SizedBox(height: 12),
            TextView(
              text: title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
