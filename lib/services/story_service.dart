import 'package:sep/feature/data/models/dataModels/story_model.dart';
import 'package:sep/feature/data/repository/story_repository.dart';
import 'package:sep/utils/appUtils.dart';

/// Story Service - High-level wrapper for story operations
class StoryService {
  final StoryRepository _repository = StoryRepository();

  /// Create a story with image
  Future<Story?> createImageStory({
    required String imageUrl,
    String? audioUrl,
    String? caption,
    String? thumbnailUrl,
  }) async {
    try {
      // Build files array - image first, then audio if present
      final files = [
        {
          'file': imageUrl,
          'type': 'image',
          if (thumbnailUrl != null) 'thumbnail': thumbnailUrl,
        },
        if (audioUrl != null) {'file': audioUrl, 'type': 'audio'},
      ];

      final response = await _repository.createStory(
        type: 'story',
        files: files,
        caption: caption,
      );

      if (response.isSuccess && response.data != null) {
        AppUtils.toast('Story created successfully!');
        return response.data;
      } else {
        AppUtils.toastError(
          response.error?.toString() ?? 'Failed to create story',
        );
        return null;
      }
    } catch (e) {
      AppUtils.toastError('Error creating story: $e');
      return null;
    }
  }

  /// Create a story with audio
  Future<Story?> createAudioStory({
    required String audioUrl,
    String? caption,
    String? thumbnailUrl,
  }) async {
    try {
      final response = await _repository.createStory(
        type: 'story',
        files: [
          {
            'file': audioUrl,
            'type': 'audio',
            if (thumbnailUrl != null) 'thumbnail': thumbnailUrl,
          },
        ],
        caption: caption,
      );

      if (response.isSuccess && response.data != null) {
        AppUtils.toast('Audio story created successfully!');
        return response.data;
      } else {
        AppUtils.toastError(
          response.error?.toString() ?? 'Failed to create audio story',
        );
        return null;
      }
    } catch (e) {
      AppUtils.toastError('Error creating audio story: $e');
      return null;
    }
  }

  /// Create a video story
  Future<Story?> createVideoStory({
    required String videoUrl,
    String? caption,
    String? thumbnailUrl,
  }) async {
    try {
      final response = await _repository.createStory(
        type: 'video',
        files: [
          {
            'file': videoUrl,
            'type': 'video',
            if (thumbnailUrl != null) 'thumbnail': thumbnailUrl,
          },
        ],
        caption: caption,
      );

      if (response.isSuccess && response.data != null) {
        AppUtils.toast('Video story created successfully!');
        return response.data;
      } else {
        AppUtils.toastError(
          response.error?.toString() ?? 'Failed to create video story',
        );
        return null;
      }
    } catch (e) {
      AppUtils.toastError('Error creating video story: $e');
      return null;
    }
  }

  /// Get all stories grouped by user
  Future<List<UserStoryGroup>> getAllStories({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print(
        '🔄 StoryService.getAllStories called - page: $page, limit: $limit',
      );
      AppUtils.log(
        '🔄 StoryService.getAllStories called - page: $page, limit: $limit',
      );
      final response = await _repository.getAllStories(
        page: page,
        limit: limit,
      );

      print(
        '📦 Response received - isSuccess: ${response.isSuccess}, hasData: ${response.data != null}',
      );

      if (response.isSuccess && response.data != null) {
        final stories = response.data!['stories'] as List<UserStoryGroup>;
        AppUtils.log(
          '✅ Retrieved ${stories.length} story groups from repository',
        );

        // Filter out expired stories
        final activeStories = stories.where((group) {
          final beforeCount = group.stories.length;
          group.stories.removeWhere((story) => story.isExpired);
          final afterCount = group.stories.length;
          if (beforeCount != afterCount) {
            AppUtils.log(
              '🗑️ Filtered out ${beforeCount - afterCount} expired stories for user: ${group.user.name}',
            );
          }
          return group.stories.isNotEmpty;
        }).toList();

        AppUtils.log('✅ Returning ${activeStories.length} active story groups');
        print(
          '✅ Service returning ${activeStories.length} active story groups',
        );
        return activeStories;
      } else {
        print('❌❌❌ SERVICE ERROR - Failed to fetch stories: ${response.error}');
        AppUtils.log('❌ Failed to fetch stories: ${response.error}');
        return [];
      }
    } catch (e, stackTrace) {
      print('❌❌❌ SERVICE EXCEPTION: $e');
      print('❌ Stack: $stackTrace');
      AppUtils.log('❌ Error fetching stories: $e');
      AppUtils.log('Stack trace: $stackTrace');
      return [];
    }
  }

  /// Get stories for a specific user
  Future<List<Story>> getUserStories(String userId) async {
    try {
      final response = await _repository.getUserStories(userId);

      if (response.isSuccess && response.data != null) {
        // Filter out expired stories
        final activeStories = response.data!
            .where((story) => !story.isExpired)
            .toList();
        return activeStories;
      } else {
        AppUtils.log('Failed to fetch user stories: ${response.error}');
        return [];
      }
    } catch (e) {
      AppUtils.log('Error fetching user stories: $e');
      return [];
    }
  }

  /// Get current user's stories
  Future<List<Story>> getMyStories() async {
    try {
      final response = await _repository.getMyStories();

      if (response.isSuccess && response.data != null) {
        // Filter out expired stories
        final activeStories = response.data!
            .where((story) => !story.isExpired)
            .toList();
        return activeStories;
      } else {
        AppUtils.log('Failed to fetch my stories: ${response.error}');
        return [];
      }
    } catch (e) {
      AppUtils.log('Error fetching my stories: $e');
      return [];
    }
  }

  /// View a story (mark as viewed)
  Future<bool> viewStory(String storyId) async {
    try {
      final response = await _repository.viewStory(storyId);

      if (response.isSuccess) {
        AppUtils.log('Story viewed successfully');
        return true;
      } else {
        AppUtils.log('Failed to view story: ${response.error}');
        return false;
      }
    } catch (e) {
      AppUtils.log('Error viewing story: $e');
      return false;
    }
  }

  /// Like or unlike a story
  Future<Map<String, dynamic>?> toggleLike(String storyId) async {
    try {
      final response = await _repository.likeStory(storyId);

      if (response.isSuccess && response.data != null) {
        final isLiked = response.data!['isLiked'];
        final likeCount = response.data!['likeCount'];

        // Show toast only for like action
        if (isLiked) {
          AppUtils.toast('Story liked!');
        }

        return response.data;
      } else {
        AppUtils.toastError(
          response.error?.toString() ?? 'Failed to like story',
        );
        return null;
      }
    } catch (e) {
      AppUtils.toastError('Error liking story: $e');
      return null;
    }
  }

  /// Delete a story
  Future<bool> deleteStory(String storyId) async {
    try {
      final response = await _repository.deleteStory(storyId);

      if (response.isSuccess) {
        AppUtils.toast('Story deleted successfully!');
        return true;
      } else {
        AppUtils.toastError(
          response.error?.toString() ?? 'Failed to delete story',
        );
        return false;
      }
    } catch (e) {
      AppUtils.toastError('Error deleting story: $e');
      return false;
    }
  }

  /// Get story details
  Future<Story?> getStoryDetails(String storyId) async {
    try {
      final response = await _repository.getStoryDetails(storyId);

      if (response.isSuccess && response.data != null) {
        return response.data;
      } else {
        AppUtils.log('Failed to fetch story details: ${response.error}');
        return null;
      }
    } catch (e) {
      AppUtils.log('Error fetching story details: $e');
      return null;
    }
  }
}
