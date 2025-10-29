import 'dart:io';
import '../../data/models/dataModels/Createpost/getcategory_model.dart';
import '../../data/models/dataModels/auth_models/emailvalid_model.dart';
import '../../data/models/dataModels/auth_models/forgetpassword_model.dart';
import '../../data/models/dataModels/auth_models/login_model.dart';
import '../../data/models/dataModels/auth_models/sociallogin_model.dart'
    as social_login;
import '../../data/models/dataModels/otpDataModel.dart';
import '../../data/models/dataModels/poll_item_model/poll_item_model.dart';
import '../../data/models/dataModels/profile_data/profile_data_model.dart';
import '../../data/models/dataModels/resendOtpModel.dart';
import '../../data/models/dataModels/responseDataModel.dart';
import '../../data/models/dataModels/termsConditionModel.dart';

abstract class AuthRepository {
  Future<ResponseData<LoginModel>> loginUser({
    required String email,
    required String password,
  });
  Future<ResponseData<EmailvalidModel>> emailvalidation({
    required String email,
  });

  Future<ResponseData<Map<String, dynamic>>> post({
    required String url,
    Map<String, dynamic>? data,
    Map<String, String>? header,
    bool enableAuthToken = false,
  });

  Future<ResponseData<List<ProfileDataModel>>> getFollowersList({
    required String type,
    String? userId,
  });

  Future<ResponseData<ProfileDataModel?>> removeFollower({
    required String userId,
  });

  Future<ResponseData<Map<String, dynamic>>> registerUser({
    required String name,
    required String email,
    required String phone,
    required String countryCode,
    required String password,
    required String dob,
    required String gender,
    required String image,
    required String bio,
    required String country,
    required String webSite,
  });

  Future<ResponseData<ForgetpasswordModel>> forgotPassword({
    required String email,
  });

  Future<ResponseData<social_login.SocialloginModel>> socialLogin({
    String? name,
    String? email,
    String? socialId,
    String? socialType,
    bool? type,
  });

  Future<ResponseData<Map<String, dynamic>>> otpVerify({
    required String email,
    required String otp,
  });

  Future<ResponseData<ProfileDataModel>> getProfileDetails();

  Future<ResponseData<Map<String, dynamic>>> changePasswordProfile({
    required String oldpassword,
    required String newpassword,
  });

  Future<ResponseData<GetcategoryModel>> createpostcategory();

  Future<ResponseData<Map<String, dynamic>>> CreatePost({
    required String userId,
    required String categoryId,
    required String content,
    required String? address,
    required Map<String, dynamic>? location,
    required List<Map<String, dynamic>>? uploadedFileUrls,
    required String fileType,
    required List<PollItemModel>? pollOptions,
    required String? startTime,
    required String? endTime,
    required String? duration,
  });

  Future<ResponseData<Map<String, dynamic>>> removePost({
    required String postId,
  });

  // Future<ResponseData<Map<String, dynamic>>> editPost({
  //   required String postId,
  //   required String userId,
  //   required String categoryId,
  //   required String content,
  //   required String? address,
  //   required Map<String, dynamic>? location,
  //   required List<String>? uploadedFileUrls,
  //   required String fileType,
  //   required List<PollItemModel>? pollOptions,
  //   required String? startTime,
  //   required String? endTime,
  //   required String? duration,
  // });

  Future<ResponseData<TermsConditionModel>> getTermsAndCondations();

  Future<ResponseData<TermsConditionModel>> getPrivacyAndPolicy();

  Future<ResponseData<Map<String, dynamic>>> getUserAgoraToken({
    required String channelName,
    required String uid,
    bool isPublisher = false,
  });

  Future<ResponseData<ResendOtpModel>> resetPass({
    required String email,
    required String id,
    required String otp,
    required String newPassword,
  });

  Future<ResponseData<OtpDataModel>> emailOtpVerify({
    required String id,
    required String otp,
  });

  Future<ResponseData<Map<String, dynamic>>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<ResponseData<Map<String, dynamic>>> logout();

  Future<ResponseData<Map<String, dynamic>>> profileUpdate({
    required String name,
    required String email,
    String? phone,
    String? dob,
    String? gender,
    String? image,

    String? accessToken,
  });

  Future<ResponseData> deleteAccount();

  Future<ResponseData<List<String>>> uploadPhoto({required File imageFile});

  Future<ResponseData<bool>> followUnfollowUserRequest({
    required String followUserId,
  });
  Future<ResponseData<bool>> blockUnblockUserRequest({
    required String blockUserId,
  });
  Future<ResponseData<List<ProfileDataModel>>> getBlockedUserList();
  Future<ResponseData<bool>> reportUserRequest({
    required String id,
    required String title,
    String? message,
  });
  Future<ResponseData<bool>> reportPostRequest({
    required String postId,
    required String title,
    String? message,
  });

  Future<ResponseData<Map<String, dynamic>>> createMoneyWalletTransaction({
    required String sendTo,
    required String amount,
  });

  Future<ResponseData<Map<String, dynamic>>> purchaseTokens({
    required String userId,
    required double amount,
  });

  // Future<List<String>> uploadMultipleImages(List<File> images);
}
