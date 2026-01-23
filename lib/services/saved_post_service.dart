import 'package:sep/services/networking/apiMethods.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';

class SavedPostService {
  static final IApiMethod _apiMethod = IApiMethod();

  /// Save a post
  static Future<Map<String, dynamic>> savePost({
    required String postId,
  }) async {
    try {
      final token = Preferences.authToken;
      final response = await _apiMethod.post(
        url: Urls.savedPost,
        authToken: token,
        body: {
          'postId': postId,
        },
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.data != null && response.data!['status'] == true) {
        AppUtils.toast('Post saved successfully');
        return response.data!;
      } else {
        final errorMessage = response.data?['message'] ?? response.getError ?? 'Failed to save post';
        if (errorMessage.contains('already saved')) {
          AppUtils.toast('This post is already saved');
        } else {
          AppUtils.toastError(errorMessage);
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppUtils.log('Error saving post: $e');
      if (!e.toString().contains('already saved')) {
        AppUtils.toastError('Failed to save post');
      }
      rethrow;
    }
  }

  /// Get saved posts with pagination
  static Future<Map<String, dynamic>> getSavedPosts({
    int page = 1,
  }) async {
    try {
      final token = Preferences.authToken;
      final response = await _apiMethod.get(
        url: Urls.getSavedPosts,
        authToken: token,
        query: {'page': page.toString()},
      );

      if (response.data != null && response.data!['status'] == true) {
        return response.data!;
      } else {
        final errorMessage = response.data?['message'] ?? response.getError ?? 'Failed to get saved posts';
        AppUtils.toastError(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppUtils.log('Error getting saved posts: $e');
      AppUtils.toastError('Failed to load saved posts');
      rethrow;
    }
  }

  /// Unsave a post
  static Future<Map<String, dynamic>> unsavePost({
    required String postId,
  }) async {
    try {
      final token = Preferences.authToken;
      final response = await _apiMethod.delete(
        url: Urls.unsavePost(postId),
        authToken: token,
      );

      if (response.data != null && response.data!['status'] == true) {
        AppUtils.toast('Post unsaved successfully');
        return response.data!;
      } else {
        final errorMessage = response.data?['message'] ?? response.getError ?? 'Failed to unsave post';
        AppUtils.toastError(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppUtils.log('Error unsaving post: $e');
      AppUtils.toastError('Failed to unsave post');
      rethrow;
    }
  }

  /// Check if a post is saved
  static Future<bool> checkIfPostIsSaved({
    required String postId,
  }) async {
    try {
      final token = Preferences.authToken;
      final response = await _apiMethod.get(
        url: Urls.checkIfPostIsSaved(postId),
        authToken: token,
      );

      if (response.data != null && response.data!['status'] == true) {
        return response.data!['data']['isSaved'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      AppUtils.log('Error checking if post is saved: $e');
      return false;
    }
  }
}
