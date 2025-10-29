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
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/extensions.dart';

import '../../../services/networking/urls.dart';
import '../../data/models/dataModels/profile_data/profile_data_model.dart';
import '../../data/repository/iAuthRepository.dart';
import '../../domain/respository/authRepository.dart';

class ChatCtrl extends GetxController {
  final ChatRepo _repo = IChatRepo(SocketHelper(connectUrl: baseUrl));

  static ChatCtrl get find {
    try {
      return Get.find<ChatCtrl>();
    } catch (e) {
      return Get.put(ChatCtrl());
    }
  }

  String? singleChatId;

  List<ProfileDataModel> get friendList => ProfileCtrl.find.myFollowingList;

  RxList<ChatMsgModel> chatMessages = RxList([]);
  RxList<RecentChatModel> recentChat = RxList([]);
  final AuthRepository _authRepository = IAuthRepository();

  // Track socket connection status
  RxBool isSocketConnected = RxBool(false);

  void getFriendsList() => ProfileCtrl.find.getMyFollowings();

  Timer? _connectionMonitorTimer;

  void connectSocket() {
    AppUtils.log('🔌 Attempting socket connection...');

    _repo.connect(() {
      isSocketConnected.value = true;
      AppUtils.log('✅ Socket connected - isSocketConnected set to TRUE');
      watchRecentChat();
      _startConnectionMonitor();
    });

    getFriendsList();
  }

