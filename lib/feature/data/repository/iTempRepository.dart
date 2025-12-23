import 'package:sep/feature/data/models/dataModels/home_model/comments_list_model.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/extensions.dart';
import '../../../services/networking/apiMethods.dart';
import '../../domain/respository/templateRepository.dart';
import '../../data/models/dataModels/responseDataModel.dart';
import '../../presentation/controller/auth_Controller/profileCtrl.dart';
import '../models/dataModels/home_model/like_model.dart';
import '../models/dataModels/notification_model/notification_model.dart';
import '../models/dataModels/post_data.dart';
import '../models/dataModels/profile_data/profile_data_model.dart';
import '../models/dataModels/settings_model/contactusnew_model.dart';
import '../models/dataModels/settings_model/faq_item_model.dart';
import '../models/dataModels/settings_model/seemyprofile_model.dart';
import '../models/dataModels/termsConditionModel.dart';

String? get _authToken => Preferences.authToken?.bearer;

class ITempRepository implements TempRepository {
  final IApiMethod _apiMethod = IApiMethod();

  @override
  Future<ResponseData<List<PostData>>> getPostList() async {
    try {
      final id = Preferences.profile?.id;
      // AppUtils.log("userid ::::>>> $id");

      final response = await _apiMethod.get(
        url: Urls.getPostList,
        query: {'userId': id.toString()},
      );

      if (response.data != null) {
        AppUtils.log(response.data!);

        return ResponseData<List<PostData>>(
          isSuccess: true,
          data: List<PostData>.from(
            (response.data?['data'] ?? []).map(
              (json) => PostData.fromJson(json),
            ),
          ),
        );
      } else {
        return ResponseData<List<PostData>>(
          isSuccess: false,
          error: Exception('No data received'),
        );
      }
    } catch (e) {
      return ResponseData<List<PostData>>(
        isSuccess: false,
        exception: Exception(e.toString()),
      );
    }
  }

  @override
  Future<ResponseData<PostData>> getPostById(String postId) async {
    try {
      AppUtils.log('getPostById - Requesting postId: $postId');
      AppUtils.log('getPostById - URL: ${Urls.getPostList}/$postId');

      final response = await _apiMethod.get(
        url:
            '${Urls.getPostList}/$postId', // Assuming the API endpoint for single post
      );

      AppUtils.log('getPostById - Full Response: ${response.data}');
      AppUtils.log('getPostById - Response isSuccess: ${response.isSuccess}');

      if (response.data != null) {
        AppUtils.log('getPostById - Single post response: ${response.data!}');

        final data = response.data?['data'] ?? {};
        AppUtils.log('getPostById - Extracted data: $data');

        final postData = PostData.fromJson(data);
        AppUtils.log('getPostById - PostData ID after parsing: ${postData.id}');

        return ResponseData<PostData>(isSuccess: true, data: postData);
      } else {
        AppUtils.log('getPostById - No data received from API');
        return ResponseData<PostData>(
          isSuccess: false,
          error: Exception('Post not found'),
        );
      }
    } catch (e) {
      AppUtils.log('getPostById - Exception: $e');
      return ResponseData<PostData>(
        isSuccess: false,
        exception: Exception(e.toString()),
      );
    }
  }

