import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:get/get.dart';
import 'package:sep/feature/data/repository/i_agora_chat_repo.dart';
import 'package:sep/feature/domain/respository/agora_chat_repo.dart';
import 'package:sep/main.dart';
import 'package:sep/services/socket/socket_helper.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';

import '../../../services/networking/urls.dart';
import '../../data/models/dataModels/live_stream_message_model/live_stream_message_model.dart';
import '../liveStreaming_screen/broad_cast_video.dart';
import '../liveStreaming_screen/live_stream_ctrl.dart';

bool _showLog = true;

enum LiveRequestStatus {
  requested,
  allowed,
  rejected,
  joined,
  leave,
  end,
  removeByHost,
  inviteForLive,
}

enum GiftTokenEnum { giftToken }

class AgoraChatCtrl extends GetxController {
  static AgoraChatCtrl get find {
    try {
      return Get.find<AgoraChatCtrl>();
    } catch (e) {
      return Get.put(AgoraChatCtrl());
    }
  }

  // static Future<bool> get clear => Get.delete<AgoraChatCtrl>();

  LiveStreamCtrl get liveStreamCtrl => LiveStreamCtrl.find;
  String? roomId;
  String? hostId;
  RxInt coinsAnimationList = RxInt(0);

  final RxInt _liveCount = RxInt(0);

  String get liveCountValue => '${_liveCount.value}';

  bool chatConnection = false;

  RxInt hostGiftAmountTotal = RxInt(0);

  RxList<LiveStreamMessageModel> chatList = RxList();

  ClientRoleType? get role => LiveStreamCtrl.find.streamCtrl.value.clientRole;

  final AgoraChatRepo _repo = IAgoraChatRepo(SocketHelper(connectUrl: baseUrl));

  // RxList<ChatMsgModel> liveChatMessages = <ChatMsgModel>[].obs;

  void connect(Function() onCreateConnection) {
    if (_repo.isConnected) {
      onCreateConnection();
      return;
    } else {
      _repo.connect(() {
        onCreateConnection();
        _connectUserForListenLiveStream();
      });

      return;
    }
  }

  void connectAndJoin(String hostId, String username) {
    // _chatConnection = false;
    connect(() {
      if (chatConnection) {
        AppUtils.log('go back');
        return;
      } else {
        AppUtils.log('continue');
        chatConnection = true;
        this.hostId = hostId;
        callStart();
      }
      // _onConnect();
      return;
    });
  }

  void hitParticipantsList(String roomId) =>
      _repo.getParticipantsList(roomId, hostId!);

  void updateLiveBroadCasterCountByHost(int broadcasters) =>
      roomId != null && hostId != null
      ? _repo.checkRoomExist(roomId!, hostId!, broadCasterCount: broadcasters)
      : null;

  void checkIfRoomExist(
    String roomId,
    String hostId,
    Function(bool, int) call,
  ) {
    _repo.onRoomExistCheckResult((data) {
      AppUtils.log(data);
      final broadcasters = data?['data']?['data']?['broadcastCount'];
      call(
        (data['code'] ?? 400) == 200,
        (broadcasters ?? 0) == 0 ? 1 : broadcasters,
      );

      // flutter: │ 🐛 {
      // flutter: │ 🐛   "code": 400,
      // flutter: │ 🐛   "status": false,
      // flutter: │ 🐛   "message": "No live room available for this host"
      // flutter: │ 🐛 }
    });
    _repo.checkRoomExist(roomId, hostId);
  }

  void _connectUserForListenLiveStream() {
    _repo.connectUserForListenLiveStream();
  }

  void getLiveStreamChannelList() {
    _repo.getLiveStreamChannelList();
  }

  void sendLiveRequestToFriendByHost(String uid) {
    _repo.sendLiveRequestToFriendByHost({'sentTo': uid, 'channelId': roomId});
  }

  RxList<LiveStreamChannelModel> liveStreamChannels = RxList([]);

