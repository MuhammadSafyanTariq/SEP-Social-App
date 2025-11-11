import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:sep/feature/data/models/dataModels/chat_msg_model/chat_msg_model.dart';
import 'package:sep/feature/data/models/dataModels/recent_chat_model/recent_chat_model.dart';
import 'package:sep/feature/data/repository/i_chat_repo.dart';
import 'package:sep/feature/domain/respository/chat_repo.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/services/socket/socket_helper.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/services/chat_notification_service.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/extensions.dart';

import '../../../services/networking/urls.dart';
import '../../data/models/dataModels/profile_data/profile_data_model.dart';
import '../../data/repository/iAuthRepository.dart';
import '../../domain/respository/authRepository.dart';

class ChatCtrl extends GetxController {
  final ChatRepo _repo = IChatRepo(SocketHelper(connectUrl: baseUrl));
  final AuthRepository _authRepository = IAuthRepository();

  static ChatCtrl get find {
    try {
      return Get.find<ChatCtrl>();
    } catch (e) {
      return Get.put(ChatCtrl());
    }
  }

  String? singleChatId;
  String? receiverId; // Store receiver ID for notifications

  // Prevent duplicate message sending
  String? _lastSentMessage;
  int _lastSentTime = 0;

  // Prevent duplicate message processing
  final Set<String> _processedMessageIds = <String>{};
  int _lastMessageCleanupTime = 0;

  List<ProfileDataModel> get friendList => ProfileCtrl.find.myFollowingList;

  RxList<ChatMsgModel> chatMessages = RxList([]);
  RxList<RecentChatModel> recentChat = RxList([]);

  void getFriendsList() => ProfileCtrl.find.getMyFollowings();

  void connectSocket() {
    _repo.connect(() {
      watchRecentChat();
    });
    getFriendsList();
  }

  void deleteMessage(ChatMsgModel message, {required String type}) {
    final messageId = message.id ?? '';
    // final chatId = singleChatId;

    // AppUtils.log('Deleting message with ID: $messageId, Chat ID: $chatId, Type: $type');

    _repo.deleteMessage(
      messageId: messageId,
      chatId: singleChatId!,
      type: type,
    );

    // if (type == 'one') {
    //   chatMessages.remove(message);
    //   chatMessages.refresh();
    // } else {
    //   chatMessages.clear();
    // }
  }

  void joinSingleChat(String? id, String? chatId) {
    AppUtils.log('🚀 joinSingleChat called with id: $id, chatId: $chatId');

    // Clean up existing listeners to prevent duplicates
    _repo.closeListener(SocketKey.sendMessage);
    _repo.closeListener(SocketKey.getMessages);
    _repo.closeListener(SocketKey.deleteMessages);
    _repo.closeListener(SocketKey.joinRoom);

    // Clear existing messages to prevent mixing old and new data
    chatMessages.clear();

    // Store receiver ID for notifications
    receiverId = id;

    if (chatId == null) {
      _repo.joinRoomListener(
        data: (data) {
          AppUtils.log('📥 Join room response: $data');
          _repo.closeListener(SocketKey.joinRoom);
          final id = data['_id'];
          if (id != null) {
            singleChatId = id;
            watchSingleChatData(isRefresh: true);
          }
        },
      );
    } else {
      singleChatId = chatId;
      watchSingleChatData(isRefresh: true);
    }

    // Set up message listeners after cleanup
    getMessage();
    deleteMsgListener();

    _repo.join(
      chatId != null
          ? {'room': chatId}
          : {"userId": Preferences.uid, "otherUserId": id},
    );
  }

  void fireRecentChatEvent() => _repo.fireRecentChatEvent();

  void watchRecentChat() {
    _repo.getRecentChatList(
      data: (data) {
        AppUtils.logg('getRecentChatList');
        AppUtils.logg(data);
        recentChat.assignAll(
          List<RecentChatModel>.from(
            data.map((json) => RecentChatModel.fromJson(json)),
          ),
        );
      },
    );
  }

