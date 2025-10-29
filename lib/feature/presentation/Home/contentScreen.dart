import 'dart:io';
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
import '../../../services/networking/urls.dart';
import '../controller/auth_Controller/profileCtrl.dart';
import '../controller/createpost/createpost_ctrl.dart';
import '../widgets/profile_image.dart';
import 'CommonBannerAdWidget.dart';
import 'homeScreenComponents/pollCard.dart';
import 'homeScreenComponents/postCard.dart';
import 'homeScreenComponents/postVideo.dart';
import 'homeScreenComponents/post_components.dart';
import 'homeScreenComponents/celebrationCard.dart';

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

  List<Categories> get categories {
    final list = CreatePostCtrl.find.getCategories;
    final filtered = list
        .where((cat) => cat.name?.toLowerCase() != 'other')
        .toList();

    return [Categories(id: null, name: 'All'), ...filtered];
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
    // _scrollController.addListener(_scrollListener);
    CreatePostCtrl.find.getPostCategories();
    widget.getLiveStreamList?.call();
  }

  void _scrollListener() {
    // if (_scrollController.position.pixels >=
    //         _scrollController.position.maxScrollExtent - 100 &&
    //     // !_isLoading.value &&
    //     profileCtrl.hasMoreData) {
    //   _loadMorePosts();
    // }
  }

  Future postliker(String selectedpostId) async {
    await profileCtrl.likeposts(selectedpostId);
  }

  Future _loadInitialPosts({bool isRefresh = false}) async {
    widget.getLiveStreamList?.call();
    AppUtils.log(
      'Selected categruyyyyyy--------${selectedCategory.value.toJson()}',
    );
    await profileCtrl.globalList(
      offset: 1,
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
    if (isLoadingMore
    // || !profileCtrl.hasMoreData
    )
      return;
    // setState(() => isLoadingMore = true);

    // int offset = profileCtrl.globalPostList.length;
    await profileCtrl
        .globalList(isLoadMore: true, selectedCat: selectedCategory.value)
        .applyLoaderWithOption(profileCtrl.globalPostList.isEmpty);
    // setState(() => isLoadingMore = false);
    refreshController.loadComplete();
    return;
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
              body = CupertinoActivityIndicator(color: AppColors.white);
            } else {
              body = SizedBox();
            }

            return Container(height: 55.0, child: Center(child: body));
          },
        ),
        controller: refreshController,
        onRefresh: _loadInitialPosts,
        onLoading: _loadMorePosts,
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            // This allows child widgets to observe scroll events
            return false;
          },
          child: CustomScrollView(
            slivers: [
              Obx(
                () => SliverAppBar(
                  automaticallyImplyLeading: false,
                  pinned: false,
                  floating: true,
                  backgroundColor: Colors.white,
                  expandedHeight:
                      AgoraChatCtrl.find.liveStreamChannels.isNotEmpty
                      ? 130
                      : 40,
                  flexibleSpace: SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          Visibility(
                            visible: AgoraChatCtrl
                                .find
                                .liveStreamChannels
                                .isNotEmpty,
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
                                          socketConnection:
                                              socketConnectionFlag,
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
                                itemCount: AgoraChatCtrl
                                    .find
                                    .liveStreamChannels
                                    .length,
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.white,
                            height: 50,
                            child: Obx(
                              () => ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      selectedCategory.value =
                                          categories[index];
                                      selectedCategory.refresh();
                                      AppUtils.log('hiihgjfgygj');
                                      _loadInitialPosts().applyLoader;
                                    },
                                    child: Obx(
                                      () => Padding(
                                        padding: const EdgeInsets.only(
                                          left: 7.0,
                                        ),
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
                                                        selectedCategory
                                                            .value
                                                            .id
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
                                                    : AppColors.btnColor,
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Obx(
                () => SliverList(
                  delegate: profileCtrl.globalPostList.isNotEmpty
                      ? SliverChildBuilderDelegate((context, index) {
                          // Calculate positions: Every 11th position (10, 21, 32, etc.) is an ad
                          final isAdPosition = (index + 1) % 11 == 0;

                          if (isAdPosition) {
                            // COMPULSORY: Show ad after every 10 posts
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 16.0,
                              ),
                              child: CommonBannerAdWidget(
                                adUnitId: Platform.isAndroid
                                    ? 'ca-app-pub-3940256099942544/6300978111'
                                    : 'ca-app-pub-3940256099942544/2934735716',
                              ),
                            );
                          } else {
                            // Calculate the actual post index (subtract number of ads shown before this position)
                            final adsBeforeThisPosition = (index + 1) ~/ 11;
                            final postIndex = index - adsBeforeThisPosition;

                            if (postIndex < profileCtrl.globalPostList.length) {
                              // Show regular post
                              final post =
                                  profileCtrl.globalPostList[postIndex];

                              return _buildPostWidget(
                                post,
                                () => _loadInitialPosts(),
                                postIndex,
                              );
                            } else {
                              // Return empty container for invalid indices
                              return Container();
                            }
                          }
                        }, childCount: _getTotalItemCount())
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
      ),
    );
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
        header: header,
        caption: item.content ?? '',
        imageUrls: item.files,
        likes: '',
        comments: '',
        footer: footer,
      );
    }
  }

  // Widget _buildPostWidget1(PostData item, Function onBlockUser, int index) {
  //   final coordinates = item.location?.coordinates;
  //   return FutureBuilder<String>(
  //     future: coordinates != null
  //         ? getAddressFromCoordinates(coordinates[1], coordinates[0])
  //         : Future.value(""),
  //     builder: (context, snapshot) {
  //       // String address = "Loading...";
  //
  //       // if (snapshot.connectionState == ConnectionState.done) {
  //       //   address = snapshot.hasData ? snapshot.data! : "No Address Found";
  //       // }
  //
  //       final header = postCardHeader(item, onBlockUser: onBlockUser,
  //           onRemovePostAction: () {
  //             profileCtrl.globalPostList.removeAt(index);
  //             profileCtrl.globalPostList.refresh();
  //           });
  //
  //       final footer = postFooter(
  //           context: context,
  //           item: item,
  //           postLiker: (value) {
  //             postliker(value);
  //             final count = item.likeCount ?? 0;
  //             final status = item.isLikedByUser ?? false;
  //             profileCtrl.globalPostList[index] = item.copyWith(
  //                 isLikedByUser: !status,
  //                 likeCount: status ? count - 1 : count + 1);
  //             profileCtrl.globalPostList.refresh();
  //           },
  //           updateCommentCount: updateCommentCount,
  //           updatePostOnAction: (commentCount) {
  //             final postId = item.id!;
  //             profileCtrl.getSinglePostData(postId).then((value) {
  //               final index = profileCtrl.globalPostList
  //                   .indexWhere((element) => element.id == postId);
  //               if (index > -1) {
  //                 final existingPost = profileCtrl.globalPostList[index];
  //                 profileCtrl.globalPostList[index] = existingPost.copyWith(
  //                   commentCount: commentCount ??
  //                       value.commentCount ??
  //                       existingPost.commentCount,
  //                 );
  //                 profileCtrl.globalPostList.refresh();
  //               }
  //             });
  //           });
  //
  //       if (item.fileType == 'poll') {
  //         return PollCard(
  //           footer: footer,
  //           data: item,
  //           header: header,
  //           question: item.content ?? '',
  //           options: item.options ?? [],
  //           onPollAction: (String optionId) {
  //             profileCtrl.givePollToHomePost(item, optionId).applyLoader;
  //           },
  //         );
  //       } else if (item.files != null &&
  //           item.files!.isNotEmpty &&
  //           item.files!.first.type == 'video') {
  //         return PostVideo(
  //           data: item,
  //           header: header,
  //           caption: item.content ?? '',
  //           videoUrl: _getFormattedVideoUrl(item.files?.first.file),
  //           likes: '',
  //           comments: '',
  //           footer: footer,
  //           postId: item.id,
  //           view: () {
  //             int index = profileCtrl.globalPostList.indexOf(item);
  //             if (index != -1) {
  //               final updatedItem = item.copyWith(
  //                 videoCount: (item.videoCount ?? 0) + 1,
  //               );
  //               profileCtrl.globalPostList[index] = updatedItem;
  //             }
  //             _loadMorePosts();
  //             profileCtrl.globalPostList.refresh();
  //           },
  //         );
  //       } else {
  //         return PostCard(
  //           header: header,
  //           caption: item.content ?? '',
  //           imageUrls: item.files ?? <FileElement>[],
  //           likes: '',
  //           comments: '',
  //           footer: footer,
  //         );
  //       }
  //     },
  //   );
  // }

  // Calculate total item count including MANDATORY ads after every 10 posts
  int _getTotalItemCount() {
    final postCount = profileCtrl.globalPostList.length;
    if (postCount == 0) return 0;

    // COMPULSORY: Add one ad for every 10 posts
    // Formula: For n posts, we need floor(n/10) ads
    // Total items = posts + ads
    final adCount = (postCount / 10).floor();
    final totalItems = postCount + adCount;

    AppUtils.log(
      '📊 POST COUNT: $postCount, AD COUNT: $adCount, TOTAL ITEMS: $totalItems',
    );

    return totalItems;
  }

  String _getFormattedVideoUrl(String? video) {
    if (video == null || video.isEmpty) return "";
    return video.startsWith("http") ? video : "$baseUrl$video";
  }
}
