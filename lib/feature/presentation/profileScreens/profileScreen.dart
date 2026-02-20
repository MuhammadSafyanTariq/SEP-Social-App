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
import 'package:sep/feature/presentation/chatScreens/ImagePreviewScreen.dart';

import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';

import '../../../services/storage/preferences.dart';
import '../../../utils/appUtils.dart';
import '../../data/models/dataModels/profile_data/profile_data_model.dart';
import '../../data/models/dataModels/getUserDetailModel.dart';
import '../Home/homeScreenComponents/pollCard.dart';
import '../Home/homeScreenComponents/celebrationCard.dart';
import '../Home/homeScreenComponents/post_components.dart';
import '../profileScreens/setting/fullScreenVideoPlayer.dart';
import '../Home/reels_video_screen.dart';
import '../controller/auth_Controller/profileCtrl.dart';
import '../controller/story/story_controller.dart';
import '../../data/models/dataModels/story_model.dart';
import '../Home/story/story_view_screen_new.dart';
import '../screens/post_browsing_listing.dart';
import 'followers.dart';
import 'pending_follow_requests_screen.dart';
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
  StoryController? storyController;
  late var profileimage = Preferences.profile;
  String? imageonly;
  String? name;
  String? namee;

  bool get hasStories {
    if (storyController == null) return false;
    // Use the reactive myStories list from the controller
    return storyController!.myStories.isNotEmpty;
  }

  // Cache for video thumbnails
  final Map<String, String?> _thumbnailCache = {};

  List<String> get tabsss => ["IMAGES", "VIDEOS", "POLLS", "CELEBRATIONS"];

  List<PostData> get list => tabIndex.value == 3
      ? profileCtrl.profileCelebrationPostList
      : tabIndex.value == 2
      ? profileCtrl.profilePollPostList
      : tabIndex.value == 1
      ? profileCtrl.profileVideoPostList
      : profileCtrl.profileImagePostList;

  PostFileType get postType => tabIndex.value == 3
      ? PostFileType.post
      : tabIndex.value == 2
      ? PostFileType.poll
      : tabIndex.value == 1
      ? PostFileType.video
      : PostFileType.image;

  ProfileDataModel get profileData => profileCtrl.profileData.value;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabsss.length, vsync: this);

    // Get story controller if available
    if (Get.isRegistered<StoryController>()) {
      storyController = Get.find<StoryController>();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
      _updateHeight();
    });
  }

  _initData() async {
    // Fetch profile details first
    await profileCtrl.getProfileDetails();

    // Fetch my stories if story controller is available
    if (storyController != null) {
      await storyController!.fetchMyStories();
    }

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

    // Fetch all post types at once to show accurate count immediately
    // Use applyLoader to show loading indicator while fetching
    await profileCtrl.fetchAllPostCounts(refresh: true).applyLoader;
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

  void _showProfileImageOptions() {
    final hasProfileImage =
        profileCtrl.profileImageData.network?.isNotEmpty == true;
    // Use the reactive myStories list from the controller
    final userStories = storyController?.myStories ?? <Story>[];
    final showStoryOption = userStories.isNotEmpty;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasProfileImage)
                ListTile(
                  leading: Icon(Icons.person, color: AppColors.primaryColor),
                  title: Text('View Profile Image'),
                  onTap: () {
                    Navigator.pop(context);
                    context.pushNavigator(
                      ImagePreviewScreen(
                        imageUrl: profileCtrl.profileImageData.network!,
                      ),
                    );
                  },
                ),
              if (showStoryOption)
                ListTile(
                  leading: Icon(Icons.auto_stories, color: Colors.purple),
                  title: Text('View Story'),
                  onTap: () {
                    Navigator.pop(context);
                    // Convert Story list to UserStoryGroup for StoryViewScreenNew
                    final profileData = profileCtrl.profileData.value;
                    final currentUser = UserData(
                      id: int.tryParse(profileData.id ?? '0'),
                      name: profileData.name ?? 'Unknown',
                      email: profileData.email ?? '',
                      phone: profileData.phone ?? '',
                      image: profileData.image ?? '',
                      createdAt: profileData.createdAt ?? '',
                      updatedAt: profileData.updatedAt ?? '',
                    );
                    final storyGroup = UserStoryGroup(
                      user: currentUser,
                      stories: userStories,
                    );
                    context.pushNavigator(
                      StoryViewScreenNew(
                        storyGroups: [storyGroup],
                        initialGroupIndex: 0,
                        canDeleteStories: true,
                      ),
                    );
                  },
                ),
              if (!hasProfileImage && !showStoryOption)
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No profile image or story available',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
            ],
          ),
        );
      },
    );
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
    AppUtils.log(
      "Building cover photo section - coverPhoto: ${profileData.coverPhoto}",
    );
    final coverPhotoUrl = profileData.coverPhoto?.isNotEmpty == true
        ? AppUtils.configImageUrl(profileData.coverPhoto!)
        : null;
    AppUtils.log("Cover photo URL after config: $coverPhotoUrl");

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
                    url: AppUtils.configImageUrl(profileData.coverPhoto!),
                    fit: BoxFit.cover,
                    imageType: ImageType.network,
                    height: 200,
                    width: double.infinity,
                  )
                : Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
          ),
          // Profile Picture (overlapping)
          Positioned(
            bottom: -50,
            left: MediaQuery.of(context).size.width / 2 - 60,
            child: GestureDetector(
              onTap: () {
                _showProfileImageOptions();
              },
              child: Obx(() {
                final showStoryRing = hasStories;
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: showStoryRing
                        ? LinearGradient(
                            colors: [
                              Colors.green.shade400,
                              Colors.green.shade600,
                              Colors.green.shade800,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    border: !showStoryRing
                        ? Border.all(color: Colors.white, width: 4)
                        : null,
                  ),
                  padding: showStoryRing ? EdgeInsets.all(3) : EdgeInsets.zero,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: showStoryRing
                          ? Border.all(color: Colors.white, width: 4)
                          : null,
                    ),
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: Colors.grey[300],
                      backgroundImage:
                          profileCtrl.profileImageData.network?.isNotEmpty ==
                              true
                          ? NetworkImage(profileCtrl.profileImageData.network!)
                          : AssetImage(AppImages.dummyProfile) as ImageProvider,
                    ),
                  ),
                );
              }),
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
    return Obx(
      () {
        final isPrivate = profileData.isPrivate == true;
        final statRow = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatItem(
              '${profileCtrl.adjustedPostCount}',
              'Posts',
              null,
            ),
            Container(
              height: 30,
              width: 1,
              color: Colors.grey[400],
              margin: EdgeInsets.symmetric(horizontal: 16),
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
              margin: EdgeInsets.symmetric(horizontal: 16),
            ),
            _buildStatItem(
              '${(profileData.following ?? []).length}',
              'Link Ups',
              () {
                context.pushNavigator(MyFollowingListScreen());
              },
            ),
            if (isPrivate) ...[
              Container(
                height: 30,
                width: 1,
                color: Colors.grey[400],
                margin: EdgeInsets.symmetric(horizontal: 16),
              ),
              _buildStatItem(
                '${(profileData.pendingFollowRequests ?? []).length}',
                'Requests',
                () {
                  context.pushNavigator(PendingFollowRequestsScreen());
                },
              ),
            ],
          ],
        );
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: isPrivate
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: statRow,
                  )
                : Center(child: statRow),
          ),
        );
      },
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
                textOverflow: TextOverflow.ellipsis,
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

                    print('Topic will be sent to backend: $topic');

                    print('Navigating to BroadCastVideo...');
                    context.pushNavigator(
                      BroadCastVideo(
                        clientRole: ClientRoleType.clientRoleBroadcaster,
                        title: topic, // Pass title to BroadCastVideo
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
        () => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
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
              _buildTab(
                icon: Icons.celebration_outlined,
                label: 'Celebrations',
                isSelected: tabIndex.value == 3,
                onTap: () {
                  tabIndex.value = 3;
                  _tabController.animateTo(3);
                  getPosts(onChangePage: true);
                },
              ),
            ],
          ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 85,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
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
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
        case 3:
          filteredPosts = profileCtrl.profileCelebrationPostList;
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
                  : tabIndex.value == 2
                  ? 'No polls yet'
                  : 'No celebrations yet',
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
            : tabIndex.value == 2
            ? _buildPollsList(filteredPosts)
            : _buildCelebrationsList(filteredPosts),
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

  void _showVideoDeleteOptions(PostData post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: Colors.red),
            title: Text(
              'Delete Video',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              _confirmDeleteVideo(post);
            },
          ),
        ),
      ),
    );
  }

  void _confirmDeleteVideo(PostData post) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Delete Video?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete this video? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await profileCtrl.removePost(post.id!).applyLoader;
                profileCtrl.profileVideoPostList.removeWhere(
                  (p) => p.id == post.id,
                );
                profileCtrl.profileVideoPostList.refresh();
              } catch (_) {
                AppUtils.log('Failed to delete video');
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoGridItem(PostData post, int index) {
    final firstFile = post.files.isNotEmpty ? post.files.first : null;
    final videoUrl = firstFile?.file?.isNotEmpty == true
        ? AppUtils.configImageUrl(firstFile!.file!)
        : null;

    return GestureDetector(
      onLongPress: () => _showVideoDeleteOptions(post),
      onTap: () {
        // Get all video posts (filter to only include posts with valid video files)
        final allVideoPosts = profileCtrl.profileVideoPostList
            .where(
              (p) =>
                  p.files.isNotEmpty &&
                  p.files.first.file?.isNotEmpty == true &&
                  p.files.first.type == 'video',
            )
            .toList();

        if (allVideoPosts.isNotEmpty) {
          // Find the index of the clicked video
          final clickedIndex = allVideoPosts.indexWhere((p) => p.id == post.id);
          final initialIndex = clickedIndex >= 0 ? clickedIndex : 0;

          context.pushNavigator(
            ReelsVideoScreen(
              initialPosts: allVideoPosts,
              initialIndex: initialIndex,
            ),
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

  Widget _buildCelebrationsList(List<PostData> posts) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: posts.length,
      separatorBuilder: (context, index) => SizedBox(height: 10),
      itemBuilder: (context, index) {
        final post = posts[index];

        return CelebrationCard(
          header: postCardHeader(
            post,
            onRemovePostAction: () {
              profileCtrl.profileCelebrationPostList.removeAt(index);
              profileCtrl.profileCelebrationPostList.refresh();
            },
          ),
          caption: post.content ?? '',
          footer: postFooter(
            context: context,
            item: post,
            postLiker: (value) async {
              await profileCtrl.likeposts(post.id ?? '');
              final data = profileCtrl.profileCelebrationPostList[index];
              final count = data.likeCount ?? 0;
              final status = data.isLikedByUser ?? false;
              profileCtrl.profileCelebrationPostList[index] = data.copyWith(
                isLikedByUser: !status,
                likeCount: status ? count - 1 : count + 1,
              );
              profileCtrl.profileCelebrationPostList.refresh();
            },
            updateCommentCount: (value) {},
            updatePostOnAction: (commentCount) {
              final postId = post.id!;
              profileCtrl.getSinglePostData(postId).then((value) {
                final idx = profileCtrl.profileCelebrationPostList.indexWhere(
                  (element) => element.id == postId,
                );
                if (idx > -1) {
                  profileCtrl.profileCelebrationPostList[idx] = value.copyWith(
                    user: profileCtrl.profileCelebrationPostList[idx].user,
                    commentCount: commentCount,
                  );
                  profileCtrl.profileCelebrationPostList.refresh();
                }
              });
            },
          ),
          data: post,
        );
      },
    );
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