  void onLeaveChatRoom() {
    AppUtils.log('🚫 Leaving chat room and cleaning up');

    // Close all listeners to prevent memory leaks and duplicate listeners
    _repo.closeListener(SocketKey.sendMessage);
    _repo.closeListener(SocketKey.getMessages);
    _repo.closeListener(SocketKey.deleteMessages);
    _repo.closeListener(SocketKey.joinRoom);

    // Clear all chat data
    chatMessages.clear();
    singleChatId = null;
    singleChatPage = 1;
    receiverId = null;

    // Clear duplicate prevention state
    _lastSentMessage = null;
    _lastSentTime = 0;
    _processedMessageIds.clear();
    _lastMessageCleanupTime = 0;

    AppUtils.log('✅ Chat room cleanup completed');
  }

  int singleChatPage = 1;
  int _tempSingleChatPage = 1;

  RxBool isSingleChatLoading = RxBool(false);

  Future watchSingleChatData({
    bool isRefresh = false,
    bool isLoadMore = false,
  }) async {
    AppUtils.log(
      '📊 watchSingleChatData called - isRefresh: $isRefresh, isLoadMore: $isLoadMore',
    );

    isSingleChatLoading.value = true;
    _tempSingleChatPage = singleChatPage;
    if (isRefresh) _tempSingleChatPage = 1;
    if (isLoadMore) _tempSingleChatPage++;

    // Small delay to ensure socket listeners are properly set up
    if (isRefresh) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    final result = await getSingleChat();

    AppUtils.log("📊 Chat data loading completed: $result");
  }

  Future getSingleChat() async {
    AppUtils.log('📞 Loading chat data for page $_tempSingleChatPage');
    _repo.getSingleChatList(
      chatId: singleChatId!,
      page: _tempSingleChatPage,
      data: (data) {
        AppUtils.log(
          '📥 Received chat data: ${data.length} messages for page $_tempSingleChatPage',
        );
        final list = List<ChatMsgModel>.from(
          data.map((json) => ChatMsgModel.fromJson(json)),
        );

        if (list.isNotEmpty) {
          singleChatPage = _tempSingleChatPage;
        }

        if (_tempSingleChatPage == 1) {
          // For page 1, replace all messages (fresh load)
          AppUtils.log(
            '🔄 Fresh load: replacing all messages with ${list.length} new messages',
          );

          // Filter out messages that were already processed via socket
          final filteredList = list
              .where(
                (msg) =>
                    msg.id == null || !_processedMessageIds.contains(msg.id),
              )
              .toList();

          AppUtils.log(
            '🔍 Filtered ${list.length - filteredList.length} already processed messages',
          );

          chatMessages.assignAll(filteredList);

          // Mark all these messages as processed
          for (final msg in filteredList) {
            if (msg.id != null) {
              _processedMessageIds.add(msg.id!);
            }
          }

          // Sort messages by time after initial load
          _sortMessagesByTime();
        } else {
          // For subsequent pages, only add new messages
          List<ChatMsgModel> newList = [];
          for (var newItem in list) {
            bool exists = chatMessages.any((item) => item.id == newItem.id);
            bool alreadyProcessed =
                newItem.id != null && _processedMessageIds.contains(newItem.id);

            if (!exists && !alreadyProcessed) {
              newList.add(newItem);
              if (newItem.id != null) {
                _processedMessageIds.add(newItem.id!);
              }
            }
          }
          AppUtils.log(
            '📎 Adding ${newList.length} new messages from ${list.length} total (${list.length - newList.length} duplicates filtered)',
          );
          chatMessages.addAll(newList);
          // Sort messages by time after adding more messages
          _sortMessagesByTime();
        }

        chatMessages.refresh();
        isSingleChatLoading.value = false;

        AppUtils.log(
          '✅ Chat data loaded. Total messages: ${chatMessages.length}',
        );
      },
    );
  }

