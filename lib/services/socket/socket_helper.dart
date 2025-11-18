import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../utils/appUtils.dart';
import '../storage/preferences.dart';

enum SocketKey {
  joinRoom,
  getChatList,
  sendMessage,
  getMessages,
  deleteMessages,
  deleteChat,

  joinLiveChatRoom,
  sendLiveChatMessage,
  receiveLiveChatMessage,
  leaveLiveChatRoom,
  leaveLive,
  newChatMessage,
  joinLive,
  sendChatMessage,
  startLive,
  liveError,
  liveStarted,
  liveJoined,
  userJoinedLive,
  userLeftLive,
  liveEnded,
  chatError,
  roomExist,
  participantsList,
  liveUserCountUpdate,
  getParticipantsList,
  activeLiveRooms,
  userConnected,
  getLiveFollowers,
  inviteUserLive,
  getLiveRoomInfo,
  liveRoomInfo,
  newParticipantJoined,
}

// updateDriverStatus

class SocketKeys {
  static const String roomId = 'roomId';
  static const String message = 'message';
  static const String statusType = 'statusType';
  static const String coordinates = 'coordinates';
  static const String rideId = 'rideId';
  static const String previousRideStatus = 'previousStatus';
  static const String speed = 'speed';
  static const String messageId = 'messageId';

  static const String userId = 'userId';
  static const String timestamp = 'timestamp';
  static const String username = 'username';
}

class SocketHelper {
  String connectUrl;
  late IO.Socket socket;

  SocketHelper({required this.connectUrl});

  void connect(Function() onConnection) {
    AppUtils.log(Preferences.authToken);
    socket = IO.io(connectUrl, <String, dynamic>{
      'autoConnect': false,
      'transports': ['websocket'],
      'timeout': 10000, // 10 second timeout (increased for better reliability)
      'reconnection': true, // Enable reconnection for better stability
      'reconnectionAttempts': 3,
      'reconnectionDelay': 1000,
    });
    socket.io.options?['extraHeaders'] = {
      'Authorization': Preferences.authToken,
    };
    if (socket.connected) {
      print('Connection established');
      onConnection();
      return;
    } else {
      socket.connect();
    }
    socket.onConnect((_) {
      print('Connection established');
      onConnection();
      return;
    });
    socket.onDisconnect((_) => print('Connection Disconnection'));
    socket.onConnectError((err) {
      AppUtils.logEr('SocketError :: $err');
      // Don't retry connection if it's a server configuration issue
      if (err.toString().contains('503') ||
          err.toString().contains('not upgraded')) {
        AppUtils.log(
          'Socket server not available, stopping connection attempts',
        );
        return;
      }
    });
    socket.onError((err) => AppUtils.logEr('SocketError :: $err'));
  }

  void joinRoomEvent(String roomId, {String? uid}) => callEvent(
    SocketKey.joinRoom,
    {SocketKeys.roomId: roomId, SocketKeys.userId: uid},
  );

  void callEvent(SocketKey event, dynamic data) {
    socket.emit(event.name, data);

    AppUtils.log({'type': 'EMIT Socket', 'event': event.name, 'data': data});
  }

  void listen(SocketKey event, dynamic Function(dynamic) handler) async {
    // Remove any existing listeners for this event to prevent duplicates
    if (hasListener(event)) {
      AppUtils.log(
        '⚠️ Removing existing listener for ${event.name} to prevent duplicates',
      );
      socket.off(event.name);
    }

    socket.on(event.name, (value) {
      AppUtils.log({
        'type': 'LISTENER Socket',
        'event': event.name,
        'data': value,
      });
      handler(value);
    });

    AppUtils.log('✅ Listener registered for ${event.name}');
  }

  void get(SocketKey event, dynamic Function(dynamic) handler) {
    socket.once(event.name, (value) {
      AppUtils.log({'type': 'ONCE Socket', 'event': event.name, 'data': value});
      handler(value);
    });
  }

  void unsubscribe(SocketKey event) {
    if (hasListener(event)) {
      socket.off(event.name);
    }
  }

  void deleteMessageNow(String messageId) {
    callEvent(SocketKey.deleteMessages, {SocketKeys.messageId: messageId});
  }

  bool hasListener(SocketKey event) => socket.hasListeners(event.name);

  bool get isConnected => socket.connected;
}
