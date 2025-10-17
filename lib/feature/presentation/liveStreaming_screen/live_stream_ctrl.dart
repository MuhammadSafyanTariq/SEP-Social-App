import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/main.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';

import '../../../services/networking/urls.dart';
import '../../../services/storage/preferences.dart';
import '../../data/models/dataModels/profile_data/profile_data_model.dart';
import '../../data/models/dataModels/responseDataModel.dart';
import '../helpers/token_transfer_helper.dart';
import '../controller/agora_chat_ctrl.dart';
import '../controller/auth_Controller/auth_ctrl.dart';

bool _showLog = true;

int broadCastUserMaxLimit = 6;

enum AgoraUserLiveStatus { offLine, liveBroadCaster, liveAudience, invited }

extension OnAgoraUserLiveStatus on AgoraUserLiveStatus {
  String get statusValue {
    switch (this) {
      case AgoraUserLiveStatus.offLine:
        return 'Off Line';
      case AgoraUserLiveStatus.liveBroadCaster:
        return 'Live (Co Host)';
      case AgoraUserLiveStatus.liveAudience:
        return 'Live';
      case AgoraUserLiveStatus.invited:
        return 'Invitation Sent';
    }
  }
}

class StreamControlsModel {
  ClientRoleType? clientRole;
  Set<RemoteUserAgora>? remoteIds;
  String? channelId;
  LocalAudioStreamState? localMicState;
  LocalVideoStreamState? localVideoState;
  bool enginePreviewState;
  bool localChannelJoined;

  StreamControlsModel({
    this.remoteIds,
    this.clientRole,
    this.channelId,
    this.localMicState,
    this.localVideoState,
    this.enginePreviewState = false,
    this.localChannelJoined = false,
  });

  RemoteUserAgora? get localUser {
    if (clientRole == ClientRoleType.clientRoleBroadcaster) {
      return RemoteUserAgora(id: 0);
    }
    return null;
  }
}

class StreamUtils {
  /// Requests camera and microphone permissions.
  /// Opens app settings if any permission is permanently denied.
  /// Returns `true` if both are granted.
  static Future<bool> checkPermission() async {
    final cameraStatus = await Permission.camera.status;
    final micStatus = await Permission.microphone.status;

    AppUtils.log("Camera status: $cameraStatus", show: _showLog);
    AppUtils.log("Mic status: $micStatus", show: _showLog);

    final camera = await Permission.camera.request();
    final mic = await Permission.microphone.request();

    AppUtils.log("Camera after request: $camera", show: _showLog);
    AppUtils.log("Mic after request: $mic", show: _showLog);

    if (camera.isGranted && mic.isGranted) return true;

    if (camera.isPermanentlyDenied || mic.isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
  }

  /// Logs info messages if [_showLog] is enabled.
  static void log(String key, String value) {
    AppUtils.log("$key :: $value", show: _showLog);
  }

  /// Logs error messages if [_showLog] is enabled.
  static void logEr(String key, String value) {
    AppUtils.logEr("$key :: $value", show: _showLog);
  }

  /// Registers all event handlers for Agora RtcEngine.
  static void registerEventHandlers(
    RtcEngine engine, {
    void Function(RemoteUserAgora)? onRemoteUserJoined,
    void Function(RemoteUserAgora)? onRemoteVideoStateChanged,
    void Function(RemoteUserAgora)? onRemoteAudioStateChanged,
    void Function(RemoteUserAgora)? onRemoteUserOffline,
    void Function(LocalAudioStreamState)? onLocalMicStateChange,
    void Function(LocalVideoStreamState)? onLocalVideoStateChange,
    void Function()? onLocalJoinChannel,
    void Function(ClientRoleType)? onClientRoleChanged,
  }) {
    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          onLocalJoinChannel?.call();
          log('onJoinChannelSuccess', 'Channel: ${connection.channelId}');
        },
        onUserJoined: (connection, uid, elapsed) {
          onRemoteUserJoined?.call(
            RemoteUserAgora(
              id: uid,
              audioState: RemoteAudioState.remoteAudioStateStarting,
              videoState: RemoteVideoState.remoteVideoStateStarting,
              channelId: connection.channelId,
            ),
          );
        },
        onUserOffline: (connection, uid, reason) {
          onRemoteUserOffline?.call(RemoteUserAgora(id: uid));
          log('onUserOffline', 'UID: $uid, Reason: ${reason.name}');
        },
        onLocalAudioStateChanged: (connection, state, reason) {
          onLocalMicStateChange?.call(state);
        },
        onLocalVideoStateChanged: (source, state, reason) {
          onLocalVideoStateChange?.call(state);
        },
        onRemoteAudioStateChanged:
            (connection, remoteUid, state, reason, elapsed) {
              onRemoteAudioStateChanged?.call(
                RemoteUserAgora(id: remoteUid, audioState: state),
              );
            },
        onRemoteVideoStateChanged:
            (connection, remoteUid, state, reason, elapsed) {
              onRemoteVideoStateChanged?.call(
                RemoteUserAgora(id: remoteUid, videoState: state),
              );
            },
        onConnectionStateChanged: (connection, state, reason) {
          log(
            'ConnectionState',
            'State: ${state.name}, Reason: ${reason.name}',
          );
        },
        onClientRoleChanged: (connection, oldRole, newRole, _) {
          onClientRoleChanged?.call(newRole);
          log('RoleChanged', '${oldRole.name} -> ${newRole.name}');
        },
        onConnectionInterrupted: (connection) {
          logEr('ConnectionInterrupted', '${connection.toJson()}');
        },
        onConnectionLost: (connection) {
          logEr('ConnectionLost', '${connection.toJson()}');
        },
        onError: (err, msg) {
          AppUtils.logEr({
            'type': 'AgoraError',
            'name': err.name,
            'value': err.value(),
            'message': msg,
          }, show: _showLog);
        },
      ),
    );
  }
}

