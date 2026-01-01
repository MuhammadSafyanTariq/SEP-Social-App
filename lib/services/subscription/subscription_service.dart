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

  /// Check if user has a store
  /// Returns true if user has a store, false otherwise
  Future<bool> hasStore() async {
    try {
      final token = Preferences.authToken;
      if (token == null) return false;

      final response = await _apiMethod.get(
        url: '/api/shop/my-shop',
        authToken: token,
        headers: {},
      );

      if (response.isSuccess && response.data?['data'] != null) {
        final shopData = response.data!['data'];
        final shopId = shopData['_id'] as String?;
        return shopId != null && shopId.isNotEmpty;
      }
      return false;
    } catch (e) {
      AppUtils.log('Error checking store: $e');
      return false;
    }
  }

  /// Check if subscription is expired and within 3-day grace period
  /// Returns true if expired within last 3 days, false otherwise
  Future<bool> isInGracePeriod() async {
    try {
      final data = await getSubscriptionData();
      if (data == null) return false;

      final status = data['subscriptionStatus'];
      final expiresAt = data['subscriptionExpiresAt'];

      // Only show warning if subscription is expired (not active, not none)
      if (status != 'expired' || expiresAt == null) return false;

      // Parse expiration date
      final expirationDate = DateTime.parse(expiresAt);
      final now = DateTime.now();

      // Calculate days since expiration
      final daysSinceExpiration = now.difference(expirationDate).inDays;

      // Show warning if expired within last 3 days (0-3 days)
      return daysSinceExpiration >= 0 && daysSinceExpiration <= 3;
    } catch (e) {
      AppUtils.log('Error checking grace period: $e');
      return false;
    }
  }

  /// Check if should show resubscribe warning
  /// Returns true if user has expired subscription within grace period and has a store
  Future<bool> shouldShowResubscribeWarning() async {
    final hasAStore = await hasStore();
    if (!hasAStore) return false;

    final inGracePeriod = await isInGracePeriod();
    return inGracePeriod;
  }
}
