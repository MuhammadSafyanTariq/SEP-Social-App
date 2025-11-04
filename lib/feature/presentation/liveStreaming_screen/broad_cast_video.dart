import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../services/storage/preferences.dart';
import '../controller/agora_chat_ctrl.dart';
import 'helper/video_stream_frame.dart';
import 'live_stream_ctrl.dart';

class BroadCastVideo extends StatefulWidget {
  final String? hostId;
  final String? hostName;
  final ClientRoleType clientRole;
  final bool isHost;

  const BroadCastVideo({
    super.key,
    required this.clientRole,
    this.hostId,
    this.hostName,
    this.isHost = false,
  });

  @override
  State<BroadCastVideo> createState() => _BroadCastVideoState();
}

class _BroadCastVideoState extends State<BroadCastVideo> {
  final ctrl = LiveStreamCtrl.find;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeBroadcast();
  }

  Future<void> _initializeBroadcast() async {
    print('BroadCastVideo: Starting _initializeBroadcast');

    try {
      WakelockPlus.enable();
      AgoraChatCtrl.find.chatConnection = false;

      print('BroadCastVideo: Calling ctrl.initBroadCast...');
      // Wait for engine initialization to complete
      await ctrl.initBroadCast(
        widget.clientRole,
        widget.hostId ?? Preferences.uid ?? '',
        isHost: widget.isHost,
      );
      print('BroadCastVideo: initBroadCast completed');

      setState(() {
        _isInitializing = false;
      });
      print('BroadCastVideo: Set _isInitializing to false');

      // if(widget.clientRole == ClientRoleType.clientRoleAudience || (widget.hostId ?? '') == Preferences.uid ){
      if (!widget.isHost) {
        AppUtils.log('testing step 1111   ${widget.isHost}');
        _createChatConnection();
      }

      print('BroadCastVideo: _initializeBroadcast completed successfully');
    } catch (e) {
      print('BroadCastVideo: Error in _initializeBroadcast: $e');
      // Keep showing loading spinner on error
      AppUtils.toastError('Failed to initialize live stream: $e');
    }
  }

  void _createChatConnection() {
    print('calll for data.....');
    AgoraChatCtrl.find.connectAndJoin(
      widget.hostId ?? Preferences.uid ?? '',
      Preferences.profile?.name ?? 'Guest',
    );
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    AgoraChatCtrl.find.leaveRoom();
    LiveStreamCtrl.clear;
    // Don't call endStream here to prevent duplicate dialog
    // endStream is handled by UI close button

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return InstagramLiveFrame(
      hostName: widget.hostName,
      clientRole: widget.clientRole,
      connectChatOnStartLive: widget.isHost ? _createChatConnection : null,
    );
  }
}
