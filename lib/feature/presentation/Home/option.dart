import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/feature/presentation/controller/chat_ctrl.dart';
import 'package:sep/services/deep_link_service.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import 'package:sep/utils/extensions/widget.dart';
import 'package:share_plus/share_plus.dart';
import '../../../components/coreComponents/AppButton.dart';
import '../../../components/coreComponents/ImageView.dart';
import '../../../components/coreComponents/TextView.dart';
import '../../../components/styles/appColors.dart';
import '../../../services/storage/preferences.dart';
import '../../data/models/dataModels/post_data.dart';
import '../../data/models/dataModels/profile_data/profile_data_model.dart';
import 'block.dart';
import 'otherreport.dart';

class Options extends StatelessWidget {
  final String? postUserId;
  final String? postId;
  final ProfileDataModel data;
  final Function onBlockSuccess;

  String? name;
  final PostData postData;

  Options({
    super.key,
    required this.name,
    required this.postUserId,
    required this.data,
    required this.onBlockSuccess,
    required this.postData,
    this.postId,
  });

  Widget _buildOption({
    required String text,
    required TextStyle style,
    required VoidCallback onTap, // onTap functionality
    bool isLast = false,
  }) {
    AppUtils.log(data.toJson());
    return Column(
      children: [
        InkWell(
          onTap: onTap, // Assigning onTap function
          splashColor: AppColors.Grey.withOpacity(0.2), // Adds touch feedback
          borderRadius: BorderRadius.circular(
            8,
          ), // Slight rounding for better UX
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextView(text: text, style: style, textAlign: TextAlign.left),
                const Icon(Icons.arrow_forward_ios, size: 20),
              ],
            ),
          ),
        ),
        if (!isLast) Divider(thickness: 1, color: AppColors.Grey),
      ],
    );
  }

  void _showShareToFriendsDialog(BuildContext context) {
    final chatCtrl = ChatCtrl.find;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextView(text: 'Share Post', style: 18.txtSBoldprimary),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                Divider(),
                
                // External Share Options
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.greenlight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.greenlight.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextView(
                        text: 'Share Outside App',
                        style: 14.txtSBoldprimary,
                      ),
                      SizedBox(height: 8),
                      InkWell(
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          _sharePostExternally(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.share,
                                color: AppColors.greenlight,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextView(
                                      text: 'Share via...',
                                      style: 14.txtMediumprimary,
                                    ),
                                    TextView(
                                      text: 'WhatsApp, Instagram, SMS, etc.',
                                      style: 12.txtRegularGrey,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AppColors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Share to Chat Section
                TextView(
                  text: 'Share to Chat',
                  style: 14.txtSBoldprimary,
                ),
                SizedBox(height: 8),
                Expanded(
                  child: chatCtrl.recentChat.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: AppColors.grey,
                              ),
                              SizedBox(height: 16),
                              TextView(
                                text: 'No chats available',
                                style: 16.txtMediumprimary,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: chatCtrl.recentChat.length,
                          itemBuilder: (context, index) {
                            final chat = chatCtrl.recentChat[index];
                            final otherUser = chat.userDetails?.firstWhere(
                              (user) => user.id != Preferences.uid,
                              orElse: () => chat.userDetails!.first,
                            );

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    otherUser?.image != null &&
                                        otherUser!.image!.isNotEmpty
                                    ? NetworkImage(
                                        AppUtils.configImageUrl(
                                          otherUser.image!,
                                        ),
                                      )
                                    : null,
                                child:
                                    otherUser?.image == null ||
                                        otherUser!.image!.isEmpty
                                    ? Icon(Icons.person)
                                    : null,
                              ),
                              title: TextView(
                                text: otherUser?.name ?? 'Unknown',
                                style: 16.txtMediumprimary,
                              ),
                              onTap: () {
                                Navigator.of(dialogContext).pop();
                                _sharePostToChat(context, chat.id, otherUser);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Share post externally via third-party apps
  void _sharePostExternally(BuildContext context) async {
    try {
      if (postData.id == null) {
        AppUtils.toastError('Unable to share this post');
        return;
      }

      AppUtils.log('🔗 Sharing post externally: ${postData.id}');
      
      // Get post caption (limit to 200 chars)
      String caption = postData.content ?? '';
      if (caption.length > 200) {
        caption = caption.substring(0, 200) + '...';
      }

      // Generate share message
      String shareText = DeepLinkService.generatePostShareText(
        postData.id!,
        caption: caption.isNotEmpty ? caption : null,
      );

      // Add app install instructions
      shareText += '\n\nDownload SEP Media to see more amazing content!';

      AppUtils.log('📤 Share text: $shareText');

      // Use share_plus to share
      final result = await Share.share(
        shareText,
        subject: 'Check out this post on SEP Media!',
      );

      if (result.status == ShareResultStatus.success) {
        AppUtils.toast('Post shared successfully!');
        AppUtils.log('✅ Share completed successfully');
      } else if (result.status == ShareResultStatus.dismissed) {
        AppUtils.log('ℹ️ Share dismissed by user');
      }
    } catch (e) {
      AppUtils.log('❌ Error sharing post: $e');
      AppUtils.toastError('Failed to share post');
    }
  }

  void _sharePostToChat(
    BuildContext context,
    String? chatId,
    dynamic otherUser,
  ) {
    AppUtils.log('🎯 _sharePostToChat called');
    AppUtils.log('   chatId: $chatId');
    AppUtils.log('   otherUserId: ${otherUser?.id}');
    AppUtils.log('   postData.id: ${postData.id}');
    AppUtils.log('   postData.userId: ${postData.userId}');

    if (chatId == null) {
      AppUtils.toastError('Unable to share to this chat');
      return;
    }

    if (postData.id == null || postData.userId == null) {
      AppUtils.toastError('Post data incomplete');
      return;
    }

    final chatCtrl = ChatCtrl.find;

    AppUtils.log('✅ Chat controller found, joining chat...');

    // Join the chat first
    chatCtrl.joinSingleChat(otherUser?.id, chatId);

    // Show immediate feedback
    AppUtils.toast('Sharing post...');

    // Wait a moment for the chat to initialize then send the post
    Future.delayed(Duration(milliseconds: 800), () {
      AppUtils.log('⏰ Delayed callback executing, about to send post...');
      // Send only post ID (post data already contains userId)
      chatCtrl.sendPostMessage(postData.id!);
    });
  }

  // late var loginUserId = Preferences.profile?.id.toString();

  @override
  Widget build(BuildContext context) {
    AppUtils.log("postuserid>>>>>>>>>>>>>>>>>>>>>${postUserId.toString()}");
    AppUtils.log("name>>>>>>>>>>>>>>>>>>>>>${name}");
    // AppUtils.log("loginuserid>>>>>>>>>>>>>>>>>>>>>${loginUserId}");
    // AppUtils.log("image>>>>${postImage.fileUrl}");
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: ListView(
          children: [
            postUserId == Preferences.uid ||
                    (data.followers ?? []).contains(Preferences.uid)
                ? SizedBox.shrink()
                : _buildOption(
                    text: 'Link Up',
                    style: 17.txtMediumBlack,
                    onTap: () {
                      context.pop();
                      ProfileCtrl.find.followRequest(data.id!).applyLoader;
                      print('Mute This Follow tapped');
                      // Example: Perform mute functionality
                    },
                  ),

            // : Container(),
            Visibility(
              visible: false,
              child: _buildOption(
                text: 'Share',
                style: 17.txtMediumBlack,
                onTap: () {
                  print('Comments tapped');
                  // Example: Navigate to Comments screen
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => CommentsScreen()));
                },
              ),
            ),

            Visibility(
              visible: false,
              child: _buildOption(
                text: 'Hide This Post',
                style: 17.txtMediumBlack,
                onTap: () {
                  print('Mute This Post tapped');
                  // Example: Perform mute functionality
                },
              ),
            ),
            postUserId.toString() == Preferences.uid
                ? SizedBox.shrink()
                : Visibility(
                    // visible: false,
                    child: _buildOption(
                      text: 'Report',
                      style: 17.txtMediumBlack,
                      onTap: () {
                        context.pop();
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (BuildContext context) {
                            return Container(
                              height: MediaQuery.of(context).size.height * 0.75,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 70,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: AppColors.grey,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ReportSheet(
                                      postUserId: postUserId!,
                                      postId: postId!,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ); // Example: Save post action
                      },
                    ),
                  ),

            postUserId.toString() == Preferences.uid
                ? SizedBox.shrink()
                : _buildOption(
                    text: 'Block ${name}',
                    style: 17.txtMediumRed,
                    onTap: () {
                      print('Block Nelson Carroll tapped');
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (BuildContext context) {
                          return Container(
                            height: MediaQuery.of(context).size.height * 0.7,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 70,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: AppColors.grey,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Block(
                                    name: name.toString(),
                                    data: data,
                                    onBlock: () {
                                      onBlockSuccess.call();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    isLast: true,
                  ),
            Divider(color: AppColors.grey),
            _buildOption(
              text: 'Share',
              style: 17.txtMediumBlack,
              onTap: () async {
                Navigator.of(context).pop();
                _showShareToFriendsDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ReportSheet extends StatefulWidget {
  final String postUserId;
  final String postId;

  const ReportSheet({Key? key, required this.postUserId, required this.postId})
    : super(key: key);

  @override
  _ReportSheetState createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  List<String> options = [
    'Hate Speech or Symbols',
    'Harassment or Bullying',
    'Violence or Threats',
    'Nudity or Sexual Content',
    'Self-Harm or Suicide',
    'False Information',
    'Spam or Scams',
    'Impersonation',
    'Illegal Activities',
    'Terrorism or Extremism',
    'Animal or Child Abuse',
    'Graphic Violence or Gore',
    'Unauthorized Sales',
    'Privacy Violations',
    'Underage Use',
    "Other",
  ];

  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            8.height,
            Center(
              child: TextView(text: "Report", style: 20.txtMediumBlack),
            ),
            25.height,
            Expanded(
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextView(
                      text: "Why are you reporting this post?",
                      style: 20.txtMediumBlack,
                      // margin: 10.left,
                    ),
                    10.height,
                    TextView(
                      text:
                          "Your report is anonymous. If someone is in immediate danger, call the local emergency services - don’t wait.",
                      style: 16.txtRegularBlack,
                      // margin: 10.left,
                    ),
                    10.height,
                    ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: options.length,
                      shrinkWrap: true,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextView(
                                    text: options[index],
                                    style: 19.txtMediumBlack,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                index == options.length - 1
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                          right: 12.0,
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: AppColors.btnColor,
                                        ),
                                      )
                                    : Checkbox(
                                        value: selectedIndex == index,
                                        activeColor: AppColors.btnColor,
                                        checkColor: Colors.white,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            selectedIndex = value!
                                                ? index
                                                : null;
                                          });
                                        },
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                        ),
                                        side: BorderSide(
                                          color: AppColors.btnColor,
                                        ),
                                      ),
                              ],
                            ),
                            Positioned.fill(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex = index;
                                  });

                                  if (index == options.length - 1) {
                                    context.replaceNavigator(
                                      OtherReport(postId: widget.postId),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            AppButton(
              onTap: () {
                if (selectedIndex != null) {
                  final title = options[selectedIndex!];
                  ProfileCtrl.find
                      .reportPostRequest(widget.postId, title, null)
                      .applyLoader
                      .then((value) {
                        ProfileCtrl.find.globalPostList.removeWhere(
                          (element) => element.id == widget.postId,
                        );
                        ProfileCtrl.find.globalPostList.refresh();
                        context.pop();
                      })
                      .catchError((error) {
                        AppUtils.toastError(error);
                      });
                }
              },
              margin: EdgeInsets.only(bottom: context.bottomSafeArea + 10),
              label: 'Done',
              buttonColor: AppColors.greenlight,
            ),
          ],
        ),
      ),
    );
  }
}
