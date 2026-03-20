import 'package:flutter/material.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/auto_play_video_player.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/post_card_header.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/read_more_text.dart';
import 'package:sep/main.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sep/services/music/deezer_api.dart';
import '../../../../components/styles/appColors.dart';
import '../../../../utils/image_utils.dart';
import '../../../data/models/dataModels/post_data.dart';
import '../../../../utils/video_quality_helper.dart';
import 'dart:ui' as ui;
import 'package:audioplayers/audioplayers.dart';
import 'package:visibility_detector/visibility_detector.dart';

List<String> videoExtensions = [
  "mp4",
  "mkv",
  "mov",
  "avi",
  "wmv",
  "flv",
  "webm",
  "mpeg",
  "mpg",
  "3gp",
  "ogv",
  "ogg",
  "ts",
  "m2ts",
  "m4v",
  "asf",
  "rm",
  "rmvb",
  "divx",
  "vob",
  "f4v",
  "mxf",
  "prores",
];

String getFileExtn(String? data) {
  if (data.isNotNullEmpty) {
    final array = data!.split('.');
    if (array.length > 1) {
      AppUtils.log(array.last);
      return array.last.toLowerCase();
    } else {
      return '';
    }
  } else {
    return '';
  }
}

class PostCard extends StatelessWidget {
  final String caption;
  final List<FileElement> imageUrls;
  final String likes;
  final String comments;
  final VoidCallback? onTap;
  final PostCardHeader header;
  final Widget footer;
  final String postId;
  final PostAudio? audio;

  PostCard({
    Key? key,
    required this.caption,
    required this.imageUrls,
    required this.likes,
    required this.comments,
    this.onTap,
    required this.header,
    required this.footer,
    required this.postId,
    this.audio,
  }) : super(key: key);

  final PageController _pageController = PageController();
  static final AudioPlayer _sharedAudioPlayer = AudioPlayer();
  static String? _currentAudioUrl;
  static final Set<String> _audioDebugLoggedPostIds = <String>{};
  static bool _audioEnabled = true;

  /// Stop any currently playing post audio (shared across all PostCards).
  /// This is needed when leaving the Home tab, because some widgets may remain
  /// mounted and `VisibilityDetector` might not fire immediately.
  static void stopSharedAudio() {
    try {
      // Fire-and-forget: we don't want tab switching to wait on audio I/O.
      _sharedAudioPlayer.stop();
    } catch (_) {
      // Ignore audio stop failures.
    }
    _currentAudioUrl = null;
  }

  /// Enable/disable post-audio autoplay globally.
  ///
  /// When disabled, `_AutoPlayPostAudio` will not start playback even if
  /// `VisibilityDetector` reports the widget as visible.
  static void setAudioEnabled(bool enabled) {
    _audioEnabled = enabled;
    if (!enabled) stopSharedAudio();
  }

  bool isVideo(FileElement file) {
    // First check the type field if available
    if (file.type != null && file.type!.toLowerCase() == 'video') {
      return true;
    }

    // Fallback: check file extension
    final fileUrl = file.file ?? '';
    if (fileUrl.isNotEmpty) {
      final extension = getFileExtn(fileUrl).toLowerCase();
      return videoExtensions.contains(extension);
    }

    return false;
  }

  /// Calculate precise aspect ratio with safety checks
  double calculateAspectRatio(
    double? width,
    double? height, {
    double fallback = 16 / 9,
  }) {
    if (width == null || height == null || width <= 0 || height <= 0) {
      return fallback;
    }

    final ratio = width / height;

    // Clamp extreme aspect ratios to prevent UI issues
    const minRatio = 0.2; // Very tall images (1:5)
    const maxRatio = 5.0; // Very wide images (5:1)

    return ratio.clamp(minRatio, maxRatio);
  }

  /// Calculate optimal aspect ratio for multi-image carousel
  double calculateCarouselAspectRatio(List<FileElement> images) {
    if (images.isEmpty) return 1.0;

    double totalRatio = 0;
    int validRatios = 0;

    for (final image in images) {
      if (image.x != null && image.y != null && image.x! > 0 && image.y! > 0) {
        totalRatio += calculateAspectRatio(image.x, image.y);
        validRatios++;
      }
    }

    if (validRatios == 0) return 1.0;

    final averageRatio = totalRatio / validRatios;

    // For carousel, prefer slightly square ratios for consistency
    // but still respect the content
    if (averageRatio > 1.5) return 1.5; // Limit wide ratios
    if (averageRatio < 0.75) return 0.75; // Limit tall ratios

    return averageRatio;
  }

