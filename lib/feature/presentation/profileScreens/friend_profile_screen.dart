import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/instance_manager.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/coreComponents/editProfileImage.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/core/core/model/imageDataModel.dart';
import 'package:sep/feature/data/models/dataModels/post_data.dart';
import 'package:sep/feature/data/models/dataModels/profile_data/profile_data_model.dart';
import 'package:sep/feature/presentation/profileScreens/followers.dart';
import 'package:sep/feature/presentation/profileScreens/profileScreen.dart';
import 'package:sep/feature/presentation/profileScreens/setting/following.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/loaderUtils.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/widget.dart';
import '../../../utils/appUtils.dart';
import '../Home/homeScreenComponents/pollCard.dart';
import '../Home/homeScreenComponents/post_components.dart';
import '../Home/video.dart';
import '../chatScreens/Messages_Screen.dart';
import '../controller/auth_Controller/profileCtrl.dart';
import '../screens/post_browsing_listing.dart';

class FriendProfileScreen extends StatefulWidget {
  final ProfileDataModel data;

  const FriendProfileScreen({super.key, required this.data});

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen>
    with SingleTickerProviderStateMixin {
  final ProfileCtrl profileCtrl = ProfileCtrl.find;
  Rx<ProfileDataModel> profileData = Rx(ProfileDataModel());
  late TabController _tabController;
  final GlobalKey _dynamicContentKey = GlobalKey();
  RxInt tabIndex = RxInt(0);
  RxDouble collapseHeight = RxDouble(120);
  String? name;
  String? namee;

  List<String> get tabsss => ["IMAGES", "VIDEOS", "POLLS"];

  RxList<PostData> profileImagePostListFriend = RxList();
  RxList<PostData> profileVideoPostListFriend = RxList();
  RxList<PostData> profilePollPostListFriend = RxList();

  int profileImagePageNoFriend = 1;
  int profileVideoPageNoFriend = 1;
  int profilePollPageNoFriend = 1;

  // List<PostData> get list =>
  //     tabIndex.value == 2 ? profileCtrl.profilePollPostListFriend :
  //     tabIndex.value == 1 ?profileCtrl.profileVideoPostListFriend :
  //     profileCtrl.profileImagePostListFriend;

  List<PostData> get list => tabIndex.value == 2
      ? profilePollPostListFriend
      : tabIndex.value == 1
      ? profileVideoPostListFriend
      : profileImagePostListFriend;

  PostFileType get postType => tabIndex.value == 2
      ? PostFileType.poll
      : tabIndex.value == 1
      ? PostFileType.video
      : PostFileType.image;

  bool get isFriend =>
      (profileData.value.followers ?? []).contains(Preferences.uid);

  // ProfileDataModel get profileDataValue => profileCtrl.

  @override
  void initState() {
    super.initState();
    profileData.value = widget.data;

    AppUtils.log(profileData.value.toJson());
    _tabController = TabController(length: tabsss.length, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  _initData() async {
    profileData.value = await profileCtrl
        .getFriendProfileDetails(profileData.value.id!)
        .applyLoader;
    profileData.refresh();
    _updateHeight();
    profileImagePageNoFriend = 1;
    profileVideoPageNoFriend = 1;
    profilePollPageNoFriend = 1;

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
      int pageNo = postType == PostFileType.poll
          ? profilePollPageNoFriend
          : postType == PostFileType.video
          ? profileVideoPageNoFriend
          : profileImagePageNoFriend;
      return await profileCtrl
          .getMyProfilePostsFriend(
            userId: profileData.value.id!,
            type: postType,
            refresh: refresh,
            loadMore: loadMore,
            pageCount: pageNo,
          )
          .applyLoaderWithOption(!refresh && !loadMore)
          .then((list) {
            if (list.isNotEmpty) {
              if (postType == PostFileType.poll) {
                profilePollPageNoFriend = pageNo;
              } else if (postType == PostFileType.video) {
                profileVideoPageNoFriend = pageNo;
              } else {
                profileImagePageNoFriend = pageNo;
              }

              if (pageNo == 1) {
                if (postType == PostFileType.poll) {
                  profilePollPostListFriend.assignAll(list);
                  profilePollPostListFriend.refresh();
                } else if (postType == PostFileType.video) {
                  profileVideoPostListFriend.assignAll(list);
                  profileVideoPostListFriend.refresh();
                } else {
                  profileImagePostListFriend.assignAll(list);
                  profileImagePostListFriend.refresh();
                }
              } else {
                if (postType == PostFileType.poll) {
                  profilePollPostListFriend.addAll(list);
                  profilePollPostListFriend.refresh();
                } else if (postType == PostFileType.video) {
                  profileVideoPostListFriend.addAll(list);
                  profileVideoPostListFriend.refresh();
                } else {
                  profileImagePostListFriend.addAll(list);
                  profileImagePostListFriend.refresh();
                }
              }
            } else {}
          });
    }
  }

  Future followAction() async {
    LoaderUtils.show();
    await ProfileCtrl.find.followRequest(profileData.value.id!);
    profileData.value = await profileCtrl.getFriendProfileDetails(
      profileData.value.id!,
    );
    profileData.refresh();
    LoaderUtils.dismiss();
  }

  Widget profileInfo() {
    return Container(
      key: _dynamicContentKey,
      child: Padding(
        padding: const EdgeInsets.only(right: 15.0, left: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Obx(() {
                        return EditProfileImage(
                          size: 60,
                          imageData: ImageDataModel(
                            network: baseUrl + (profileData.value.image ?? ''),
                            type: ImageType.network,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                Obx(
                  () => TextView(
                    margin: 20.top + 10.bottom + 20.left,
                    text: profileData.value.name ?? "",
                    style: 20.txtBoldWhite,
                  ),
                ),
                // Obx(() => TextView(
                //   margin: 20.top + 10.bottom + 20.left,
                //   text: profileData.value.createdAt ?? "",
                //   style: 20.txtBoldWhite,
                // )),
              ],
            ),
            10.height,
            Column(
              children: [
                Padding(
                  padding: 14.left,
                  child: Row(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => TextView(
                          // margin: 10.top,
                          text: '${profileData.value.postCount ?? 0}',
                          style: 14.txtBoldWhite,
                        ),
                      ),
                      10.width,
                      TextView(
                        // margin: 1.top + 10.bottom,
                        text: 'Posts',
                        style: 16.txtBoldWhite,
                      ),
                    ],
                  ),
                ),
                10.height,
                GestureDetector(
                  onTap: () {
                    profileCtrl
                        .getFriendFollowers(profileData.value.id!)
                        .applyLoader
                        .then((value) {
                          context.pushNavigator(
                            FriendFollowersListScreen(
                              list: value,
                              userId: profileData.value.id!,
                            ),
                          );
                        });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 14.0),
                    child: Row(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextView(
                          // margin: 10.top,
                          text: '${(profileData.value.followers ?? []).length}',
                          style: 14.txtBoldWhite,
                        ),
                        10.width,
                        TextView(
                          // margin: 1.top + 10.bottom,
                          text: 'Linked Me',
                          style: 16.txtBoldWhite,
                        ),
                      ],
                    ),
                  ),
                ),
                10.height,
                Padding(
                  padding: const EdgeInsets.only(left: 14.0),
                  child: GestureDetector(
                    onTap: () {
                      profileCtrl
                          .getFriendFollowings(profileData.value.id!)
                          .applyLoader
                          .then((value) {
                            context.pushNavigator(
                              FriendFollowingListScreen(
                                list: value,
                                userId: profileData.value.id!,
                              ),
                            );
                          });
                    },
                    child: Row(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => TextView(
                            // margin: 10.top,
                            text:
                                '${(profileData.value.following ?? []).length}',
                            style: 14.txtBoldWhite,
                          ),
                        ),
                        10.width,
                        TextView(
                          // margin: 1.top + 10.bottom,
                          text: 'Link Ups',
                          style: 16.txtBoldWhite,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 10.height,
            Obx(
              () => Visibility(
                visible: !isFriend,
                child: AppButton(
                  margin: 15.top,
                  onTap: () {
                    followAction();
                  },
                  padding: EdgeInsets.symmetric(vertical: 8),
                  radius: 10,
                  buttonColor: AppColors.btnColor,
                  label: 'Link Up',
                ),
              ),
            ),

            Obx(
              () => Visibility(
                visible: isFriend,
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        onTap: () async {
                          followAction();
                        },
                        padding: EdgeInsets.symmetric(vertical: 8),
                        radius: 10,
                        buttonBorderColor: AppColors.btnColor,
                        // buttonColor: AppColors.green,
                        label: 'Linked',
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: AppButton(
                        onTap: () {
                          context.pushNavigator(
                            MessageScreen(data: profileData.value),
                          );
                        },
                        padding: EdgeInsets.symmetric(vertical: 8),
                        radius: 10,
                        buttonBorderColor: AppColors.btnColor,
                        // buttonColor: AppColors.green,
                        label: 'Message',
                      ),
                    ),
                    20.height,
                  ],
                ),
              ),
            ),

            30.height,

            // Row(
            //   children: [
            //
            //   ],
            // )
          ],
        ),
      ),
    );
  }

  void _updateHeight() {
    final renderBox =
        _dynamicContentKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      AppUtils.log(collapseHeight.value);
      collapseHeight.value = renderBox.size.height + 80;
      showView.value = true;
    }
  }

