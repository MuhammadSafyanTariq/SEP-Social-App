import 'package:sep/feature/data/models/dataModels/responseDataModel.dart';
import 'package:sep/services/networking/apiMethods.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';

/// Service for handling seller subscription operations
class SubscriptionService {
  final IApiMethod _apiMethod = IApiMethod();

  /// Subscribe to seller subscription ($9.99/month)
  /// Returns subscription data including expiration date and updated wallet balance
  Future<ResponseData<Map<String, dynamic>>> subscribe() async {
    try {
      final token = Preferences.authToken;
      if (token == null) {
        return ResponseData(
          isSuccess: false,
          error: Exception('Authentication required'),
        );
      }

      final response = await _apiMethod.post(
        url: '/api/subscription/subscribe',
        authToken: token,
        body: {},
        headers: {},
      );

      AppUtils.log('Subscription response: ${response.data}');

      if (response.isSuccess && response.data != null) {
        return ResponseData(
          isSuccess: true,
          data: response.data!['data'] ?? response.data!,
        );
      } else {
        return ResponseData(
          isSuccess: false,
          error: Exception(response.data?['message'] ?? 'Subscription failed'),
        );
      }
    } catch (e) {
      AppUtils.log('Error subscribing: $e');
      return ResponseData(
        isSuccess: false,
        error: Exception('Failed to subscribe: $e'),
      );
    }
  }

  /// Get current subscription status
  /// Returns subscription info including isActive, expiresAt, daysRemaining, etc.
  Future<ResponseData<Map<String, dynamic>>> getSubscriptionStatus() async {
    try {
      final token = Preferences.authToken;
      if (token == null) {
        return ResponseData(
          isSuccess: false,
          error: Exception('Authentication required'),
        );
      }

      final response = await _apiMethod.get(
        url: '/api/subscription/status',
        authToken: token,
        headers: {},
      );

      AppUtils.log('Subscription status response: ${response.data}');

      if (response.isSuccess && response.data != null) {
        return ResponseData(
          isSuccess: true,
          data: response.data!['data'] ?? response.data!,
        );
      } else {
        return ResponseData(
          isSuccess: false,
          error: Exception(
            response.data?['message'] ?? 'Failed to get subscription status',
          ),
        );
      }
    } catch (e) {
      AppUtils.log('Error getting subscription status: $e');
      return ResponseData(
        isSuccess: false,
        error: Exception('Failed to get subscription status: $e'),
      );
    }
  }

  /// Check if user has an active subscription
  /// Returns true if subscription is active, false otherwise
  Future<bool> isSubscriptionActive() async {
    final result = await getSubscriptionStatus();
    if (result.isSuccess && result.data != null) {
      return result.data!['isActive'] == true;
    }
    return false;
  }

  /// Get subscription data including status, expiration, etc.
  /// Returns null if failed to fetch
  Future<Map<String, dynamic>?> getSubscriptionData() async {
    final result = await getSubscriptionStatus();
    if (result.isSuccess) {
      return result.data;
    }
    return null;
  }
}