  Widget buildMediaItem(FileElement file, BuildContext context) {
    if (isVideo(file)) {
      // Use optimal video quality based on device capabilities
      final videoUrl = VideoQualityHelper.getOptimalVideoUrl(
        file,
        context: context,
      );
      final preciseAspectRatio = calculateAspectRatio(
        file.x,
        file.y,
        fallback: 16 / 9,
      );

      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AutoPlayVideoPlayer(
          videoUrl: videoUrl,
          postId: postId,
          aspectRatio: preciseAspectRatio,
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageView(
          file.file!,
          context: context,
          height: file.y,
          width: file.x,
        ),
      );
    }
  }

  /// Build media item specifically for carousel to prevent overflow
  Widget buildMediaItemForCarousel(FileElement file, BuildContext context) {
    if (isVideo(file)) {
      // Use optimal video quality based on device capabilities
      final videoUrl = VideoQualityHelper.getOptimalVideoUrl(
        file,
        context: context,
      );
      final preciseAspectRatio = calculateAspectRatio(
        file.x,
        file.y,
        fallback: 16 / 9,
      );

      return AutoPlayVideoPlayer(
        videoUrl: videoUrl,
        postId: postId,
        aspectRatio: preciseAspectRatio,
      );
    } else {
      return imageViewForCarousel(
        file.file!,
        context: context,
        height: file.y,
        width: file.x,
      );
    }
  }