  void onLiveStreamChannelList() {
    _repo.onLiveStreamChannelList((data) {
      AppUtils.log('liveChannelsdata ::: ::::::::');
      AppUtils.log(data);
      if (data['code'] == 200) {
        final list = List<LiveStreamChannelModel>.from(
          (data['data']?['liveFollowers'] ?? []).map(
            (json) => LiveStreamChannelModel.fromJson(json),
          ),
        );
        liveStreamChannels.assignAll(list);
      }

      // flutter: │ 🐛 {
      // flutter: │ 🐛   "code": 200,
      // flutter: │ 🐛   "message": "Live followers retrieved successfully",
      // flutter: │ 🐛   "data": {
      // flutter: │ 🐛     "liveFollowers": [],
      // flutter: │ 🐛     "totalLiveFollowers": 0,
      // flutter: │ 🐛     "totalFollowers": 5,
      // flutter: │ 🐛     "requestedBy": "68776d0beb035f622fff2bc3",
      // flutter: │ 🐛     "timestamp": "2025-07-21T04:53:24.505Z"
      // flutter: │ 🐛   }
      // flutter: │ 🐛 }
    });
  }

  bool isUserLive(String uid) {
    return liveStreamChannels.indexWhere((element) => element.hostId == uid) >
        -1;
  }

  void joinLiveChannel(
    LiveStreamChannelModel data,
    ClientRoleType? role,
    bool isConnected,
    Function(dynamic) call,
  ) {
    void navigateIfRoomExists() {
      checkIfRoomExist(data.channelId!, data.hostId!, (exists, broadcasters) {
        if (exists) {
          final newRole = broadcasters < broadCastUserMaxLimit
              ? (role ?? ClientRoleType.clientRoleAudience)
              : ClientRoleType.clientRoleAudience;

          AppUtils.log({
            'newRole ': newRole.name,
            'live': broadcasters,
            'max': broadCastUserMaxLimit,
          });
          navState.currentContext!
              .pushNavigator(
                BroadCastVideo(
                  clientRole: newRole,
                  hostId: data.hostId,
                  hostName: data.hostName,
                ),
              )
              .then(call);
        } else {
          AppUtils.toastError('Live stream ended!');
        }
      });
    }

    if (!_repo.isConnected) {
      AppUtils.log('Socket not connected, establishing connection...');
      connect(() {
        AppUtils.log('Socket connected, navigating to live stream...');
        navigateIfRoomExists();
      });
    } else {
      AppUtils.log('Socket already connected, navigating to live stream...');
      navigateIfRoomExists();
    }
  }

  // void joinLiveChannel(LiveStreamChannelModel data, bool connectionState ){
  //   if(!connectionState){
  //     connect((){
  //       if(connectionState) return;
  //       connectionState = true;
  //       checkIfRoomExist(data.channelId!, data.hostId!,(value){
  //         if(value){
  //           navState.currentContext!.pushNavigator(BroadCastVideo(
  //             clientRole: ClientRoleType.clientRoleAudience,
  //             hostId: data.hostId,
  //             hostName: data.hostName ,
  //           ));
  //         }else{
  //           AppUtils.toastError('Live stream ended!');
  //         }
  //       });
  //     });
  //   }else{
  //     checkIfRoomExist(data.channelId!, data.hostId!,(value){
  //       if(value){
  //         navState.currentContext!.pushNavigator(BroadCastVideo(
  //           clientRole: ClientRoleType.clientRoleAudience,
  //           hostId: data.hostId,
  //           hostName: data.hostName ,
  //         ));
  //       }else{
  //         AppUtils.toastError('Live stream ended!');
  //       }
  //     });
  //   }
  // }

  void callStart() {
    // if (role == ClientRoleType.clientRoleBroadcaster) {
    if (liveStreamCtrl.isHost) {
      _startLive();
    } else {
      _joinLive();
    }
    _onReceiveMessage();
    _onError();
    _onJoin();
    _onUserJoinedLive();
    _onUserLeave();
    _onLiveEnded();
    _onChatError();
    _onParticipantsCount();
  }

