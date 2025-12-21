import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/feature/data/models/dataModels/post_data.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/feature/presentation/controller/story/story_controller.dart';
import 'package:sep/utils/appUtils.dart';
import 'dart:async';

class StoryViewScreen extends StatefulWidget {
  final int initialIndex;
  final List<PostData> stories;

  const StoryViewScreen({
    Key? key,
    required this.initialIndex,
    required this.stories,
  }) : super(key: key);

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  late AnimationController _progressController;
  Timer? _timer;
  late ProfileCtrl profileCtrl;
  StoryController? storyController;

  // Track like state for each story
  Map<String, bool> likeStates = {};
  Map<String, int> likeCounts = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );

    profileCtrl = Get.find<ProfileCtrl>();

    // Try to get StoryController if it exists
    if (Get.isRegistered<StoryController>()) {
      storyController = Get.find<StoryController>();
    }

    // Initialize like states for all stories
    for (var story in widget.stories) {
      final postId = story.id ?? '';
      likeStates[postId] = story.isLikedByUser ?? false;
      likeCounts[postId] = story.likeCount ?? 0;
    }

    _startProgress();
  }

  void _startProgress() {
    _progressController.reset();
    _progressController.forward();

    _timer = Timer(Duration(seconds: 5), () {
      if (_currentIndex < widget.stories.length - 1) {
        _nextStory();
      } else {
        Navigator.pop(context);
      }
    });
  }

  void _nextStory() {
    _timer?.cancel();
    if (_currentIndex < widget.stories.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _pageController.animateToPage(
        _currentIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startProgress();
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    _timer?.cancel();
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _pageController.animateToPage(
        _currentIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startProgress();
    }
  }

  Future<void> _toggleLike() async {
    final story = widget.stories[_currentIndex];
    final postId = story.id ?? '';

    if (postId.isEmpty) {
      AppUtils.log('Cannot like story: Invalid post ID');
      return;
    }

    // Store current state for revert
    final previousLikeState = likeStates[postId] ?? false;
    final previousLikeCount = likeCounts[postId] ?? 0;

    // Optimistic update
    setState(() {
      likeStates[postId] = !previousLikeState;
      likeCounts[postId] = previousLikeCount + (previousLikeState ? -1 : 1);
    });

    // Make API call
    try {
      await profileCtrl.likeposts(postId);
      AppUtils.log('Story liked successfully: $postId');

      // Update the story data in the stories list
      widget.stories[_currentIndex] = story.copyWith(
        isLikedByUser: !previousLikeState,
        likeCount: previousLikeCount + (previousLikeState ? -1 : 1),
      );

      // Update in StoryController if available
      if (storyController != null) {
        final storyIndex = storyController!.stories.indexWhere(
          (s) => s.id == postId,
        );
        if (storyIndex != -1) {
          storyController!.stories[storyIndex] = widget.stories[_currentIndex];
        }
      }

      // Update in ProfileCtrl global post list
      final globalIndex = profileCtrl.globalPostList.indexWhere(
        (p) => p.id == postId,
      );
      if (globalIndex != -1) {
        profileCtrl.globalPostList[globalIndex] = widget.stories[_currentIndex];
      }
    } catch (e) {
      // Revert on error
      setState(() {
        likeStates[postId] = previousLikeState;
        likeCounts[postId] = previousLikeCount;
      });
      AppUtils.log('Error liking story: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  String _getTimeAgo(String? createdAt) {
    if (createdAt == null) return '';

    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_currentIndex];
    final user = story.user?.isNotEmpty == true ? story.user!.first : null;
    final imageUrl = story.files?.isNotEmpty == true
        ? story.files!.first.file
        : null;

    // Extract caption without #SEPStory tag
    String caption = story.content ?? '';
    caption = caption
        .replaceAll(RegExp(r'#SEPStory', caseSensitive: false), '')
        .trim();

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth / 2) {
            _previousStory();
          } else {
            _nextStory();
          }
        },
        child: Stack(
          children: [
            // Story image
            PageView.builder(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.stories.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final storyItem = widget.stories[index];
                final storyImageUrl = storyItem.files?.isNotEmpty == true
                    ? storyItem.files!.first.file
                    : null;

                return Center(
                  child: storyImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: storyImageUrl.startsWith('http')
                              ? storyImageUrl
                              : '$baseUrl$storyImageUrl',
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error, color: Colors.white, size: 50),
                        )
                      : Icon(
                          Icons.image_not_supported,
                          color: Colors.white,
                          size: 100,
                        ),
                );
              },
            ),

            // Progress bars
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: List.generate(widget.stories.length, (index) {
                    return Expanded(
                      child: Container(
                        height: 3,
                        margin: EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, child) {
                            double progress = 0;
                            if (index < _currentIndex) {
                              progress = 1;
                            } else if (index == _currentIndex) {
                              progress = _progressController.value;
                            }

                            return FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // User info header
            Positioned(
              top: 55,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: user?.image != null
                          ? CachedNetworkImageProvider(
                              user!.image!.startsWith('http')
                                  ? user.image!
                                  : '$baseUrl${user.image}',
                            )
                          : null,
                      child: user?.image == null
                          ? Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Unknown',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _getTimeAgo(story.createdAt),
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),

            // Caption and Like button at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Caption
                    if (caption.isNotEmpty)
                      Expanded(
                        child: Text(
                          caption,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (caption.isEmpty) Spacer(),

                    SizedBox(width: 12),

                    // Like button
                    GestureDetector(
                      onTap: _toggleLike,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              likeStates[story.id ?? ''] ?? false
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: likeStates[story.id ?? ''] ?? false
                                  ? Colors.red
                                  : Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 6),
                            Text(
                              '${likeCounts[story.id ?? ''] ?? 0}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
