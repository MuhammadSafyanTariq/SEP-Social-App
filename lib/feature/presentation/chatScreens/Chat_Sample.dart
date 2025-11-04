import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/presentation/controller/chat_ctrl.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../../components/coreComponents/ImageView.dart';
import '../../../components/styles/appColors.dart';
import '../../../components/styles/appImages.dart';
import '../../data/models/dataModels/chat_msg_model/chat_msg_model.dart';
import '../../data/models/dataModels/profile_data/profile_data_model.dart';
import '../controller/agora_chat_ctrl.dart';
import '../helpers/chat_message_helper.dart';
import 'ImagePreviewScreen.dart';
import 'VideoPreviewScreen.dart';

final GlobalKey<ChatSampleState> singleMessageScreenChatOperationKey =
    GlobalKey<ChatSampleState>();

class ChatSample extends StatefulWidget {
  final ProfileDataModel? peerUser;
  const ChatSample({Key? key, this.peerUser}) : super(key: key);

  @override
  ChatSampleState createState() => ChatSampleState();
}

class ChatSampleState extends State<ChatSample> {
  Set<ChatMsgModel> _selectedMessage = {};
  bool get isSelectionMode => _selectedMessage.isNotEmpty;

  final _ctrl = ChatCtrl.find;

  void deleteMessagesFromMe() {
    AppUtils.log('delete Messages From Me called');
    final selected = _selectedMessage.first;
    _ctrl.deleteMessage(selected, type: 'one');
    setState(() {
      _ctrl.chatMessages.removeWhere((msg) => msg.id == selected.id);
      _selectedMessage.clear();
    });
  }

  void deleteMessagesFromEveryone() {
    final selected = _selectedMessage.first;
    _ctrl.deleteMessage(selected, type: 'all');
    setState(() {
      _ctrl.chatMessages.removeWhere((msg) => msg.id == selected.id);
      _selectedMessage.clear();
    });
  }

