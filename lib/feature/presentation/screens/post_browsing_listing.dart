import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/postCard.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/post_components.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/utils/extensions/size.dart';

import '../../../components/coreComponents/TextView.dart';
import '../../../components/styles/appColors.dart';
import '../../data/models/dataModels/post_data.dart';
import '../../data/models/dataModels/profile_data/profile_data_model.dart';

class PostImageBrowsingListing extends StatefulWidget {
  final List<PostData>? list;
  final Function(int)? onRemovePost;
  final Function(int)? onPostLikeAction;
  final int? initialIndex;
  /// When opening from another user's profile, pass the profile owner so we can
  /// show their name/avatar when the API returns 403 and post has no user data.
  final ProfileDataModel? profileOwner;

  const PostImageBrowsingListing({
    super.key,
    this.list,
    this.onRemovePost,
    this.onPostLikeAction,
    this.initialIndex,
    this.profileOwner,
  });

  @override
  State<PostImageBrowsingListing> createState() =>
      _PostImageBrowsingListingState();
}

class _PostImageBrowsingListingState extends State<PostImageBrowsingListing> {
  Rx<List<PostData>?> list = Rx(null);
  late ScrollController _scrollController;
  final Set<String> _enrichedPostIds = {};

  /// Enrich a post with full data (likeCount, commentCount, user) from getSinglePost – same as home screen.
  Future<void> _enrichPostAt(int index) async {
    final sourceList =
        list.value ?? ProfileCtrl.find.profileImagePostList;
    if (index < 0 || index >= sourceList.length) return;
    final post = sourceList[index];
    if (post.id == null || post.id!.isEmpty) return;
    try {
      final full = await ProfileCtrl.find.getSinglePostData(post.id!);
      if (!mounted) return;
      // Use likes/comments array length when count is missing so we show correct numbers
      final likeCount = full.likeCount ?? full.likes?.length ?? 0;
      final commentCount = full.commentCount ?? full.comments?.length ?? 0;
      sourceList[index] = full.copyWith(
        likeCount: likeCount,
        commentCount: commentCount,
      );
      if (list.value != null) {
        list.refresh();
      } else {
        ProfileCtrl.find.profileImagePostList.refresh();
      }
      setState(() {});
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    list.value = widget.list;
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo((widget.initialIndex ?? 0) * 500);
      }
      // Enrich the opened post immediately so likes/comments show correctly (e.g. my profile)
      final sourceList =
          list.value ?? ProfileCtrl.find.profileImagePostList;
      final idx = widget.initialIndex ?? 0;
      if (idx >= 0 && idx < sourceList.length) {
        final post = sourceList[idx];
        if (post.id != null && post.id!.isNotEmpty) {
          _enrichedPostIds.add(post.id!);
          _enrichPostAt(idx);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.white,
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
            TextView(text: "Posts", style: 14.txtRegularBlack),
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
            // Enrich with full post data (likes, comments, user) when missing or possibly stale
            if (post.id != null &&
                post.id!.isNotEmpty &&
                !_enrichedPostIds.contains(post.id) &&
                ((post.likeCount == null || post.commentCount == null) ||
                    post.user.isEmpty ||
                    (post.likeCount ?? 0) == 0 ||
                    (post.commentCount ?? 0) == 0)) {
              _enrichedPostIds.add(post.id!);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _enrichPostAt(index);
              });
            }
            // When API returns 403 (other user's post), use profile owner for name/avatar so they still show
            final owner = widget.profileOwner;
            final displayPost =
                (post.user.isEmpty &&
                    owner != null &&
                    ((owner.name?.isNotEmpty ?? false) ||
                        (owner.userName?.isNotEmpty ?? false)) &&
                    (post.userId == null || post.userId == owner.id))
                    ? post.copyWith(
                        user: [
                          User(
                            id: owner.id,
                            name: owner.name ?? owner.userName,
                            image: owner.image,
                          ),
                        ],
                      )
                    : post;
            final footer = postFooter(
              context: context,
              item: displayPost,
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
                  final sourceList =
                      list.value ?? ProfileCtrl.find.profileImagePostList;
                  final idx =
                      sourceList.indexWhere((element) => element.id == postId);
                  if (idx > -1) {
                    sourceList[idx] = value.copyWith(
                      user: sourceList[idx].user,
                      commentCount: commentCount ?? value.commentCount ?? 0,
                    );
                    if (list.value != null) {
                      list.refresh();
                    } else {
                      ProfileCtrl.find.profileImagePostList.refresh();
                    }
                    setState(() {});
                  }
                });
              },
            );

            return PostCard(
              postId: post.id ?? '',
              header: postCardHeader(
                displayPost,
                onRemovePostAction: () {
                  if (widget.list != null) {
                    widget.onRemovePost?.call(index);
                  } else {
                    ProfileCtrl.find.profileImagePostList.removeAt(index);
                    ProfileCtrl.find.profileImagePostList.refresh();
                  }
                },
              ),
              caption: displayPost.content ?? '',
              imageUrls: displayPost.files,
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