class LiveStreamCtrl extends GetxController {
  ///---------------------------------------------------------------------------
  /// objects and instances....
  late RtcEngine engine;
  static LiveStreamCtrl get find => Get.isRegistered<LiveStreamCtrl>()
      ? Get.find<LiveStreamCtrl>()
      : Get.put(LiveStreamCtrl());
  final RxList<Map<String, dynamic>> liveUsers = RxList([]);
  RxList<ProfileDataModel> invitedUsers = RxList([]);
  final List<Map<String, dynamic>> _userIdsMapping = [];
  final Rx<StreamControlsModel> streamCtrl = Rx(StreamControlsModel());
  Rx<ProfileDataModel> hostProfileData = Rx(ProfileDataModel());
  RxBool videoRequestButtonEnable = RxBool(true);

  ///---------------------------------------------------------------------------
  /// getters.......
  bool get isHost => streamCtrl.value.channelId == Preferences.uid;
  int get hostAgoraId => getNumericUserId(uid: streamCtrl.value.channelId);
  List<ProfileDataModel> get _friendList => ProfileCtrl.find.myFollowingList;
  List<RemoteUserAgora> get getBroadcasters {
    final remoteList = streamCtrl.value.remoteIds ?? <RemoteUserAgora>{};

    final remote = remoteList.toList();
    final localUser = streamCtrl.value.localUser;

    // Remove 0 if it's somehow already in remote IDs
    remote.removeWhere((element) => element.id == 0);

    // Limit remote list to max 6, or 5 if local broadcaster to make space for 0
    final maxRemote = localUser != null ? 5 : 6;
    final limitedRemote = remote.take(maxRemote).toList();

    // Append 0 at end if local broadcaster
    if (localUser != null) {
      limitedRemote.add(localUser);
    }

    AppUtils.log('broadCaster length :: ${limitedRemote.length}');

    return limitedRemote;
  }

  List<Map<String, dynamic>> get getBroadcastersIds {
    List<Map<String, dynamic>> list = [];
    for (var user in getBroadcasters) {
      final data = _userIdsMapping.firstWhereOrNull(
        (element) => element['agoraId'] == user.id,
      );
      if (data != null) {
        list.add(data);
      }
    }

    return list;
  }

  List<ProfileDataModel> get getLiveBroadcastersVisibleToHost {
    if (isHost) {
      final broadcasterIds = getBroadcasters.map((e) => e.id).toSet();
      return liveUsers
          .map((json) => json.agoraLiveUserJsonToProfileModel)
          .where((profile) => broadcasterIds.contains(profile.agoraId))
          .toList();
    }
    return [];
  }

  ///---------------------------------------------------------------------------
  /// core methods.......
  static Future<bool> get clear => Get.delete<LiveStreamCtrl>();

