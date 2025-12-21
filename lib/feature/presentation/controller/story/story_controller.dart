import 'package:get/get.dart';
import 'package:sep/feature/data/models/dataModels/post_data.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/utils/appUtils.dart';

class StoryController extends GetxController {
  late final ProfileCtrl profileCtrl;

  RxList<PostData> stories = RxList([]);
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    AppUtils.log('StoryController onInit called');
    try {
      profileCtrl = Get.find<ProfileCtrl>();
      AppUtils.log('ProfileCtrl found successfully');
      // Delay fetch to ensure ProfileCtrl is fully initialized
      Future.delayed(Duration(milliseconds: 300), () {
        AppUtils.log('Starting delayed fetchStories from onInit');
        fetchStories();
      });
    } catch (e) {
      AppUtils.log('Error in StoryController onInit: $e');
      isLoading.value = false;
    }
  }

  Future<void> fetchStories() async {
    try {
      isLoading.value = true;

      // Fetch all posts from global list
      await profileCtrl.globalList(
        offset: 1,
        isLoadMore: false,
        selectedCat: null,
      );

      final now = DateTime.now();
      final tempStories = <PostData>[];

      // Filter stories: posts with #sepstory tag that are within 24 hours
      for (var post in profileCtrl.globalPostList) {
        final content = post.content?.toLowerCase() ?? '';

        // Must have #sepstory tag
        if (!content.contains('#sepstory')) continue;

        // Check if story is still valid (within 24 hours)
        if (post.createdAt != null) {
          try {
            final createdAt = DateTime.parse(post.createdAt!);
            final difference = now.difference(createdAt);
            if (difference.inHours < 24) {
              tempStories.add(post);
            }
          } catch (e) {
            AppUtils.log('Error parsing createdAt: $e');
          }
        }
      }

      // Sort by newest first
      tempStories.sort((a, b) {
        if (a.createdAt == null || b.createdAt == null) return 0;
        return DateTime.parse(
          b.createdAt!,
        ).compareTo(DateTime.parse(a.createdAt!));
      });

      stories.value = tempStories;
      AppUtils.log('Fetched ${stories.length} stories');
    } catch (e) {
      AppUtils.log('Error fetching stories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshStories() async {
    await fetchStories();
  }

  // Get all stories for a specific user
  List<PostData> getStoriesForUser(String userId) {
    final now = DateTime.now();

    return profileCtrl.globalPostList.where((post) {
      final postUserId = post.user.isNotEmpty ? post.user.first.id : null;
      if (postUserId != userId) return false;

      final content = post.content?.toLowerCase() ?? '';
      if (!content.contains('#sepstory')) return false;

      // Check if story is still valid (within 24 hours)
      if (post.createdAt != null) {
        try {
          return now.difference(DateTime.parse(post.createdAt!)).inHours < 24;
        } catch (e) {
          return false;
        }
      }

      return false;
    }).toList()..sort((a, b) {
      if (a.createdAt == null || b.createdAt == null) return 0;
      return DateTime.parse(
        a.createdAt!,
      ).compareTo(DateTime.parse(b.createdAt!));
    });
  }
}
