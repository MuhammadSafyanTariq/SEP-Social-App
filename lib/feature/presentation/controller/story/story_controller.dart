import 'package:get/get.dart';
import 'package:sep/feature/data/models/dataModels/story_model.dart';
import 'package:sep/services/story_service.dart';
import 'package:sep/utils/appUtils.dart';

class StoryController extends GetxController {
  final StoryService _storyService = StoryService();

  RxList<UserStoryGroup> storyGroups = RxList([]);
  RxList<Story> myStories = RxList([]);
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;

  int currentPage = 1;
  final int itemsPerPage = 20;
  bool hasMorePages = true;

  @override
  void onInit() {
    super.onInit();
    print('🎯 StoryController onInit called');
    AppUtils.log('🎯 StoryController onInit called');
    // Initial fetch
    Future.delayed(Duration(milliseconds: 300), () {
      print('⏰ Starting delayed fetchStories from onInit');
      AppUtils.log('⏰ Starting delayed fetchStories from onInit');
      fetchStories();
    });
  }

  /// Fetch all stories from backend
  Future<void> fetchStories({bool isLoadMore = false}) async {
    print('📞 fetchStories CALLED - isLoadMore: $isLoadMore');
    AppUtils.log('📞 fetchStories CALLED - isLoadMore: $isLoadMore');
    try {
      if (isLoadMore) {
        if (!hasMorePages || isLoadingMore.value) return;
        isLoadingMore.value = true;
        currentPage++;
      } else {
        isLoading.value = true;
        currentPage = 1;
        hasMorePages = true;
      }

      AppUtils.log(
        '🔄 Calling _storyService.getAllStories - page: $currentPage',
      );
      final stories = await _storyService.getAllStories(
        page: currentPage,
        limit: itemsPerPage,
      );

      AppUtils.log('📦 Received ${stories.length} story groups from service');

      if (isLoadMore) {
        storyGroups.addAll(stories);
        hasMorePages = stories.length == itemsPerPage;
        AppUtils.log(
          '➕ Added to existing groups. Total: ${storyGroups.length}',
        );
      } else {
        storyGroups.value = stories;
        hasMorePages = stories.length == itemsPerPage;
        AppUtils.log('🔄 Replaced groups. Total: ${storyGroups.length}');
      }

      print(
        '✅ fetchStories complete - ${storyGroups.length} groups, hasMore: $hasMorePages',
      );
      AppUtils.log(
        '✅ fetchStories complete - ${storyGroups.length} groups, hasMore: $hasMorePages',
      );
    } catch (e, stackTrace) {
      print('❌❌❌ CRITICAL ERROR in fetchStories: $e');
      print('❌ Stack trace: $stackTrace');
      AppUtils.log('❌ CRITICAL ERROR in fetchStories: $e');
      AppUtils.log('❌ Stack trace: $stackTrace');
      if (isLoadMore) {
        currentPage--; // Revert page increment on error
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Refresh stories (pull to refresh)
  Future<void> refreshStories() async {
    await fetchStories(isLoadMore: false);
  }

  /// Get all stories for a specific user
  Future<List<Story>> getStoriesForUser(String userId) async {
    try {
      final stories = await _storyService.getUserStories(userId);
      AppUtils.log('Fetched ${stories.length} stories for user: $userId');
      return stories;
    } catch (e) {
      AppUtils.log('Error fetching user stories: $e');
      return [];
    }
  }

  /// Get current user's stories
  Future<void> fetchMyStories() async {
    try {
      isLoading.value = true;
      final stories = await _storyService.getMyStories();
      myStories.value = stories;
      AppUtils.log('Fetched ${stories.length} of my stories');
    } catch (e) {
      AppUtils.log('Error fetching my stories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// View a story
  Future<void> viewStory(String storyId) async {
    try {
      await _storyService.viewStory(storyId);

      // Update local state
      _updateStoryInList(storyId, (story) => story.copyWith(hasViewed: true));
    } catch (e) {
      AppUtils.log('Error viewing story: $e');
    }
  }

  /// Like/unlike a story
  Future<void> toggleLikeStory(String storyId) async {
    try {
      final result = await _storyService.toggleLike(storyId);

      if (result != null) {
        final isLiked = result['isLiked'];
        final likeCount = result['likeCount'];

        // Update local state
        _updateStoryInList(
          storyId,
          (story) => story.copyWith(isLiked: isLiked, likeCount: likeCount),
        );
      }
    } catch (e) {
      AppUtils.log('Error toggling like: $e');
    }
  }

  /// Delete a story
  Future<bool> deleteStory(String storyId) async {
    try {
      final success = await _storyService.deleteStory(storyId);

      if (success) {
        // Remove from local lists
        myStories.removeWhere((story) => story.id == storyId);

        for (var group in storyGroups) {
          group.stories.removeWhere((story) => story.id == storyId);
        }
        storyGroups.removeWhere((group) => group.stories.isEmpty);

        storyGroups.refresh();
      }

      return success;
    } catch (e) {
      AppUtils.log('Error deleting story: $e');
      return false;
    }
  }

  /// Helper to update a story in all lists
  void _updateStoryInList(String storyId, Story Function(Story) update) {
    // Update in story groups
    for (var group in storyGroups) {
      for (int i = 0; i < group.stories.length; i++) {
        if (group.stories[i].id == storyId) {
          group.stories[i] = update(group.stories[i]);
        }
      }
    }
    storyGroups.refresh();

    // Update in my stories
    for (int i = 0; i < myStories.length; i++) {
      if (myStories[i].id == storyId) {
        myStories[i] = update(myStories[i]);
      }
    }
    myStories.refresh();
  }

  /// Get total story count
  int get totalStoryCount {
    return storyGroups.fold(0, (sum, group) => sum + group.stories.length);
  }

  /// Check if user has any stories
  bool hasStoriesForUser(String userId) {
    return storyGroups.any(
      (group) => group.user.id == userId && group.stories.isNotEmpty,
    );
  }

  /// Get unviewed story count
  int get unviewedStoryCount {
    int count = 0;
    for (var group in storyGroups) {
      count += group.stories.where((story) => !story.hasViewed).length;
    }
    return count;
  }
}
