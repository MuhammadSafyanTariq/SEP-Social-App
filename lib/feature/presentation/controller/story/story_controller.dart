import 'package:get/get.dart';
import 'package:sep/feature/data/models/dataModels/post_data.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/feature/presentation/profileScreens/profileScreen.dart';
import 'package:sep/services/storage/preferences.dart';
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
      fetchStories();
    } catch (e) {
      AppUtils.log('Error in StoryController onInit: $e');
      isLoading.value = false;
    }
  }

  Future<void> fetchStories() async {
    AppUtils.log('=== fetchStories ENTRY ===');
    try {
      isLoading.value = true;
      AppUtils.log('=== Starting fetchStories ===');

      // Fetch current user's profile posts to include their own stories
      final currentUserId = Preferences.uid;
      AppUtils.log('Current user ID: $currentUserId');
      
      if (currentUserId != null) {
        try {
          // Fetch current user's posts by type
          await profileCtrl.getMyProfilePosts(type: PostFileType.image, refresh: true);
          await profileCtrl.getMyProfilePosts(type: PostFileType.video, refresh: true);
          await profileCtrl.getMyProfilePosts(type: PostFileType.poll, refresh: true);
          AppUtils.log('Fetched current user profile posts');
        } catch (e) {
          AppUtils.log('Error fetching user posts: $e');
          // Continue even if user posts fail
        }
      }

      // Fetch all posts from the global list (followers + followings)
      await profileCtrl.globalList(
        offset: 1,
        isLoadMore: false,
        selectedCat: null,
      );
      AppUtils.log('Fetched global posts: ${profileCtrl.globalPostList.length}');

      // Combine global posts and current user's posts
      final allPosts = <PostData>[];
      allPosts.addAll(profileCtrl.globalPostList);
      
      // Add current user's own posts (image, video, poll posts)
      final imageCount = profileCtrl.profileImagePostList.length;
      final videoCount = profileCtrl.profileVideoPostList.length;
      final pollCount = profileCtrl.profilePollPostList.length;
      
      allPosts.addAll(profileCtrl.profileImagePostList);
      allPosts.addAll(profileCtrl.profileVideoPostList);
      allPosts.addAll(profileCtrl.profilePollPostList);
      
      AppUtils.log('User posts - Image: $imageCount, Video: $videoCount, Poll: $pollCount');
      AppUtils.log('Total posts combined: ${allPosts.length}');

      final now = DateTime.now();
      final tempStories = <PostData>[];

      // Filter stories from all posts
      for (var post in allPosts) {
        final content = post.content?.toLowerCase() ?? '';
        final userId = post.user != null && post.user!.isNotEmpty ? post.user!.first.id : null;
        AppUtils.log('Checking post ID: ${post.id}, userId: $userId, content: ${content.substring(0, content.length > 50 ? 50 : content.length)}');
        
        if (!content.contains('#sepstory')) {
          continue;
        }
        
        AppUtils.log('Found post with #sepstory tag: ${post.id}, user: ${userId}');

        // Check if story is not older than 24 hours
        if (post.createdAt != null) {
          try {
            final createdAt = DateTime.parse(post.createdAt!);
            final difference = now.difference(createdAt);
            AppUtils.log('Story age: ${difference.inHours} hours');
            
            if (difference.inHours < 24) {
              tempStories.add(post);
              AppUtils.log('Added story to tempStories: ${post.id}');
            } else {
              AppUtils.log('Story too old, skipping');
            }
          } catch (e) {
            AppUtils.log('Error parsing date: $e');
          }
        } else {
          AppUtils.log('Post has no createdAt date, skipping');
        }
      }
      
      AppUtils.log('=== Total stories before dedup: ${tempStories.length} ===');

      // Remove duplicates based on post ID
      final seenIds = <String>{};
      final uniqueStories = tempStories.where((post) {
        if (post.id == null) return false;
        if (seenIds.contains(post.id)) return false;
        seenIds.add(post.id!);
        return true;
      }).toList();
      
      AppUtils.log('=== Stories after dedup: ${uniqueStories.length} ===');

      // Sort by creation date (newest first)
      uniqueStories.sort((a, b) {
        if (a.createdAt == null || b.createdAt == null) return 0;
        try {
          final dateA = DateTime.parse(a.createdAt!);
          final dateB = DateTime.parse(b.createdAt!);
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });
      
      AppUtils.log('=== Stories after sorting: ${uniqueStories.length} ===');

      // Group stories by user - show only the first (latest) story per user
      final seenUserIds = <String>{};
      stories.value = uniqueStories.where((post) {
        final userId = post.user != null && post.user!.isNotEmpty ? post.user!.first.id : null;
        AppUtils.log('Grouping check - Post ${post.id}, userId: $userId');
        if (userId == null) {
          AppUtils.log('Story has no user ID, skipping: ${post.id}');
          return false;
        }
        if (seenUserIds.contains(userId)) {
          AppUtils.log('Already seen user $userId, skipping story: ${post.id}');
          return false;
        }
        seenUserIds.add(userId);
        AppUtils.log('Adding story for user $userId: ${post.id}');
        return true;
      }).toList();

      AppUtils.log('=== Final story count: ${stories.length} (grouped by user) ===');
    } catch (e, stackTrace) {
      AppUtils.log('Error fetching stories: $e');
      AppUtils.log('Stack trace: $stackTrace');
    } finally {
      isLoading.value = false;
      AppUtils.log('=== fetchStories COMPLETE ===');
    }
  }

  Future<void> refreshStories() async {
    await fetchStories();
  }

  // Get all stories for a specific user
  List<PostData> getStoriesForUser(String userId) {
    final allStories = <PostData>[];
    
    // Collect all posts (global + user's own)
    final allPosts = <PostData>[];
    allPosts.addAll(profileCtrl.globalPostList);
    allPosts.addAll(profileCtrl.profileImagePostList);
    allPosts.addAll(profileCtrl.profileVideoPostList);
    allPosts.addAll(profileCtrl.profilePollPostList);

    final now = DateTime.now();
    
    // Filter stories for this specific user
    for (var post in allPosts) {
      final postUserId = post.user != null && post.user!.isNotEmpty ? post.user!.first.id : null;
      if (postUserId != userId) continue;
      
      final content = post.content?.toLowerCase() ?? '';
      if (!content.contains('#sepstory')) continue;
      
      // Check if story is not older than 24 hours
      if (post.createdAt != null) {
        try {
          final createdAt = DateTime.parse(post.createdAt!);
          final difference = now.difference(createdAt);
          if (difference.inHours < 24) {
            allStories.add(post);
          }
        } catch (e) {
          // Skip invalid dates
        }
      }
    }

    // Remove duplicates and sort by creation date (oldest first for viewing)
    final seenIds = <String>{};
    final uniqueStories = allStories.where((post) {
      if (post.id == null) return false;
      if (seenIds.contains(post.id)) return false;
      seenIds.add(post.id!);
      return true;
    }).toList();

    uniqueStories.sort((a, b) {
      if (a.createdAt == null || b.createdAt == null) return 0;
      try {
        final dateA = DateTime.parse(a.createdAt!);
        final dateB = DateTime.parse(b.createdAt!);
        return dateA.compareTo(dateB); // Oldest first
      } catch (e) {
        return 0;
      }
    });

    return uniqueStories;
  }
}