  @override
  Future<ResponseData<List<PostData>>> globalList({
    int? limit,
    int? offset,
    String? categoryId,
  }) async {
    String? authToken = Preferences.authToken?.bearer;

    Map<String, String> query = {
      // 'globalList': 'query data list',
      'userId': Preferences.uid ?? '',
      'limit': limit?.toString() ?? '',
      'page': offset?.toString() ?? '',
      'categoryId': categoryId ?? '',
    };

    AppUtils.log(query);

    try {
      AppUtils.log('$baseUrl${'/api/post/postListing'}');
      AppUtils.log(Urls.globalPostList);

      final response = await _apiMethod.get(
        url: Urls.globalPostList,
        query: query,
        authToken: authToken,
      );

      final rawPosts = response.data?['data']?['data'] ?? [];

      // Log first post's options to check backend structure
      if (rawPosts.isNotEmpty) {
        final firstPost = rawPosts[0];
        AppUtils.log("FIRST POST RAW OPTIONS: ${firstPost['options']}");
      }

      final parsedData = List<PostData>.from(
        rawPosts.map((json) => PostData.fromJson(json)),
      );

      // Log parsed options
      if (parsedData.isNotEmpty && parsedData.first.options.isNotEmpty) {
        final firstOption = parsedData.first.options.first;
        AppUtils.log(
          "FIRST PARSED OPTION: id=${firstOption.id}, name=${firstOption.name}",
        );
      }

      return ResponseData<List<PostData>>(isSuccess: true, data: parsedData);
    } catch (e) {
      AppUtils.log('throw issue on ----homeApi.....$e');

      return ResponseData<List<PostData>>(
        isSuccess: false,
        error: Exception(e),
      );
    }
  }

  @override
  Future<ResponseData<List<PostData>>> deletePost(String postId) async {
    try {
      if (postId.isEmpty) {
        return ResponseData<List<PostData>>(
          isSuccess: false,
          error: Exception('Invalid post ID'),
        );
      }
      AppUtils.log("Deleting post with ID: $postId");

      final response = await _apiMethod.delete(
        url: '${Urls.deleteUserPost}?id=$postId',
      );
      AppUtils.log("Delete Post Url ::: ${Urls.deleteUserPost}?id=$postId");

      if (response.data != null) {
        return ResponseData<List<PostData>>(isSuccess: true);
      } else {
        return ResponseData<List<PostData>>(
          isSuccess: false,
          error: Exception('No data received'),
        );
      }
    } catch (e) {
      AppUtils.log("Error deleting post: $e");
      return ResponseData<List<PostData>>(
        isSuccess: false,
        exception: Exception(e.toString()),
      );
    }
  }

  Future<ResponseData<TermsConditionModel>> _fetchTermsData(String type) async {
    final ResponseData<Map<String, dynamic>?> response = await _apiMethod.get(
      url: Urls.termsAndCondition,
      headers: {'Content-Type': 'application/json'},
      query: {'type': type},
    );

    AppUtils.log('API Response for $type: ${response.data}');

    if (response.isSuccess && response.data != null) {
      final termsData = TermsConditionModel.fromJson(response.data!);
      return ResponseData<TermsConditionModel>(
        isSuccess: true,
        data: termsData,
      );
    } else {
      AppUtils.log('Failed to load $type data');
      return ResponseData<TermsConditionModel>(
        isSuccess: false,
        error: Exception('Failed to load $type details'),
      );
    }
  }

  @override
  Future<ResponseData<TermsConditionModel>> getTermsAndCondations() {
    return _fetchTermsData('TermAndCondition');
  }

  @override
  Future<ResponseData<TermsConditionModel>> getPrivacyAndPolicy() {
    return _fetchTermsData('PrivacyPolicy');
  }

  @override
  Future<ResponseData<ContactusnewModel>> contactus({
    required String email,
    required String title,
    required String description,
  }) async {
    String? authToken = Preferences.authToken?.bearer;

    final body = {'email': email, 'title': title, 'description': description};
    final result = await _apiMethod.post(
      url: Urls.contactus,
      body: body,
      headers: {},
      authToken: authToken,
    );

    if (result.isSuccess) {
      final body = result.data ?? {};

      final data = ContactusnewModel.fromJson(body);
      return ResponseData(isSuccess: true, data: data);
    } else {
      return ResponseData(isSuccess: false, error: result.error);
    }
  }

