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
  late PageController _pageController;
  VideoPlayerController? _controller;
  ChewieController? _chewieController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
    _initializeAndPlay(_currentIndex);
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
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _initializeAndPlay(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.videoUrls.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Center(
                child:
                    _currentIndex == index &&
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
              // Page indicator
              if (widget.videoUrls.length > 1)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentIndex + 1} / ${widget.videoUrls.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
