import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:get/get.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/feature/data/models/dataModels/post_data.dart';
import 'package:sep/utils/video_quality_helper.dart';
import 'package:sep/utils/gpu_error_handler.dart';

// Global video controller manager
class VideoControllerManager extends GetxController {
  static VideoControllerManager get find => Get.find<VideoControllerManager>();

  final Map<String, VideoPlayerController> _controllers = {};

  void registerController(String postId, VideoPlayerController controller) {
    _controllers[postId] = controller;
  }

  void unregisterController(String postId) {
    final controller = _controllers.remove(postId);
    if (controller != null) {
      try {
        controller.pause();
        controller.dispose();
      } catch (e) {
        AppUtils.log('Error disposing controller: $e');
      }
    }
  }

  void pauseAll() {
    for (var controller in _controllers.values) {
      try {
        if (controller.value.isPlaying) {
          controller.pause();
        }
      } catch (e) {
        AppUtils.log('Error pausing controller: $e');
      }
    }
  }

  void disposeAll() {
    for (var controller in _controllers.values) {
      try {
        controller.pause();
        controller.dispose();
      } catch (e) {
        AppUtils.log('Error disposing controller: $e');
      }
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
  final FileElement? fileElement; // Optional: provides access to qualities map

  const AutoPlayVideoPlayer({
    Key? key,
    required this.videoUrl,
    required this.postId,
    this.aspectRatio = 16 / 9,
    this.fileElement,
  }) : super(key: key);

  @override
  State<AutoPlayVideoPlayer> createState() => _AutoPlayVideoPlayerState();
}

class _AutoPlayVideoPlayerState extends State<AutoPlayVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isMuted = true;
  bool _hasReachedHalfway = false;
  bool _viewCounted = false;

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
    // Check GPU state before initializing
    if (GpuErrorHandler.instance.isGpuDeviceLost && 
        !GpuErrorHandler.instance.canAttemptRecovery()) {
      AppUtils.log('⚠️ Skipping video initialization - GPU device lost');
      return;
    }

    try {
      // Get optimal video URL
      // widget.videoUrl from postVideo.dart is already wrapped with AppUtils.configImageUrl()
      // But if fileElement is provided, we can re-select quality if needed
      String finalVideoUrl = widget.videoUrl;
      
      if (widget.fileElement != null) {
        // Get optimal quality URL (returns relative path like /public/upload/...)
        final optimalUrl = VideoQualityHelper.getOptimalVideoUrl(
          widget.fileElement!,
          context: context,
        );
        
        // Wrap with base URL if it's a relative path
        finalVideoUrl = optimalUrl.startsWith('http://') || optimalUrl.startsWith('https://')
            ? optimalUrl
            : AppUtils.configImageUrl(optimalUrl);
      } else {
        // If no fileElement, ensure widget.videoUrl is properly formatted
        if (!finalVideoUrl.startsWith('http://') && !finalVideoUrl.startsWith('https://')) {
          finalVideoUrl = AppUtils.configImageUrl(finalVideoUrl);
        }
      }

      AppUtils.log('🎥 Initializing video - URL: $finalVideoUrl');

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(finalVideoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
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
          // Check for GPU errors during playback
          if (_controller!.value.hasError) {
            final errorDesc = _controller!.value.errorDescription ?? '';
            final errorStr = errorDesc.toLowerCase();
            if (errorStr.contains('devicelost') ||
                errorStr.contains('vulkan') ||
                errorStr.contains('impeller') ||
                errorStr.contains('gpu')) {
              GpuErrorHandler.instance.markGpuDeviceLost();
              AppUtils.log('⚠️ GPU error detected during playback');
              return;
            }
          }

          setState(() {
            _isPlaying = _controller!.value.isPlaying;
          });
          _checkVideoProgress();
        }
      });

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      AppUtils.log('❌ Error initializing video: $e');
      AppUtils.log('   Video URL was: ${widget.videoUrl}');
      if (widget.fileElement != null) {
        AppUtils.log('   FileElement provided, attempted quality selection');
      }
      
