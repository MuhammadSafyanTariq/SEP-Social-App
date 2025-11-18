import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/EditText.dart';

import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';

import 'package:sep/utils/extensions/textStyle.dart';

import '../../../../components/coreComponents/ImageView.dart';
import '../../../../components/coreComponents/TextView.dart';
import '../../../../components/styles/appColors.dart';
import '../../../../components/styles/appImages.dart';
import '../../../../services/storage/preferences.dart';
import '../../../data/models/dataModels/live_stream_message_model/live_stream_message_model.dart';
import '../live_stream_ctrl.dart';
import '../../../data/models/dataModels/profile_data/profile_data_model.dart';
import '../../controller/agora_chat_ctrl.dart';
import '../../wallet/add_card_screen.dart';
import '../live_stream_ctrl.dart';
import 'helper_broadcast.dart';

class InstagramLiveFrame extends StatefulWidget {
  final ClientRoleType clientRole;
  final String? hostName;
  final Function()? connectChatOnStartLive;

  const InstagramLiveFrame({
    super.key,
    required this.clientRole,
    required this.connectChatOnStartLive,
    this.hostName,
  });

  @override
  State<InstagramLiveFrame> createState() => _InstagramLiveFrameState();
}

class _InstagramLiveFrameState extends State<InstagramLiveFrame>
    with SingleTickerProviderStateMixin {
  final ctrl = LiveStreamCtrl.find;
  final chatCtrl = AgoraChatCtrl.find;

  String get hostName =>
      ctrl.hostProfileData.value.name ??
      widget.hostName ??
      Preferences.profile?.name ??
      '';

  String? get hostProfileImage {
    final file =
        (ctrl.hostProfileData.value.image.isNotNullEmpty
                ? ctrl.hostProfileData.value.image
                : (ctrl.isHost ? Preferences.profile?.image : null))
            .fileUrl;

    if (!file.isNotNullEmpty && ctrl.isHost) {
      return ProfileCtrl.find.profileData.value.image.isNotNullEmpty
          ? ProfileCtrl.find.profileData.value.image.fileUrl
          : null;
    }

    AppUtils.log('host profile data ..... $file');
    return file;
  }

  ClientRoleType get clientRole =>
      ctrl.streamCtrl.value.clientRole ?? ClientRoleType.clientRoleAudience;

  bool get isBroadcaster => clientRole == ClientRoleType.clientRoleBroadcaster;

  bool get isLiveNow =>
      (isBroadcaster && ctrl.streamCtrl.value.localChannelJoined) ||
      clientRole == ClientRoleType.clientRoleAudience;

  bool chatConnected = false;

  bool _inComingRequestFlag = false;

  // State for collapsible right controls
  bool _rightControlsCollapsed = false;
  bool _keyboardVisible = false;

  // Pagination state for video grid
  int _currentVideoPage = 0;
  static const int _maxUsersPerPage = 4;

  void onJoinHandler() {
    if (ctrl.isHost && !chatConnected) {
      ctrl.streamCtrl.listen((value) {
        if (isLiveNow) {
          AppUtils.logg('testing step 222222');
          chatConnected = true;
          widget.connectChatOnStartLive?.call();
        }
      });
    }
  }

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    onJoinHandler();
    chatCtrl.incomingLiveRequestToHostStream.listen((data) {
      if (!_inComingRequestFlag) {
        openIncomingLiveRequestBS(data);
      }
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // listen for when animation completes one loop
    // _controller.addStatusListener((status) {
    //   // if (status == AnimationStatus.completed) {
    //   //   if (loopCounts> 0) {
    //   //     _controller.forward(from: 0);
    //   //   } else {
    //   //     _playNext();
    //   //   }
    //   // }
    // });

    ever(chatCtrl.coinsAnimationList, (list) {
      if (list != 0 && !_controller.isAnimating) {
        _playNext();
      }
    });
  }

  int get loopCounts {
    final count = chatCtrl.coinsAnimationList.value;
    // if (count > 0 && !_controller.isAnimating) {
    //   _playNext();
    // }
    // if(!_controller.isAnimating){
    //   _playNext();
    // }
    return count;
  }

  // List<String> get _queue {
  //   final list = chatCtrl.coinsAnimationList;
  //   if (_currentId == null && list.isNotEmpty) {
  //    AppUtils.logg('callPlayAgain');
  //     _playNext();
  //   }
  //   return list;
  // }

  void _playNext() {
    if (chatCtrl.coinsAnimationList.value == 0) return;
    _controller
      ..reset()
      ..forward().whenComplete(() {
        // decrement
        chatCtrl.coinsAnimationList.value--;

        // continue if more items left
        if (chatCtrl.coinsAnimationList.value > 0) {
          _playNext();
        }
      });

    // _controller.reset();
    // _controller.forward().whenComplete(() {
    //   chatCtrl.coinsAnimationList.value = chatCtrl.coinsAnimationList.value -1;
    //   // Play next item AFTER current animation ends
    //   if(chatCtrl.coinsAnimationList.value != 0){
    //     _playNext();
    //   }
    //
    // });

    // if(loopCounts> 0){
    //   chatCtrl.coinsAnimationList.value -= 1;
    //   _controller.forward(from: 0);
    // }

    // try{
    //   if (_queue.isEmpty) {
    //     _currentId = null; // nothing left to play
    //     return;
    //   }
    //   if(chatCtrl.coinsAnimationList.isNotEmpty){
    //     _currentId = chatCtrl.coinsAnimationList.removeAt(0);
    //     _loopCount = 0;
    //     _controller.forward(from: 0);
    //   }
    // }catch(e){
    //
    // }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Detect keyboard visibility
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final newKeyboardVisible = keyboardHeight > 0;

    if (newKeyboardVisible != _keyboardVisible) {
      _keyboardVisible = newKeyboardVisible;
      // Auto-collapse controls when keyboard opens, expand when closes
      if (_keyboardVisible) {
        _rightControlsCollapsed = true;
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Main Content: Video Grid and Chat Sections
          Column(
            children: [
              // TOP HALF: Video Grid Section
              Expanded(flex: 1, child: _buildCameraView()),

              // BOTTOM HALF: Messaging Section
              Expanded(
                flex: 1,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate responsive heights
                    final screenHeight = MediaQuery.of(context).size.height;
                    final keyboardHeight = MediaQuery.of(
                      context,
                    ).viewInsets.bottom;
                    final isKeyboardOpen = keyboardHeight > 0;

                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF1a1a2e).withValues(alpha: 0.95),
                            Color(0xFF16213e).withValues(alpha: 0.98),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Chat Messages (takes most of bottom half)
                          Expanded(child: _buildChatList(context)),

                          // Chat Input Box and Controls (compact at bottom)
                          _buildBottomBar(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Overlays that span entire screen
          // Coin Animation
          Obx(
            () => loopCounts > 0
                ? Positioned(
                    right: 0,
                    top: context.getHeight / 5,
                    bottom: context.getHeight / 2,
                    child: coinAnimation(),
                  )
                : SizedBox.shrink(),
          ),

          // App Bar (Host info, Live status, Close button)
          widget.clientRole == ClientRoleType.clientRoleAudience
              ? _buildAppBar(context, isLiveNow)
              : Obx(() => _buildAppBar(context, isLiveNow)),

          // Video Controls (Right side) - Overlay entire screen
          _buildVideoControls(context),

          // Left Action Buttons (for Host) - Overlay entire screen
          _leftActionButtonsForHost(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
    );
  }

  Widget _buildCameraView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Obx(() {
          return buildVideoGrid(ctrl.getBroadcasters);
        });
      },
    );
  }

  Widget buildVideoGrid(List<RemoteUserAgora> uids) {
    int count = uids.length;

    AppUtils.log('buildVideoGrid called with ${count} users');
    for (int i = 0; i < uids.length; i++) {
      AppUtils.log(
        'User $i: id=${uids[i].id}, videoState=${uids[i].videoState?.name}, audioState=${uids[i].audioState?.name}',
      );
    }

    if (count == 0) {
      AppUtils.log('No users to display - showing "No users" message');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off, size: 64, color: Colors.white54),
            SizedBox(height: 16),
            Text(
              "Waiting for stream...",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              "The broadcaster will appear here",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                AppUtils.log(
                  'Refresh button pressed - triggering manual refresh',
                );
                ctrl.streamCtrl.refresh();
                // Try to force add host if still no remote users
                if ((ctrl.streamCtrl.value.remoteIds?.isEmpty ?? true) &&
                    !ctrl.isHost) {
                  AppUtils.log(
                    'Manual refresh: No remote users, attempting to add host',
                  );
                  final hostUser = RemoteUserAgora(
                    id: ctrl.hostAgoraId,
                    audioState: RemoteAudioState.remoteAudioStateStarting,
                    videoState: RemoteVideoState.remoteVideoStateStarting,
                    channelId: ctrl.streamCtrl.value.channelId,
                  );

                  final remoteIds =
                      (ctrl.streamCtrl.value.remoteIds ?? <RemoteUserAgora>{})
                        ..add(hostUser);
                  ctrl.streamCtrl.value.remoteIds = remoteIds;
                  ctrl.streamCtrl.refresh();
                }
              },
              icon: Icon(Icons.refresh),
              label: Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white24,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // Pagination: Show max 4 users per page
    final totalPages = (count / _maxUsersPerPage).ceil();

    // Ensure current page is valid
    if (_currentVideoPage >= totalPages) {
      _currentVideoPage = totalPages - 1;
    }
    if (_currentVideoPage < 0) {
      _currentVideoPage = 0;
    }

    final startIndex = _currentVideoPage * _maxUsersPerPage;
    final endIndex = (startIndex + _maxUsersPerPage).clamp(0, count);
    final visibleUsers = uids.sublist(startIndex, endIndex);

    return Stack(
      children: [
        // Video Grid
        _buildGridForUsers(visibleUsers),

        // Pagination Controls (only show if more than 4 users)
        if (totalPages > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Previous button
                    IconButton(
                      icon: Icon(Icons.chevron_left, color: Colors.white),
                      onPressed: _currentVideoPage > 0
                          ? () {
                              setState(() {
                                _currentVideoPage--;
                              });
                            }
                          : null,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),

                    SizedBox(width: 8),

                    // Page indicator
                    Text(
                      '${_currentVideoPage + 1} / $totalPages',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(width: 8),

                    // Next button
                    IconButton(
                      icon: Icon(Icons.chevron_right, color: Colors.white),
                      onPressed: _currentVideoPage < totalPages - 1
                          ? () {
                              setState(() {
                                _currentVideoPage++;
                              });
                            }
                          : null,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGridForUsers(List<RemoteUserAgora> uids) {
    int count = uids.length;

    if (count == 0) {
      return SizedBox();
    }

    if (count == 1) {
      // One user: full screen
      return Column(
        children: [Expanded(child: _agoraVideoViewWidget(uid: uids[0]))],
      );
    }

    if (count == 2) {
      // Two users: stacked full width or side by side
      return Column(
        children: [
          Expanded(child: _agoraVideoViewWidget(uid: uids[0])),
          Expanded(child: _agoraVideoViewWidget(uid: uids[1])),
        ],
      );
    }

    if (count == 3) {
      // Three users: first full width, bottom two side by side
      return Column(
        children: [
          Expanded(child: _agoraVideoViewWidget(uid: uids[0])),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _agoraVideoViewWidget(uid: uids[1])),
                Expanded(child: _agoraVideoViewWidget(uid: uids[2])),
              ],
            ),
          ),
        ],
      );
    }

    if (count == 4) {
      // Four users: 2x2 grid
      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _agoraVideoViewWidget(uid: uids[0])),
                Expanded(child: _agoraVideoViewWidget(uid: uids[1])),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _agoraVideoViewWidget(uid: uids[2])),
                Expanded(child: _agoraVideoViewWidget(uid: uids[3])),
              ],
            ),
          ),
        ],
      );
    }

    return SizedBox();
  }

  Widget _agoraVideoViewWidget({required RemoteUserAgora uid}) {
    final isLocal = uid.id == 0;
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: AgoraVideoView(
        controller: isLocal
            ? VideoViewController(
                rtcEngine: ctrl.engine,
                canvas: const VideoCanvas(uid: 0),
              )
            : VideoViewController.remote(
                rtcEngine: ctrl.engine,
                canvas: VideoCanvas(uid: uid.id),
                connection: RtcConnection(
                  channelId: ctrl.streamCtrl.value.channelId,
                ),
              ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isLive) {
    return Positioned(
      top: context.topSafeArea + 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => ImageView(
              url: hostProfileImage ?? '',
              size: 40,
              radius: 20,
              fit: BoxFit.cover,
              imageType: ImageType.network,
              defaultImage: AppImages.dummyProfile,
              margin: const EdgeInsets.only(right: 10),
            ),
          ),
          Expanded(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextView(
                    text: hostName,
                    style: 18.txtSBoldBlack.withShadow(AppColors.grey),
                  ),
                  // Show title from backend if available - reactive with Obx
                  Obx(() {
                    final title = chatCtrl.currentStreamTitle;
                    print('VideoStreamFrame: currentStreamTitle = "$title"');
                    print('VideoStreamFrame: title isEmpty = ${title.isEmpty}');
                    print(
                      'VideoStreamFrame: currentLiveRoomInfo = ${chatCtrl.currentLiveRoomInfo.value}',
                    );
                    return title.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: TextView(
                              text: "📺 $title",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.8),
                                    offset: Offset(1, 1),
                                    blurRadius: 3,
                                  ),
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    offset: Offset(0, 0),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ),
          Visibility(visible: isLive, child: LiveStatusButtons()),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () async {
              // End stream and wait for dialog to be dismissed
              await ctrl.endStream();
              // Now pop the stream screen
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: CircleAvatar(
              backgroundColor: AppColors.grey.withValues(alpha: 0.35),
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget coinAnimation() {
    return Container(
      // color: Colors.red,
      child: Lottie.asset(
        AppImages.coinAnimationLottie,
        // repeat: true,
        // animate: true,
        controller: _controller,
        // onLoaded: (composition) {
        //   _controller
        //     ..duration = composition.duration
        //     ..forward(); // start first loop
        // },

        // frameRate:fr.FrameRate.max,
      ),
    );
  }

  Widget _buildBottomBar() {
    return !ctrl.isHost
        ? _chatBox()
        : Obx(
            () => isBroadcaster && !ctrl.streamCtrl.value.localChannelJoined
                ? StartStreamButton(
                    onPressed: () async {
                      // Check permissions before starting stream
                      final hasPermissions =
                          await StreamUtils.checkPermission();
                      if (!hasPermissions) {
                        AppUtils.toastError(
                          'Camera and microphone permissions are required to start the stream',
                        );
                        return;
                      }

                      // Start the stream
                      await ctrl.joinChannel();
                    },
                  )
                : _chatBox(),
          );
  }

  Widget _chatBox() {
    // Get screen dimensions for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isShortScreen = screenHeight < 700;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: isSmallScreen ? 8 : 12,
        right: isSmallScreen ? 8 : 12,
        top: isShortScreen ? 6 : 8,
        bottom: keyboardHeight > 0 ? 8 : (isShortScreen ? 6 : 8),
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: isSmallScreen ? 44 : 48,
                  minHeight: 40,
                ),
                child: ChatInputBox(),
              ),
            ),
            // Spacing
            SizedBox(width: isSmallScreen ? 6 : 8),

            // Token button (for non-hosts)
            Visibility(
              visible: !ctrl.isHost,
              child: GestureDetector(
                onTap: openTokenBottomSheet,
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 5 : 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    color: Colors.black.withOpacity(0.3),
                  ),
                  child: ImageView(
                    url: AppImages.token,
                    size: isSmallScreen ? 18 : 20,
                  ),
                ),
              ),
            ),

            // Spacing before video request button
            if (!ctrl.isHost) SizedBox(width: isSmallScreen ? 6 : 8),

            // Video request button (for non-hosts)
            Visibility(
              visible: !ctrl.isHost,
              child: Obx(
                () => GestureDetector(
                  onTap: ctrl.videoRequestButtonEnable.isTrue
                      ? () {
                          if (ctrl.streamCtrl.value.clientRole ==
                              ClientRoleType.clientRoleAudience) {
                            if (ctrl.getBroadcasters.length <
                                broadCastUserMaxLimit) {
                              openLiveRequestBS();
                            }
                          } else {
                            ctrl.changeRole();
                            AgoraChatCtrl.find.leaveAudienceLiveCamera(
                              LiveRequestStatus.end,
                            );
                          }
                        }
                      : null,
                  child: Container(
                    padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.3),
                    ),
                    child: ImageView(
                      url:
                          ctrl.streamCtrl.value.clientRole ==
                              ClientRoleType.clientRoleAudience
                          ? AppImages.videoRequest
                          : AppImages.offVideo,
                      size: isSmallScreen ? 24 : 28,
                      tintColor: ctrl.videoRequestButtonEnable.isTrue
                          ? (ctrl.streamCtrl.value.clientRole ==
                                    ClientRoleType.clientRoleAudience
                                ? ctrl.getBroadcasters.length <
                                          broadCastUserMaxLimit
                                      ? Colors.red
                                      : Colors.grey.withValues(alpha: 0.2)
                                : Colors.red)
                          : Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void openLiveRequestBS() {
    context.openBottomSheet(_sendRequestBSView());
  }

  void acceptLiveRequestByHost(LiveStreamMessageModel msgData) {
    AgoraChatCtrl.find.hostRequestActive(
      LiveRequestStatus.allowed,
      msgData.id!,
      msgData.userId!,
    );
  }

  void declineLiveRequestByHost(LiveStreamMessageModel msgData) {
    AgoraChatCtrl.find.hostRequestActive(
      LiveRequestStatus.rejected,
      msgData.id!,
      msgData.userId!,
    );
  }

  void openIncomingLiveRequestBS(LiveStreamMessageModel msgData) {
    _inComingRequestFlag = true;
    context
        .openBottomSheet(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () {
                      context.pop();
                    },
                    icon: Icon(Icons.close, size: 30, color: Colors.black),
                  ),
                ),
                _userImage(msgData.userId, size: 100),

                // ImageView(
                //   // url: ctrl.hostProfileData.value.image.fileUrl ?? '',
                //   // url: msgData..fileUrl ?? '',
                //   url:'',
                //   size: 100,
                //   radius: 50,
                //   imageType: ImageType.network,
                //   defaultImage: AppImages.profile,
                //   fit: BoxFit.cover,
                // ),
                TextView(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  text: '${msgData.userName} request to join live session',
                  style: 18.txtBoldBlack,
                ),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        buttonColor: AppColors.red,
                        label: 'Decline',
                        onTap: () {
                          declineLiveRequestByHost(msgData);
                          context.pop();
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: AppButton(
                        buttonColor: AppColors.btnColor,
                        label: 'Accept',
                        onTap: () {
                          acceptLiveRequestByHost(msgData);
                          context.pop();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
        .whenComplete(() {
          _inComingRequestFlag = false;
        });
  }

  Widget _sendRequestBSView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextView(
            text: 'Request to be in this live video',
            style: 20.txtBoldBlack,
          ),
          AppButton(
            margin: EdgeInsets.symmetric(vertical: 20),
            label: 'Send Request',
            onTap: () {
              AgoraChatCtrl.find.sendLiveRequest();
              context.pop();
            },
          ),
          TextView(onTap: context.pop, text: 'Cancel', style: 18.txtboldred),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildChatList(BuildContext context) {
    // Get screen dimensions for responsive padding
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      // Takes available space in bottom half
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 6 : 8,
      ),
      child: Obx(() {
        final messages = chatCtrl.chatList;

        // Debug: Show message count
        print('Chat messages count: ${messages.length}');

        if (messages.isEmpty) {
          return Center(
            child: TextView(
              text: 'No messages yet. Start chatting!',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          );
        }

        return ListView.separated(
          reverse: true,
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 8),
          itemCount: messages.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, index) {
            final msg = messages.reversed.toList()[index];

            if (msg.type == 'system') {
              return Center(
                child: TextView(
                  text: msg.message ?? '',
                  style: 14.txtBoldWhite.withShadow(AppColors.grey),
                ),
              );
            }
            if (msg.type == 'liveRequest') {
              final liveRequestStatus = LiveRequestStatus.values.indexWhere(
                (element) => element.name == msg.message,
              );

              return Column(
                children: [
                  Row(
                    children: [
                      _userImage(msg.userId),
                      Expanded(
                        child: TextView(
                          text: liveRequestStatus == 0
                              ? '${msg.userName} sent a request to be in your live video.'
                              : liveRequestStatus == 1
                              ? '${msg.userName} is live in video'
                              : liveRequestStatus == 2
                              ? 'Host rejected live request'
                              : liveRequestStatus == 3
                              ? 'UserName joined the live video.'
                              : liveRequestStatus == 4
                              ? 'request Expired'
                              : liveRequestStatus == 5
                              ? '${msg.userName} leave from live video.'
                              : liveRequestStatus == 6
                              ? 'Admin remove ${msg.userName} from live video'
                              : '',
                          style: 14.txtBoldWhite.withShadow(AppColors.grey),
                        ),
                      ),
                      Visibility(
                        visible:
                            Preferences.uid == msg.userId &&
                            liveRequestStatus == 0,
                        child: _requestBtn('Requested', AppColors.grey, () {}),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: ctrl.isHost && liveRequestStatus == 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _requestBtn('Approve', AppColors.green, () {
                          acceptLiveRequestByHost(msg);
                        }),
                        SizedBox(width: 16),
                        _requestBtn('Reject', AppColors.red, () {
                          declineLiveRequestByHost(msg);
                        }),
                      ],
                    ),
                  ),
                ],
              );
            }
            if (msg.type == GiftTokenEnum.giftToken.name) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 4),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    _userImage(msg.userId),
                    Expanded(
                      child: Row(
                        children: [
                          TextView(
                            text: '${msg.userName} sent ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          TextView(
                            text: '${msg.message}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 4),
                          ImageView(url: AppImages.token, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _userImage(msg.userId),
                      Expanded(
                        child: TextView(
                          text: msg.userName ?? '',
                          style: 16.txtBoldWhite.withShadow(AppColors.grey),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  TextView(
                    text: msg.message ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _requestBtn(String label, Color color, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: TextView(text: label),
      ),
    );
  }

  Widget _leftActionButtonsForHost() {
    return Obx(() {
      final isJoined = ctrl.streamCtrl.value.localChannelJoined;
      final hasVisibleBroadcasters =
          ctrl.getLiveBroadcastersVisibleToHost.isNotEmpty;

      // Only show for host after stream has started and has visible broadcasters
      if (!ctrl.isHost || !isJoined || !hasVisibleBroadcasters) {
        return Positioned(top: 0, left: 0, child: const SizedBox.shrink());
      }

      return Positioned(
        top: context.topSafeArea + 120,
        left: 16,
        right: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconControl(
              url: AppImages.broadcaster,
              onTap: () => _openInviteBottomSheet(forGetLiveBroadcaster: true),
            ),
          ],
        ),
      );
    });
  }

  List<int> tokens = [10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000];
  RxnInt selectedToken = RxnInt();

  void openTokenBottomSheet() {
    selectedToken.value = null;
    final TextEditingController customAmountController =
        TextEditingController();
    RxBool useCustomAmount = false.obs;

    context.openBottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                ImageView(
                  url: AppImages.token,
                  size: 30,
                  margin: EdgeInsets.only(right: 8),
                ),
                Expanded(
                  child: TextView(
                    text: 'Send Tokens',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, size: 30, color: Colors.grey),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Token Amount Selection
            TextView(
              text: 'Select Amount',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 12),

            // Pre-defined amounts
            Obx(
              () => !useCustomAmount.value
                  ? SizedBox(
                      height: 120,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 2.5,
                        ),
                        itemCount: tokens.length,
                        itemBuilder: (context, index) {
                          final token = tokens[index];
                          return Obx(
                            () => GestureDetector(
                              onTap: () => selectedToken.value = token,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: selectedToken.value == token
                                      ? AppColors.primaryColor
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                  border: selectedToken.value == token
                                      ? Border.all(
                                          color: AppColors.primaryColor,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            AppImages.token,
                                            width: 16,
                                            height: 16,
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 4),
                                      TextView(
                                        text: '$token',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: selectedToken.value == token
                                              ? Colors.white
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: TextField(
                        controller: customAmountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(12),
                            child: ImageView(
                              url: AppImages.token,
                              size: 20,
                              fit: BoxFit.contain,
                            ),
                          ),
                          hintText: 'Enter custom amount',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          final amount = int.tryParse(value);
                          selectedToken.value = amount;
                        },
                      ),
                    ),
            ),

            // Custom amount toggle
            Obx(
              () => GestureDetector(
                onTap: () {
                  useCustomAmount.value = !useCustomAmount.value;
                  if (!useCustomAmount.value) {
                    customAmountController.clear();
                    selectedToken.value = null;
                  }
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: useCustomAmount.value
                        ? AppColors.primaryColor
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextView(
                    text: useCustomAmount.value
                        ? 'Use Quick Select'
                        : 'Custom Amount',
                    style: TextStyle(
                      fontSize: 14,
                      color: useCustomAmount.value
                          ? Colors.white
                          : Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Send Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: selectedToken.value != null
                      ? 'Send ${selectedToken.value} Tokens'
                      : 'Select Amount',
                  buttonColor: selectedToken.value != null
                      ? AppColors.primaryColor
                      : Colors.grey,
                  onTap: selectedToken.value != null
                      ? () => _sendTokens()
                      : null,
                ),
              ),
            ),

            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _sendTokens() {
    if (selectedToken.value == null) return;

    // Send tokens to broadcaster (host)
    // Get the host's user ID from broadcasters list
    final hostId = ctrl.getBroadcasters.isNotEmpty
        ? ctrl.getBroadcasters.first.id.toString()
        : (ctrl.hostProfileData.value.id ?? '');

    ctrl.sendGiftToken(
      selectedToken.value!.toString(),
      hostId,
      onInsufficientBalance: (msg) {
        context.openDialog(
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextView(
                        text: 'Insufficient Token Balance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, size: 25, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextView(
                  text: msg,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 20),
                AppButton(
                  label: 'Add Tokens',
                  onTap: () {
                    Navigator.pop(context);
                    context.pushNavigator(AddCreditCardScreen());
                  },
                ),
              ],
            ),
          ),
        );
      },
      onTransactionSuccess: () {
        Navigator.pop(context);
        // Send token message in chat
        _sendTokenMessage();
      },
    );
  }

  void _sendTokenMessage() {
    // Token message is automatically sent by giftTokenEmitter in sendGiftToken method
    // This method is kept for future customization if needed
  }

  void _openInviteBottomSheet({
    bool forInviteFriend = false,
    bool forGetLiveBroadcaster = false,
  }) async {
    List<ProfileDataModel> friends = [];

    if (forInviteFriend) {
      friends = await ctrl.getFriends().applyLoader;
    }

    if (forGetLiveBroadcaster) {
      friends = ctrl.getLiveBroadcastersVisibleToHost;
    }

    if (friends.isEmpty) return;

    if (!mounted) return;
    context.openBottomSheet(
      DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        // adjust as needed
        minChildSize: 0.8,
        maxChildSize: 0.8,
        builder: (context, scrollController) {
          return _FriendBottomSheets(
            forGetLiveBroadcaster: forGetLiveBroadcaster,
            forInviteFriend: forInviteFriend,
            ctrl: ctrl,
            friends: friends,
          );
        },
      ),
    );
  }

  Widget _buildVideoControls(BuildContext context) {
    return Obx(() {
      if ((!ctrl.streamCtrl.value.localChannelJoined) ||
          ctrl.streamCtrl.value.clientRole ==
              ClientRoleType.clientRoleAudience) {
        return Positioned(
          top: 0,
          right: 0,
          child: SizedBox(height: 0, width: 0),
        );
      }
      return Positioned(
        top: context.topSafeArea + 120,
        right: 16,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Collapse/Expand Button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _rightControlsCollapsed = !_rightControlsCollapsed;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _rightControlsCollapsed
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_up_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              if (!_rightControlsCollapsed) ...[
                SizedBox(height: 8),
                // Recording button (only for host)
                Visibility(
                  visible: ctrl.isHost,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => ctrl.toggleRecording(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ctrl.isRecording.value
                                ? Colors.red.withValues(alpha: 0.9)
                                : Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            ctrl.isRecording.value
                                ? Icons.stop_rounded
                                : Icons.fiber_manual_record_rounded,
                            size: 28,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      if (ctrl.isRecording.value)
                        Padding(
                          padding: EdgeInsets.only(top: 4, bottom: 8),
                          child: Obx(
                            () => TextView(
                              text: ctrl.recordingDuration.value,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      if (!ctrl.isRecording.value) SizedBox(height: 16),
                    ],
                  ),
                ),
                IconControl(
                  icon:
                      ctrl.streamCtrl.value.localVideoState ==
                          LocalVideoStreamState.localVideoStreamStateStopped
                      ? Icons.videocam_off
                      : Icons.videocam,
                  onTap: ctrl.onVideoAction,
                ),
                SizedBox(height: 8),
                IconControl(
                  icon:
                      ctrl.streamCtrl.value.localMicState ==
                          LocalAudioStreamState.localAudioStreamStateStopped
                      ? Icons.mic_off
                      : Icons.mic,
                  onTap: ctrl.micButtonAction,
                ),
                SizedBox(height: 8),
                IconControl(
                  icon: Icons.flip_camera_android_sharp,
                  onTap: ctrl.cameraFlip,
                ),
                Visibility(
                  visible: ctrl.isHost,
                  child: Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Column(
                      children: [
                        // Invite button
                        IconControl(
                          url: AppImages.inviteToVideo,
                          onTap: () =>
                              _openInviteBottomSheet(forInviteFriend: true),
                        ),
                        SizedBox(height: 12),
                        // Token display with updated icon
                        Column(
                          children: [
                            ImageView(url: AppImages.token, size: 40),
                            SizedBox(height: 4),
                            Obx(
                              () => TextView(
                                text:
                                    '${AgoraChatCtrl.find.hostGiftAmountTotal}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ], // Close the conditional block for !_rightControlsCollapsed
            ],
          ),
        ),
      );
    });
  }
}

// {"status":false,"code":400,"message":"Insufficient token balance. Available: 4011 tokens, Required: 13000 tokens (includes 3000 commission)","data":{}}

Widget _userImage(String? userId, {double size = 27, String? url}) {
  AppUtils.log(userId);
  AppUtils.log(LiveStreamCtrl.find.getUserById(userId)?['image']);
  String? finalUrl = url ?? LiveStreamCtrl.find.getUserById(userId)?['image'];

  return ImageView(
    margin: EdgeInsets.only(right: 10),
    url: finalUrl?.fileUrl ?? '',
    // (url ?? LiveStreamCtrl.find.getUserById(userId)?['image'])?.fileUrl ?? ''
    size: size,
    radius: size / 2,
    defaultImage: AppImages.dummyProfile,
    fit: BoxFit.cover,
    imageType: ImageType.network,
  );
}

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class _FriendBottomSheets extends StatefulWidget {
  final bool forInviteFriend;
  final bool forGetLiveBroadcaster;
  final List<ProfileDataModel> friends;
  final LiveStreamCtrl ctrl;

  const _FriendBottomSheets({
    required this.forInviteFriend,
    required this.forGetLiveBroadcaster,
    required this.friends,
    required this.ctrl,
  });

  @override
  State<_FriendBottomSheets> createState() => _FriendBottomSheetsState();
}

class _FriendBottomSheetsState extends State<_FriendBottomSheets> {
  final searchCtrl = TextEditingController();
  RxList<ProfileDataModel> list = RxList();

  @override
  void initState() {
    super.initState();
    list.assignAll(widget.friends);

    searchCtrl.addListener(onChangeSearch);
  }

  void onChangeSearch() {
    final search = searchCtrl.getText;
    final mainList = widget.friends;
    if (search.isNotNullEmpty) {
      final newList = mainList
          .where(
            (element) =>
                element.name?.toLowerCase().contains(search.toLowerCase()) ??
                false,
          )
          .toList();
      list.assignAll(newList);
    } else {
      list.assignAll(mainList);
    }
  }

  @override
  void dispose() {
    searchCtrl.removeListener(onChangeSearch);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).add(const EdgeInsets.only(bottom: 12)),
          child: Row(
            children: [
              Expanded(
                child: TextView(
                  text: widget.forInviteFriend
                      ? 'Invite Friend to video call'
                      : widget.forGetLiveBroadcaster
                      ? 'Live Users'
                      : '',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                onTap: context.pop,
                child: const Icon(Icons.close, size: 30),
              ),
            ],
          ),
        ),
        Visibility(
          visible: widget.forInviteFriend,
          child: EditText(
            hint: 'Search',
            controller: searchCtrl,
            margin:
                EdgeInsets.symmetric(horizontal: 16) +
                EdgeInsets.only(bottom: 16),
          ),
        ),
        Expanded(
          child: Obx(
            () => ListView.separated(
              shrinkWrap: true,
              itemCount: list.length,
              itemBuilder: (context, index) {
                final friend = list[index];
                return ListTile(
                  leading: _userImage(null, size: 50, url: friend.image),
                  // ImageView(
                  //   url: friend.image.fileUrl ?? '',
                  //   radius: 25,
                  //   size: 50,
                  //   defaultImage: AppImages.dummyProfile,
                  //   fit: BoxFit.cover,
                  //   imageType: ImageType.network,
                  //   bgColor: AppColors.grey.withAlpha(100),
                  // ),
                  title: TextView(
                    text: friend.name ?? '',
                    style: 16.txtRegularprimary,
                  ),
                  subtitle: Visibility(
                    visible: widget.forInviteFriend,
                    child: TextView(
                      text: friend.agoraLiveStatus?.statusValue ?? '',
                      style: 12.txtRegularprimary,
                    ),
                  ),
                  trailing: Obx(() {
                    final exist = widget.ctrl.invitedUsers.firstWhereOrNull(
                      (element) => element.id == friend.id,
                    );
                    return Visibility(
                      visible: widget.forInviteFriend
                          ? (friend.agoraLiveStatus == null ||
                                friend.agoraLiveStatus ==
                                    AgoraUserLiveStatus.offLine ||
                                friend.agoraLiveStatus ==
                                    AgoraUserLiveStatus.invited)
                          : true,
                      child: TextButton(
                        onPressed: widget.forInviteFriend && exist != null
                            ? null
                            : () {
                                if (widget.forInviteFriend) {
                                  widget.ctrl
                                      .inviteForLive(friend)
                                      .applyLoader
                                      .catchError((error) {
                                        AppUtils.toastError(
                                          "Failed to send invite: ${error.toString()}",
                                        );
                                      });
                                }

                                if (widget.forGetLiveBroadcaster) {
                                  AgoraChatCtrl.find
                                      .removeFromBroadcasterByHost(friend.id!);
                                  context.pop();
                                }
                              },
                        child: TextView(
                          text: widget.forInviteFriend
                              ? exist != null
                                    ? 'Invitation Sent'
                                    : 'Invite'
                              : widget.forGetLiveBroadcaster
                              ? 'Remove'
                              : '',
                          style: widget.forGetLiveBroadcaster
                              ? 14.txtRegularError
                              : 14.txtRegularbtncolor,
                        ),
                      ),
                    );
                  }),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 20),
            ),
          ),
        ),
      ],
    );
  }
}