  Widget imageView(
    String url, {
    double? height,
    double? width,
    BuildContext? context,
  }) {
    // Calculate responsive sizing
    final screenHeight = MediaQuery.of(navState.currentContext!).size.height;
    final screenWidth = MediaQuery.of(navState.currentContext!).size.width;
    final maxHeight = screenHeight * 0.65; // Max 65% of screen height

    // For images with known dimensions, calculate optimal size
    if (height != null && width != null && height > 0 && width > 0) {
      // Calculate display dimensions while respecting aspect ratio
      double displayHeight = height;
      double displayWidth = width;

      // More precise scaling calculation
      final scaleForHeight = maxHeight / height;
      final scaleForWidth = screenWidth / width;
      final optimalScale = (scaleForHeight < scaleForWidth)
          ? scaleForHeight
          : scaleForWidth;

      // Apply scaling only if needed (image is larger than constraints)
      if (optimalScale < 1.0) {
        displayHeight = height * optimalScale;
        displayWidth = width * optimalScale;
      }

      // Final safety check to ensure we don't exceed screen bounds
      if (displayHeight > maxHeight) {
        final heightScale = maxHeight / displayHeight;
        displayHeight = maxHeight;
        displayWidth = displayWidth * heightScale;
      }

      if (displayWidth > screenWidth) {
        final widthScale = screenWidth / displayWidth;
        displayWidth = screenWidth;
        displayHeight = displayHeight * widthScale;
      }

      // Use Container with flexible constraints to adjust to image dimensions
      return Container(
        constraints: BoxConstraints(
          maxHeight: displayHeight,
          maxWidth: displayWidth,
          minHeight: 100,
          minWidth: 100,
        ),
        child: _PinchGestureHandler(
          child: SizedImage(
            maxHeight: displayHeight,
            maxWidth: displayWidth,
            size: ui.Size(displayWidth, displayHeight),
            url: url.fileUrl ?? '',
          ),
        ),
      );
    }

    // For images without known dimensions, use flexible sizing with constraints
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
        maxWidth: screenWidth,
        minHeight: 100, // Minimum height for unknown dimension images
      ),
      child: _PinchGestureHandler(
        child: Image.network(
          url.fileUrl ?? '',
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                color: Colors.white,
                width: double.infinity,
                height: 200,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 150,
              child: Center(
                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Image view specifically designed for carousel to prevent overflow
  Widget imageViewForCarousel(
    String url, {
    double? height,
    double? width,
    BuildContext? context,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: _PinchGestureHandler(
        child: Image.network(
          url.fileUrl ?? '',
          fit: BoxFit
              .cover, // Use cover to fill the container and prevent overflow
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                color: Colors.white,
                width: double.infinity,
                height: double.infinity,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSingleImage = imageUrls.isNotEmpty && imageUrls.length == 1;
    final screenHeight = MediaQuery.of(context).size.height;
    final hasAudio = audio != null && (audio!.file ?? '').isNotEmpty;
    final audioUrl =
        hasAudio ? AppUtils.configImageUrl(audio!.file ?? '') : null;
    final int? deezerTrackId = audio?.duration;

    // Debug: confirm backend returns what we expect for autoplay.
    if (hasAudio && !_audioDebugLoggedPostIds.contains(postId)) {
      _audioDebugLoggedPostIds.add(postId);
      final fileRaw = audio!.file ?? '';
      final filePreview =
          fileRaw.length > 90 ? '${fileRaw.substring(0, 90)}...' : fileRaw;
      AppUtils.log(
        'DEBUG post audio model. postId=$postId file="$filePreview" duration(trackId?)=${audio?.duration} title="${audio?.title}"',
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            header,
            // Helper that auto-plays this post's audio when visible.
            if (hasAudio && audioUrl != null)
              _AutoPlayPostAudio(
                url: audioUrl,
                postId: postId,
                deezerTrackId: deezerTrackId,
              ),
            Visibility(
              visible: caption.isNotNullEmpty,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: ReadMoreText(text: caption),
              ),
            ),
            if (imageUrls.isNotEmpty)
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: screenHeight * 0.7,
                    minHeight:
                        100, // Minimum height to prevent too small images
                  ),
                  child: isSingleImage
                      ? buildMediaItem(imageUrls[0], context)
                      : Container(
                          height:
                              screenHeight *
                              0.5, // Fixed height for carousel to prevent overflow
                          child: PageView.builder(
                            scrollDirection: Axis.horizontal,
                            controller: _pageController,
                            itemCount: imageUrls.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2.0,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: buildMediaItemForCarousel(
                                    imageUrls[index],
                                    context,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ),

            SizedBox(height: 10),
            if (imageUrls.length > 1)
              Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: imageUrls.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: AppColors.btnColor,
                    dotColor: AppColors.Grey,
                    dotHeight: 4,
                    dotWidth: 10,
                  ),
                ),
              ),

            footer,
          ],
        ),
      ),
    );
  }

}

class _AutoPlayPostAudio extends StatefulWidget {
  final String url;
  final String postId;
  final int? deezerTrackId;

  const _AutoPlayPostAudio({
    Key? key,
    required this.url,
    required this.postId,
    required this.deezerTrackId,
  }) : super(key: key);

  @override
  State<_AutoPlayPostAudio> createState() => _AutoPlayPostAudioState();
}

class _AutoPlayPostAudioState extends State<_AutoPlayPostAudio> {
  bool _isPlaying = false;

  int? _maybeTrackIdFromDuration(int? value) {
    if (value == null) return null;
    // Deezer track ids are typically large; Deezer "duration (seconds)" is small.
    return value > 100000 ? value : null;
  }

  int? _getUnixExpFromDeezerUrl(String url) {
    // Deezer signed preview URLs contain `exp=<unixSeconds>` inside `hdnea`.
    // If parsing fails, return null and just play the URL as-is.
    try {
      final match = RegExp(r'exp=(\d+)').firstMatch(url);
      if (match == null) return null;
      return int.tryParse(match.group(1) ?? '');
    } catch (_) {
      return null;
    }
  }

  int? _extractDeezerTrackId(String rawValue) {
    const marker = '::trackId=';
    if (!rawValue.contains(marker)) return null;
    final idPart = rawValue.split(marker).last;
    return int.tryParse(idPart);
  }

