import 'package:flutter/material.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/feature/data/models/dataModels/post_data.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/postCard.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/pollCard.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/postVideo.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/celebrationCard.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/post_components.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';

class PostDetailScreen extends StatefulWidget {
  final PostData postData;
  final bool openComments;

  const PostDetailScreen({
    super.key,
    required this.postData,
    this.openComments = false,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late PostData postData;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    postData = widget.postData;

    // If openComments is true, show comments sheet after build
    if (widget.openComments) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Open comments - this will be handled by postFooter
      });
    }
  }

  // Build post widget using the same pattern as home screen
  Widget _buildPostWidget(PostData item) {
    final header = postCardHeader(
      item,
      onBlockUser: () {},
      onRemovePostAction: () {
        // Post removed, go back
        context.pop();
      },
    );

    final footer = postFooter(
      context: context,
      item: item, // Pass the current state item which has updated counts
      postLiker: (postId) {
        // Update like status immediately
        final count = item.likeCount ?? 0;
        final isLiked = item.isLikedByUser ?? false;

        setState(() {
          postData = postData.copyWith(
            isLikedByUser: !isLiked,
            likeCount: isLiked ? count - 1 : count + 1,
          );
        });

        // Then sync with server
        ProfileCtrl.find.likeposts(postId);
      },
      updateCommentCount: (count) {
        // Update comment count in state
        setState(() {
          postData = postData.copyWith(commentCount: count);
        });
      },
      updatePostOnAction: (commentCount) {
        // Refresh full post data from server
        if (item.id != null) {
          ProfileCtrl.find.getSinglePostData(item.id!).then((updatedPost) {
            setState(() {
              postData = updatedPost;
            });
          });
        }
      },
    );

    // Check if post is a celebration (starts with "SEP#Celebrate")
    if (item.content != null && item.content!.startsWith('SEP#Celebrate')) {
      return CelebrationCard(
        header: header,
        caption: item.content ?? '',
        footer: footer,
        data: item,
      );
    } else if (item.fileType == 'poll') {
      return PollCard(
        footer: footer,
        data: item,
        header: header,
        question: item.content ?? '',
        options: item.options,
        onPollAction: (String optionId) {
          ProfileCtrl.find.givePollToHomePost(item, optionId);
        },
      );
    } else if (item.files.isNotEmpty && item.files.first.type == 'video') {
      return PostVideo(data: item, header: header, footer: footer, view: () {});
    } else {
      return PostCard(
        header: header,
        caption: item.content ?? '',
        imageUrls: item.files,
        likes: '',
        comments: '',
        footer: footer,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Custom AppBar
          AppBar2(
            title: 'Post',
            titleStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            prefixImage: 'back',
            onPrefixTap: () => context.pop(),
            backgroundColor: Colors.white,
          ),

          // Post Content - Use the same widget builder as home screen
          // Rebuild with updated postData whenever state changes
          Expanded(
            child: SingleChildScrollView(
              key: ValueKey(postData.id), // Force rebuild on data change
              controller: _scrollController,
              child: _buildPostWidget(postData),
            ),
          ),
        ],
      ),
    );
  }
}
