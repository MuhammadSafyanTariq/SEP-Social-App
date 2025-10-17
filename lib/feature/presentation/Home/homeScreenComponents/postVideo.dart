import 'dart:io';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
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
import 'package:flutter/src/widgets/media_query.dart' as mq;
import 'dart:ui' as ui;


class PostVideo extends StatelessWidget {
  final PostCardHeader header;
  final Widget footer;
  final VoidCallback? view;
  final PostData data;
  const PostVideo({super.key, required this.header, required this.footer, this.view, required this.data});

  FileElement? get file =>  data.files.first;
  String? get caption => data.content;
  String? get videoUrl =>data.files.first.file;
  String? get postId =>data.id;




  @override
  Widget build(BuildContext context) {
    AppUtils.log(file?.thumbnail.fileUrl ?? '');

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Card(
        margin: 10.all,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            10.height,
            Visibility(
              visible: data.content.isNotNullEmpty,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 8),
                child: ReadMoreText(text: data.content ?? ''),
              ),
            ),
            10.height,
            SizedBox(
              width: context.getWidth,
              child:  Stack(
                children: file?.thumbnail.isNotNullEmpty ?? false ?
                <Widget>[
                  Center(
                    child: SizedImage(
                        url: file?.thumbnail.fileUrl ?? '',
                        size: ui.Size(
                            file?.x ?? context.getWidth,
                            file?.y ??
                                 MediaQuery.of(context).size.height * 0.6
                        ),
                        maxWidth: context.getWidth,
                        maxHeight:
                        // file?.y ??
                        MediaQuery.of(context).size.height * 0.6
                    ),
                  ),
                  playButton(context)
                ] : <Widget>[
                   SizedBox(
                     height: file?.y ??
                         MediaQuery.of(context).size.height * 0.6,
                       child: _VideoFrame(data: file,
                       maxHeight:
                       file?.y ??MediaQuery.of(context).size.height * 0.6,
                       )),
                  playButton(context)
                ] ,
              ),
            ),
          footer,
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


  Positioned playButton(BuildContext context){
    return Positioned.fill(child: GestureDetector(
      onTap: () async{
        final result = await context.pushNavigator(
          VideoPlayerScreen(
              videoUrl: videoUrl!.fileUrl!,
              postId: postId
          ),
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
    ));
  }
}

class _VideoFrame extends StatefulWidget {
  final FileElement? data;
  final double? maxHeight;
  const _VideoFrame({super.key, this.data,  this.maxHeight});

  @override
  State<_VideoFrame> createState() => _VideoFrameState();
}

class _VideoFrameState extends State<_VideoFrame> {
  FileElement? get data => widget.data;
  String? get videoUrl =>data?.file.fileUrl ?? '';
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;

  Rx<VideoPlayerValue> playerState = Rx(VideoPlayerValue.uninitialized());

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _videoController.removeListener(listener);
    super.dispose();
  }

  void listener(){
    _videoController.addListener((){
      playerState.value = _videoController.value;
    });
  }




  void _initializeVideo() {
    if (!(data?.file.isNotNullEmpty ?? false)) {
      debugPrint("Video URL is empty!");
      return;
    }

    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl ?? ''));
    listener();
    _videoController.initialize().then((_) {
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
        );
      }).catchError((error) {
        debugPrint("Video initialization failed: $error");
      });
  }

  Widget playerView(){
    return Chewie(controller: _chewieController!);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(()=>!playerState.value.isInitialized ?
        Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: widget.maxHeight ?? 250,
        color: Colors.grey,
      ),
    ) : playerView()
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

  const VideoCardPlayer({super.key, required this.videoUrl,this.postId,this.viewVideo, this.thumbnail, this.thumbnailWidth, this.thumbnailHeight,  this.height});

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

  void _togglePlayPause() {
    setState(() {
      if (_videoController.value.isPlaying) {
        _videoController.pause();
      } else {
        _videoController.play();
      }
    });
  }

  void _initializeVideo() {
    if (widget.videoUrl.isEmpty) {
      debugPrint("Video URL is empty!");
      return;
    }

    _videoController = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
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
      }).catchError((error) {
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
      children: widget.thumbnail.isNotNullEmpty ? <Widget>[
      SizedImage(
          url: widget.thumbnail.fileUrl ?? '',
          size: ui.Size(
            widget.thumbnailWidth ?? context.getWidth,
              widget.thumbnailWidth ??
              widget.height ?? MediaQuery.of(context).size.height * 0.6),
          maxWidth: double.maxFinite,
          maxHeight: widget.height ?? MediaQuery.of(context).size.height * 0.6
      ),
        playButton()
      ] :

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
          Image.file(File(_thumbnailPath!), fit: BoxFit.cover, width: double.infinity, height: 250),
        if (_isVideoReady)
          GestureDetector(
            onTap: () async {
              widget.viewVideo?.call();

              final result = await context.pushNavigator(
                VideoPlayerScreen(
                    videoUrl: widget.videoUrl,
                    postId: widget.postId
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
                      child: Icon(Icons.play_arrow, color: Colors.white, size: 50),
                    ),
                  ),
              ],
            ),
          ),
        playButton()
        ,
      ],
    );
  }


  Positioned playButton(){
    return Positioned(
      bottom: 20.sdp,
      right: 8.sdp,
      child: IconButton(
        icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white),
        onPressed: _toggleMute,
      ),
    );
  }
}