  void _startLive() {
    AppUtils.log('emit-----_startLive');
    _repo.startLive();
  }

  void _joinLive() {
    AppUtils.log('emit-----_joinLive');
    _repo.joinLive(hostId!);
  }

  void _onNewParticipantJoined() {
    _repo.onNewParticipantJoined((data) {
      AppUtils.log(data);
    });
  }

  void sendMessage(String msg) {
    _repo.onChatError((data) {
      AppUtils.logEr({'channel': 'onChatError', 'data': data}, show: _showLog);
    });
    _sendMsg({"message": msg, "roomId": roomId});
  }

  void _sendMsg(Map<String, dynamic> json, {String? userId}) =>
      _repo.sendMessage(json, userId: userId);

  void sendLiveRequest() {
    _sendMsg({
      "message": LiveRequestStatus.requested.name,
      "type": 'liveRequest',
      "roomId": roomId,
    });
  }

  void giftTokenEmitter({required String token, required String hostId}) {
    _sendMsg({
      "message": token,
      "type": GiftTokenEnum.giftToken.name,
      "roomId": roomId,
      'hostId': hostId,
    });
  }

  void hostRequestActive(
    LiveRequestStatus status,
    String msgId,
    String userId,
  ) {
    // message:allowed
    // "type": 'liveRequest'

    _sendMsg({
      "msgId": msgId,
      "message": status.name,
      "type": 'liveRequest',
      "roomId": roomId,
    }, userId: userId);
  }

  void removeFromBroadcasterByHost(String userId) {
    _sendMsg({
      // "msgId": msgId,
      "message": LiveRequestStatus.removeByHost.name,
      "type": 'liveRequest',
      "roomId": roomId,
    }, userId: userId);
  }

  void leaveAudienceLiveCamera(LiveRequestStatus status) {
    if (liveStreamCtrl.isHost) return;
    final index = chatList.indexWhere(
      (element) =>
          element.type == 'liveRequest' &&
          element.message == LiveRequestStatus.allowed.name,
    );
    if (index > -1) {
      final data = chatList[index];
      hostRequestActive(status, data.id!, Preferences.uid!);
    }
  }

  late StreamController<LiveStreamMessageModel>
  _incomingLiveRequestToHostController =
      StreamController<LiveStreamMessageModel>.broadcast();

  Stream<LiveStreamMessageModel> get incomingLiveRequestToHostStream =>
      _incomingLiveRequestToHostController.stream;

