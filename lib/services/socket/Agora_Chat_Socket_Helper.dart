import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../utils/appUtils.dart';

enum LiveChatSocketEvent {
  joinLiveChatRoom,
  sendLiveChatMessage,
  receiveLiveChatMessage,
  leaveLiveChatRoom,
}


class LiveChatSocketKeys {
  static const String roomId = 'roomId';
  static const String userId = 'userId';
  static const String message = 'message';
  static const String timestamp = 'timestamp';
  static const String username = 'username';
}



typedef OnConnectCallback = void Function();
typedef OnErrorCallback = void Function(dynamic error);
typedef OnMessageCallback = void Function(dynamic data);

class AgoraChatSocketHelper {
  final String connectUrl;

  late IO.Socket _socket;

  AgoraChatSocketHelper({required this.connectUrl});

  void connect({
    required OnConnectCallback onConnect,
    required OnErrorCallback onError,
  }) {
    _socket = IO.io(
      connectUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket.connect();

    _socket.onConnect((_) {
      AppUtils.log(" Agora socket connected");
      onConnect();
    });

    _socket.onDisconnect((_) {
      AppUtils.log(" Agora socket disconnected");
    });

    _socket.onConnectError((e) {
      AppUtils.log(" Agora socket connection error: $e");
      onError(e);
    });

    _socket.onError((e) {
      AppUtils.log(" Agora socket general error: $e");
      onError(e);
    });
  }

  void joinRoom({required String roomId, required String username}) {
    final data = {
      "userId": username,
      "roomId": roomId,
    };
    AppUtils.log(" Emitting joinLive: $data");
    _socket.emit("joinLive", data);
  }

  void leaveRoom(String roomId) {
    final data = {
      "roomId": roomId,
    };
    AppUtils.log(" Emitting leaveLive: $data");
    _socket.emit("leaveLive", data);
  }

  void sendMessage({required String roomId, required String message, required String username}) {
    final data = {
      "userId": username,
      "roomId": roomId,
      "message": message,
    };
    AppUtils.log(" Sending message: $data");
    _socket.emit("sendChatMessage", data);
  }

  void onMessage(OnMessageCallback callback) {
    _socket.on("newChatMessage", callback);
  }

  void unsubscribeFromMessage() {
    _socket.off("newChatMessage");
  }

  void disconnect() {
    AppUtils.log(" Disconnecting socket...");
    _socket.dispose();
  }
}




