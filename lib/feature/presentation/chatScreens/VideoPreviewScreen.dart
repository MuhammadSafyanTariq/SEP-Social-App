import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/textStyles.dart';

class VideoPreviewScreen extends StatefulWidget {
  final File? videoFile;
  final String? videoUrl;
  final VoidCallback? onSend;

  const VideoPreviewScreen({
    Key? key,
    this.videoFile,
    this.videoUrl,
    this.onSend,
  }) : super(key: key);

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoFile != null) {
      _controller = VideoPlayerController.file(widget.videoFile!);
    } else if (widget.videoUrl != null) {
      _controller = VideoPlayerController.network(widget.videoUrl!);
    } else {
      throw Exception("No video source provided.");
    }

    _controller.initialize().then((_) {
      setState(() => _isInitialized = true);
      _controller.play();
      _controller.setLooping(true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _isInitialized
                ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
                : const CircularProgressIndicator(color: Colors.white),
          ),

          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          if (widget.onSend != null)
            Positioned(
              bottom: 70,
              left: 20,
              right: 20,
              child: GestureDetector(
                onTap: widget.onSend,
                child: AppButton(
                  buttonColor: AppColors.btnColor,
                  label: "Send",
                  labelStyle: 16.txtBoldBlack,
                  radius: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
