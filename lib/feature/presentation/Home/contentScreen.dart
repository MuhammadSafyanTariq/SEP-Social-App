import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/data/models/dataModels/Createpost/getcategory_model.dart';
import 'package:sep/feature/data/models/dataModels/post_data.dart';
import 'package:sep/feature/presentation/controller/agora_chat_ctrl.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import '../controller/auth_Controller/profileCtrl.dart';
import '../controller/createpost/createpost_ctrl.dart';
import '../widgets/profile_image.dart';
import 'homeScreenComponents/pollCard.dart';
import 'homeScreenComponents/postCard.dart';
import 'homeScreenComponents/postVideo.dart';
import 'homeScreenComponents/post_components.dart';
import 'homeScreenComponents/celebrationCard.dart';
import 'searchScreen.dart';
import 'story/story_list_widget.dart';

class Contentscreen extends StatefulWidget {
  final Function()? getLiveStreamList;
  const Contentscreen({Key? key, this.getLiveStreamList}) : super(key: key);

  @override
  State<Contentscreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Contentscreen> {
  int commentCount = 0;

  void updateCommentCount(int newCount) {
    setState(() {
      commentCount = newCount;
    });
  }

  var globalPostList = <PostData>[].obs;

  // Helper function to capitalize category names
  String _getCategoryDisplayName(String? categoryName) {
    if (categoryName == null) return '';
    // Map "Politics" to "Perception" for display
    if (categoryName == 'Politics') return 'Perception';

    // Capitalize category names that start with lowercase
    if (categoryName.isNotEmpty &&
        categoryName[0].toLowerCase() == categoryName[0]) {
      return categoryName[0].toUpperCase() + categoryName.substring(1);
    }

    return categoryName;
  }

  // Helper method to sort categories in the specified order
  List<Categories> _sortCategories(List<Categories> categories) {
    // Define the desired order
    const order = [
      'sports',
      'entertainment',
      'perception',
      'politics',
      'advertisement',
      'others',
      'other',
    ];

    return categories..sort((a, b) {
      final aName = a.name?.toLowerCase() ?? '';
      final bName = b.name?.toLowerCase() ?? '';

      final aIndex = order.indexOf(aName);
      final bIndex = order.indexOf(bName);

      // If both are in the order list, sort by their position
      if (aIndex != -1 && bIndex != -1) {
        return aIndex.compareTo(bIndex);
      }

      // If only a is in the order list, it comes first
      if (aIndex != -1) return -1;

      // If only b is in the order list, it comes first
      if (bIndex != -1) return 1;

      // If neither is in the order list, sort alphabetically
      return aName.compareTo(bName);
    });
  }

  List<Categories> get categories {
    final list = CreatePostCtrl.find.getCategories;
    final filtered = list
        .where((cat) => cat.name?.toLowerCase() != 'other')
        .toList();

    // Sort the filtered categories
    final sorted = _sortCategories(filtered);

    return [Categories(id: null, name: 'All'), ...sorted];
  }

  Rx<Categories> selectedCategory = Rx(Categories(id: null, name: 'All'));

  final ProfileCtrl profileCtrl = Get.put(ProfileCtrl());
  // final ScrollController _scrollController = ScrollController();

  // final RxBool _isLoading = false.obs;
  bool isLoadingMore = false;
  bool socketConnectionFlag = false;

  @override
  void initState() {
    super.initState();
    _loadInitialPosts();
    CreatePostCtrl.find.getPostCategories();
    widget.getLiveStreamList?.call();
  }

  Future postliker(String selectedpostId) async {
    await profileCtrl.likeposts(selectedpostId);
  }

  Future _loadInitialPosts({bool isRefresh = false}) async {
    widget.getLiveStreamList?.call();
    AppUtils.log(
      'Selected categruyyyyyy--------${selectedCategory.value.toJson()}',
    );

    // Reset pagination when loading initial posts or filtering by category
    setState(() => isLoadingMore = false);

    await profileCtrl.globalList(
      offset: 1,
      isLoadMore: false,
      selectedCat: selectedCategory.value,
    );

    // Debug: Check post IDs after loading
    debugPrint("🔍 Loaded ${profileCtrl.globalPostList.length} posts:");
    for (int i = 0; i < profileCtrl.globalPostList.length; i++) {
      final post = profileCtrl.globalPostList[i];
      debugPrint(
        "  Post $i: ID='${post.id}' (null: ${post.id == null}, empty: ${post.id?.isEmpty ?? true})",
      );
    }

    refreshController.refreshCompleted();
  }

  Future<void> _loadMorePosts() async {
    if (isLoadingMore) {
      refreshController.loadComplete();
      return;
    }

    if (!profileCtrl.hasMoreData) {
      refreshController.loadNoData();
      return;
    }

    setState(() => isLoadingMore = true);

    await profileCtrl
        .globalList(isLoadMore: true, selectedCat: selectedCategory.value)
        .applyLoaderWithOption(false);

    setState(() => isLoadingMore = false);

    if (profileCtrl.hasMoreData) {
      refreshController.loadComplete();
    } else {
      refreshController.loadNoData();
    }
  }

  RefreshController refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,

      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: const WaterDropHeader(),
        footer: CustomFooter(
          builder: (context, mode) {
            Widget body;
            if (mode == LoadStatus.loading) {
              body = CupertinoActivityIndicator(color: AppColors.primaryColor);
            } else if (mode == LoadStatus.noMore) {
              body = Text(
                'No more posts',
                style: TextStyle(color: Colors.grey),
              );
            } else {
              body = SizedBox();
            }

            return Container(height: 55.0, child: Center(child: body));
          },
        ),
        controller: refreshController,
        onRefresh: _loadInitialPosts,
        onLoading: _loadMorePosts,
        child: CustomScrollView(
          slivers: [
            // Search Bar
            SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () {
                  context.pushNavigator(
                    const Search(autoFocus: true),
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Colors.grey.shade600,
                        size: 22,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Search users...',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Story section
            SliverToBoxAdapter(
              child: StoryListWidget(),
            ),
            // Live Stream section
            Obx(
              () => AgoraChatCtrl.find.liveStreamChannels.isNotEmpty
                  ? SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        height: 65,
                        child: ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final item = AgoraChatCtrl
                                .find
                                .liveStreamChannels[index];
                            return SizedBox(
                              width: 50,
                              child: Column(
                                children: [
                                  ProfileImage(
                                    size: 40,
                                    image: item.hostImage.fileUrl,
                                    uid: item.hostId,
                                    socketConnection: socketConnectionFlag,
                                  ),
                                  TextView(
                                    margin: EdgeInsets.only(top: 3),
                                    text: item.hostName ?? '',
                                    maxlines: 1,
                                    style: 12.txtRegularMainBlack,
                                  ),
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              SizedBox(width: 20),
                          itemCount:
                              AgoraChatCtrl.find.liveStreamChannels.length,
                        ),
                      ),
                    )
                  : SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
            // Category Filter
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                height: 50,
                child: Obx(
                  () => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          selectedCategory.value = categories[index];
                          selectedCategory.refresh();
                          AppUtils.log('hiihgjfgygj');
                          _loadInitialPosts().applyLoader;
                        },
                        child: Obx(
                          () => Padding(
                            padding: const EdgeInsets.only(left: 7.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    categories[index].name ==
                                            selectedCategory
                                                .value
                                                .name &&
                                        categories[index].id ==
                                            selectedCategory.value.id
                                    ? AppColors.btnColor
                                    : AppColors.grey.withValues(
                                        alpha: 0.1,
                                      ),
                                borderRadius: BorderRadius.circular(
                                  30,
                                ),
                              ),
                              child: Center(
                                child: TextView(
                                  text: _getCategoryDisplayName(
                                    categories[index].name,
                                  ),
                                  style: TextStyle(
                                    color:
                                        categories[index].name ==
                                                selectedCategory
                                                    .value
                                                    .name &&
                                            categories[index].id ==
                                                selectedCategory
                                                    .value
                                                    .id
                                        ? Colors.white
                                        : categories[index].name
                                                  ?.toLowerCase() ==
                                              'other'
                                        ? Colors.red
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Obx(
              () => SliverList(
                delegate: profileCtrl.postsWithoutStories.isNotEmpty
                    ? SliverChildBuilderDelegate((context, index) {
                        if (index < _getFilteredPosts().length) {
                          final post = _getFilteredPosts()[index];
                          // Find original index for state management
                          final originalIndex = profileCtrl.postsWithoutStories
                              .indexOf(post);
                          return _buildPostWidget(
                            post,
                            () => _loadInitialPosts(),
                            originalIndex >= 0 ? originalIndex : index,
                          );
                        }
                        return Container();
                      }, childCount: _getFilteredPosts().length)
                    : SliverChildBuilderDelegate(
                        (context, index) => Center(
                          child: TextView(
                            margin: const EdgeInsets.only(top: 100),
                            text: 'No posts available',
                            style: 18.txtSBoldprimary,
                          ),
                        ),
                        childCount: 1,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Filter and reorder posts to show advertisement posts after at least 5 posts
  List<PostData> _getFilteredPosts() {
    const advertisementCategoryId = '68eb8453d5e284efb554b401';
    const minPostsBeforeAd = 5;

    final allPosts = profileCtrl.postsWithoutStories;

    // Separate advertisement posts from regular posts
    final regularPosts = allPosts
        .where((post) => post.categoryId != advertisementCategoryId)
        .toList();
    final adPosts = allPosts
        .where((post) => post.categoryId == advertisementCategoryId)
        .toList();

    // If we don't have enough regular posts, just show regular posts first
    if (regularPosts.length < minPostsBeforeAd) {
      return [...regularPosts, ...adPosts];
    }

    // Interleave advertisement posts after every 5 regular posts
    final result = <PostData>[];
    int regularIndex = 0;
    int adIndex = 0;

    while (regularIndex < regularPosts.length || adIndex < adPosts.length) {
      // Add up to 5 regular posts
      for (
        int i = 0;
        i < minPostsBeforeAd && regularIndex < regularPosts.length;
        i++
      ) {
        result.add(regularPosts[regularIndex]);
        regularIndex++;
      }

      // Add one advertisement post if available
      if (adIndex < adPosts.length) {
        result.add(adPosts[adIndex]);
        adIndex++;
      }
    }

    return result;
  }

  Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address =
            '${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}';
        return address;
      }
    } catch (e) {
      print("Error retrieving address: $e");
    }
    return "No Address Found";
  }

  Widget _buildPostWidget(PostData item, Function onBlockUser, int index) {
    final header = postCardHeader(
      item,
      onBlockUser: onBlockUser,
      onRemovePostAction: () {
        profileCtrl.globalPostList.removeAt(index);
        profileCtrl.globalPostList.refresh();
      },
    );

    final footer = postFooter(
      context: context,
      item: item,
      postLiker: (value) {
        postliker(value);
        final count = item.likeCount ?? 0;
        final status = item.isLikedByUser ?? false;
        profileCtrl.globalPostList[index] = item.copyWith(
          isLikedByUser: !status,
          likeCount: status ? count - 1 : count + 1,
        );
        profileCtrl.globalPostList.refresh();
      },
      updateCommentCount: updateCommentCount,
      updatePostOnAction: (commentCount) {
        final postId = item.id!;
        profileCtrl.getSinglePostData(postId).then((value) {
          final index = profileCtrl.globalPostList.indexWhere(
            (element) => element.id == postId,
          );
          if (index > -1) {
            final existingPost = profileCtrl.globalPostList[index];
            profileCtrl.globalPostList[index] = existingPost.copyWith(
              commentCount:
                  commentCount ??
                  value.commentCount ??
                  existingPost.commentCount,
            );
            profileCtrl.globalPostList.refresh();
          }
        });
      },
    );

    // Check if post is a celebration (starts with "SEP#Celebrate")
    if (item.content != null && item.content!.startsWith('SEP#Celebrate')) {
      return CelebrationCard(
        header: header,
        caption: item.content ?? '',
        footer: footer,
        data: item,
      );
    } else if (item.fileType == 'poll') {
      return PollCard(
        footer: footer,
        data: item,
        header: header,
        question: item.content ?? '',
        options: item.options,
        onPollAction: (String optionId) {
          profileCtrl.givePollToHomePost(item, optionId).applyLoader;
        },
      );
    } else if (item.files.isNotEmpty && item.files.first.type == 'video') {
      return PostVideo(
        data: item,
        header: header,
        footer: footer,
        view: () {
          int index = profileCtrl.globalPostList.indexOf(item);
          if (index != -1) {
            final updatedItem = item.copyWith(
              videoCount: (item.videoCount ?? 0) + 1,
            );
            profileCtrl.globalPostList[index] = updatedItem;
          }
          _loadMorePosts();
          profileCtrl.globalPostList.refresh();
        },
      );
    } else {
      return PostCard(
        postId: item.id ?? '',
        header: header,
        caption: item.content ?? '',
        imageUrls: item.files,
        likes: '',
        comments: '',
        footer: footer,
      );
    }
  }
}