  @override
  Future<ResponseData<Map<String, dynamic>>> feedback({
    required String title,
    required String message,
    String? image,
  }) async {
    try {
      AppUtils.log({
        'title': title,
        'description': message,
        'image': image ?? 'No image provided',
      });

      final result = await _apiMethod.post(
        url: Urls.feedbackk,
        body: {
          'title': title,
          'description': message,
          'image': image ?? 'No image provided',
        },
        headers: {},
      );

      AppUtils.log(result.toJson());

      if (result.isSuccess) {
        return ResponseData(isSuccess: true, data: result.data ?? {});
      } else {
        return ResponseData(isSuccess: false, error: result.getError);
      }
    } catch (e) {
      AppUtils.log("Exception: $e");
      return ResponseData(isSuccess: false);
    }
  }

  @override
  Future<List<FaqItemModel>> frequentaskquestion({
    required String question,
  }) async {
    String? authToken = Preferences.authToken?.bearer;

    final body = {'question': question};

    final response = await _apiMethod.get(
      url: Urls.faq,
      body: body,
      headers: {"Authorization": authToken ?? ""},
    );

    // AppUtils.log(msg)

    if (response.isSuccess && response.data != null) {
      final data = response.data?['data']?['data'] ?? [];

      final list = List<FaqItemModel>.from(
        data.map((json) => FaqItemModel.fromJson(json)),
      );
      return list;

      // final faqModel = FaqModel.fromJson(response.data!);
      // return ResponseData(isSuccess: true, data: faqModel);
    } else {
      AppUtils.toastError(response.error);
      throw '';
      // return ResponseData(isSuccess: false, error: response.error);
    }
  }

  @override
  Future<ResponseData<SeemyprofileModel>> seemyprofile({
    required String seemyprofile,
  }) async {
    String? authToken = Preferences.authToken?.bearer;

    final body = {'seeMyProfile': seemyprofile};
    final ResponseData<Map<String, dynamic>?> response = await _apiMethod.put(
      url: Urls.updateProfile,
      body: body,
      authToken: authToken,
      headers: {},
    );

    if (response.isSuccess) {
      AppUtils.log(response.data);

      final body = response.data ?? {};

      final data = ProfileDataModel.fromJson(body['data'] ?? {});

      Preferences.profile = data;

      // final seemyprofilee = body['data']?['seeMyProfile'];
      // final shareMypostt = body['data']?['shareMyPost'];
      // Preferences.seemypost = seemyprofilee;
      // Preferences.shareMypost = shareMypostt;

      ProfileCtrl.find.profileData.value = data;
      ProfileCtrl.find.profileData.refresh();

      // final data = ContactusnewModel.fromJson(body);
      return ResponseData(isSuccess: true);
    } else {
      return ResponseData(isSuccess: false, error: response.error);
    }
  }

  @override
  Future<ResponseData<SeemyprofileModel>> sharemypost({
    required String sharemypost,
  }) async {
    String? authToken = Preferences.authToken?.bearer;

    final body = {'shareMyPost': sharemypost};
    final ResponseData<Map<String, dynamic>?> response = await _apiMethod.put(
      url: Urls.updateProfile,
      body: body,
      authToken: authToken,
      headers: {},
    );

    if (response.isSuccess) {
      AppUtils.log(response.data);

      final body = response.data ?? {};

      final data = ProfileDataModel.fromJson(body['data'] ?? {});

      Preferences.profile = data;

      ProfileCtrl.find.profileData.value = data;
      ProfileCtrl.find.profileData.refresh();

      return ResponseData(isSuccess: true);
    } else {
      return ResponseData(isSuccess: false, error: response.error);
    }
  }

