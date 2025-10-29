import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';

import '../../../services/socket/socket_helper.dart';
import '../../domain/respository/chat_repo.dart';

class IChatRepo implements ChatRepo {
  final SocketHelper _socket;
  IChatRepo(this._socket);

  @override
  void connect(Function() onConnect) {
    _socket.connect(onConnect);
  }

  @override
  void reconnect(Function() onConnect) {
    _socket.reconnect(onConnect);
  }

  @override
  bool get isConnected => _socket.isConnected;

  @override
  void getMessage({required Function(dynamic p1) data}) {
    _socket.listen(SocketKey.sendMessage, data);
  }

  @override
  void fireRecentChatEvent() {
    _socket.callEvent(SocketKey.getChatList, {"userId": Preferences.uid});
  }

  @override
  void getRecentChatList({required Function(dynamic p1) data}) {
    _socket.listen(SocketKey.getChatList, data);
    fireRecentChatEvent();
  }

  @override
  void getSingleChatList({
    required String chatId,
    required int page,
    required Function(dynamic data) data,
  }) {
    _socket.listen(SocketKey.getMessages, (value) => data(value));
    _socket.callEvent(SocketKey.getMessages, {
      "userId": Preferences.uid,
      'chatId': chatId,
      "page": page,
    });
    AppUtils.log({"userId": Preferences.uid, 'chatId': chatId, "page": page});
  }

  @override
  void sendMessage(msg) {
    _socket.callEvent(SocketKey.sendMessage, msg);
  }

  @override
  void join(data) {
    _socket.callEvent(SocketKey.joinRoom, data);
  }

  @override
  void joinRoomListener({required Function(dynamic p1) data}) {
    _socket.listen(SocketKey.joinRoom, data);
  }

  @override
  void closeListener(SocketKey key) => _socket.unsubscribe(key);

  @override
  void deleteMessage({
    required String messageId,
    required String chatId,
    required String type,
  }) {
    // AppUtils.log('Socket calling deleteMessage: $messageId, $chatId, $type');
    _socket.callEvent(SocketKey.deleteMessages, {
      'messageIds': messageId,
      'userId': Preferences.uid,
      'chatId': chatId,
      'types': type,
    });
  }

  @override
  void deleteMessageListener({required Function(dynamic p1) data}) {
    _socket.listen(SocketKey.deleteMessages, data);
  }
}
