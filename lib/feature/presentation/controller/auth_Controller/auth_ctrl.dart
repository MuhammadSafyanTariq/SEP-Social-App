import 'package:get/get.dart';
import 'package:sep/feature/data/repository/iAuthRepository.dart';
import 'package:sep/feature/data/repository/iTempRepository.dart';
import 'package:sep/feature/domain/respository/authRepository.dart';
import 'package:sep/feature/domain/respository/templateRepository.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/utils/appUtils.dart';

import '../../../../services/storage/preferences.dart';
import '../../../data/models/dataModels/profile_data/profile_data_model.dart';

class AuthCtrl extends GetxController {
  static AuthCtrl get find => Get.put(AuthCtrl(), permanent: true);
  final AuthRepository _repo = IAuthRepository();
  final TempRepository repo = ITempRepository();
  ProfileDataModel? userProfile;
  AuthRepository get getRepo => _repo;

  var searchedUsers = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> pollList = <Map<String, dynamic>>[].obs;

  RxBool isLoading = false.obs;

  var image = ''.obs;
  var name = ''.obs;
  var email = ''.obs;
  var phone = ''.obs;
  var dob = ''.obs;
  var gender = ''.obs;

  Future isEmailExist(String email, {bool showToastEr = true}) async {
    final result = await _repo.emailvalidation(email: email);
    if (result.isSuccess) {
      final data = result.data!;
      return;
    } else {
      if (showToastEr) {
        AppUtils.toastError(result.getError!);
      }
      throw result.getError!;
    }
  }

  Future<Map<String, dynamic>?> createMoneyWalletTransaction(
    String amount,
    String sendTo,
  ) async {
    final result = await _repo.createMoneyWalletTransaction(
      amount: amount,
      sendTo: sendTo,
    );

    if (result.isSuccess) {
      // Updated API Response Format:
      // {
      //   "status": true,
      //   "code": 200,
      //   "message": "Transaction successfully",
      //   "data": {
      //     "tokenAmount": 1,
      //     "commissionTokens": 0,
      //     "netTokensToReceiver": 1,
      //     "dollarValue": 0.05,
      //     "dollarCommission": 0.0,
      //     "senderNewBalance": 120,
      //     "receiverNewBalance": 120.05
      //   }
      // }
      return result.data;
    } else {
      throw result.statusCode == 402 ? result : result.error!;
    }
  }

  Future<void> register(
    String name,
    String email,
    String phone,
    String countryCode,
    String password,
    String dob,
    String gender,
    String country,
    String image,
    String bio,
    String webSite,
  ) async {
    final response = await _repo.registerUser(
      name: name,
      email: email,
      phone: phone,
      countryCode: countryCode,
      password: password,
      country: country,
      dob: dob,
      gender: gender,
      image: image,
      bio: bio,
      webSite: webSite,
    );
    AppUtils.log(">>>>>>>>$image");

    if (response.isSuccess) {
      return;
    } else {
      final error = response.getError;
      AppUtils.toastError(error ?? Exception('Unknown error'));
      // Return instead of throwing empty string to avoid unhandled exception
      return;
    }
  }

  Future forgotPassword() async {}

  Future login(String email, String password) async {
    AppUtils.log("🔐 AuthCtrl.login() called");
    AppUtils.log("📧 Email: $email");
    AppUtils.log("🔑 Password provided: ${password.isNotEmpty}");

    try {
      AppUtils.log("📡 Calling repository loginUser...");
      final response = await _repo.loginUser(email: email, password: password);

      AppUtils.log("📥 Repository response received");
      AppUtils.log("✅ Response isSuccess: ${response.isSuccess}");
      AppUtils.log("📦 Response data: ${response.data}");
      AppUtils.log("❌ Response error: ${response.error}");

      if (response.isSuccess) {
        final data = response.data;
        AppUtils.log("✅ Login successful!");
        AppUtils.log("📦 Login data: $data");
        AppUtils.log("👤 User profile saved: ${Preferences.profile?.toJson()}");
        AppUtils.log("🔑 Auth token saved: ${Preferences.authToken}");
        AppUtils.log("🆔 User ID saved: ${Preferences.uid}");

        return response;
      } else {
        final error = response.getError;
        AppUtils.log("❌ Login failed!");
        AppUtils.log("❌ Error: $error");
        AppUtils.log("❌ Error type: ${error.runtimeType}");
        AppUtils.toastError(error ?? Exception('Unknown error'));

        return response;
      }
    } catch (e, stackTrace) {
      AppUtils.log("❌ Exception in AuthCtrl.login: $e");
      AppUtils.log("❌ Stack trace: $stackTrace");
      AppUtils.toastError(Exception('Login failed: $e'));
      return null;
    }
  }

