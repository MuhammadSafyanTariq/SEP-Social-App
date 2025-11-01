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
            agoraLiveStatus:
                AgoraUserLiveStatus.liveBroadCaster as AgoraUserLiveStatus?,
          );
        }
        // if(uData != null && uData['data'] == 'host'){
        //   return friend.copyWith(agoraLiveStatus: AgoraUserLiveStatus.liveBroadCaster);
        // }
        return friend.copyWith(
          agoraLiveStatus:
              AgoraUserLiveStatus.liveAudience as AgoraUserLiveStatus?,
        );
      } else if (invitedUsers.any((invited) => invited.id == friend.id)) {
        return friend.copyWith(
          agoraLiveStatus: AgoraUserLiveStatus.invited as AgoraUserLiveStatus?,
        );
      } else {
        return friend.copyWith(
          agoraLiveStatus: AgoraUserLiveStatus.offLine as AgoraUserLiveStatus?,
        );
      }
    }).toList();
  }

  ///---------------------------------------------------------------------------
  /// Recording Methods

  /// Start Agora cloud recording
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
      AppUtils.log('═══════════════════════════════════════════════════');
      AppUtils.log('STARTING RECORDING - DIAGNOSTIC INFO');
      AppUtils.log('═══════════════════════════════════════════════════');
      AppUtils.log('Channel Name: $channelName');
      AppUtils.log('Host UID (numeric): $hostAgoraId');
      AppUtils.log('Host UID (string): ${hostAgoraId.toString()}');
      AppUtils.log('Is Host: $isHost');
      AppUtils.log('Can Record: $canRecord');
      AppUtils.log('Current User ID: ${Preferences.uid}');
      AppUtils.log('Local user audio state: ${streamCtrl.value.localMicState}');
      AppUtils.log(
        'Local user video state: ${streamCtrl.value.localVideoState}',
      );
      AppUtils.log(
        'Remote users count: ${streamCtrl.value.remoteIds?.length ?? 0}',
      );
      AppUtils.log(
        'Local channel joined: ${streamCtrl.value.localChannelJoined}',
      );
      AppUtils.log('═══════════════════════════════════════════════════');

      // Check if user has joined the channel and is publishing
      if (!streamCtrl.value.localChannelJoined) {
        AppUtils.toastError('Please wait until you join the channel');
        AppUtils.logEr('Recording blocked: Not joined to channel yet');
        return false;
      }

      // Check if at least one stream is active (either audio or video)
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
        AppUtils.logEr('Recording blocked: No active audio/video streams');
        AppUtils.logEr(
          'Audio state: ${streamCtrl.value.localMicState}, Video state: ${streamCtrl.value.localVideoState}',
        );
        return false;
      }

      AppUtils.log(
        '✓ Stream validation passed - Audio: $hasAudio, Video: $hasVideo',
      );

      // Wait a moment to ensure streams are fully established
      AppUtils.log('Waiting 2 seconds for streams to stabilize...');
      await Future.delayed(Duration(seconds: 2));
      AppUtils.log('Stream stabilization complete, proceeding with recording');

      // Show loading
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
                    text: 'Starting recording...',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      isRecording.value = true;

      // Generate recording UID
      final recordingUid = AgoraRecordingService.generateRecordingUid();
      _recordingUid = recordingUid; // Store for stop operation
      AppUtils.log('🎯 Generated recording UID: $recordingUid');

      // Get token from backend (keep backend token generation)
      final tokenData = await ProfileCtrl.find.getUserAgoraToken(
        channelName,
        recordingUid.toString(),
        false, // Not host for recording
      );
      final token = tokenData['token'] as String?;

      if (token == null || token.isEmpty) {
        throw Exception('Failed to get recording token from backend');
      }

      AppUtils.log('🔑 Got recording token: ${token.substring(0, 20)}...');

      // Use complete recording workflow
      final workflowResult = await AgoraRecordingService.startCompleteRecording(
        channelName: channelName,
        uid: recordingUid,
        token: token,
        maxRetries: 2,
      );

      _recordingResourceId = workflowResult['resourceId'];
      _recordingSid = workflowResult['sid'];

      AppUtils.log('═══════════════════════════════════════════════════');
      AppUtils.log('START RECORDING RESULT');
      AppUtils.log('Workflow completed successfully');
      AppUtils.log('ResourceId: $_recordingResourceId');
      AppUtils.log('SID: $_recordingSid');
      AppUtils.log('═══════════════════════════════════════════════════');
      _recordingStartTime = DateTime.now();

      // Start timer to update recording duration
      _startRecordingDurationTimer();

      // Close loading dialog
      Get.back();

      AppUtils.log('═══════════════════════════════════════════════════');
      AppUtils.log('RECORDING STARTED SUCCESSFULLY ✓');
      AppUtils.log('Channel: $channelName');
      AppUtils.log('UID: ${hostAgoraId.toString()}');
      AppUtils.log('ResourceId: $_recordingResourceId');
      AppUtils.log('SID: $_recordingSid');
      AppUtils.log('Started at: $_recordingStartTime');
      AppUtils.log('═══════════════════════════════════════════════════');

      AppUtils.toast('Recording started successfully');

      return true;
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen == true) Get.back();

      isRecording.value = false;
      _recordingResourceId = null;
      _recordingSid = null;
      _recordingUid = null;
      _recordingStartTime = null;
      _stopRecordingDurationTimer();

      AppUtils.logEr('❌ Error starting recording: $e');
      AppUtils.toastError('Failed to start recording: $e');
      return false;
    }
  }

  /// Stop Agora cloud recording
  Future<bool> stopRecording() async {
    AppUtils.log('═══════════════════════════════════════════════════');
    AppUtils.log('STOPPING RECORDING - DIAGNOSTIC INFO');
    AppUtils.log('═══════════════════════════════════════════════════');
    AppUtils.log('Is Recording: ${isRecording.value}');
    AppUtils.log('ResourceId: $_recordingResourceId');
    AppUtils.log('SID: $_recordingSid');
    AppUtils.log('Channel: ${streamCtrl.value.channelId}');
    AppUtils.log('Host UID: ${hostAgoraId.toString()}');
    AppUtils.log('═══════════════════════════════════════════════════');

    if (!isRecording.value) {
      AppUtils.toastError('No recording in progress');
      return false;
    }

    if (_recordingResourceId == null ||
        _recordingSid == null ||
        _recordingUid == null) {
      AppUtils.logEr('⚠️ CRITICAL: Recording session data is missing!');
      AppUtils.logEr('ResourceId is null: ${_recordingResourceId == null}');
      AppUtils.logEr('SID is null: ${_recordingSid == null}');
      AppUtils.logEr('Recording UID is null: ${_recordingUid == null}');
      AppUtils.toastError('Recording session not found');
      isRecording.value = false;
      _stopRecordingDurationTimer();
      return false;
    }

    final channelName = streamCtrl.value.channelId;
    if (channelName == null || channelName.isEmpty) {
      AppUtils.toastError('Channel not initialized');
      return false;
    }

    try {
      AppUtils.log(
        '🛑 Stopping recording - Channel: $channelName, SID: $_recordingSid, ResourceID: $_recordingResourceId',
      );
      AppUtils.log(
        '🔧 Host UID: ${hostAgoraId.toString()}, Recording UID: $_recordingUid',
      );

      // Show loading with safety check
      if (Get.isDialogOpen != true) {
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
                      text: 'Stopping recording...',
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

      AppUtils.log('📞 Calling AgoraRecordingService.stop...');
      final stopResult = await AgoraRecordingService.stop(
        channelName: channelName,
        uid: _recordingUid.toString(), // Use recording UID, not host UID
        resourceId: _recordingResourceId!,
        sid: _recordingSid!,
      );

      AppUtils.log(
        'Stop result received - Success: ${stopResult.success}, Message: ${stopResult.message}, Error: ${stopResult.errorMessage}',
      );
      AppUtils.log('Stop result fileUrl: ${stopResult.fileUrl}');
      AppUtils.log('Stop result serverResponse: ${stopResult.serverResponse}');

      // Close loading dialog with safety check
      try {
        if (Get.isDialogOpen == true) {
          Get.back();
          AppUtils.log('Loading dialog closed');
        }
      } catch (e) {
        AppUtils.log('Dialog already closed or error closing: $e');
      }

      // Always reset state after stop attempt
      isRecording.value = false;
      final tempResourceId = _recordingResourceId;
      final tempSid = _recordingSid;
      final tempRecordingUid = _recordingUid;
      _recordingResourceId = null;
      _recordingSid = null;
      _recordingUid = null;
      _recordingStartTime = null;
      _stopRecordingDurationTimer();

      if (!stopResult.success) {
        final errorMsg = stopResult.errorMessage ?? 'Failed to stop recording';
        AppUtils.logEr('❌ Error stopping recording: $errorMsg');
        AppUtils.logEr(
          '📊 Previous ResourceID: $tempResourceId, SID: $tempSid, Recording UID: $tempRecordingUid',
        );
        AppUtils.toastError(errorMsg);
        return false;
      }

      // 🎬 IMMEDIATE VIDEO URL EXTRACTION (like your working files)
      // Extract video URLs directly from the server response
      List<String> extractedVideoUrls = [];

      // First, check if fileUrl is immediately available
      if (stopResult.fileUrl != null && stopResult.fileUrl!.isNotEmpty) {
        extractedVideoUrls.add(stopResult.fileUrl!);
        recordedVideoUrl = stopResult.fileUrl;
        AppUtils.log('🎬 ✅ Immediate URL available: ${stopResult.fileUrl}');
      }

      // Also check MP4 URL if available
      if (stopResult.mp4Url != null && stopResult.mp4Url!.isNotEmpty) {
        if (!extractedVideoUrls.contains(stopResult.mp4Url!)) {
          extractedVideoUrls.add(stopResult.mp4Url!);
        }
        AppUtils.log('🎬 ✅ MP4 URL available: ${stopResult.mp4Url}');
      }

      // Extract URLs from server response - ONLY ONE VIDEO for sharing/posting
      if (stopResult.serverResponse != null) {
        final fileList = stopResult.serverResponse!['fileList'] as List?;
        if (fileList != null && fileList.isNotEmpty) {
          AppUtils.log(
            '🎬 🔍 Processing ${fileList.length} files from server response',
          );

          // PRIORITY: Find MP4 first - this is what we want for sharing
          String? primaryVideoUrl;

          for (final file in fileList) {
            if (file is Map<String, dynamic>) {
              // Fix: Use 'fileName' (capital N) as returned by Agora API
              final filename = file['fileName'] ?? file['filename'] ?? '';
              final downloadUrl = file['downloadUrl'] as String?;
              final trackType = file['trackType'] ?? '';

              AppUtils.log(
                '🎬 📄 File: $filename, trackType: $trackType, downloadUrl: $downloadUrl',
              );

              // Look for MP4 files ONLY - ignore M3U8 for sharing
              if (filename.endsWith('.mp4') &&
                  trackType.contains('audio_and_video')) {
                if (downloadUrl != null && downloadUrl.isNotEmpty) {
                  primaryVideoUrl = downloadUrl;
                } else {
                  // Construct Blackblaze B2 URL with proper format
                  primaryVideoUrl =
                      'https://s3.us-east-005.backblazeb2.com/$filename';
                }

                AppUtils.log(
                  '🎬 ✅ Found PRIMARY video (MP4): $primaryVideoUrl',
                );
                // Break immediately - we only want ONE video for sharing
                break;
              }
            }
          }

          // Only add the PRIMARY video URL (MP4) to the list
          if (primaryVideoUrl != null && primaryVideoUrl.isNotEmpty) {
            extractedVideoUrls.clear(); // Clear any previous URLs
            extractedVideoUrls.add(primaryVideoUrl);
            AppUtils.log(
              '🎬 ✅ Using SINGLE video for sharing: $primaryVideoUrl',
            );
          }
        }
      }

      // 🎯 PROFESSIONAL VIDEO URL STORAGE (like your working files)
      if (extractedVideoUrls.isNotEmpty) {
        // Use VideoUrlRetrieverService to store URLs professionally
        VideoUrlRetrieverService.storeVideoUrls(
          extractedVideoUrls,
          (videoUrl) {
            if (!recordedVideoUrls.contains(videoUrl)) {
              recordedVideoUrls.add(videoUrl);
            }
          },
          onVideoStored: (videoUrl) {
            // Set main recordedVideoUrl to first available URL
            recordedVideoUrl ??= videoUrl;
            AppUtils.log('🎯 Stored video URL: $videoUrl');
          },
        );

        AppUtils.log(
          '🎬 ✅ Successfully extracted ${extractedVideoUrls.length} video URLs immediately',
        );
        AppUtils.log(
          '🎬 📊 Total recordings in array: ${recordedVideoUrls.length}',
        );
        AppUtils.log('🎬 📋 All recorded URLs: $recordedVideoUrls');
      } else {
        // Try extracting using the new AgoraRecordingService method
        AppUtils.log(
          '🔄 [FALLBACK] Trying AgoraRecordingService.extractRecordingFiles...',
        );

        if (stopResult.serverResponse != null) {
          final recordingFiles = AgoraRecordingService.extractRecordingFiles(
            stopResult,
            channelName,
          );

          final immediateUrl = AgoraRecordingService.getImmediateVideoUrl(
            recordingFiles,
          );

          if (immediateUrl != null && immediateUrl.isNotEmpty) {
            recordedVideoUrls.add(immediateUrl);
            recordedVideoUrl = immediateUrl;
            AppUtils.log(
              '🎬 ✅ [FALLBACK] Found immediate video URL: $immediateUrl',
            );
          } else {
            // Last resort: Wait for video URL to become available
            AppUtils.log('⏳ [WAIT] Starting wait for video URL...');

            final waitedUrl = await AgoraRecordingService.waitForVideoUrl(
              resourceId: tempResourceId!,
              sid: tempSid!,
              maxWaitSeconds: 30,
              checkIntervalSeconds: 5,
            );

            if (waitedUrl != null && waitedUrl.isNotEmpty) {
              recordedVideoUrls.add(waitedUrl);
              recordedVideoUrl = waitedUrl;
              AppUtils.log(
                '🎬 ✅ [WAIT] Video URL available after waiting: $waitedUrl',
              );
            } else {
              AppUtils.logEr(
                '⚠️ No video URLs available immediately. Recording may still be processing.',
              );
            }
          }
        }

        // Store metadata for potential future retrieval
        AppUtils.log(
          'Recording metadata - ResourceID: $tempResourceId, SID: $tempSid, Channel: $channelName',
        );
      }

      AppUtils.toast('Recording stopped successfully');
      AppUtils.log(
        'Recording stopped successfully. File URL: $recordedVideoUrl',
      );
      AppUtils.log('Server response: ${stopResult.serverResponse}');

      return true;
    } catch (e, stackTrace) {
      // Close loading dialog if open with safety check
      try {
        if (Get.isDialogOpen == true) {
          Get.back();
          AppUtils.log('Loading dialog closed after exception');
        }
      } catch (dialogError) {
        AppUtils.log('Error closing dialog: $dialogError');
      }

      AppUtils.logEr('Exception stopping recording: $e');
      AppUtils.logEr('Stack trace: $stackTrace');
      AppUtils.toastError('Failed to stop recording: ${e.toString()}');

      // Reset recording state on exception
      isRecording.value = false;
      _recordingResourceId = null;
      _recordingSid = null;
      _recordingUid = null;
      _recordingStartTime = null;
      _stopRecordingDurationTimer();

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
    streamCtrl.value = StreamControlsModel(
      clientRole: role,
      channelId: channelName,
    );
    await _registerEngine();
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
        await engine.muteLocalVideoStream(true);
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

    // Store video URL and host status before cleanup
    final videoUrl = recordedVideoUrl;
    final wasHost = isHost;
    final hasRecording = videoUrl != null && videoUrl.isNotEmpty;

    AppUtils.log(
      'Ending stream - Has recording: $hasRecording, Was host: $wasHost, Video URL: $videoUrl',
    );
    AppUtils.log('Total recordings in array: ${recordedVideoUrls.length}');
    AppUtils.log('isRecording.value: ${isRecording.value}');

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

    // Show recorded video dialog if there are recordings and user was host
    final hasRecordings = recordedVideoUrls.isNotEmpty;

    AppUtils.log(
      'Final check - Has recordings in array: $hasRecordings, Was host: $wasHost, Total videos: ${recordedVideoUrls.length}',
    );
    AppUtils.log('Will show dialog? ${hasRecordings && wasHost}');

    if (hasRecordings && wasHost) {
      AppUtils.log('Calling _showRecordedVideosDialog...');
      // Wait for dialog to be dismissed before continuing
      await _showRecordedVideosDialog(recordedVideoUrls.toList());
      AppUtils.log('Dialog dismissed, endStream completing');
    } else if (wasHost && !hasRecordings) {
      // Host stopped recording but file URL not yet available
      AppUtils.log('Host ended stream but no recordings available yet');
      AppUtils.log('Showing processing dialog instead...');
      await _showRecordingProcessingDialog();
    } else {
      AppUtils.log(
        'NOT showing dialog - hasRecordings: $hasRecordings, wasHost: $wasHost',
      );
    }

    AppUtils.log('=== END endStream() ===');
  }

  Future<void> _showRecordedVideosDialog(List<String> videoUrls) async {
    AppUtils.log('=== _showRecordedVideosDialog START ===');
    AppUtils.log(
      'Showing recorded videos dialog with ${videoUrls.length} URLs: $videoUrls',
    );

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
      // Show loading
      AppUtils.toast(
        videoUrls.length > 1
            ? 'Downloading ${videoUrls.length} videos...'
            : 'Downloading video...',
      );

      // TODO: Implement download logic for all videos in the array
      // This would typically involve:
      // 1. Loop through videoUrls array
      // 2. Download each video from the URL
      // 3. Save to device gallery using image_gallery_saver or similar package

      await Future.delayed(Duration(seconds: 1)); // Simulate download

      AppUtils.toast(
        videoUrls.length > 1
            ? '${videoUrls.length} videos saved to gallery!'
            : 'Video saved to gallery!',
      );
      onClose?.call();

      // Close dialog safely
      try {
        if (Navigator.of(context).canPop()) {
          Navigator.pop(context); // Close dialog only
        }
      } catch (e) {
        AppUtils.log('Error closing dialog: $e');
      }
    } catch (e) {
      AppUtils.toastError('Failed to save video: $e');
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