  /// Sort messages by senderTime in descending order (newest first)
  /// Since ListView has reverse: true, newest messages will appear at bottom (correct chat behavior)
  void _sortMessagesByTime() {
    chatMessages.sort((a, b) {
      // Parse senderTime for comparison
      DateTime? timeA = DateTime.tryParse(a.senderTime ?? '');
      DateTime? timeB = DateTime.tryParse(b.senderTime ?? '');

      // If parsing fails, use createdAt as fallback
      timeA ??= DateTime.tryParse(a.createdAt ?? '');
      timeB ??= DateTime.tryParse(b.createdAt ?? '');

      // If both times are null, maintain current order
      if (timeA == null && timeB == null) return 0;
      if (timeA == null) return 1; // a goes after b
      if (timeB == null) return -1; // a goes before b

      // Sort in descending order (newest first) - ListView reverse will make newest appear at bottom
      return timeB.compareTo(timeA);
    });

    AppUtils.log(
      '🕒 Messages sorted by time (newest first for reverse ListView). Total: ${chatMessages.length}',
    );
  }

  void sendTextMsg(String msg) => sendMessage(type: 'text', msg: msg);

  void sendMessage({required String msg, required String type}) {
    final callId = DateTime.now().millisecondsSinceEpoch;
    AppUtils.log(
      '🎯 sendMessage called [$callId] with type: $type, msg length: ${msg.length}',
    );
    AppUtils.log('🔍 Current singleChatId: $singleChatId');
    AppUtils.log(
      '📱 Stack trace: ${StackTrace.current.toString().split('\n').take(3).join('\n')}',
    );

    // Prevent duplicate sends within 2 seconds
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_lastSentMessage == msg && (now - _lastSentTime) < 2000) {
      AppUtils.log(
        '🚫 Duplicate message detected within 2 seconds, ignoring [$callId]',
      );
      return;
    }

    _lastSentMessage = msg;
    _lastSentTime = now;

