import 'package:flutter/material.dart';
import 'package:sep/components/appLoader.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/presentation/Home/homeScreen.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/widget.dart';
import 'package:video_player/video_player.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import '../../../components/coreComponents/TextView.dart';
import '../../../utils/appUtils.dart';
import '../../data/repository/iTempRepository.dart';
import '../controller/auth_Controller/profileCtrl.dart';

class VideoScreen extends StatefulWidget {
  final List<String> videoUrls;
  final int initialIndex;

  const VideoScreen({Key? key, required this.videoUrls, this.initialIndex = 0}) : super(key: key);

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late PageController _pageController;
  VideoPlayerController? _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
    _initializeAndPlay(_currentIndex);
  }

  Future<void> _initializeAndPlay(int index) async {
    if (_controller != null) {
      await _controller!.pause();
      await _controller!.dispose();
    }

    _controller = VideoPlayerController.network(widget.videoUrls[index])
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller!.play();
        }
      }).catchError((error) {
        debugPrint("Video Initialization Error: $error");
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    _initializeAndPlay(index);
    setState(() {
      _currentIndex = index;
    });
  }

  void _showDeleteOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10.sdp)),
      ),
      builder: (context) {
        return Padding(
          padding: 20.horizontal + 16.vertical,
          child: Wrap(
            children: [
              ListTile(
                contentPadding: 12.vertical,
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context);
                },
                leading: Icon(Icons.delete, color: Colors.redAccent),
                title: TextView(
                  text: "Delete Post",
                  style: 16.txtRegularWhite,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.sdp)),
        title: Center(child: TextView(text: "Delete Post", style: 20.txtMediumWhite)),
        content: TextView(
          text: "Are you sure you want to delete this post?",
          style: 16.txtRegularWhite,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextView(text: "Cancel", style: 14.txtRegularWhite),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePost(context).applyLoader;
              context.pushAndClearNavigator(HomeScreen());
            },
            child: TextView(text: "Delete", style: 14.txtRegularError),
          ),
        ],
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sdp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.videoUrls.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          return Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Center(
                child: _controller != null && _controller!.value.isInitialized
                    ? AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                )
                    : AppLoader.loaderWidget(),
              ),
              // Positioned(
              //   right: 10.sdp,
              //   bottom: 50.sdp,
              //   child: Column(
              //     children: [
              //       ImageView(url: "assets/images/11.png"),
              //       20.height,
              //       ImageView(url: "assets/images/33.png"),
              //       20.height,
              //       ImageView(url: "assets/images/44.png"),
              //       20.height,
              //       ImageView(
              //         url: "assets/images/22.png",
              //         onTap: () => _showDeleteOptionsBottomSheet(context),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          );
        },
      ),
    );
  }


  Future<void> _deletePost(BuildContext context) async {
    final postId = ProfileCtrl.find.postList.first.id;

    final response = await ITempRepository().deletePost(postId ?? '').applyLoader;
    if (response.isSuccess) {
      AppUtils.log("Post deleted successfully");
      ProfileCtrl().postList.removeWhere((p) => p.id == postId);
      Navigator.pop(context);
    } else {
      AppUtils.log("Failed to delete post: \${response.exception ?? response.error}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete post")),
      );
    }
  }
}