  ///---------------------------------------------------------------------------
  /// methods.........

  Map<String, dynamic>? getUserById(String? uid) {
    AppUtils.log(_userIdsMapping);
    return _userIdsMapping.firstWhereOrNull((e) => e['uid'] == uid)?['data'];
  }

  void addUserIdToMappingList(String uid, {Map<String, dynamic>? json}) {
    if (_userIdsMapping.firstWhereOrNull((e) => e['uid'] == uid) == null) {
      _userIdsMapping.add({
        'uid': uid,
        'agoraId': getNumericUserId(uid: uid),
        'data': json,
      });
    } else {
      final index = _userIdsMapping.indexWhere((e) => e['uid'] == uid);
      if (index > -1) {
        var dd = _userIdsMapping[index];
        dd['data'] = json;
        _userIdsMapping[index] = dd;
      }
    }

    AppUtils.log(_userIdsMapping);
  }

  /// Invite a friend to the live stream
  Future<void> inviteForLive(ProfileDataModel user) async {
    // Validate required data
    if (user.id == null || user.id!.isEmpty) {
      throw Exception('Invalid user ID');
    }

    if (Preferences.uid == null || Preferences.uid!.isEmpty) {
      throw Exception('Current user not authenticated');
    }

    if (AgoraChatCtrl.find.roomId?.isEmpty != false) {
      throw Exception('Live stream not properly initialized');
    }

    // Send both chat message and API notification
    AgoraChatCtrl.find.sendLiveRequestToFriendByHost(user.id!);

    // Send proper invite notification via API
    final result = await AuthCtrl.find.getRepo.post(
      url: Urls.inviteFriendToLiveStream,
      enableAuthToken: true,
      data: {
        "type": "inviteForLive",
        "sentTo": user.id,
        "sentBy": Preferences.uid,
        "channelId": AgoraChatCtrl.find.roomId,
        "message":
            '${Preferences.profile?.name ?? 'User'} invited you to join live video session',
      },
    );

    AppUtils.log('Invite API Response: ${result.toString()}');

    if (result.isSuccess) {
      invitedUsers.add(user);
      AppUtils.toast("Invite sent successfully!");
      return;
    } else {
      final errorMsg = result.getError ?? 'Unknown error occurred';
      AppUtils.toastError('Failed to send invite: $errorMsg');
      throw Exception('Failed to send invite: $errorMsg');
    }
  }

  /// Get friend list who are not live
  Future<List<ProfileDataModel>> getFriends() async {
    await ProfileCtrl.find.getMyFollowings();
    // getMyFollowings
    return _friendList.map((friend) {
      if (liveUsers.any((user) => user['userId'] == friend.id)) {
        //   {
        // flutter: │ 🐛     "uid": "68aedb61e80f138227cd4b13",
        // flutter: │ 🐛     "agoraId": 1115127494,
        // flutter: │ 🐛     "data": {
        // flutter: │ 🐛       "id": "68aedb61e80f138227cd4b13",
        // flutter: │ 🐛       "name": "test1",
        // flutter: │ 🐛       "image": "/public/upload/image_picker_68A93548-82AE-4A60-B998-1F484CDC5751-19217-0000000F3C905E57-1756793139140.jpg",
        // flutter: │ 🐛       "joinedAt": "2025-09-15T05:35:57.313Z",
        // flutter: │ 🐛       "role": "participant"
        // flutter: │ 🐛     }
        // flutter: │ 🐛   }

        final uData = _userIdsMapping.firstWhereOrNull(
          (json) => json['uid'] == friend.id,
        );
        final agoraId = uData != null
            ? streamCtrl.value.remoteIds?.firstWhereOrNull(
                (element) => element.id == uData['agoraId'],
              )
            : null;

        if (agoraId != null) {
          return friend.copyWith(
            agoraLiveStatus: AgoraUserLiveStatus.liveBroadCaster,
          );
        }
        // if(uData != null && uData['data'] == 'host'){
        //   return friend.copyWith(agoraLiveStatus: AgoraUserLiveStatus.liveBroadCaster);
        // }
        return friend.copyWith(
          agoraLiveStatus: AgoraUserLiveStatus.liveAudience,
        );
      } else if (invitedUsers.any((invited) => invited.id == friend.id)) {
        return friend.copyWith(agoraLiveStatus: AgoraUserLiveStatus.invited);
      } else {
        return friend.copyWith(agoraLiveStatus: AgoraUserLiveStatus.offLine);
      }
    }).toList();
  }

