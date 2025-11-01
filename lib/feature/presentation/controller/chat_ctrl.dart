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
    // Store receiver ID for notifications
    receiverId = id;

    if (chatId == null) {
      _repo.joinRoomListener(
        data: (data) {
          // AppUtils.log('on join room .......${data}');
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
    _repo.closeListener(SocketKey.sendMessage);
    _repo.closeListener(SocketKey.getMessages);
    chatMessages.clear();
    singleChatId = null;
    singleChatPage = 1;
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
    if (singleChatId != null) {
      final currentTime = DateTime.now().toUtc().toIso8601String();

      final data = {
        "chatId": singleChatId,
        "senderId": Preferences.uid,
        "content": msg,
        "mediaType": type,
        "senderTime": currentTime,
      };

      AppUtils.log('🚀 SENDING MESSAGE:');
      AppUtils.log('📤 Data being sent to server: $data');
      AppUtils.log('👤 Current user ID in preferences: ${Preferences.uid}');
      AppUtils.log(
        '👤 Current profile name: ${ProfileCtrl.find.profileData.value.name}',
      );

      // Send to server
      _repo.sendMessage(data);

      // Send notification (non-blocking)
      if (receiverId != null) {
        _sendChatNotification(msg, type).catchError((error) {
          AppUtils.log('⚠️ Notification error (message still sent): $error');
        });
      }

      AppUtils.log('⏳ Message sent to server, waiting for response...');
    }
  }

  // Send push notification for chat message (doesn't create duplicate messages)
  Future<void> _sendChatNotification(String content, String type) async {
    if (receiverId == null || receiverId!.isEmpty) {
      AppUtils.log('⚠️ No receiver ID available for notification');
      return;
    }

    try {
      final senderName = ProfileCtrl.find.profileData.value.name ?? 'User';
      String notificationMessage;

      // Customize notification message based on content type
      if (type == 'file') {
        if (content.contains('.mp4') ||
            content.contains('.mov') ||
            content.contains('.avi')) {
          notificationMessage = 'sent you a video';
        } else {
          notificationMessage = 'sent you an image';
        }
      } else {
        // For text messages, show preview (limit to 50 characters)
        notificationMessage = content.length > 50
            ? '${content.substring(0, 50)}...'
            : content;
      }

      final result = await _authRepository.post(
        url: Urls.inviteFriendToLiveStream,
        enableAuthToken: true,
        data: {
          "type":
              "chatNotification", // Different type to avoid creating chat message
          "sentTo": receiverId,
          "sentBy": Preferences.uid,
          "message": notificationMessage,
          "senderName": senderName,
          "chatId": singleChatId,
        },
      );

      if (result.isSuccess) {
        AppUtils.log('✅ Chat notification sent successfully');
      } else {
        AppUtils.log('❌ Failed to send notification: ${result.getError}');
      }
    } catch (e) {
      AppUtils.log('❌ Error sending notification: $e');
    }
  }

  Future<void> sendImageMessage(XFile file) async {
    try {
      final result = await _authRepository.uploadPhoto(
        imageFile: File(file.path),
      );
      final imageUrl = result.data?.first.fileUrl;

      if (imageUrl != null && imageUrl.isNotEmpty) {
        chatMessages.refresh();
        final serverPayload = {
          "chatId": singleChatId,
          "senderId": Preferences.uid,
          "content": imageUrl,
          "mediaType": "file",
          "senderTime": DateTime.now().toUtc().toIso8601String(),
        };
        _repo.sendMessage(serverPayload);

        // Send notification (non-blocking)
        if (receiverId != null) {
          _sendChatNotification(imageUrl, "file").catchError((error) {
            AppUtils.log('⚠️ Notification error (image still sent): $error');
          });
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
        chatMessages.refresh();

        final serverPayload = {
          "chatId": singleChatId,
          "senderId": Preferences.uid,
          "content": videoUrl,
          "mediaType": "file",
          "senderTime": DateTime.now().toUtc().toIso8601String(),
        };

        _repo.sendMessage(serverPayload);

        // Send notification (non-blocking)
        if (receiverId != null) {
          _sendChatNotification(videoUrl, "file").catchError((error) {
            AppUtils.log('⚠️ Notification error (video still sent): $error');
          });
        }
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

        // Add message and maintain chronological order
        chatMessages.add(message);
        _sortMessagesByTime();
        AppUtils.log('➕ Added message to chat list and sorted by time');

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
