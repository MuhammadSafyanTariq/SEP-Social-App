import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/core/core/model/imageDataModel.dart';
import 'package:sep/feature/domain/respository/authRepository.dart';
import 'package:sep/utils/extensions/extensions.dart';
import '../../../../services/networking/apiMethods.dart';
import '../../../../services/networking/urls.dart';
import '../../../../services/storage/preferences.dart';
import '../../../../utils/appUtils.dart';
import '../../../data/models/dataModels/Createpost/getcategory_model.dart';
import '../../../data/models/dataModels/home_model/comments_list_model.dart';
import '../../../data/models/dataModels/poll_item_model/poll_item_model.dart';
import '../../../data/models/dataModels/post_data.dart';
import '../../../data/models/dataModels/profile_data/profile_data_model.dart';
import '../../../data/repository/iAuthRepository.dart';
import '../../../data/repository/iTempRepository.dart';
import '../../profileScreens/profileScreen.dart';

// getFriendProfileDetails

class ProfileCtrl extends GetxController {
  static ProfileCtrl get find => Get.put(ProfileCtrl(), permanent: true);

  final IApiMethod _apiMethod = IApiMethod();
  final ITempRepository _itemRepository = ITempRepository();
  final AuthRepository _authRepository = IAuthRepository();

  var profileData = ProfileDataModel().obs;

  ImageDataModel get profileImageData {
    ImageDataModel data = ImageDataModel();
    final imageValue = profileData.value.image;
    if (imageValue != null && imageValue.toString().trim().isNotEmpty) {
      data.network = AppUtils.configImageUrl(imageValue.toString());

      // '$baseUrl${profileData.value.image ?? ''}';
      data.type = ImageType.network;
    }
    return data;
  }

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var postList = <PostData>[].obs;
  var globalPostList = <PostData>[].obs;
  var commentList = <CommentsListModel>[].obs;

  var comentslistdata = <CommentsListModel>[].obs;

  // bool get hasMoreData => _hasMoreData.value;
  // bool get hasMoreData => globalPostList.length % 5 == 0 && globalPostList.isNotEmpty;
  //
  final RxBool _hasMoreData = true.obs;

  //
  // var _hasMoreData = true.obs;
  bool get hasMoreData => _hasMoreData.value;

  RxBool hasMoreGlobalData = true.obs;

  final RxMap<String, String?> videoThumbnails = <String, String?>{}.obs;

  @override
  void onReady() {
    super.onReady();
    getProfileDetails();
    getPostList();
    globalList();
  }

  @override
  void onInit() {
    super.onInit();
    getProfileDetails();
    getPostList();
    globalList();
  }

  Future<Map<String, dynamic>> getUserAgoraToken(
    String channelName,
    String uid,
    bool isPublisher,
  ) async {
    final result = await _authRepository.getUserAgoraToken(
      channelName: channelName,
      uid: uid,
      isPublisher: isPublisher,
    );

    if (result.isSuccess) {
      return result.data!;
    } else {
      throw result.getError!;
    }
  }

  Future<void> preloadThumbnails() async {
    for (var post in postList) {
      if (post.files?.isNotEmpty ?? false) {
        String? videoUrl = (post.files!.first.file?.startsWith("http") ?? false)
            ? post.files!.first.file
            : "$baseUrl${post.files?.first.file}";

        if (videoUrl != null && !videoThumbnails.containsKey(videoUrl)) {
          String? thumbnail = await _generateThumbnail(videoUrl);
          videoThumbnails[videoUrl] = thumbnail;
        }
      }
    }
  }

  Future<PostData> getSinglePostData(String id) async {
    final result = await _itemRepository.getSinglePost(id);
    if (result.isSuccess) {
      return result.data!;
    } else {
      // AppUtils.toastError(result.getError);
      throw '';
    }
  }