    if (singleChatId != null) {
      final currentTime = DateTime.now().toUtc().toIso8601String();

      final data = {
        "chatId": singleChatId,
        "senderId": Preferences.uid,
        "content": msg,
        "mediaType": type,
        "senderTime": currentTime,
      };

      AppUtils.log('🚀 SENDING MESSAGE [$callId]:');
      AppUtils.log('📤 Data being sent to server: $data');
      AppUtils.log('👤 Current user ID in preferences: ${Preferences.uid}');
      AppUtils.log(
        '👤 Current profile name: ${ProfileCtrl.find.profileData.value.name}',
      );

      // Add message optimistically to UI first (for immediate feedback)
      final optimisticMessage = ChatMsgModel(
        id: 'temp_${callId}_${DateTime.now().millisecondsSinceEpoch}', // Temporary ID
        content: msg,
        mediaType: type,
        senderTime: currentTime,
        createdAt: currentTime,
        chat: singleChatId,
        sender: Sender(
          id: Preferences.uid,
          name: ProfileCtrl.find.profileData.value.name,
        ),
      );

      AppUtils.log('🚀 Adding optimistic message to UI [$callId]');
      chatMessages.add(optimisticMessage);
      _sortMessagesByTime();
      chatMessages.refresh();

      // Send to server
      _repo.sendMessage(data);
      AppUtils.log('✅ Message sent to server [$callId]');

      // ✅ NOTIFICATIONS RE-ENABLED with proper service
      // Using new ChatNotificationService to avoid duplicate message creation
      if (receiverId != null && !msg.startsWith('SEP#Celebrate')) {
        AppUtils.log('� Sending push notification via new service');
        ChatNotificationService.sendChatNotification(
          receiverId: receiverId!,
          message: msg,
          chatId: singleChatId!,
          type: type,
        ).catchError((error) {
          AppUtils.log('⚠️ Notification error (message still sent): $error');
        });
      } else if (msg.startsWith('SEP#Celebrate')) {
        AppUtils.log('🎉 Celebration message sent');
        if (receiverId != null) {
          ChatNotificationService.sendCelebrationNotification(
            receiverId: receiverId!,
            celebrationContent: msg,
            chatId: singleChatId!,
          ).catchError((error) {
            AppUtils.log('⚠️ Celebration notification error: $error');
          });
        } else {
          AppUtils.log(
            '⚠️ No receiver ID available for celebration notification',
          );
        }
      } else {
        AppUtils.log('⚠️ No receiver ID available for notification');
      }

      AppUtils.log('⏳ Message send completed [$callId]');
    } else {
      AppUtils.log('❌ Cannot send message [$callId]: singleChatId is null');
    }
  }

  // OLD notification method removed - now using ChatNotificationService
  // The old method was using the wrong endpoint (inviteFriendToLiveStream)
  // which was causing duplicate chat messages on the server side

  Future<void> sendImageMessage(XFile file) async {
    try {
      final result = await _authRepository.uploadPhoto(
        imageFile: File(file.path),
      );
      final imageUrl = result.data?.first.fileUrl;

      if (imageUrl != null && imageUrl.isNotEmpty) {
        final currentTime = DateTime.now().toUtc().toIso8601String();
        final callId = DateTime.now().millisecondsSinceEpoch;

        // Add optimistic image message to UI
        final optimisticMessage = ChatMsgModel(
          id: 'temp_img_${callId}_${DateTime.now().millisecondsSinceEpoch}',
          content: imageUrl,
          mediaType: "file",
          senderTime: currentTime,
          createdAt: currentTime,
          chat: singleChatId,
          sender: Sender(
            id: Preferences.uid,
            name: ProfileCtrl.find.profileData.value.name,
          ),
        );

        AppUtils.log('🖼️ Adding optimistic image message to UI');
        chatMessages.add(optimisticMessage);
        _sortMessagesByTime();
        chatMessages.refresh();

        final serverPayload = {
          "chatId": singleChatId,
          "senderId": Preferences.uid,
          "content": imageUrl,
          "mediaType": "file",
          "senderTime": currentTime,
        };
        _repo.sendMessage(serverPayload);

        // ✅ RE-ENABLED: Image notifications with proper service
        AppUtils.log('� Sending image notification via new service');
        if (receiverId != null) {
          ChatNotificationService.sendImageNotification(
            receiverId: receiverId!,
            imageUrl: imageUrl,
            chatId: singleChatId!,
          ).catchError((error) {
            AppUtils.log(
              '⚠️ Image notification error (image still sent): $error',
            );
          });
        } else {
          AppUtils.log('⚠️ No receiver ID available for image notification');
        }
      }
    } catch (e) {
      AppUtils.toast('Failed to send image');
    }
  }

  Future<void> sendVideoMessage(XFile file) async {
    try {
      final result = await _authRepository.uploadPhoto(
        imageFile: File(file.path),
      );
      final videoUrl = result.data?.first.fileUrl;

      if (videoUrl != null && videoUrl.isNotEmpty) {
        final currentTime = DateTime.now().toUtc().toIso8601String();
        final callId = DateTime.now().millisecondsSinceEpoch;

        // Add optimistic video message to UI
        final optimisticMessage = ChatMsgModel(
          id: 'temp_video_${callId}_${DateTime.now().millisecondsSinceEpoch}',
          content: videoUrl,
          mediaType: "file",
          senderTime: currentTime,
          createdAt: currentTime,
          chat: singleChatId,
          sender: Sender(
            id: Preferences.uid,
            name: ProfileCtrl.find.profileData.value.name,
          ),
        );

        AppUtils.log('🎥 Adding optimistic video message to UI');
        chatMessages.add(optimisticMessage);
        _sortMessagesByTime();
        chatMessages.refresh();

        final serverPayload = {
          "chatId": singleChatId,
          "senderId": Preferences.uid,
          "content": videoUrl,
          "mediaType": "file",
          "senderTime": currentTime,
        };

        _repo.sendMessage(serverPayload);

        // ✅ RE-ENABLED: Video notifications with proper service
        AppUtils.log('� Sending video notification via new service');
        if (receiverId != null) {
          ChatNotificationService.sendVideoNotification(
            receiverId: receiverId!,
            videoUrl: videoUrl,
            chatId: singleChatId!,
          ).catchError((error) {
            AppUtils.log(
              '⚠️ Video notification error (video still sent): $error',
            );
          });
        } else {
          AppUtils.log('⚠️ No receiver ID available for video notification');
        }
      }
    } catch (e) {
      AppUtils.toast('Failed to send video');
    }
  }

  void getMessage() {
    AppUtils.log('🎯 Setting up getMessage listener');
    _repo.getMessage(
      data: (data) {
        AppUtils.log('📥 RECEIVED MESSAGE FROM SERVER:');
        AppUtils.log('🔍 Raw server data: $data');

        final message = ChatMsgModel.fromJson(data);

        AppUtils.log('📝 Parsed message details:');
        AppUtils.log('  - Message ID: ${message.id}');
        AppUtils.log('  - Content: ${message.content}');
        AppUtils.log('  - Media Type: ${message.mediaType}');
        AppUtils.log('  - Sender ID: ${message.sender?.id}');
        AppUtils.log('  - Sender Name: ${message.sender?.name}');
        AppUtils.log('  - Sender Time: ${message.senderTime}');
        AppUtils.log('  - Chat ID: ${message.chat}');

        // Verify this message belongs to current chat
        if (message.chat != singleChatId) {
          AppUtils.log(
            '⚠️ Message for different chat (${message.chat} vs $singleChatId), ignoring',
          );
          return;
        }

        // Check if we've already processed this message ID
        if (message.id != null && _processedMessageIds.contains(message.id)) {
          AppUtils.log('⚠️ Message already processed: ${message.id}');
          return;
        }

        // Clean up old processed message IDs every 5 minutes
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - _lastMessageCleanupTime > 300000) {
          // 5 minutes
          _processedMessageIds.clear();
          _lastMessageCleanupTime = now;
          AppUtils.log('🧹 Cleaned up processed message IDs cache');
        }

        AppUtils.log('👤 Current user comparison:');
        AppUtils.log('  - Preferences.uid: ${Preferences.uid}');
        AppUtils.log(
          '  - Profile ID: ${ProfileCtrl.find.profileData.value.id}',
        );
        AppUtils.log(
          '  - Profile Name: ${ProfileCtrl.find.profileData.value.name}',
        );

        // Check if this message was sent by the current user
        final isFromCurrentUser = message.sender?.id == Preferences.uid;
        AppUtils.log('✅ Is message from current user: $isFromCurrentUser');

        // Enhanced duplicate check with detailed logging
        bool messageExists = false;
        String duplicateReason = '';

        for (var existingMsg in chatMessages) {
          // Check by ID first (most reliable)
          if (existingMsg.id != null &&
              message.id != null &&
              existingMsg.id == message.id) {
            messageExists = true;
            duplicateReason = 'Same ID: ${message.id}';
            break;
          }

          // Check by content, sender, and approximate time (within 3 seconds)
          if (existingMsg.content == message.content &&
              existingMsg.sender?.id == message.sender?.id) {
            // Parse times for comparison
            final existingTime = DateTime.tryParse(
              existingMsg.senderTime ?? existingMsg.createdAt ?? '',
            );
            final newTime = DateTime.tryParse(
              message.senderTime ?? message.createdAt ?? '',
            );

            if (existingTime != null && newTime != null) {
              final timeDiff =
                  (existingTime.millisecondsSinceEpoch -
                          newTime.millisecondsSinceEpoch)
                      .abs();
              if (timeDiff < 3000) {
                // Within 3 seconds (stricter check)
                messageExists = true;
                duplicateReason =
                    'Same content+sender+time (${timeDiff}ms diff)';
                break;
              }
            } else if (existingMsg.senderTime == message.senderTime ||
                existingMsg.createdAt == message.createdAt) {
              messageExists = true;
              duplicateReason = 'Same content+sender+exact time';
              break;
            }
          }

          // Additional check: if message from current user was sent very recently (within 1 second)
          // and has same content, likely a duplicate from sending process
          if (isFromCurrentUser &&
              existingMsg.content == message.content &&
              existingMsg.sender?.id == message.sender?.id) {
            final now = DateTime.now().millisecondsSinceEpoch;
            if (now - _lastSentTime < 1000) {
              // Within 1 second of sending
              messageExists = true;
              duplicateReason =
                  'Recent send duplicate (${now - _lastSentTime}ms after send)';
              break;
            }
          }
        }

        AppUtils.log('🔍 Duplicate check result: $messageExists');
        if (messageExists) {
          AppUtils.log('📝 Duplicate reason: $duplicateReason');
        }

        if (!messageExists) {
          // Check if this is a server confirmation of an optimistic message
          bool replacedOptimistic = false;

          if (isFromCurrentUser) {
            // Look for temporary optimistic messages to replace
            for (int i = 0; i < chatMessages.length; i++) {
              final existingMsg = chatMessages[i];
              if (existingMsg.id?.startsWith('temp_') == true &&
                  existingMsg.content == message.content &&
                  existingMsg.sender?.id == message.sender?.id) {
                // Replace optimistic message with server-confirmed message
                chatMessages[i] = message;
                replacedOptimistic = true;
                AppUtils.log(
                  '🔄 Replaced optimistic message with server response',
                );
                break;
              }
            }
          }

          if (!replacedOptimistic) {
            // Add new message and maintain chronological order
            chatMessages.add(message);
            _sortMessagesByTime();
            AppUtils.log('➕ Added new message to chat list and sorted by time');
          }

          // Mark this message as processed
          if (message.id != null) {
            _processedMessageIds.add(message.id!);
          }

          chatMessages.refresh();
        } else {
          AppUtils.log(
            '⚠️ Message already exists, skipping to prevent duplicate ($duplicateReason)',
          );
        }

        // Log current chat messages count
        AppUtils.log('📊 Total messages in chat: ${chatMessages.length}');
      },
    );
  }

  void deleteMsgListener() {
    _repo.deleteMessageListener(
      data: (data) {
        AppUtils.log('delete msg listener called');
        AppUtils.log(data);
        final deletedMessages = data['deletedMessages'] as List<dynamic>;
        if (deletedMessages.isNotEmpty) {
          final firstMessage = deletedMessages[0];
          AppUtils.log('First deleted message: $firstMessage');

          final messageId = firstMessage['_id'] ?? firstMessage['id'];
          AppUtils.log("Message ID: $messageId");

          if (messageId != null) {
            final matches = chatMessages
                .where((msg) => msg.id == messageId)
                .toList();
            AppUtils.log("Matches: $matches");
          } else {
            AppUtils.log("Message ID is null, cannot match.");
          }
        }
      },
    );
  }

  /// Test the notification system to ensure it's working properly
  Future<void> testNotificationSystem() async {
    if (receiverId == null || singleChatId == null) {
      AppUtils.log('❌ Cannot test notifications: missing receiverId or chatId');
      return;
    }

    AppUtils.log('🧪 Testing notification system...');

    try {
      await ChatNotificationService.sendChatNotification(
        receiverId: receiverId!,
        message: 'Test notification - system working properly!',
        chatId: singleChatId!,
        type: 'text',
      );

      AppUtils.log(
        '✅ Notification test completed - check if recipient received it',
      );
    } catch (e) {
      AppUtils.log('❌ Notification test failed: $e');
    }
  }
}