  void _startConnectionMonitor() {
    // Cancel any existing monitor
    _connectionMonitorTimer?.cancel();

    // Check connection every 5 seconds
    _connectionMonitorTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      final actuallyConnected = _repo.isConnected;

      if (actuallyConnected != isSocketConnected.value) {
        AppUtils.log('⚠️ Socket connection state mismatch detected');
        AppUtils.log(
          '   Actual: $actuallyConnected, Tracked: ${isSocketConnected.value}',
        );
        isSocketConnected.value = actuallyConnected;
      }

      if (!actuallyConnected) {
        AppUtils.logEr('⚠️ Socket disconnected, attempting reconnect...');
        _repo.reconnect(() {
          isSocketConnected.value = true;
          AppUtils.log('✅ Reconnection successful');
          watchRecentChat();
        });
      }
    });
  }

  void stopConnectionMonitor() {
    _connectionMonitorTimer?.cancel();
    _connectionMonitorTimer = null;
  }

  bool get canSendMessages => isSocketConnected.value && singleChatId != null;

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
    AppUtils.log('🚪 ========== JOIN SINGLE CHAT ==========');
    AppUtils.log('   Peer ID: $id');
    AppUtils.log('   Chat ID: ${chatId ?? "NULL"}');
    AppUtils.log('   Socket Connected: ${isSocketConnected.value}');
    AppUtils.log('   Current User: ${Preferences.uid}');
    AppUtils.log('=========================================');

    // NEW: Ensure socket is connected before proceeding
    if (!isSocketConnected.value || !_repo.isConnected) {
      AppUtils.logEr('❌ Socket not connected, initiating connection...');
      AppUtils.toast('Connecting to chat server...');

      // Connect if not connected
      if (!_repo.isConnected) {
        connectSocket();
      }

      // Wait for connection with timeout
      int attempts = 0;
      Timer.periodic(Duration(milliseconds: 500), (timer) {
        attempts++;
        AppUtils.log('⏳ Waiting for connection... Attempt $attempts/20');

        if (isSocketConnected.value && _repo.isConnected) {
          timer.cancel();
          AppUtils.log('✅ Connection established, retrying joinSingleChat...');
          joinSingleChat(id, chatId); // Retry
        } else if (attempts >= 20) {
          timer.cancel();
          AppUtils.logEr('❌ Connection timeout after 10 seconds');
          AppUtils.toast(
            'Unable to connect to chat server. Please check your internet connection.',
          );
        }
      });
      return;
    }

    if (chatId != null) {
      // SCENARIO 1: Existing chat (from chat list)
      // =========================================
      singleChatId = chatId;
      AppUtils.log('✅ SCENARIO 1: Using existing chat ID');
      AppUtils.log('   Chat ID set to: $singleChatId');

      watchSingleChatData(isRefresh: true);

      // Register this session with the chat room (optional, for real-time updates)
      if (isSocketConnected.value) {
        _repo.join({'room': chatId});
        AppUtils.log('📤 Registered session with chat room');
      } else {
        AppUtils.log('⚠️ Socket not connected, skipping session registration');
      }

      // Set up message listeners
      getMessage();
      deleteMsgListener();

      AppUtils.log('✅ Chat room joined successfully (existing)');
      return;
    }

    // SCENARIO 2: New chat (from profile)
    // ===================================
    AppUtils.log('⚠️ SCENARIO 2: Creating new chat room');

    // Check if socket is connected
    if (!isSocketConnected.value) {
      AppUtils.logEr('❌ Socket not connected, cannot create new chat');
      AppUtils.logEr('   Current connection status: Disconnected');
      AppUtils.toast('Connecting to chat server... Please wait.');

      // Wait and retry
      int retryCount = 0;
      Timer.periodic(Duration(seconds: 2), (timer) {
        retryCount++;
        AppUtils.log('🔄 Retry attempt $retryCount/5');

        if (isSocketConnected.value) {
          timer.cancel();
          AppUtils.log('✅ Socket connected, retrying chat creation');
          joinSingleChat(id, chatId);
        } else if (retryCount >= 5) {
          timer.cancel();
          AppUtils.logEr('❌ Connection timeout after 5 attempts');
          AppUtils.toast(
            'Unable to connect to chat server. Please try again later.',
          );
        }
      });
      return;
    }

    AppUtils.log('✅ Socket is connected, proceeding with chat creation');
    AppUtils.log('⏳ Setting up join room listener...');

    // Set up listener for server response
    _repo.joinRoomListener(
      data: (data) {
        AppUtils.log('📥 ===== JOIN ROOM RESPONSE =====');
        AppUtils.log('   Response data: $data');

        _repo.closeListener(SocketKey.joinRoom);

        final serverChatId = data['_id'];
        AppUtils.log('   Extracted chat ID: $serverChatId');

        if (serverChatId != null) {
          singleChatId = serverChatId;
          AppUtils.log('✅ Chat room created successfully!');
          AppUtils.log('   Chat ID: $singleChatId');
          watchSingleChatData(isRefresh: true);
        } else {
          AppUtils.logEr('❌ Server response missing _id field');
          AppUtils.logEr('   Full response: $data');
          AppUtils.toast('Failed to create chat. Please try again.');
        }
        AppUtils.log('=================================');
      },
    );

    // Send join request
    final joinPayload = {"userId": Preferences.uid, "otherUserId": id};
    AppUtils.log('📤 Sending join room request...');
    AppUtils.log('   Payload: $joinPayload');

    _repo.join(joinPayload);

    // Set up message listeners
    getMessage();
    deleteMsgListener();

    AppUtils.log('✅ Join request sent, waiting for server response...');
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
    _repo.closeListener(SocketKey.sendMessage);
    _repo.closeListener(SocketKey.getMessages);
    chatMessages.clear();
    singleChatId = null;
    singleChatPage = 1;
  }

  @override
  void onClose() {
    stopConnectionMonitor();
    super.onClose();
  }

  int singleChatPage = 1;
  int _tempSingleChatPage = 1;

  RxBool isSingleChatLoading = RxBool(false);

  Future watchSingleChatData({
    bool isRefresh = false,
    bool isLoadMore = false,
  }) async {
    isSingleChatLoading.value = true;
    _tempSingleChatPage = singleChatPage;
    if (isRefresh) _tempSingleChatPage = 1;
    if (isLoadMore) _tempSingleChatPage++;
    final result = await getSingleChat();

    print("Data ------ $result");

    // singleMessageScreenChatOperationKey.currentState?.stopLoading();
  }

  Future getSingleChat() async {
    _repo.getSingleChatList(
      chatId: singleChatId!,
      page: _tempSingleChatPage,
      data: (data) {
        AppUtils.log(data);
        final list = List<ChatMsgModel>.from(
          data.map((json) => ChatMsgModel.fromJson(json)),
        );
        if (list.isNotEmpty) {
          singleChatPage = _tempSingleChatPage;
        }

        if (_tempSingleChatPage == 1) {
          chatMessages.assignAll(list);
          // Sort messages by time after initial load
          _sortMessagesByTime();
        } else {
          List<ChatMsgModel> newList = [];
          for (var newItem in list) {
            bool exists = chatMessages.any((item) => item.id == newItem.id);
            if (!exists) {
              newList.add(newItem);
            }
          }
          chatMessages.addAll(newList);
          // Sort messages by time after adding more messages
          _sortMessagesByTime();
        }
        chatMessages.refresh();
        // checkValue;
        // AppUtils.log(singleMessageScreenChatOperationKey.currentState != null);
        // if()

        // callBack?.call();
        isSingleChatLoading.value = false;
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
    // Validate chat room is ready
    if (singleChatId == null) {
      AppUtils.logEr('❌ Cannot send message: Chat room not initialized');
      AppUtils.toast('Connecting to chat... Please wait a moment.');
      return;
    }

    // Check socket connection
    if (!isSocketConnected.value) {
      AppUtils.logEr('❌ Cannot send message: Socket not connected');
      AppUtils.toast('Connection lost. Reconnecting...');
      return;
    }

    final currentTime = DateTime.now().toUtc().toIso8601String();

    final data = {
      "chatId": singleChatId,
      "senderId": Preferences.uid,
      "content": msg,
      "mediaType": type,
      "senderTime": currentTime,
    };

    AppUtils.log('🚀 Sending message:');
    AppUtils.log('  Chat ID: $singleChatId');
    AppUtils.log('  Content: $msg');
    AppUtils.log('  Type: $type');

    // Add optimistic update - show message immediately
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimisticMessage = ChatMsgModel(
      id: tempId,
      chat: singleChatId,
      sender: Sender(
        id: Preferences.uid,
        name: ProfileCtrl.find.profileData.value.name,
      ),
      content: msg,
      mediaType: type,
      senderTime: currentTime,
      createdAt: currentTime,
      updatedAt: currentTime, v: null,
    );

    // Show message immediately in UI
    chatMessages.add(optimisticMessage);
    _sortMessagesByTime();
    chatMessages.refresh();
    AppUtils.log('✅ Message displayed in UI');

    // Send to server
    try {
      _repo.sendMessage(data);
      AppUtils.log('📤 Message sent to server');
    } catch (e) {
      AppUtils.logEr('❌ Failed to send message: $e');
      AppUtils.toast('Failed to send message. Please try again.');
      // Remove the optimistic message if send fails
      chatMessages.removeWhere((m) => m.id == tempId);
      chatMessages.refresh();
    }
  }

  Future<void> sendImageMessage(XFile file) async {
    try {
      final currentTime = DateTime.now().toUtc().toIso8601String();
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

      // Show loading placeholder immediately
      final tempMessage = ChatMsgModel(
        id: tempId,
        chat: singleChatId,
        sender: Sender(
          id: Preferences.uid,
          name: ProfileCtrl.find.profileData.value.name,
        ),
        content: file.path, // Local path temporarily
        mediaType: "file",
        senderTime: currentTime,
        createdAt: currentTime,
        updatedAt: currentTime, v: null,
      );

      chatMessages.add(tempMessage);
      _sortMessagesByTime();
      chatMessages.refresh();
      AppUtils.log('✅ Image message added optimistically to UI');

      final result = await _authRepository.uploadPhoto(
        imageFile: File(file.path),
      );
      final imageUrl = result.data?.first.fileUrl;

      if (imageUrl != null && imageUrl.isNotEmpty) {
        // Remove temp message and add real one
        chatMessages.removeWhere((msg) => msg.id == tempId);
        chatMessages.refresh();

        final serverPayload = {
          "chatId": singleChatId,
          "senderId": Preferences.uid,
          "content": imageUrl,
          "mediaType": "file",
          "senderTime": DateTime.now().toUtc().toIso8601String(),
        };
        _repo.sendMessage(serverPayload);
        AppUtils.log('📤 Image uploaded and message sent to server');
      }
    } catch (e) {
      AppUtils.toast('Failed to send image');
    }
  }

  Future<void> sendVideoMessage(XFile file) async {
    try {
      final currentTime = DateTime.now().toUtc().toIso8601String();
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

      // Show loading placeholder immediately
      final tempMessage = ChatMsgModel(
        id: tempId,
        chat: singleChatId,
        sender: Sender(
          id: Preferences.uid,
          name: ProfileCtrl.find.profileData.value.name,
        ),
        content: file.path, // Local path temporarily
        mediaType: "file",
        senderTime: currentTime,
        createdAt: currentTime,
        updatedAt: currentTime,
      );

      chatMessages.add(tempMessage);
      _sortMessagesByTime();
      chatMessages.refresh();
      AppUtils.log('✅ Video message added optimistically to UI');

      final result = await _authRepository.uploadPhoto(
        imageFile: File(file.path),
      );
      final videoUrl = result.data?.first.fileUrl;

      if (videoUrl != null && videoUrl.isNotEmpty) {
        // Remove temp message and add real one
        chatMessages.removeWhere((msg) => msg.id == tempId);
        chatMessages.refresh();

        final serverPayload = {
          "chatId": singleChatId,
          "senderId": Preferences.uid,
          "content": videoUrl,
          "mediaType": "file",
          "senderTime": DateTime.now().toUtc().toIso8601String(),
        };

        _repo.sendMessage(serverPayload);
        AppUtils.log('📤 Video uploaded and message sent to server');
      }
    } catch (e) {
      AppUtils.toast('Failed to send video');
    }
  }

  void getMessage() {
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
        AppUtils.log('🔧 FIXED: Sender ID should no longer be null!');

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

        // If from current user, remove any temporary message with same content
        if (isFromCurrentUser) {
          chatMessages.removeWhere(
            (msg) =>
                msg.id?.startsWith('temp_') == true &&
                msg.content == message.content &&
                msg.mediaType == message.mediaType,
          );
          AppUtils.log(
            '🗑️ Removed temporary message, replacing with server version',
          );
        }

        // Check if this message already exists (by ID)
        final existingIndex = chatMessages.indexWhere(
          (msg) => msg.id == message.id,
        );
        if (existingIndex == -1) {
          // Add new message
          chatMessages.add(message);
          _sortMessagesByTime();
          AppUtils.log('➕ Added new message to chat list and sorted by time');
        } else {
          AppUtils.log('⚠️ Message already exists, skipping duplicate');
        }

        chatMessages.refresh();

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
}
