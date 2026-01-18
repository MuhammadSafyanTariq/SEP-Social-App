import 'package:sep/feature/data/models/dataModels/story_model.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/extensions.dart';
import '../../../services/networking/apiMethods.dart';
import '../../data/models/dataModels/responseDataModel.dart';

String? get _authToken => Preferences.authToken?.bearer;

class StoryRepository {
  final IApiMethod _apiMethod = IApiMethod();

  /// Create a new story
  Future<ResponseData<Story>> createStory({
    required String type,
    required List<Map<String, dynamic>> files,
    String? caption,
  }) async {
    try {
      AppUtils.log('Creating story - Type: $type, Files: ${files.length}');

      final response = await _apiMethod.post(
        url: Urls.createStory,
        authToken: _authToken,
        body: {'type': type, 'files': files, 'caption': caption ?? ''},
        headers: {},
      );

      if (response.data != null && response.data?['status'] == true) {
        final storyData = response.data?['data'];
        AppUtils.log('Story created successfully: ${storyData['_id']}');

        return ResponseData<Story>(
          isSuccess: true,
          data: Story.fromJson(storyData),
        );
      } else {
        final errorMessage =
            response.data?['message'] ?? 'Failed to create story';
        AppUtils.log('Create story error: $errorMessage');
        return ResponseData<Story>(
          isSuccess: false,
          error: Exception(errorMessage),
        );
      }
    } catch (e) {
      AppUtils.log('Create story exception: $e');
      return ResponseData<Story>(
        isSuccess: false,
        error: Exception('Network error: ${e.toString()}'),
      );
    }
  }

  /// Get all stories (grouped by user)
  Future<ResponseData<Map<String, dynamic>>> getAllStories({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      AppUtils.log('📡 Repository.getAllStories - Page: $page, Limit: $limit');

      final response = await _apiMethod.get(
        url: Urls.getAllStories,
        authToken: _authToken,
        query: {'page': page.toString(), 'limit': limit.toString()},
      );

      print('📡 API Response received - Raw response: ${response.data}');
      print(
        '📡 API Response - status: ${response.data?["status"]}, code: ${response.data?["code"]}',
      );
      AppUtils.log(
        '📡 Response status: ${response.data?["status"]}, code: ${response.data?["code"]}',
      );

      if (response.data != null && response.data?['status'] == true) {
        final data = response.data?['data'];
        final storiesData = data['stories'] as List;
        final paginationData = data['pagination'];

        AppUtils.log('📦 Raw stories data count: ${storiesData.length}');

        List<UserStoryGroup> storyGroups = [];
        for (var i = 0; i < storiesData.length; i++) {
          try {
            final group = UserStoryGroup.fromJson(storiesData[i]);
            storyGroups.add(group);
          } catch (e) {
            AppUtils.log('❌ Error parsing story group $i: $e');
          }
        }

        StoryPagination pagination = StoryPagination.fromJson(paginationData);

        AppUtils.log(
          '✅ Successfully parsed ${storyGroups.length} story groups',
        );

        return ResponseData<Map<String, dynamic>>(
          isSuccess: true,
          data: {'stories': storyGroups, 'pagination': pagination},
        );
      } else {
        final errorMessage =
            response.data?['message'] ?? 'Failed to fetch stories';
        AppUtils.log('Get all stories error: $errorMessage');
        return ResponseData<Map<String, dynamic>>(
          isSuccess: false,
          error: Exception(errorMessage),
        );
      }
    } catch (e, stackTrace) {
      print('❌❌❌ REPOSITORY EXCEPTION: $e');
      print('❌ Stack: $stackTrace');
      AppUtils.log('❌ Get all stories exception: $e');
      AppUtils.log('❌ Stack: $stackTrace');
      return ResponseData<Map<String, dynamic>>(
        isSuccess: false,
        error: Exception('Network error: ${e.toString()}'),
      );
    }
  }

  /// Get stories for a specific user
  Future<ResponseData<List<Story>>> getUserStories(String userId) async {
    try {
      AppUtils.log('Fetching stories for user: $userId');

      final response = await _apiMethod.get(
        url: Urls.getUserStories(userId),
        authToken: _authToken,
      );

      if (response.data != null && response.data?['status'] == true) {
        final storiesData = response.data?['data']['stories'] as List;
        List<Story> stories = storiesData
            .map((story) => Story.fromJson(story))
            .toList();

        AppUtils.log('Fetched ${stories.length} stories for user: $userId');

        return ResponseData<List<Story>>(isSuccess: true, data: stories);
      } else {
        final errorMessage =
            response.data?['message'] ?? 'Failed to fetch user stories';
        AppUtils.log('Get user stories error: $errorMessage');
        return ResponseData<List<Story>>(
          isSuccess: false,
          error: Exception(errorMessage),
        );
      }
    } catch (e) {
      AppUtils.log('Get user stories exception: $e');
      return ResponseData<List<Story>>(
        isSuccess: false,
        error: Exception('Network error: ${e.toString()}'),
      );
    }
  }