      // Check if it's a GPU error
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('devicelost') ||
          errorStr.contains('vulkan') ||
          errorStr.contains('impeller') ||
          errorStr.contains('gpu')) {
        GpuErrorHandler.instance.markGpuDeviceLost();
      }
      
      // If initialization fails, set state to show error
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (!mounted || _controller == null || !_isInitialized) return;

    // Check GPU state
    if (GpuErrorHandler.instance.isGpuDeviceLost && 
        !GpuErrorHandler.instance.canAttemptRecovery()) {
      return;
    }

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
      try {
        _controller!.play();
        if (mounted) {
          setState(() {
            _isPlaying = true;
          });
        }
      } catch (e) {
        AppUtils.log('Error playing video: $e');
      }
    } else if (!isVisible && _controller!.value.isPlaying) {
      // Pause when scrolled away
      try {
        _controller!.pause();
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      } catch (e) {
        AppUtils.log('Error pausing video: $e');
      }
    }
  }

  void _checkVideoProgress() {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _viewCounted)
      return;

    final position = _controller!.value.position;
    final duration = _controller!.value.duration;

    if (duration.inMilliseconds > 0) {
      final progress = position.inMilliseconds / duration.inMilliseconds;

      // Check if video has been played more than 50%
      if (progress >= 0.5 && !_hasReachedHalfway) {
        _hasReachedHalfway = true;
        _incrementViewCount();
      }
    }
  }

  void _incrementViewCount() {
    if (_viewCounted || widget.postId.isEmpty) return;

    _viewCounted = true;

    try {
      final profileCtrl = Get.find<ProfileCtrl>();

      // Update video count on server
      profileCtrl
          .videoCount(widget.postId)
          .then((_) {
            // Update globalPostList to reflect changes
            final globalIndex = profileCtrl.globalPostList.indexWhere(
              (p) => p.id == widget.postId,
            );

            if (globalIndex != -1) {
              final post = profileCtrl.globalPostList[globalIndex];
              final updatedPost = post.copyWith(
                videoCount: (post.videoCount ?? 0) + 1,
              );
              profileCtrl.globalPostList[globalIndex] = updatedPost;
              profileCtrl.globalPostList.refresh();
            }

            AppUtils.log('Video count incremented for post: ${widget.postId}');
          })
          .catchError((error) {
            AppUtils.log('Error updating video count: $error');
            _viewCounted = false; // Reset so it can be retried
          });
    } catch (e) {
      AppUtils.log('Error finding ProfileCtrl: $e');
      _viewCounted = false;
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;

    try {
      setState(() {
        if (_controller!.value.isPlaying) {
          _controller!.pause();
          _isPlaying = false;
        } else {
          _controller!.play();
          _isPlaying = true;
        }
      });
    } catch (e) {
      AppUtils.log('Error toggling play/pause: $e');
    }
  }

  void _toggleMute() {
    if (_controller == null || !_isInitialized) return;

    try {
      setState(() {
        _isMuted = !_isMuted;
        _controller!.setVolume(_isMuted ? 0 : 1);
      });
    } catch (e) {
      AppUtils.log('Error toggling mute: $e');
    }
  }

  @override
  void dispose() {
    // Unregister from manager
    try {
      VideoControllerManager.find.unregisterController(widget.postId);
    } catch (e) {
      AppUtils.log('Error unregistering controller: $e');
    }

    try {
      _controller?.pause();
      _controller?.dispose();
    } catch (e) {
      AppUtils.log('Error disposing controller: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null || !_controller!.value.isInitialized) {
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
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller!),

            // Corner Play/Pause button overlay
            Positioned(
              top: 8,
              left: 8,
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
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
                    color: Colors.black.withOpacity(0.7),
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
    );
  }
}
