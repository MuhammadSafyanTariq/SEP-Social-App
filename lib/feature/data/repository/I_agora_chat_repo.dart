import 'package:sep/services/socket/socket_helper.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import '../../domain/respository/agora_chat_repo.dart';
import '../../presentation/controller/agora_chat_ctrl.dart';


class IAgoraChatRepo implements AgoraChatRepo {
  final SocketHelper _socket;

  IAgoraChatRepo(this._socket);

  @override
  void connect(Function() onConnected, {Function(dynamic)? onError}) {
    _socket.connect(onConnected);
  }

  @override
  void onMessageReceive(Function(dynamic) data) {
    _socket.listen(SocketKey.newChatMessage, data);
  }

  @override
  void joinLive(String host) {
    _socket.callEvent(SocketKey.joinLive, {
      "userId": Preferences.uid,
      "hostId":host
    });
  }

  @override
  void leave() {
    _socket.callEvent(SocketKey.leaveLive, {'userId':Preferences.uid});
  }

  @override
  void sendMessage(Map<String,dynamic> msg, {String? userId}) {
    _socket.callEvent(SocketKey.sendChatMessage, {
      "userId": userId ?? Preferences.uid,
      ...msg
    });
  }

  @override
  void startLive() {
    AppUtils.log({
      'event': 'startLive',
      'data': {'userId':Preferences.uid}
    });
    _socket.callEvent(SocketKey.startLive, {'userId':Preferences.uid});
  }

  @override
  void onLiveError(Function(dynamic) data) {
    _socket.listen(SocketKey.liveError, data);
  }

  @override
  void onLiveStart(Function(dynamic) data) {

    _socket.listen(SocketKey.liveStarted, data);
  }

  @override
  void onLiveJoined(Function(dynamic) data) {
    _socket.listen(SocketKey.liveJoined, data);
  }

  @override
  void onUserJoinedLive(Function(dynamic) data) {
    _socket.listen(SocketKey.userJoinedLive, data);
  }

  @override
  void onUserLeftLive(Function(dynamic) data) {
    _socket.listen(SocketKey.userLeftLive, data);
  }

  @override
  void onChatError(Function(dynamic) data) {
    _socket.listen(SocketKey.chatError, data);
  }

  @override
  void onLiveEnded(Function(dynamic) data) {
    _socket.listen(SocketKey.liveEnded, data);
  }

  @override
  void removeListenersOnLeaveLiveStream() {

  }

  @override
  void unsubscribe(SocketKey key) {
    _socket.unsubscribe(key);
  }

  @override
  bool get isConnected {
    try{
     return _socket.socket.connected;
    }catch(e){
      return false;
    }
  }

  @override
  void checkRoomExist(String roomId, String hostId,{int? broadCasterCount} ) {
    _socket.callEvent(SocketKey.roomExist,{
      'roomId':roomId,
      "hostId":hostId,
      ...(broadCasterCount != null ? {'broadcastCount':broadCasterCount} : {})
    });
  }

  @override
  void onRoomExistCheckResult(Function(dynamic) data) {
    _socket.get(SocketKey.roomExist, data);
  }

  @override
  void onParticipantsCount(Function(dynamic) data) {
    _socket.listen(SocketKey.liveUserCountUpdate, data);
  }

  @override
  void getParticipantsList(String roomId, String hostId) {
    _socket.callEvent(SocketKey.getParticipantsList,{
      'roomId':roomId,
      // "userId":Preferences.uid,
      "userId":hostId,
    });
  }

  @override
  void onActiveLiveRooms(Function(dynamic) data) {
    _socket.listen(SocketKey.activeLiveRooms, data);
  }

  @override
  void getLiveStreamChannelList() {
    _socket.callEvent(SocketKey.getLiveFollowers,{'userId':Preferences.uid,});
  }

  @override
  void onLiveStreamChannelList(Function(dynamic) data) {
    _socket.listen(SocketKey.getLiveFollowers, data);
  }

  @override
  void connectUserForListenLiveStream() {
    _socket.callEvent(SocketKey.userConnected,{'userId':Preferences.uid,});
  }

  @override
  void sendLiveRequestToFriendByHost(Map<String, dynamic> data) {
    _socket.callEvent(SocketKey.inviteUserLive, {
      'sentBy': Preferences.uid,
      ...data,
      'type':LiveRequestStatus.inviteForLive.name,
      "message": '${Preferences.profile?.name ?? ''} invited you to join live video session',
    });
  }

  @override
  void getLiveRoomInfo(String hostId, String roomId) {
    _socket.callEvent(SocketKey.getLiveRoomInfo, {
      "hostId":hostId,
      "roomId":roomId
    });
  }

  @override
  void onNewParticipantJoined(Function(dynamic) data) {
    _socket.listen(SocketKey.newParticipantJoined, data);
  }










  // _onReceiveMessage();
  // _onError();
  // _onJoin();
  // _onUserJoinedLive();
  // _onUserLeave();
  // _onLiveEnded();
  // _onChatError();



}
