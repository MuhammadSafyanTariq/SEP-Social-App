import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:sep/feature/data/models/dataModels/profile_data/profile_data_model.dart';
import 'package:sep/utils/extensions/dateTimeUtils.dart';
import 'package:sep/utils/extensions/extensions.dart';
import '../../../services/networking/apiMethods.dart';
import '../../../services/networking/urls.dart';
import '../../../services/storage/preferences.dart';
import '../../../utils/appUtils.dart';
import '../../domain/respository/authRepository.dart';
import '../../presentation/controller/auth_Controller/profileCtrl.dart';
import '../global_state.dart';
import '../models/dataModels/Createpost/getcategory_model.dart';
import '../models/dataModels/auth_models/emailvalid_model.dart';
import '../models/dataModels/auth_models/forgetpassword_model.dart';
import '../models/dataModels/auth_models/login_model.dart';
import '../models/dataModels/auth_models/sociallogin_model.dart'
    as social_login;
import '../models/dataModels/otpDataModel.dart';
import '../models/dataModels/poll_item_model/poll_item_model.dart';
import '../models/dataModels/resendOtpModel.dart';
import '../models/dataModels/responseDataModel.dart';
import '../models/dataModels/termsConditionModel.dart';

class IAuthRepository implements AuthRepository {
  final IApiMethod _apiMethod = IApiMethod();

  @override
  Future<ResponseData<EmailvalidModel>> emailvalidation({
    required String email,
  }) async {
    final body = {'email': email};
    final result = await _apiMethod.post(
      url: Urls.emailvalid,
      body: body,
      headers: {},
    );

    if (result.isSuccess) {
      final body = result.data ?? {};
      final data = EmailvalidModel.fromJson(body);
      return ResponseData(isSuccess: true, data: data);
    } else {
      return ResponseData(isSuccess: false, error: result.error);
    }
  }

  @override
  Future<ResponseData<LoginModel>> loginUser({
    required String email,
    required String password,
  }) async {
    AppUtils.log("🔐 iAuthRepository.loginUser() called");

    final body = {
      'email': email,
      'password': password,
      'deviceToken': Preferences.fcmToken,
      'deviceType': AppUtils.deviceType,
    };

    AppUtils.log("📤 Login Request Body:");
    AppUtils.log("  - Email: $email");
    AppUtils.log(
      "  - Password: ${password.isNotEmpty ? '[PROVIDED]' : '[EMPTY]'}",
    );
    AppUtils.log("  - DeviceToken: ${Preferences.fcmToken ?? '[NULL]'}");
    AppUtils.log("  - DeviceType: ${AppUtils.deviceType}");
    AppUtils.log("📡 API URL: ${Urls.login}");
    AppUtils.log("📡 Full URL: $baseUrl${Urls.login}");

    try {
      AppUtils.log("🚀 Sending POST request...");
      final result = await _apiMethod.post(
        url: Urls.login,
        body: body,
        headers: {},
      );

      AppUtils.log("📥 API Response received");
      AppUtils.log("✅ Response isSuccess: ${result.isSuccess}");
      AppUtils.log("📦 Response data type: ${result.data.runtimeType}");
      AppUtils.log("📦 Response data: ${result.data}");
      AppUtils.log("❌ Response error: ${result.error}");

      if (result.isSuccess) {
        final body = result.data ?? {};

        AppUtils.log("✅ Login API call successful");
        AppUtils.log("📦 Response body keys: ${body.keys}");
        AppUtils.log("👤 User data: ${body['data']?['user']}");
        AppUtils.log("🔑 Token: ${body['data']?['token']}");

        _onLoginSuccess(body['data']?['user'], body['data']?['token']);

        final data = LoginModel.fromJson(body);
        AppUtils.log("✅ LoginModel created successfully");
        AppUtils.log("📦 LoginModel data: ${data.toJson()}");

        return ResponseData(isSuccess: true, data: data);
      } else {
        AppUtils.log("❌ Login API call failed");
        AppUtils.log("❌ Error: ${result.getError}");
        AppUtils.log("❌ Status code: ${result.statusCode}");
        return ResponseData(isSuccess: false, error: result.getError);
      }
    } catch (e, stackTrace) {
      AppUtils.log("❌ Exception in loginUser: $e");
      AppUtils.log("❌ Stack trace: $stackTrace");
      return ResponseData(
        isSuccess: false,
        error: Exception('Login request failed: $e'),
      );
    }
  }

  // void _onLoginSuccess(Map<String, dynamic> body) {
  //   final profile = body['data']?['user'] ?? {};
  //   final userid = body['data']?['user']['_id'] ?? {};
  //
  //   final token = body['data']?['token'];
  //   Preferences.profile = ProfileDataModel.fromJson(profile);
  //   Preferences.authToken = token;
  //   Preferences.uid = userid;
  //   AppUtils.log(
  //       "USerId>>>>>>>>>>>>>>><><><><><><><><>><><><><><><><><>$userid");
  //   Preferences.savePrefOnLogin = Preferences.profile;
  // }

  void _onLoginSuccess(Map<String, dynamic> profile, String? accessToken) {
    AppUtils.log("💾 _onLoginSuccess() called");
    AppUtils.log("👤 Profile data: $profile");
    AppUtils.log("🔑 Access token: ${accessToken ?? '[NULL]'}");

    // final profile = body['data']?['user'] ?? {};
    final userid = profile['_id'];
    AppUtils.log("🆔 User ID extracted: $userid");

    // body['data']?['user']['_id'] ?? {};

    // final token = body['data']?['token'];
    final token = accessToken;

    try {
      AppUtils.log("📝 Creating ProfileDataModel from JSON...");
      Preferences.profile = ProfileDataModel.fromJson(profile);
      AppUtils.log("✅ ProfileDataModel created successfully");

      AppUtils.log("💾 Saving auth token...");
      Preferences.authToken = token;
      AppUtils.log("✅ Auth token saved: ${Preferences.authToken}");

      AppUtils.log("💾 Saving user ID...");
      Preferences.uid = userid;
      AppUtils.log("✅ User ID saved: ${Preferences.uid}");

      AppUtils.log("💾 Saving preferences on login...");
      Preferences.savePrefOnLogin = Preferences.profile;
      AppUtils.log("✅ Login preferences saved successfully");

      AppUtils.log(
        "🎉 LOGIN SUCCESS - User: ${Preferences.profile?.name}, ID: $userid",
      );
    } catch (e, stackTrace) {
      AppUtils.log("❌ Error in _onLoginSuccess: $e");
      AppUtils.log("❌ Stack trace: $stackTrace");
      rethrow;
    }
  }