  void _onReceiveMessage() {
    _repo.onMessageReceive((data) {
      final msgData = LiveStreamMessageModel.fromJson(data);

      if (msgData.type == 'liveRequest' &&
          !liveStreamCtrl.isHost &&
          msgData.userId == Preferences.uid) {
        if (msgData.message == LiveRequestStatus.allowed.name ||
            msgData.message == LiveRequestStatus.removeByHost.name) {
          liveStreamCtrl.changeRole();
        }
      }

      // flutter: │ 🐛 {
      // flutter: │ 🐛   "channel": "onMessageReceive",
      // flutter: │ 🐛   "data": {
      // flutter: │ 🐛     "id": "msg_1755520968285_683a8cc26a337827c39db2ef",
      // flutter: │ 🐛     "type": "liveRequest",
      // flutter: │ 🐛     "message": "requested",
      // flutter: │ 🐛     "timestamp": "2025-08-18T12:42:48.285Z",
      // flutter: │ 🐛     "userId": "683a8cc26a337827c39db2ef",
      // flutter: │ 🐛     "userName": "testing live",
      // flutter: │ 🐛     "userRole": "participant",
      // flutter: │ 🐛     "participantCount": 2
      // flutter: │ 🐛   }
      // flutter: │ 🐛 }

      if (msgData.type == 'liveRequest' &&
          liveStreamCtrl.isHost &&
          msgData.message == LiveRequestStatus.requested.name) {
        AppUtils.log('open bs');

        AppUtils.log(msgData);

        if (_incomingLiveRequestToHostController.isClosed) {
          _incomingLiveRequestToHostController =
              StreamController<LiveStreamMessageModel>.broadcast();
        }
        _incomingLiveRequestToHostController.add(msgData);
      }

      // ctrl.isHost && liveRequestStatus == 0
      // final liveRequestStatus = LiveRequestStatus.values
      //     .indexWhere((element) => element.name == msg.message);

      if (msgData.type == GiftTokenEnum.giftToken.name) {
        final amount = msgData.message!.getInt;
        hostGiftAmountTotal.value = hostGiftAmountTotal.value + amount;
        coinsAnimationList.value = coinsAnimationList.value + 1;
      }

      if (msgData.type == 'system' &&
          (msgData.message?.contains('joined the live session') ?? false)) {
        hitParticipantsList(roomId!);
      }

      final index = chatList.indexWhere((element) => element.id == msgData.id);
      if (index > -1) {
        chatList[index] = msgData;
      } else {
        chatList.add(msgData);
      }
      chatList.refresh();
      AppUtils.log({
        'channel': 'onMessageReceive',
        'data': data,
      }, show: _showLog);
      _repo.unsubscribe(SocketKey.chatError);

      if (msgData.type == 'liveRequest' && !liveStreamCtrl.isHost) {
        final data = chatList.firstWhereOrNull(
          (element) =>
              element.message == LiveRequestStatus.requested.name &&
              element.userId == Preferences.uid,
        );
        liveStreamCtrl.videoRequestButtonEnable.value = data == null;
        liveStreamCtrl.videoRequestButtonEnable.refresh();
      }
    });

    // flutter: │ 🐛 {
    // flutter: │ 🐛   "type": "LISTENER Socket",
    // flutter: │ 🐛   "event": "newChatMessage",
    // flutter: │ 🐛   "data": {
    // flutter: │ 🐛     "id": "msg_1756804455694_68ac3622e8dc5a68b07d94f1",
    // flutter: │ 🐛     "type": "liveRequest",
    // flutter: │ 🐛     "message": "requested",
    // flutter: │ 🐛     "timestamp": "2025-09-02T09:14:15.694Z",
    // flutter: │ 🐛     "userId": "68ac3622e8dc5a68b07d94f1",
    // flutter: │ 🐛     "userName": "test",
    // flutter: │ 🐛     "userRole": "participant",
    // flutter: │ 🐛     "participantCount": 2
    // flutter: │ 🐛   }
    // flutter: │ 🐛 }
  }

  void _updateHostOnJoin(Map<String, dynamic> data) {
    _onNewParticipantJoined();

    AppUtils.log('_updateHostOnJoin');
    roomId = data['roomId'];
    AppUtils.log({'channel': 'onLiveJoined', 'data': data}, show: _showLog);
    final participants = List<Map<String, dynamic>>.from(
      data['participants'] ?? [],
    );
    _addUsersToMappingList(participants);
    _liveCount.value = data['participantCount'] ?? 0;
  }

  void _onJoin() {
    _repo.onLiveJoined((data) {
      _repo.unsubscribe(SocketKey.liveJoined);
      _updateHostOnJoin(data);
      AppUtils.logg('onLiveJoined');
      AppUtils.logg(data);
    });
    _repo.onLiveStart((data) {
      AppUtils.logg('onLiveStart');
      AppUtils.logg(data);
      _updateHostOnJoin(data);
      _repo.unsubscribe(SocketKey.startLive);
      updateLiveBroadCasterCountByHost(liveStreamCtrl.getBroadcasters.length);
    });
  }

  void _onError() {
    _repo.onLiveError((data) {
      AppUtils.logEr({'channel': 'onLiveError', 'data': data}, show: _showLog);

      // flutter: \^[[38;5;196m│ ⛔ {<…>
      // flutter: \^[[38;5;196m│ ⛔   "channel": "onLiveError",<…>
      // flutter: \^[[38;5;196m│ ⛔   "data": {<…>
      // flutter: \^[[38;5;196m│ ⛔     "message": "You are already hosting a live session",<…>
      // flutter: \^[[38;5;196m│ ⛔     "type": "ALREADY_HOSTING"<…>
      // flutter: \^[[38;5;196m│ ⛔   }<…>
      // flutter: \^[[38;5;196m│ ⛔ }<…>
    });
  }

