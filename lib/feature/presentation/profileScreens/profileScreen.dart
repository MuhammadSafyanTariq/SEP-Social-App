import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:video_player/video_player.dart';

import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/feature/data/models/dataModels/post_data.dart';
import 'package:sep/feature/presentation/liveStreaming_screen/broad_cast_video.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';

import '../../../services/storage/preferences.dart';
import '../../../utils/appUtils.dart';
import '../../data/models/dataModels/profile_data/profile_data_model.dart';
import '../controller/auth_Controller/profileCtrl.dart';
import '../Home/homeScreenComponents/pollCard.dart';
import '../Home/homeScreenComponents/post_components.dart';
import '../postDetail/post_detail_screen.dart';
import 'followers.dart';
import 'setting/following.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

enum PostFileType { image, video, poll, post }

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey _dynamicContentKey = GlobalKey();
  RxInt tabIndex = RxInt(0);
  RxDouble collapseHeight = RxDouble(120);
  final ProfileCtrl profileCtrl = ProfileCtrl.find;
  late var profileimage = Preferences.profile;
  String? imageonly;
  String? name;
  String? namee;

  List<String> get tabsss => ["IMAGES", "VIDEOS", "POLLS"];

  List<PostData> get list => tabIndex.value == 2
      ? profileCtrl.profilePollPostList
      : tabIndex.value == 1
      ? profileCtrl.profileVideoPostList
      : profileCtrl.profileImagePostList;

  PostFileType get postType => tabIndex.value == 2
      ? PostFileType.poll
      : tabIndex.value == 1
      ? PostFileType.video
      : PostFileType.image;

  ProfileDataModel get profileData => profileCtrl.profileData.value;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabsss.length, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
      _updateHeight();
    });
  }

  _initData() async {
    profileCtrl.getProfileDetails().then((value) {});
    String? imageonly = profileimage?.image;

    if (imageonly != null && !imageonly.startsWith("http")) {
      imageonly = "$imageonly";
    }

    profileCtrl.profileImagePageNo = 1;
    profileCtrl.profileVideoPageNo = 1;
    profileCtrl.profilePollPageNo = 1;

    _tabController.addListener(() {
      tabIndex.value = _tabController.index;
      getPosts(onChangePage: true);
    });

    getPosts(refresh: true);
  }

  Future getPosts({
    bool refresh = false,
    bool loadMore = false,
    bool onChangePage = false,
  }) async {
    bool loadData = onChangePage ? list.isEmpty : true;
    if (loadData) {
      return await profileCtrl
          .getMyProfilePosts(
            type: postType,
            refresh: refresh,
            loadMore: loadMore,
          )
          .applyLoaderWithOption(!refresh && !loadMore);
    }
  }

  void _updateHeight() {
    final renderBox =
        _dynamicContentKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      AppUtils.log(collapseHeight.value);
      collapseHeight.value = renderBox.size.height + 50;
      // AppUtils.log(collapseHeight.value);
    }

    // setState(() {
    //   _expandedHeight = renderBox.size.height;
    // });
  }

  String _getJoinedText() {
    if (profileData.createdAt == null) return 'Recently joined';

    try {
      final joinDate = DateTime.parse(profileData.createdAt!);
      final now = DateTime.now();
      final difference = now.difference(joinDate);

      if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        if (weeks == 0) {
          return difference.inDays == 0
              ? 'Joined today'
              : 'Joined ${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
        }
        return 'Joined ${weeks} week${weeks == 1 ? '' : 's'} ago';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return 'Joined ${months} month${months == 1 ? '' : 's'} ago';
      } else {
        final years = (difference.inDays / 365).floor();
        return 'Joined ${years} year${years == 1 ? '' : 's'} ago';
      }
    } catch (e) {
      return 'Recently joined';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Obx(
          () => CustomScrollView(
            slivers: [
              // Cover Photo Section
              SliverToBoxAdapter(child: _buildCoverPhotoSection()),
              // Profile Info Section
              SliverToBoxAdapter(child: _buildProfileInfoSection()),
              // Stats Section
              SliverToBoxAdapter(child: _buildStatsSection()),
              // Edit Profile Button
              SliverToBoxAdapter(child: _buildEditProfileButton()),
              // Tabs Section
              SliverToBoxAdapter(child: _buildTabsSection()),
              // Posts Grid Section
              SliverToBoxAdapter(child: _buildPostsGridSection()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverPhotoSection() {
    return Container(
      height: 200,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Cover Photo or Default Background
          Container(
            height: 200,
            width: double.infinity,
            child: profileData.coverPhoto?.isNotEmpty == true
                ? ImageView(
                    url: profileData.coverPhoto!,
                    fit: BoxFit.cover,
                    imageType: ImageType.network,
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black,
                          AppColors.greenSplash,
                          Colors.black,
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageView(
                            url: AppImages.splashLogo,
                            height: 70,
                            width: 70,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          // Profile Picture (overlapping)
          Positioned(
            bottom: -50,
            left: MediaQuery.of(context).size.width / 2 - 60,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: CircleAvatar(
                radius: 56,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    profileCtrl.profileImageData.network?.isNotEmpty == true
                    ? NetworkImage(profileCtrl.profileImageData.network!)
                    : AssetImage(AppImages.dummyProfile) as ImageProvider,
                child: profileCtrl.profileImageData.network?.isEmpty ?? true
                    ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoSection() {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 60, bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Name
          TextView(
            text: profileData.name ?? 'User Name',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4),
          // Join Date
          TextView(
            text: _getJoinedText(),
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
          SizedBox(height: 8),
          // Bio
          if (profileData.bio?.isNotEmpty == true)
            TextView(
              text: profileData.bio!,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatItem('${profileData.postCount ?? 0}', 'Posts'),
              Container(
                height: 30,
                width: 1,
                color: Colors.grey[400],
                margin: EdgeInsets.symmetric(horizontal: 20),
              ),
              _buildStatItem(
                '${(profileData.followers ?? []).length}',
                'Linked Me',
                onTap: () {
                  profileCtrl.getMyFollowers().then((value) {
                    context.pushNavigator(const MyFollowersListScreen());
                  });
                },
              ),
              Container(
                height: 30,
                width: 1,
                color: Colors.grey[400],
                margin: EdgeInsets.symmetric(horizontal: 20),
              ),
              _buildStatItem(
                '${(profileData.following ?? []).length}',
                'Link Ups',
                onTap: () {
                  profileCtrl.getMyFollowings().then((value) {
                    context.pushNavigator(const MyFollowingListScreen());
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          TextView(
            text: count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 2),
          TextView(
            text: label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileButton() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              height: 45,
              child: AppButton(
                label: 'Edit Profile',
                buttonColor: AppColors.btnColor,
                onTap: () {
                  // Navigate to edit profile
                },
              ),
            ),
          ),
          SizedBox(width: 12),
          Container(
            width: 70,
            height: 45,
            child: Material(
              color: AppColors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  if (Platform.isIOS && kDebugMode) {
                    context.pushNavigator(
                      BroadCastVideo(
                        clientRole: ClientRoleType.clientRoleBroadcaster,
                        isHost: true,
                      ),
                    );
                  } else {
                    // StreamUtils.checkPermission().then((value) {
                    //   if (value) {
                    context.pushNavigator(
                      BroadCastVideo(
                        clientRole: ClientRoleType.clientRoleBroadcaster,
                        isHost: true,
                      ),
                    );
                    //   }
                    // });
                  }
                },
                child: Icon(
                  Icons.videocam,
                  color: AppColors.greenlight,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Obx(
        () => Row(
          children: [
            _buildTab(
              icon: Icons.image_outlined,
              label: 'Images',
              isSelected: tabIndex.value == 0,
              onTap: () {
                tabIndex.value = 0;
                _tabController.animateTo(0);
                getPosts(onChangePage: true);
              },
            ),
            _buildTab(
              icon: Icons.videocam_outlined,
              label: 'Videos',
              isSelected: tabIndex.value == 1,
              onTap: () {
                tabIndex.value = 1;
                _tabController.animateTo(1);
                getPosts(onChangePage: true);
              },
            ),
            _buildTab(
              icon: Icons.poll_outlined,
              label: 'Polls',
              isSelected: tabIndex.value == 2,
              onTap: () {
                tabIndex.value = 2;
                _tabController.animateTo(2);
                getPosts(onChangePage: true);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: isSelected
                ? Border(
                    bottom: BorderSide(color: AppColors.primaryColor, width: 2),
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primaryColor : Colors.grey[600],
                size: 24,
              ),
              SizedBox(height: 4),
              TextView(
                text: label,
                style: TextStyle(
                  color: isSelected ? AppColors.primaryColor : Colors.grey[600],
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostsGridSection() {
    return Obx(() {
      // Get posts based on selected tab
      List<PostData> filteredPosts;
      switch (tabIndex.value) {
        case 0:
          filteredPosts = profileCtrl.profileImagePostList;
          break;
        case 1:
          filteredPosts = profileCtrl.profileVideoPostList;
          break;
        case 2:
          filteredPosts = profileCtrl.profilePollPostList;
          break;
        default:
          filteredPosts = profileCtrl.profileImagePostList;
      }

      AppUtils.log(
        "Filtered posts (tab ${tabIndex.value}): ${filteredPosts.length}",
      );

      if (filteredPosts.isEmpty) {
        return Container(
          height: 200,
          child: Center(
            child: TextView(
              text: tabIndex.value == 0
                  ? 'No images yet'
                  : tabIndex.value == 1
                  ? 'No videos yet'
                  : 'No polls yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: tabIndex.value == 0
            ? _buildStaggeredImagesGrid(filteredPosts)
            : tabIndex.value == 2
            ? _buildPollsList(filteredPosts)
            : _buildVideosList(filteredPosts),
      );
    });
  }

  Widget _buildStaggeredImagesGrid(List<PostData> posts) {
    if (posts.isEmpty) {
      return Center(
        child: TextView(
          text: "No post available",
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return _buildGridItem(post, 1.0);
      },
    );
  }

  Widget _buildVideosList(List<PostData> posts) {
    if (posts.isEmpty) {
      return Center(
        child: TextView(
          text: "No videos available",
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        final firstFile = post.files.isNotEmpty ? post.files.first : null;
        final videoUrl = firstFile?.file?.isNotEmpty == true
            ? AppUtils.configImageUrl(firstFile!.file!)
            : null;

        return GestureDetector(
          onTap: () => _handleVideoTap(post),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: videoUrl?.isNotEmpty == true
                  ? VideoThumbnailWidget(videoUrl: videoUrl!)
                  : Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(
                          Icons.videocam,
                          color: Colors.grey[500],
                          size: 60,
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPollsList(List<PostData> posts) {
    if (posts.isEmpty) {
      return Center(
        child: TextView(
          text: "No polls available",
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return PollCard(
          question: post.content ?? '',
          options: post.options,
          header: postCardHeader(post),
          data: post,
          onPollAction: (optionId) {
            // Handle poll vote action - you'll need to implement this in your controller
            AppUtils.log("Vote on poll: ${post.id}, option: $optionId");
          },
          footer: postFooter(
            item: post,
            context: context,
            postLiker: (postId) {
              // Handle like action
              AppUtils.log("Like post: $postId");
            },
            updateCommentCount: (count) {
              // Handle comment count update
            },
            updatePostOnAction: (index) {
              // Handle post action update
            },
          ),
          showPollButton: false,
        );
      },
    );
  }

  // Simple and direct profile post card
  Widget _buildGridItem(PostData post, double aspectRatio) {
    final firstFile = post.files.isNotEmpty ? post.files.first : null;
    String? imageUrl;

    // For videos, use thumbnail; for images, use the file itself
    if (post.fileType == 'video') {
      if (firstFile?.thumbnail?.isNotEmpty == true) {
        imageUrl = AppUtils.configImageUrl(firstFile!.thumbnail!);
      }
    } else if (firstFile?.file?.isNotEmpty == true) {
      imageUrl = AppUtils.configImageUrl(firstFile!.file!);
    }

    return GestureDetector(
      onTap: () => _handlePostTap(post, firstFile, 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[200],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _buildPostCardContent(imageUrl, post),
        ),
      ),
    );
  }

  Widget _buildPostCardContent(String? imageUrl, PostData post) {
    // For videos, use video player to get first frame
    if (post.fileType == 'video') {
      final firstFile = post.files.isNotEmpty ? post.files.first : null;
      final videoUrl = firstFile?.file?.isNotEmpty == true
          ? AppUtils.configImageUrl(firstFile!.file!)
          : null;

      if (videoUrl?.isNotEmpty == true) {
        return VideoThumbnailWidget(videoUrl: videoUrl!);
      } else {
        return Container(
          color: Colors.grey[300],
          child: Center(
            child: Icon(Icons.videocam, color: Colors.grey[500], size: 40),
          ),
        );
      }
    }

    // For images
    if (imageUrl?.isNotEmpty == true) {
      return Stack(
        fit: StackFit.expand,
        children: [
          // Image that fills the container
          Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.grey[500],
                    size: 40,
                  ),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
          ),
        ],
      );
    } else if (post.fileType == 'poll') {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryColor.withOpacity(0.1),
              AppColors.primaryColor.withOpacity(0.2),
            ],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.poll_outlined,
                    color: AppColors.primaryColor,
                    size: 40,
                  ),
                  SizedBox(height: 8),
                  TextView(
                    text: 'Poll',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[300],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_outlined, color: Colors.grey[500], size: 40),
              SizedBox(height: 8),
              TextView(
                text: 'No Image',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }
  }

  // Enhanced overlay with better visual effects

  void _handlePostTap(PostData post, FileElement? firstFile, int index) {
    context.pushNavigator(
      PostDetailScreen(postData: post, openComments: false),
    );
  }

  void _handleVideoTap(PostData post) {
    context.pushNavigator(
      PostDetailScreen(postData: post, openComments: false),
    );
  }
}

// Video thumbnail widget with proper video player
class VideoThumbnailWidget extends StatefulWidget {
  final String videoUrl;

  const VideoThumbnailWidget({Key? key, required this.videoUrl})
    : super(key: key);

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.network(widget.videoUrl);
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      AppUtils.log("Video thumbnail error: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.grey[300],
        child: Center(
          child: Icon(Icons.videocam, color: Colors.grey[500], size: 40),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.size.width,
            height: _controller!.value.size.height,
            child: VideoPlayer(_controller!),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
            ),
          ),
          child: Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.play_arrow,
                color: AppColors.primaryColor,
                size: 40,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