  @override
  Future<ResponseData<SeemyprofileModel>> notificationallow({
    required bool isNotification,
  }) async {
    String? authToken = Preferences.authToken?.bearer;

    final body = {'isNotification': isNotification};
    final ResponseData<Map<String, dynamic>?> response = await _apiMethod.put(
      url: Urls.updateProfile,
      body: body,
      authToken: authToken,
      headers: {},
    );

    if (response.isSuccess) {
      AppUtils.log(response.data);

      final body = response.data ?? {};
      final data = ProfileDataModel.fromJson(body['data'] ?? {});

      Preferences.profile = data;
      ProfileCtrl.find.profileData.value = data;
      ProfileCtrl.find.profileData.refresh();

      return ResponseData(isSuccess: true);
    } else {
      return ResponseData(isSuccess: false, error: response.error);
    }
  }

  @override
  Future<ResponseData<PostData>> updatePollAction(
    String optionId,
    String postId,
  ) async {
    AppUtils.log(
      "updatePollAction called - postId: $postId, optionId: $optionId",
    );

    final body = {"userId": Preferences.uid, "optionId": optionId};

    AppUtils.log("Request body: $body");
    AppUtils.log("Request URL: ${Urls.updatePollAction}/$postId");

    final result = await _apiMethod.post(
      url: '${Urls.updatePollAction}/$postId',
      body: body,
      headers: {},
      authToken: _authToken,
    );

    if (result.isSuccess) {
      AppUtils.log("updatePollAction SUCCESS - Full response:");
      AppUtils.log(result.data);

      final data = result.data?['data'];

      if (data == null) {
        AppUtils.log("ERROR: Backend returned null 'data' field");
        return ResponseData(
          isSuccess: false,
          error: Exception("Backend returned null data for poll vote"),
        );
      }

      AppUtils.log("Parsing PostData from response...");
      AppUtils.log("RAW OPTIONS DATA from backend: ${data['options']}");

      try {
        final postData = PostData.fromJson(data);
        AppUtils.log("PostData parsed successfully - ID: ${postData.id}");
        AppUtils.log("Options count: ${postData.options.length}");

        // Log each option's ID
        for (var i = 0; i < postData.options.length; i++) {
          final opt = postData.options[i];
          AppUtils.log(
            "Option[$i]: id=${opt.id}, name=${opt.name}, voteCount=${opt.voteCount}",
          );
        }

        return ResponseData(isSuccess: true, data: postData);
      } catch (e) {
        AppUtils.log("ERROR parsing PostData: $e");
        return ResponseData(
          isSuccess: false,
          error: Exception("Failed to parse poll response: $e"),
        );
      }
    } else {
      AppUtils.log("updatePollAction FAILED - Error: ${result.getError}");
      return ResponseData(isSuccess: false, error: result.getError);
    }
  }

  @override
  Future<ResponseData<LikeModel>> postLike({required String postId}) async {
    String? authToken = Preferences.authToken?.bearer;

    final body = {
      'postId': postId,
      'userId':
          Preferences.uid ??
          '', // Pass userId so backend can include postId in notification
    };

    AppUtils.log(
      'Liking post with postId: $postId, userId: ${Preferences.uid}',
    );

    final ResponseData<Map<String, dynamic>?> response = await _apiMethod.post(
      url: Urls.likepost,
      body: body,
      authToken: authToken,
      headers: {},
    );

    if (response.isSuccess) {
      AppUtils.log('like console.....');
      AppUtils.log(response.data);

      return ResponseData(isSuccess: true);
    } else {
      return ResponseData(isSuccess: false, error: response.error);
    }
  }

  @override
  Future<ResponseData<PostData>> videoCount({required String postId}) async {
    String? authToken = Preferences.authToken?.bearer;

    final body = {'id': postId};
    final ResponseData<Map<String, dynamic>?> response = await _apiMethod.get(
      url: Urls.videoCount,
      body: {},
      query: body,
      authToken: authToken,
      headers: {},
    );

    if (response.isSuccess) {
      AppUtils.log('video count console.....');
      AppUtils.log(response.data);

      final data = response.data?['data'] ?? {};
      // final data = ProfileDataModel.fromJson(body['data'] ?? {});

      // Preferences.profile = data;
      // ProfileCtrl.find.profileData.value = data;
      // ProfileCtrl.find.profileData.refresh();

      return ResponseData(isSuccess: true, data: PostData.fromJson(data));
    } else {
      return ResponseData(isSuccess: false, error: response.getError);
    }
  }

