import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/feature/data/models/dataModels/post_data.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/utils/appUtils.dart';
import 'reels_video_screen.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({Key? key}) : super(key: key);

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final ProfileCtrl profileCtrl = Get.find<ProfileCtrl>();
  bool _isLoading = true;
  List<PostData> _videoPosts = [];

  @override
  void initState() {
    super.initState();
    _loadVideoPosts();
  }

  Future<void> _loadVideoPosts() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Load global posts if not already loaded
      if (profileCtrl.globalPostList.isEmpty) {
        await profileCtrl.globalList();
      }

      // Filter only video posts
      final videoPosts = profileCtrl.globalPostList
          .where(
            (post) =>
                post.files.isNotEmpty &&
                post.files.first.type == 'video' &&
                post.files.first.file?.isNotEmpty == true,
          )
          .toList();

      // Shuffle the list to show random videos
      videoPosts.shuffle();

      setState(() {
        _videoPosts = videoPosts;
        _isLoading = false;
      });

      // Navigate to reels video screen if we have videos
      if (_videoPosts.isNotEmpty && mounted) {
        // Use WidgetsBinding to ensure navigation happens after current frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ReelsVideoScreen(
                  initialPosts: _videoPosts,
                  initialIndex: 0,
                ),
              ),
            );
          }
        });
      }
    } catch (e) {
      AppUtils.log('Error loading video posts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Reels',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryColor),
                  SizedBox(height: 16),
                  Text(
                    'Loading reels...',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              )
            : _videoPosts.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_library_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No video posts available',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Go Back',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              )
            : SizedBox(),
      ),
    );
  }
}
