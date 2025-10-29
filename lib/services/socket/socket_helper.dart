import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../utils/appUtils.dart';
import '../storage/preferences.dart';

enum SocketKey {
  joinRoom,
  getChatList,
  sendMessage,
  getMessages,
  deleteMessages,

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

  SocketHelper({required this.connectUrl}) {
    // Initialize socket immediately in constructor to prevent LateInitializationError
    AppUtils.log('� Initializing socket for: $connectUrl');
    socket = IO.io(
      connectUrl,
      IO.OptionBuilder()
          .setTransports([
            'websocket',
            'polling',
          ]) // Try websocket first, fallback to polling
          .disableAutoConnect() // Manual connection control
          .setTimeout(15000) // 15 second timeout
          .enableReconnection() // Enable reconnection
          .setReconnectionDelay(1000) // 1 second initial delay
          .setReconnectionDelayMax(5000) // Max 5 seconds between retries
          .setReconnectionAttempts(5) // Max 5 reconnection attempts
          .setExtraHeaders({
            'Authorization': Preferences.authToken ?? '',
          }) // Auth header
          .build(),
    );

    // Set up persistent event listeners
    _setupSocketListeners();
  }

  bool _isConnecting = false;
  bool get isConnected => socket.connected;
  Function()? _pendingConnectionCallback;

  void _setupSocketListeners() {
    socket.onConnect((_) {
      AppUtils.log('✅ Socket connected successfully');
      _isConnecting = false;
      if (_pendingConnectionCallback != null) {
        _pendingConnectionCallback!();
        _pendingConnectionCallback = null;
      }
    });

    socket.onDisconnect((_) {
      AppUtils.log('⚠️ Socket disconnected');
      _isConnecting = false;
    });

    socket.onConnectError((err) {
      AppUtils.logEr('❌ Socket connection error: $err');
      AppUtils.logEr(
        '💡 Check: 1) Server is running 2) Network connection 3) Auth token is valid',
      );
      _isConnecting = false;
    });

    socket.onError((err) {
      AppUtils.logEr('❌ Socket error: $err');
    });

    socket.onReconnectAttempt((attempt) {
      AppUtils.log('🔄 Reconnection attempt #$attempt of 5...');
    });

    socket.onReconnect((attempt) {
      AppUtils.log('✅ Reconnected successfully after $attempt attempts');
      _isConnecting = false;
      if (_pendingConnectionCallback != null) {
        _pendingConnectionCallback!();
        _pendingConnectionCallback = null;
      }
    });

    socket.onReconnectError((err) {
      AppUtils.logEr('❌ Reconnection error: $err');
    });

    socket.onReconnectFailed((_) {
      AppUtils.logEr('❌ All reconnection attempts failed');
      AppUtils.logEr('🔧 Please check your internet connection and try again');
      _isConnecting = false;
    });
  }

  void connect(Function() onConnection) {
    if (_isConnecting) {
      AppUtils.log('⏳ Connection already in progress, queuing callback...');
      _pendingConnectionCallback = onConnection;
      return;
    }

    if (socket.connected) {
      AppUtils.log('✅ Socket already connected');
      onConnection();
      return;
    }

    _isConnecting = true;
    _pendingConnectionCallback = onConnection;

    // Update auth token before connecting
    socket.io.options?['extraHeaders'] = {
      'Authorization': Preferences.authToken ?? '',
    };

    AppUtils.log('🔌 Connecting to socket: $connectUrl');
    AppUtils.log(
      '🔑 Using auth token: ${Preferences.authToken != null ? "Present" : "Missing"}',
    );

    socket.connect();
  }

  // Helper to manually retry connection
  void reconnect(Function() onConnection) {
    if (socket.connected) {
      AppUtils.log('✅ Already connected');
      onConnection();
      return;
    }

    AppUtils.log('🔄 Manual reconnection initiated...');
    _isConnecting = false; // Reset flag
    connect(onConnection);
  }

  // Disconnect socket cleanly
  void disconnect() {
    if (socket.connected) {
      AppUtils.log('🔌 Disconnecting socket...');
      socket.disconnect();
    }
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
    if (!hasListener(event)) {
      socket.on(event.name, (value) {
        AppUtils.log({
          'type': 'LISTENER Socket',
          'event': event.name,
          'data': value,
        });
        handler(value);
      });

      // socket.once(event, handler)
    }
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
}