  void leaveRoom() {
    if (liveStreamCtrl.videoRequestButtonEnable.isFalse) {
      final data = chatList.firstWhereOrNull(
        (element) =>
            element.userId == Preferences.uid &&
            element.message == LiveRequestStatus.requested.name &&
            element.type == 'liveRequest',
      );
      if (data != null) {
        hostRequestActive(LiveRequestStatus.leave, data.id!, data.userId!);
      }
    }
    hostGiftAmountTotal.value = 0;
    chatList.clear();
    _repo.leave();
    _repo.removeListenersOnLeaveLiveStream();
    _incomingLiveRequestToHostController.close();
  }

  void _onUserJoinedLive() {
    _repo.onUserJoinedLive((data) {
      AppUtils.log({
        'channel': 'onUserJoinedLive',
        'data': data,
      }, show: _showLog);
      // flutter: │ 🐛 {
      // flutter: │ 🐛   "channel": "onUserJoinedLive",
      // flutter: │ 🐛   "data": {
      // flutter: │ 🐛     "userId": "683a8cc26a337827c39db2ef",
      // flutter: │ 🐛     "userName": "testing live",
      // flutter: │ 🐛     "participantCount": 2,
      // flutter: │ 🐛     "totalJoined": 2,
      // flutter: │ 🐛     "joinedAt": "2025-07-23T09:11:05.856Z",
      // flutter: │ 🐛     "message": "testing live joined the live session"
      // flutter: │ 🐛   }
      // flutter: │ 🐛 }
      liveStreamCtrl.liveUsers.add(data);
    });
  }

  void _onUserLeave() {
    _repo.onUserLeftLive((data) {
      AppUtils.log({'channel': 'onUserLeftLive', 'data': data}, show: _showLog);

      liveStreamCtrl.liveUsers.removeWhere(
        (element) => element['userId'] == data['userId'],
      );

      // flutter: │ 🐛 {
      // flutter: │ 🐛   "channel": "onUserLeftLive",
      // flutter: │ 🐛   "data": {
      // flutter: │ 🐛     "userId": "683a8cc26a337827c39db2ef",
      // flutter: │ 🐛     "userName": "testing live",
      // flutter: │ 🐛     "participantCount": 1,
      // flutter: │ 🐛     "totalJoined": 2,
      // flutter: │ 🐛     "leftAt": "2025-07-23T09:12:04.475Z",
      // flutter: │ 🐛     "message": "testing live left the live session"
      // flutter: │ 🐛   }
      // flutter: │ 🐛 }
    });
  }

  void _onLiveEnded() {
    _repo.onLiveEnded((data) {
      AppUtils.log({'channel': 'onLiveEnded', 'data': data}, show: _showLog);

      //  {
      //    "channel": "onLiveEnded",
      //    "data": {
      //      "message": "Live session ended successfully",
      //      "endTime": "2025-07-08T07:23:27.628Z",
      //      "duration": 110,
      //      "totalParticipants": 1
      //    }
      //  }
      leaveRoom();
    });
  }

  void _onChatError() {
    _repo.onChatError((data) {
      AppUtils.logEr({'channel': 'onChatError', 'data': data}, show: _showLog);
    });
  }

