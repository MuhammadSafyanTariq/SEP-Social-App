import 'package:sep/services/socket/socket_helper.dart';

abstract class ChatRepo {
  void connect(Function() onConnect);
  void join(data);
  void joinRoomListener({required Function(dynamic) data});
  void fireRecentChatEvent();
  void getRecentChatList({required Function(dynamic) data});
  void getSingleChatList({
    required String chatId,
    required int page,
    required Function(dynamic data) data,
  });
  void sendMessage(msg);
  void getMessage({required Function(dynamic) data});
  void closeListener(SocketKey key);
  void deleteMessage({
    required String messageId,
    required String chatId,
    required String type,
  });
  void deleteMultipleMessages({
    required List<String> messageIds,
    required String chatId,
    required String type,
  });
  void deleteMessageListener({required Function(dynamic p1) data});
  void deleteChat({required String chatId});
  void deleteChatListener({required Function(dynamic p1) data});
  void markMessagesAsRead({required String chatId});
  bool isConnected();
}
