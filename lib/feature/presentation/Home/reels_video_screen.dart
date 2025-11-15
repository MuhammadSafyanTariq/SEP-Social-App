import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:sep/feature/data/models/dataModels/post_data.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/feature/presentation/Home/comment.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/read_more_text.dart';
import 'package:sep/services/networking/urls.dart';

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

  final ProfileCtrl profileCtrl = Get.find<ProfileCtrl>();
  List<PostData> _posts = [];
  bool _isLoadingMore = false;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _posts = List.from(widget.initialPosts);
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
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
    if (_controller != null && _controller!.value.isInitialized) {
      _controller!.pause();
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
    final videoUrl =
        post.files.isNotEmpty && post.files.first.file?.isNotEmpty == true
        ? AppUtils.configImageUrl(post.files.first.file!)
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
            }
          })
          .catchError((error) {
            debugPrint("Video Initialization Error: $error");
          });
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
    await profileCtrl.likePostWithData(post);
    setState(() {
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        _posts[index] = post.copyWith(
          isLikedByUser: !(post.isLikedByUser ?? false),
          likeCount: (post.isLikedByUser ?? false)
              ? (post.likeCount ?? 0) - 1
              : (post.likeCount ?? 0) + 1,
        );
      }
    });
  }

  void _openComments(BuildContext context, PostData post) {
    final postId = post.id ?? '';
    if (postId.isEmpty) {
      AppUtils.log("Warning: Cannot open comments - missing post ID");
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
            onCommentAdded: (int newCount) {
              setState(() {
                final index = _posts.indexWhere((p) => p.id == post.id);
                if (index != -1) {
                  _posts[index] = post.copyWith(commentCount: newCount);
                }
              });
            },
            postId: postId,
            updatePostOnAction: (commentCount) {
              setState(() {
                final index = _posts.indexWhere((p) => p.id == post.id);
                if (index != -1) {
                  _posts[index] = post.copyWith(commentCount: commentCount);
                }
              });
            },
          ),
        ),
      ),
    );
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
                    ? GestureDetector(
                        onTap: () {
                          if (_controller != null &&
                              _controller!.value.isInitialized &&
                              _chewieController != null) {
                            if (_controller!.value.isPlaying) {
                              _controller!.pause();
                            } else {
                              _controller!.play();
                            }
                          }
                        },
                        child: Chewie(controller: _chewieController!),
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
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
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
                        Colors.black.withOpacity(0.8),
                        Colors.black.withOpacity(0.6),
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
                          CircleAvatar(
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
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'Unknown User',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
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
                        ReadMoreText(
                          text: post.content!,
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          maxLines: 3,
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
