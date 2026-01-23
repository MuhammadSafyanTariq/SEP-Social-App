import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/feature/data/models/dataModels/post_data.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/post_components.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/postCard.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/postVideo.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/pollCard.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/celebrationCard.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/services/saved_post_service.dart';
import 'package:sep/utils/appUtils.dart';

class SavedPostsScreen extends StatefulWidget {
  @override
  _SavedPostsScreenState createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  final RxList<PostData> _savedPosts = <PostData>[].obs;
  final RxBool _isLoading = true.obs;
  final RxString _error = ''.obs;
  int _currentPage = 1;
  bool _hasMore = true;
  Map<String, dynamic>? _pagination;
  final ScrollController _scrollController = ScrollController();
  final ProfileCtrl profileCtrl = ProfileCtrl.find;

  @override
  void initState() {
    super.initState();
    _loadSavedPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_hasMore && !_isLoading.value) {
        _loadMore();
      }
    }
  }

  Future<void> _loadSavedPosts({bool loadMore = false}) async {
    if (!loadMore) {
      _isLoading.value = true;
      _error.value = '';
      _currentPage = 1;
    }

    try {
      final response = await SavedPostService.getSavedPosts(page: _currentPage);

      if (response['status'] == true) {
        final data = response['data'];
        final posts =
            (data['posts'] as List?)
                ?.map((post) => PostData.fromJson(post))
                .toList() ??
            [];

        final pagination = data['pagination'];

        if (loadMore) {
          _savedPosts.addAll(posts);
        } else {
          _savedPosts.assignAll(posts);
        }

        _hasMore = _currentPage < (pagination['totalPages'] ?? 0);
        _isLoading.value = false;
      } else {
        _error.value = response['message'] ?? 'Failed to load saved posts';
        _isLoading.value = false;
      }
    } catch (e) {
      AppUtils.log('Error loading saved posts: $e');
      _error.value = 'Failed to load saved posts: $e';
      _isLoading.value = false;
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoading.value) return;

    _currentPage++;
    await _loadSavedPosts(loadMore: true);
  }

  Future<void> _unsavePost(String postId) async {
    try {
      await SavedPostService.unsavePost(postId: postId);
      // Remove from list
      _savedPosts.removeWhere((post) => post.id == postId);
    } catch (e) {
      AppUtils.log('Error unsaving post: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey.withOpacity(0.1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextView(
          text: 'Saved Posts',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: () => _loadSavedPosts(),
          ),
        ],
      ),
      body: Obx(() {
        if (_isLoading.value && _savedPosts.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        if (_error.value.isNotEmpty && _savedPosts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey),
                SizedBox(height: 20),
                Text(
                  'Error: ${_error.value}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _loadSavedPosts(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.btnColor,
                  ),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (_savedPosts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                SizedBox(height: 20),
                Text(
                  'No saved posts',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 10),
                Text(
                  'Save posts to view them here',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _loadSavedPosts(),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _savedPosts.length + (_hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _savedPosts.length) {
                return _buildLoadMoreButton();
              }

              final post = _savedPosts[index];
              return _buildPostCard(post);
            },
          ),
        );
      }),
    );
  }

  Widget _buildPostCard(PostData item) {
    final header = postCardHeader(
      item,
      onRemovePostAction: () {
        _unsavePost(item.id ?? '');
      },
    );

    final footer = postFooter(
      item: item,
      context: context,
      postLiker: (String postId) async {
        await profileCtrl.likeposts(postId);
      },
      updateCommentCount: (int count) {
        // Update comment count if needed
      },
      updatePostOnAction: (int? index) {
        // Handle post updates if needed
      },
    );

    // Check if post is a celebration
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
        onPollAction: (String optionId) async {
          try {
            await profileCtrl.givePollToHomePost(item, optionId);
          } catch (e) {
            AppUtils.log("Error voting on poll: $e");
          }
        },
      );
    } else if (item.files.isNotEmpty && item.files.first.type == 'video') {
      return PostVideo(
        data: item,
        header: header,
        footer: footer,
        view: () {
          // Handle view count increment if needed
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
      );
    }
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Obx(
          () => _isLoading.value
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _loadMore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.btnColor,
                  ),
                  child: Text('Load More'),
                ),
        ),
      ),
    );
  }
}