  /// Helper method to resolve post ID from PostData object
  /// Uses getSinglePostData if direct ID is not available
  Future<String?> resolvePostId(PostData postData) async {
    // First try the direct ID
    if (postData.id != null && postData.id!.isNotEmpty) {
      return postData.id;
    }

    // If direct ID is not available, try using other identifiers
    // This could be enhanced based on your specific use case
    try {
      // Option 1: Try to find the post in the current list by other properties
      final matchingPost = globalPostList.firstWhere(
        (post) =>
            post.userId == postData.userId &&
            post.createdAt == postData.createdAt &&
            post.content == postData.content,
        orElse: () => PostData(),
      );

      if (matchingPost.id != null && matchingPost.id!.isNotEmpty) {
        return matchingPost.id;
      }

      // Option 2: If we have any identifying information, we could make a search API call
      // This would require implementing a search endpoint in your backend
      AppUtils.log(
        "Unable to resolve post ID for post with userId: ${postData.userId}",
      );
      return null;
    } catch (e) {
      AppUtils.log("Error resolving post ID: $e");
      return null;
    }
  }

  Future<String?> _generateThumbnail(String videoUrl) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnailFile = File(
        '${tempDir.path}/thumbnail_${videoUrl.hashCode}.png',
      );

      // If thumbnail already exists, return it
      if (thumbnailFile.existsSync()) {
        return thumbnailFile.path;
      }

