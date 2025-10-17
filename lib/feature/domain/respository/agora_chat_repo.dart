

import 'package:sep/services/socket/socket_helper.dart';

abstract class AgoraChatRepo {

  bool get isConnected;

  void connect(Function() onConnected, {Function(dynamic)? onError});

  //Events....
  void startLive();

  void joinLive(String host);

  void leave();

  void sendMessage(Map<String,dynamic> msg, {String? userId});

  void checkRoomExist(String roomId, String hostId,{int? broadCasterCount});

  void getParticipantsList(String roomId, String hostId);

  void getLiveRoomInfo(String hostId, String roomId);

  void getLiveStreamChannelList();

  void connectUserForListenLiveStream();

  void sendLiveRequestToFriendByHost(Map<String,dynamic> data);



  //listeners.....

  void onLiveError(Function(dynamic) data);

  void onLiveStart(Function(dynamic) data);

  void onLiveJoined(Function(dynamic) data);

  void onNewParticipantJoined(Function(dynamic) data);

  void onUserJoinedLive(Function(dynamic) data);

  void onUserLeftLive(Function(dynamic) data);

  void onMessageReceive(Function(dynamic) data);

  void onLiveEnded(Function(dynamic) data);

  void onChatError(Function(dynamic) data);

  void removeListenersOnLeaveLiveStream();

  void unsubscribe(SocketKey key);

  void onRoomExistCheckResult(Function(dynamic) data);

  void onParticipantsCount(Function(dynamic) data);

  void onActiveLiveRooms(Function(dynamic) data);

  void onLiveStreamChannelList(Function(dynamic) data);




}