  /// Initialize Live Broadcast session
  void initBroadCast(
    ClientRoleType role,
    String channelName, {
    bool isHost = false,
  }) {
    streamCtrl.value = StreamControlsModel(
      clientRole: role,
      channelId: channelName,
    );
    _registerEngine();
  }

  void sendGiftToken(
    String amount,
    String hostId, {
    Function(String)? onInsufficientBalance,
    Function()? onTransactionSuccess,
  }) {
    AuthCtrl.find
        .createMoneyWalletTransaction(amount, hostId)
        .applyLoader
        .then((responseData) {
          onTransactionSuccess?.call();

          // Use the actual token amount from the new API response
          final tokenAmount =
              responseData?['tokenAmount']?.toString() ?? amount;
          AgoraChatCtrl.find.giftTokenEmitter(
            token: tokenAmount,
            hostId: hostId,
          );

          // Show enhanced feedback with commission info using helper
          TokenTransferHelper.showTransferSuccessMessage(
            responseData,
            defaultTokenAmount: int.parse(amount),
            recipientType: 'Host',
          );
        })
        .catchError((error) {
          if (error is ResponseData) {
            onInsufficientBalance?.call(
              error.getError.toString().replaceAll('Exception: ', ''),
            );
          } else {
            AppUtils.toastError(error);
          }
        });
  }

  int getNumericUserId({String? uid}) => (uid ?? Preferences.uid!).agoraToken;

  void _updateBroadcasterCount() {
    if (isHost) {
      AgoraChatCtrl.find.updateLiveBroadCasterCountByHost(
        getBroadcasters.length,
      );
    }
  }

