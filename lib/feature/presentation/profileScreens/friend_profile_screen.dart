import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/feature/presentation/controller/chat_ctrl.dart';
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
import 'package:sep/feature/presentation/chatScreens/ImagePreviewScreen.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/loaderUtils.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/widget.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import '../../../utils/appUtils.dart';
import '../Home/homeScreenComponents/pollCard.dart';
import '../Home/homeScreenComponents/celebrationCard.dart';
import '../Home/homeScreenComponents/post_components.dart';
import '../Home/video.dart';
import '../chatScreens/Messages_Screen.dart';
import '../controller/auth_Controller/profileCtrl.dart';
import '../controller/story/story_controller.dart';
import '../Home/story/story_view_screen.dart';
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
  StoryController? storyController;

  bool get hasStories {
    if (storyController == null) return false;
    final userId = profileData.value.id;
    return storyController!.getStoriesForUser(userId ?? '').isNotEmpty;
  }

  // Cache for video thumbnails
  final Map<String, String?> _thumbnailCache = {};

  List<String> get tabsss => ["IMAGES", "VIDEOS", "POLLS", "CELEBRATIONS"];

  RxList<PostData> profileImagePostListFriend = RxList();
  RxList<PostData> profileVideoPostListFriend = RxList();
  RxList<PostData> profilePollPostListFriend = RxList();
  RxList<PostData> profileCelebrationPostListFriend = RxList();

  int profileImagePageNoFriend = 1;
  int profileVideoPageNoFriend = 1;
  int profilePollPageNoFriend = 1;
  int profileCelebrationPageNoFriend = 1;

  // List<PostData> get list =>
  //     tabIndex.value == 2 ? profileCtrl.profilePollPostListFriend :
  //     tabIndex.value == 1 ?profileCtrl.profileVideoPostListFriend :
  //     profileCtrl.profileImagePostListFriend;

  List<PostData> get list => tabIndex.value == 3
      ? profileCelebrationPostListFriend
      : tabIndex.value == 2
      ? profilePollPostListFriend
      : tabIndex.value == 1
      ? profileVideoPostListFriend
      : profileImagePostListFriend;

  PostFileType get postType => tabIndex.value == 3
      ? PostFileType.post
      : tabIndex.value == 2
      ? PostFileType.poll
      : tabIndex.value == 1
      ? PostFileType.video
      : PostFileType.image;

  bool get isFriend =>
      (profileData.value.followers ?? []).contains(Preferences.uid);

  // Get actual count of displayed posts (excluding stories)
  int get adjustedFriendPostCount {
    return profileImagePostListFriend.length +
        profileVideoPostListFriend.length +
        profilePollPostListFriend.length +
        profileCelebrationPostListFriend.length;
  }

  // ProfileDataModel get profileDataValue => profileCtrl.

  @override
  void initState() {
    super.initState();
    profileData.value = widget.data;

    AppUtils.log(profileData.value.toJson());
    _tabController = TabController(length: tabsss.length, vsync: this);

    // Get story controller if available
    if (Get.isRegistered<StoryController>()) {
      storyController = Get.find<StoryController>();
    }

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
          : postType == PostFileType.post
          ? profileCelebrationPageNoFriend
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
            // Filter celebrations for celebration tab
            if (postType == PostFileType.post) {
              list = list
                  .where(
                    (post) =>
                        post.content != null &&
                        post.content!.startsWith('SEP#Celebrate'),
                  )
                  .toList();
            }

            if (list.isNotEmpty) {
              if (postType == PostFileType.poll) {
                profilePollPageNoFriend = pageNo;
              } else if (postType == PostFileType.video) {
                profileVideoPageNoFriend = pageNo;
              } else if (postType == PostFileType.post) {
                profileCelebrationPageNoFriend = pageNo;
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
                } else if (postType == PostFileType.post) {
                  profileCelebrationPostListFriend.assignAll(list);
                  profileCelebrationPostListFriend.refresh();
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
                } else if (postType == PostFileType.post) {
                  profileCelebrationPostListFriend.addAll(list);
                  profileCelebrationPostListFriend.refresh();
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

  // Block user functionality
  void _showBlockConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.block_outlined, color: Colors.red, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Block User',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to block ${profileData.value.name ?? "this user"}? They will not be able to see your profile or contact you.',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _blockUser();
              },
              child: Text(
                'Block',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _blockUser() async {
    try {
      LoaderUtils.show();
      await profileCtrl.unblockBlockUser(
        userId: profileData.value.id!,
        refreshList: false,
      );
      LoaderUtils.dismiss();
      AppUtils.toast('User blocked successfully');

      // Navigate back to previous screen
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      LoaderUtils.dismiss();
      AppUtils.toast('Failed to block user');
    }
  }

  // Report user functionality
  void _showReportDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.report_outlined, color: Colors.red, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Report User',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Please provide details about why you are reporting ${profileData.value.name ?? "this user"}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Reason',
                    hintText: 'e.g., Inappropriate content',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  maxLength: 50,
                ),
                SizedBox(height: 12),
                TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    labelText: 'Additional Details (Optional)',
                    hintText: 'Provide more information...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  maxLines: 3,
                  maxLength: 200,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                if (titleController.text.trim().isEmpty) {
                  AppUtils.toast('Please provide a reason');
                  return;
                }
                Navigator.of(dialogContext).pop();
                await _reportUser(
                  titleController.text.trim(),
                  messageController.text.trim().isEmpty
                      ? null
                      : messageController.text.trim(),
                );
              },
              child: Text(
                'Submit Report',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _reportUser(String title, String? message) async {
    try {
      LoaderUtils.show();
      await profileCtrl.reportUser(profileData.value.id!, title, message);
      LoaderUtils.dismiss();
      AppUtils.toast('User reported successfully');
    } catch (e) {
      LoaderUtils.dismiss();
      AppUtils.toast('Failed to report user');
    }
  }

  // Share profile functionality - Send profile card to friends in chat
  void _shareProfile() {
    _showFriendSelector();
  }

  void _showProfileImageOptions() {
    final imageUrl = AppUtils.configImageUrl(profileData.value.image ?? '');
    final hasProfileImage = imageUrl.isNotEmpty;
    final userId = profileData.value.id ?? '';
    final userStories = storyController?.getStoriesForUser(userId) ?? [];
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
                      ImagePreviewScreen(imageUrl: imageUrl),
                    );
                  },
                ),
              if (showStoryOption)
                ListTile(
                  leading: Icon(Icons.auto_stories, color: Colors.purple),
                  title: Text('View Story'),
                  onTap: () {
                    Navigator.pop(context);
                    context.pushNavigator(
                      StoryViewScreen(initialIndex: 0, stories: userStories),
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

  void _showFriendSelector() {
    final profileCtrl = ProfileCtrl.find;

    // Load friends lists if not already loaded
    if (profileCtrl.myFollowingList.isEmpty) {
      profileCtrl.getMyFollowings();
    }
    if (profileCtrl.myFollowersList.isEmpty) {
      profileCtrl.getMyFollowers();
    }

    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Send Profile To',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                // Combine both followers and following lists
                final allFriends = <ProfileDataModel>[
                  ...profileCtrl.myFollowingList,
                  ...profileCtrl.myFollowersList,
                ];

                // Remove duplicates and filter out current user and the profile being viewed
                final uniqueFriends = <String, ProfileDataModel>{};
                for (var friend in allFriends) {
                  if (friend.id != null &&
                      friend.id != Preferences.uid && // Exclude yourself
                      friend.id != profileData.value.id) {
                    // Exclude the profile being viewed
                    uniqueFriends[friend.id!] = friend;
                  }
                }

                final friends = uniqueFriends.values.toList();

                if (friends.isEmpty) {
                  return const Center(child: Text('No friends to share with'));
                }

                return ListView.builder(
                  controller: controller,
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friend = friends[index];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: friend.image != null
                            ? NetworkImage(
                                AppUtils.configImageUrl(friend.image!),
                              )
                            : null,
                        child: friend.image == null
                            ? Text(friend.name?[0].toUpperCase() ?? 'U')
                            : null,
                      ),
                      title: Text(friend.name ?? 'Unknown'),
                      subtitle: Text(friend.email ?? ''),
                      onTap: () {
                        Navigator.pop(context);
                        _sendProfileToFriend(friend);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _sendProfileToFriend(ProfileDataModel friend) async {
    try {
      // First, get or create chat with this friend
      final chatCtrl = ChatCtrl.find;

      // Find existing chat with this friend
      final existingChat = chatCtrl.recentChat.firstWhereOrNull(
        (chat) => chat.users?.contains(friend.id) == true,
      );

      if (existingChat != null) {
        // Use existing chat
        chatCtrl.singleChatId = existingChat.id;
      } else {
        // Create new chat - you may need to implement this in your ChatCtrl
        // For now, we'll show an error if no chat exists
        AppUtils.toast('Please start a conversation with ${friend.name} first');
        return;
      }

      // Encode profile data as JSON
      final profileJson = profileData.value.toJson();
      final jsonString = json.encode(profileJson);
      final message = 'SEP#Profile:$jsonString';

      // Send the message
      chatCtrl.sendTextMsg(message);

      // Show success message
      AppUtils.toast('Profile shared successfully');
    } catch (e) {
      AppUtils.toast('Failed to share profile');
    }
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
                          text: '$adjustedFriendPostCount',
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
                        textOverflow: TextOverflow.ellipsis,
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
                        textOverflow: TextOverflow.ellipsis,
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
                            _showReportDialog(context);
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
                            _showBlockConfirmationDialog(context);
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.share_outlined),
                          title: Text('Share Profile'),
                          onTap: () {
                            Navigator.pop(context);
                            _shareProfile();
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
            child: GestureDetector(
              onTap: () {
                _showProfileImageOptions();
              },
              child: Obx(() {
                final imageUrl = AppUtils.configImageUrl(
                  profileData.value.image ?? '',
                );
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
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
                      backgroundImage: imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl)
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
              Obx(() => _buildStatItem('$adjustedFriendPostCount', 'Posts')),
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
              ? Border(bottom: BorderSide(color: AppColors.btnColor, width: 2))
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
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
            ? _buildImagesGrid(filteredPosts)
            : tabIndex.value == 1
            ? _buildVideosGrid(filteredPosts)
            : tabIndex.value == 2
            ? _buildPollsList(filteredPosts)
            : _buildCelebrationsList(filteredPosts),
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
    final imageUrl = firstFile?.file?.isNotEmpty == true
        ? AppUtils.configImageUrl(firstFile!.file!)
        : null;

    AppUtils.log(
      'Friend Profile Grid Item - Post ${post.id}: file=$imageUrl, hasFiles=${post.files.isNotEmpty}',
    );

    return GestureDetector(
      onTap: () {
        context.pushNavigator(
          PostImageBrowsingListing(
            initialIndex: index,
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
              profileCelebrationPostListFriend.removeAt(index);
              profileCelebrationPostListFriend.refresh();
            },
          ),
          caption: post.content ?? '',
          footer: postFooter(
            context: context,
            item: post,
            postLiker: (value) async {
              await profileCtrl.likeposts(post.id ?? '');
              final data = profileCelebrationPostListFriend[index];
              final count = data.likeCount ?? 0;
              final status = data.isLikedByUser ?? false;
              profileCelebrationPostListFriend[index] = data.copyWith(
                isLikedByUser: !status,
                likeCount: status ? count - 1 : count + 1,
              );
              profileCelebrationPostListFriend.refresh();
            },
            updateCommentCount: (value) {},
            updatePostOnAction: (commentCount) {
              final postId = post.id!;
              profileCtrl.getSinglePostData(postId).then((value) {
                final idx = profileCelebrationPostListFriend.indexWhere(
                  (element) => element.id == postId,
                );
                if (idx > -1) {
                  profileCelebrationPostListFriend[idx] = value.copyWith(
                    user: profileCelebrationPostListFriend[idx].user,
                    commentCount: commentCount,
                  );
                  profileCelebrationPostListFriend.refresh();
                }
              });
            },
          ),
          data: post,
        );
      },
    );
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