  void updatePreferences(Map<String, dynamic> profile, String? accessToken) =>
      _onLoginSuccess(profile, accessToken);

  Future<ResponseData<Map<String, dynamic>>> registerUser({
    required String name,
    required String email,
    required String phone,
    required String countryCode,
    required String password,
    required String dob,
    required String gender,
    required String? image,
    required String bio,
    required String country,
    required String webSite,
  }) async {
    try {
      AppUtils.log("🔧 Repository registerUser called");
      AppUtils.log("🔧 Checking null values before API call:");
      AppUtils.log("  - name: ${name} (${name.runtimeType})");
      AppUtils.log("  - email: ${email} (${email.runtimeType})");
      AppUtils.log("  - phone: ${phone} (${phone.runtimeType})");
      AppUtils.log(
        "  - countryCode: ${countryCode} (${countryCode.runtimeType})",
      );
      AppUtils.log("  - dob: ${dob} (${dob.runtimeType})");
      AppUtils.log("  - gender: ${gender} (${gender.runtimeType})");
      AppUtils.log("  - country: ${country} (${country.runtimeType})");
      AppUtils.log("  - image: ${image} (${image.runtimeType})");
      AppUtils.log("  - bio: ${bio} (${bio.runtimeType})");
      AppUtils.log("  - webSite: ${webSite} (${webSite.runtimeType})");
      AppUtils.log(
        "  - fcmToken: ${Preferences.fcmToken} (${Preferences.fcmToken.runtimeType})",
      );
      AppUtils.log(
        "  - deviceType: ${AppUtils.deviceType} (${AppUtils.deviceType.runtimeType})",
      );

      AppUtils.log("🚀 Making API call to: ${Urls.register}");

      final requestBody = {
        'name': name,
        'email': email,
        'phone': phone,
        'countryCode': countryCode,
        'password': password,
        'dob': dob,
        'gender': gender,
        'country': country,
        'image': image ?? '',
        'bio': bio,
        'website': webSite,
        'deviceToken': Preferences.fcmToken ?? '',
        'deviceType': AppUtils.deviceType,
      };

      AppUtils.log("📤 Final request body: $requestBody");

      final result = await _apiMethod.post(
        url: Urls.register,
        body: requestBody,
        headers: {},
      );

      AppUtils.log("📥 API Response received:");
      AppUtils.log("  - result type: ${result.runtimeType}");
      AppUtils.log("  - result.isSuccess: ${result.isSuccess}");
      AppUtils.log("  - result.data type: ${result.data.runtimeType}");
      AppUtils.log("  - result.data: ${result.data}");

      if (result.isSuccess) {
        AppUtils.log("✅ API call successful, processing response...");

        // Safe null checking
        if (result.data == null) {
          AppUtils.log("❌ result.data is null");
          return ResponseData(
            isSuccess: false,
            error: Exception("API response data is null"),
          );
        }

        final resultData = result.data!['data'];
        if (resultData == null) {
          AppUtils.log("❌ result.data['data'] is null");
          return ResponseData(
            isSuccess: false,
            error: Exception("API response data['data'] is null"),
          );
        }

        final userJson = resultData['user'];
        final token = resultData['token'];
        final userId = userJson?['_id'];

        AppUtils.log("🔍 Extracted values:");
        AppUtils.log("  - userJson: ${userJson} (${userJson.runtimeType})");
        AppUtils.log("  - token: ${token} (${token.runtimeType})");
        AppUtils.log("  - userId: ${userId} (${userId.runtimeType})");

        if (userJson != null && token != null) {
          AppUtils.log("✅ Creating profile model...");
          final profile = ProfileDataModel.fromJson(userJson);

          AppUtils.log("✅ Setting preferences...");
          Preferences.profile = profile;
          Preferences.authToken = token;
          Preferences.uid = userId;

          AppUtils.log("✅ Registration completed successfully!");
          return ResponseData(isSuccess: true, data: result.data!);
        } else {
          AppUtils.log("❌ Missing userJson or token");
          return ResponseData(
            isSuccess: false,
            error: Exception("Invalid user data - missing user or token"),
          );
        }
      } else {
        AppUtils.log("❌ API call failed");
        AppUtils.log("❌ Error: ${result.error}");
        return ResponseData(isSuccess: false, error: result.getError);
      }
    } catch (e) {
      AppUtils.log("❌ Exception in registerUser: $e");
      AppUtils.log("❌ Exception type: ${e.runtimeType}");
      AppUtils.log("❌ Stack trace: ${StackTrace.current}");
      return ResponseData(
        isSuccess: false,
        error: Exception("Registration failed: $e"),
      );
    }
  }

  @override
  Future<ResponseData<ForgetpasswordModel>> forgotPassword({
    required String email,
  }) async {
    final body = {'email': email};

    final response = await _apiMethod.post(
      url: Urls.forgotPassword,
      body: body,
      headers: {},
    );
    if (response.isSuccess) {
      return ResponseData(
        isSuccess: true,
        data: ForgetpasswordModel.fromJson(response.data ?? {}),
      );
    } else {
      return ResponseData(isSuccess: false, error: response.error);
    }
  }

