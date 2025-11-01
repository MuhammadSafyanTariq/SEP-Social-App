import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:get/get.dart';

// Global video controller manager
class VideoControllerManager extends GetxController {
  static VideoControllerManager get find => Get.find<VideoControllerManager>();

  final Map<String, VideoPlayerController> _controllers = {};

  void registerController(String postId, VideoPlayerController controller) {
    _controllers[postId] = controller;
  }

  void unregisterController(String postId) {
    _controllers.remove(postId);
  }

  void pauseAll() {
    for (var controller in _controllers.values) {
      if (controller.value.isPlaying) {
        controller.pause();
      }
    }
  }

  void disposeAll() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }

  @override
  void onInit() {
    super.onInit();
    AppUtils.log('VideoControllerManager initialized');
  }

  @override
  void onClose() {
    disposeAll();
    super.onClose();
  }
}

class AutoPlayVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String postId;
  final double aspectRatio;

  const AutoPlayVideoPlayer({
    Key? key,
    required this.videoUrl,
    required this.postId,
    this.aspectRatio = 16 / 9,
  }) : super(key: key);

  @override
  State<AutoPlayVideoPlayer> createState() => _AutoPlayVideoPlayerState();
}

class _AutoPlayVideoPlayerState extends State<AutoPlayVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = false;
  bool _isMuted = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();

    // Initialize VideoControllerManager if not already initialized
    try {
      Get.find<VideoControllerManager>();
    } catch (e) {
      Get.put(VideoControllerManager());
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await _controller!.initialize();

      // Set video to loop and mute by default for better auto-play UX
      _controller!.setLooping(true);
      _controller!.setVolume(0); // Muted by default

      // Register controller with manager
      try {
        VideoControllerManager.find.registerController(
          widget.postId,
          _controller!,
        );
      } catch (e) {
        AppUtils.log('Error registering controller: $e');
      }

      _controller!.addListener(() {
        if (mounted) {
          setState(() {
            _isPlaying = _controller!.value.isPlaying;
          });
        }
      });

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      AppUtils.log('Error initializing video: $e');
    }
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (!mounted || _controller == null || !_isInitialized) return;

    // Video is considered "in focus" when more than 50% visible
    final isVisible = info.visibleFraction > 0.5;

    if (isVisible && !_controller!.value.isPlaying) {
      // Pause all other videos first
      try {
        VideoControllerManager.find.pauseAll();
      } catch (e) {
        AppUtils.log('Error pausing other videos: $e');
      }

      // Play this video
      _controller!.play();
      if (mounted) {
        setState(() {
          _isPlaying = true;
        });
      }
    } else if (!isVisible && _controller!.value.isPlaying) {
      // Pause when scrolled away
      _controller!.pause();
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _isPlaying = false;
      } else {
        _controller!.play();
        _isPlaying = true;
      }
      _showControls = true;
    });

    // Hide controls after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleMute() {
    if (_controller == null || !_isInitialized) return;

    setState(() {
      _isMuted = !_isMuted;
      _controller!.setVolume(_isMuted ? 0 : 1);
    });
  }

  @override
  void dispose() {
    // Unregister from manager
    try {
      VideoControllerManager.find.unregisterController(widget.postId);
    } catch (e) {
      AppUtils.log('Error unregistering controller: $e');
    }

    _controller?.pause();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: Container(
          color: Colors.black,
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    return VisibilityDetector(
      key: Key('video_${widget.postId}'),
      onVisibilityChanged: _handleVisibilityChanged,
      child: GestureDetector(
        onTap: _togglePlayPause,
        child: AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_controller!),

              // Play/Pause overlay
              AnimatedOpacity(
                opacity: !_isPlaying || _showControls ? 1.0 : 0.0,
                duration: Duration(milliseconds: 300),
                child: Container(
                  decoration: BoxDecoration(color: Colors.black26),
                  child: Center(
                    child: Icon(
                      _isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      size: 64,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
              ),

              // Mute/Unmute button
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: _toggleMute,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Progress indicator
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: VideoProgressIndicator(
                  _controller!,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: Colors.red,
                    bufferedColor: Colors.grey,
                    backgroundColor: Colors.white.withOpacity(0.3),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
