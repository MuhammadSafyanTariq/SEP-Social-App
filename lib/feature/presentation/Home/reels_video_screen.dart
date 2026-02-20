import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:sep/feature/data/models/dataModels/post_data.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/feature/presentation/Home/comment.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/read_more_text.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/utils/video_quality_helper.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sep/services/saved_post_service.dart';
import 'package:sep/services/deep_link_service.dart';
import 'package:sep/feature/presentation/profileScreens/friend_profile_screen.dart';
import 'package:sep/feature/data/models/dataModels/profile_data/profile_data_model.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';

class ReelsVideoScreen extends StatefulWidget {
  final List<PostData> initialPosts;
  final int initialIndex;

  const ReelsVideoScreen({
    Key? key,
    required this.initialPosts,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<ReelsVideoScreen> createState() => _ReelsVideoScreenState();
}

class _ReelsVideoScreenState extends State<ReelsVideoScreen>
    with WidgetsBindingObserver {
  late PageController _pageController;
  VideoPlayerController? _controller;
  ChewieController? _chewieController;
  int _currentIndex = 0;
  bool _showPlayPauseIcon = false;
  bool _showBackwardIcon = false;
  bool _showForwardIcon = false;

  final ProfileCtrl profileCtrl = Get.find<ProfileCtrl>();
  List<PostData> _posts = [];
  bool _isLoadingMore = false;
  int _currentPage = 1;

  // Track which videos have had their view count incremented
  final Set<String> _viewCountedPosts = {};

  // Track video progress for view counting
  bool _hasReachedHalfway = false;

  // Track saved status for each post
  final Map<String, bool> _savedStatusMap = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _posts = List.from(widget.initialPosts);
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
    
    // Initialize saved status map
    for (var post in _posts) {
      if (post.id != null) {
        _savedStatusMap[post.id!] = post.isSaved ?? false;
      }
    }
    
    _initializeAndPlay(_currentIndex);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Pause video when app goes to background or screen is not active
      if (_controller != null && _controller!.value.isInitialized) {
        _controller!.pause();
      }
      // Restore system UI overlays when app goes to background
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    } else if (state == AppLifecycleState.resumed) {
      // Resume video when app comes back to foreground
      if (_controller != null && _controller!.value.isInitialized) {
        _controller!.play();
      }
    }
  }

