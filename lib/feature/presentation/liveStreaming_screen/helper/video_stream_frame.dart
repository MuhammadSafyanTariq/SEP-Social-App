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
    // Get the image value - it might be String or dynamic
    final imageValue = ctrl.hostProfileData.value.image;

    // Check if we have an image
    final hasImage =
        imageValue != null && imageValue.toString().trim().isNotEmpty;

    // Get the image source (either from host profile or preferences)
    final imageSource = hasImage
        ? imageValue
        : (ctrl.isHost ? Preferences.profile?.image : null);

    // Convert to String? and apply fileUrl extension
    final String? imageString = imageSource?.toString();
    final file = imageString?.fileUrl;

    if (file == null || file.trim().isEmpty) {
      if (ctrl.isHost) {
        final profileImage = ProfileCtrl.find.profileData.value.image;
        final String? profileImageString = profileImage?.toString();
        return profileImageString?.fileUrl;
      }
      return null;
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(child: _buildCameraView()),
          Obx(
            () => Positioned(
              right: 0,
              top: context.getHeight / 2.5,
              bottom: context.getHeight * 0.15,
              child: loopCounts > 0 ? coinAnimation() : SizedBox(),
            ),
          ),
          _chatSectionAndLiveButton(context),
          widget.clientRole == ClientRoleType.clientRoleAudience
              ? _buildAppBar(context, isLiveNow)
              : Obx(() => _buildAppBar(context, isLiveNow)),
          _buildVideoControls(context),
          _leftActionButtonsForHost(),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return Obx(() {
      return buildVideoGrid(ctrl.getBroadcasters);
    });
  }

  Widget buildVideoGrid(List<RemoteUserAgora> uids) {
    int count = uids.length;

    if (count == 0) return Center(child: Text("No users"));

    List<Widget> rows = [];

    if (count == 1) {
      // One user: full screen
      return Column(
        children: [Expanded(child: _agoraVideoViewWidget(uid: uids[0]))],
      );
    }

    if (count == 2) {
      // Two users: stacked full width
      return Column(
        children: [
          Expanded(child: _agoraVideoViewWidget(uid: uids[0])),
          Expanded(child: _agoraVideoViewWidget(uid: uids[1])),
        ],
      );
    }

    int startIndex = 0;

    if (count % 2 != 0) {
      // Odd number: First full-width, rest in pairs
      rows.add(Expanded(child: _agoraVideoViewWidget(uid: uids[0])));
      startIndex = 1;
    }

    // Render remaining in pairs
    for (int i = startIndex; i < count; i += 2) {
      rows.add(
        Expanded(
          child: Row(
            children: [
              Expanded(child: _agoraVideoViewWidget(uid: uids[i])),
              if (i + 1 < count)
                Expanded(child: _agoraVideoViewWidget(uid: uids[i + 1]))
              else
                Expanded(child: SizedBox()), // filler to maintain layout
            ],
          ),
        ),
      );
    }

    return Column(children: rows);
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
              () => TextView(
                text: hostName,
                style: 18.txtSBoldBlack.withShadow(AppColors.grey),
              ),
            ),
          ),
          Visibility(visible: isLive, child: LiveStatusButtons()),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () => Navigator.pop(context),
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

  Widget _chatSectionAndLiveButton(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [_buildChatList(context), _buildBottomBar()],
      ),
    );
  }

  Widget _buildBottomBar() {
    return !ctrl.isHost
        ? _chatBox()
        : Obx(
            () => isBroadcaster && !ctrl.streamCtrl.value.localChannelJoined
                ? StartStreamButton(
                    onPressed: () {
                      // chatCtrl.coinsAnimationListInt.add(chatCtrl.coinsAnimationListInt.length);
                      ctrl.joinChannel();
                    },
                  )
                : _chatBox(),
          );
  }

  Widget _chatBox() {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: 16) +
          EdgeInsets.only(bottom: context.bottomSafeArea + 20, top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: ChatInputBox()),
          Visibility(
            visible: !ctrl.isHost,
            child: GestureDetector(
              onTap: openTokenBottomSheet,
              child: Container(
                margin: EdgeInsets.only(left: 16),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.white),
                ),
                child: ImageView(url: AppImages.token, size: 24),
              ),
            ),
          ),
          Visibility(
            visible: !ctrl.isHost,
            child: Obx(
              () => ImageView(
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
                margin: EdgeInsets.only(left: 16),
                url:
                    ctrl.streamCtrl.value.clientRole ==
                        ClientRoleType.clientRoleAudience
                    ?
                      // offVideo
                      AppImages.videoRequest
                    : AppImages.offVideo,
                size: 40,
                tintColor: ctrl.videoRequestButtonEnable.isTrue
                    ? (ctrl.streamCtrl.value.clientRole ==
                              ClientRoleType.clientRoleAudience
                          ? ctrl.getBroadcasters.length < broadCastUserMaxLimit
                                ? Colors.red
                                : Colors.grey.withValues(alpha: 0.2)
                          : Colors.red)
                    : Colors.grey.withValues(alpha: 0.2),
              ),
            ),
          ),
        ],
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
    return Obx(
      () => Container(
        height: context.getHeight * 0.35,
        decoration: chatCtrl.chatList.isNotEmpty
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.grey.withValues(alpha: 0.009),
                    AppColors.grey.withValues(alpha: 0.06),
                    AppColors.grey.withValues(alpha: 0.3),
                    AppColors.grey.withValues(alpha: 0.7),
                  ],
                  stops: [0.05, 0.1, 0.25, 0.8],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              )
            : null,
        child: Obx(() {
          final messages = chatCtrl.chatList;
          return ListView.separated(
            reverse: true,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: messages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                          child: _requestBtn(
                            'Requested',
                            AppColors.grey,
                            () {},
                          ),
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
              return Column(
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
                  TextView(text: msg.message ?? '', style: 14.txtMediumWhite),
                ],
              );
            },
          );
        }),
      ),
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

      AppUtils.log(
        '_leftActionButtonsForHost - isHost: ${ctrl.isHost}, isJoined: $isJoined, hasVisibleBroadcasters: $hasVisibleBroadcasters',
      );

      if (!ctrl.isHost || (!isJoined && !hasVisibleBroadcasters)) {
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
            if (hasVisibleBroadcasters)
              IconControl(
                url: AppImages.broadcaster,
                onTap: () {
                  AppUtils.log(
                    'Broadcaster button tapped, count: ${ctrl.getLiveBroadcastersVisibleToHost.length}',
                  );
                  _openInviteBottomSheet(forGetLiveBroadcaster: true);
                },
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
      AppUtils.log('Fetching friends for invite...');
      try {
        friends = await ctrl.getFriends().applyLoader;
        AppUtils.log('Friends fetched: ${friends.length}');
        if (friends.isNotEmpty) {
          AppUtils.log('First friend: ${friends.first.name}');
        }
      } catch (e) {
        AppUtils.log('Error fetching friends: $e');
        if (mounted) {
          AppUtils.toastError('Error loading friends: $e');
        }
        return;
      }
    }

    if (forGetLiveBroadcaster) {
      friends = ctrl.getLiveBroadcastersVisibleToHost;
      AppUtils.log('Live broadcasters count: ${friends.length}');
    }

    if (!mounted) return;

    // Always show the bottom sheet, even if empty
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
                      // Recording button
                      Obx(
                        () => GestureDetector(
                          onTap: ctrl.toggleRecording,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: ctrl.isRecording.value
                                  ? Colors.red
                                  : AppColors.black.withValues(alpha: 0.35),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              ctrl.isRecording.value
                                  ? Icons.stop_circle
                                  : Icons.fiber_manual_record,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // Recording duration display
                      Obx(
                        () => Visibility(
                          visible: ctrl.isRecording.value,
                          child: Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextView(
                                text: ctrl.formattedRecordingDuration,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
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
                              text: '${AgoraChatCtrl.find.hostGiftAmountTotal}',
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
    if (search.trim().isNotEmpty) {
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
            () => list.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.forInviteFriend
                                ? Icons.people_outline
                                : Icons.person_off_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 20),
                          TextView(
                            text: widget.forInviteFriend
                                ? 'No Friends Found'
                                : 'No Live Users',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 10),
                          TextView(
                            text: widget.forInviteFriend
                                ? 'Follow users to invite them\nto your live stream'
                                : 'No users are currently live\nin this session',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
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
                          final exist = widget.ctrl.invitedUsers
                              .firstWhereOrNull(
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
                                  : () async {
                                      if (widget.forInviteFriend) {
                                        try {
                                          await widget.ctrl
                                              .inviteForLive(friend)
                                              .applyLoader;
                                          // Success is already handled in inviteForLive method
                                        } catch (error) {
                                          AppUtils.log('Invite error: $error');
                                          // Extract meaningful error message
                                          String errorMsg = error.toString();
                                          if (errorMsg.contains('Exception:')) {
                                            errorMsg = errorMsg
                                                .replaceAll('Exception:', '')
                                                .trim();
                                          }
                                          if (errorMsg.contains(
                                            'Failed to send invite:',
                                          )) {
                                            errorMsg = errorMsg
                                                .replaceAll(
                                                  'Failed to send invite:',
                                                  '',
                                                )
                                                .trim();
                                          }
                                          AppUtils.toastError(
                                            errorMsg.isEmpty
                                                ? "Failed to send invitation"
                                                : errorMsg,
                                          );
                                        }
                                      }

                                      if (widget.forGetLiveBroadcaster) {
                                        AgoraChatCtrl.find
                                            .removeFromBroadcasterByHost(
                                              friend.id!,
                                            );
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
