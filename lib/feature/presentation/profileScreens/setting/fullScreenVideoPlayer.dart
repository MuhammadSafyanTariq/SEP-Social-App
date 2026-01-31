import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/appUtils.dart';

class FullScreenVideoPlayer extends StatefulWidget {
  final List<String> videoUrls;
  final int initialIndex;
  /// When set, shows a delete option (for own profile videos).
  final String? deletablePostId;
  /// Called after the post is successfully deleted.
  final VoidCallback? onPostDeleted;

  const FullScreenVideoPlayer({
    Key? key,
    required this.videoUrls,
    this.initialIndex = 0,
    this.deletablePostId,
    this.onPostDeleted,
  }) : super(key: key);

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  VideoPlayerController? _controller;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializeAndPlay(widget.initialIndex);
  }

  Future<void> _initializeAndPlay(int index) async {
    // Dispose previous controllers
    _chewieController?.dispose();
    await _controller?.dispose();

    // Initialize new video
    _controller = VideoPlayerController.network(widget.videoUrls[index])
      ..initialize()
          .then((_) {
            if (mounted) {
              setState(() {
                _chewieController = ChewieController(
                  videoPlayerController: _controller!,
                  autoPlay: true,
                  looping: false,
                  aspectRatio: _controller!.value.aspectRatio,
                  allowPlaybackSpeedChanging: true,
                  allowFullScreen: true,
                  allowMuting: true,
                  additionalOptions: widget.deletablePostId != null
                      ? (_) => [
                            OptionItem(
                              onTap: (_) => _confirmAndDelete(),
                              iconData: Icons.delete_outline,
                              title: 'Delete Video',
                            ),
                          ]
                      : null,
                );
              });
            }
          })
          .catchError((error) {
            debugPrint("Video Initialization Error: $error");
          });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child:
                _controller != null &&
                    _controller!.value.isInitialized &&
                    _chewieController != null
                ? Chewie(controller: _chewieController!)
                : const CircularProgressIndicator(color: Colors.white),
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
        ],
      ),
    );
  }

  void _confirmAndDelete() {
    if (!mounted) return;
    final navContext = context;
    showDialog(
      context: navContext,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Delete Video?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete this video? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ProfileCtrl.find
                    .removePost(widget.deletablePostId!)
                    .applyLoader;
                AppUtils.log('Video deleted successfully');
                widget.onPostDeleted?.call();
                if (mounted) Navigator.pop(navContext);
              } catch (_) {
                AppUtils.log('Failed to delete video');
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
