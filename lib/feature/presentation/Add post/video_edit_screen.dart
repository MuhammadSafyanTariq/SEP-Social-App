import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoEditScreen extends StatefulWidget {
  final File file;

  const VideoEditScreen({super.key, required this.file});

  @override
  State<VideoEditScreen> createState() => _VideoEditScreenState();
}

class _VideoEditScreenState extends State<VideoEditScreen> {
  late final VideoPlayerController _controller;
  bool _isInitializing = true;
  bool _isSaving = false;
  Duration _videoDuration = Duration.zero;
  RangeValues _trimRange = const RangeValues(0, 0);
  final List<Uint8List?> _thumbnails = [];
  bool _isGeneratingThumbs = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      _controller = VideoPlayerController.file(widget.file);
      await _controller.initialize();
      _videoDuration = _controller.value.duration;

      final maxSeconds = _videoDuration.inSeconds.toDouble();
      _trimRange = RangeValues(0, maxSeconds);

      _generateThumbnails();

      await _controller.setLooping(true);
      setState(() {
        _isInitializing = false;
      });
      _controller.play();
    } catch (e) {
      AppUtils.log('Error initializing video editor: $e');
      AppUtils.toastError('Failed to open video. Please try another file.');
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _generateThumbnails() async {
    if (_isGeneratingThumbs) return;
    setState(() {
      _isGeneratingThumbs = true;
      _thumbnails.clear();
    });

    // Generate a small strip of frames across the whole video
    const frameCount = 8;
    final totalMs = _videoDuration.inMilliseconds;
    if (totalMs <= 0) {
      setState(() {
        _isGeneratingThumbs = false;
      });
      return;
    }

    for (int i = 0; i < frameCount; i++) {
      try {
        final ratio = frameCount == 1 ? 0.0 : i / (frameCount - 1);
        final timeMs = (totalMs * ratio).round();
        final bytes = await VideoThumbnail.thumbnailData(
          video: widget.file.path,
          timeMs: timeMs,
          imageFormat: ImageFormat.JPEG,
          quality: 70,
        );
        _thumbnails.add(bytes);
      } catch (e) {
        AppUtils.log('Thumbnail generation error: $e');
        _thumbnails.add(null);
      }
      if (!mounted) return;
      setState(() {});
    }

    if (mounted) {
      setState(() {
        _isGeneratingThumbs = false;
      });
    }
  }

  @override
  void dispose() {
    if (!_isInitializing) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveEdits() async {
    if (_isSaving || _isInitializing) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final start = _trimRange.start.round();
      final end = _trimRange.end.round();
      final durationSeconds = (end - start).clamp(1, _videoDuration.inSeconds);

      AppUtils.log(
        'Trimming video from $start to $end (duration $durationSeconds s)',
      );

      final info = await VideoCompress.compressVideo(
        widget.file.path,
        quality: VideoQuality.MediumQuality,
        includeAudio: true,
        startTime: start,
        duration: durationSeconds,
      );

      if (!mounted) return;

      final File? outputFile = info?.file;
      if (outputFile == null || !outputFile.existsSync()) {
        AppUtils.toastError('Failed to save edited video.');
        setState(() {
          _isSaving = false;
        });
        return;
      }

      Navigator.of(context).pop<File>(outputFile);
    } catch (e) {
      AppUtils.log('Error trimming video: $e');
      AppUtils.toastError('Error saving video. Please try again.');
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _formatTime(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
        ),
        title: const TextView(
          text: 'Edit Video',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: (_isSaving || _isInitializing) ? null : _saveEdits,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: _isInitializing
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : Column(
              children: [
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          VideoPlayer(_controller),
                          _PlayPauseOverlay(controller: _controller),
                          VideoProgressIndicator(
                            _controller,
                            allowScrubbing: true,
                            colors: const VideoProgressColors(
                              playedColor: AppColors.btnColor,
                              bufferedColor: Colors.white54,
                              backgroundColor: Colors.white24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TextView(
                        text: 'Trim video',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        margin: const EdgeInsets.only(top: 4, bottom: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatTime(
                                    Duration(
                                      seconds: _trimRange.start.round(),
                                    ),
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontFeatures: [FontFeature.tabularFigures()],
                                  ),
                                ),
                                Text(
                                  'Total ${_formatTime(_videoDuration)}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontFeatures: [FontFeature.tabularFigures()],
                                  ),
                                ),
                                Text(
                                  _formatTime(
                                    Duration(
                                      seconds: _trimRange.end.round(),
                                    ),
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontFeatures: [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 50,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: ColoredBox(
                                      color: Colors.black.withOpacity(0.5),
                                      child: Row(
                                        children: [
                                          for (final thumb in _thumbnails)
                                            Expanded(
                                              child: thumb == null
                                                  ? Container(
                                                      color: Colors.grey[800],
                                                    )
                                                  : Image.memory(
                                                      thumb,
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                          if (_thumbnails.isEmpty)
                                            const Expanded(
                                              child: Center(
                                                child: SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(
                                                      Colors.white54,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 2,
                                      activeTrackColor: Colors.transparent,
                                      inactiveTrackColor: Colors.transparent,
                                      thumbColor: Colors.white,
                                      overlayColor: Colors.transparent,
                                      rangeThumbShape:
                                          const _RectRangeSliderThumbShape(),
                                      rangeTrackShape:
                                          const _FullWidthRangeSliderTrackShape(),
                                    ),
                                    child: RangeSlider(
                                      values: _trimRange,
                                      min: 0,
                                      max: _videoDuration.inSeconds
                                          .clamp(1, 600)
                                          .toDouble(),
                                      onChanged: (values) {
                                        setState(() {
                                          if (values.end - values.start < 1) {
                                            final mid =
                                                (values.start + values.end) /
                                                    2.0;
                                            final clampedMid = mid.clamp(
                                              0,
                                              _videoDuration.inSeconds
                                                  .toDouble(),
                                            );
                                            _trimRange = RangeValues(
                                              clampedMid - 0.5,
                                              clampedMid + 0.5,
                                            );
                                          } else {
                                            _trimRange = values;
                                          }
                                        });
                                        final seekPosition = Duration(
                                          seconds: _trimRange.start.round(),
                                        );
                                        _controller.seekTo(seekPosition);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  final VideoPlayerController controller;

  const _PlayPauseOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (controller.value.isPlaying) {
          controller.pause();
        } else {
          controller.play();
        }
      },
      child: Stack(
        children: [
          if (!controller.value.isPlaying)
            const Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white70,
                size: 72,
              ),
            ),
        ],
      ),
    );
  }
}

class _RectRangeSliderThumbShape extends RangeSliderThumbShape {
  const _RectRangeSliderThumbShape();

  static const double _barWidth = 8;
  static const double _barHeight = 48;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(_barWidth, _barHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool isOnTop = false,
    required SliderThemeData sliderTheme,
    TextDirection textDirection = TextDirection.ltr,
    Thumb thumb = Thumb.start,
    bool isPressed = false,
  }) {
    final Canvas canvas = context.canvas;

    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: _barWidth,
        height: _barHeight,
      ),
      const Radius.circular(2),
    );

    canvas.drawRRect(rrect, paint);
  }
}

class _FullWidthRangeSliderTrackShape extends RangeSliderTrackShape {
  const _FullWidthRangeSliderTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 2;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset startThumbCenter,
    required Offset endThumbCenter,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    // We keep the track invisible because the thumbnails are the visual track.
  }
}



