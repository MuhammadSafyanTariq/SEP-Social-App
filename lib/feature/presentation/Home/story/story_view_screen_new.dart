import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sep/feature/data/models/dataModels/story_model.dart';
import 'package:sep/feature/presentation/controller/story/story_controller.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/read_more_text.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class StoryViewScreenNew extends StatefulWidget {
  final List<UserStoryGroup> storyGroups;
  final int initialGroupIndex;

  const StoryViewScreenNew({
    Key? key,
    required this.storyGroups,
    this.initialGroupIndex = 0,
  }) : super(key: key);

  @override
  State<StoryViewScreenNew> createState() => _StoryViewScreenNewState();
}

class _StoryViewScreenNewState extends State<StoryViewScreenNew> {
  late PageController _pageController;
  late int _currentGroupIndex;
  late int _currentStoryIndex;
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  Timer? _storyTimer;
  final StoryController _storyController = Get.find<StoryController>();

  // Progress indicators
  double _progress = 0.0;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _currentGroupIndex = widget.initialGroupIndex;
    _currentStoryIndex = 0;
    _pageController = PageController(initialPage: _currentGroupIndex);

    // Mark first story as viewed and start timer
    _viewCurrentStory();
    _startStoryTimer();
  }

  @override
  void dispose() {
    _storyTimer?.cancel();
    _videoController?.dispose();
    _audioPlayer?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _viewCurrentStory() {
    final story = _getCurrentStory();
    if (story != null && !story.hasViewed) {
      _storyController.viewStory(story.id);
    }
  }

  Story? _getCurrentStory() {
    if (_currentGroupIndex >= widget.storyGroups.length) return null;
    final stories = widget.storyGroups[_currentGroupIndex].stories;
    if (_currentStoryIndex >= stories.length) return null;
    return stories[_currentStoryIndex];
  }

  void _startStoryTimer() {
    _storyTimer?.cancel();
    _audioPlayer?.stop();
    _progress = 0.0;

    final story = _getCurrentStory();
    if (story == null) return;

    // Log story files for debugging
    AppUtils.log('Story files count: ${story.files.length}');
    for (var file in story.files) {
      AppUtils.log('File type: ${file.type}, File: ${file.file}');
    }

    // Check if it's a video story
    if (story.type == 'video' && story.files.isNotEmpty) {
      _initializeVideo(story.files.first.file);
      return;
    }

    // Check if story has audio file (for image stories with audio)
    StoryFile? audioFile;
    try {
      audioFile = story.files.firstWhere((file) => file.type == 'audio');
      AppUtils.log('Found audio file: ${audioFile.file}');
      _playAudio(audioFile.file);
    } catch (e) {
      AppUtils.log('No audio file found in story');
    }

    // For image/audio stories, use 5 second timer
    const duration = Duration(seconds: 5);
    const tickDuration = Duration(milliseconds: 50);
    final totalTicks = duration.inMilliseconds / tickDuration.inMilliseconds;
    int currentTick = 0;

    _storyTimer = Timer.periodic(tickDuration, (timer) {
      if (_isPaused) return;

      setState(() {
        currentTick++;
        _progress = currentTick / totalTicks;

        if (_progress >= 1.0) {
          timer.cancel();
          _nextStory();
        }
      });
    });
  }

  Future<void> _playAudio(String audioUrl) async {
    try {
      final fullUrl = audioUrl.startsWith('http')
          ? audioUrl
          : '$baseUrl$audioUrl';

      _audioPlayer ??= AudioPlayer();
      await _audioPlayer!.play(UrlSource(fullUrl));
      AppUtils.log('Playing audio: $fullUrl');
    } catch (e) {
      AppUtils.log('Error playing audio: $e');
    }
  }

  Future<void> _initializeVideo(String videoUrl) async {
    await _videoController?.dispose();
    _videoController = null;

    try {
      final fullUrl = videoUrl.startsWith('http')
          ? videoUrl
          : '$baseUrl$videoUrl';

      setState(() {
        // Trigger rebuild to show loading
      });

      _videoController = VideoPlayerController.network(fullUrl);
      await _videoController!.initialize();

      setState(() {
        // Trigger rebuild to show video
      });

      await _videoController!.play();

      // Listen to video progress
      _videoController!.addListener(() {
        if (!mounted) return;

        final position = _videoController!.value.position.inMilliseconds;
        final duration = _videoController!.value.duration.inMilliseconds;

        if (duration > 0) {
          setState(() {
            _progress = position / duration;
          });
        }

        // Auto advance when video ends
        if (_videoController!.value.position >=
            _videoController!.value.duration) {
          _nextStory();
        }
      });
    } catch (e) {
      AppUtils.log('Error initializing video: $e');
      AppUtils.toastError('Failed to load video');
      _nextStory();
    }
  }

  void _nextStory() {
    final currentGroup = widget.storyGroups[_currentGroupIndex];

    if (_currentStoryIndex < currentGroup.stories.length - 1) {
      // Next story in current group
      setState(() {
        _currentStoryIndex++;
        _viewCurrentStory();
        _startStoryTimer();
      });
    } else {
      // Next group
      if (_currentGroupIndex < widget.storyGroups.length - 1) {
        setState(() {
          _currentGroupIndex++;
          _currentStoryIndex = 0;
        });
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _viewCurrentStory();
        _startStoryTimer();
      } else {
        // End of stories
        Navigator.pop(context);
      }
    }
  }

  void _previousStory() {
    if (_currentStoryIndex > 0) {
      // Previous story in current group
      setState(() {
        _currentStoryIndex--;
        _startStoryTimer();
      });
    } else {
      // Previous group
      if (_currentGroupIndex > 0) {
        setState(() {
          _currentGroupIndex--;
          final prevGroup = widget.storyGroups[_currentGroupIndex];
          _currentStoryIndex = prevGroup.stories.length - 1;
        });
        _pageController.previousPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _startStoryTimer();
      }
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_videoController != null) {
        if (_isPaused) {
          _videoController!.pause();
        } else {
          _videoController!.play();
        }
      }
      if (_audioPlayer != null) {
        if (_isPaused) {
          _audioPlayer!.pause();
        } else {
          _audioPlayer!.resume();
        }
      }
    });
  }

  Future<void> _toggleLike() async {
    final story = _getCurrentStory();
    if (story != null) {
      await _storyController.toggleLikeStory(story.id);
      setState(() {}); // Refresh UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.localPosition.dx < screenWidth / 3) {
            _previousStory();
          } else if (details.localPosition.dx > 2 * screenWidth / 3) {
            _nextStory();
          } else {
            _togglePause();
          }
        },
        child: PageView.builder(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          itemCount: widget.storyGroups.length,
          onPageChanged: (index) {
            setState(() {
              _currentGroupIndex = index;
              _currentStoryIndex = 0;
              _viewCurrentStory();
              _startStoryTimer();
            });
          },
          itemBuilder: (context, groupIndex) {
            return _buildStoryPage(groupIndex);
          },
        ),
      ),
    );
  }

  Widget _buildStoryPage(int groupIndex) {
    final storyGroup = widget.storyGroups[groupIndex];
    final story = storyGroup.stories[_currentStoryIndex];
    final user = storyGroup.user;

    return Stack(
      children: [
        // Story content
        Center(child: _buildStoryContent(story)),

        // Progress bars
        _buildProgressBars(storyGroup.stories),

        // User info header
        _buildUserHeader(user, story),

        // Like and view count footer
        _buildFooter(story),

        // Pause/Play indicator (only for videos)
        if (_isPaused && story.type == 'video')
          Center(
            child: Icon(
              Icons.play_circle_outline,
              size: 80,
              color: Colors.white70,
            ),
          ),
      ],
    );
  }

  Widget _buildStoryContent(Story story) {
    if (story.files.isEmpty) {
      final caption = story.caption.toString();
      return Center(
        child: Text(
          caption.isNotEmpty ? caption : 'No content',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    final file = story.files.first;

    if (story.type == 'video') {
      // Check if video controller exists and is initialized
      if (_videoController != null && _videoController!.value.isInitialized) {
        return Center(
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
        );
      } else {
        // Show loading while video initializes or if controller is null
        return Container(
          color: Colors.black,
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
              strokeWidth: 3,
            ),
          ),
        );
      }
    } else if (file.type == 'image') {
      // Check if there's also an audio file
      final audioFile = story.files.firstWhere(
        (f) => f.type == 'audio',
        orElse: () => StoryFile(file: '', type: ''),
      );
      final hasAudio = audioFile.file.isNotEmpty;

      // Extract audio file name if present
      String? audioFileName;
      if (hasAudio) {
        final uri = Uri.parse(audioFile.file);
        final segments = uri.pathSegments;
        if (segments.isNotEmpty) {
          audioFileName = segments.last;
          // Remove any query parameters or fragments
          audioFileName = audioFileName.split('?').first;
          // Decode URL encoding
          audioFileName = Uri.decodeComponent(audioFileName);
        }
      }

      return Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            CachedNetworkImage(
              imageUrl: file.file.startsWith('http')
                  ? file.file
                  : '$baseUrl${file.file}',
              fit: BoxFit.contain,
              placeholder: (context, url) => Container(
                color: Colors.black,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                    strokeWidth: 3,
                  ),
                ),
              ),
              errorWidget: (context, url, error) =>
                  Icon(Icons.error, color: Colors.white, size: 50),
            ),
            // Show audio indicator and file name if story has audio
            if (hasAudio && audioFileName != null)
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.music_note, color: Colors.white, size: 20),
                      SizedBox(width: 6),
                      Container(
                        constraints: BoxConstraints(maxWidth: 150),
                        child: Text(
                          audioFileName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    } else if (file.type == 'audio') {
      final caption = story.caption.toString();
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_note, size: 100, color: Colors.white),
          SizedBox(height: 20),
          if (caption.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                caption,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
        ],
      );
    }

    return SizedBox();
  }

  Widget _buildProgressBars(List<Story> stories) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: List.generate(stories.length, (index) {
            double progress = 0.0;
            if (index < _currentStoryIndex) {
              progress = 1.0;
            } else if (index == _currentStoryIndex) {
              progress = _progress;
            }

            return Expanded(
              child: Container(
                height: 3,
                margin: EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  widthFactor: progress,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildUserHeader(dynamic user, Story story) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                user.image?.startsWith('http') == true
                    ? user.image
                    : '$baseUrl${user.image ?? ''}',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.name ?? 'Unknown',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    _getTimeAgo(story.createdAt),
                    style: TextStyle(color: Colors.white70, fontSize: 12),
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
    );
  }

  Widget _buildFooter(Story story) {
    final caption = story.caption.toString();
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (caption.isNotEmpty && story.type != 'audio')
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ReadMoreText(
                    text: caption,
                    textStyle: TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 3,
                  ),
                ),
              SizedBox(height: 12),
              Row(
                children: [
                  GestureDetector(
                    onTap: _toggleLike,
                    child: Row(
                      children: [
                        Icon(
                          story.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: story.isLiked ? Colors.red : Colors.white,
                          size: 28,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${story.likeCount}',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 24),
                  Row(
                    children: [
                      Icon(Icons.visibility, color: Colors.white, size: 24),
                      SizedBox(width: 4),
                      Text(
                        '${story.viewCount}',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
