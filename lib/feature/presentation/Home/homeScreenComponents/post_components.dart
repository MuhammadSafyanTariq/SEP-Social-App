import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/data/models/dataModels/post_data.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/post_card_header.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/services/saved_post_service.dart';
import 'package:sep/services/deep_link_service.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/widget.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../components/coreComponents/TextView.dart';
import '../../../../components/styles/appColors.dart';
import '../../../../utils/appUtils.dart';
import '../../../data/models/dataModels/profile_data/profile_data_model.dart';
import '../../widgets/fav_button.dart';
import '../comment.dart';
import '../../controller/chat_ctrl.dart';
import '../../controller/auth_Controller/profileCtrl.dart';

ProfileDataModel userProfile(PostData item) {
  if (item.userId == Preferences.uid) {
    return ProfileDataModel(
      id: Preferences.uid,
      name: Preferences.profile?.name ?? '',
      image: Preferences.profile?.image,
    );
  }

  if (item.user.isNotEmpty) {
    final u = item.user.first;
    return ProfileDataModel(id: u.id ?? '', name: u.name ?? '', image: u.image);
  }

  // 3. Fallback – at least return the id
  return ProfileDataModel(id: item.userId ?? '');
}

PostCardHeader postCardHeader(
  PostData item, {
  Function? onBlockUser,
  Function? onRemovePostAction,
}) {
  return PostCardHeader(
    time: formatTimeAgo(item.createdAt ?? ''),
    userData: userProfile(item),
    location: '',

    // snapshot.connectionState == ConnectionState.done
    //     ? (snapshot.hasData ? address : "No Address Found")
    //     : "Loading..."
    data: item,
    onBlockUser: () {
      onBlockUser?.call();
    },
    onRemovePostAction: onRemovePostAction,
  );
}

void _showShareToFriendsDialog(BuildContext context, PostData postData) {
  final chatCtrl = ChatCtrl.find;

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                        _sharePostExternally(context, postData);
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
              TextView(text: 'Share to Chat', style: 14.txtSBoldprimary),
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
                              style: 16.txtMediumPrimary,
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
                                      AppUtils.configImageUrl(otherUser.image!),
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
                              style: 16.txtMediumPrimary,
                            ),
                            onTap: () {
                              Navigator.of(dialogContext).pop();
                              _sharePostToChat(
                                context,
                                chat.id,
                                otherUser,
                                postData,
                              );
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
void _sharePostExternally(BuildContext context, PostData postData) async {
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
  PostData postData,
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

Widget postFooter({
  required PostData item,
  required BuildContext context,
  required Function(String) postLiker,
  required Function(int) updateCommentCount,
  required Function(int?) updatePostOnAction,
  Function(PostData)?
  postLikerWithData, // New callback for handling PostData directly
}) => Column(
  children: [
    SizedBox(height: 10),
    Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 20),
      child: Container(
        height: 20,
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            12.width,
            FavButton(
              initialState: item.isLikedByUser ?? false,
              initialCount: item.likeCount ?? 0,
              onTap: () {
                // Try to use direct post ID first
                final postId = item.id ?? '';
                if (postId.isNotEmpty) {
                  postLiker(postId);
                } else {
                  // If direct ID is not available, use PostData callback if provided
                  if (postLikerWithData != null) {
                    AppUtils.log("Using PostData callback for like action");
                    postLikerWithData(item);
                  } else {
                    AppUtils.log(
                      "Warning: Cannot like post - missing post ID and no PostData callback",
                    );
                    AppUtils.toastError(
                      "Unable to like post - invalid post data",
                    );
                  }
                }
              },
              postId: item.id ?? '',
            ),
            Padding(
              padding: 15.left,
              child: InkWell(
                onTap: () {
                  final postId = item.id ?? '';
                  if (postId.isEmpty) {
                    AppUtils.log(
                      "Warning: Cannot open comments - missing post ID",
                    );
                    return;
                  }

                  final height = MediaQuery.of(context).size.height * 0.6;

                  context.openBottomSheet(
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: SizedBox(
                        height: height,
                        child: CommentScreen(
                          onCommentAdded: updateCommentCount,
                          postId: postId,
                          updatePostOnAction: updatePostOnAction,
                        ),
                      ),
                    ),
                  );
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset("assets/images/mesgsvg.svg"),
                    5.width,
                    TextView(
                      text: '${item.commentCount ?? 0}',
                      style: 12.txtRegularprimary,
                    ),
                    TextView(text: " Comments", style: 12.txtRegularGrey),
                  ],
                ),
              ),
            ),
            Padding(
              padding: 15.left,
              child: InkWell(
                onTap: () {
                  _showShareToFriendsDialog(context, item);
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.share_outlined,
                      size: 20,
                      color: AppColors.primaryColor,
                    ),
                    5.width,
                    TextView(text: "Share", style: 12.txtRegularprimary),
                  ],
                ),
              ),
            ),
            Padding(
              padding: 15.left,
              child: SavePostButton(
                postId: item.id ?? '',
                initialSavedState: item.isSaved ?? false,
              ),
            ),
            Spacer(),
            10.width,
          ],
        ),
      ),
    ),
    // One row: Gift (other users) | Views (video) | X Gifts summary
    Padding(
      padding: const EdgeInsets.only(left: 22, bottom: 10, top: 2),
      child: Row(
        children: [
          if (item.userId != Preferences.uid)
            InkWell(
              onTap: () => _showGiftPicker(context, item),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.card_giftcard_outlined,
                    size: 18,
                    color: AppColors.primaryColor,
                  ),
                  5.width,
                  TextView(text: 'Gift', style: 12.txtRegularprimary),
                ],
              ),
            ),
          if (item.userId != Preferences.uid &&
              (item.files.any(
                    (f) =>
                        f.type == 'video' ||
                        (f.type != null &&
                            (f.file?.toString().endsWith(".mp4") == true ||
                                f.file?.toString().endsWith(".MOV") == true ||
                                f.file?.toString().endsWith(".avi") == true))) ||
                  (item.id ?? '').isNotEmpty))
            10.width,
          if (item.files.any(
            (file) =>
                file.type == 'video' ||
                (file.type != null &&
                    (file.file.toString().endsWith(".mp4") ||
                        file.file.toString().endsWith(".MOV") ||
                        file.file.toString().endsWith(".avi"))),
          ))...[
            ImageView(url: AppImages.eyeImg, size: 18),
            5.width,
            TextView(
              text: '${item.videoCount ?? 0}',
              style: 12.txtRegularprimary,
            ),
            5.width,
            TextView(text: "Views", style: 12.txtRegularGrey),
          ],
          if (item.files.any(
            (file) =>
                file.type == 'video' ||
                (file.type != null &&
                    (file.file.toString().endsWith(".mp4") ||
                        file.file.toString().endsWith(".MOV") ||
                        file.file.toString().endsWith(".avi"))),
          ))
            10.width,
          if ((item.id ?? '').isNotEmpty)
            Builder(
              builder: (context) {
                final postId = item.id!;
                ProfileCtrl.find.fetchPostGiftTotal(postId);
                return Obx(() {
                  final total = ProfileCtrl.find.postGiftTotals[postId] ?? 0;
                  if (total <= 0) return const SizedBox.shrink();
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.card_giftcard,
                        size: 18,
                        color: AppColors.primaryColor,
                      ),
                      5.width,
                      TextView(
                        text: '$total Gifts',
                        style: 12.txtRegularprimary,
                      ),
                    ],
                  );
                });
              },
            ),
        ],
      ),
    ),
  ],
);