  @override
  Future<ResponseData<CommentsListModel>> postcomment({
    required String postId,
    required String? content,
    List<Map<String, dynamic>>? files,
    String? parentId,
    String? replyToUser,
  }) async {
    String? authToken = Preferences.authToken?.bearer;

    final body = {
      'postId': postId,
      'content': content,
      'files': files,
      'perantId': parentId,
      'replyUser': replyToUser,
      'userId':
          Preferences.uid ??
          '', // Pass userId so backend can include postId & commentId in notification
    };

    AppUtils.log(body);
    final ResponseData<Map<String, dynamic>?> response = await _apiMethod.post(
      url: Urls.commentpost,
      body: body,
      authToken: authToken,
      headers: {},
    );

    if (response.isSuccess) {
      AppUtils.log('on Comment addd......');
      AppUtils.log(response.data);
      final comment = response.data?['data'] ?? {};
      final data = CommentsListModel.fromJson(comment);

      // List<CommentsListModel>.from(list.map((json)=> CommentsListModel.fromJson(json)));
      //
      // final body = response.data ?? {};
      // final data = ProfileDataModel.fromJson(body['data'] ?? {});
      //
      // Preferences.profile = data;
      // ProfileCtrl.find.profileData.value = data;
      // ProfileCtrl.find.profileData.refresh();

      return ResponseData(isSuccess: true, data: data);
    } else {
      return ResponseData(isSuccess: false, error: response.error);
    }
  }

  @override
  Future<ResponseData> deleteComment({required String postId}) async {
    String? authToken = Preferences.authToken?.bearer;

    final query = {'id': postId};
    final ResponseData<Map<String, dynamic>?> response = await _apiMethod
        .delete(url: Urls.commentpost, authToken: authToken, query: query);

    if (response.isSuccess) {
      AppUtils.log(response.data);

      // final body = response.data ?? {};
      // final data = ProfileDataModel.fromJson(body['data'] ?? {});
      //
      // Preferences.profile = data;
      // ProfileCtrl.find.profileData.value = data;
      // ProfileCtrl.find.profileData.refresh();

      return ResponseData(isSuccess: true);
    } else {
      return ResponseData(isSuccess: false, error: response.error);
    }
  }

  @override
  Future<ResponseData<List<CommentsListModel>>> commentsList({
    String? postid,
    int page = 1,
    int limit = 10,
  }) async {
    String? authToken = Preferences.authToken?.bearer;

    Map<String, String> query = {
      'postId': postid.toString(),
      'page': page.toString(),
      'limit': limit.toString(),
    };

    AppUtils.log(query);

    try {
      final response = await _apiMethod.get(
        url: Urls.commentslists,
        query: query,
        authToken: authToken,
      );

      if (response.isSuccess) {
        final parsedData = List<CommentsListModel>.from(
          (response.data?['data']?['comments'] ?? []).map(
            (json) => CommentsListModel.fromJson(json),
          ),
        );

        return ResponseData<List<CommentsListModel>>(
          isSuccess: true,
          data: parsedData,
        );
      } else {
        return ResponseData<List<CommentsListModel>>(
          isSuccess: false,
          error: response.getError,
        );
      }
    } catch (e) {
      return ResponseData<List<CommentsListModel>>(
        isSuccess: false,
        error: Exception(e),
      );
    }
  }

