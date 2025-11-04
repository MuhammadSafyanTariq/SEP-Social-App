import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/feature/data/models/dataModels/post_data.dart';
import 'package:sep/feature/presentation/liveStreaming_screen/broad_cast_video.dart';
import 'package:sep/feature/presentation/liveStreaming_screen/live_stream_ctrl.dart';
import 'package:sep/feature/presentation/liveStreaming_screen/helper/topic_dialog.dart';
import 'package:sep/feature/presentation/controller/agora_chat_ctrl.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';

import '../../../services/storage/preferences.dart';
import '../../../utils/appUtils.dart';
import '../../data/models/dataModels/profile_data/profile_data_model.dart';
import '../Home/homeScreenComponents/pollCard.dart';
import '../Home/homeScreenComponents/post_components.dart';
import '../Home/video.dart';
import '../controller/auth_Controller/profileCtrl.dart';
import '../screens/post_browsing_listing.dart';
import 'followers.dart';
import 'setting/following.dart';
import 'setting/editProfile.dart';

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

  // Cache for video thumbnails
  final Map<String, String?> _thumbnailCache = {};

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
              _buildStatItem('${profileData.postCount ?? 0}', 'Posts', null),
              Container(
                height: 30,
                width: 1,
                color: Colors.grey[400],
                margin: EdgeInsets.symmetric(horizontal: 20),
              ),
              _buildStatItem(
                '${(profileData.followers ?? []).length}',
                'Linked Me',
                () {
                  context.pushNavigator(MyFollowersListScreen());
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
                () {
                  context.pushNavigator(MyFollowingListScreen());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label, [VoidCallback? onTap]) {
    Widget statContent = Column(
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
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: statContent);
    }

    return statContent;
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
                  context.pushNavigator(EditProfile());
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
                onTap: () async {
                  print('Live button clicked - starting flow...');

                  // Check permissions before starting live stream
                  final hasPermissions = await StreamUtils.checkPermission();
                  print('Permissions check result: $hasPermissions');

                  if (!hasPermissions) {
                    // Show error message if permissions not granted
                    AppUtils.toastError(
                      'Camera and Microphone permissions are required to go live',
                    );
                    return;
                  }

                  try {
                    print('Showing topic dialog...');
                    final topic = await LiveStreamTopicDialog.show(context);
                    print('Topic dialog result: $topic');

                    // If user cancels (topic is null), don't proceed
                    if (topic == null) {
                      print('User cancelled topic dialog');
                      return;
                    }

                    // Store the topic in controller
                    AgoraChatCtrl.find.liveStreamTopic.value = topic;
                    print('Topic stored: $topic');

                    print('Navigating to BroadCastVideo...');
                    context.pushNavigator(
                      BroadCastVideo(
                        clientRole: ClientRoleType.clientRoleBroadcaster,
                        isHost: true,
                      ),
                    );
                    print('Navigation completed');
                  } catch (e) {
                    print('Error in live stream flow: $e');
                    AppUtils.toastError('Failed to start live stream: $e');
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
            : tabIndex.value == 1
            ? _buildVideosGrid(filteredPosts)
            : _buildPollsList(filteredPosts),
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
        return _buildImageGridItem(post, index);
      },
    );
  }

  Widget _buildVideosGrid(List<PostData> posts) {
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
        childAspectRatio: 1.0,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return _buildVideoGridItem(post, index);
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

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: posts.length,
      separatorBuilder: (context, index) => SizedBox(height: 10),
      itemBuilder: (context, index) {
        final post = posts[index];
        return PollCard(
          data: post,
          header: postCardHeader(
            post,
            onRemovePostAction: () {
              profileCtrl.profilePollPostList.removeAt(index);
              profileCtrl.profilePollPostList.refresh();
            },
          ),
          question: post.content ?? '',
          options: post.options,
          onPollAction: (String optionId) {
            profileCtrl.givePollToHomePost(post, optionId).applyLoader;
          },
          footer: postFooter(
            context: context,
            item: post,
            postLiker: (value) async {
              await profileCtrl.likeposts(post.id ?? '');
              final data = profileCtrl.profilePollPostList[index];
              final count = data.likeCount ?? 0;
              final status = data.isLikedByUser ?? false;
              profileCtrl.profilePollPostList[index] = data.copyWith(
                isLikedByUser: !status,
                likeCount: status ? count - 1 : count + 1,
              );
              profileCtrl.profilePollPostList.refresh();
            },
            updateCommentCount: (value) {},
            updatePostOnAction: (commentCount) {
              final postId = post.id!;
              profileCtrl.getSinglePostData(postId).then((value) {
                final idx = profileCtrl.profilePollPostList.indexWhere(
                  (element) => element.id == postId,
                );
                if (idx > -1) {
                  profileCtrl.profilePollPostList[idx] = value.copyWith(
                    user: profileCtrl.profilePollPostList[idx].user,
                    commentCount: commentCount,
                  );
                  profileCtrl.profilePollPostList.refresh();
                }
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildImageGridItem(PostData post, int index) {
    final firstFile = post.files.isNotEmpty ? post.files.first : null;
    String? imageUrl;

    if (firstFile?.file?.isNotEmpty == true) {
      imageUrl = AppUtils.configImageUrl(firstFile!.file!);
    }

    return GestureDetector(
      onTap: () {
        context.pushNavigator(
          PostImageBrowsingListing(
            initialIndex: profileCtrl.profileImagePostList.indexWhere(
              (p) => p.id == post.id,
            ),
            onRemovePost: (index) {},
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[200],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: imageUrl?.isNotEmpty == true
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
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
                )
              : Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.grey[500],
                      size: 40,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildVideoGridItem(PostData post, int index) {
    final firstFile = post.files.isNotEmpty ? post.files.first : null;
    final videoUrl = firstFile?.file?.isNotEmpty == true
        ? AppUtils.configImageUrl(firstFile!.file!)
        : null;

    return GestureDetector(
      onTap: () {
        if (videoUrl != null) {
          context.pushNavigator(
            VideoScreen(videoUrls: [videoUrl], initialIndex: 0),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[200],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (videoUrl != null)
                FutureBuilder<String?>(
                  key: ValueKey('video_thumb_$videoUrl'),
                  future: _getCachedThumbnail(videoUrl),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasData && snapshot.data != null) {
                      final file = File(snapshot.data!);
                      if (file.existsSync()) {
                        return Image.file(
                          file,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            AppUtils.log('Image.file error: $error');
                            return _buildVideoPlaceholder();
                          },
                        );
                      }
                    }

                    return _buildVideoPlaceholder();
                  },
                )
              else
                _buildVideoPlaceholder(),
              // Video play overlay
              Center(
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.play_arrow, color: Colors.white, size: 32),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          Icons.video_library_outlined,
          color: Colors.grey[500],
          size: 40,
        ),
      ),
    );
  }

  Future<String?> _getCachedThumbnail(String videoUrl) async {
    // Check cache first
    if (_thumbnailCache.containsKey(videoUrl)) {
      final cachedPath = _thumbnailCache[videoUrl];
      if (cachedPath != null && File(cachedPath).existsSync()) {
        AppUtils.log('Using cached thumbnail for: $videoUrl');
        return cachedPath;
      }
    }

    // Generate new thumbnail
    final thumbnailPath = await _generateVideoThumbnail(videoUrl);
    if (thumbnailPath != null) {
      _thumbnailCache[videoUrl] = thumbnailPath;
    }
    return thumbnailPath;
  }

  Future<String?> _generateVideoThumbnail(String videoUrl) async {
    try {
      AppUtils.log('Generating thumbnail for: $videoUrl');

      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoUrl,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 400,
        quality: 75,
      );

      if (thumbnailPath != null) {
        AppUtils.log('Thumbnail generated successfully: $thumbnailPath');
      } else {
        AppUtils.log('Thumbnail generation returned null');
      }

      return thumbnailPath;
    } catch (e, stackTrace) {
      AppUtils.log('Error generating thumbnail: $e');
      AppUtils.log('Stack trace: $stackTrace');
      return null;
    }
  }
}