      // Generate thumbnail (replace this with a manual image extraction method)
      debugPrint("Generating Thumbnail for: $videoUrl");
      return null; // Placeholder for actual implementation
    } catch (e) {
      debugPrint("Thumbnail generation failed: $e");
    }
    return null;
  }

  Future<ProfileDataModel> getFriendProfileDetails(String id) async {
    String? authToken = Preferences.authToken;
    try {
      final response = await _apiMethod.get(
        query: {'id': id},
        url: Urls.getUserDetails,
        authToken: authToken,
      );
      final extractedData = response.data?['data'] ?? {};
      final userDetails = ProfileDataModel.fromJson(extractedData);
      return userDetails;
    } catch (e) {
      AppUtils.toastError(e);
      rethrow; // Properly rethrow the exception instead of throwing empty string
    }
  }

  Future<void> getProfileDetails() async {
    isLoading.value = true;
    errorMessage.value = '';

    String? authToken = Preferences.authToken;
    // AppUtils.log('Auth Token: $authToken');

    try {
      final response = await _apiMethod.get(
        url: Urls.getUserDetails,
        authToken: authToken,
      );

      // AppUtils.log('API Raw Response: ${response.data}');

      if (!response.isSuccess) {
        errorMessage.value =
            "Failed to fetch profile: ${response.error ?? 'Unknown error'}";
        AppUtils.log("API request failed: ${response.error}");
        AppUtils.toastError(
          response.error ?? Exception("Failed to fetch profile"),
        );
        return;
      }

      if (response.data == null) {
        errorMessage.value =
            "Failed to fetch profile: No data returned from server";
        AppUtils.log("API returned null data");
        AppUtils.toastError(Exception("Failed to fetch profile"));
        return;
      }

      final extractedData = response.data!['data'];
      if (extractedData != null) {
        AppUtils.log("Extracted Data: $extractedData");

        try {
          final userDetails = ProfileDataModel.fromJson(extractedData);

          // Debug logging for token balance updates
          final oldTokenBalance = profileData.value.tokenBalance ?? 0;
          final oldWalletTokens = profileData.value.walletTokens ?? 0;
          final newTokenBalance = userDetails.tokenBalance ?? 0;
          final newWalletTokens = userDetails.walletTokens ?? 0;
          AppUtils.log(
            "Profile Update - tokenBalance: $oldTokenBalance -> $newTokenBalance",
          );
          AppUtils.log(
            "Profile Update - walletTokens: $oldWalletTokens -> $newWalletTokens",
          );

          profileData.value = userDetails;
          profileData.refresh();
        } catch (parseError) {
          errorMessage.value = "Failed to parse profile data: $parseError";
          AppUtils.log("JSON Parsing Error: $parseError");
          AppUtils.log("Problematic JSON: $extractedData");
          AppUtils.toastError(Exception("Failed to parse profile data"));
          return;
        }

        // AppUtils.log("Profile Image URL: ${userDetails.image}");
        // AppUtils.log("Parsed Profile Data: $userDetails");
      } else {
        errorMessage.value =
            "Failed to fetch profile details (data field is null)";
        AppUtils.log("API response missing 'data' field!");
        AppUtils.toastError(Exception("Failed to fetch profile details"));
      }
    } catch (e) {
      errorMessage.value = "Error fetching profile: $e";
      AppUtils.log("Error fetching profile: $e");
      AppUtils.toastError(Exception("Error fetching profile: $e"));
    } finally {
      isLoading.value = false;
    }
  }

  RxList<ProfileDataModel> myFollowersList = RxList([]);
  RxList<ProfileDataModel> friendFollowersList = RxList([]);
  RxList<ProfileDataModel> myFollowingList = RxList([]);
  RxList<ProfileDataModel> friendFollowingList = RxList([]);

  Future getMyFollowers() async {
    myFollowersList.assignAll(await _getFollowsList('followers'));
  }

  Future getMyFollowings() async {
    myFollowingList.assignAll(await _getFollowsList('following'));
  }

  Future<List<ProfileDataModel>> getFriendFollowers(String id) async {
    return await _getFollowsList('followers', userId: id);
  }

  Future<List<ProfileDataModel>> getFriendFollowings(String id) async {
    return await _getFollowsList('following', userId: id);
  }

  Future<List<ProfileDataModel>> _getFollowsList(
    String type, {
    String? userId,
  }) async {
    final data = await _authRepository.getFollowersList(
      type: type,
      userId: userId,
    );
    if (data.isSuccess) {
      return data.data ?? [];
    } else {
      AppUtils.toastError(data.getError);
      throw '';
    }
  }

  Future<ProfileDataModel?> removeFollower(String id) async {
    final result = await _authRepository.removeFollower(userId: id);
    if (result.isSuccess) {
      return result.data;
    } else {
      AppUtils.log(result.getError);
      throw '';
    }
  }

  RxList<ProfileDataModel> blockedUserList = RxList([]);

  Future removePost(String postId) async {
    final result = await _authRepository.removePost(postId: postId);
    if (result.isSuccess) {
      return;
    } else {
      AppUtils.toastError(result.getError);
      throw '';
    }
  }

  Future<void> editPost({
    required String postId,
    required String content,
    required String country,
    required List<Map<String, dynamic>> uploadedFileUrls,
    List<PollItemModel>? pollOptions,
  }) async {
    try {
      String? userId;
      String? categoryId;
      Map<String, dynamic>? location;
      String? fileType;
      String? startTime;
      String? endTime;
      String? duration;

      // List<Map<String, String>>? formattedFiles = uploadedFileUrls.map((urlMap) {
      //   final url = urlMap['file'] ?? '';
      //   final type = urlMap['type'] ?? '';
      //   return {
      //     'file': url,
      //     'type': type,
      //     // fileType == "post"
      //     //     ? (url.endsWith(".mp4") ? "video" : "image")
      //     //     : fileType ?? "",
      //   };
      // }).toList();

      Map<String, dynamic> requestBody = {
        'userId': userId,
        'categoryId': categoryId,
        'content': content,
        'files': uploadedFileUrls,
        'fileType': fileType,
        'country': country,
        'location': location,
        "startTime": startTime,
        "endTime": endTime,
        "duration": duration,
        if (pollOptions != null && pollOptions.isNotEmpty)
          "options": pollOptions.map((element) => element.toJson()).toList(),
      };

      AppUtils.log("Edit Post Request: $requestBody");

      final result = await _apiMethod.put(
        url: Urls.editPost,
        body: requestBody,
        query: {'id': postId},
        headers: {'Content-Type': 'application/json'},
      );

      AppUtils.log("Edit Post Response: ${result.toJson()}");

      if (result.isSuccess) {
        AppUtils.log("Post edited successfully");
      } else {
        AppUtils.toastError(result.getError);
        throw Exception("Failed to edit post: ${result.getError}");
      }
    } catch (e) {
      AppUtils.toastError("An error occurred: $e");
      throw Exception("An error occurred: $e");
    }
  }

  Future getBlockedUserList() async {
    final result = await _authRepository.getBlockedUserList();
    if (result.isSuccess) {
      blockedUserList.assignAll(result.data!);
      return;
    } else {
      AppUtils.toastError(result.getError);
      throw '';
    }
  }

  Future unblockBlockUser({
    bool refreshList = false,
    required String userId,
  }) async {
    final result = await _authRepository.blockUnblockUserRequest(
      blockUserId: userId,
    );
    if (result.isSuccess) {
      if (refreshList) {
        await getBlockedUserList();
      }
      return;
    } else {
      AppUtils.toastError(result.getError);
      throw '';
    }
  }

  Future reportUser(String userId, String title, String? message) async {
    final result = await _authRepository.reportUserRequest(
      id: userId,
      title: title,
      message: message,
    );
  }

  Future reportPostRequest(String postId, String title, String? message) async {
    return _authRepository.reportPostRequest(
      postId: postId,
      title: title,
      message: message,
    );
  }

  Future<void> getPostList() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _itemRepository.getPostList();
      if (response.isSuccess && response.data != null) {
        postList.assignAll(response.data ?? []);
        AppUtils.log(
          "Post List Fetched Successfully: ${postList.length} items",
        );
        AppUtils.log("UserId>>>>> ${Preferences.uid}");
        await preloadThumbnails();

        for (var post in postList) {
          if (post.files?.isNotEmpty ?? false) {
            String filePath = post.files?.first.file ?? '';
            String finalImageUrl = filePath.startsWith("http")
                ? filePath
                : "$baseUrl$filePath";
            precacheImage(NetworkImage(finalImageUrl), Get.context!);
          }
        }
      } else {
        errorMessage.value = "Failed to fetch posts";
      }
    } catch (e) {
      errorMessage.value = "Error fetching posts: $e";
      AppUtils.log("Error fetching posts: $e");
    } finally {
      isLoading.value = false;
    }
  }

  int profileImagePageNo = 1;
  int profileVideoPageNo = 1;
  int profilePollPageNo = 1;

  // int profileImagePageNoFriend = 1;
  // int profileVideoPageNoFriend  = 1;
  // int profilePollPageNoFriend  = 1;

  RxList<PostData> profileImagePostList = RxList();
  RxList<PostData> profileVideoPostList = RxList();
  RxList<PostData> profilePollPostList = RxList();

  // RxList<PostData> profileImagePostListFriend = RxList();
  // RxList<PostData> profileVideoPostListFriend = RxList();
  // RxList<PostData> profilePollPostListFriend = RxList();

  Future<void> getMyProfilePosts({
    required PostFileType type,
    bool loadMore = false,
    bool refresh = false,
  }) async {
    int pageNo = type == PostFileType.poll
        ? profilePollPageNo
        : type == PostFileType.video
        ? profileVideoPageNo
        : profileImagePageNo;

    if (refresh) {
      pageNo = 1;
    }
    if (loadMore) {
      pageNo++;
    }

    final result = await _itemRepository.getMyProfilePosts(
      pageNo: pageNo,
      fileType:
          (type != PostFileType.poll
                  ? (type == PostFileType.video
                        ? PostFileType.video
                        : PostFileType.image)
                  : null)
              ?.name,
      postType:
          (type == PostFileType.poll ? PostFileType.poll : PostFileType.post)
              .name,
    );

    if (result.isSuccess) {
      final list = result.data ?? [];

      if (list.isNotEmpty) {
        if (type == PostFileType.poll) {
          profilePollPageNo = pageNo;
        } else if (type == PostFileType.video) {
          profileVideoPageNo = pageNo;
        } else {
          profileImagePageNo = pageNo;
        }

        if (pageNo == 1) {
          if (type == PostFileType.poll) {
            profilePollPostList.assignAll(list);
            profilePollPostList.refresh();
          } else if (type == PostFileType.video) {
            profileVideoPostList.assignAll(list);
            profileVideoPostList.refresh();
          } else {
            profileImagePostList.assignAll(list);
            profileImagePostList.refresh();
          }
        } else {
          if (type == PostFileType.poll) {
            profilePollPostList.addAll(list);
            profilePollPostList.refresh();
          } else if (type == PostFileType.video) {
            profileVideoPostList.addAll(list);
            profileVideoPostList.refresh();
          } else {
            profileImagePostList.addAll(list);
            profileImagePostList.refresh();
          }
        }
      } else {}
      return;
    } else {
      AppUtils.toastError(result.getError);
      throw '';
    }
  }

  Future followRequest(String id) async {
    final result = await _authRepository.followUnfollowUserRequest(
      followUserId: id,
    );
    if (result.isSuccess) {
      return;
    } else {
      AppUtils.toastError(result.getError);
      throw '';
    }
  }

  Future<List<PostData>> getMyProfilePostsFriend({
    required String userId,
    required PostFileType type,
    bool loadMore = false,
    bool refresh = false,
    required int pageCount,
  }) async {
    int pageNo = pageCount;

    if (refresh) {
      pageNo = 1;
    }
    if (loadMore) {
      pageNo++;
    }

    final result = await _itemRepository.getMyProfilePosts(
      userId: userId,
      pageNo: pageNo,
      fileType:
          (type != PostFileType.poll
                  ? (type == PostFileType.video
                        ? PostFileType.video
                        : PostFileType.image)
                  : null)
              ?.name,
      postType:
          (type == PostFileType.poll ? PostFileType.poll : PostFileType.post)
              .name,
    );

    if (result.isSuccess) {
      final list = result.data ?? [];
      return list;

      // if (list.isNotEmpty) {
      //
      //   if (type == PostFileType.poll) {
      //     profilePollPageNoFriend = pageNo;
      //   } else if (type == PostFileType.video) {
      //     profileVideoPageNoFriend = pageNo;
      //   } else {
      //     profileImagePageNoFriend = pageNo;
      //   }
      //
      //   if (pageNo == 1) {
      //     if (type == PostFileType.poll) {
      //       profilePollPostListFriend.assignAll(list);
      //       profilePollPostListFriend.refresh();
      //     } else if (type == PostFileType.video) {
      //       profileVideoPostListFriend.assignAll(list);
      //       profileVideoPostListFriend.refresh();
      //     } else {
      //       profileImagePostListFriend.assignAll(list);
      //       profileImagePostListFriend.refresh();
      //     }
      //   } else {
      //     if (type == PostFileType.poll) {
      //       profilePollPostListFriend.addAll(list);
      //       profilePollPostListFriend.refresh();
      //     } else if (type == PostFileType.video) {
      //       profileVideoPostListFriend.addAll(list);
      //       profileVideoPostListFriend.refresh();
      //     } else {
      //       profileImagePostListFriend.addAll(list);
      //       profileImagePostListFriend.refresh();
      //     }
      //   }
      // } else {}
      // return;
    } else {
      AppUtils.toastError(result.getError);
      throw '';
    }
  }

  // Future<void> getPostList() async {
  //   isLoading.value = true;
  //   errorMessage.value = '';
  //
  //   try {
  //     final response = await _itemRepository.getPostList();
  //
  //     if (response.isSuccess && response.data?.data != null) {
  //       postList.assignAll(response.data!.data);
  //       AppUtils.log("Post List Fetched Successfully: ${postList.length} items");
  //       AppUtils.log("UserId>>>>> ${Preferences.uid}");
  //     } else {
  //       errorMessage.value = "Failed to fetch posts";
  //       AppUtils.log("Failed to fetch posts: ${response.error}");
  //     }
  //   } catch (e) {
  //     errorMessage.value = "Error fetching posts: $e";
  //     AppUtils.log("Error fetching posts: $e");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  int getUserPostCount() {
    return postList.where((post) => post.userId == Preferences.uid).length;
  }

  int homeContentIndex = 1;

  Future<void> globalList({
    int limit = 10,
    bool isLoadMore = false,
    int offset = 1,
    Categories? selectedCat,
  }) async {
    AppUtils.log('calling here.....');
    int page = isLoadMore ? homeContentIndex + 1 : 1;

    errorMessage.value = '';
    isLoading.value = true;

    try {
      final response = await _itemRepository.globalList(
        limit: limit,
        offset: page,
        categoryId: selectedCat?.id,
      );
      AppUtils.log('home page number is ::: $page');

      if (response.isSuccess && response.data != null) {
        AppUtils.log('home page number is ::: 11111111');
        final newPosts = response.data ?? [];

        if (newPosts.isNotEmpty) {
          homeContentIndex = page;

          // Debug: Check for posts with missing IDs
          _debugPostIds(newPosts);
        }

        if (page == 1) {
          // Sort posts: prioritize advertisements < 24 hours old
          final sortedPosts = _sortPostsWithAdvertisementPriority(newPosts);
          globalPostList.assignAll(
            sortedPosts,
          ); // Replace the list if it's the first page
        } else {
          globalPostList.addAll(
            newPosts,
          ); // Append new posts for subsequent pages
        }

        _hasMoreData.value =
            newPosts.length == limit; // Check if more data is available
      } else {
        AppUtils.log('home page number is ::: 2222222');
        errorMessage.value =
            "Failed to fetch posts: ${response.error ?? 'Unknown error'}";
      }
    } catch (e) {
      AppUtils.log('home page number is ::: 3333333');
      errorMessage.value = "Error fetching posts: $e";
    } finally {
      AppUtils.log('home page number is ::: 4444444');
      isLoading.value = false; // Reset loading state
    }
    AppUtils.log('home page number is ::: $page');
  }

  /// Sort posts with advertisement priority (< 24 hours old at top)
  List<PostData> _sortPostsWithAdvertisementPriority(List<PostData> posts) {
    const advertisementCategoryId = '68eb8453d5e284efb554b401';
    final now = DateTime.now();

    // Separate posts into categories
    final recentAds = <PostData>[];
    final otherPosts = <PostData>[];

    for (var post in posts) {
      // Check if it's an advertisement
      final isAdvertisement = post.categoryId == advertisementCategoryId;

      if (isAdvertisement && post.createdAt != null) {
        try {
          final postDate = DateTime.parse(post.createdAt!);
          final difference = now.difference(postDate);

          // Check if post is less than 24 hours old
          if (difference.inHours < 24) {
            recentAds.add(post);
            AppUtils.log(
              '📢 Priority Ad: ${post.id} (${difference.inHours}h old)',
            );
          } else {
            otherPosts.add(post);
          }
        } catch (e) {
          AppUtils.log('Error parsing date for post ${post.id}: $e');
          otherPosts.add(post);
        }
      } else {
        otherPosts.add(post);
      }
    }

    AppUtils.log(
      '🎯 Sorted posts: ${recentAds.length} priority ads, ${otherPosts.length} other posts',
    );

    // Return with priority ads first, then other posts
    return [...recentAds, ...otherPosts];
  }

  /// Debug method to analyze post IDs and identify missing ones
  void _debugPostIds(List<PostData> posts) {
    int totalPosts = posts.length;
    int postsWithIds = 0;
    int postsWithoutIds = 0;

    for (var post in posts) {
      if (post.id != null && post.id!.isNotEmpty) {
        postsWithIds++;
      } else {
        postsWithoutIds++;
        AppUtils.log(
          "Post without ID found - UserId: ${post.userId}, Content: ${post.content?.substring(0, post.content!.length > 50 ? 50 : post.content!.length)}..., CreatedAt: ${post.createdAt}",
        );
      }
    }

    AppUtils.log(
      "Post ID Analysis - Total: $totalPosts, With IDs: $postsWithIds, Without IDs: $postsWithoutIds",
    );

    if (postsWithoutIds > 0) {
      AppUtils.log(
        "⚠️ Warning: $postsWithoutIds posts are missing IDs. This will cause like functionality to fail.",
      );
    }
  }

  Future onHomePostLikeAction(PostData data) async {
    return;
  }

  Future makeCommentHomePost(PostData data) async {
    return;
  }

  Future getCommentListHomePost(PostData data) async {}

  Future givePollToHomePost(PostData data, String optionId) async {
    // Validate that postId is not null before making API call
    if (data.id == null || data.id!.isEmpty) {
      AppUtils.log("ERROR: PostData.id is null or empty. Cannot vote on poll.");
      AppUtils.toastError("Unable to vote - invalid poll data");
      throw 'Invalid poll data: postId is null';
    }

    AppUtils.log("Voting on poll: postId=${data.id}, optionId=$optionId");

    final result = await _itemRepository.updatePollAction(optionId, data.id!);

    if (result.isSuccess) {
      AppUtils.log("Vote successful! Response data: ${result.data?.toJson()}");

      // Validate response data
      if (result.data == null) {
        AppUtils.log("WARNING: Backend returned null data in success response");
        AppUtils.toastError("Vote may not have been recorded properly");
        return;
      }

      List<PostData> list = [...globalPostList];
      for (int i = 0; i < list.length; i++) {
        var item = list[i];
        if (item.id == data.id) {
          list[i] = result.data!;
        }
      }
      globalPostList.assignAll(list);
      globalPostList.refresh();
      return;
    } else {
      AppUtils.log("Vote failed: ${result.getError}");
      AppUtils.toastError(result.getError);
      throw '';
    }
  }

  void clearProfileData() {
    profileData.value = ProfileDataModel();
    isLoading.value = false;
    errorMessage.value = '';
    AppUtils.log("Profile data cleared on logout.");
  }

  Future<void> updateProfile({
    required String? name,
    required String? email,
    required String? phone,
    required String? countryCode,
    required String? dob,
    required String? gender,
    required String? image,
    required String? localImage,
    required String? country,
    required String? bio,
    required String? webSite,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    String? authToken = Preferences.authToken;

    try {
      String? localFileToUrl;

      if (localImage != null) {
        AppUtils.log('fileImageTest 1111');
        final imageResult = await _authRepository.uploadPhoto(
          imageFile: File(localImage),
        );
        AppUtils.log('fileImageTest 222222');
        if (imageResult.isSuccess) {
          AppUtils.log(imageResult.data!);
          final data = imageResult.data ?? [];
          localFileToUrl = data[0];
        }
      } else {
        AppUtils.log('fileImageTest 000000');
      }

      AppUtils.log({
        'name': name,
        'email': email,
        'phone': phone,
        'countryCode': countryCode,
        'dob': dob,
        'country': country,
        'gender': gender,
        'image': localFileToUrl ?? image,
      });

      final result = await _apiMethod.put(
        authToken: authToken,
        url: Urls.updateProfile,
        body: {
          'name': name,
          'email': email,
          'phone': phone,
          'countryCode': countryCode,
          'dob': dob,
          'gender': gender,
          'country': country,
          'bio': bio,
          'website': webSite,
          'image': localFileToUrl ?? image,
        },
        // multipartFile: multipartFile,
        headers: {},
      );
      AppUtils.log(name);
      AppUtils.log(email);
      AppUtils.log(phone);
      AppUtils.log(dob);
      AppUtils.log(gender);
      AppUtils.log(image);
      AppUtils.log(country);
      AppUtils.log("Profile Update Response: ${result.toJson()}");

      if (result.isSuccess) {
        final updatedProfile = profileData.value.copyWith(
          name: name,
          email: email,
          phone: phone,
          countryCode: countryCode,
          dob: dob,
          country: country,
          gender: gender,
          image: image ?? profileData.value.image,
        );

        profileData.value = updatedProfile;
        Preferences.profile = updatedProfile;

        AppUtils.log("Profile updated successfully.");
        AppUtils.log("Updated Image: ${updatedProfile.image}");
      } else {
        errorMessage.value = "Profile update failed";
        AppUtils.log("Profile update failed!");
      }
    } catch (e) {
      errorMessage.value = "Exception: $e";
      AppUtils.log("Exception during profile update: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchMorePosts() async {
    if (!hasMoreData) return;

    try {
      final response = await _itemRepository.getPostList();

      // <<<<<<< HEAD
      if (response.isSuccess && response.data != null) {
        final newPosts = response.data ?? [];
        // =======
        //       if (response.isSuccess && response.data?.data != null) {
        //         final newPosts = response.data!.data;
        // >>>>>>> 4e74444032fe00d1b74968b3216ab253a048319f

        if (newPosts.isNotEmpty) {
          postList.addAll(newPosts);
        } else {
          _hasMoreData.value = false;
        }
      } else {
        AppUtils.log("Failed to fetch more posts: ${response.error}");
      }
    } catch (e) {
      AppUtils.log("Error fetching more posts: $e");
    }
  }

  Future<void> likeposts(String postId) async {
    // Validate postId before making API call
    if (postId.isEmpty) {
      AppUtils.log("Error: PostId is empty, cannot like post");
      AppUtils.toastError("Unable to like post - invalid post ID");
      return;
    }

    try {
      final response = await _itemRepository.postLike(postId: postId);
      AppUtils.log("Like action for postId: $postId");

      if (response.isSuccess) {
        return;
      } else {
        AppUtils.toastError(response.getError ?? "Failed to like post");
        throw '';
      }
    } catch (e) {
      AppUtils.log("Error in likeposts: $e");
      AppUtils.toastError("Unable to like post");
    }
  }

  /// Enhanced like method that can work with PostData object
  /// and resolve post ID if needed
  Future<void> likePostWithData(PostData postData) async {
    try {
      final resolvedPostId = await resolvePostId(postData);

      if (resolvedPostId == null || resolvedPostId.isEmpty) {
        AppUtils.log("Error: Cannot resolve post ID for like action");
        AppUtils.toastError("Unable to like post - cannot identify post");
        return;
      }

      await likeposts(resolvedPostId);
    } catch (e) {
      AppUtils.log("Error in likePostWithData: $e");
      AppUtils.toastError("Unable to like post");
    }
  }

  Future<void> videoCount(String postId) async {
    final response = await _itemRepository.videoCount(postId: postId);
    AppUtils.log(">>>>>>>>$postId");
    AppUtils.log(">>>>>>>>${response})");

    if (response.isSuccess) {
      for (var i = 0; i < postList.length; i++) {
        if (postId == postList[i].id) {
          postList[i] = response.data!;
          postList.refresh();
        }
      }

      return;
    } else {
      final error = response.getError;
      // AppUtils.toastError(response.getError!);
      if (error != null) {
        // AppUtils.toastError(
        //     error is Exception ? error : Exception('Unknown error'));
      } else {
        AppUtils.toastError(response.getError!);
      }
      throw '';
    }
  }

  Future<CommentsListModel> commentsPost({
    String? postId,
    String? content,
    String? mediaFile,
    String? fileType,
    String? parentId,
    String? replyToUser,
  }) async {
    List<Map<String, dynamic>>? files;

    if (mediaFile.isNotNullEmpty) {
      final path = await _authRepository.uploadPhoto(
        imageFile: File(mediaFile!),
      );
      files ??= [];
      files.add({"file": (path.data ?? []).firstOrNull, "type": fileType});
    }

    final response = await _itemRepository.postcomment(
      postId: postId ?? "",
      content: content,
      files: files,
      parentId: parentId,
      replyToUser: replyToUser,
    );
    AppUtils.log(">>>>>>>>$postId");

    if (response.isSuccess) {
      return response.data!;
    } else {
      final error = response.getError;
      if (error != null) {
        AppUtils.toastError(
          error is Exception ? error : Exception('Unknown error'),
        );
      } else {
        AppUtils.toastError(response.getError!);
      }
      throw '';
    }
  }

  Future removeHomePostComment(String id) async {
    final result = await _itemRepository.deleteComment(postId: id);
    if (result.isSuccess) {
      return;
    } else {
      AppUtils.toastError(result.getError);
      throw '';
    }
  }

  Future<void> comentLists({String? selectedId}) async {
    isLoading.value = true;

    // try {

    final response = await _itemRepository.commentsList(postid: selectedId);

    if (response.isSuccess && response.data != null) {
      AppUtils.log('Fetching comments successful.');

      final newComments = response.data ?? [];

      if (newComments.isNotEmpty) {
        List<CommentsListModel> list = [];
        for (var item in newComments) {
          if (item.parentId != null) {
            final index = list.indexWhere(
              (element) => element.id == item.parentId,
            );
            if (index > -1) {
              CommentsListModel data = list[index];
              List<CommentsListModel> childList = [...(data.child ?? [])];
              childList.add(item);
              list[index] = data.copyWith(child: childList);
            } else {
              list.add(item);
            }
          } else {
            list.add(item);

            //           "postId": "6844c6e7333df0d42544b9a9",
            // flutter: │ 🐛     "perantId": "684814929b8752364e2e9f8b",
            // "_id": "683958e23639c18d1202e381",
          }
        }
        comentslistdata.assignAll(list);
        // comentslistdata.assignAll(newComments);
      }
      comentslistdata.refresh();
    } else {
      comentslistdata.refresh();

      AppUtils.log('Error fetching comments.');
      errorMessage.value =
          "Failed to fetch comments: ${response.error ?? 'Unknown error'}";
    }
    // } catch (e) {
    //   AppUtils.log('Exception occurred while fetching comments: $e');
    //   errorMessage.value = "Error fetching comments: $e";
    // } finally {
    //   isLoading.value = false;
    // }
  }

  Future<void> likedListes({String? selectedId}) async {
    isLoading.value = true;

    try {
      comentslistdata.clear();

      final response = await _itemRepository.likesList(postid: selectedId);

      if (response.isSuccess && response.data != null) {
        AppUtils.log('Fetching likes successful.');

        final newLikes = response.data ?? [];

        if (newLikes.isNotEmpty) {
          comentslistdata.assignAll(newLikes);
        }
        comentslistdata.refresh();
      } else {
        comentslistdata.refresh();

        AppUtils.log('Error fetching likes.');
        errorMessage.value =
            "Failed to fetch Likes: ${response.error ?? 'Unknown error'}";
      }
    } catch (e) {
      AppUtils.log('Exception occurred while fetching likes: $e');
      errorMessage.value = "Error fetching likes: $e";
    } finally {
      isLoading.value = false;
    }
  }
}
