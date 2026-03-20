import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:video_player/video_player.dart';
import 'package:sep/components/coreComponents/sep_image_filter.dart';
import 'video_edit_screen.dart';
import 'package:sep/utils/video_filter_exporter.dart';

class VideoPreviewResult {
  final File videoFile;
  final int filterPresetIndex;

  const VideoPreviewResult({
    required this.videoFile,
    required this.filterPresetIndex,
  });
}

class PostVideoPreviewScreen extends StatefulWidget {
  final File videoFile;
  final String? caption;
  final Future<void> Function(File videoFile)? onPublish;
  final int initialPresetIndex;

  const PostVideoPreviewScreen({
    super.key,
    required this.videoFile,
    this.caption,
    this.onPublish,
    this.initialPresetIndex = 0,
  });

  @override
  State<PostVideoPreviewScreen> createState() => _PostVideoPreviewScreenState();
}

class _PostVideoPreviewScreenState extends State<PostVideoPreviewScreen> {
  late File _currentVideoFile;
  VideoPlayerController? _controller;
  bool _initializing = true;
  bool _publishing = false;
  bool _isTrimming = false;
  late int _selectedPreset;
  bool _showFilters = true;

  @override
  void initState() {
    super.initState();
    _currentVideoFile = widget.videoFile;
    _selectedPreset = widget.initialPresetIndex;
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    // Recreate controller whenever the underlying file changes (trimmed vs original).
    setState(() => _initializing = true);
    _controller?.dispose();
    _controller = null;

    _controller = VideoPlayerController.file(_currentVideoFile);
    try {
      await _controller!.initialize();
      await _controller!.setLooping(true);
      setState(() {
        _initializing = false;
      });
      _controller!.play();
    } catch (_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _handlePublish() async {
    if (_publishing) return;

    // If no onPublish is provided, treat as confirm-only: return the file.
    if (widget.onPublish == null) {
      Navigator.of(context).pop<VideoPreviewResult>(
        VideoPreviewResult(
          videoFile: _currentVideoFile,
          filterPresetIndex: _selectedPreset,
        ),
      );
      return;
    }

    setState(() {
      _publishing = true;
    });

    // Burn the selected preset into the exported video right before upload.
    final File? finalVideoFile = await VideoFilterExporter.applyPresetToVideo(
      inputFile: _currentVideoFile,
      presetIndex: _selectedPreset,
    );
    if (!mounted) return;

    if (finalVideoFile == null) {
      setState(() => _publishing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to apply filter to video.')),
      );
      return;
    }

    await widget.onPublish!(finalVideoFile);
    if (mounted) {
      setState(() {
        _publishing = false;
      });
    }
  }

  Future<void> _handleTrim() async {
    if (_isTrimming || _initializing) return;
    setState(() => _isTrimming = true);
    try {
      final editedFile = await Navigator.of(context).push<File?>(
        MaterialPageRoute(
          builder: (_) => VideoEditScreen(file: _currentVideoFile),
          fullscreenDialog: true,
        ),
      );

      if (editedFile == null || !mounted) return;

      setState(() {
        _currentVideoFile = editedFile;
      });
      await _initPlayer();
    } catch (e) {
      // If trimming fails, keep the current file.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to trim video.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isTrimming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed:
              (_publishing || _isTrimming || _initializing) ? null : () => Navigator.of(context).pop(),
        ),
        title: const TextView(
          text: 'Preview',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Trim video',
            icon: Icon(
              Icons.content_cut,
              color: (_isTrimming || _publishing || _initializing)
                  ? Colors.white54
                  : Colors.white,
            ),
            onPressed: (_isTrimming || _publishing || _initializing)
                ? null
                : _handleTrim,
          ),
          IconButton(
            tooltip: _showFilters ? 'Hide filters' : 'Show filters',
            icon: Icon(
              Icons.filter_alt,
              color: _showFilters ? AppColors.btnColor : Colors.white54,
            ),
            onPressed: (_isTrimming || _publishing || _initializing)
                ? null
                : () => setState(() => _showFilters = !_showFilters),
          ),
          TextButton(
            onPressed: (_publishing || _isTrimming || _initializing)
                ? null
                : _handlePublish,
            child: _publishing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    widget.onPublish == null ? 'Use video' : 'Publish',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: _initializing
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: SepImageFilter(
                        settings: EnhancementPresets.byIndex(_selectedPreset),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.6),
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              VideoPlayer(_controller!),
                              _PreviewPlayPauseOverlay(controller: _controller!),
                              VideoProgressIndicator(
                                _controller!,
                                allowScrubbing: true,
                                padding: EdgeInsets.zero,
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
                  ),
                ),
                const SizedBox(height: 8),
                if (_showFilters) _buildFilterRow(),
                if (widget.caption != null && widget.caption!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Divider(
                    color: Colors.white24,
                    height: 1,
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.black,
                    child: Text(
                      widget.caption!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildFilterRow() {
    final names = EnhancementPresets.names;

    return SizedBox(
      height: 70,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: names.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == _selectedPreset;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPreset = index;
              });
            },
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.btnColor.withOpacity(0.18)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? AppColors.btnColor : Colors.white24,
                  width: selected ? 2 : 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        color: Colors.black,
                        child: EnhancementPresets.assetForIndex(index) != null
                            ? Image.asset(
                                EnhancementPresets.assetForIndex(index)!,
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.filter_alt,
                                size: 20,
                                color: Colors.white70,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    names[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PreviewPlayPauseOverlay extends StatelessWidget {
  final VideoPlayerController controller;

  const _PreviewPlayPauseOverlay({required this.controller});

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

