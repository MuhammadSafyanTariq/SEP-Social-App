import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';

import '../../../services/storage/preferences.dart';
import '../controller/agora_chat_ctrl.dart';
import 'helper/video_stream_frame.dart';
import 'live_stream_ctrl.dart';
import '../../../components/coreComponents/TextView.dart';
import '../Add post/CreatePost.dart';

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
    _initializeStream();
  }

  Future<void> _initializeStream() async {
    // Check camera and microphone permissions before initializing
    final hasPermission = await StreamUtils.checkPermission();

    if (!hasPermission) {
      // Permission denied, show message and go back
      if (mounted) {
        AppUtils.toastError(
          'Camera and microphone permissions are required for live streaming',
        );
        Navigator.pop(context);
      }
      return;
    }

    // Permissions granted, proceed with initialization
    WakelockPlus.enable();
    AgoraChatCtrl.find.chatConnection = false;
    ctrl.initBroadCast(
      widget.clientRole,
      widget.hostId ?? Preferences.uid ?? '',
      isHost: widget.isHost,
    );

    // Mark initialization complete
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }

    // if(widget.clientRole == ClientRoleType.clientRoleAudience || (widget.hostId ?? '') == Preferences.uid ){
    if (!widget.isHost) {
      AppUtils.log('testing step 1111   ${widget.isHost}');
      _createChatConnection();
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

    // Show post-stream dialog if there's a recording and user is host
    if (widget.isHost && ctrl.recordedVideoPath != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPostStreamDialog();
      });
    }

    LiveStreamCtrl.clear;
    ctrl.endStream();

    super.dispose();
  }

  void _showPostStreamDialog() {
    final videoPath = ctrl.recordedVideoPath;
    if (videoPath == null) return;

    // Check if video is still processing
    if (videoPath == 'processing') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: TextView(
            text: 'Recording Processing',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              TextView(
                text:
                    'Your recording is being processed. It will be available in cloud storage shortly.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async {
          // Ask for confirmation before closing
          final shouldClose = await _showDiscardConfirmation();
          return shouldClose;
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: TextView(
            text: 'Stream Ended',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextView(
                text:
                    'Your stream has been recorded and saved to cloud storage.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 8),
              TextView(
                text: 'What would you like to do?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('Close', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                // Copy video URL to clipboard or show it
                AppUtils.toast('Video URL: $videoPath');
                AppUtils.log('Cloud Recording URL: $videoPath');
              },
              child: Text('View URL', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                // Navigate to create post with video URL
                // You can pass the videoPath (URL) to your post creation screen
                context.pushNavigator(
                  CreatePost(
                    categoryid: '',
                    // Add video URL parameter if your CreatePost supports it
                  ),
                );
              },
              child: Text('Share', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDiscardConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: TextView(
          text: 'Leave Stream?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: TextView(
          text:
              'Are you sure you want to leave? The recording is saved in cloud storage.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('No', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Yes, Leave', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking permissions
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 20),
              TextView(
                text: 'Checking permissions...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return InstagramLiveFrame(
      hostName: widget.hostName,
      clientRole: widget.clientRole,
      connectChatOnStartLive: widget.isHost ? _createChatConnection : null,
    );
  }
}