  Future<ProfileDataModel?> getUserDetails() async {
    final response = await _repo.getProfileDetails();

    if (response.isSuccess) {
      final data = response.data;
      if (data != null) {
        name.value = response.data!.name.toString();
        image.value = response.data!.image.toString();
        email.value = response.data!.email.toString();
        phone.value = response.data!.phone.toString();

        gender.value = response.data!.gender.toString();
        dob.value = response.data!.dob.toString();

        AppUtils.log("Profile Fetched: ${name.value}");
        AppUtils.log("Profile Fetched: ${image.value}");
        AppUtils.log("Profile Fetched: ${email.value}");
        AppUtils.log("Profile Fetched: ${phone.value}");
        AppUtils.log("Profile Fetched: ${gender.value}");
        AppUtils.log("Profile Fetched: ${dob.value}");

        AuthCtrl.find.userProfile = data;
        return data;
      }
    } else {
      final error = response.getError;
      AppUtils.toastError(
        error is Exception ? error : Exception('Unknown error'),
      );
      throw Exception('Failed to fetch profile');
    }
    return null;
  }

  Future changePassword(String currentpassword, String newpassword) async {
    final response = await _repo.changePassword(
      currentPassword: currentpassword,
      newPassword: newpassword,
    );

    if (response.isSuccess) {
      final data = response.data;
      // if (data != null) {
      //
      //  Get.offAll(Loading());        } else {
      //   AppUtils.log('Response data is null');
      // }
      return;
    } else {
      final error = response.getError;
      AppUtils.toastError(error ?? Exception('Unknown error'));

      // Return instead of throwing empty string to avoid unhandled exception
      return;
    }
  }

  Future<void> logout() async {
    try {
      final result = await _repo.logout();
    } finally {
      Preferences.clearUserData();
      ProfileCtrl.find.clearProfileData();
    }
    return;
  }

  Future<void> profileUpdatee(
    String name,
    String email,
    String phone,
    String dob,
    String gender,
    String image,
  ) async {
    final response = await _repo.profileUpdate(
      name: name,
      email: email,
      phone: phone,
      dob: dob,
      gender: gender,
      image: image,
    );

    if (response.isSuccess) {
      return;
    } else {
      final error = response.getError;
      AppUtils.toastError(error ?? Exception('Unknown error'));

      // Return instead of throwing empty string to avoid unhandled exception
      return;
    }
  }

  Future<void> searchUserInProfile(
    String query, {
    int page = 1,
    int limit = 10,
  }) async {
    isLoading.value = true;

    final response = await repo.searchUsers(
      searchQuery: query,
      page: page,
      limit: limit,
    );

    if (response.isSuccess) {
      AppUtils.log("API Raw Response:::::: ${response.data}");
      final users = response.data?['data']?['users'] as List<dynamic>?;
      AppUtils.log("API Raw Respons???????? ${users}");
      searchedUsers.value = users?.cast<Map<String, dynamic>>() ?? [];
    }

    isLoading.value = false;
  }

  Future<List<Map<String, dynamic>>> getPollList(
    String type, {
    int page = 1,
    int limit = 5,
  }) async {
    isLoading.value = true;

    final response = await repo.getPollList(
      type: type,
      page: page,
      limit: limit,
    );

    List<Map<String, dynamic>> fetchedPolls = [];

    if (response.isSuccess) {
      AppUtils.log("📡 API Raw Response (page=$page): ${response.data}");

      final polls = response.data?['data']?['data'] as List<dynamic>?;

      if (polls != null) {
        fetchedPolls = polls.cast<Map<String, dynamic>>();
        AppUtils.log(
          "✅ Parsed Polls (page=$page): ${fetchedPolls.map((p) => p['_id']).toList()}",
        );
      } else {
        AppUtils.log("⚠️ No polls found in the response (page=$page).");
      }
    } else {
      AppUtils.log("❌ Failed to fetch polls, error: ${response.data}");
    }

    isLoading.value = false;
    return fetchedPolls;
  }
}