  void _showDeleteConfirmationDialog() {
    AppUtils.log(_selectedMessage.first.toJson());
    String currentUserId = Preferences.uid ?? "";
    bool canDeleteForEveryone = _selectedMessage.every(
      (message) => message.sender?.id == currentUserId,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: TextView(text: "Delete message?", style: 18.txtSBoldprimary),
          actions: [
            if (canDeleteForEveryone)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  deleteMessagesFromEveryone();
                },
                child: TextView(
                  text: "Delete for Everyone",
                  style: 14.txtRegularbtncolor,
                ),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteMessagesFromMe();
              },
              child: TextView(
                text: "Delete for Me",
                style: 14.txtRegularbtncolor,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: TextView(text: "Cancel", style: 14.txtRegularbtncolor),
            ),
          ],
        );
      },
    );
  }

  void getList({bool isRefresh = false, bool isLoadMore = false}) {
    ChatCtrl.find
        .watchSingleChatData(isRefresh: isRefresh, isLoadMore: isLoadMore)
        .then((value) {
          AppUtils.log('Future call back');
        });
  }

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  void stopLoading() {
    AppUtils.log('callledd here.....');
    if (_refreshController.isRefresh) {
      _refreshController.refreshCompleted(resetFooterState: true);
    }

    if (_refreshController.isLoading) {
      _refreshController.loadComplete();
    }
  }

  @override
  void initState() {
    super.initState();
    ChatCtrl.find.isSingleChatLoading.value = false;

    ChatCtrl.find.isSingleChatLoading.listen((value) {
      if (!value) {
        stopLoading();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          Expanded(
            child: SmartRefresher(
              enablePullDown: false,
              enablePullUp: true,
              reverse: true,
              // header: WaterDropHeader(
              //   complete: SizedBox(),
              // ),
              footer: CustomFooter(
                builder: (context, mode) {
                  if (mode == LoadStatus.loading) {
                    return SizedBox(
                      height: 55.0,
                      child: Center(child: CupertinoActivityIndicator()),
                    );
                  } else {
                    return SizedBox();
                  }
                },
              ),
              controller: _refreshController,
              // onRefresh: ()=> getList(isRefresh: true)

              //     ()=> getList(isLoadMore: true,callBack: (){
              //   // _refreshController.loadComplete();
              //   _refreshController.refreshCompleted();
              // })

              // ,
              onLoading: () => getList(isLoadMore: true),
              child: Obx(
                () => ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  // physics: NeverScrollableScrollPhysics(),
                  reverse: true,
                  itemCount: _ctrl.chatMessages.length,
                  itemBuilder: (context, index) {
                    final message = _ctrl.chatMessages[index];
                    final isSelected = _selectedMessage.contains(message);

                    // Use helper to determine if message is sent by current user
                    final isSentByUser =
                        ChatMessageHelper.isMessageSentByCurrentUser(message);

                    // Debug logging for message alignment
                    AppUtils.log('Message alignment debug:');
                    AppUtils.log('Message sender ID: ${message.sender?.id}');
                    AppUtils.log('Current user ID: ${Preferences.uid}');
                    AppUtils.log('Is sent by user: $isSentByUser');
                    AppUtils.log('Message content: ${message.content}');

                    return _buildMessage(
                      context,
                      message.content ?? '',
                      isSentByUser,
                      isSelected,
                      () {
                        setState(() {
                          if (_selectedMessage.contains(message)) {
                            _selectedMessage.remove(message);
                          } else {
                            _selectedMessage.add(message);
                          }
                        });
                      },
                      message.senderTime ?? "",
                      message.senderTime ?? "",
                      message,
                      widget.peerUser,
                    );
                  },
                ),
              ),
            ),
          ),
          if (_selectedMessage.isNotEmpty)
            Padding(
              padding: 8.all,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete),
                label: Text('Delete Selected (${_selectedMessage.length})'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _showDeleteConfirmationDialog,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessage(
    BuildContext context,
    String content,
    bool isSentByUser,
    bool isSelected,
    VoidCallback onLongPress,
    String sentTime,
    String date,
    ChatMsgModel data,
    ProfileDataModel? peerUser,
  ) {
    final bool isImage =
        content.endsWith(".jpg") ||
        content.endsWith(".jpeg") ||
        content.endsWith(".png") ||
        content.endsWith(".gif");

    final bool isVideo =
        content.endsWith(".mp4") ||
        content.endsWith(".mov") ||
        content.endsWith(".MOV") ||
        content.endsWith(".avi");

    Widget liveStreamCard() {
      return Obx(() {
        bool isActive =
            AgoraChatCtrl.find.liveStreamChannels.firstWhereOrNull(
              (element) => element.channelId == data.channelId,
            ) !=
            null;
        return GestureDetector(
          onTap: !isSentByUser && isActive
              ? () {
                  bool connectionCallBack = false;
                  AgoraChatCtrl.find.joinLiveChannel(
                    LiveStreamChannelModel(
                      channelId: data.channelId,
                      hostId: data.sender?.id,
                      hostName: data.sender?.name,
                    ),
                    ClientRoleType.clientRoleBroadcaster,
                    connectionCallBack,
                    (value) {},
                  );
                }
              : null,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            margin: EdgeInsets.only(
              left: isSentByUser ? 0 : 10.0,
              right: isSentByUser ? 10.0 : 0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: isActive
                    ? [Colors.red.shade400, Colors.red.shade600]
                    : [Colors.grey.shade400, Colors.grey.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isActive ? Colors.red : Colors.grey).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                // Background pattern
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                          Colors.black.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),

                // Main content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with live indicator
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isActive) ...[
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                    ],
                                    Text(
                                      isActive ? 'LIVE' : 'ENDED',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isActive
                                            ? Colors.red
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.videocam,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 16),

                          // Title
                          Text(
                            'Live Video Stream',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 8),

                          // Description
                          Text(
                            isSentByUser
                                ? 'You invited ${peerUser?.name ?? 'someone'} to your live video stream'
                                : '${peerUser?.name ?? 'Someone'} invited you to join the live video stream',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.95),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action button for non-sender
                    if (!isSentByUser)
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                        height: 48,
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(24),
                          border: !isActive
                              ? Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isActive ? Icons.videocam : Icons.videocam_off,
                                color: isActive
                                    ? Colors.red.shade600
                                    : Colors.white.withOpacity(0.8),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                isActive ? 'Join Live Stream' : 'Stream Ended',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? Colors.red.shade600
                                      : Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      });
    }

    return GestureDetector(
      onLongPress: () {
        if (!isSelectionMode) onLongPress();
      },
      onTap: () {
        if (isSelectionMode) {
          onLongPress();
        }
      },
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Row(
              mainAxisAlignment: isSentByUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: isSentByUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    data.isLiveInvitation
                        ? liveStreamCard()
                        : ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.8,
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: isSentByUser ? 0 : 10.0,
                                right: isSentByUser ? 10.0 : 0,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (isImage)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: GestureDetector(
                                        onTap: () {
                                          if (isSelectionMode) {
                                            onLongPress();
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    ImagePreviewScreen(
                                                      imageUrl: content,
                                                    ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Image.network(
                                          content.trim(),
                                          fit: BoxFit.cover,
                                          loadingBuilder:
                                              (
                                                context,
                                                child,
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Shimmer.fromColors(
                                                  baseColor:
                                                      Colors.grey.shade300,
                                                  highlightColor:
                                                      Colors.grey.shade100,
                                                  child: Container(
                                                    height: 150,
                                                    color: Colors.white,
                                                  ),
                                                );
                                              },
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Text(
                                                    "Image failed to load",
                                                  ),
                                        ),
                                      ),
                                    )
                                  else if (isVideo)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child:
                                          FutureBuilder<VideoPlayerController>(
                                            future: _initializeVideoController(
                                              content,
                                            ),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                      ConnectionState.done &&
                                                  snapshot.hasData) {
                                                final controller =
                                                    snapshot.data!;
                                                return GestureDetector(
                                                  onTap: () {
                                                    if (isSelectionMode) {
                                                      onLongPress();
                                                    } else {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              VideoPreviewScreen(
                                                                videoUrl:
                                                                    content,
                                                              ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      AspectRatio(
                                                        aspectRatio: controller
                                                            .value
                                                            .aspectRatio,
                                                        child: VideoPlayer(
                                                          controller,
                                                        ),
                                                      ),
                                                      const Icon(
                                                        Icons.play_circle_fill,
                                                        size: 50,
                                                        color: Colors.white,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              } else {
                                                return Shimmer.fromColors(
                                                  baseColor:
                                                      Colors.grey.shade300,
                                                  highlightColor:
                                                      Colors.grey.shade100,
                                                  child: Container(
                                                    height: 150,
                                                    width:
                                                        MediaQuery.of(
                                                          context,
                                                        ).size.width *
                                                        0.6,
                                                    color: Colors.white,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                    )
                                  else
                                    Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: isSentByUser
                                              ? Radius.circular(12.0)
                                              : Radius.zero,
                                          topRight: isSentByUser
                                              ? Radius.zero
                                              : Radius.circular(12.0),
                                          bottomRight: const Radius.circular(
                                            12.0,
                                          ),
                                          bottomLeft: const Radius.circular(
                                            12.0,
                                          ),
                                        ),
                                      ),
                                      color: isSentByUser
                                          ? AppColors.btnColor
                                          : AppColors.primaryColor,
                                      elevation: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: SelectableText.rich(
                                          TextSpan(
                                            children: _parseTextWithLinks(
                                              content,
                                              isSentByUser,
                                            ),
                                            style: 14.txtRegularBlack,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 4.0,
                        left: 8,
                        right: 8,
                      ),
                      child: Row(
                        children: [
                          Text(
                            date.formatSentDateTime(),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              top: 0,
              right: isSentByUser ? 0 : null,
              left: isSentByUser ? null : 0,
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.check, size: 16, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Future<VideoPlayerController> _initializeVideoController(String url) async {
    final controller = VideoPlayerController.network(url);
    await controller.initialize();
    return controller;
  }

  List<TextSpan> _parseTextWithLinks(String text, bool isSentByUser) {
    final RegExp linkRegExp = RegExp(
      r'(https?:\/\/[^\s]+)',
      caseSensitive: false,
    );
    final List<TextSpan> spans = [];
    final matches = linkRegExp.allMatches(text);

    int start = 0;
    for (final Match match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }

      final String url = match.group(0)!;

      spans.add(
        TextSpan(
          text: url,
          style: const TextStyle(
            color: Colors.blueAccent,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              final Uri uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
        ),
      );

      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }
}
