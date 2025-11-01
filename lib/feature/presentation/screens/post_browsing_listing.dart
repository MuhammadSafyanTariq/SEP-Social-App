import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/postCard.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/post_components.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/extensions/size.dart';

import '../../../components/coreComponents/TextView.dart';
import '../../../components/styles/appColors.dart';
import '../../data/models/dataModels/post_data.dart';

class PostImageBrowsingListing extends StatefulWidget {
  final List<PostData>? list;
  final Function(int)? onRemovePost;
  final Function(int)? onPostLikeAction;
  final int? initialIndex;

  const PostImageBrowsingListing({
    super.key,
    this.list,
    this.onRemovePost,
    this.onPostLikeAction,
    this.initialIndex,
  });

  @override
  State<PostImageBrowsingListing> createState() =>
      _PostImageBrowsingListingState();
}

class _PostImageBrowsingListingState extends State<PostImageBrowsingListing> {
  Rx<List<PostData>?> list = Rx(null);
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    list.value = widget.list;
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo((widget.initialIndex ?? 0) * 500);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.black,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left_rounded,
            color: Colors.black,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextView(
              text: Preferences.profile?.name ?? '',
              style: 14.txtRegularprimary,
            ),
            TextView(text: "Posts", style: 14.txtRegularWhite),
          ],
        ),
      ),
      body: Obx(
        () => ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.all(10.sdp),
          itemCount:
              (list.value ?? ProfileCtrl.find.profileImagePostList).length,
          itemBuilder: (context, index) {
            final post =
                (list.value ?? ProfileCtrl.find.profileImagePostList)[index];
            final footer = postFooter(
              context: context,
              item: post,
              postLiker: (value) async {
                ProfileCtrl.find.likeposts(post.id ?? '');
                if (list.value == null) {
                  final data = ProfileCtrl.find.profileImagePostList[index];
                  final status = data.isLikedByUser ?? false;
                  final count = data.likeCount ?? 0;
                  ProfileCtrl.find.profileImagePostList[index] = data.copyWith(
                    likeCount: status ? count - 1 : count + 1,
                    isLikedByUser: !status,
                  );
                  ProfileCtrl.find.profileImagePostList.refresh();
                } else {
                  widget.onPostLikeAction?.call(index);
                }
              },
              updateCommentCount: (value) {},
              updatePostOnAction: (commentCount) {
                final postId = post.id!;
                ProfileCtrl.find.getSinglePostData(postId).then((value) {
                  final index = ProfileCtrl.find.profileImagePostList
                      .indexWhere((element) => element.id == postId);
                  if (index > -1) {
                    ProfileCtrl.find.profileImagePostList[index] = value
                        .copyWith(
                          user:
                              ProfileCtrl.find.profileImagePostList[index].user,
                          commentCount: commentCount ?? 0,
                        );
                    ProfileCtrl.find.profileImagePostList.refresh();
                  }
                });
              },
            );

            return PostCard(
              postId: post.id ?? '',
              header: postCardHeader(
                post,
                onRemovePostAction: () {
                  if (widget.list != null) {
                    widget.onRemovePost?.call(index);
                  } else {
                    ProfileCtrl.find.profileImagePostList.removeAt(index);
                    ProfileCtrl.find.profileImagePostList.refresh();
                  }
                },
              ),
              caption: post.content ?? '',
              imageUrls: post.files ?? [],
              likes: '',
              comments: '',
              footer: footer,
            );
          },
        ),
      ),
    );
  }
}
