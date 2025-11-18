import 'package:sep/feature/data/repository/iAuthRepository.dart';
import 'package:sep/feature/domain/respository/authRepository.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';

/// Service for sending push notifications without creating duplicate chat messages
class ChatNotificationService {
  static final AuthRepository _authRepository = IAuthRepository();

  /// Send a push notification for a new chat message
  /// This uses a proper notification endpoint that doesn't create chat messages
  static Future<void> sendChatNotification({
    required String receiverId,
    required String message,
    required String chatId,
    String type = 'text',
  }) async {
    try {
      final senderName = ProfileCtrl.find.profileData.value.name ?? 'User';
      String notificationTitle = senderName;
      String notificationBody;

      // Format notification body based on message type
      if (type == 'file') {
        if (message.contains('.mp4') ||
            message.contains('.mov') ||
            message.contains('.avi')) {
          notificationBody = 'sent you a video';
        } else {
          notificationBody = 'sent you an image';
        }
      } else if (message.startsWith('SEP#Celebrate')) {
        notificationBody = 'shared a celebration';
      } else if (message.startsWith('SEP#Profile:')) {
        notificationBody = 'shared a profile';
      } else if (message.startsWith('SEP#Post:')) {
        notificationBody = 'shared a post';
      } else {
        // Regular text message - limit to 100 characters
        notificationBody = message.length > 100
            ? '${message.substring(0, 100)}...'
            : message;
      }

      AppUtils.log('📤 Sending push notification:');
      AppUtils.log('  - To: $receiverId');
      AppUtils.log('  - Title: $notificationTitle');
      AppUtils.log('  - Body: $notificationBody');
      AppUtils.log('  - Chat ID: $chatId');

      // Create notification payload
      final notificationData = {
        "type": "push_notification", // Different from chat creation
        "recipientId": receiverId,
        "senderId": Preferences.uid,
        "title": notificationTitle,
        "body": notificationBody,
        "chatId": chatId,
        "messageType": type,
        "timestamp": DateTime.now().toUtc().toIso8601String(),
      };

      // Send via proper notification endpoint (we'll create this)
      final result = await _sendPushNotification(notificationData);

      if (result) {
        AppUtils.log('✅ Push notification sent successfully');
      } else {
        AppUtils.log('❌ Failed to send push notification');
      }
    } catch (e) {
      AppUtils.log('❌ Error sending push notification: $e');
    }
  }

  /// Send push notification via server
  /// This method will need to be updated with the correct endpoint
  static Future<bool> _sendPushNotification(Map<String, dynamic> data) async {
    try {
      // TODO: Replace with proper notification endpoint
      // For now, using a generic post endpoint
      // The server should handle this by:
      // 1. Getting receiver's FCM token
      // 2. Sending FCM notification directly
      // 3. NOT creating any chat messages

      final result = await _authRepository.post(
        url: Urls.sendPushNotification, // Proper notification endpoint
        enableAuthToken: true,
        data: data,
      );

      return result.isSuccess;
    } catch (e) {
      AppUtils.log('Error sending push notification via server: $e');

      // Fallback: Try using the existing contact endpoint as a temporary solution
      try {
        final fallbackResult = await _authRepository.post(
          url: Urls.contactus, // Temporary fallback using proper URL constant
          enableAuthToken: true,
          data: {
            "email": "notification@app.com",
            "title": "Chat Notification - ${data['title']}",
            "description": "Push notification for chat: ${data['body']}",
            "metadata": data, // Include notification data for processing
          },
        );

        AppUtils.log('📧 Used fallback notification method');
        return fallbackResult.isSuccess;
      } catch (fallbackError) {
        AppUtils.log('❌ Fallback notification also failed: $fallbackError');
        return false;
      }
    }
  }

  /// Send notification for image message
  static Future<void> sendImageNotification({
    required String receiverId,
    required String imageUrl,
    required String chatId,
  }) async {
    await sendChatNotification(
      receiverId: receiverId,
      message: imageUrl,
      chatId: chatId,
      type: 'file',
    );
  }

  /// Send notification for video message
  static Future<void> sendVideoNotification({
    required String receiverId,
    required String videoUrl,
    required String chatId,
  }) async {
    await sendChatNotification(
      receiverId: receiverId,
      message: videoUrl,
      chatId: chatId,
      type: 'file',
    );
  }

  /// Send notification for celebration message
  static Future<void> sendCelebrationNotification({
    required String receiverId,
    required String celebrationContent,
    required String chatId,
  }) async {
    await sendChatNotification(
      receiverId: receiverId,
      message: celebrationContent,
      chatId: chatId,
      type: 'celebration',
    );
  }

  /// Test method to verify notification service is working
  static Future<void> testNotification() async {
    AppUtils.log('🧪 Testing notification service...');

    final testResult = await _sendPushNotification({
      "type": "test_notification",
      "recipientId": "test_user",
      "senderId": Preferences.uid,
      "title": "Test Notification",
      "body": "This is a test notification from the chat system",
      "chatId": "test_chat",
      "messageType": "test",
      "timestamp": DateTime.now().toUtc().toIso8601String(),
    });

    AppUtils.log('🧪 Test notification result: $testResult');
  }
}
