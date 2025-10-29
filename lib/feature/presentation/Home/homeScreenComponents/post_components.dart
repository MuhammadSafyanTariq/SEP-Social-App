import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sep/components/coreComponents/EditText.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/data/models/dataModels/post_data.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/post_card_header.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/widget.dart';

import '../../../../components/coreComponents/TextView.dart';
import '../../../../components/styles/appColors.dart';
import '../../../../utils/appUtils.dart';
import '../../../data/models/dataModels/profile_data/profile_data_model.dart';
import '../../widgets/fav_button.dart';
import '../comment.dart';

ProfileDataModel userProfile(PostData item) {
  if (item.userId == Preferences.uid) {
    return ProfileDataModel(
      id: Preferences.uid,
      name: Preferences.profile?.name ?? '',
      image: Preferences.profile?.image,
    );
  }

  if (item.user != null && item.user!.isNotEmpty) {
    final u = item.user!.first;
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
            Spacer(),
            Visibility(
              visible: item.files.any(
                (file) =>
                    file.type == 'video' ||
                    (file.type != null &&
                        (file.file.toString().endsWith(".mp4") ||
                            file.file.toString().endsWith(".MOV") ||
                            file.file.toString().endsWith(".avi"))),
              ),
              child: Row(
                children: [
                  ImageView(url: AppImages.eyeImg, size: 20),
                  5.width,
                  TextView(
                    text: '${item.videoCount ?? 0}',
                    style: 12.txtRegularprimary,
                  ),
                  5.width,
                  TextView(text: "Views", style: 12.txtRegularGrey),
                ],
              ),
            ),

            10.width,
          ],
        ),
      ),
    ),
  ],
);

String formatTimeAgo(String createdAt) {
  DateTime? postTime;
  try {
    postTime = DateTime.tryParse(createdAt);
  } catch (e) {
    AppUtils.log('Date Format issuee....... $createdAt');
    postTime = DateTime.now();
  }

  Duration difference = DateTime.now().difference(postTime!);

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
