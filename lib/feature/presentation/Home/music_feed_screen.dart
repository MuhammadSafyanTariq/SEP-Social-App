import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/data/models/dataModels/post_data.dart';
import 'package:sep/feature/data/repository/iTempRepository.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/pollCard.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/celebrationCard.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/postCard.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/postVideo.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/post_components.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/utils/appUtils.dart';

/// Dedicated feed for music posts (fileType = "music").
class MusicFeedScreen extends StatefulWidget {
  const MusicFeedScreen({Key? key}) : super(key: key);

  @override
  State<MusicFeedScreen> createState() => _MusicFeedScreenState();
}

class _MusicFeedScreenState extends State<MusicFeedScreen> {
  final ProfileCtrl profileCtrl = Get.find<ProfileCtrl>();
  final ITempRepository _repo = ITempRepository();

  final RxList<PostData> _musicPosts = <PostData>[].obs;
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialMusicPosts();
    });
  }

  Future<void> _loadInitialMusicPosts() async {
    setState(() {
      _isLoadingMore = false;
      _hasMore = true;
      _page = 1;
    });

    final result = await _repo.getMusicPosts(limit: 10, offset: _page);
    if (result.isSuccess && result.data != null) {
      final posts = result.data!;
      _musicPosts.assignAll(posts);
      _hasMore = posts.length == 10;
    } else {
      AppUtils.toastError(
        result.getError ?? 'Failed to load music posts',
      );
    }
    _refreshController.refreshCompleted();
    setState(() {});
  }

  Future<void> _loadMoreMusicPosts() async {
    if (_isLoadingMore || !_hasMore) {
      _refreshController.loadComplete();
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    _page += 1;
    final result = await _repo.getMusicPosts(limit: 10, offset: _page);
    if (result.isSuccess && result.data != null) {
      final posts = result.data!;
      if (posts.isNotEmpty) {
        _musicPosts.addAll(posts);
      }
      _hasMore = posts.length == 10;
      _refreshController.loadComplete();
    } else {
      _hasMore = false;
      _refreshController.loadNoData();
    }

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _postLiker(String postId) async {
    await profileCtrl.likeposts(postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Music',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(
        () {
          if (_musicPosts.isEmpty && !_isLoadingMore) {
            return Center(
              child: TextView(
                text: 'No music posts yet',
                style: 16.txtSBoldprimary,
              ),
            );
          }

          return SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            header: const WaterDropHeader(),
            footer: CustomFooter(
              builder: (context, mode) {
                Widget body;
                if (mode == LoadStatus.loading) {
                  body = CupertinoActivityIndicator(
                    color: AppColors.primaryColor,
                  );
                } else if (mode == LoadStatus.noMore) {
                  body = const Text(
                    'No more music posts',
                    style: TextStyle(color: Colors.grey),
                  );
                } else {
                  body = const SizedBox();
                }
                return SizedBox(height: 55.0, child: Center(child: body));
              },
            ),
            controller: _refreshController,
            onRefresh: _loadInitialMusicPosts,
            onLoading: _loadMoreMusicPosts,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              itemCount: _musicPosts.length,
              itemBuilder: (context, index) {
                final post = _musicPosts[index];
                return _buildPostWidget(post, index);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostWidget(PostData item, int index) {
    final header = postCardHeader(
      item,
      onBlockUser: () async {
        await _loadInitialMusicPosts();
      },
      onRemovePostAction: () {
        _musicPosts.removeAt(index);
      },
    );

    final footer = postFooter(
      context: context,
      item: item,
      postLiker: (value) {
        final count = item.likeCount ?? 0;
        final status = item.isLikedByUser ?? false;
        final updated = item.copyWith(
          isLikedByUser: !status,
          likeCount: status ? count - 1 : count + 1,
        );
        _musicPosts[index] = updated;
        _musicPosts.refresh();
        _postLiker(value);
      },
      updateCommentCount: (_) {},
      updatePostOnAction: (commentCount) async {
        final postId = item.id;
        if (postId == null || postId.isEmpty) return;

        try {
          final refreshed = await profileCtrl.getSinglePostData(postId);
          final existing = _musicPosts[index];
          _musicPosts[index] = existing.copyWith(
            commentCount:
                commentCount ?? refreshed.commentCount ?? existing.commentCount,
          );
          _musicPosts.refresh();
        } catch (e) {
          AppUtils.log('Error refreshing music post comments: $e');
        }
      },
    );

    if (item.content != null &&
        item.content!.startsWith('SEP#Celebrate')) {
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
        onPollAction: (String optionId) async {
          try {
            await profileCtrl.givePollToHomePost(item, optionId);
          } catch (e) {
            AppUtils.log("Error voting on poll (music tab): $e");
          }
        },
      );
    } else if (item.files.isNotEmpty &&
        (item.files.first.type ?? '').toLowerCase() == 'video') {
      return PostVideo(
        data: item,
        header: header,
        footer: footer,
        view: () async {
          final postId = item.id;
          if (postId == null || postId.isEmpty) return;

          try {
            final updated = item.copyWith(
              videoCount: (item.videoCount ?? 0) + 1,
            );
            _musicPosts[index] = updated;
            _musicPosts.refresh();
            await profileCtrl.videoCount(postId);
          } catch (e) {
            AppUtils.log('Error updating video count (music tab): $e');
          }
        },
      );
    } else {
      return PostCard(
        postId: item.id ?? '',
        header: header,
        caption: item.content ?? '',
        imageUrls: item.files,
        likes: '',
        comments: '',
        footer: footer,
        audio: item.audio,
      );
    }
  }
}