void _showGiftPicker(BuildContext context, PostData post) {
  final profileCtrl = ProfileCtrl.find;

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      final gifts = [
        {'name': 'Cake', 'price': '\$2.00'},
        {'name': 'Flowers', 'price': '\$10.00'},
        {'name': 'Vehicles', 'price': '\$3.00'},
        {'name': 'Money', 'price': '\$5.00'},
        {'name': 'Hearts', 'price': '\$1.00'},
        {'name': 'Applause', 'price': '\$0.50'},
      ];

      return SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.grey.shade100,
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextView(
                    text: 'Send Premium Gift',
                    style: 18.txtSBoldprimary,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              TextView(
                text: 'Support this creator with a premium gift',
                style: 12.txtRegularGrey,
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: gifts.length,
                itemBuilder: (context, index) {
                  final g = gifts[index];
                  final name = g['name'] as String;
                  final price = g['price'] as String;

                  final icon = index == 0
                      ? Icons.cake
                      : index == 1
                          ? Icons.local_florist
                          : index == 2
                              ? Icons.directions_car
                              : index == 3
                                  ? Icons.attach_money
                                  : index == 4
                                      ? Icons.favorite
                                      : Icons.emoji_emotions;

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.pop(ctx);
                      profileCtrl.sendGiftOnPost(
                        post: post,
                        giftName: name,
                      );
                      _showGiftExplosionOverlay(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor.withOpacity(0.08),
                            Colors.white,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.2),
                        ),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryColor,
                                  AppColors.primaryColor.withOpacity(0.7),
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              icon,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextView(
                            text: name,
                            style: 12.txtMediumprimary,
                          ),
                          const SizedBox(height: 2),
                          TextView(
                            text: price,
                            style: 11.txtRegularGrey,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _showGiftExplosionOverlay(BuildContext context) {
  final overlay = Overlay.of(context);
  const duration = Duration(milliseconds: 1200);

  final entry = OverlayEntry(
    builder: (ctx) => Positioned.fill(
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: duration,
          curve: Curves.easeOut,
          builder: (context, value, _) {
            // Burst rings: expand and fade
            final ring1 = (value < 0.5) ? (value / 0.5) : 0.0;
            final ring2 = (value >= 0.1 && value < 0.6) ? ((value - 0.1) / 0.5) : 0.0;
            final ring3 = (value >= 0.2 && value < 0.7) ? ((value - 0.2) / 0.5) : 0.0;
            final ring1Opacity = (value < 0.5) ? (1 - value / 0.5) * 0.5 : 0.0;
            final ring2Opacity = (value >= 0.1 && value < 0.6) ? (1 - (value - 0.1) / 0.5) * 0.4 : 0.0;
            final ring3Opacity = (value >= 0.2 && value < 0.7) ? (1 - (value - 0.2) / 0.5) * 0.3 : 0.0;
            // Center icon: pop in then hold and gentle scale
            final iconScale = value < 0.2
                ? (value / 0.2) * 1.2
                : value < 0.4
                    ? 1.2 + (value - 0.2) / 0.2 * 0.15
                    : 1.35 - (value - 0.4) / 0.6 * 0.35;
            final iconOpacity = value < 0.15 ? (value / 0.15) : (value > 0.85 ? (1 - value) / 0.15 : 1.0);

            return Stack(
              alignment: Alignment.center,
              children: [
                // Outer burst ring
                if (ring1 > 0)
                  Transform.scale(
                    scale: 0.3 + ring1 * 1.4,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(ring1Opacity),
                          width: 4,
                        ),
                      ),
                    ),
                  ),
                if (ring2 > 0)
                  Transform.scale(
                    scale: 0.25 + ring2 * 1.2,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(ring2Opacity),
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                if (ring3 > 0)
                  Transform.scale(
                    scale: 0.2 + ring3 * 1.0,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primaryColor.withOpacity(ring3Opacity * 0.8),
                            AppColors.primaryColor.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Center gift icon with glow
                Opacity(
                  opacity: iconOpacity.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: iconScale,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.4),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.2),
                            blurRadius: 40,
                            spreadRadius: 8,
                          ),
                        ],
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primaryColor,
                            AppColors.primaryColor.withOpacity(0.85),
                            AppColors.primaryColor.withOpacity(0.6),
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                      child: const Icon(
                        Icons.card_giftcard_rounded,
                        color: Colors.white,
                        size: 52,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );

  overlay.insert(entry);
  Future.delayed(const Duration(milliseconds: 1250), () {
    entry.remove();
  });
}

String formatTimeAgo(String createdAt) {
  DateTime postTime;
  try {
    postTime = DateTime.tryParse(createdAt) ?? DateTime.now();
    // If parsing failed or returned null, use current time
    if (createdAt.isEmpty || createdAt.trim().isEmpty) {
      postTime = DateTime.now();
    }
  } catch (e) {
    AppUtils.log('Date Format issuee....... $createdAt');
    postTime = DateTime.now();
  }

  Duration difference = DateTime.now().difference(postTime);

  if (difference.inSeconds < 60) return '${difference.inSeconds} seconds ago';
  if (difference.inMinutes < 60) return '${difference.inMinutes} minutes ago';
  if (difference.inHours < 24) return '${difference.inHours} hours ago';
  if (difference.inDays < 7) return '${difference.inDays} days ago';
  if (difference.inDays < 30)
    return '${(difference.inDays / 7).floor()} weeks ago';
  if (difference.inDays < 365)
    return '${(difference.inDays / 30).floor()} months ago';
  return '${(difference.inDays / 365).floor()} years ago';
}

// Save Post Button Widget
class SavePostButton extends StatefulWidget {
  final String postId;
  final bool initialSavedState;

  const SavePostButton({
    Key? key,
    required this.postId,
    required this.initialSavedState,
  }) : super(key: key);

  @override
  _SavePostButtonState createState() => _SavePostButtonState();
}

class _SavePostButtonState extends State<SavePostButton> {
  bool _isSaved = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.initialSavedState;
    // Optionally check saved status from backend
    _checkSavedStatus();
  }

  Future<void> _checkSavedStatus() async {
    if (widget.postId.isEmpty) return;

    try {
      final isSaved = await SavedPostService.checkIfPostIsSaved(
        postId: widget.postId,
      );
      if (mounted) {
        setState(() {
          _isSaved = isSaved;
        });
      }
    } catch (e) {
      AppUtils.log('Error checking saved status: $e');
    }
  }

  Future<void> _toggleSave() async {
    if (_isLoading || widget.postId.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isSaved) {
        await SavedPostService.unsavePost(postId: widget.postId);
        if (mounted) {
          setState(() {
            _isSaved = false;
          });
        }
      } else {
        await SavedPostService.savePost(postId: widget.postId);
        if (mounted) {
          setState(() {
            _isSaved = true;
          });
        }
      }
    } catch (e) {
      AppUtils.log('Error toggling save: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _toggleSave,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryColor,
                  ),
                )
              : Icon(
                  _isSaved ? Icons.bookmark : Icons.bookmark_border,
                  size: 20,
                  color: _isSaved ? AppColors.btnColor : AppColors.primaryColor,
                ),
          5.width,
          TextView(
            text: _isSaved ? "Saved" : "Save",
            style: 12.txtRegularprimary,
          ),
        ],
      ),
    );
  }
}
