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

  // Track deleted chats to filter them out even if backend returns them
  final Set<String> _deletedChatIds = <String>{};

  List<ProfileDataModel> get friendList => ProfileCtrl.find.myFollowingList;

  RxList<ChatMsgModel> chatMessages = RxList([]);
  RxList<RecentChatModel> recentChat = RxList([]);

  void getFriendsList() => ProfileCtrl.find.getMyFollowings();

  void connectSocket() {
    _repo.connect(() {
      watchRecentChat();
      deleteChatListener();
    });
    getFriendsList();
  }

  void deleteChat(String chatId) {
    AppUtils.log('🗑️ Deleting chat: $chatId');

    if (chatId.isEmpty) {
      AppUtils.logEr('❌ Cannot delete chat: chatId is empty');
      return;
    }

    // Add to deleted chats set to filter it out permanently
    _deletedChatIds.add(chatId);
    AppUtils.log(
      '📝 Added $chatId to deleted chats set. Total deleted: ${_deletedChatIds.length}',
    );

    // Remove from local list immediately for better UX
    recentChat.removeWhere((chat) => chat.id == chatId);
    recentChat.refresh();

    // Send delete request to server
    _repo.deleteChat(chatId: chatId);

    AppUtils.toast('Chat deleted');
  }

  /// Mark all messages in a chat as read
  Future<void> markAllMessagesAsRead(String chatId) async {
    if (chatId.isEmpty) {
      AppUtils.logEr('❌ Cannot mark messages as read: chatId is empty');
      return;
    }

    AppUtils.log('✅ Marking all messages as read in chat: $chatId');

    // Update local messages immediately
    for (int i = 0; i < chatMessages.length; i++) {
      final msg = chatMessages[i];
      if (msg.sender?.id != Preferences.uid) {
        // Add current user to readBy list if not already there
        final readBy = List<dynamic>.from(msg.readBy ?? []);
        if (!readBy.contains(Preferences.uid)) {
          readBy.add(Preferences.uid);
          chatMessages[i] = msg.copyWith(readBy: readBy);
        }
      }
    }
    chatMessages.refresh();

    // Update unread count in recent chat list
    final recentChatIndex = recentChat.indexWhere((chat) => chat.id == chatId);
    if (recentChatIndex != -1) {
      final chat = recentChat[recentChatIndex];
      final updatedUnreadCount = Map<String, int>.from(chat.unreadCount ?? {});
      updatedUnreadCount[Preferences.uid ?? ''] = 0;
      recentChat[recentChatIndex] = chat.copyWith(
        unreadCount: updatedUnreadCount,
      );
      recentChat.refresh();
    }

    // Notify server
    _repo.markMessagesAsRead(chatId: chatId);

    AppUtils.toast('Messages marked as read');
  }

  void deleteChatListener() {
    _repo.deleteChatListener(
      data: (data) {
        AppUtils.log('🗑️ Delete chat listener called');
        AppUtils.log('📥 Delete chat response data: $data');
        AppUtils.log('📥 Data type: ${data.runtimeType}');

        try {
          // Handle both Map and other response formats
          final code = data is Map ? (data['code'] ?? data['status']) : null;
          final message = data is Map ? (data['message'] ?? data['msg']) : null;
          final deletedChatId = data is Map
              ? (data['chatId'] ?? data['_id'] ?? data['id'])
              : null;

          AppUtils.log(
            '📊 Response code: $code, message: $message, chatId: $deletedChatId',
          );

          if (code == 200) {
            AppUtils.log('✅ Chat deleted successfully: $deletedChatId');

            // Ensure it's in the deleted set
            if (deletedChatId != null) {
              _deletedChatIds.add(deletedChatId);
            }

            // Remove from local list if not already removed
            recentChat.removeWhere((chat) => chat.id == deletedChatId);
            recentChat.refresh();

            // Refresh the list from server (will be filtered by deleted set)
            fireRecentChatEvent();

            AppUtils.toast(message ?? 'Chat deleted successfully');
          } else {
            AppUtils.logEr('❌ Failed to delete chat: $message');
            AppUtils.toastError(message ?? 'Failed to delete chat');

            // Remove from deleted set if it failed
            if (deletedChatId != null) {
              _deletedChatIds.remove(deletedChatId);
            }

            // Refresh to restore the chat if deletion failed
            fireRecentChatEvent();
          }
        } catch (e, stackTrace) {
          AppUtils.logEr('❌ Error processing delete chat response: $e');
          AppUtils.logEr('Stack trace: $stackTrace');
          // Refresh to ensure UI is in sync
          fireRecentChatEvent();
        }
      },
    );
  }

  /// Delete a single message
  /// [type] should be 'all' for delete for everyone, or 'one' for delete for me only
  void deleteMessage(ChatMsgModel message, {required String type}) {
    final messageId = message.id ?? '';

    if (messageId.isEmpty) {
      AppUtils.logEr('❌ Cannot delete message: message ID is empty');
      return;
    }

    if (singleChatId == null) {
      AppUtils.logEr('❌ Cannot delete message: chatId is null');
      return;
    }

    AppUtils.log('🗑️ Deleting message: $messageId, Type: $type');

    _repo.deleteMessage(
      messageId: messageId,
      chatId: singleChatId!,
      type: type,
    );
  }

  /// Delete multiple messages at once
  /// [messageIds] is a list of message IDs to delete
  /// [type] should be 'all' for delete for everyone, or 'one' for delete for me only
  void deleteMultipleMessages(List<String> messageIds, {required String type}) {
    if (messageIds.isEmpty) {
      AppUtils.logEr('❌ Cannot delete messages: message IDs list is empty');
      return;
    }

    if (singleChatId == null) {
      AppUtils.logEr('❌ Cannot delete messages: chatId is null');
      return;
    }

    AppUtils.log('🗑️ Deleting ${messageIds.length} messages, Type: $type');

    _repo.deleteMultipleMessages(
      messageIds: messageIds,
      chatId: singleChatId!,
      type: type,
    );
  }

  void joinSingleChat(String? id, String? chatId) async {
    AppUtils.log('🚀 joinSingleChat called with id: $id, chatId: $chatId');
    AppUtils.log('🔍 Current user ID: ${Preferences.uid}');

    // If chatId is not provided, check if a chat already exists with this user
    if (chatId == null && id != null) {
      final existingChat = recentChat.firstWhereOrNull((chat) {
        return chat.users?.contains(id) == true &&
            chat.users?.contains(Preferences.uid) == true;
      });

      if (existingChat != null && existingChat.id != null) {
        AppUtils.log('✅ Found existing chat with user $id: ${existingChat.id}');
        chatId = existingChat.id;
      } else {
        AppUtils.log(
          '📝 No existing chat found with user $id, will create new one',
        );
      }
    }

    // Check socket connection first
    if (!_repo.isConnected()) {
      AppUtils.log('⚠️ Socket not connected, attempting to connect...');
      bool connected = false;
      _repo.connect(() {
        connected = true;
        AppUtils.log('✅ Socket connected successfully');
      });

      // Wait for connection (max 5 seconds)
      int attempts = 0;
      while (!connected && attempts < 25) {
        await Future.delayed(const Duration(milliseconds: 200));
        attempts++;
      }

      if (!connected) {
        AppUtils.logEr('❌ Socket connection failed');
        AppUtils.toastError(
          'Connection failed. Please check your internet and try again.',
        );
        return;
      }
    }

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
      // Reset singleChatId to null while waiting for new room
      singleChatId = null;

      AppUtils.log('📡 Setting up join room listener for new chat');

      // Create a completer to handle the join room response with timeout
      bool roomReceived = false;

      _repo.joinRoomListener(
        data: (data) {
          AppUtils.log('📥 Join room response received: $data');
          AppUtils.log('📥 Response type: ${data.runtimeType}');
          _repo.closeListener(SocketKey.joinRoom);

          // Handle different response formats
          String? roomId;
          if (data is Map) {
            roomId = data['_id'] ?? data['chatId'] ?? data['id'];
          } else if (data is String) {
            roomId = data;
          }

          if (roomId != null && roomId.isNotEmpty) {
            AppUtils.log('✅ Chat room ID received: $roomId');
            singleChatId = roomId;
            roomReceived = true;
            watchSingleChatData(isRefresh: true);
          } else {
            AppUtils.logEr('❌ Join room response missing room ID. Data: $data');
            AppUtils.toastError(
              'Failed to create chat room. Please try again.',
            );
            roomReceived = true; // Mark as received even if invalid
          }
        },
      );

      // Set up message listeners before joining
      getMessage();
      deleteMsgListener();

      // Now emit the join event
      AppUtils.log('📤 Emitting join event for new chat');
      _repo.join({"userId": Preferences.uid, "otherUserId": id});

      // Wait for room ID to be set (with timeout)
      int waitAttempts = 0;
      const maxWaitAttempts = 25; // 5 seconds
      while (!roomReceived && waitAttempts < maxWaitAttempts) {
        await Future.delayed(const Duration(milliseconds: 200));
        waitAttempts++;
      }

      if (!roomReceived) {
        AppUtils.logEr(
          '⏱️ Join room request timed out - no response from server',
        );
        AppUtils.toastError('Server not responding. Please try again.');
        _repo.closeListener(SocketKey.joinRoom);
      }
    } else {
      AppUtils.log('✅ Using existing chat ID: $chatId');
      singleChatId = chatId;
      watchSingleChatData(isRefresh: true);

      // Set up message listeners
      getMessage();
      deleteMsgListener();

      // Rejoin existing room
      AppUtils.log('📤 Emitting join event for existing chat');
      _repo.join({'room': chatId});
    }
  }

  void fireRecentChatEvent() => _repo.fireRecentChatEvent();

  void watchRecentChat() {
    _repo.getRecentChatList(
      data: (data) {
        AppUtils.logg('getRecentChatList');
        AppUtils.logg(data);

        // Parse all chats from server
        final allChats = List<RecentChatModel>.from(
          data.map((json) => RecentChatModel.fromJson(json)),
        );

        // Filter out deleted chats
        final filteredChats = allChats.where((chat) {
          final isDeleted = _deletedChatIds.contains(chat.id);
          if (isDeleted) {
            AppUtils.log('🚫 Filtering out deleted chat: ${chat.id}');
          }
          return !isDeleted;
        }).toList();

        AppUtils.log(
          '📊 Total chats from server: ${allChats.length}, After filtering: ${filteredChats.length}, Deleted: ${_deletedChatIds.length}',
        );

        recentChat.assignAll(filteredChats);
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
          // For page 1, replace all messages (fresh load from server)
          AppUtils.log(
            '🔄 Fresh load: replacing all messages with ${list.length} new messages',
          );

          // On fresh load, accept all messages from server (they are authoritative)
          chatMessages.assignAll(list);

          // Clear and rebuild processed IDs set with current messages
          _processedMessageIds.clear();
          for (final msg in list) {
            if (msg.id != null) {
              _processedMessageIds.add(msg.id!);
            }
          }

          AppUtils.log(
            '✅ Loaded ${list.length} messages, tracking ${_processedMessageIds.length} message IDs',
          );

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

  void sendMessage({required String msg, required String type}) async {
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

    // Wait for singleChatId to be set (max 10 seconds with better messaging)
    if (singleChatId == null) {
      AppUtils.log('⏳ Waiting for chat room to be initialized...');
      int attempts = 0;
      const maxAttempts = 50; // 50 * 200ms = 10 seconds

      while (singleChatId == null && attempts < maxAttempts) {
        await Future.delayed(const Duration(milliseconds: 200));
        attempts++;

        if (attempts % 10 == 0) {
          AppUtils.log(
            '⏳ Still waiting for chat initialization... (${attempts * 0.2}s)',
          );
        }
      }

      if (singleChatId == null) {
        AppUtils.logEr(
          '❌ Chat room initialization timed out after ${maxAttempts * 0.2} seconds',
        );
        AppUtils.toastError(
          'Unable to initialize chat. Please check your connection and try again.',
        );
        return;
      }

      AppUtils.log('✅ Chat room initialized: $singleChatId');
    }

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
      if (receiverId != null &&
          !msg.startsWith('SEP#Celebrate') &&
          !msg.startsWith('SEP#Post:') &&
          !msg.startsWith('SEP#Profile:')) {
        AppUtils.log('📲 Sending push notification via new service');
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
      } else if (msg.startsWith('SEP#Post:') ||
          msg.startsWith('SEP#Profile:')) {
        AppUtils.log('📝 Special content shared (post/profile)');
        if (receiverId != null) {
          ChatNotificationService.sendChatNotification(
            receiverId: receiverId!,
            message: msg,
            chatId: singleChatId!,
            type: 'text',
          ).catchError((error) {
            AppUtils.log('⚠️ Content share notification error: $error');
          });
        } else {
          AppUtils.log(
            '⚠️ No receiver ID available for content share notification',
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

  /// Send a post as a chat message
  /// Uses SEP#Post: prefix like celebrations and profiles
  Future<void> sendPostMessage(String postId) async {
    try {
      if (singleChatId == null) {
        AppUtils.logEr('❌ Cannot send post: chatId is null');
        AppUtils.toastError('Unable to share post. Please try again.');
        return;
      }

      AppUtils.log('📤 Sending post message - postId: $postId');

      // Create post message with SEP#Post: prefix (like SEP#Celebrate and SEP#Profile:)
      // Only send postId since post data contains userId
      final postMessage = 'SEP#Post:$postId';

      AppUtils.log('📤 Post message content: $postMessage');

      // Use the regular sendMessage method (same as celebrations and profiles)
      sendMessage(msg: postMessage, type: 'text');

      AppUtils.toast('Post shared successfully!');
    } catch (e) {
      AppUtils.logEr('❌ Failed to send post message: $e');
      AppUtils.toastError('Failed to share post');
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
        AppUtils.log('🗑️ Delete message listener called');
        AppUtils.log('📥 Delete response data: $data');

        try {
          final code = data['code'];
          final message = data['message'];
          final deletedMessages = data['deletedMessages'] as List<dynamic>?;

          AppUtils.log('📊 Response code: $code, message: $message');

          if (code == 200 &&
              deletedMessages != null &&
              deletedMessages.isNotEmpty) {
            // Extract message IDs from deleted messages
            final deletedIds = deletedMessages
                .map((msg) => msg['_id'] ?? msg['id'])
                .where((id) => id != null)
                .cast<String>()
                .toList();

            AppUtils.log(
              '🗑️ Processing ${deletedIds.length} deleted message(s): $deletedIds',
            );

            // Remove deleted messages from the local list
            chatMessages.removeWhere((msg) => deletedIds.contains(msg.id));
            chatMessages.refresh();

            AppUtils.log(
              '✅ Messages removed from UI. Remaining: ${chatMessages.length}',
            );
          } else {
            AppUtils.log('⚠️ Delete operation failed or no messages to delete');
          }
        } catch (e) {
          AppUtils.logEr('❌ Error processing delete message response: $e');
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