  Future<String> _resolveAudioPlaybackUrl(String rawValue) async {
    // Best path: use persisted deezerTrackId from PostAudio.duration.
    final trackIdFromModel = _maybeTrackIdFromDuration(widget.deezerTrackId);
    if (trackIdFromModel != null) {
      final freshPreviewUrl = await DeezerApi.previewUrlForTrackId(trackIdFromModel);
      if (freshPreviewUrl != null && freshPreviewUrl.isNotEmpty) {
        AppUtils.log('Deezer preview resolved from trackId=$trackIdFromModel exp=${_getUnixExpFromDeezerUrl(freshPreviewUrl)}');
        return freshPreviewUrl;
      }
    }

    final trackId = _extractDeezerTrackId(rawValue);
    if (trackId != null) {
      // Some signed URLs can expire very quickly; if `exp` is too close,
      // fetch again once before playback.
      for (var attempt = 0; attempt < 2; attempt++) {
        final freshPreviewUrl =
            await DeezerApi.previewUrlForTrackId(trackId);
        if (freshPreviewUrl == null || freshPreviewUrl.isEmpty) continue;

        final expUnix = _getUnixExpFromDeezerUrl(freshPreviewUrl);
        final nowUnix = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        // If we can read exp and it's within the next 10 seconds, retry.
        if (expUnix != null && (expUnix - nowUnix) <= 10) {
          continue;
        }

        // Avoid logging full signed URLs; tokenized URLs can be large.
        AppUtils.log('Deezer preview resolved. trackId=$trackId exp=$expUnix');
        return freshPreviewUrl;
      }
    }

    // Fallback: use the stored previewUrl part if present.
    const marker = '::trackId=';
    if (rawValue.contains(marker)) {
      return rawValue.split(marker).first;
    }

    return rawValue;
  }

  Future<void> _handleVisibilityChanged(VisibilityInfo info) async {
    if (!mounted) return;

    // If Home is not active, never start autoplay (and pause if needed).
    if (!PostCard._audioEnabled) {
      if (_isPlaying && PostCard._currentAudioUrl == widget.url) {
        try {
          await PostCard._sharedAudioPlayer.pause();
        } catch (_) {}
      }
      return;
    }

    final isVisible = info.visibleFraction > 0.6;

    if (isVisible) {
      try {
        if (PostCard._currentAudioUrl != widget.url) {
          await PostCard._sharedAudioPlayer.stop();
          PostCard._currentAudioUrl = widget.url;
        }
        final playbackUrl = await _resolveAudioPlaybackUrl(widget.url);
        AppUtils.log('Playing post audio. exp=${_getUnixExpFromDeezerUrl(playbackUrl)} trackId=${_maybeTrackIdFromDuration(widget.deezerTrackId)}');
        await PostCard._sharedAudioPlayer.play(UrlSource(playbackUrl));
        if (mounted) {
          setState(() {
            _isPlaying = true;
          });
        }
      } catch (e) {
        final trackId = _maybeTrackIdFromDuration(widget.deezerTrackId) ?? _extractDeezerTrackId(widget.url);
        AppUtils.log('Error auto-playing post audio: $e. trackId=$trackId');

        // Retry once with a freshly generated preview URL.
        if (trackId != null) {
          try {
            final freshPreviewUrl = await DeezerApi.previewUrlForTrackId(trackId);
            if (freshPreviewUrl != null && freshPreviewUrl.isNotEmpty) {
              AppUtils.log('Retrying Deezer preview play. exp=${_getUnixExpFromDeezerUrl(freshPreviewUrl)}');
              await PostCard._sharedAudioPlayer.play(UrlSource(freshPreviewUrl));
              if (mounted) {
                setState(() => _isPlaying = true);
              }
            }
          } catch (_) {}
        }
      }
    } else {
      if (_isPlaying && PostCard._currentAudioUrl == widget.url) {
        try {
          await PostCard._sharedAudioPlayer.pause();
        } catch (_) {}
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tiny widget whose only job is to react to visibility changes
    return VisibilityDetector(
      key: ValueKey('post-audio-${widget.postId}'),
      onVisibilityChanged: _handleVisibilityChanged,
      child: const SizedBox(
        height: 1,
        width: double.infinity,
      ),
    );
  }
}

class _PinchGestureHandler extends StatefulWidget {
  final Widget child;
  const _PinchGestureHandler({required this.child});

  @override
  State<_PinchGestureHandler> createState() => _PinchGestureHandlerState();
}

class _PinchGestureHandlerState extends State<_PinchGestureHandler> {
  @override
  Widget build(BuildContext context) {
    return PinchZoom(maxScale: 3.5, child: widget.child);
  }
}
