import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class FullScreenVideoPlayer extends StatefulWidget {
  final List<String> videoUrls;
  final int initialIndex;

  const FullScreenVideoPlayer({
    Key? key,
    required this.videoUrls,
    this.initialIndex = 0,
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
}
