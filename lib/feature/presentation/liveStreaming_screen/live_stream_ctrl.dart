import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/main.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/video_download_utils.dart';

import '../../../services/networking/urls.dart';
import '../../../services/storage/preferences.dart';
import '../../../services/agora/agora_recording_service.dart';
import '../../../services/agora/video_url_retriever_service.dart';
import '../../data/models/dataModels/profile_data/profile_data_model.dart';
import '../../data/models/dataModels/responseDataModel.dart';
import '../helpers/token_transfer_helper.dart';
import '../controller/agora_chat_ctrl.dart';
import '../controller/auth_Controller/auth_ctrl.dart';

bool _showLog = true;

int broadCastUserMaxLimit = 6;

enum AgoraUserLiveStatus {
  offLine,
  onLine,
  liveBroadCaster,
  liveAudience,
  invited,
}

extension OnAgoraUserLiveStatus on AgoraUserLiveStatus {
  String get statusValue {
    switch (this) {
      case AgoraUserLiveStatus.offLine:
        return 'Off Line';
      case AgoraUserLiveStatus.onLine:
        return 'Online';
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
  bool _isEngineInitialized = false;
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
  /// Recording variables
  RxBool isRecording = RxBool(false);
  String? _recordingResourceId;
  String? _recordingSid;
  int? _recordingUid; // Store the recording UID used for the session
  DateTime? _recordingStartTime;
  String? recordedVideoUrl; // Current recording URL
  Timer? _recordingDurationTimer;
  RxString recordingDuration = RxString('00:00');

  // Array to store all recorded video URLs in the session
  final RxList<String> recordedVideoUrls = RxList<String>([]);

  // Flag to prevent showing dialog multiple times
  bool _hasShownRecordingDialog = false;

  // Flag to track if recording was ever started in this session
  bool _recordingWasStarted = false;

  ///---------------------------------------------------------------------------
  /// Recording getters
  bool get canRecord => isHost; // Only host can record

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

    // FOR AUDIENCE MEMBERS: If we don't have any remote users but we're connected to a channel,
    // we should add the host as a remote user so audience can see the stream
    if (remote.isEmpty &&
        !isHost &&
        streamCtrl.value.localChannelJoined == true &&
        streamCtrl.value.clientRole == ClientRoleType.clientRoleAudience) {
      AppUtils.log(
        'Audience member with no remote users - adding host to broadcasters',
      );

      // Add the host as a remote user so audience can see the stream
      final hostUser = RemoteUserAgora(
        id: hostAgoraId,
        audioState: RemoteAudioState.remoteAudioStateStarting,
        videoState: RemoteVideoState.remoteVideoStateStarting,
        channelId: streamCtrl.value.channelId,
      );
      remote.add(hostUser);
    }

    // Limit remote list to max 6, or 5 if local broadcaster to make space for 0
    final maxRemote = localUser != null ? 5 : 6;
    final limitedRemote = remote.take(maxRemote).toList();

    // Append 0 at end if local broadcaster
    if (localUser != null) {
      limitedRemote.add(localUser);
    }

    AppUtils.log('broadCaster length :: ${limitedRemote.length}');
    AppUtils.log(
      'isHost: $isHost, localChannelJoined: ${streamCtrl.value.localChannelJoined}, clientRole: ${streamCtrl.value.clientRole?.name}',
    );

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
      // Priority-based status detection:
      // 1. If invited -> show "Invitation Sent"
      // 2. If hosting and co-hosting -> show "CoHost"
      // 3. If hosting but not co-hosting -> show "Live"
      // 4. If online (socket connected and isActive) -> show "Online"
      // 5. If offline -> show "Off Line"

      // Check if friend has been invited
      if (invitedUsers.any((invited) => invited.id == friend.id)) {
        return friend.copyWith(
          agoraLiveStatus: AgoraUserLiveStatus.invited as AgoraUserLiveStatus?,
        );
      }

      // Check if friend is currently hosting a live stream
      final isHostingLive = AgoraChatCtrl.find.liveStreamChannels.any(
        (channel) => channel.hostId == friend.id,
      );

      if (isHostingLive) {
        // Check if they are also broadcasting in the current stream (co-hosting)
        final uData = _userIdsMapping.firstWhereOrNull(
          (json) => json['uid'] == friend.id,
        );
        final agoraId = uData != null
            ? streamCtrl.value.remoteIds?.firstWhereOrNull(
                (element) => element.id == uData['agoraId'],
              )
            : null;

        if (agoraId != null) {
          // User is co-hosting in current stream
          return friend.copyWith(
            agoraLiveStatus:
                AgoraUserLiveStatus.liveBroadCaster as AgoraUserLiveStatus?,
          );
        }
        // If hosting but not broadcasting in current stream, they're live audience
        return friend.copyWith(
          agoraLiveStatus:
              AgoraUserLiveStatus.liveAudience as AgoraUserLiveStatus?,
        );
      }

      // Check if user is online (using socket connection + isActive status)
      final isUserOnline = _isUserOnline(friend);

      if (isUserOnline) {
        // User is online but not live streaming
        return friend.copyWith(
          agoraLiveStatus: AgoraUserLiveStatus.onLine as AgoraUserLiveStatus?,
          isActive: true,
        );
      } else {
        // User is offline
        return friend.copyWith(
          agoraLiveStatus: AgoraUserLiveStatus.offLine as AgoraUserLiveStatus?,
          isActive: false,
        );
      }
    }).toList();
  }

  /// Determine if a user is currently online
  /// This method checks multiple indicators to determine online status
  bool _isUserOnline(ProfileDataModel user) {
    try {
      // Method 1: Check if user's profile isActive flag is true
      if (user.isActive == true) {
        return true;
      }

      // Method 2: Check if user is connected to any socket services
      // (This would require additional socket tracking implementation)
      final isSocketConnected = _checkUserSocketConnection(user.id);
      if (isSocketConnected) {
        return true;
      }

      // Method 3: Check recent activity timestamp
      // If user has been active within the last 5 minutes, consider online
      final isRecentlyActive = _checkRecentActivity(user);
      if (isRecentlyActive) {
        return true;
      }

      // Default to offline if no indicators show online status
      return false;
    } catch (e) {
      AppUtils.log('Error checking user online status: $e');
      return false;
    }
  }

  /// Check if user has an active socket connection
  /// This is a placeholder - would need backend socket tracking
  bool _checkUserSocketConnection(String? userId) {
    if (userId == null) return false;

    try {
      // Check if user is in live stream participants (indicates socket connection)
      final chatCtrl = AgoraChatCtrl.find;

      // Check if user is in any active live stream as host
      final isHostingLiveStream = chatCtrl.liveStreamChannels.any(
        (channel) => channel.hostId == userId,
      );

      if (isHostingLiveStream) {
        return true;
      }

      // Additional checks could be added here for:
      // - Chat socket connections
      // - Recent message sending
      // - Other real-time activities

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Check if user has been recently active
  bool _checkRecentActivity(ProfileDataModel user) {
    try {
      // Check updatedAt timestamp - if updated within last 5 minutes, consider active
      if (user.updatedAt != null) {
        final lastUpdate = DateTime.tryParse(user.updatedAt!);
        if (lastUpdate != null) {
          final timeDifference = DateTime.now().difference(lastUpdate);
          // Consider user online if last activity was within 5 minutes
          if (timeDifference.inMinutes < 5) {
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  ///---------------------------------------------------------------------------
  /// Recording Methods

  /// Show recording loading dialog
  void _showRecordingLoadingDialog(String message) {
    Get.dialog(
      Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                TextView(
                  text: message,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Close loading dialog safely
  void _closeLoadingDialog() {
    try {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    } catch (e) {
      AppUtils.log('Error closing dialog: $e');
    }
  }

  /// Reset recording state
  void _resetRecordingState() {
    isRecording.value = false;
    _recordingResourceId = null;
    _recordingSid = null;
    _recordingUid = null;
    _recordingStartTime = null;
    _stopRecordingDurationTimer();
  }

  /// Start Agora cloud recording using service
  Future<bool> startRecording() async {
    if (!canRecord) {
      AppUtils.toastError('Only host can start recording');
      return false;
    }

    if (isRecording.value) {
      AppUtils.toastError('Recording is already in progress');
      return false;
    }

    final channelName = streamCtrl.value.channelId;
    if (channelName == null || channelName.isEmpty) {
      AppUtils.toastError('Channel not initialized');
      return false;
    }

    try {
      // Pre-recording validations
      if (!streamCtrl.value.localChannelJoined) {
        AppUtils.toastError('Please wait until you join the channel');
        return false;
      }

      final hasAudio =
          streamCtrl.value.localMicState != null &&
          streamCtrl.value.localMicState !=
              LocalAudioStreamState.localAudioStreamStateStopped;
      final hasVideo =
          streamCtrl.value.localVideoState != null &&
          streamCtrl.value.localVideoState !=
              LocalVideoStreamState.localVideoStreamStateStopped;

      if (!hasAudio && !hasVideo) {
        AppUtils.toastError(
          'Please enable camera or microphone before recording',
        );
        return false;
      }

      // Show loading
      _showRecordingLoadingDialog('Starting recording...');

      isRecording.value = true;

      // Generate recording UID using service
      final recordingUid = AgoraRecordingService.generateRecordingUid();
      _recordingUid = recordingUid;

      // Get token from backend
      final tokenData = await ProfileCtrl.find.getUserAgoraToken(
        channelName,
        recordingUid.toString(),
        false,
      );
      final token = tokenData['token'] as String?;

      if (token == null || token.isEmpty) {
        throw Exception('Failed to get recording token from backend');
      }

      // Use AgoraRecordingService for complete workflow
      final workflowResult = await AgoraRecordingService.startCompleteRecording(
        channelName: channelName,
        uid: recordingUid,
        token: token,
        maxRetries: 2,
      );

      _recordingResourceId = workflowResult['resourceId'];
      _recordingSid = workflowResult['sid'];
      _recordingStartTime = DateTime.now();

      // Set flag that recording was started in this session
      _recordingWasStarted = true;

      // Start duration timer
      _startRecordingDurationTimer();

      // Close loading dialog
      _closeLoadingDialog();

      AppUtils.toast('Recording started successfully');
      return true;
    } catch (e) {
      _closeLoadingDialog();
      _resetRecordingState();
      AppUtils.toastError('Failed to start recording: $e');
      return false;
    }
  }

  /// Stop Agora cloud recording using service
  Future<bool> stopRecording() async {
    if (!isRecording.value) {
      AppUtils.toastError('No recording in progress');
      return false;
    }

    if (_recordingResourceId == null ||
        _recordingSid == null ||
        _recordingUid == null) {
      AppUtils.toastError('Recording session not found');
      _resetRecordingState();
      return false;
    }

    final channelName = streamCtrl.value.channelId;
    if (channelName == null || channelName.isEmpty) {
      AppUtils.toastError('Channel not initialized');
      return false;
    }

    try {
      // Show loading
      _showRecordingLoadingDialog('Stopping recording...');

      // Use AgoraRecordingService to stop recording
      final stopResult = await AgoraRecordingService.stop(
        channelName: channelName,
        uid: _recordingUid.toString(),
        resourceId: _recordingResourceId!,
        sid: _recordingSid!,
      );

      // Close loading dialog
      _closeLoadingDialog();

      // Reset recording state
      _resetRecordingState();

      if (!stopResult.success) {
        AppUtils.toastError(
          stopResult.errorMessage ?? 'Failed to stop recording',
        );
        return false;
      }

      // Extract video URLs using AgoraRecordingService
      final recordingFiles = await AgoraRecordingService.extractRecordingFiles(
        stopResult,
        channelName,
      );

      // Get immediate video URL if available
      final immediateUrl = AgoraRecordingService.getImmediateVideoUrl(
        recordingFiles,
      );

      if (immediateUrl != null && immediateUrl.isNotEmpty) {
        // Store video URLs using VideoUrlRetrieverService
        VideoUrlRetrieverService.storeVideoUrls(
          [immediateUrl],
          (videoUrl) {
            if (!recordedVideoUrls.contains(videoUrl)) {
              recordedVideoUrls.add(videoUrl);
            }
          },
          onVideoStored: (videoUrl) {
            recordedVideoUrl = videoUrl;
            AppUtils.log('🎯 Stored video URL: $videoUrl');
          },
        );

        // Print URLs for debugging using VideoDownloadUtils
        VideoDownloadUtils.printVideoUrlsInGreen([immediateUrl]);
      }

      AppUtils.toast('Recording stopped successfully');
      return true;
    } catch (e) {
      _closeLoadingDialog();
      _resetRecordingState();
      AppUtils.toastError('Failed to stop recording: $e');
      return false;
    }
  }

  // 🎬 NOTE: Old _startVideoUrlRetrieval method removed
  // We now use immediate URL extraction approach (like your working files)
  // URLs are available immediately when recording stops

  /// Toggle recording on/off
  bool _isTogglingRecording = false;

  Future<void> toggleRecording() async {
    // Prevent multiple simultaneous toggle operations
    if (_isTogglingRecording) {
      AppUtils.log('Recording toggle already in progress, ignoring...');
      return;
    }

    _isTogglingRecording = true;

    try {
      if (isRecording.value) {
        await stopRecording();
      } else {
        await startRecording();
      }
    } finally {
      _isTogglingRecording = false;
    }
  }

  /// Start timer to update recording duration
  void _startRecordingDurationTimer() {
    _stopRecordingDurationTimer(); // Stop any existing timer
    _recordingDurationTimer = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) {
      if (_recordingStartTime != null) {
        final duration = DateTime.now().difference(_recordingStartTime!);
        final minutes = duration.inMinutes;
        final seconds = duration.inSeconds % 60;
        recordingDuration.value =
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      }
    });
  }

  /// Stop recording duration timer
  void _stopRecordingDurationTimer() {
    _recordingDurationTimer?.cancel();
    _recordingDurationTimer = null;
    recordingDuration.value = '00:00';
  }

  ///---------------------------------------------------------------------------

  /// Initialize Live Broadcast session
  Future<void> initBroadCast(
    ClientRoleType role,
    String channelName, {
    bool isHost = false,
  }) async {
    print(
      'LiveStreamCtrl: Starting initBroadCast - role: ${role.name}, channel: $channelName, isHost: $isHost',
    );

    try {
      // Reset dialog and recording flags for new session
      _hasShownRecordingDialog = false;
      _recordingWasStarted = false;
      print('LiveStreamCtrl: Reset dialog flags');

      streamCtrl.value = StreamControlsModel(
        clientRole: role,
        channelId: channelName,
      );
      print('LiveStreamCtrl: Set stream control model');

      print('LiveStreamCtrl: Calling _registerEngine...');
      await _registerEngine();
      print('LiveStreamCtrl: _registerEngine completed successfully');
    } catch (e) {
      print('LiveStreamCtrl: Error in initBroadCast: $e');
      rethrow;
    }
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
    try {
      // Reset initialization flag
      _isEngineInitialized = false;

      // Check and request permissions first
      StreamUtils.log('_registerEngine', 'Checking permissions...');
      final hasPermissions = await StreamUtils.checkPermission();
      if (!hasPermissions) {
        throw Exception('Camera and microphone permissions are required');
      }
      StreamUtils.log('_registerEngine', 'Permissions granted');

      // Create and initialize engine
      StreamUtils.log('_registerEngine', 'Creating Agora engine...');
      engine = createAgoraRtcEngine();

      StreamUtils.log(
        '_registerEngine',
        'Initializing with appId: $agoraAppId',
      );
      await engine.initialize(
        RtcEngineContext(
          appId: agoraAppId,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
      );
      StreamUtils.log('_engine.initialize', 'success');

      // Mark engine as initialized
      _isEngineInitialized = true;

      // Small delay to ensure engine is fully ready
      await Future.delayed(const Duration(milliseconds: 500));

      // Register event handlers
      StreamUtils.log('_registerEngine', 'Registering event handlers...');
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

      // Enable video and set client role
      StreamUtils.log('_registerEngine', 'Enabling video...');
      await engine.enableVideo();

      StreamUtils.log(
        '_registerEngine',
        'Setting client role: ${streamCtrl.value.clientRole?.name}',
      );
      await engine.setClientRole(role: streamCtrl.value.clientRole!);

      if (isHost ||
          streamCtrl.value.clientRole == ClientRoleType.clientRoleBroadcaster) {
        StreamUtils.log(
          '_registerEngine',
          'Starting preview for broadcaster...',
        );
        await engine.startPreview();
        streamCtrl.value.enginePreviewState = true;
        streamCtrl.refresh();
        StreamUtils.log('_registerEngine', 'Preview started successfully');
      }

      if (!isHost &&
          streamCtrl.value.clientRole == ClientRoleType.clientRoleBroadcaster &&
          getBroadcasters.length < broadCastUserMaxLimit) {
        StreamUtils.log(
          '_registerEngine',
          'Auto-joining channel for co-broadcaster...',
        );
        await joinChannel();
      } else if (!isHost) {
        StreamUtils.log('_registerEngine', 'Setting up audience mode...');
        streamCtrl.value.clientRole = ClientRoleType.clientRoleAudience;

        // For audience members, mute local streams
        await engine.muteLocalVideoStream(true);
        await engine.muteLocalAudioStream(true);

        StreamUtils.log(
          '_registerEngine',
          'Audience setup complete, joining channel...',
        );
        await joinChannel();
      }

      StreamUtils.log(
        '_registerEngine',
        'Engine registration completed successfully',
      );
    } catch (e, stackTrace) {
      _isEngineInitialized = false;
      StreamUtils.logEr('_registerEngine', 'Error: ${e.toString()}');
      StreamUtils.logEr(
        '_registerEngine',
        'StackTrace: ${stackTrace.toString()}',
      );
      AppUtils.toastError('Failed to initialize stream: ${e.toString()}');
      rethrow;
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
    // Check if engine is initialized
    if (!_isEngineInitialized) {
      final errorMsg =
          'Agora engine not initialized. Please wait for initialization to complete.';
      StreamUtils.logEr('joinChannel', errorMsg);
      AppUtils.toastError(errorMsg);
      throw Exception(errorMsg);
    }

    final channelName = streamCtrl.value.channelId ?? '';
    final uid = getNumericUserId();

    StreamUtils.log(
      'joinChannel',
      'Starting - Channel: $channelName, UID: $uid, isHost: $isHost',
    );

    try {
      // Get Agora token
      StreamUtils.log('joinChannel', 'Fetching token from API...');
      final tokenData = await ProfileCtrl.find.getUserAgoraToken(
        channelName,
        uid.toString(),
        isHost,
      );

      // Log complete server response for debugging
      StreamUtils.log('joinChannel', '=== COMPLETE SERVER RESPONSE ===');
      StreamUtils.log('joinChannel', 'Full Response: ${tokenData.toString()}');
      StreamUtils.log(
        'joinChannel',
        'Response Keys: ${tokenData.keys.toList()}',
      );

      // Validate token response
      final token = tokenData['token'] as String?;
      final appId = tokenData['appId'] as String?;
      final responseChannelName = tokenData['channelName'] as String?;
      final responseUid = tokenData['uid'];
      final success = tokenData['success'];

      StreamUtils.log('joinChannel', 'Parsed Fields:');
      StreamUtils.log('joinChannel', '  - success: $success');
      StreamUtils.log(
        'joinChannel',
        '  - token: "${token ?? 'null'}" (length: ${token?.length ?? 0})',
      );
      StreamUtils.log('joinChannel', '  - appId: "$appId"');
      StreamUtils.log('joinChannel', '  - channelName: "$responseChannelName"');
      StreamUtils.log('joinChannel', '  - uid: $responseUid');
      StreamUtils.log('joinChannel', '================================');

      // Check if token is empty or null
      if (token == null || token.isEmpty) {
        final errorMsg =
            '⚠️ SERVER ERROR: Token generation failed!\n\n'
            'The server returned an empty token.\n\n'
            'Full server response:\n${tokenData.toString()}\n\n'
            'This is a BACKEND issue - please contact your backend team.';

        StreamUtils.logEr('joinChannel', errorMsg);
        AppUtils.toastError(
          'Server error: Cannot generate stream token. Please contact support.',
        );

        throw Exception(
          'Empty token received from server. Backend needs to fix token generation.',
        );
      }

      // Join the channel with valid token
      StreamUtils.log(
        'joinChannel',
        'Valid token received (length: ${token.length}), joining channel...',
      );
      await engine.joinChannel(
        token: token,
        channelId: responseChannelName ?? channelName,
        uid: uid,
        options: const ChannelMediaOptions(),
      );

      StreamUtils.log('joinChannel', 'Join request sent successfully');
    } catch (e) {
      final errorStr = e.toString();
      StreamUtils.logEr('joinChannel', 'Error: $errorStr');

      // Handle specific error codes
      if (errorStr.contains('Empty token')) {
        // Already handled above with user-friendly message
      } else if (errorStr.contains('-17') ||
          errorStr.contains('ERR_NOT_INITIALIZED')) {
        AppUtils.toastError(
          'Stream engine not properly initialized. Please try again.',
        );
      } else if (errorStr.contains('-2') ||
          errorStr.contains('ERR_INVALID_ARGUMENT')) {
        AppUtils.toastError(
          'Invalid stream configuration. Please restart the app.',
        );
      } else if (errorStr.contains('110') ||
          errorStr.contains('errInvalidToken')) {
        AppUtils.toastError(
          'Invalid stream token. Server configuration error.',
        );
      } else {
        AppUtils.toastError('Failed to start stream: $errorStr');
      }

      rethrow;
    }
  }

  Future<void> endStream() async {
    AppUtils.log('=== START endStream() ===');

    // Prevent showing dialog multiple times
    if (_hasShownRecordingDialog) {
      AppUtils.log('Recording dialog already shown, skipping...');
      return;
    }

    // Store video URL and host status before cleanup
    final videoUrl = recordedVideoUrl;
    final wasHost = isHost;
    final hasRecording = videoUrl != null && videoUrl.isNotEmpty;

    AppUtils.log(
      'Ending stream - Has recording: $hasRecording, Was host: $wasHost, Video URL: $videoUrl',
    );
    AppUtils.log('Total recordings in array: ${recordedVideoUrls.length}');
    AppUtils.log('isRecording.value: ${isRecording.value}');
    AppUtils.log('Recording was started in session: $_recordingWasStarted');

    try {
      // Stop recording if active
      if (isRecording.value) {
        AppUtils.log('Stopping active recording...');
        await stopRecording();
        // Update videoUrl after stopping in case it was just saved
        final updatedUrl = recordedVideoUrl;
        AppUtils.log('Updated video URL after stopping: $updatedUrl');
        AppUtils.log(
          'Updated recordings array length: ${recordedVideoUrls.length}',
        );
      }
      _stopRecordingDurationTimer();

      AppUtils.log('Leaving channel and releasing engine...');
      await engine.leaveChannel();
      await engine.release();
      _isEngineInitialized = false;
      AppUtils.log('Engine cleanup complete');
    } catch (e) {
      AppUtils.logEr('Error ending stream: $e');
    }

    _updateBroadcasterCount();
    AgoraChatCtrl.find.leaveAudienceLiveCamera(LiveRequestStatus.leave);

    // Show recorded video dialog only if recording was started and user was host
    final hasRecordings = recordedVideoUrls.isNotEmpty;

    AppUtils.log(
      'Final check - Has recordings in array: $hasRecordings, Was host: $wasHost, Total videos: ${recordedVideoUrls.length}',
    );
    AppUtils.log('Recording was started: $_recordingWasStarted');
    AppUtils.log(
      'Will show dialog? ${hasRecordings && wasHost && _recordingWasStarted}',
    );

    // Only show dialog if recording was actually started in this session
    if (hasRecordings && wasHost && _recordingWasStarted) {
      AppUtils.log('Calling _showRecordedVideosDialog...');
      _hasShownRecordingDialog = true; // Set flag to prevent duplicate
      // Wait for dialog to be dismissed before continuing
      await _showRecordedVideosDialog(recordedVideoUrls.toList());
      AppUtils.log('Dialog dismissed, endStream completing');
    } else if (wasHost && !hasRecordings && _recordingWasStarted) {
      // Host started recording but file URL not yet available
      AppUtils.log('Host ended stream but no recordings available yet');
      AppUtils.log('Showing processing dialog instead...');
      _hasShownRecordingDialog = true; // Set flag to prevent duplicate
      await _showRecordingProcessingDialog();
    } else {
      AppUtils.log(
        'NOT showing dialog - hasRecordings: $hasRecordings, wasHost: $wasHost, recordingStarted: $_recordingWasStarted',
      );
    }

    AppUtils.log('=== END endStream() ===');
  }

  Future<void> _showRecordedVideosDialog(List<String> videoUrls) async {
    AppUtils.log('=== _showRecordedVideosDialog START ===');
    AppUtils.log(
      'Showing recorded videos dialog with ${videoUrls.length} URLs: $videoUrls',
    );

    // Download videos directly to gallery using VideoDownloadUtils
    AppUtils.log(
      '🎥 [DOWNLOAD] Preparing to download ${videoUrls.length} videos...',
    );

    // Use VideoDownloadUtils service for multiple video downloads
    final downloadResults =
        await VideoDownloadUtils.downloadMultipleVideosToGallery(videoUrls);

    final successCount = downloadResults.values
        .where((success) => success)
        .length;
    AppUtils.log(
      '🎯 Downloaded $successCount/${videoUrls.length} videos successfully',
    );

    // Print video URLs in green color for easy debugging
    VideoDownloadUtils.printVideoUrlsInGreen(videoUrls);

    // Prevent showing dialog if already open
    if (Get.isDialogOpen == true) {
      AppUtils.log('Dialog already open, skipping...');
      return;
    }

    // Wait for UI to stabilize before showing dialog
    AppUtils.log('Waiting 500ms for UI to stabilize...');
    await Future.delayed(const Duration(milliseconds: 500));

    AppUtils.log('Delay complete, getting context...');
    final context = Get.context ?? navState.currentContext;
    AppUtils.log('Context: ${context != null ? "FOUND" : "NULL"}');

    if (context != null) {
      AppUtils.log('Context found, calling Get.dialog...');
      // Get.dialog returns a Future that completes when dialog is dismissed
      await Get.dialog(
        Material(
          color: Colors.transparent,
          child: Center(
            child: _RecordedVideoDialog(
              videoUrls: videoUrls,
              onClose: () {
                // Clear the recorded URLs array when dialog is closed
                recordedVideoUrls.clear();
                AppUtils.log('Cleared recorded video URLs array');
              },
            ),
          ),
        ),
        barrierDismissible: false,
      );
      AppUtils.log('Dialog dismissed');
    } else {
      AppUtils.logEr('No context available to show dialog');
    }

    AppUtils.log('=== _showRecordedVideosDialog END ===');
  }

  /// Show dialog when recording is processing
  Future<void> _showRecordingProcessingDialog() async {
    AppUtils.log('=== _showRecordingProcessingDialog START ===');

    // Prevent showing dialog if already open
    if (Get.isDialogOpen == true) {
      AppUtils.log('Dialog already open, skipping processing dialog...');
      return;
    }

    // Wait for UI to stabilize
    await Future.delayed(const Duration(milliseconds: 500));

    final context = Get.context ?? navState.currentContext;
    AppUtils.log('Context: ${context != null ? "FOUND" : "NULL"}');

    if (context != null) {
      AppUtils.log('Showing recording processing dialog...');
      await Get.dialog(
        Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Processing Icon
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.video_library,
                        size: 60,
                        color: Colors.blue,
                      ),
                    ),

                    SizedBox(height: 20),

                    // Title
                    TextView(
                      text: 'Recording Saved!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    SizedBox(height: 10),

                    // Description
                    TextView(
                      text:
                          'Your live stream recording is being processed and will be available in your cloud storage shortly.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 30),

                    // Close Button
                    AppButton(
                      label: 'Got it',
                      buttonColor: AppColors.primaryColor,
                      onTap: () {
                        try {
                          // Close dialog first
                          if (Navigator.of(context).canPop()) {
                            Navigator.pop(context); // Close dialog
                          }
                          // Then close stream screen after delay
                          Future.delayed(Duration(milliseconds: 100), () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.pop(context); // Close stream screen
                            }
                          });
                        } catch (e) {
                          AppUtils.log('Error closing dialog: $e');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );
      AppUtils.log('Processing dialog dismissed');
    } else {
      AppUtils.logEr('No context available to show processing dialog');
    }

    AppUtils.log('=== _showRecordingProcessingDialog END ===');
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
    AppUtils.log(
      'Remote user joined: ${user.id}, isHost: $isHost, hostAgoraId: $hostAgoraId',
    );

    final remoteIds = (streamCtrl.value.remoteIds ?? <RemoteUserAgora>{})
      ..add(user);
    streamCtrl.value.remoteIds = remoteIds;
    streamCtrl.refresh();
    _updateBroadcasterCount();

    // For audience members, if this is the host joining, log it
    if (!isHost && user.id == hostAgoraId) {
      AppUtils.log('Host stream is now available for audience member');
    }
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

    AppUtils.log(
      'Local user joined channel - isHost: $isHost, role: ${streamCtrl.value.clientRole?.name}',
    );

    // For audience members, trigger a refresh after joining to ensure we can see existing broadcasters
    if (!isHost &&
        streamCtrl.value.clientRole == ClientRoleType.clientRoleAudience) {
      AppUtils.log(
        'Audience member joined - checking for existing broadcasters...',
      );

      // Small delay to allow for remote users to be detected
      Future.delayed(const Duration(milliseconds: 1000), () {
        AppUtils.log('Refreshing broadcasters list for audience member');
        streamCtrl.refresh();

        // If still no remote users, force add the host
        if ((streamCtrl.value.remoteIds?.isEmpty ?? true)) {
          AppUtils.log('No remote users detected, manually adding host stream');
          _forceAddHostForAudience();
        }
      });
    }

    // Title is now stored in backend via startLive API call
    // No need to broadcast via chat messages
  }

  void _forceAddHostForAudience() {
    if (!isHost &&
        streamCtrl.value.clientRole == ClientRoleType.clientRoleAudience) {
      final hostUser = RemoteUserAgora(
        id: hostAgoraId,
        audioState: RemoteAudioState.remoteAudioStateStarting,
        videoState: RemoteVideoState.remoteVideoStateStarting,
        channelId: streamCtrl.value.channelId,
      );

      final remoteIds = (streamCtrl.value.remoteIds ?? <RemoteUserAgora>{})
        ..add(hostUser);
      streamCtrl.value.remoteIds = remoteIds;
      streamCtrl.refresh();

      AppUtils.log('Manually added host to remote users for audience member');
    }
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

class _RecordedVideoDialog extends StatelessWidget {
  final List<String> videoUrls;
  final VoidCallback? onClose;

  const _RecordedVideoDialog({required this.videoUrls, this.onClose});

  @override
  Widget build(BuildContext context) {
    final videoCount = videoUrls.length;

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, size: 60, color: Colors.green),
              ),

              SizedBox(height: 20),

              // Title
              TextView(
                text: videoCount > 1
                    ? '$videoCount Streams Recorded!'
                    : 'Stream Recorded!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 10),

              // Description
              TextView(
                text: videoCount > 1
                    ? 'Your $videoCount live streams have been successfully recorded.'
                    : 'Your live stream has been successfully recorded.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 30),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Save to Gallery',
                      buttonColor: Colors.grey[300]!,
                      labelStyle: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      onTap: () => _saveToGallery(context),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'Share as Post',
                      buttonColor: AppColors.primaryColor,
                      onTap: () => _shareAsPost(context),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Close Button
              TextButton(
                onPressed: () {
                  try {
                    onClose?.call();
                    // Close dialog first
                    if (Navigator.of(context).canPop()) {
                      Navigator.pop(context); // Close dialog
                    }
                    // Then close stream screen
                    Future.delayed(Duration(milliseconds: 100), () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.pop(context); // Close stream screen
                      }
                    });
                  } catch (e) {
                    AppUtils.log('Error closing dialog: $e');
                  }
                },
                child: TextView(
                  text: 'Close',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveToGallery(BuildContext context) async {
    try {
      AppUtils.log('🎬 [GALLERY] Starting gallery save process...');

      // Print all video URLs in green for debugging
      VideoDownloadUtils.printVideoUrlsInGreen(videoUrls);

      // Show loading message
      AppUtils.toast(
        videoUrls.length > 1
            ? 'Downloading ${videoUrls.length} videos...'
            : 'Downloading video...',
      );

      // Use VideoDownloadUtils for all downloads
      if (videoUrls.length == 1) {
        // Single video download
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'SEP_LiveStream_$timestamp.mp4';

        final success = await VideoDownloadUtils.downloadVideoToGallery(
          videoUrls.first,
          fileName: fileName,
        );

        if (success) {
          AppUtils.toast('✅ Video saved to gallery!');
        } else {
          AppUtils.toastError('❌ Failed to save video to gallery');
          return;
        }
      } else {
        // Multiple videos download using VideoDownloadUtils service
        final downloadResults =
            await VideoDownloadUtils.downloadMultipleVideosToGallery(videoUrls);

        final successCount = downloadResults.values
            .where((success) => success)
            .length;

        if (successCount == videoUrls.length) {
          AppUtils.toast('✅ All $successCount videos saved to gallery!');
        } else if (successCount > 0) {
          AppUtils.toast(
            '⚠️ $successCount/${videoUrls.length} videos saved to gallery',
          );
        } else {
          AppUtils.toastError('❌ Failed to save videos to gallery');
          return;
        }
      }

      onClose?.call();

      // Close dialog safely
      try {
        if (Navigator.of(context).canPop()) {
          Navigator.pop(context);
        }
      } catch (e) {
        AppUtils.log('Error closing dialog: $e');
      }
    } catch (e) {
      AppUtils.toastError('Failed to save video: $e');
      AppUtils.logEr('❌ [GALLERY] Error in _saveToGallery: $e');
    }
  }

  void _shareAsPost(BuildContext context) {
    try {
      // Close dialog and clear array
      onClose?.call();

      // Close dialog safely
      try {
        if (Navigator.of(context).canPop()) {
          Navigator.pop(context); // Close dialog only
        }
      } catch (e) {
        AppUtils.log('Error closing dialog: $e');
      }

      // Show toast for now - TODO: Navigate to CreatePost with video URLs array
      AppUtils.toast('Opening post creator...');

      // TODO: Navigate to create post screen with video URLs array
      // You'll need to:
      // 1. Get a category ID (or allow user to select in CreatePost)
      // 2. Pass the video URLs array to CreatePost
      // 3. Modify CreatePost to accept optional video URLs parameter

      // For now, just close the dialog
      if (videoUrls.length > 1) {
        AppUtils.toast(
          'Feature coming soon: Share ${videoUrls.length} recorded streams as posts',
        );
      } else {
        AppUtils.toast('Feature coming soon: Share recorded stream as post');
      }
    } catch (e) {
      AppUtils.toastError('Failed to open post creator: $e');
    }
  }
}
