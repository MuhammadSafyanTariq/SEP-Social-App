import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/feature/presentation/controller/story/story_controller.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/styles/appImages.dart';
import 'story_create_screen_new.dart';
import 'story_view_screen_new.dart';

class StoryListWidgetNew extends StatefulWidget {
  const StoryListWidgetNew({Key? key}) : super(key: key);

  @override
  State<StoryListWidgetNew> createState() => _StoryListWidgetNewState();
}

class _StoryListWidgetNewState extends State<StoryListWidgetNew> {
  late final StoryController storyController;

  @override
  void initState() {
    super.initState();
    print('🚀 === StoryListWidgetNew initState START ===');
    AppUtils.log('🚀 === StoryListWidgetNew initState START ===');
    try {
      if (Get.isRegistered<StoryController>()) {
        storyController = Get.find<StoryController>();
        print('✅ Found existing StoryController');
        AppUtils.log('✅ Found existing StoryController');
        // Call immediately without delay to see if it's a timing issue
        Future.microtask(() {
          if (mounted) {
            print('🔄 Calling fetchStories immediately...');
            AppUtils.log('🔄 Calling fetchStories immediately...');
            storyController.fetchStories();
          }
        });
      } else {
        print('🆕 Creating new StoryController...');
        AppUtils.log('🆕 Creating new StoryController...');
        storyController = Get.put(StoryController());
        print('✅ StoryController created successfully');
        AppUtils.log('✅ StoryController created successfully');
      }
    } catch (e, stackTrace) {
      print('❌ ERROR initializing StoryController: $e');
      print('Stack trace: $stackTrace');
      AppUtils.log('❌ ERROR initializing StoryController: $e');
      AppUtils.log('Stack trace: $stackTrace');
    }
    print('🏁 === StoryListWidgetNew initState END ===');
    AppUtils.log('🏁 === StoryListWidgetNew initState END ===');
  }

  @override
  Widget build(BuildContext context) {
    // Force a fetch if we have no stories and aren't loading
    if (storyController.storyGroups.isEmpty &&
        !storyController.isLoading.value) {
      print('⚠️ BUILD: No stories and not loading - forcing fetch');
      Future.microtask(() => storyController.fetchStories());
    }

    return Obx(() {
      print(
        '🎨 BUILD: Story groups: ${storyController.storyGroups.length}, Loading: ${storyController.isLoading.value}',
      );
      AppUtils.log(
        'StoryListWidget building - Story groups: ${storyController.storyGroups.length}, Loading: ${storyController.isLoading.value}',
      );

      if (storyController.isLoading.value &&
          storyController.storyGroups.isEmpty) {
        return Container(
          height: 110,
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          ),
        );
      }

      if (storyController.storyGroups.isEmpty &&
          !storyController.isLoading.value) {
        return Container(
          height: 110,
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        print('🔴 MANUAL FETCH TRIGGERED');
                        storyController.fetchStories();
                      },
                      child: Text('Refresh Stories'),
                    ),
                    Text('No stories loaded', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  children: [_buildCreateStoryButton(context)],
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        height: 110,
        margin: EdgeInsets.symmetric(vertical: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 12),
          itemCount: storyController.storyGroups.length + 1,
          itemBuilder: (context, index) {
            // First item - Create Story
            if (index == 0) {
              return _buildCreateStoryButton(context);
            }

            // Story items
            final groupIndex = index - 1;
            final storyGroup = storyController.storyGroups[groupIndex];
            final user = storyGroup.user;
            final stories = storyGroup.stories;

            final userImageUrl = user.image?.isNotEmpty == true
                ? AppUtils.configImageUrl(user.image!)
                : AppImages.dummyProfile;

            // Check if user has unviewed stories
            final hasUnviewed = storyGroup.hasUnviewedStories;

            return GestureDetector(
              onTap: () {
                AppUtils.log(
                  'Opening ${stories.length} stories for user: ${user.name}',
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StoryViewScreenNew(
                      storyGroups: [storyGroup],
                      initialGroupIndex: 0,
                    ),
                  ),
                );
              },
              child: Container(
                width: 70,
                margin: EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 74,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: hasUnviewed
                                ? LinearGradient(
                                    colors: [
                                      AppColors.primaryColor,
                                      AppColors.btnColor,
                                    ],
                                  )
                                : null,
                            border: !hasUnviewed
                                ? Border.all(color: Colors.grey, width: 2)
                                : null,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: ImageView(
                                  url: userImageUrl,
                                  height: 60,
                                  width: 64,
                                  imageType: user.image?.isNotEmpty == true
                                      ? ImageType.network
                                      : null,
                                  defaultImage: AppImages.dummyProfile,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Story count badge
                        if (stories.length > 1)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '${stories.length}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      user.name ?? 'Unknown',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: Colors.black87),
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
    final currentUser = Preferences.profile;
    final userImageUrl = currentUser?.image?.isNotEmpty == true
        ? AppUtils.configImageUrl(currentUser!.image!)
        : AppImages.dummyProfile;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StoryCreateScreenNew()),
        ).then((result) {
          if (result == true) {
            // Refresh stories after creating
            storyController.refreshStories();
          }
        });
      },
      child: Container(
        width: 70,
        margin: EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(3),
                    child: ClipOval(
                      child: ImageView(
                        url: userImageUrl,
                        height: 64,
                        width: 64,
                        imageType: currentUser?.image?.isNotEmpty == true
                            ? ImageType.network
                            : null,
                        defaultImage: AppImages.dummyProfile,
                        fit: BoxFit.cover,
                      ),
                    ),
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
                    child: Icon(Icons.add, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              'Your Story',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