  ///---------------------------------------------------------------------------
  /// agora methods......
  /// Register and configure Agora engine
  Future<void> _registerEngine() async {
    engine = createAgoraRtcEngine();

    try {
      await engine.initialize(
        RtcEngineContext(
          appId: agoraAppId,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
      );

      StreamUtils.log('_engine.initialize', 'success');

      StreamUtils.registerEventHandlers(
        engine,
        onRemoteUserJoined: _handleRemoteUserJoined,
        onRemoteUserOffline: _handleRemoteUserOffline,
        onLocalMicStateChange: _handleMicChange,
        onLocalVideoStateChange: _handleVideoChange,
        onLocalJoinChannel: _handleLocalJoin,
        onClientRoleChanged: _onClientRoleChanged,
        onRemoteVideoStateChanged: _onRemoteVideoStateChanged,
        onRemoteAudioStateChanged: _onRemoteAudioStateChanged,
      );

      await engine.enableVideo();
      StreamUtils.log('_engine.setClientRole + enableVideo', 'success');
      await engine.setClientRole(role: streamCtrl.value.clientRole!);
      if (isHost ||
          streamCtrl.value.clientRole == ClientRoleType.clientRoleBroadcaster) {
        // await engine.setClientRole(role: streamCtrl.value.clientRole!);
        await engine.startPreview();
        streamCtrl.value.enginePreviewState = true;
        streamCtrl.refresh();
      }

      if (!isHost &&
          streamCtrl.value.clientRole == ClientRoleType.clientRoleBroadcaster &&
          getBroadcasters.length < broadCastUserMaxLimit) {
        await joinChannel();
      } else if (!isHost) {
        streamCtrl.value.clientRole = ClientRoleType.clientRoleAudience;
        // await engine.setClientRole(role: streamCtrl.value.clientRole!);
        await engine.muteLocalVideoStream(true);
        await joinChannel();
      }
    } catch (e) {
      StreamUtils.logEr('_registerEngine', e.toString());
    }
  }

  /// Switch between host and audience
  Future<void> changeRole() async {
    final currentRole = streamCtrl.value.clientRole;
    final isBroadcaster = currentRole == ClientRoleType.clientRoleBroadcaster;
    final newRole = isBroadcaster
        ? ClientRoleType.clientRoleAudience
        : ClientRoleType.clientRoleBroadcaster;

    if (!isBroadcaster && !(await StreamUtils.checkPermission())) return;

    await engine.setClientRole(role: newRole);
    streamCtrl.update((val) {
      if (val != null) val.clientRole = newRole;
    });
  }

  Future<void> joinChannel() async {
    final channelName = streamCtrl.value.channelId ?? '';
    final uid = getNumericUserId();
    try {
      final tokenData = await ProfileCtrl.find.getUserAgoraToken(
        channelName,
        uid.toString(),
        isHost,
      );
      await engine.joinChannel(
        token: tokenData['token'],
        channelId: tokenData['channelName'],
        uid: uid,
        options: const ChannelMediaOptions(),
      );

      StreamUtils.log('joinChannel', 'success');
    } catch (e) {
      StreamUtils.logEr('joinChannel', e.toString());
    }
  }

  Future<void> endStream() async {
    try {
      await engine.leaveChannel();
      await engine.release();
    } catch (_) {}
    _updateBroadcasterCount();
    AgoraChatCtrl.find.leaveAudienceLiveCamera(LiveRequestStatus.leave);
  }

  void cameraFlip() => engine.switchCamera();

  void micButtonAction() {
    final state = streamCtrl.value.localMicState;
    engine.enableLocalAudio(
      state == LocalAudioStreamState.localAudioStreamStateStopped,
    );
  }

  void onVideoAction() {
    final state = streamCtrl.value.localVideoState;
    engine.enableLocalVideo(
      state == LocalVideoStreamState.localVideoStreamStateStopped,
    );
  }

  void _handleRemoteUserJoined(RemoteUserAgora user) {
    final remoteIds = (streamCtrl.value.remoteIds ?? <RemoteUserAgora>{})
      ..add(user);
    streamCtrl.value.remoteIds = remoteIds;
    streamCtrl.refresh();
    _updateBroadcasterCount();
  }

  void _onRemoteVideoStateChanged(RemoteUserAgora user) =>
      _updateRemoteUser(user.id, videoState: user.videoState);

  void _onRemoteAudioStateChanged(RemoteUserAgora user) =>
      _updateRemoteUser(user.id, audioState: user.audioState);

  void _updateRemoteUser(
    int userId, {
    RemoteVideoState? videoState,
    RemoteAudioState? audioState,
  }) {
    final currentSet = streamCtrl.value.remoteIds ?? <RemoteUserAgora>{};
    final updatedSet = {...currentSet};

    final existingUser = updatedSet.firstWhereOrNull((e) => e.id == userId);

    if (existingUser != null) {
      updatedSet
        ..remove(existingUser)
        ..add(
          existingUser.copyWith(
            videoState: videoState ?? existingUser.videoState,
            audioState: audioState ?? existingUser.audioState,
          ),
        );

      streamCtrl.value.remoteIds = updatedSet;
      streamCtrl.refresh();
    }
  }

  void _handleMicChange(LocalAudioStreamState state) {
    streamCtrl.value.localMicState = state;
    streamCtrl.refresh();
  }

  void _handleVideoChange(LocalVideoStreamState state) {
    streamCtrl.value.localVideoState = state;
    streamCtrl.refresh();
  }

  void _handleLocalJoin() {
    streamCtrl.value.localChannelJoined = true;
    streamCtrl.refresh();
    _updateBroadcasterCount();
  }

  void _handleRemoteUserOffline(RemoteUserAgora user) {
    if (user.id == hostAgoraId) {
      navState.currentContext?.pop();
      return;
    }
    final remoteUsers = streamCtrl.value.remoteIds;
    if (remoteUsers == null || remoteUsers.isEmpty) return;
    final updatedUsers = Set<RemoteUserAgora>.from(remoteUsers)
      ..removeWhere((e) => e.id == user.id);
    streamCtrl.value.remoteIds = updatedUsers;
    streamCtrl.refresh();
    _updateBroadcasterCount();
  }

  void _onClientRoleChanged(ClientRoleType role) {
    streamCtrl.value.clientRole = role;
    streamCtrl.refresh();
  }
}

class RemoteUserAgora {
  int id;
  RemoteAudioState? audioState;
  RemoteVideoState? videoState;
  String? channelId;

  RemoteUserAgora({
    required this.id,
    this.audioState,
    this.videoState,
    this.channelId,
  });

  RemoteUserAgora copyWith({
    RemoteVideoState? videoState,
    RemoteAudioState? audioState,
  }) {
    return RemoteUserAgora(
      id: id,
      audioState: audioState ?? this.audioState,
      channelId: channelId,
      videoState: videoState ?? this.videoState,
    );
  }
}
