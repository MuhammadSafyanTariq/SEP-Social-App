import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/feature/presentation/controller/story/story_controller.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/styles/appImages.dart';
import 'story_create_screen.dart';
import 'story_view_screen.dart';

class StoryListWidget extends StatefulWidget {
  const StoryListWidget({Key? key}) : super(key: key);

  @override
  State<StoryListWidget> createState() => _StoryListWidgetState();
}

class _StoryListWidgetState extends State<StoryListWidget> {
  late final StoryController storyController;

  @override
  void initState() {
    super.initState();
    AppUtils.log('=== StoryListWidget initState START ===');
    try {
      // Try to find existing controller first, or create new one
      if (Get.isRegistered<StoryController>()) {
        storyController = Get.find<StoryController>();
        AppUtils.log('Found existing StoryController');
        // Refresh stories when widget is recreated
        Future.delayed(Duration(milliseconds: 100), () {
          if (mounted) {
            AppUtils.log('⏰ Refreshing stories from existing controller...');
            storyController.fetchStories();
          }
        });
      } else {
        AppUtils.log('Creating new StoryController...');
        storyController = Get.put(StoryController());
        AppUtils.log('StoryController created successfully');
        // Controller's onInit will call fetchStories, no need to call again
      }
    } catch (e, stackTrace) {
      AppUtils.log('ERROR initializing StoryController: $e');
      AppUtils.log('Stack trace: $stackTrace');
    }
    AppUtils.log('=== StoryListWidget initState END ===');
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      AppUtils.log(
        'StoryListWidget building - Stories count: ${storyController.stories.length}, Loading: ${storyController.isLoading.value}',
      );

      if (storyController.isLoading.value && storyController.stories.isEmpty) {
        return Container(
          height: 110,
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (storyController.stories.isEmpty && !storyController.isLoading.value) {
        // Only show create story button when no stories
        return Container(
          height: 110,
          margin: EdgeInsets.symmetric(vertical: 5),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12),
            children: [_buildCreateStoryButton(context)],
          ),
        );
      }

      return Container(
        height: 110,
        margin: EdgeInsets.symmetric(vertical: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 12),
          itemCount: storyController.stories.length + 1,
          itemBuilder: (context, index) {
            // First item - Create Story
            if (index == 0) {
              return _buildCreateStoryButton(context);
            }

            // Story items
            final storyIndex = index - 1;
            final story = storyController.stories[storyIndex];
            final user = story.user.isNotEmpty ? story.user.first : null;
            final userImageUrl = user?.image?.isNotEmpty == true
                ? AppUtils.configImageUrl(user!.image!)
                : AppImages.dummyProfile;

            return GestureDetector(
              onTap: () {
                // Open this single story
                AppUtils.log('Opening story: ${story.id}');
                context.pushNavigator(
                  StoryViewScreen(initialIndex: 0, stories: [story]),
                );
              },
              child: Container(
                width: 70,
                margin: EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor,
                            AppColors.primaryColor.withOpacity(0.5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: EdgeInsets.all(3),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.all(2),
                        child: ClipOval(
                          child: ImageView(
                            url: userImageUrl,
                            size: 64,
                            radius: 32,
                            imageType: user?.image?.isNotEmpty == true
                                ? ImageType.network
                                : null,
                            defaultImage: AppImages.dummyProfile,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      user?.name ?? 'Unknown',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildCreateStoryButton(BuildContext context) {
    final profileImage = Preferences.profile?.image;
    final imageUrl = profileImage != null && profileImage.isNotEmpty
        ? AppUtils.configImageUrl(profileImage)
        : AppImages.dummyProfile;

    return GestureDetector(
      onTap: () {
        context.pushNavigator(StoryCreateScreen());
      },
      child: Container(
        width: 70,
        margin: EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
              ),
              child: Stack(
                children: [
                  ClipOval(
                    child: ImageView(
                      url: imageUrl,
                      size: 70,
                      radius: 35,
                      imageType: profileImage != null && profileImage.isNotEmpty
                          ? ImageType.network
                          : null,
                      defaultImage: AppImages.dummyProfile,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(Icons.add, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Add Story',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
