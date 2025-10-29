import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/feature/data/models/dataModels/post_data.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/post_card_header.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/read_more_text.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/videoPlayerScreen.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/widget.dart';
import 'package:sep/utils/image_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui' as ui;
import 'package:sep/main.dart';

class PostVideo extends StatefulWidget {
  final PostCardHeader header;
  final Widget footer;
  final VoidCallback? view;
  final PostData data;
  const PostVideo({
    super.key,
    required this.header,
    required this.footer,
    this.view,
    required this.data,
  });

  @override
  State<PostVideo> createState() => _PostVideoState();
}

class _PostVideoState extends State<PostVideo>
    with WidgetsBindingObserver, RouteAware {
  final GlobalKey _videoKey = GlobalKey();
  bool _isInView = false;
  bool _isPageActive = true;
  ScrollNotificationObserverState? _scrollNotificationObserver;

  FileElement? get file => widget.data.files.first;
  String? get caption => widget.data.content;
  String? get videoUrl => widget.data.files.first.file;
  String? get postId => widget.data.id;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollNotificationObserver?.removeListener(_onScroll);
    _scrollNotificationObserver = ScrollNotificationObserver.of(context);
    _scrollNotificationObserver?.addListener(_onScroll);

    // Subscribe to route observer
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollNotificationObserver?.removeListener(_onScroll);
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // App went to background or is inactive
      setState(() {
        _isPageActive = false;
      });
    } else if (state == AppLifecycleState.resumed) {
      // App came back to foreground
      setState(() {
        _isPageActive = true;
      });
      _checkVisibility();
    }
  }

  @override
  void didPushNext() {
    // User navigated to another screen - pause all videos
    setState(() {
      _isPageActive = false;
    });
    AppUtils.log(
      'PostVideo: User navigated away from home screen - pausing video',
    );
  }

  @override
  void didPopNext() {
    // User came back from another screen - resume if in view
    setState(() {
      _isPageActive = true;
    });
    _checkVisibility();
    AppUtils.log(
      'PostVideo: User returned to home screen - checking visibility',
    );
  }

  void _onScroll(ScrollNotification notification) {
    _checkVisibility();
  }

  void _checkVisibility() {
    if (!mounted || !_isPageActive) return;

    final RenderBox? renderBox =
        _videoKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenHeight = MediaQuery.of(context).size.height;

    // Check if at least 50% of the video is visible
    final visibleTop =
        position.dy < screenHeight && position.dy + size.height > 0;
    final visibilityPercentage = _calculateVisibilityPercentage(
      position.dy,
      size.height,
      screenHeight,
    );

    final shouldBeInView = visibleTop && visibilityPercentage > 0.5;

    if (_isInView != shouldBeInView) {
      setState(() {
        _isInView = shouldBeInView;
      });
    }
  }

  double _calculateVisibilityPercentage(
    double top,
    double height,
    double screenHeight,
  ) {
    if (top >= screenHeight || top + height <= 0) return 0.0;

    final visibleTop = top < 0 ? 0.0 : top;
    final visibleBottom = (top + height) > screenHeight
        ? screenHeight
        : (top + height);
    final visibleHeight = visibleBottom - visibleTop;

    return (visibleHeight / height).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    AppUtils.log(file?.thumbnail.fileUrl ?? '');

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Card(
        key: _videoKey,
        margin: 10.all,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.header,
            10.height,
            Visibility(
              visible: widget.data.content.isNotNullEmpty,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 8),
                child: ReadMoreText(text: widget.data.content ?? ''),
              ),
            ),
            10.height,
            AspectRatio(
              aspectRatio: 2 / 3, // 2:3 aspect ratio (portrait format)
              child: Container(
                width: context.getWidth,
                color: Colors.black,
                child: _VideoFrame(
                  data: file,
                  shouldAutoPlay: _isInView && _isPageActive,
                  videoUrl: videoUrl?.fileUrl,
                  postId: postId,
                ),
              ),
            ),
            widget.footer,
          ],
        ),
      ),
    );
  }

  // Positioned playButton(){
  //   return Positioned(
  //     bottom: 20.sdp,
  //     right: 8.sdp,
  //     child:
  //
  //     IconButton(
  //       icon: Icon(true ? Icons.volume_off : Icons.volume_up, color: Colors.white),
  //       onPressed: (){},
  //     )
  //
  //
  //     // IconButton(
  //     //   icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white),
  //     //   onPressed: _toggleMute,
  //     // ),
  //   );
  // }

  Positioned playButton(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () async {
          await context.pushNavigator(
            VideoPlayerScreen(videoUrl: videoUrl!.fileUrl!, postId: postId),
          );
        },
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.play_arrow, color: Colors.white, size: 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoFrame extends StatefulWidget {
  final FileElement? data;
  final bool shouldAutoPlay;
  final String? videoUrl;
  final String? postId;
  const _VideoFrame({
    this.data,
    this.shouldAutoPlay = false,
    this.videoUrl,
    this.postId,
  });

  @override
  State<_VideoFrame> createState() => _VideoFrameState();
}

class _VideoFrameState extends State<_VideoFrame> {
  FileElement? get data => widget.data;
  String? get videoUrl => data?.file.fileUrl ?? '';
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;

  Rx<VideoPlayerValue> playerState = Rx(VideoPlayerValue.uninitialized());

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(_VideoFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-play/pause based on visibility
    if (widget.shouldAutoPlay != oldWidget.shouldAutoPlay) {
      if (widget.shouldAutoPlay) {
        _playVideo();
      } else {
        _pauseVideo();
      }
    }
  }

  @override
  void dispose() {
    _videoController.removeListener(listener);
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void listener() {
    _videoController.addListener(() {
      final newState = _videoController.value;
      playerState.value = newState;
    });
  }

  void _playVideo() {
    if (playerState.value.isInitialized && !_videoController.value.isPlaying) {
      _videoController.play();
    }
  }

  void _pauseVideo() {
    if (playerState.value.isInitialized && _videoController.value.isPlaying) {
      _videoController.pause();
    }
  }

  void _initializeVideo() {
    if (!(data?.file.isNotNullEmpty ?? false)) {
      debugPrint("Video URL is empty!");
      return;
    }

    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl ?? ''),
    );
    listener();
    _videoController
        .initialize()
        .then((_) {
          if (!mounted) return;
          _chewieController = ChewieController(
            videoPlayerController: _videoController,
            aspectRatio: _videoController.value.aspectRatio > 0
                ? _videoController.value.aspectRatio
                : 16 / 9,
            autoPlay: false,
            looping: true,
            allowFullScreen: true,
            showControls: false,
            // Preserve aspect ratio - don't stretch video
            materialProgressColors: ChewieProgressColors(
              playedColor: Colors.red,
              handleColor: Colors.red,
              backgroundColor: Colors.grey,
              bufferedColor: Colors.lightGreen,
            ),
          );

          // Auto-play if in view after initialization
          if (widget.shouldAutoPlay) {
            _playVideo();
          }
        })
        .catchError((error) {
          debugPrint("Video initialization failed: $error");
        });
  }

  void _togglePlayPause() {
    if (playerState.value.isInitialized) {
      if (_videoController.value.isPlaying) {
        _pauseVideo();
      } else {
        _playVideo();
      }
    }
  }

  Widget playerView() {
    return Center(
      child: AspectRatio(
        aspectRatio: _videoController.value.aspectRatio > 0
            ? _videoController.value.aspectRatio
            : 16 / 9,
        child: Chewie(controller: _chewieController!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => !playerState.value.isInitialized
          ? Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.grey,
              ),
            )
          : Stack(
              alignment: Alignment.center,
              children: [
                playerView(),
                // Tap area for play/pause
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(color: Colors.transparent),
                  ),
                ),
                // Play/Pause button overlay
                if (!playerState.value.isPlaying)
                  GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                // Full screen button
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () async {
                      if (widget.videoUrl != null && widget.postId != null) {
                        await context.pushNavigator(
                          VideoPlayerScreen(
                            videoUrl: widget.videoUrl!,
                            postId: widget.postId,
                          ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// class PostVideo1 extends StatefulWidget {
//   final PostCardHeader header;
//   final Widget footer;
//   final VoidCallback? view;
//   final PostData data;
//
//   const PostVideo1({
//     Key? key, required this.header, required this.footer,
//     this.view, required this.data
//   }) : super(key: key);
//
//   @override
//   _PostVideoState createState() => _PostVideoState();
// }
// class _PostVideoState extends State<PostVideo1> {
//
//
//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(10),
//       child: Card(
//         margin: 10.all,
//         color: Colors.white,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             widget.header,
//
//            10.height,
//             Padding(
//               padding: const EdgeInsets.only(left: 10, bottom: 8),
//               child: ReadMoreText(text: data.content ?? ''),
//             ),
//             10.height,
//             SizedBox(
//               width: double.maxFinite,
//               height:  MediaQuery.of(context).size.height * 0.6,
//               child: VideoCardPlayer(
//                 height: MediaQuery.of(context).size.height * 0.6,
//                 videoUrl: file?.file.fileUrl ?? '',
//                 thumbnail: file?.thumbnail.fileUrl,
//                 thumbnailHeight: file?.y,
//                 thumbnailWidth: file?.x,
//                 postId : widget.postId,viewVideo: () {
//                 widget.view?.call();
//               },
//
//               ),
//             ),
//
//
//             widget.footer,
//
//
//           ],
//         ),
//       ),
//     );
//   }
//
// }

class VideoCardPlayer extends StatefulWidget {
  final String videoUrl;
  final String? postId;
  final VoidCallback? viewVideo;
  final String? thumbnail;
  final double? thumbnailWidth;
  final double? thumbnailHeight;
  final double? height;

  const VideoCardPlayer({
    super.key,
    required this.videoUrl,
    this.postId,
    this.viewVideo,
    this.thumbnail,
    this.thumbnailWidth,
    this.thumbnailHeight,
    this.height,
  });

  @override
  State<VideoCardPlayer> createState() => _VideoCardPlayerState();
}

class _VideoCardPlayerState extends State<VideoCardPlayer> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isVideoReady = false;
  bool _isMuted = true;
  bool _isPlaying = false;
  String? _thumbnailPath;

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _videoController.setVolume(_isMuted ? 0 : 1);
    });
  }

  @override
  void initState() {
    super.initState();

    AppUtils.log('myvideoUrl ::: ${widget.videoUrl}');
    // _generateThumbnail(widget.videoUrl);
    _initializeVideo();
  }

  void _initializeVideo() {
    if (widget.videoUrl.isEmpty) {
      debugPrint("Video URL is empty!");
      return;
    }

    _videoController = VideoPlayerController.network(widget.videoUrl)
      ..initialize()
          .then((_) {
            if (!mounted) return;
            setState(() {
              _isVideoReady = true;
              _chewieController = ChewieController(
                videoPlayerController: _videoController,
                aspectRatio: _videoController.value.aspectRatio > 0
                    ? _videoController.value.aspectRatio
                    : 16 / 9,
                autoPlay: false,
                looping: true,
                allowFullScreen: true,
                showControls: false,
              );
            });
          })
          .catchError((error) {
            debugPrint("Video initialization failed: $error");
          });

    _videoController.addListener(() {
      if (mounted) {
        setState(() {
          _isPlaying = _videoController.value.isPlaying;
        });
      }
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
    //   widget.thumbnail.isNotNullEmpty ?
    // ImageView(url: widget.thumbnail ?? '',
    //   height: widget.thumbnailHeight,
    //   width: widget.thumbnailWidth,
    //   imageType: ImageType.network,
    // ):
    Stack(
      alignment: Alignment.center,
      children: widget.thumbnail.isNotNullEmpty
          ? <Widget>[
              SizedImage(
                url: widget.thumbnail.fileUrl ?? '',
                size: ui.Size(
                  widget.thumbnailWidth ?? context.getWidth,
                  widget.thumbnailWidth ??
                      widget.height ??
                      MediaQuery.of(context).size.height * 0.6,
                ),
                maxWidth: double.maxFinite,
                maxHeight:
                    widget.height ?? MediaQuery.of(context).size.height * 0.6,
              ),
              playButton(),
            ]
          :
            // widget.thumbnail.isNotNullEmpty ?
            <Widget>[
              if (!_isVideoReady)
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: double.infinity,
                    height: 250,
                    color: Colors.grey,
                  ),
                ),
              if (_thumbnailPath != null && !_isVideoReady)
                Image.file(
                  File(_thumbnailPath!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 250,
                ),
              if (_isVideoReady)
                GestureDetector(
                  onTap: () async {
                    widget.viewVideo?.call();

                    final result = await context.pushNavigator(
                      VideoPlayerScreen(
                        videoUrl: widget.videoUrl,
                        postId: widget.postId,
                      ),
                    );

                    if (result == true && widget.viewVideo != null) {
                      widget.viewVideo!();
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Chewie(controller: _chewieController!),
                      if (!_isPlaying)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              playButton(),
            ],
    );
  }

  Positioned playButton() {
    return Positioned(
      bottom: 20.sdp,
      right: 8.sdp,
      child: IconButton(
        icon: Icon(
          _isMuted ? Icons.volume_off : Icons.volume_up,
          color: Colors.white,
        ),
        onPressed: _toggleMute,
      ),
    );
  }
}