  /// Get story details by ID
  Future<ResponseData<Story>> getStoryDetails(String storyId) async {
    try {
      AppUtils.log('Fetching story details: $storyId');

      final response = await _apiMethod.get(
        url: Urls.getStoryDetails(storyId),
        authToken: _authToken,
      );

      if (response.data != null && response.data?['status'] == true) {
        final storyData = response.data?['data'];
        Story story = Story.fromJson(storyData);

        AppUtils.log('Fetched story details: ${story.id}');

        return ResponseData<Story>(isSuccess: true, data: story);
      } else {
        final errorMessage =
            response.data?['message'] ?? 'Failed to fetch story details';
        AppUtils.log('Get story details error: $errorMessage');
        return ResponseData<Story>(
          isSuccess: false,
          error: Exception(errorMessage),
        );
      }
    } catch (e) {
      AppUtils.log('Get story details exception: $e');
      return ResponseData<Story>(
        isSuccess: false,
        error: Exception('Network error: ${e.toString()}'),
      );
    }
  }

  /// Mark a story as viewed
  Future<ResponseData<Map<String, dynamic>>> viewStory(String storyId) async {
    try {
      AppUtils.log('Marking story as viewed: $storyId');

      final response = await _apiMethod.post(
        url: Urls.viewStory(storyId),
        authToken: _authToken,
        body: {},
        headers: {},
      );

      if (response.data != null && response.data?['status'] == true) {
        final data = response.data?['data'];
        AppUtils.log('Story viewed - View count: ${data['viewCount']}');

        return ResponseData<Map<String, dynamic>>(
          isSuccess: true,
          data: {
            'storyId': data['storyId'],
            'viewCount': data['viewCount'],
            'hasViewed': data['hasViewed'],
          },
        );
      } else {
        final errorMessage =
            response.data?['message'] ?? 'Failed to view story';
        AppUtils.log('View story error: $errorMessage');
        return ResponseData<Map<String, dynamic>>(
          isSuccess: false,
          error: Exception(errorMessage),
        );
      }
    } catch (e) {
      AppUtils.log('View story exception: $e');
      return ResponseData<Map<String, dynamic>>(
        isSuccess: false,
        error: Exception('Network error: ${e.toString()}'),
      );
    }
  }

  /// Like or unlike a story (toggle)
  Future<ResponseData<Map<String, dynamic>>> likeStory(String storyId) async {
    try {
      AppUtils.log('Toggling like for story: $storyId');

      final response = await _apiMethod.post(
        url: Urls.likeStory(storyId),
        authToken: _authToken,
        body: {},
        headers: {},
      );

      if (response.data != null && response.data?['status'] == true) {
        final data = response.data?['data'];
        AppUtils.log(
          'Story like toggled - isLiked: ${data['isLiked']}, likeCount: ${data['likeCount']}',
        );

        return ResponseData<Map<String, dynamic>>(
          isSuccess: true,
          data: {
            'storyId': data['storyId'],
            'isLiked': data['isLiked'],
            'likeCount': data['likeCount'],
          },
        );
      } else {
        final errorMessage =
            response.data?['message'] ?? 'Failed to like story';
        AppUtils.log('Like story error: $errorMessage');
        return ResponseData<Map<String, dynamic>>(
          isSuccess: false,
          error: Exception(errorMessage),
        );
      }
    } catch (e) {
      AppUtils.log('Like story exception: $e');
      return ResponseData<Map<String, dynamic>>(
        isSuccess: false,
        error: Exception('Network error: ${e.toString()}'),
      );
    }
  }

  /// Delete a story
  Future<ResponseData<bool>> deleteStory(String storyId) async {
    try {
      AppUtils.log('Deleting story: $storyId');

      final response = await _apiMethod.delete(
        url: Urls.deleteStory(storyId),
        authToken: _authToken,
      );

      if (response.data != null && response.data?['status'] == true) {
        AppUtils.log('Story deleted successfully: $storyId');

        return ResponseData<bool>(isSuccess: true, data: true);
      } else {
        final errorMessage =
            response.data?['message'] ?? 'Failed to delete story';
        AppUtils.log('Delete story error: $errorMessage');
        return ResponseData<bool>(
          isSuccess: false,
          error: Exception(errorMessage),
        );
      }
    } catch (e) {
      AppUtils.log('Delete story exception: $e');
      return ResponseData<bool>(
        isSuccess: false,
        error: Exception('Network error: ${e.toString()}'),
      );
    }
  }

  /// Get current user's stories
  Future<ResponseData<List<Story>>> getMyStories() async {
    try {
      AppUtils.log('Fetching my stories');

      final response = await _apiMethod.get(
        url: Urls.getMyStories,
        authToken: _authToken,
      );

      if (response.data != null && response.data?['status'] == true) {
        final storiesData = response.data?['data']['stories'] as List;
        List<Story> stories = storiesData
            .map((story) => Story.fromJson(story))
            .toList();

        AppUtils.log('Fetched ${stories.length} of my stories');

        return ResponseData<List<Story>>(isSuccess: true, data: stories);
      } else {
        final errorMessage =
            response.data?['message'] ?? 'Failed to fetch my stories';
        AppUtils.log('Get my stories error: $errorMessage');
        return ResponseData<List<Story>>(
          isSuccess: false,
          error: Exception(errorMessage),
        );
      }
    } catch (e) {
      AppUtils.log('Get my stories exception: $e');
      return ResponseData<List<Story>>(
        isSuccess: false,
        error: Exception('Network error: ${e.toString()}'),
      );
    }
  }
}