  void _onParticipantsCount() {
    _repo.onParticipantsCount((data) {
      AppUtils.log('onParticipantsCount');
      AppUtils.logg('onParticipantsCount');
      AppUtils.logg(data);
      _liveCount.value = data['participantCount'] ?? _liveCount.value;

      // List<Map<String,dynamic>> list = data['participants']  ?? <Map<String,dynamic>>[] ;
      // final participants = (data['participants'] as List)
      //     .map((e) => e as Map<String, dynamic>)
      //     .toList();

      List<Map<String, dynamic>> list =
          (data['participants'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          <Map<String, dynamic>>[];

      _addUsersToMappingList(list);

      // "roomId": "live_683a8cc26a337827c39db2ef_1755090027801",
      // flutter: │ 🐛     "participantCount": 2,
      // flutter: │ 🐛     "totalJoined": 3,
      // flutter: │ 🐛     "participants": [
      // flutter: │ 🐛       {
      // flutter: │ 🐛         "id": "683a8cc26a337827c39db2ef",
      // flutter: │ 🐛         "name": "testing live",
      // flutter: │ 🐛         "joinedAt": "2025-08-13T13:00:27.801Z",
      // flutter: │ 🐛         "role": "host"
      // flutter: │ 🐛       },
      // flutter: │ 🐛       {
      // flutter: │ 🐛         "id": "687a274d642948724b3e7ca2",
      // flutter: │ 🐛         "name": "test ios 2",
      // flutter: │ 🐛         "joinedAt": "2025-08-13T13:01:31.111Z",
      // flutter: │ 🐛         "role": "participant"
      // flutter: │ 🐛       }
      // flutter: │ 🐛     ]
    });

    // ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄<…>
    // flutter: \^[[38;5;196m│ ⛔ {<…>
    // flutter: \^[[38;5;196m│ ⛔   "channel": "liveUserCountUpdate",<…>
    // flutter: \^[[38;5;196m│ ⛔   "data": {<…>
    // flutter: \^[[38;5;196m│ ⛔     "participantCount": 2<…>
    // flutter: \^[[38;5;196m│ ⛔   }<…>
    // flutter: \^[[38;5;196m│ ⛔ }<…>
  }

  void _addUsersToMappingList(List<Map<String, dynamic>> list) {
    for (var user in list) {
      // liveStreamCtrl.addUserIdToMappingList(user['id'], json: user);
      liveStreamCtrl.addUserIdToMappingList(user['id'], json: user);
    }

    final hostEntry = list.firstWhereOrNull(
      (e) =>
          e['role'] == 'host' &&
          e['id'] == liveStreamCtrl.streamCtrl.value.channelId,
    );

    if (hostEntry != null) {
      final updatedHost = liveStreamCtrl.hostProfileData.value.copyWith(
        name: hostEntry['name'] ?? '',
        id: hostEntry['id'] ?? '',
        image: hostEntry['image'],
      );

      liveStreamCtrl.hostProfileData.value = updatedHost;
      liveStreamCtrl.hostProfileData.refresh();
    }
  }
}

// liveEnded
//chatError

class LiveStreamChannelModel {
  String? channelId;
  String? hostId;
  String? hostName;
  String? hostImage;

  // flutter: │ 🐛       {
  // flutter: │ 🐛         "userId": "687a274d642948724b3e7ca2",
  // flutter: │ 🐛         "name": "test ios 2",
  // flutter: │ 🐛         "username": "",
  // flutter: │ 🐛         "image": "",
  // flutter: │ 🐛         "bio": "",
  // flutter: │ 🐛         "roomId": "live_687a274d642948724b3e7ca2_1753088313817",
  // flutter: │ 🐛         "participantCount": 1,
  // flutter: │ 🐛         "totalJoined": 1,
  // flutter: │ 🐛         "startTime": "2025-07-21T08:58:33.817Z",
  // flutter: │ 🐛         "duration": 1,
  // flutter: │ 🐛         "isOnline": true,
  // flutter: │ 🐛         "socketId": null,
  // flutter: │ 🐛         "hasSocket": false
  // flutter: │ 🐛       }

  LiveStreamChannelModel({
    this.channelId,
    this.hostName,
    this.hostId,
    this.hostImage,
  });

  factory LiveStreamChannelModel.fromJson(Map<String, dynamic> json) =>
      LiveStreamChannelModel(
        hostId: json['userId'],
        hostName: json['name'],
        channelId: json['roomId'],
        hostImage: json['image'],
      );
}