  @override
  Future<ResponseData<List<CommentsListModel>>> likesList({
    String? postid,
  }) async {
    String? authToken = Preferences.authToken?.bearer;

    Map<String, String> query = {'postId': postid.toString()};

    AppUtils.log(query);

    try {
      AppUtils.log('$baseUrl${'/api/likeComment/getLikeList'}');
      AppUtils.log(Urls.likeslists);

      final response = await _apiMethod.get(
        url: Urls.likeslists,
        query: query,
        authToken: authToken,
      );

      final parsedData = List<CommentsListModel>.from(
        (response.data?['data']?['comments'] ?? []).map(
          (json) => CommentsListModel.fromJson(json),
        ),
      );

      return ResponseData<List<CommentsListModel>>(
        isSuccess: true,
        data: parsedData,
      );
    } catch (e) {
      AppUtils.log('throw issue on ----homeApi.....$e');

      return ResponseData<List<CommentsListModel>>(
        isSuccess: false,
        error: Exception(e),
      );
    }
  }

  @override
  Future<ResponseData<PostData>> getSinglePost(String postId) async {
    try {
      AppUtils.log('getSinglePost - Requesting postId: $postId');
      AppUtils.log('getSinglePost - URL: ${Urls.deleteUserPost}');
      AppUtils.log('getSinglePost - Current userId: ${Preferences.uid}');

      final response = await _apiMethod.get(
        url: Urls.deleteUserPost,
        query: {
          'id': postId,
          'userId':
              ?Preferences.uid, // Include userId to get isLikedByUser status
        },
      );

      AppUtils.log('getSinglePost - Full Response: ${response.data}');
      AppUtils.log('getSinglePost - Response isSuccess: ${response.isSuccess}');

      if (response.isSuccess) {
        final data = response.data?['data'] ?? {};
        AppUtils.log('getSinglePost - Extracted data: $data');

        final postData = PostData.fromJson(data);
        AppUtils.log(
          'getSinglePost - PostData ID after parsing: ${postData.id}',
        );
        AppUtils.log(
          'getSinglePost - isLikedByUser from API: ${postData.isLikedByUser}',
        );
        AppUtils.log(
          'getSinglePost - Likes array length: ${postData.likes?.length ?? 0}',
        );

        // Check if current user has liked the post by scanning likes array
        bool isLikedByCurrentUser = false;
        if (postData.likes != null && postData.likes!.isNotEmpty) {
          isLikedByCurrentUser = postData.likes!.any((like) {
            if (like is Map) {
              final userId = like['userId'] ?? like['_id'];
              AppUtils.log('  - Checking like (Map): $userId');
              return userId == Preferences.uid;
            } else if (like is String) {
              AppUtils.log('  - Checking like (String): $like');
              return like == Preferences.uid;
            }
            return false;
          });
        }

        AppUtils.log(
          'getSinglePost - ✅ Checked likes array - isLikedByCurrentUser: $isLikedByCurrentUser',
        );

        // Update postData with correct isLikedByUser status
        final updatedPostData = postData.copyWith(
          isLikedByUser: isLikedByCurrentUser,
        );

        return ResponseData<PostData>(isSuccess: true, data: updatedPostData);
      } else {
        AppUtils.log('getSinglePost - API call failed: ${response.getError}');
        return ResponseData<PostData>(
          isSuccess: false,
          error: response.getError,
        );
      }
    } catch (e) {
      AppUtils.log('getSinglePost - Exception: $e');
      return ResponseData<PostData>(isSuccess: false, error: Exception(e));
    }
  }