  @override
  Future<ResponseData<social_login.SocialloginModel>> socialLogin({
    String? name,
    String? email,
    String? socialId,
    String? socialType,
    bool? type = false,
  }) async {
    final body = {
      'name': name,
      'email': email,
      'socialId': socialId,
      'socialType': socialType,
      'deviceToken': Preferences.fcmToken,
    };

    final response = await _apiMethod.post(
      url: Urls.googleSocialLogin,
      body: body,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    AppUtils.log(">>>>>>>>>>>>>>>>>>>>$response");

    if (response.isSuccess) {
      final responseBody = response.data ?? {};

      // Check if response has the wrapped structure { data: { user: {...}, token: "..." } }
      // or if it's a direct user object
      if (responseBody.containsKey('data') && responseBody['data'] is Map) {
        // Wrapped response format
        _onLoginSuccess(
          responseBody['data']?['user'],
          responseBody['data']?['token'],
        );
        final data = social_login.SocialloginModel.fromJson(responseBody);
        return ResponseData(isSuccess: true, data: data);
      } else if (responseBody.containsKey('_id')) {
        // Direct user object response format
        // Wrap it in the expected structure
        final userData = ProfileDataModel.fromJson(responseBody);
        _onLoginSuccess(responseBody, null); // No token in direct response

        final wrappedData = social_login.SocialloginModel(
          status: true,
          code: 200,
          message: 'Login successful',
          data: social_login.Data(user: userData, token: null),
        );
        return ResponseData(isSuccess: true, data: wrappedData);
      } else {
        // Try to parse as wrapped format anyway
        final data = social_login.SocialloginModel.fromJson(responseBody);
        _onLoginSuccess(
          responseBody['data']?['user'],
          responseBody['data']?['token'],
        );
        return ResponseData(isSuccess: true, data: data);
      }
    } else {
      return ResponseData(isSuccess: false, error: response.error);
    }
  }

  @override
  Future<ResponseData<ProfileDataModel>> getProfileDetails() async {
    String? authToken = Preferences.authToken?.bearer;

    AppUtils.log('Auth Token: $authToken');

    try {
      final ResponseData<Map<String, dynamic>> response = await _apiMethod.get(
        url: Urls.getUserDetails,
        authToken: authToken,
      );

      AppUtils.log('API Raw Response: ${response.data}');

      if (response.isSuccess) {
        if (response.data != null) {
          AppUtils.log("API Data Exists: ${response.data}");

          final userDetails = ProfileDataModel.fromJson(response.data!);
          AppUtils.log("Parsed Profile Data: ${userDetails.toJson()}");

          return ResponseData<ProfileDataModel>(
            isSuccess: true,
            data: userDetails,
          );
        } else {
          AppUtils.log("API returned NULL data!");
        }
      } else {
        AppUtils.log("API request failed!");
      }
    } catch (e) {
      AppUtils.log("Error fetching profile: $e");
    }

    return ResponseData<ProfileDataModel>(
      isSuccess: false,
      error: Exception('Failed to fetch profile'),
    );
  }

  @override
  Future<ResponseData<Map<String, dynamic>>> changePasswordProfile({
    required String oldpassword,
    required String newpassword,
  }) async {
    String? authToken = Preferences.authToken?.bearer;

    if (authToken == null) {
      return ResponseData<Map<String, dynamic>>(isSuccess: false);
    }
    final body = {'oldPassword': oldpassword, 'newPassword': newpassword};
    final ResponseData<Map<String, dynamic>?> response = await _apiMethod.post(
      url: Urls.changepassword,
      body: body,
      authToken: authToken,
      headers: {},
    );

    if (response.isSuccess) {
      return ResponseData<Map<String, dynamic>>(
        isSuccess: true,
        data: response.data ?? {},
      );
    } else {
      return ResponseData<Map<String, dynamic>>(
        isSuccess: false,
        error: response.error,
      );
    }
  }

  @override
  Future<ResponseData<GetcategoryModel>> createpostcategory() async {
    String? authToken = Preferences.authToken?.bearer;

    AppUtils.log('Auth Token: $authToken');

    try {
      final ResponseData<Map<String, dynamic>> response = await _apiMethod.get(
        url: Urls.getcategory,
        authToken: authToken,
      );

      AppUtils.log('API Raw Response Cate>>>>: ${response.data}');

      if (response.isSuccess) {
        if (response.data != null) {
          AppUtils.log("API Data Exists: ${response.data}");

          // Transform the data to map _id to id before parsing
          final transformedData = Map<String, dynamic>.from(response.data!);
          if (transformedData['data'] != null &&
              transformedData['data']['data'] != null) {
            final categoriesArray = List<Map<String, dynamic>>.from(
              transformedData['data']['data'],
            );
            final transformedCategories = categoriesArray.map((category) {
              final transformed = Map<String, dynamic>.from(category);
              // Map _id to id
              if (transformed.containsKey('_id')) {
                transformed['id'] = transformed['_id'];
                transformed.remove('_id');
              }
              // Map __v to v
              if (transformed.containsKey('__v')) {
                transformed['v'] = transformed['__v'];
                transformed.remove('__v');
              }
              AppUtils.log(
                "Transformed category: ${transformed['name']} (ID: ${transformed['id']})",
              );
              return transformed;
            }).toList();

            transformedData['data']['data'] = transformedCategories;
            AppUtils.log(
              "Categories transformed successfully. Count: ${transformedCategories.length}",
            );
          }

          final userDetails = GetcategoryModel.fromJson(transformedData);
          AppUtils.log("Parsed Profile Data: ${userDetails.toJson()}");

          return ResponseData<GetcategoryModel>(
            isSuccess: true,
            data: userDetails,
          );
        } else {
          AppUtils.log("API returned NULL data!");
        }
      } else {
        AppUtils.log("API request failed!");
      }
    } catch (e) {
      AppUtils.log("Error fetching profile: $e");
    }

    return ResponseData<GetcategoryModel>(
      isSuccess: false,
      error: Exception('Failed to fetch profile'),
    );
  }

  @override
  Future<ResponseData<Map<String, dynamic>>> removePost({
    required String postId,
  }) async {
    final result = await _apiMethod.delete(
      url: Urls.Createpost,
      query: {'id': postId},
    );

    if (result.isSuccess) {
      return ResponseData(isSuccess: true, data: result.data);
    } else {
      return ResponseData(isSuccess: false, exception: result.getError);
    }
  }

  //
  //
  // @override
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
  // }) async {
  //   try {
  //     List<Map<String, String>>? formattedFiles = uploadedFileUrls?.map((url) {
  //       return {
  //         'file': url,
  //         'type': fileType == "post" ? (url.endsWith(".mp4") ? "video" : "image") : fileType,
  //       };
  //     }).toList();
  //
  //     Map<String, dynamic> requestBody = {
  //       'userId': userId,
  //       'categoryId': categoryId,
  //       'content': content,
  //       'files': formattedFiles,
  //       'fileType': fileType,
  //       'country': address,
  //       'location': location,
  //       "startTime": startTime,
  //       "endTime": endTime,
  //       "duration": duration,
  //       "options": pollOptions?.map((element) => element.toJson()).toList(),
  //     };
  //
  //     AppUtils.log("Edit Post Request: $requestBody");
  //
  //     final result = await _apiMethod.put(
  //       url: Urls.editPost,
  //       query: {'id': postId},
  //       body: requestBody,
  //       headers: {'Content-Type': 'application/json'},
  //     );
  //
  //     AppUtils.log("Edit Post Response: ${result.toJson()}");
  //
  //     if (result.isSuccess) {
  //       return ResponseData(isSuccess: true, data: result.data ?? {});
  //     } else {
  //       return ResponseData(isSuccess: false, error: result.getError);
  //     }
  //   } catch (e) {
  //     AppUtils.log("Exception in EditPost: $e");
  //     return ResponseData(isSuccess: false, error: Exception(e));
  //   }
  // }

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
  }) async {
    try {
      // Check wallet balance for advertisement category
      if (categoryId == '68eb8453d5e284efb554b401') {
        // Import ProfileCtrl to check wallet balance
        final profileCtrl = Get.find<ProfileCtrl>();
        final currentBalance =
            (profileCtrl.profileData.value.walletBalance ?? 0).toDouble();
        const requiredAmount = 5.0;

        AppUtils.log(
          "Advertisement post - Current balance: \$${currentBalance}, Required: \$${requiredAmount}",
        );

        if (currentBalance < requiredAmount) {
          final errorMsg =
              "Insufficient balance. You have \$${currentBalance.toStringAsFixed(2)} but need \$${requiredAmount.toStringAsFixed(2)}. Please add funds to your wallet first.";
          AppUtils.toastError(errorMsg);
          return ResponseData(
            isSuccess: false,
            error: Exception("Insufficient balance"),
          );
        }
      }

      const videoFormats = ['mp4', 'mov', 'avi'];

      // List<Map<String, String>>? formattedFiles = uploadedFileUrls?.map((url) {
      //   final extension = p.extension(url.toLowerCase()).replaceAll(".", "");
      //
      //   final isVideo = videoFormats.contains(extension);
      //
      //   return {
      //     'file': url,
      //     'type': isVideo ? "video" : "image",
      //   };
      // }).toList();

      Map<String, dynamic> requestBody = {
        'userId': userId,
        'categoryId': categoryId,
        'content': content,
        'files': uploadedFileUrls,
        'fileType': fileType,
        'country': address,
        'location': location,
        "startTime": startTime,
        "endTime": endTime,
        "duration": duration,
        "options": pollOptions?.map((element) => element.toJson()).toList(),
      };

      // Add price field for advertisement category (ID: 68eb8453d5e284efb554b401)
      if (categoryId == '68eb8453d5e284efb554b401') {
        requestBody['price'] = 5; // $5 for advertisement posts
        AppUtils.log("Advertisement category detected, adding \$5 price");
      }

      AppUtils.log("Create Post Request: $requestBody");

      final result = await _apiMethod.post(
        url: Urls.Createpost,
        body: requestBody,
        headers: {'Content-Type': 'application/json'},
      );

      AppUtils.log("Create Post Response: ${result.toJson()}");

      if (result.isSuccess) {
        return ResponseData(isSuccess: true, data: result.data ?? {});
      } else {
        return ResponseData(isSuccess: false, error: result.getError);
      }
    } catch (e) {
      AppUtils.log("Exception in CreatePost: $e");
      return ResponseData(isSuccess: false, error: Exception(e));
    }
  }

  @override
  Future<ResponseData<TermsConditionModel>> getTermsAndCondations() async {
    final ResponseData<Map<String, dynamic>?> response = await _apiMethod.get(
      url: Urls.termsAndCondition,
      headers: {'Content-Type': 'application/json'},
      query: {'type': 'Contact_Us'},
    );
    AppUtils.log('API Response: ${response.data}');
    if (response.isSuccess && response.data != null) {
      final userDetails = TermsConditionModel.fromJson(response.data!);
      return ResponseData<TermsConditionModel>(
        isSuccess: true,
        data: userDetails,
      );
    } else {
      AppUtils.log('Response data is null or API call failed');
      return ResponseData<TermsConditionModel>(
        isSuccess: false,
        error: Exception('Failed to load details'),
      );
    }
  }

  @override
  Future<ResponseData<Map<String, dynamic>>> getUserAgoraToken({
    required String channelName,
    required String uid,
    bool isPublisher = false,
  }) async {
    final ResponseData<Map<String, dynamic>?> response = await _apiMethod.post(
      responseStatusValue: {'status': true},
      url: Urls.getUserAgoraToken,
      headers: {'Content-Type': 'application/json'},
      withoutStatus: true,
      body: {
        "channelName": channelName,
        "uid": uid,
        "role": isPublisher ? "publisher" : 'subscriber',
      },
    );
    AppUtils.log('API Response: ${response.data}');
    if (response.isSuccess && response.data != null) {
      return ResponseData<Map<String, dynamic>>(
        isSuccess: true,
        data: response.data!,
      );
    } else {
      return ResponseData<Map<String, dynamic>>(
        isSuccess: false,
        error: Exception('Failed to load details'),
      );
    }
  }

  @override
  Future<ResponseData<TermsConditionModel>> getPrivacyAndPolicy() async {
    final ResponseData<Map<String, dynamic>?> response = await _apiMethod.get(
      url: Urls.termsAndCondition,
      headers: {'Content-Type': 'application/json'},
      query: {'type': 'PrivacyPolicy'},
    );
    AppUtils.log('API Response: ${response.data}');
    if (response.isSuccess && response.data != null) {
      final userDetails = TermsConditionModel.fromJson(response.data!);
      return ResponseData<TermsConditionModel>(
        isSuccess: true,
        data: userDetails,
      );
    } else {
      AppUtils.log('Response data is null or API call failed');
      return ResponseData<TermsConditionModel>(
        isSuccess: false,
        error: Exception('Failed to load details'),
      );
    }
  }

  @override
  Future<ResponseData<Map<String, dynamic>>> otpVerify({
    required String email,
    required String otp,
  }) async {
    final body = {'email': email, 'otp': otp};
    return _apiRequest(
      url: Urls.verifyOtp,
      body: body,
      errorMessage: 'OTP verification failed',
    );
  }

  @override
  Future<ResponseData<ResendOtpModel>> resetPass({
    required String email,
    required String id,
    required String otp,
    String? newPassword,
  }) async {
    final body = {
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
      'id': id,
    };

    final response = await _apiMethod.post(
      url: Urls.resetPassword,
      body: body,
      headers: {},
    );

    if (response.isSuccess) {
      final body = response.data ?? {};
      final data = ResendOtpModel.fromJson(body);
      return ResponseData(isSuccess: true, data: data);
    } else {
      return ResponseData(isSuccess: false, error: response.error);
    }

    // final response = await _apiRequest(
    //   url: Urls.forgotPassword,
    //   body: body,
    //   errorMessage: 'Forgot password failed',
    // );
    //
    // if (response.isSuccess) {
    //   try {
    //     final resendOtpModel = ResendOtpModel.fromJson(response.data ?? {});
    //     AppUtils.log('New OTP from response: ${resendOtpModel.data?.otp}');
    //   } catch (e) {
    //     AppUtils.log('Failed to parse OTP response: $e');
    //   }
    // } else {
    //   AppUtils.log('Failed to resend OTP: ${response.error}');
    // }

    // return response;
  }

  @override
  Future<ResponseData<Map<String, dynamic>>> changeResetPass({
    required String password,
    required String changepassword,
  }) async {
    final body = {'password': password, 'confirmPassword': changepassword};
    final userId = Preferences.uid;

    AppUtils.log("user id >>>>>>>>>>> $userId");
    AppUtils.log("URL: ${Urls.changeResetPassword}?id=$userId");
    final urlWithParams = Uri.parse(
      Urls.changeResetPassword,
    ).replace(queryParameters: {'id': userId}).toString();
    AppUtils.log("URL with param: $urlWithParams");

    try {
      final apiResponse = await _apiRequest(
        url: urlWithParams,
        body: body,
        errorMessage: 'Change password failed',
      );
      AppUtils.log("API Response: ${apiResponse.data}");
      return apiResponse;
    } catch (e) {
      AppUtils.log("Error: $e");
      return ResponseData(
        isSuccess: false,
        error: Exception('Change password failed: $e'),
      );
    }
  }

  @override
  Future<ResponseData<OtpDataModel>> emailOtpVerify({
    required String id,
    required String otp,
  }) async {
    final body = {'id': id, 'otp': otp};

    final response = await _apiMethod.post(
      url: Urls.otpVerification,
      headers: {},
      body: body,
    );

    if (response.isSuccess) {
      final otpDataModel = OtpDataModel.fromJson(response.data ?? {});
      return ResponseData(isSuccess: true, data: otpDataModel);
    } else {
      return ResponseData(isSuccess: false, error: response.error);
    }
  }

  @override
  Future<ResponseData<Map<String, dynamic>>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      String? authToken = Preferences.authToken?.bearer;
      AppUtils.log("authToken>>>>>>>>>>>>$authToken");
      if (authToken == null || authToken.isEmpty) {
        AppUtils.log("Auth Token is missing or invalid");
        throw Exception('Authentication failed: No token found');
      }
      final response = await _apiMethod.put(
        url: Urls.changePassword,
        headers: {},
        body: {"currentPassword": currentPassword, "newPassword": newPassword},
        authToken: authToken,
      );
      if (response.isSuccess) {
        AppUtils.log("Password changed successfully");
      } else {
        throw Exception('Failed to change password: ${response.isSuccess}');
      }
      return response;
    } catch (e, stackTrace) {
      AppUtils.log("Error changing password: $e");
      AppUtils.log("StackTrace: $stackTrace");

      return Future.error(e);
    }
  }

  @override
  Future<ResponseData<Map<String, dynamic>>> profileUpdate({
    required String name,
    required String email,
    String? phone,
    String? dob,
    String? gender,
    String? image,

    String? accessToken,
  }) async {
    try {
      String? authToken = (accessToken ?? Preferences.authToken)?.bearer;

      final multipartFile = image != null && image.isNotEmpty
          ? <String, String>{'image': image}
          : <String, String>{};

      AppUtils.log({
        'name': name,
        'email': email,
        'phone': phone,
        'dob': dob.isNotNullEmpty ? dob?.ddMMyyyy.yyyyMMdd : null,
        'gender': gender,
        'image': image ?? 'No image provided',
      });

      final result = await _apiMethod.put(
        authToken: authToken,
        url: Urls.updateProfile,
        body: {
          'name': name,
          'email': email,
          'phone': phone,
          'dob': dob,
          'gender': gender,
        },
        multipartFile: multipartFile,
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
  Future<ResponseData<Map<String, dynamic>>> logout() async {
    String? authToken = Preferences.authToken?.bearer;
    try {
      final response = await _apiMethod.post(
        url: Urls.logout,
        headers: {},
        authToken: authToken,
      );

      AppUtils.log(
        "API response: ${response.isSuccess ? 'Success' : 'Failed'}",
      );
      AppUtils.log("API response error: ${response.error}");

      if (response.isSuccess) {
        AppUtils.log('User logged out successfully.');
      }
      return response;
    } catch (e) {
      AppUtils.log('Logout exception: $e');
      return ResponseData(
        isSuccess: false,
        error: Exception('Logout failed due to an exception: $e'),
      );
    }
  }

  @override
  Future<ResponseData<Map<String, dynamic>>> deleteAccount() async {
    String? authToken = Preferences.authToken!.bearer;
    String? userid = Preferences.uid;
    try {
      final response = await _apiMethod.delete(
        url: Urls.deleteAccount,
        authToken: authToken,
        query: {'id': '$userid'},
      );

      AppUtils.log(
        "API response: ${response.isSuccess ? 'Success' : 'Failed'}",
      );
      AppUtils.log("API response error: ${response.error}");
      if (response.isSuccess) {
        await _clearUserData();
        AppUtils.log('User Delete successfully.');
      }
      return response;
    } catch (e) {
      AppUtils.log('Delete exception: $e');
      return ResponseData(
        isSuccess: false,
        error: Exception('Delete failed due to an exception: $e'),
      );
    }
  }

  Future<void> _clearUserData() async {
    await Preferences.onLogout();
    AppUtils.log('User data cleared from Preferences.');
  }

  @override
  Future<ResponseData<Map<String, dynamic>>> deleteNotification(
    String notificationId,
  ) async {
    String? authToken = Preferences.authToken!.bearer;
    try {
      final response = await _apiMethod.delete(
        url: Urls.deleteNotification,
        authToken: authToken,
        query: {'notificationId': notificationId},
      );

      AppUtils.log(
        "API response: ${response.isSuccess ? 'Success' : 'Failed'}",
      );
      AppUtils.log("API response error: ${response.error}");
      if (response.isSuccess) {
        AppUtils.log('Notification Delete successfully.');
      }
      return response;
    } catch (e) {
      AppUtils.log('Delete exception: $e');
      return ResponseData(
        isSuccess: false,
        error: Exception('Delete failed due to an exception: $e'),
      );
    }
  }

  @override
  Future<ResponseData<List<String>>> uploadPhoto({
    File? imageFile,
    Uint8List? memoryFile,
  }) async {
    // try {
    final token = GlobalState.signupFromData?.data?.token?.bearer;
    // try {
    final multipartFile = {'files': imageFile?.path ?? memoryFile};
    AppUtils.log("Uploading photo: $multipartFile");
    final response = await _apiMethod.post(
      url: Urls.uploadPhoto,
      body: {},
      multipartFile: multipartFile,
      headers: {},
      authToken: token,
      isMultipartFromPath: memoryFile == null,
      // memoryFile != null
    );

    if (response.isSuccess) {
      // final data = imageResult.data?["data"]?['urls'] ?? [];
      // ;
      List<dynamic> list = response.data?["data"]?['urls'] ?? [];

      List<String> data = list.map((element) => '$element').toList();

      print(data);

      return ResponseData<List<String>>(isSuccess: true, data: data);
    } else {
      AppUtils.log("Photo upload failed with status: ${response.error}");
      throw Exception('Photo upload failed');
    }
    // } on Exception catch (e) {
    //   AppUtils.log(e);
    //   throw e;
    // }
    // } catch (e) {
    //   AppUtils.log("Error uploading photo: $e");
    //   return ResponseData<List<String>>(
    //     isSuccess: false,
    //     error: Exception('Photo uploading failed: $e'),
    //   );
    // }
  }

  ///////////////////////////////////////////  Templates ///////////////////////////////////

  Future<ResponseData<Map<String, dynamic>>> _apiRequest({
    required String url,
    Map<String, dynamic>? body,
    String? authToken,
    Map<String, String>? headers,
    required String errorMessage,
    int? id,
  }) async {
    try {
      if (id != null) {
        final uri = Uri.parse(url).replace(queryParameters: {'id': id});
        url = uri.toString();
      }

      final header = {
        if (headers != null) ...headers,
        if (authToken != null) 'Authorization': authToken,
      };
      AppUtils.log("Headers sent to API: $header");
      final response = await _apiMethod.post(
        url: url,
        body: body,
        headers: header,
      );

      if (response.isSuccess == true && response.data != null) {
        return ResponseData(isSuccess: true, data: response.data!);
      } else {
        throw Exception(errorMessage);
      }
    } catch (e) {
      return ResponseData(
        isSuccess: false,
        error: Exception('$errorMessage: $e'),
      );
    }
  }

  // static const String followUnfollowUserRequest = '${_Collection.product}/api/followUnfollowUser';
  // // {"followUserId":"679b081d3cdfb86bfb8d705f"}
  // //Authorization
  //
  // static const String blockUnblockUserRequest = '${_Collection.product}/api/blockUnblockUsers';
  // // {"blockUserId":"679b081d3cdfb86bfb8d705f"}
  // //Authorization
  //
  //
  //
  // static const String getBlockedUserList = '${_Collection.product}/api/getBlockUsersList';
  // // Authorization
  //

  @override
  Future<ResponseData<bool>> blockUnblockUserRequest({
    required String blockUserId,
  }) async {
    final response = await _apiMethod.post(
      url: Urls.blockUnblockUserRequest,
      responseStatusValue: {"success": true},
      body: {"blockUserId": blockUserId},
      headers: {},
      authToken: Preferences.authToken,
      // authToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2N2FkN2E3YmU1ZjM2MTBhMzg5YWNjOTIiLCJlbWFpbCI6InBhbmthamNkejYzQGdtYWlsLmNvbSIsImlhdCI6MTc0MTc3MTU0NSwiZXhwIjoxNzQ0MzYzNTQ1fQ.i8UMaWNOFfiN_2VJk7rIeR7-cJV2hiiAn8W-Sp7WbIo"
    );

    if (response.isSuccess) {
      //     {
      //       "success": true,
      //   "message": "User unblock successfully",
      //   "data": {
      //   "username": "",
      //   "countryCode": "",
      //   "followers": [],
      //   "isBlocked": false,
      //   "isBlockedByAdmin": false,
      //   "_id": "67ad7a7be5f3610a389acc92",
      //   "name": "Pankaj sharma",
      //   "email": "pankajcdz63@gmail.com",
      //   "password": "$2b$10$v8HqbAlOttV7z2FWpwWiBefvrwTsYpRaxM6CZ3sh0f5y7PI20T54q",
      //   "role": "user",
      //   "phone": "+null",
      //   "dob": "2003-05-31T00:00:00.000Z",
      //   "gender": "Male",
      //   "seeMyProfile": "Everybody",
      //   "shareMyPost": "Nobody",
      //   "image": "/public/uploads/1739360336105.jpg",
      //   "createdAt": "2025-02-13T04:52:11.903Z",
      //   "updatedAt": "2025-03-13T19:20:49.760Z",
      //   "__v": 0,
      //   "isNotification": false,
      //   "otp": "2498",
      //   "isActive": true,
      //   "following": [
      //   "679b081d3cdfb86bfb8d705f"
      //   ],
      //   "blockUser": []
      // },
      //   "statusCode": 200
      // }

      return ResponseData<bool>(isSuccess: true, data: true);
    } else {
      throw response.getError!;
    }
  }

  @override
  Future<ResponseData<bool>> followUnfollowUserRequest({
    required String followUserId,
  }) async {
    String? currentUserId = Preferences.uid;

    final response = await _apiMethod.post(
      url: Urls.followUnfollowUserRequest,
      body: {
        "followUserId": followUserId,
        "userId": currentUserId, // Add current userId for follow notification
      },
      headers: {},
      authToken: Preferences.authToken,
    );

    if (response.isSuccess) {
      //     {
      //       "status": true,
      //   "code": 200,
      //   "message": "User follow successfully",
      //   "data": {
      //   "username": "",
      //   "countryCode": "",
      //   "followers": [],
      //   "isBlocked": false,
      //   "isBlockedByAdmin": false,
      //   "_id": "67ad7a7be5f3610a389acc92",
      //   "name": "Pankaj sharma",
      //   "email": "pankajcdz63@gmail.com",
      //   "password": "$2b$10$v8HqbAlOttV7z2FWpwWiBefvrwTsYpRaxM6CZ3sh0f5y7PI20T54q",
      //   "role": "user",
      //   "phone": "+null",
      //   "dob": "2003-05-31T00:00:00.000Z",
      //   "gender": "Male",
      //   "seeMyProfile": "Everybody",
      //   "shareMyPost": "Nobody",
      //   "image": "/public/uploads/1739360336105.jpg",
      //   "createdAt": "2025-02-13T04:52:11.903Z",
      //   "updatedAt": "2025-03-13T19:20:06.597Z",
      //   "__v": 0,
      //   "isNotification": false,
      //   "otp": "2498",
      //   "isActive": true,
      //   "following": [
      //   "679b081d3cdfb86bfb8d705f"
      //   ],
      //   "blockUser": [
      //   "679b081d3cdfb86bfb8d705f"
      //   ]
      // }
      // }

      return ResponseData<bool>(isSuccess: true, data: true);
    } else {
      throw response.getError!;
    }
  }

  @override
  Future<ResponseData<List<ProfileDataModel>>> getBlockedUserList() async {
    final response = await _apiMethod.get(
      responseStatusValue: {'success': true},
      url: Urls.getBlockedUserList,
      authToken: Preferences.authToken,
      // authToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2N2FkN2E3YmU1ZjM2MTBhMzg5YWNjOTIiLCJlbWFpbCI6InBhbmthamNkejYzQGdtYWlsLmNvbSIsImlhdCI6MTc0MTc3MTU0NSwiZXhwIjoxNzQ0MzYzNTQ1fQ.i8UMaWNOFfiN_2VJk7rIeR7-cJV2hiiAn8W-Sp7WbIo'
    );

    if (response.isSuccess) {
      // final list = List<ProfileDataModel>.from((response.data?['data']?['blockUsers'] ?? []).map((json)=> ProfileDataModel(
      final list = List<ProfileDataModel>.from(
        (response.data?['data'] ?? []).map(
          (json) => ProfileDataModel(
            id: json['_id'],
            name: json['name'],
            image: json['image'],
            email: json['email'],
            // phone: json[''],
            // createdAt: json[''],
            // updatedAt: json[''],
            // dob: json[''],
            // gender: json[''],
            // isNotification: json[''],
            // password: json[''],
            // role: json[''],
            // seeMyProfile: json[''],
            // shareMyPost: json[''],
            // socialId: json[''],
          ),
        ),
      );

      //     {
      //       "success": true,
      //   "message": "Fetched block users list successfully",
      //   "data": {
      //   "_id": "67ad7a7be5f3610a389acc92",
      //   "blockUser": [
      // {
      //   "username": "",
      //   "countryCode": "",
      //   "dob": null,
      //   "isNotification": true,
      //   "following": [],
      //   "blockUser": [],
      //   "seeMyProfile": "everyBody",
      //   "shareMyPost": "everyBody",
      //   "isActive": false,
      //   "isBlocked": false,
      //   "isBlockedByAdmin": false,
      //   "_id": "679b081d3cdfb86bfb8d705f",
      //   "name": "test",
      //   "email": "test@gmail.com",
      //   "password": "$2b$10$d4M2utbEN1oWUnCUttMehemwtpPKQPlvzLz8Y.kDXdZGpNpaoaGFa",
      //   "role": "user",
      //   "gender": "male",
      //   "createdAt": "2025-01-30T05:03:25.279Z",
      //   "updatedAt": "2025-03-12T09:42:39.842Z",
      //   "__v": 0,
      //   "otp": null,
      //   "followers": []
      // }
      //   ]
      // },
      //   "statusCode": 200
      // }

      return ResponseData<List<ProfileDataModel>>(isSuccess: true, data: list);
    } else {
      AppUtils.log("Photo upload failed with status: ${response.error}");
      throw Exception('Photo upload failed');
    }
  }

  // static const String reportUserRequest = '${_Collection.product}/api/reportUser?id=679b081d3cdfb86bfb8d705f';
  //Authorization

  @override
  Future<ResponseData<bool>> reportUserRequest({
    required String id,
    required String title,
    String? message,
  }) async {
    final response = await _apiMethod.post(
      url: Urls.reportUserRequest,
      query: {'id': id},
      authToken: Preferences.authToken,
      headers: {},
      body: {'title': title, 'message': message},
    );
    //   {
    //     "success": true,
    //   "message": "undefined has reported undefined again. Report count is now 2.",
    //   "data": {
    //   "_id": "67d165a7a28237ba95db7e95",
    //   "userId": "67ad7a7be5f3610a389acc92",
    //   "retporUserId": "679b081d3cdfb86bfb8d705f",
    //   "count": 2,
    //   "message": "Pankaj sharma has reported test.",
    //   "timestamp": "2025-03-12T10:44:55.878Z",
    //   "__v": 0
    // },
    //   "statusCode": 200
    // }

    if (response.isSuccess) {
      AppUtils.log(response.data?['message'] ?? '');

      return ResponseData<bool>(isSuccess: true, data: true);
    } else {
      throw response.getError!;
    }
  }

  @override
  Future<ResponseData<bool>> reportPostRequest({
    required String postId,
    required String title,
    String? message,
  }) async {
    final response = await _apiMethod.post(
      url: Urls.reportPostRequest,
      authToken: Preferences.authToken?.bearer,
      headers: {},
      body: {'reportedPostId': postId, 'reason': title, "details": message},
    );

    //   {
    //     "success": true,
    //   "message": "undefined has reported undefined again. Report count is now 2.",
    //   "data": {
    //   "_id": "67d165a7a28237ba95db7e95",
    //   "userId": "67ad7a7be5f3610a389acc92",
    //   "retporUserId": "679b081d3cdfb86bfb8d705f",
    //   "count": 2,
    //   "message": "Pankaj sharma has reported test.",
    //   "timestamp": "2025-03-12T10:44:55.878Z",
    //   "__v": 0
    // },
    //   "statusCode": 200
    // }

    if (response.isSuccess) {
      AppUtils.log(response.data?['message'] ?? '');

      return ResponseData<bool>(isSuccess: true, data: true);
    } else {
      throw response.getError!;
    }
  }

  @override
  Future<ResponseData<List<ProfileDataModel>>> getFollowersList({
    required String type,
    String? userId,
  }) async {
    final response = await _apiMethod.get(
      url: Urls.getFollowingList,
      query: {'userId': userId ?? Preferences.uid!, 'type': type},
      authToken: Preferences.authToken,
      headers: {},
    );
    //   {
    //     "success": true,
    //   "message": "undefined has reported undefined again. Report count is now 2.",
    //   "data": {
    //   "_id": "67d165a7a28237ba95db7e95",
    //   "userId": "67ad7a7be5f3610a389acc92",
    //   "retporUserId": "679b081d3cdfb86bfb8d705f",
    //   "count": 2,
    //   "message": "Pankaj sharma has reported test.",
    //   "timestamp": "2025-03-12T10:44:55.878Z",
    //   "__v": 0
    // },
    //   "statusCode": 200
    // }

    if (response.isSuccess) {
      AppUtils.log(response.data?['message'] ?? '');

      List<ProfileDataModel> list = List<ProfileDataModel>.from(
        (type == 'followers'
                ? (response.data?['data']?['followers']) ?? []
                : (response.data?['data']?['following']) ?? [])
            .map((json) => ProfileDataModel.fromJson(json)),
      );

      return ResponseData<List<ProfileDataModel>>(isSuccess: true, data: list);
    } else {
      throw response.getError!;
    }
  }

  @override
  Future<ResponseData<ProfileDataModel?>> removeFollower({
    required String userId,
  }) async {
    final response = await _apiMethod.post(
      url: Urls.removeFollowers,
      body: {'followerId': userId},
      authToken: Preferences.authToken,
      headers: {},
    );

    if (response.isSuccess) {
      // AppUtils.log(response.data?['message']?? '');
      final dynamicData = response.data?['data'];

      final data = dynamicData != null
          ? ProfileDataModel.fromJson(response.data?['data'] ?? {})
          : null;

      // List<ProfileDataModel> list = List<ProfileDataModel>.from(
      //     (
      //         type == 'followers' ? (response.data?['data']?['followers'])??[] :
      //
      //         (response.data?['data']?['following'])??[]
      //
      //
      //     ).map((json)=> ProfileDataModel.fromJson(json))
      // );

      return ResponseData<ProfileDataModel?>(isSuccess: true, data: data);
    } else {
      throw response.getError!;
    }
  }

  @override
  Future<ResponseData<Map<String, dynamic>>> post({
    required String url,
    Map<String, dynamic>? data,
    Map<String, String>? header,
    bool enableAuthToken = false,
  }) async {
    final result = await _apiMethod.post(
      url: url,
      body: data,
      headers: header ?? {},
      authToken: enableAuthToken ? Preferences.authToken : null,
    );
    return result;
  }

  @override
  Future<ResponseData<Map<String, dynamic>>> createMoneyWalletTransaction({
    required String sendTo,
    required String amount,
  }) async {
    final result = await post(
      url: Urls.moneyWalletTransaction,
      data: {
        "sentTo": sendTo,
        "sentBy": Preferences.uid,
        "token": int.parse(amount), // Convert string to int for new API format
      },
      enableAuthToken: true,
    );

    return result;
  }

  @override
  Future<ResponseData<Map<String, dynamic>>> purchaseTokens({
    required String userId,
    required double amount,
  }) async {
    final result = await post(
      url: Urls.tokenPurchase,
      data: {"userId": userId, "amount": amount},
      enableAuthToken: true,
    );

    return result;
  }
}