  @override
  void deactivate() {
    // Pause and stop video when navigating away from this screen
    // Defer pause to avoid setState() during build phase
    if (_controller != null && _controller!.value.isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Check if still mounted and controller is still valid
        if (mounted && _controller != null && _controller!.value.isInitialized) {
          try {
            _controller!.pause();
          } catch (e) {
            // Ignore errors if controller was disposed
            AppUtils.log('Error pausing video in deactivate: $e');
          }
        }
      });
    }
    super.deactivate();
  }

  Future<void> _initializeAndPlay(int index) async {
    if (index >= _posts.length || !mounted) return;

    // Dispose previous controllers
    if (_chewieController != null) {
      _chewieController!.dispose();
      _chewieController = null;
    }
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }

    final post = _posts[index];
    final videoFile = post.files.isNotEmpty ? post.files.first : null;
    final videoUrl = videoFile != null && videoFile.file?.isNotEmpty == true
        ? AppUtils.configImageUrl(
            VideoQualityHelper.getOptimalVideoUrl(videoFile, context: context),
          )
        : null;

    if (videoUrl == null) return;

    // Initialize new video
    _controller = VideoPlayerController.network(videoUrl)
      ..initialize()
          .then((_) {
            if (mounted) {
              setState(() {
                _chewieController = ChewieController(
                  videoPlayerController: _controller!,
                  autoPlay: true,
                  looping: true,
                  aspectRatio: _controller!.value.aspectRatio,
                  showControls: false,
                  allowFullScreen: false,
                  allowMuting: true,
                  allowPlaybackSpeedChanging: false,
                );
              });

              // Reset halfway flag for new video
              _hasReachedHalfway = false;

              // Add listener to track video progress
              _controller!.addListener(_checkVideoProgress);
            }
          })
          .catchError((error) {
            debugPrint("Video Initialization Error: $error");
          });
  }

  void _checkVideoProgress() {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final position = _controller!.value.position;
    final duration = _controller!.value.duration;

    if (duration.inMilliseconds > 0) {
      final progress = position.inMilliseconds / duration.inMilliseconds;

      // Check if video has been played more than 50%
      if (progress >= 0.5 && !_hasReachedHalfway) {
        _hasReachedHalfway = true;
        _incrementVideoCount(_currentIndex);
      }
    }
  }

  void _incrementVideoCount(int index) {
    if (index >= _posts.length) return;

    final post = _posts[index];
    final postId = post.id;

    // Only increment if we haven't counted this video yet
    if (postId != null &&
        postId.isNotEmpty &&
        !_viewCountedPosts.contains(postId)) {
      _viewCountedPosts.add(postId);

      // Update video count on server
      profileCtrl
          .videoCount(postId)
          .then((_) {
            // Update local posts list
            final updatedPost = post.copyWith(
              videoCount: (post.videoCount ?? 0) + 1,
            );

            if (mounted) {
              setState(() {
                _posts[index] = updatedPost;
              });
            }

            // Update globalPostList to reflect changes when returning to home screen
            final globalIndex = profileCtrl.globalPostList.indexWhere(
              (p) => p.id == postId,
            );
            if (globalIndex != -1) {
              profileCtrl.globalPostList[globalIndex] = updatedPost;
              profileCtrl.globalPostList.refresh();
            }

            AppUtils.log('Video count incremented for post: $postId');
          })
          .catchError((error) {
            AppUtils.log('Error updating video count: $error');
            // Remove from set so it can be retried
            _viewCountedPosts.remove(postId);
          });
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      // Load more video posts from the backend
      await profileCtrl.globalList(isLoadMore: true, offset: _currentPage + 1);

      // Filter only video posts
      final newVideoPosts = profileCtrl.globalPostList
          .where(
            (post) =>
                post.files.isNotEmpty &&
                post.files.first.type == 'video' &&
                post.files.first.file?.isNotEmpty == true &&
                !_posts.any((p) => p.id == post.id),
          ) // Avoid duplicates
          .toList();

      if (newVideoPosts.isNotEmpty) {
        // Initialize saved status for new posts
        for (var post in newVideoPosts) {
          if (post.id != null) {
            _savedStatusMap[post.id!] = post.isSaved ?? false;
          }
        }
        
        setState(() {
          _posts.addAll(newVideoPosts);
          _currentPage++;
        });
      }
    } catch (e) {
      AppUtils.log('Error loading more posts: $e');
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // Remove video progress listener
    _controller?.removeListener(_checkVideoProgress);

    // Restore system UI overlays before disposing
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    // Pause and dispose video controllers
    if (_controller != null && _controller!.value.isInitialized) {
      _controller!.pause();
    }

    _chewieController?.dispose();
    _chewieController = null;

    _controller?.dispose();
    _controller = null;

    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _initializeAndPlay(index);

    // Load more posts when approaching the end
    if (index >= _posts.length - 2 && !_isLoadingMore) {
      _loadMorePosts();
    }
  }

  void _toggleLike(PostData post) async {
    // Optimistic update: change UI immediately, then sync with backend
    final updatedPost = post.copyWith(
      isLikedByUser: !(post.isLikedByUser ?? false),
      likeCount: (post.isLikedByUser ?? false)
          ? (post.likeCount ?? 0) - 1
          : (post.likeCount ?? 0) + 1,
    );

    setState(() {
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        _posts[index] = updatedPost;
      }
    });

    final globalIndex = profileCtrl.globalPostList.indexWhere(
      (p) => p.id == post.id,
    );
    if (globalIndex != -1) {
      profileCtrl.globalPostList[globalIndex] = updatedPost;
      profileCtrl.globalPostList.refresh();
    }

    await profileCtrl.likePostWithData(post);
  }

  Future<void> _sharePost(PostData post) async {
    try {
      if (post.id == null) {
        AppUtils.toastError('Unable to share this post');
        return;
      }

      // Get post caption (limit to 200 chars)
      String caption = post.content ?? '';
      if (caption.length > 200) {
        caption = caption.substring(0, 200) + '...';
      }

      // Generate share message
      String shareText = DeepLinkService.generatePostShareText(
        post.id!,
        caption: caption.isNotEmpty ? caption : null,
      );

      // Add app install instructions
      shareText += '\n\nDownload SEP Media to see more amazing content!';

      // Use share_plus to share
      final result = await Share.share(
        shareText,
        subject: 'Check out this post on SEP Media!',
      );

      if (result.status == ShareResultStatus.success) {
        AppUtils.toast('Post shared successfully!');
      }
    } catch (e) {
      AppUtils.log('❌ Error sharing post: $e');
      AppUtils.toastError('Failed to share post');
    }
  }

  Future<void> _toggleSave(PostData post) async {
    if (post.id == null || post.id!.isEmpty) return;

    final postId = post.id!;
    final isCurrentlySaved = _savedStatusMap[postId] ?? (post.isSaved ?? false);

    setState(() {
      _savedStatusMap[postId] = !isCurrentlySaved;
    });

    try {
      if (isCurrentlySaved) {
        await SavedPostService.unsavePost(postId: postId);
      } else {
        await SavedPostService.savePost(postId: postId);
      }
    } catch (e) {
      // Revert on error
      setState(() {
        _savedStatusMap[postId] = isCurrentlySaved;
      });
      AppUtils.log('Error toggling save: $e');
      AppUtils.toastError('Failed to ${isCurrentlySaved ? 'unsave' : 'save'} post');
    }
  }

  void _navigateToProfile(dynamic user) {
    if (user == null) return;

    final profileData = ProfileDataModel(
      id: user.id ?? '',
      name: user.name ?? '',
      image: user.image,
    );

    context.pushNavigator(FriendProfileScreen(data: profileData));
  }

  void _openComments(BuildContext context, PostData post) {
    final postId = post.id ?? '';
    if (postId.isEmpty) {
      AppUtils.log("Warning: Cannot open comments - missing post ID");
      return;
    }

    // Pause video when opening comments
    if (_controller != null && _controller!.value.isInitialized) {
      _controller!.pause();
    }

    // Hide bottom navigation bar
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: CommentScreen(
            onCommentAdded: (int newCount) {
              final updatedPost = post.copyWith(commentCount: newCount);

              setState(() {
                final index = _posts.indexWhere((p) => p.id == post.id);
                if (index != -1) {
                  _posts[index] = updatedPost;
                }
              });

              // Update the globalPostList to reflect changes when returning to home screen
              final globalIndex = profileCtrl.globalPostList.indexWhere(
                (p) => p.id == post.id,
              );
              if (globalIndex != -1) {
                profileCtrl.globalPostList[globalIndex] = updatedPost;
                profileCtrl.globalPostList.refresh();
              }
            },
            postId: postId,
            updatePostOnAction: (commentCount) {
              final updatedPost = post.copyWith(commentCount: commentCount);

              setState(() {
                final index = _posts.indexWhere((p) => p.id == post.id);
                if (index != -1) {
                  _posts[index] = updatedPost;
                }
              });

              // Update the globalPostList to reflect changes when returning to home screen
              final globalIndex = profileCtrl.globalPostList.indexWhere(
                (p) => p.id == post.id,
              );
              if (globalIndex != -1) {
                profileCtrl.globalPostList[globalIndex] = updatedPost;
                profileCtrl.globalPostList.refresh();
              }
            },
          ),
        ),
      ),
    ).then((_) {
      // Restore bottom navigation bar
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );

      // Resume video when comments are closed
      if (mounted && _controller != null && _controller!.value.isInitialized) {
        _controller!.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _posts.length + (_isLoadingMore ? 1 : 0),
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          if (index >= _posts.length) {
            return Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          final post = _posts[index];
          final user = post.user.isNotEmpty ? post.user.first : null;

          return Stack(
            children: [
              // Video Player
              Center(
                child:
                    _currentIndex == index &&
                        _controller != null &&
                        _controller!.value.isInitialized &&
                        _chewieController != null
                    ? Stack(
                        children: [
                          Chewie(controller: _chewieController!),

                          // Three tap zones overlay
                          Row(
                            children: [
                              // Left zone - Double tap to rewind 5 seconds
                              Expanded(
                                child: GestureDetector(
                                  onDoubleTap: () {
                                    final currentPosition =
                                        _controller!.value.position;
                                    final newPosition =
                                        currentPosition - Duration(seconds: 5);
                                    _controller!.seekTo(
                                      newPosition < Duration.zero
                                          ? Duration.zero
                                          : newPosition,
                                    );
                                    setState(() {
                                      _showBackwardIcon = true;
                                    });
                                    Future.delayed(
                                      Duration(milliseconds: 500),
                                      () {
                                        if (mounted) {
                                          setState(() {
                                            _showBackwardIcon = false;
                                          });
                                        }
                                      },
                                    );
                                  },
                                  child: Container(color: Colors.transparent),
                                ),
                              ),

                              // Center zone - Tap to play/pause
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (_controller!.value.isPlaying) {
                                        _controller!.pause();
                                      } else {
                                        _controller!.play();
                                      }
                                      _showPlayPauseIcon = true;
                                    });
                                    Future.delayed(
                                      Duration(milliseconds: 500),
                                      () {
                                        if (mounted) {
                                          setState(() {
                                            _showPlayPauseIcon = false;
                                          });
                                        }
                                      },
                                    );
                                  },
                                  child: Container(color: Colors.transparent),
                                ),
                              ),

                              // Right zone - Double tap to forward 5 seconds
                              Expanded(
                                child: GestureDetector(
                                  onDoubleTap: () {
                                    final currentPosition =
                                        _controller!.value.position;
                                    final duration =
                                        _controller!.value.duration;
                                    final newPosition =
                                        currentPosition + Duration(seconds: 5);
                                    _controller!.seekTo(
                                      newPosition > duration
                                          ? duration
                                          : newPosition,
                                    );
                                    setState(() {
                                      _showForwardIcon = true;
                                    });
                                    Future.delayed(
                                      Duration(milliseconds: 500),
                                      () {
                                        if (mounted) {
                                          setState(() {
                                            _showForwardIcon = false;
                                          });
                                        }
                                      },
                                    );
                                  },
                                  child: Container(color: Colors.transparent),
                                ),
                              ),
                            ],
                          ),

                          // Visual feedback icons
                          if (_showBackwardIcon)
                            Center(
                              child: Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.replay_5,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ),
                            ),
                          if (_showPlayPauseIcon)
                            Center(
                              child: Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _controller!.value.isPlaying
                                      ? Icons.play_arrow
                                      : Icons.pause,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ),
                            ),
                          if (_showForwardIcon)
                            Center(
                              child: Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.forward_5,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ),
                            ),

                          // Progress bar at bottom
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: VideoProgressIndicator(
                              _controller!,
                              allowScrubbing: true,
                              colors: VideoProgressColors(
                                playedColor: Colors.white,
                                bufferedColor: Colors.white.withOpacity(0.3),
                                backgroundColor: Colors.white.withOpacity(0.2),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      )
                    : const CircularProgressIndicator(color: Colors.white),
              ),

              // Top Gradient
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 100,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Close button
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),

              // Bottom content with gradient
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.9),
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 80,
                    bottom: MediaQuery.of(context).padding.bottom + 20,
                    top: 60,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // User info
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _navigateToProfile(user),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey[300],
                              backgroundImage:
                                  (user?.image != null && user!.image!.isNotEmpty)
                                  ? NetworkImage(
                                      user.image!.startsWith('http')
                                          ? user.image!
                                          : '$baseUrl${user.image}',
                                    )
                                  : null,
                              child: (user?.image == null || user!.image!.isEmpty)
                                  ? Icon(Icons.person, color: Colors.grey[600])
                                  : null,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () => _navigateToProfile(user),
                                  child: Text(
                                    user?.name ?? 'Unknown User',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      // Caption
                      if (post.content?.isNotEmpty == true)
                        Container(
                          padding: EdgeInsets.only(right: 80),
                          child: ReadMoreText(
                            text: post.content!,
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 3,
                                  color: Colors.black.withOpacity(0.8),
                                ),
                              ],
                            ),
                            maxLines: 3,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Right side actions
              Positioned(
                right: 12,
                bottom: MediaQuery.of(context).padding.bottom + 80,
                child: Column(
                  children: [
                    // Like button
                    _buildActionButton(
                      icon: (post.isLikedByUser ?? false)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: (post.isLikedByUser ?? false)
                          ? Colors.red
                          : Colors.white,
                      label: '${post.likeCount ?? 0}',
                      onTap: () => _toggleLike(post),
                    ),
                    SizedBox(height: 24),

                    // Comment button
                    _buildActionButton(
                      icon: Icons.comment,
                      color: Colors.white,
                      label: '${post.commentCount ?? 0}',
                      onTap: () => _openComments(context, post),
                    ),
                    SizedBox(height: 24),

                    // View count
                    _buildActionButton(
                      icon: Icons.visibility,
                      color: Colors.white,
                      label: '${post.videoCount ?? 0}',
                      onTap: null,
                    ),
                    SizedBox(height: 24),

                    // Share button
                    _buildActionButton(
                      icon: Icons.share,
                      color: Colors.white,
                      label: 'Share',
                      onTap: () => _sharePost(post),
                    ),
                    SizedBox(height: 24),

                    // Save button
                    _buildActionButton(
                      icon: (_savedStatusMap[post.id ?? ''] ?? (post.isSaved ?? false))
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: (_savedStatusMap[post.id ?? ''] ?? (post.isSaved ?? false))
                          ? Colors.yellow
                          : Colors.white,
                      label: 'Save',
                      onTap: () => _toggleSave(post),
                    ),
                  ],
                ),
              ),

              // Loading indicator for more posts
              if (_isLoadingMore && index == _posts.length - 1)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Loading more...',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