  @override
  Future<ResponseData<List<PostData>>> getMyProfilePosts({
    String? userId,
    required String postType,
    required String? fileType,
    required int pageNo,
  }) async {
    // try{
    final Map<String, String> queryParams = {
      ...(userId.isNotNullEmpty ? {'userId': userId!} : {}),
      'fileType': postType,
      ...(fileType.isNotNullEmpty ? {'type': fileType!} : {}),
      'limit': '100',
      'page': '$pageNo',

      // 'fileType':'poll'
      // 'type':'image',
      // 'limit':100,
      // /api/post/getProfileData?type=image&limit=100&fileType=poll
    };

    AppUtils.log('📡 API Call - ${Urls.profileData}');
    AppUtils.log('   Query Params: $queryParams');

    final response = await _apiMethod.get(
      url: Urls.profileData,
      query: queryParams,
      authToken: Preferences.authToken.bearer,
    );

    if (response.isSuccess) {
      final data = response.data?['data']?['posts'] ?? [];
      AppUtils.log('   ✅ API Response Success: ${data.length} posts returned');

      // Log first few posts details
      for (var i = 0; i < (data.length > 3 ? 3 : data.length); i++) {
        final post = data[i];
        AppUtils.log(
          '      Post #${i + 1}: id=${post['_id']}, fileType=${post['fileType']}, files=${post['files']?.length ?? 0}',
        );
      }

      return ResponseData<List<PostData>>(
        isSuccess: true,
        data: List<PostData>.from(data.map((json) => PostData.fromJson(json))),
        // PostData.fromJson(data)
      );
    } else {
      AppUtils.log('   ❌ API Response Failed: ${response.getError}');
      return ResponseData<List<PostData>>(
        isSuccess: false,
        error: response.getError,
      );
    }
    // }catch(e){
    //   return ResponseData<List<PostData>>(
    //     isSuccess: false,
    //     error: Exception(e),
    //   );
    // }
  }

  @override
  Future<ResponseData<Map<String, dynamic>>> searchUsers({
    required String searchQuery,
    int page = 1,
    int limit = 10,
  }) async {
    String? authToken = Preferences.authToken!.bearer;

    try {
      final response = await _apiMethod.get(
        url: Urls.searchUser,
        authToken: authToken,
        query: {
          'search': searchQuery,
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      AppUtils.log(
        "Search API response: ${response.isSuccess ? 'Success' : 'Failed'}",
      );
      AppUtils.log("Search API data: ${response.data}");
      AppUtils.log("Search API error: ${response.error}");

      return response;
    } catch (e) {
      AppUtils.log('Search exception: $e');
      return ResponseData(
        isSuccess: false,
        error: Exception('Search failed due to an exception: $e'),
      );
    }
  }

  @override
  Future<ResponseData<Map<String, dynamic>>> getPollList({
    required String type,
    int page = 1,
    int limit = 5,
  }) async {
    String? authToken = Preferences.authToken!.bearer;

    try {
      final response = await _apiMethod.get(
        url: Urls.getPollList,
        authToken: authToken,
        query: {
          'type': type,
          'page': page.toString(),
          'limit': limit.toString(),
          "userId": Preferences.uid ?? "",
        },
      );

      AppUtils.log(
        "getpost API response: ${response.isSuccess ? 'Success' : 'Failed'}",
      );
      AppUtils.log("getpost API data: ${response.data}");
      AppUtils.log("getpost API error: ${response.error}");

      return response;
    } catch (e) {
      AppUtils.log('Search exception: $e');
      return ResponseData(
        isSuccess: false,
        error: Exception('Search failed due to an exception: $e'),
      );
    }
  }

  @override
  Future<List<NotificationItem>> notification({
    int page = 1,
    int limit = 10,
  }) async {
    String? authToken = Preferences.authToken?.bearer;

    AppUtils.log(authToken);

    final response = await _apiMethod.get(
      url: Urls.notification,
      headers: {"Authorization": authToken ?? ""},
      query: {'page': page.toString(), 'limit': limit.toString()},
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data?['data']['notifications'] ?? [];

      AppUtils.log("Notification list raw data: $data");

      final list = List<NotificationItem>.from(
        data.map((json) => NotificationItem.fromJson(json)),
      );

      // Log each notification's postId
      for (var i = 0; i < list.length; i++) {
        final notif = list[i];
        AppUtils.log(
          "Notification[$i]: type=${notif.notificationType}, postId=${notif.postId}, title=${notif.title}",
        );
      }

      return list;
    }

    return [];
  }
}
