import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../controller/auth_Controller/profileCtrl.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String? postId;

  const VideoPlayerScreen({Key? key, required this.videoUrl, this.postId})
    : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  final ProfileCtrl profileCtrl = Get.put(ProfileCtrl());

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    profileCtrl.videoCount(widget.postId ?? '');
    _videoController =
        VideoPlayerController.networkUrl(
            Uri.parse(widget.videoUrl),
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          )
          ..initialize()
              .then((_) {
                if (!mounted) return;
                setState(() {
                  _chewieController = ChewieController(
                    videoPlayerController: _videoController,
                    autoPlay: true,
                    looping: false,
                    allowFullScreen: true,
                  );
                });
              })
              .catchError((error) {
                debugPrint("Video initialization failed: $error");
              });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video player fills the entire screen
          Center(
            child: _chewieController != null
                ? Chewie(controller: _chewieController!)
                : const CircularProgressIndicator(color: Colors.white),
          ),
          // AppBar positioned at the top as an overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