  RxBool showView = RxBool(false);

  String _getJoinedText() {
    if (profileData.value.createdAt == null) return 'Recently joined';

    try {
      final joinDate = DateTime.parse(profileData.value.createdAt!);
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
    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Cover Photo Section
              SliverToBoxAdapter(child: _buildCoverPhotoSection()),
              // Profile Info Section
              SliverToBoxAdapter(child: _buildProfileInfoSection()),
              // Stats Section
              SliverToBoxAdapter(child: _buildStatsSection()),
              // Action Buttons (Link/Message)
              SliverToBoxAdapter(child: _buildActionButtons()),
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
            child: profileData.value.coverPhoto?.isNotEmpty == true
                ? ImageView(
                    url: profileData.value.coverPhoto!,
                    fit: BoxFit.fill,
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
          // Back button
          Positioned(
            top: 10,
            left: 10,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          // More options button
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () {
                // Show more options menu
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) => Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.report_outlined,
                            color: Colors.red,
                          ),
                          title: Text('Report User'),
                          onTap: () {
                            Navigator.pop(context);
                            // Add report functionality
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.block_outlined,
                            color: Colors.red,
                          ),
                          title: Text('Block User'),
                          onTap: () {
                            Navigator.pop(context);
                            // Add block functionality
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.share_outlined),
                          title: Text('Share Profile'),
                          onTap: () {
                            Navigator.pop(context);
                            // Add share functionality
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.more_vert, color: Colors.white, size: 20),
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Obx(() {
                final imageUrl = AppUtils.configImageUrl(
                  profileData.value.image ?? '',
                );
                return CircleAvatar(
                  radius: 56,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: imageUrl.isNotEmpty
                      ? NetworkImage(imageUrl)
                      : AssetImage(AppImages.dummyProfile) as ImageProvider,
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
          Obx(
            () => TextView(
              text: profileData.value.name ?? 'User Name',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 4),
          // Join Date
          Obx(
            () => TextView(
              text: _getJoinedText(),
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
          ),
          SizedBox(height: 8),
          // Bio
          if (profileData.value.bio?.isNotEmpty == true)
            Obx(
              () => TextView(
                text: profileData.value.bio!,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
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
              Obx(
                () => _buildStatItem(
                  '${profileData.value.postCount ?? 0}',
                  'Posts',
                ),
              ),
              Container(
                height: 30,
                width: 1,
                color: Colors.grey[400],
                margin: EdgeInsets.symmetric(horizontal: 20),
              ),
              GestureDetector(
                onTap: () {
                  profileCtrl
                      .getFriendFollowers(profileData.value.id!)
                      .applyLoader
                      .then((value) {
                        context.pushNavigator(
                          FriendFollowersListScreen(
                            list: value,
                            userId: profileData.value.id!,
                          ),
                        );
                      });
                },
                child: Obx(
                  () => _buildStatItem(
                    '${(profileData.value.followers ?? []).length}',
                    'Linked Me',
                  ),
                ),
              ),
              Container(
                height: 30,
                width: 1,
                color: Colors.grey[400],
                margin: EdgeInsets.symmetric(horizontal: 20),
              ),
              GestureDetector(
                onTap: () {
                  profileCtrl
                      .getFriendFollowings(profileData.value.id!)
                      .applyLoader
                      .then((value) {
                        context.pushNavigator(
                          FriendFollowingListScreen(
                            list: value,
                            userId: profileData.value.id!,
                          ),
                        );
                      });
                },
                child: Obx(
                  () => _buildStatItem(
                    '${(profileData.value.following ?? []).length}',
                    'Link Ups',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
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
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: followAction,
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: isFriend ? AppColors.btnColor : Colors.transparent,
                    border: Border.all(color: AppColors.btnColor, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: TextView(
                      text: isFriend ? "Linked" : "Link Up",
                      style: TextStyle(
                        color: isFriend ? Colors.white : AppColors.btnColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  context.pushNavigator(MessageScreen(data: profileData.value));
                },
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.btnColor, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: TextView(
                      text: "Message",
                      style: TextStyle(
                        color: AppColors.btnColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
                    bottom: BorderSide(color: AppColors.btnColor, width: 2),
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.btnColor : Colors.grey[600],
                size: 24,
              ),
              SizedBox(height: 4),
              TextView(
                text: label,
                style: TextStyle(
                  color: isSelected ? AppColors.btnColor : Colors.grey[600],
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
      List<PostData> filteredPosts = list;

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
            ? _buildImagesGrid(filteredPosts)
            : tabIndex.value == 1
            ? _buildVideosGrid(filteredPosts)
            : _buildPollsList(filteredPosts),
      );
    });
  }

  Widget _buildImagesGrid(List<PostData> posts) {
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
        return _buildGridItem(post, index);
      },
    );
  }

  Widget _buildVideosGrid(List<PostData> posts) {
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
        return _buildVideoGridItem(post, index);
      },
    );
  }

  Widget _buildPollsList(List<PostData> posts) {
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
              profilePollPostListFriend.removeAt(index);
              profilePollPostListFriend.refresh();
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
              final data = profilePollPostListFriend[index];
              final count = data.likeCount ?? 0;
              final status = data.isLikedByUser ?? false;
              profilePollPostListFriend[index] = data.copyWith(
                isLikedByUser: !status,
                likeCount: status ? count - 1 : count + 1,
              );
              profilePollPostListFriend.refresh();
            },
            updateCommentCount: (value) {},
            updatePostOnAction: (commentCount) {
              final postId = post.id!;
              profileCtrl.getSinglePostData(postId).then((value) {
                final index = profilePollPostListFriend.indexWhere(
                  (element) => element.id == postId,
                );
                if (index > -1) {
                  profilePollPostListFriend[index] = value.copyWith(
                    user: profilePollPostListFriend[index].user,
                    commentCount: commentCount,
                  );
                  profilePollPostListFriend.refresh();
                }
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildGridItem(PostData post, int index) {
    final firstFile = post.files.isNotEmpty ? post.files.first : null;

    return GestureDetector(
      onTap: () {
        context.pushNavigator(
          PostImageBrowsingListing(
            list: profileImagePostListFriend,
            onRemovePost: (index) {
              profileImagePostListFriend.removeAt(index);
              profileImagePostListFriend.refresh();
            },
            onPostLikeAction: (index) {
              final data = profileImagePostListFriend[index];
              final status = data.isLikedByUser ?? false;
              final count = data.likeCount ?? 0;
              profileImagePostListFriend[index] = data.copyWith(
                likeCount: status ? count - 1 : count + 1,
                isLikedByUser: !status,
              );
              profileImagePostListFriend.refresh();
            },
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (firstFile?.file?.isNotEmpty == true)
                Image.network(
                  AppUtils.configImageUrl(firstFile!.file!),
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
                )
              else
                Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.grey[500],
                      size: 40,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoGridItem(PostData post, int index) {
    final firstFile = post.files.isNotEmpty ? post.files.first : null;

    return GestureDetector(
      onTap: () {
        final videoUrl = AppUtils.configImageUrl(firstFile?.file ?? '');
        context.pushNavigator(
          VideoScreen(videoUrls: [videoUrl], initialIndex: 0),
        );
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
              if (firstFile?.file?.isNotEmpty == true)
                Image.network(
                  AppUtils.configImageUrl(firstFile!.file!),
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
                )
              else
                Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(
                      Icons.video_library_outlined,
                      color: Colors.grey[500],
                      size: 40,
                    ),
                  ),
                ),
              // Video overlay
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.play_arrow, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOldGridView(
    ProfileCtrl profileCtrl,
    List<PostData> list,
    Function(int) removePost,
  ) {
    return Obx(() {
      if (!Get.isRegistered<ProfileCtrl>()) {
        return const SizedBox();
      }

      final imagePosts = list;

      // profileCtrl.postList
      //     .where((post) =>
      // (post.files?.isNotEmpty ?? false) && (post.files?.first.file?.isNotEmpty ?? false))
      //     .toList();

      if (imagePosts.isEmpty) {
        return Center(
          child: TextView(text: "No post available", style: 16.txtSBoldprimary),
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
        itemCount: imagePosts.length,
        itemBuilder: (context, index) {
          final post = imagePosts[index];
          return GestureDetector(
            onTap: () => context.pushNavigator(
              PostImageBrowsingListing(
                initialIndex: index,
                list: profileImagePostListFriend,
                onRemovePost: (index) {
                  removePost(index);
                },
                onPostLikeAction: (index) {
                  final data = profileImagePostListFriend[index];
                  final status = data.isLikedByUser ?? false;
                  final count = data.likeCount ?? 0;
                  profileImagePostListFriend[index] = data.copyWith(
                    likeCount: status ? count - 1 : count + 1,
                    isLikedByUser: !status,
                  );
                  profileImagePostListFriend.refresh();
                },
              ),
            ),
            // child: ClipRRect(
            //   borderRadius: BorderRadius.circular(20),
            //   child: CachedNetworkImage(
            //     imageUrl: finalImageUrl,
            //     fit: BoxFit.cover,
            //     height: 100.sdp,
            //     width: 100.sdp,
            //     errorWidget: (context, url, error) => Icon(Icons.error),
            //   ),
            // ),
          );
        },
      );
    });
  }

  Future<String?> _generateThumbnail(String videoUrl) async {
    try {
      // YouTube Video Thumbnails
      if (videoUrl.contains("youtube.com")) {
        // Example for YouTube - Extract video ID from the URL
        final videoId = videoUrl.split("v=")[1].split("&")[0];
        return "https://img.youtube.com/vi/$videoId/maxresdefault.jpg"; // Max resolution
      }

      // Vimeo Video Thumbnails (if supported)
      if (videoUrl.contains("vimeo.com")) {
        // Extract the video ID from the Vimeo URL
        final videoId = videoUrl.split("/").last;
        return "https://vumbnail.com/$videoId.jpg"; // Example thumbnail URL
      }

      // For MP4 files, you could generate a thumbnail or use a static URL (from your server)
      if (videoUrl.endsWith(".mp4")) {
        // Return a custom thumbnail based on the MP4 file or server logic
        return "$videoUrl-thumbnail.jpg"; // Assuming your server generates thumbnails
      }

      // Default static thumbnail (fallback)
      return 'https://images.stockcake.com/public/4/5/f/45f56484-6a01-4537-9d7d-6e4a5245e1b6_large/digital-connectivity-network-stockcake.jpg';
    } catch (e) {
      debugPrint("Thumbnail generation failed: $e");
    }
    return null;
  }

  Widget _buildOldGridViewVideo(
    ProfileCtrl profileCtrl,
    List<PostData> profileVideoPostListFriend,
  ) {
    return Obx(() {
      if (!Get.isRegistered<ProfileCtrl>()) {
        return const SizedBox();
      }

      final videoPosts = profileVideoPostListFriend;

      if (videoPosts.isEmpty) {
        return Center(
          child: TextView(text: "No post available", style: 16.txtSBoldprimary),
        );
      }

      final videoUrls = <String>[];

      videoUrls.add(
        "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4",
      );

      for (var post in videoPosts) {
        if (post.files?.isNotEmpty ?? false) {
          String? filePath = post.files?.first.file;
          if (filePath != null && filePath.isNotEmpty) {
            if (filePath.startsWith("http")) {
              videoUrls.add(filePath);
            } else if (filePath.startsWith("/public/uploads/") ||
                filePath.startsWith("/")) {
              videoUrls.add("$baseUrl$filePath");
            }
          }
        }
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: videoUrls.length,
        itemBuilder: (context, index) {
          final videoUrl = videoUrls[index];

          return FutureBuilder<String?>(
            future: _generateThumbnail(videoUrl),
            // Dynamically fetch the thumbnail
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || snapshot.data == null) {
                return const SizedBox();
              }

              return GestureDetector(
                onTap: () {
                  context.pushNavigator(
                    VideoScreen(videoUrls: videoUrls, initialIndex: index),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.sdp),
                  child: Container(
                    height: 100.sdp,
                    width: 100.sdp,
                    decoration: BoxDecoration(
                      color: AppColors.grey.withAlpha(100),
                      borderRadius: BorderRadius.circular(10.sdp),
                      image: DecorationImage(
                        image: NetworkImage(snapshot.data!),
                        // Use dynamic thumbnail URL
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    });
  }

  Widget _buildOldPollListView(ProfileCtrl profileCtrl, List<PostData> list) {
    return Obx(() {
      if (!Get.isRegistered<ProfileCtrl>()) {
        return const SizedBox();
      }

      final videoPosts = list;

      // profileCtrl.postList
      //     .where((post) =>
      // (post.files?.isNotEmpty ?? false) && (post.files?.first.file?.isNotEmpty ?? false))
      //     .toList();

      if (videoPosts.isEmpty) {
        return Center(
          child: TextView(
            text: "No Polls Available",
            style: 16.txtSBoldprimary,
          ),
        );
      }

      final videoUrls = <String>[];

      videoUrls.add(
        "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4",
      );

      for (var post in videoPosts) {
        if (post.files?.isNotEmpty ?? false) {
          String? filePath = post.files?.first.file;
          if (filePath != null && filePath.isNotEmpty) {
            if (filePath.startsWith("http")) {
              videoUrls.add(filePath);
            } else if (filePath.startsWith("/public/uploads/") ||
                filePath.startsWith("/")) {
              videoUrls.add("$baseUrl$filePath");
            }
          }
        }
      }

      return ListView.separated(
        itemBuilder: (context, index) {
          final item = list[index];

          final footer = postFooter(
            context: context,
            item: item,
            postLiker: (value) async {
              // ........
              await profileCtrl.likeposts(item.id ?? '');
            },
            updateCommentCount: (value) {},
            updatePostOnAction: (commentCount) {
              final postId = item.id!;
              profileCtrl.getSinglePostData(postId).then((value) {
                final index = profilePollPostListFriend.indexWhere(
                  (element) => element.id == postId,
                );
                if (index > -1) {
                  profilePollPostListFriend[index] = value.copyWith(
                    user: profilePollPostListFriend[index].user,
                    commentCount: commentCount,
                  );
                  profilePollPostListFriend.refresh();
                }
              });
            },
          );
          ;

          return PollCard(
            footer: footer,
            data: item,
            header: postCardHeader(
              item,
              onRemovePostAction: () {
                profilePollPostListFriend.removeAt(index);
                profilePollPostListFriend.refresh();
              },
            ),
            question: item.content ?? '',
            options: item.options,
            onPollAction: (String optionId) {
              profileCtrl.givePollToHomePost(item, optionId).applyLoader;
            },
            // starttime: DateTime.parse(item.startTime.toString()),
            // endtime: DateTime.parse(item.endTime.toString()),
          );
        },
        separatorBuilder: (context, index) => SizedBox(height: 10),
        itemCount: list.length,
      );
    });
  }
}
