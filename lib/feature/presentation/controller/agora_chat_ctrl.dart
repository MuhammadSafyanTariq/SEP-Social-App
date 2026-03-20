import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:sep/feature/data/repository/i_agora_chat_repo.dart';
import 'package:sep/feature/domain/respository/agora_chat_repo.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/feature/presentation/liveStreaming_screen/live_stream_ctrl.dart';
import 'package:sep/components/coreComponents/sep_image_filter.dart';
import 'package:sep/main.dart';
import 'package:sep/services/socket/socket_helper.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';

import '../../../services/networking/urls.dart';
import '../../data/models/dataModels/live_stream_message_model/live_stream_message_model.dart';
import '../liveStreaming_screen/broad_cast_video.dart';
import '../widgets/gift_effects_overlay.dart';

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

class LiveGiftOverlayConfig {
  final String giftCode;
  final String? giftLabel;
  final String? senderName;

  const LiveGiftOverlayConfig({
    required this.giftCode,
    this.giftLabel,
    this.senderName,
  });
}

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
  // Context from the currently visible live video frame; used for gift overlays.
  BuildContext? liveOverlayContext;
  String? roomId;
  String? hostId;
  RxInt coinsAnimationList = RxInt(0);
  Rx<LiveGiftOverlayConfig?> currentLiveGiftOverlay =
      Rx<LiveGiftOverlayConfig?>(null);

  final RxInt _liveCount = RxInt(0);

  String get liveCountValue => '${_liveCount.value}';

  bool chatConnection = false;

  RxInt hostGiftAmountTotal = RxInt(0);

  RxList<LiveStreamMessageModel> chatList = RxList();

  // Live gifts over Socket.IO
  IO.Socket? _liveGiftSocket;
  RxDouble liveGiftTotalAmount = 0.0.obs;
  RxInt liveGiftTotalCount = 0.obs;

  // Get the current live stream title from backend data only
  String get currentStreamTitle {
    // Access the reactive variable first to ensure reactivity
    final roomInfo = currentLiveRoomInfo.value;
    final channels = liveStreamChannels;
    final currentChannelId = liveStreamCtrl.streamCtrl.value.channelId;

    AppUtils.log('🔍 Getting currentStreamTitle...');
    AppUtils.log('📊 currentLiveRoomInfo.value: $roomInfo');
    AppUtils.log('📋 liveStreamChannels.length: ${channels.length}');
    AppUtils.log('🆔 current channelId: $currentChannelId');

    // First priority: Current live room info from backend
    final backendTitle = roomInfo?['title'];
    AppUtils.log('🎯 Backend title from currentLiveRoomInfo: "$backendTitle"');
    if (backendTitle != null && backendTitle.toString().isNotEmpty) {
      AppUtils.log('✅ Returning backend title: "${backendTitle.toString()}"');
      return backendTitle.toString();
    }

    // Second priority: Channel list data from backend
    if (currentChannelId != null) {
      final currentChannel = channels.firstWhereOrNull(
        (channel) => channel.channelId == currentChannelId,
      );
      AppUtils.log('📺 Channel found: ${currentChannel?.title}');
      if (currentChannel?.title != null && currentChannel!.title!.isNotEmpty) {
        AppUtils.log('✅ Returning channel title: "${currentChannel.title!}"');
        return currentChannel.title!;
      }
    }

    // No title available from backend
    AppUtils.log('❌ No title available, returning empty string');
    return '';
  }

  // Temporary getter to fix the missing liveStreamTopic error
  // This should be removed once we identify where it's being called from
  String get liveStreamTopic {
    AppUtils.log('liveStreamTopic getter called - this should be replaced!');
    return currentStreamTitle;
  }

  // Debug method to test title retrieval
  void debugTitleData() {
    AppUtils.log('=== DEBUG TITLE DATA ===');
    AppUtils.log('currentLiveRoomInfo: ${currentLiveRoomInfo.value}');
    AppUtils.log('liveStreamChannels count: ${liveStreamChannels.length}');
    for (var i = 0; i < liveStreamChannels.length; i++) {
      final ch = liveStreamChannels[i];
      AppUtils.log('Channel $i: id=${ch.channelId}, title=${ch.title}');
    }
    AppUtils.log('currentStreamTitle getter returns: "${currentStreamTitle}"');
    AppUtils.log('========================');
  }

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

  void connectAndJoin(String hostId, String username, {String? title}) {
    // _chatConnection = false;
    AppUtils.log('connectAndJoin called with title: $title');
    connect(() {
      if (chatConnection) {
        AppUtils.log('go back');
        return;
      } else {
        AppUtils.log('continue');
        chatConnection = true;
        this.hostId = hostId;
        AppUtils.log('About to callStart with title: $title');
        callStart(title: title);
      }
      // _onConnect();
      return;
    });
  }

  //----------------------------------------------------------------------------
  // Live gift socket (USD gift system, separate from token-based chat)
  //----------------------------------------------------------------------------

  void connectLiveGiftSocket() {
    if (_liveGiftSocket != null && _liveGiftSocket!.connected) {
      return;
    }

    _liveGiftSocket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    _liveGiftSocket!.onConnect((_) {
      AppUtils.log('Live gift socket connected');
    });

    _liveGiftSocket!.onDisconnect((_) {
      AppUtils.log('Live gift socket disconnected');
    });

    _registerGiftListeners();
  }

  void _registerGiftListeners() {
    final socket = _liveGiftSocket;
    if (socket == null) return;

    socket.on('giftReceived', (data) {
      AppUtils.log({
        'event': 'giftReceived',
        'data': data,
        'viewer_debug': {
          'isHost': liveStreamCtrl.isHost,
          'clientRole': liveStreamCtrl.streamCtrl.value.clientRole?.name,
          'uid': Preferences.uid,
        },
      });

      final amount = (data['amount'] ?? 0).toString().getDouble ?? 0.0;
      liveGiftTotalAmount.value = (liveGiftTotalAmount.value) + amount;
      // Show visual gift effect for everyone in the room.
      try {
        final giftName = data['giftName']?.toString();
        final senderName = data['senderName']?.toString();
        if (giftName != null && giftName.isNotEmpty) {
          // When the live screen is active, drive the local overlay layer
          // instead of inserting a global OverlayEntry so chat stays on top.
          if (liveOverlayContext != null) {
            currentLiveGiftOverlay.value = LiveGiftOverlayConfig(
              giftCode: giftName,
              giftLabel: giftName,
              senderName: senderName,
            );
          } else {
            final ctx = Get.context ?? navState.currentContext;
            if (ctx != null) {
              showGiftEffectOverlay(
                ctx,
                giftCode: giftName,
                giftLabel: giftName,
                senderName: senderName,
              );
            }
          }
        }
      } catch (_) {}

      // Reuse existing animation counter for coin animation visual feedback.
      try {
        coinsAnimationList.value = coinsAnimationList.value + 1;
      } catch (e, stack) {
        AppUtils.logEr(
          {
            'channel': 'liveCoinAnimationError',
            'error': e.toString(),
            'stack': stack.toString(),
          },
          show: _showLog,
        );
      }
    });

    socket.on('liveGiftUpdate', (data) {
      AppUtils.log({'event': 'liveGiftUpdate', 'data': data});
      final total = (data['totalGifts'] ?? 0).toString().getDouble ?? 0.0;
      final count = (data['totalGiftCount'] ?? 0) as int? ?? 0;
      liveGiftTotalAmount.value = total;
      liveGiftTotalCount.value = count;
      hostGiftAmountTotal.value = total.toInt();
    });

    socket.on('giftSent', (data) {
      AppUtils.log({'event': 'giftSent', 'data': data});
      // Update local coin balance per guide: use senderNewTokenBalance
      final newBalanceRaw = data['senderNewTokenBalance'];
      if (newBalanceRaw != null) {
        final newTokens = newBalanceRaw is num
            ? newBalanceRaw.toInt()
            : int.tryParse(newBalanceRaw.toString());
        if (newTokens != null) {
          try {
            final profileCtrl = ProfileCtrl.find;
            final updated = profileCtrl.profileData.value.copyWith(
              walletTokens: newTokens,
            );
            profileCtrl.profileData.value = updated;
            profileCtrl.profileData.refresh();
            Preferences.profile = updated;
            Preferences.savePrefOnLogin = updated;
          } catch (_) {}
        }
      }
    });

    socket.on('giftReceivedPersonal', (data) {
      AppUtils.log({
        'event': 'giftReceivedPersonal',
        'data': data,
        'viewer_debug': {
          'isHost': liveStreamCtrl.isHost,
          'clientRole': liveStreamCtrl.streamCtrl.value.clientRole?.name,
          'uid': Preferences.uid,
        },
      });

      // Prefer backend-provided message in the golden bottom banner instead of a toast.
      var backendMessage = data['message']?.toString();
      // Strip amount like " ($0.48)" from the end, if present.
      if (backendMessage != null) {
        final idx = backendMessage.indexOf(' (\$');
        if (idx > 0) {
          backendMessage = backendMessage.substring(0, idx);
        }
      }

      // Show the full-screen gift animation for the receiver.
      try {
        final giftName = data['giftName']?.toString();
        if (giftName != null && giftName.isNotEmpty) {
          // If we're on the live screen, drive a local overlay layer instead
          // of pushing a global OverlayEntry above the entire UI. This keeps
          // chat/messages visually on top of the SVGA animations.
          if (liveOverlayContext != null) {
            currentLiveGiftOverlay.value = LiveGiftOverlayConfig(
              giftCode: giftName,
              giftLabel:
                  (backendMessage != null && backendMessage.isNotEmpty)
                      ? backendMessage
                      : giftName,
              senderName: null,
            );
          } else {
            final ctx = Get.context ?? navState.currentContext;
            if (ctx != null) {
              showGiftEffectOverlay(
                ctx,
                giftCode: giftName,
                giftLabel:
                    (backendMessage != null && backendMessage.isNotEmpty)
                        ? backendMessage
                        : giftName,
                senderName: null,
              );
            }
          }
        }
      } catch (_) {}
    });

    socket.on('giftError', (data) {
      AppUtils.log({'event': 'giftError', 'data': data});
      final msg =
          data['message']?.toString() ?? 'Unable to send live gift right now';
      AppUtils.toastError(msg);
    });
  }

  void sendLiveGift({required String giftName}) {
    // Ensure socket is created and connecting; allow socket_io_client to queue emissions
    if (_liveGiftSocket == null) {
      connectLiveGiftSocket();
    }

    final socket = _liveGiftSocket;
    if (socket == null) {
      AppUtils.toastError('Unable to connect to live gifts');
      return;
    }

    final senderId = Preferences.uid;
    final room = roomId ?? liveStreamCtrl.streamCtrl.value.channelId ?? '';
    final receiver = hostId ?? liveStreamCtrl.hostProfileData.value.id ?? '';

    if (senderId == null ||
        senderId.isEmpty ||
        room.isEmpty ||
        receiver.isEmpty) {
      AppUtils.toastError('Unable to send live gift - invalid session');
      return;
    }

    final payload = {
      'senderId': senderId,
      'receiverId': receiver,
      'roomId': room,
      'giftName': giftName,
    };

    AppUtils.log({'event': 'sendGiftLive', 'data': payload});
    socket.emit('sendGiftLive', payload);
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

  // Store current live room info
  Rx<Map<String, dynamic>?> currentLiveRoomInfo = Rx<Map<String, dynamic>?>(
    null,
  );

  void onLiveStreamChannelList() {
    _repo.onLiveStreamChannelList((data) {
      AppUtils.log('liveChannelsdata ::: ::::::::');
      AppUtils.log(data);
      if (data['code'] == 200) {
        final liveFollowersData = data['data']?['liveFollowers'] ?? [];
        AppUtils.log('Raw live followers data:');
        AppUtils.log(liveFollowersData);

        final list = List<LiveStreamChannelModel>.from(
          liveFollowersData.map((json) {
            AppUtils.log(
              'Processing channel: ${json['roomId']}, title: ${json['title']}',
            );
            return LiveStreamChannelModel.fromJson(json);
          }),
        );
        liveStreamChannels.assignAll(list);

        // Log final parsed channels with titles
        for (var channel in liveStreamChannels) {
          AppUtils.log(
            'Channel ${channel.channelId} has title: ${channel.title}',
          );
        }
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

  void onLiveRoomInfo() {
    AppUtils.log(
      '🔧🔧🔧 REGISTERING onLiveRoomInfo listener - VERSION 2 🔧🔧🔧',
    );

    // Force unsubscribe first to clear any old handlers
    try {
      _repo.unsubscribe(SocketKey.liveRoomInfo);
      AppUtils.log('🧹 Old liveRoomInfo handler unsubscribed');
    } catch (e) {
      AppUtils.log('⚠️ No old handler to unsubscribe: $e');
    }

    _repo.onLiveRoomInfo((data) {
      AppUtils.log(
        '🚨🚨🚨 NEW HANDLER TRIGGERED - DATA RECEIVED - VERSION 2 🚨🚨🚨',
      );
      try {
        AppUtils.log('=== onLiveRoomInfo HANDLER CALLED ===');
        AppUtils.log('=== onLiveRoomInfo START ===');
        AppUtils.log('Raw data: $data');
        AppUtils.log('Data type: ${data.runtimeType}');

        // Backend sends direct response without code/data wrapper
        if (data != null && data is Map<String, dynamic>) {
          AppUtils.log('✅ Valid data received, processing...');

          // Extract and log the title before assignment
          final title = data['title'];
          AppUtils.log('📝 Title from backend: "$title"');

          // Store the data
          currentLiveRoomInfo.value = data;
          AppUtils.log('💾 Data stored in currentLiveRoomInfo');

          // Force refresh
          currentLiveRoomInfo.refresh();
          AppUtils.log('🔄 Refreshed reactive variable');

          // Test the getter immediately
          final currentTitle = currentStreamTitle;
          AppUtils.log('🎯 Current title via getter: "$currentTitle"');

          AppUtils.log('✅ onLiveRoomInfo processing complete');
        } else {
          AppUtils.log('❌ Invalid or null data received for live room info');
        }
        AppUtils.log('=== onLiveRoomInfo END ===');
      } catch (e, stackTrace) {
        AppUtils.log('💥 ERROR in onLiveRoomInfo: $e');
        AppUtils.log('Stack trace: $stackTrace');
      }
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
    void navigateIfRoomExists() async {
      checkIfRoomExist(data.channelId!, data.hostId!, (
        exists,
        broadcasters,
      ) async {
        if (exists) {
          final newRole = broadcasters < broadCastUserMaxLimit
              ? (role ?? ClientRoleType.clientRoleAudience)
              : ClientRoleType.clientRoleAudience;

          AppUtils.log({
            'newRole ': newRole.name,
            'live': broadcasters,
            'max': broadCastUserMaxLimit,
          });

          // Check permissions before joining live stream
          final hasPermissions = await StreamUtils.checkPermission();
          if (!hasPermissions) {
            AppUtils.toastError(
              'Camera and Microphone permissions are required to join live stream',
            );
            return;
          }

          navState.currentContext!
              .pushNavigator(
                BroadCastVideo(
                  clientRole: newRole,
                  hostId: data.hostId,
                  hostName: data.hostName,
                  title: data.title,
                ),
              )
              .then(call);
        } else {
          AppUtils.toastError('Live stream ended!');
        }
      });
    }

    if (!isConnected) {
      AppUtils.log('rgregregergreg');
      connect(() {
        if (!isConnected) {
          isConnected = true;
          navigateIfRoomExists();
        }
      });
    } else {
      AppUtils.log('hkjyhjghjhgjgh');
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

  void callStart({String? title}) {
    // if (role == ClientRoleType.clientRoleBroadcaster) {
    if (liveStreamCtrl.isHost) {
      _startLive(title: title);
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
    onLiveRoomInfo();
  }

  void _startLive({String? title}) {
    AppUtils.log('emit-----_startLive with title: $title');
    _repo.startLive(title: title);
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

  /// Broadcast host's selected live filter preset index to all participants.
  void sendLiveFilterPreset(int index) {
    _sendMsg({
      "message": index.toString(),
      "type": "liveFilter",
      "roomId": roomId,
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

      if (msgData.type == "liveFilter") {
        final idx = int.tryParse(msgData.message ?? '');
        if (idx != null &&
            idx >= 0 &&
            idx < EnhancementPresets.names.length) {
          liveStreamCtrl.setLiveFilterIndex(idx);
        }
      } else if (msgData.type == GiftTokenEnum.giftToken.name) {
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
    AppUtils.log('Complete join data: $data');

    roomId = data['roomId'];
    AppUtils.log('RoomId set to: $roomId');
    AppUtils.log('HostId is: $hostId');

    // Check if title is already in the join response
    final titleInJoinData = data['title'];
    AppUtils.log('Title in join data: $titleInJoinData');

    AppUtils.log({'channel': 'onLiveJoined', 'data': data}, show: _showLog);
    final participants = List<Map<String, dynamic>>.from(
      data['participants'] ?? [],
    );
    _addUsersToMappingList(participants);
    _liveCount.value = data['participantCount'] ?? 0;

    // Fetch live room info to get the title from backend
    if (roomId != null && hostId != null) {
      AppUtils.log(
        'Fetching live room info for roomId: $roomId, hostId: $hostId',
      );
      _repo.getLiveRoomInfo(hostId!, roomId!);
    } else {
      AppUtils.log('Cannot fetch room info - roomId: $roomId, hostId: $hostId');
    }
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
      AppUtils.logg('Complete onLiveStart data:');
      AppUtils.logg(data);

      // Check if title is in the start response
      final titleInStartData = data['title'];
      AppUtils.log('Title in onLiveStart data: $titleInStartData');

      _updateHostOnJoin(data);
      _repo.unsubscribe(SocketKey.startLive);
      updateLiveBroadCasterCountByHost(liveStreamCtrl.getBroadcasters.length);

      // For host: also fetch room info to get the title after starting live
      if (liveStreamCtrl.isHost && roomId != null && hostId != null) {
        AppUtils.log('Host started live, fetching room info for title...');
        _repo.getLiveRoomInfo(hostId!, roomId!);
      }
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
  String? title;

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
    this.title,
  });

  factory LiveStreamChannelModel.fromJson(Map<String, dynamic> json) =>
      LiveStreamChannelModel(
        hostId: json['userId'],
        hostName: json['name'],
        channelId: json['roomId'],
        hostImage: json['image'],
        title: json['title'],
      );
}
