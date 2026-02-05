import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:get/get.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';

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
  bool _isMuted = true;
  bool _hasReachedHalfway = false;
  bool _viewCounted = false;
  bool _hasError = false;
  String? _errorMessage;
  int _retryCount = 0;
  static const int _maxRetries = 2;

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

  // Get device max supported resolution based on screen size and capabilities
  int _getMaxSupportedResolution() {
    if (Platform.isAndroid) {
      // Conservative approach: Most Android devices can handle up to 1080p
      // High-end devices might handle 1440p, but we'll be conservative
      return 1920; // 1080p for most devices
    } else if (Platform.isIOS) {
      // iOS devices generally handle up to 1080p well
      return 1920; // 1080p
    }
    return 1920; // Default to 1080p
  }

  // Check if video URL supports HLS (adaptive streaming)
  bool _isHLSVideo(String url) {
    return url.toLowerCase().endsWith('.m3u8') ||
        url.toLowerCase().contains('/hls/') ||
        url.toLowerCase().contains('playlist.m3u8');
  }

  // Get optimal video URL - prefer HLS, fallback to MP4 with quality detection
  String _getOptimalVideoUrl(String originalUrl, int attempt) {
    // If HLS, use it directly (HLS handles quality automatically)
    if (_isHLSVideo(originalUrl)) {
      return originalUrl;
    }

    // For MP4, check if server provides multiple quality versions
    // Common patterns: video_1080p.mp4, video_720p.mp4, etc.
    if (attempt > 0 && originalUrl.contains('.mp4')) {
      final uri = Uri.parse(originalUrl);
      final path = uri.path;

      // Try to find lower quality versions by modifying filename
      if (attempt == 1 &&
          (path.contains('_4k') ||
              path.contains('_2160p') ||
              path.contains('_1440p'))) {
        // Replace 4K/1440p with 1080p
        final newPath = path
            .replaceAll('_4k', '_1080p')
            .replaceAll('_2160p', '_1080p')
            .replaceAll('_1440p', '_1080p');
        return uri.replace(path: newPath).toString();
      } else if (attempt == 2 && path.contains('_1080p')) {
        // Replace 1080p with 720p
        final newPath = path.replaceAll('_1080p', '_720p');
        return uri.replace(path: newPath).toString();
      }
    }

    return originalUrl;
  }

  Future<void> _initializeVideo({
    int attempt = 0,
    bool useSoftwareDecoding = false,
  }) async {
    try {
      // Get optimal URL based on retry attempt and video type
      final videoUrl = _getOptimalVideoUrl(widget.videoUrl, attempt);

      // Log video type for debugging
      if (attempt == 0) {
        AppUtils.log(
          'Initializing video: ${_isHLSVideo(videoUrl) ? "HLS (adaptive)" : "MP4 (single quality)"}',
        );
      }

      // For single-quality videos, we'll try software decoding as last resort
      // Note: video_player doesn't directly expose software decoding
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      // Add timeout to prevent hanging - increased for slow networks/large files
      await _controller!.initialize().timeout(
        const Duration(seconds: 30), // Increased from 10 to 30 seconds
        onTimeout: () {
          throw TimeoutException(
            'Video initialization timed out after 30 seconds. This may be due to slow network or large file size.',
          );
        },
      );

      // Check if initialization was successful
      if (!_controller!.value.isInitialized) {
        throw Exception('Video failed to initialize');
      }

      // Check video resolution and retry with lower quality if too high
      final videoSize = _controller!.value.size;
      final maxResolution = _getMaxSupportedResolution();

      if (videoSize.width > maxResolution &&
          attempt == 0 &&
          _retryCount < _maxRetries) {
        AppUtils.log(
          'Video resolution (${videoSize.width}x${videoSize.height}) exceeds recommended max ($maxResolution). Retrying with lower quality...',
        );
        // Dispose and retry with lower quality
        await _controller?.dispose();
        _controller = null;

        if (mounted) {
          setState(() {
            _retryCount++;
          });
          // Retry with lower quality
          await Future.delayed(const Duration(milliseconds: 500));
          return _initializeVideo(attempt: _retryCount);
        }
      }

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
          // Check for errors during playback
          if (_controller!.value.hasError) {
            AppUtils.log(
              'Video playback error: ${_controller!.value.errorDescription}',
            );

            // Try to recover from playback errors
            if (_retryCount < _maxRetries) {
              _retryCount++;
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  _initializeVideo(attempt: _retryCount);
                }
              });
              return;
            }

            setState(() {
              _hasError = true;
              _errorMessage = 'Video playback error';
              _isInitialized = false;
            });
            return;
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
          _hasError = false;
          _errorMessage = null;
          _retryCount = 0; // Reset retry count on success
        });
      }
    } catch (e) {
      AppUtils.log('Error initializing video (attempt $attempt): $e');

      // Check for specific error types
      final errorString = e.toString().toLowerCase();
      bool isFormatError =
          errorString.contains('exceeds_capabilities') ||
          errorString.contains('format_supported=no') ||
          errorString.contains('mediacodec') ||
          errorString.contains('codec') ||
          errorString.contains('exoplayer');

      bool isTimeoutError =
          errorString.contains('timeout') ||
          errorString.contains('timed out') ||
          e is TimeoutException;

      bool isNetworkError =
          errorString.contains('socket') ||
          errorString.contains('connection') ||
          errorString.contains('network') ||
          errorString.contains('failed host lookup');

      // Retry on timeout or network errors (up to max retries)
      if ((isTimeoutError || isNetworkError) && _retryCount < _maxRetries) {
        _retryCount++;
        AppUtils.log(
          '${isTimeoutError ? "Timeout" : "Network"} error detected. Retrying (attempt $_retryCount/$_maxRetries)...',
        );

        // Dispose current controller
        try {
          await _controller?.dispose();
          _controller = null;
        } catch (_) {
          // Ignore disposal errors
        }

        // Wait longer before retry for network issues
        if (mounted) {
          await Future.delayed(Duration(seconds: isTimeoutError ? 2 : 1));
          return _initializeVideo(attempt: _retryCount);
        }
      }

      // Retry with lower quality if format error and haven't exceeded max retries
      if (isFormatError && _retryCount < _maxRetries) {
        _retryCount++;
        AppUtils.log(
          'Format error detected. Retrying with lower quality (attempt $_retryCount)...',
        );

        // Dispose current controller
        try {
          await _controller?.dispose();
          _controller = null;
        } catch (_) {
          // Ignore disposal errors
        }

        // Retry with lower quality after a short delay
        if (mounted) {
          await Future.delayed(const Duration(milliseconds: 500));
          return _initializeVideo(attempt: _retryCount);
        }
      }

      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitialized = false;
          if (isFormatError && _retryCount >= _maxRetries) {
            _errorMessage = 'Video format not supported on this device';
          } else if (isFormatError) {
            _errorMessage =
                'Video format not supported. Trying lower quality...';
          } else if (isTimeoutError && _retryCount >= _maxRetries) {
            _errorMessage =
                'Video took too long to load. Please check your connection.';
          } else if (isNetworkError && _retryCount >= _maxRetries) {
            _errorMessage =
                'Network error. Please check your internet connection.';
          } else {
            _errorMessage = 'Failed to load video';
          }
        });
      }

      // Dispose controller on error to prevent memory leaks
      try {
        await _controller?.dispose();
        _controller = null;
      } catch (_) {
        // Ignore disposal errors
      }
    }
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (!mounted || _controller == null || !_isInitialized || _hasError) return;

    // Video is considered "in focus" when more than 50% visible
    final isVisible = info.visibleFraction > 0.5;

    if (isVisible && !_controller!.value.isPlaying) {
      // Pause all other videos first
      try {
        VideoControllerManager.find.pauseAll();
      } catch (e) {
        AppUtils.log('Error pausing other videos: $e');
      }

      // Play this video with error handling
      try {
        _controller!.play();
        if (mounted) {
          setState(() {
            _isPlaying = true;
          });
        }
      } catch (e) {
        AppUtils.log('Error playing video: $e');
        // If play fails, mark as error
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Failed to play video';
          });
        }
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

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _isPlaying = false;
      } else {
        _controller!.play();
        _isPlaying = true;
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
    // Show error state
    if (_hasError) {
      return AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.white70, size: 48),
                SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    _errorMessage ?? 'Video unavailable',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                      _errorMessage = null;
                      _retryCount = 0; // Reset retry count
                    });
                    _initializeVideo(attempt: 0);
                  },
                  child: Text('Retry', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show loading state
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
