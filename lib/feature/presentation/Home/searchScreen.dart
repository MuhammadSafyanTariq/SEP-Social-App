import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import 'package:sep/utils/extensions/widget.dart';
import '../../../components/coreComponents/appBar2.dart';
import '../../../components/coreComponents/EditText.dart';
import '../../../components/coreComponents/ImageView.dart';
import '../../../components/coreComponents/TextView.dart';
import '../../../components/styles/appColors.dart';
import '../../../components/styles/appImages.dart';
import '../../../components/styles/app_strings.dart';
import '../../data/models/dataModels/profile_data/profile_data_model.dart';
import '../../data/models/dataModels/post_data.dart';
import 'homeScreenComponents/post_components.dart';
import '../controller/auth_Controller/auth_ctrl.dart';
import '../controller/auth_Controller/profileCtrl.dart';
import '../profileScreens/friend_profile_screen.dart';

class Search extends StatefulWidget {
  final bool autoFocus;
  const Search({super.key, this.autoFocus = false});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  final _authCtrl = AuthCtrl.find;

  final _debounce = RxString('');
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  int _currentPage = 1;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;
  String _lastSearchQuery = '';

  @override
  void initState() {
    super.initState();

    debounce(_debounce, (_) {
      final searchText = _searchController.text.trim();
      AppUtils.log('Debounced search text: $searchText');
      _lastSearchQuery = searchText;
      _currentPage = 1;
      _hasMoreData = true;
      _authCtrl.searchUserInProfile(searchText, page: 1, limit: 20);
      _authCtrl.searchPostsByCaption(searchText, page: 1, limit: 20);
    }, time: const Duration(milliseconds: 500));

    _searchController.addListener(() {
      _debounce.value = _searchController.text;
    });

    _authCtrl.searchUserInProfile('', page: 1, limit: 20);
    _authCtrl.searchPostsByCaption('', page: 1, limit: 20);

    // Auto focus if requested
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  Future<void> _loadMoreUsers() async {
    if (_isLoadingMore || !_hasMoreData) {
      _refreshController.loadComplete();
      return;
    }

    setState(() => _isLoadingMore = true);

    _currentPage++;
    final previousLength = _authCtrl.searchedUsers.length;

    await _authCtrl.searchUserInProfile(
      _lastSearchQuery,
      page: _currentPage,
      limit: 20,
    );

    final newLength = _authCtrl.searchedUsers.length;

    // If no new users were added, we've reached the end
    if (newLength == previousLength) {
      _hasMoreData = false;
      _refreshController.loadNoData();
    } else {
      _refreshController.loadComplete();
    }

    setState(() => _isLoadingMore = false);
  }

  Future<void> _refreshUsers() async {
    _currentPage = 1;
    _hasMoreData = true;
    await _authCtrl.searchUserInProfile(_lastSearchQuery, page: 1, limit: 20);
    _refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              AppBar2(
                prefixImage: AppImages.backBtn,
                leadIconSize: 16,
                onPrefixTap: () => Navigator.pop(context),
                title: AppStrings.search.tr,
                titleAlign: TextAlign.center,
                titleStyle: 20.txtSBoldprimary,
                backgroundColor: AppColors.white,
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.sdp,
                  vertical: 16.sdp,
                ),
                child: EditText(
                  controller: _searchController,
                  node: _focusNode,
                  hint: 'Search users or posts...',
                  hintStyle: 14.txtMediumgrey,
                  radius: 20,
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(12.sdp),
                    child: ImageView(
                      url: AppImages.searchsc,
                      size: 20.sdp,
                      tintColor: AppColors.grey,
                    ),
                  ),
                ),
              ),

              // Tabs for Users / Posts
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.sdp),
                child: TabBar(
                  labelColor: AppColors.primaryColor,
                  unselectedLabelColor: AppColors.grey,
                  indicatorColor: AppColors.primaryColor,
                  tabs: const [
                    Tab(text: 'Users'),
                    Tab(text: 'Posts'),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: TabBarView(
                  children: [
                    _buildUsersTab(),
                    _buildPostsTab(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    return Obx(() {
      final currentUserId = Preferences.uid;
      final users = _authCtrl.searchedUsers
          .where((user) => user['_id'] != currentUserId)
          .toList();

      return SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: true,
        onRefresh: _refreshUsers,
        onLoading: _loadMoreUsers,
        footer: CustomFooter(
          builder: (context, mode) {
            Widget body;
            if (mode == LoadStatus.loading) {
              body = CircularProgressIndicator(
                color: AppColors.primaryColor,
              );
            } else if (mode == LoadStatus.noMore) {
              body = const Text(
                'No more users',
                style: TextStyle(color: Colors.grey),
              );
            } else {
              body = const SizedBox();
            }
            return SizedBox(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20.sdp, vertical: 16.sdp),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final userName = user['name'] ?? 'Unknown User';
            return Padding(
              padding: EdgeInsets.only(bottom: 12.sdp),
              child: GestureDetector(
                onTap: () {
                  final userId = user['_id'];
                  if (userId != null) {
                    Get.to(
                      () => FriendProfileScreen(
                        data: ProfileDataModel.fromJson(user),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.sdp,
                    vertical: 20.sdp,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.sdp),
                  ),
                  child: Row(
                    children: [
                      ImageView(
                        url: (user['image'] as String?)?.fileUrl ?? '',
                        imageType: ImageType.network,
                        fit: BoxFit.cover,
                        size: 50.sdp,
                        radius: 25.sdp,
                        defaultImage: AppImages.dummyProfile,
                      ),
                      16.width,
                      Expanded(
                        child: TextView(
                          text: userName,
                          style: 16.txtMediumprimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildPostsTab(BuildContext context) {
    return Obx(() {
      final posts = _authCtrl.searchedPosts;

      if (posts.isEmpty) {
        return Center(
          child: TextView(
            text: 'No posts found!',
            style: 16.txtMediumgrey,
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.sdp, vertical: 16.sdp),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final raw = posts[index];
          final post = PostData.fromJson(raw);
          final header = postCardHeader(
            post,
            onBlockUser: () {},
            onRemovePostAction: null,
          );

          return Padding(
            padding: EdgeInsets.only(bottom: 16.sdp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                postFooter(
                  item: post,
                  context: context,
                  postLiker: (postId) async {
                    await ProfileCtrl.find.likeposts(postId);
                  },
                  updateCommentCount: (_) {},
                  updatePostOnAction: (_) {},
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
