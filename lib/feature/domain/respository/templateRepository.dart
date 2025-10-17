import 'package:sep/feature/data/models/dataModels/home_model/comment_model.dart';
import 'package:sep/feature/data/models/dataModels/settings_model/faq_item_model.dart';

import '../../data/models/dataModels/GeTListDataModel.dart';
import '../../data/models/dataModels/GetlistModel.dart';
import '../../data/models/dataModels/get_templateInfo_model.dart';
import '../../data/models/dataModels/home_model/comments_list_model.dart';
import '../../data/models/dataModels/home_model/like_model.dart';
import '../../data/models/dataModels/notification_model/notification_model.dart';
import '../../data/models/dataModels/pdfModel.dart';
// <<<<<<< HEAD
import '../../data/models/dataModels/post_data.dart';
// =======
// >>>>>>> 4e74444032fe00d1b74968b3216ab253a048319f
import '../../data/models/dataModels/responseDataModel.dart';
import '../../data/models/dataModels/settings_model/contactusnew_model.dart';
import '../../data/models/dataModels/settings_model/faq_model.dart';
import '../../data/models/dataModels/settings_model/seemyprofile_model.dart';
import '../../data/models/dataModels/termsConditionModel.dart';

abstract class TempRepository {
  Future<ResponseData<List<PostData>>> getPostList();
  Future<ResponseData<PostData>> getPostById(String postId);
  Future<ResponseData<List<PostData>>> getMyProfilePosts({
    String? userId,
    required String postType,
    required String? fileType,
    required int pageNo,
  });

  Future<ResponseData<Map<String, dynamic>>> searchUsers({
    required String searchQuery,
    int page = 1,
    int limit = 10,
  });

  Future<ResponseData<Map<String, dynamic>>> getPollList({
    required String type,
    int page = 1,
    int limit = 5,
  });

  Future<ResponseData<List<PostData>>> globalList({
    int? limit,
    int? offset,
    String? categoryId,
  });
  Future<ResponseData<PostData>> updatePollAction(
    String optionId,
    String postId,
  );

  Future<ResponseData<LikeModel>> postLike({required String postId});

  Future<ResponseData<PostData>> videoCount({required String postId});

  Future<ResponseData<CommentsListModel>> postcomment({
    required String postId,
    required String? content,
    List<Map<String, dynamic>>? files,
    String? parentId,
    String? replyToUser,
  });
  Future<ResponseData> deleteComment({required String postId});

  Future<ResponseData<List<CommentsListModel>>> commentsList({String? postid});

  Future<ResponseData<List<CommentsListModel>>> likesList({String? postid});

  Future<ResponseData<List<PostData>>> deletePost(String postId);

  Future<ResponseData<PostData>> getSinglePost(String postId);

  Future<ResponseData<TermsConditionModel>> getTermsAndCondations();

  Future<ResponseData<TermsConditionModel>> getPrivacyAndPolicy();
  Future<ResponseData<ContactusnewModel>> contactus({
    required String email,
    required String title,
    required String description,
  });

  Future<ResponseData<Map<String, dynamic>>> feedback({
    required String title,
    required String message,
    String? image,
  });

  Future<List<FaqItemModel>> frequentaskquestion({required String question});

  Future<List<NotificationItem>> notification({required int page});

  Future<ResponseData<SeemyprofileModel>> seemyprofile({
    required String seemyprofile,
  });

  Future<ResponseData<SeemyprofileModel>> sharemypost({
    required String sharemypost,
  });

  Future<ResponseData<SeemyprofileModel>> notificationallow({
    required bool isNotification,
  });
}
