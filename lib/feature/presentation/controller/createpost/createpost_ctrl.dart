// <<<<<<< HEAD
import 'dart:io';

import 'package:get/get.dart';
import 'package:sep/feature/data/models/dataModels/Createpost/address_model.dart';
import 'package:sep/feature/data/models/dataModels/poll_item_model/poll_item_model.dart';
// =======
// import 'package:get/get.dart';
// >>>>>>> 4e74444032fe00d1b74968b3216ab253a048319f
import 'package:sep/feature/data/repository/iAuthRepository.dart';
import 'package:sep/feature/domain/respository/authRepository.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/services/storage/preferences.dart';
import '../../../data/models/dataModels/Createpost/getcategory_model.dart';
import '../../../data/models/dataModels/profile_data/profile_data_model.dart';

class CreatePostCtrl extends GetxController {
  static CreatePostCtrl get find => Get.put(CreatePostCtrl(), permanent: true);
  final AuthRepository _repo = IAuthRepository();

  ProfileDataModel? userProfile;
  RxList<Categories> getCategories = <Categories>[].obs;
  var category = ''.obs;

  Future<void> getPostCategories() async {
    final response = await _repo.createpostcategory();

    if (response.isSuccess && response.data != null) {
      final data = response.data;
      if (data?.data?.data != null) {
        getCategories.assignAll(data?.data?.data ?? []);
      } else {
        AppUtils.toastError(Exception('Category data is null'));
      }
    } else {
      final error = response.getError;
      AppUtils.toastError(
        error is Exception ? error : Exception('Unknown error'),
      );
      throw Exception('Failed to fetch categories');
    }
  }

  Future<void> createPosts(
    String userId,
    String categoryId,
    String content,
    AddressModel address,
    // <<<<<<< HEAD
    Map<String, dynamic>? location,
    List<Map<String, dynamic>>? uploadedFileUrls,
    List<PollItemModel>? pollOptions,
    String fileType,
    String? startTime,
    String? endTime,
    String? duration,
  ) async {
    try {
      List<PollItemModel>? pollOptionsData;
      Map<String, dynamic>? formattedLocation;
      if (fileType == 'post') {
        if (location != null &&
            location.containsKey("latitude") &&
            location.containsKey("longitude")) {
          AppUtils.log("Latitude before parsing: ${location["latitude"]}");
          AppUtils.log("Longitude before parsing: ${location["longitude"]}");

          location["latitude"] =
              double.tryParse(location["latitude"].toString()) ?? 0.0;
          location["longitude"] =
              double.tryParse(location["longitude"].toString()) ?? 0.0;
        } else {
          throw Exception(
            "Invalid location format: missing latitude/longitude",
          );
        }
        formattedLocation = {
          "type": "Point",
          "coordinates": [location["latitude"], location["longitude"]],
        };
      } else if (fileType == 'poll') {
        pollOptionsData ??= [];
        for (var item in (pollOptions ?? <PollItemModel>[])) {
          final result = await _repo.uploadPhoto(
            imageFile: File(item.file ?? ''),
          );
          if (result.isSuccess) {
            List urls = result.data ?? [];
            PollItemModel data = item.copyWith(image: urls.first);
            pollOptionsData.add(data);
          } else {
            AppUtils.toastError(result.getError);
            throw '';
          }
        }
      }

      // List<String>? fileUrls = uploadedFileUrls?.map((file) => file["file"] ?? "").toList();
      // =======
      //       Map<String, dynamic> location,
      //       List<Map<String, String>> uploadedFileUrls,
      //       String fileType,
      //       ) async {
      //     try {
      //       if (location.containsKey("latitude") && location.containsKey("longitude")) {
      //         AppUtils.log("Latitude before parsing: ${location["latitude"]}");
      //         AppUtils.log("Longitude before parsing: ${location["longitude"]}");
      //
      //         location["latitude"] = double.tryParse(location["latitude"].toString()) ?? 0.0;
      //         location["longitude"] = double.tryParse(location["longitude"].toString()) ?? 0.0;
      //       } else {
      //         throw Exception("Invalid location format: missing latitude/longitude");
      //       }
      //
      //       Map<String, dynamic> formattedLocation = {
      //         "type": "Point",
      //         "coordinates": [location["latitude"], location["longitude"]],
      //       };
      //
      //       List<String> fileUrls = uploadedFileUrls.map((file) => file["file"] ?? "").toList();
      // >>>>>>> 4e74444032fe00d1b74968b3216ab253a048319f

      //       {
      //     "latitude": location.latitude,
      // "longitude": location.longitude,
      // "country": _selectedCountry ?? " ",
      // }

      final response = await _repo.CreatePost(
        userId: userId,
        categoryId: categoryId,
        content: content,
        location: formattedLocation,
        uploadedFileUrls: uploadedFileUrls,
        fileType: fileType,
        endTime: endTime,
        pollOptions: pollOptionsData,
        startTime: startTime,
        address: location?['country'],
        duration: duration,
      );

      if (response.isSuccess) {
        return;
      } else {
        final error = response.getError;
        AppUtils.toastError(
          error is Exception ? error : Exception('Unknown error'),
        );
        throw Exception('Failed to create post');
      }
    } catch (e, stackTrace) {
      AppUtils.log("Exception in createPosts: $e\n$stackTrace");
      AppUtils.toastError(Exception("Something went wrong!"));
      // <<<<<<< HEAD
      throw '';
      // =======
      // >>>>>>> 4e74444032fe00d1b74968b3216ab253a048319f
    }
  }

  // Helper method for uploading files
  Future<List<Map<String, dynamic>>> uploadFiles(List<File> files) async {
    List<Map<String, dynamic>> uploadedFiles = [];

    for (var file in files) {
      try {
        final result = await _repo.uploadPhoto(imageFile: file);
        if (result.isSuccess && result.data != null) {
          final urls = result.data as List;
          if (urls.isNotEmpty) {
            uploadedFiles.add({'file': urls.first, 'type': 'image'});
          }
        } else {
          AppUtils.toastError(result.getError);
        }
      } catch (e) {
        AppUtils.log('Error uploading file: $e');
      }
    }

    return uploadedFiles;
  }

  // Simplified method for creating posts/stories
  Future<void> createPost({
    required String? categoryId,
    required String content,
    required List<Map<String, dynamic>> files,
    required String fileType,
    required String country,
    Map<String, dynamic>? location,
  }) async {
    try {
      final response = await _repo.CreatePost(
        userId: Preferences.uid ?? '',
        categoryId: categoryId ?? '',
        content: content,
        location: location,
        uploadedFileUrls: files,
        fileType: fileType,
        address: country,
        duration: null,
        endTime: null,
        pollOptions: null,
        startTime: null,
      );

      if (response.isSuccess) {
        AppUtils.log('Post created successfully');
      } else {
        final error = response.getError;
        AppUtils.toastError(
          error is Exception ? error : Exception('Unknown error'),
        );
        throw Exception('Failed to create post');
      }
    } catch (e) {
      AppUtils.log("Exception in createPost: $e");
      rethrow;
    }
  }

  // Dedicated method for creating stories
  Future<void> createStory({
    required String? categoryId,
    required String content,
    required List<Map<String, dynamic>> files,
    required String country,
  }) async {
    try {
      // Calculate start and end times for 24-hour story
      final now = DateTime.now();
      final startTime = now.toIso8601String();
      final endTime = now.add(Duration(hours: 24)).toIso8601String();

      final response = await _repo.CreatePost(
        userId: Preferences.uid ?? '',
        categoryId: categoryId ?? '',
        content: content,
        location: null,
        uploadedFileUrls: files,
        fileType: 'post',
        address: country,
        duration: null,
        endTime: endTime,
        pollOptions: null,
        startTime: startTime,
      );

      if (response.isSuccess) {
        AppUtils.log('Story created successfully');
        return; // Success
      } else {
        final error = response.getError;
        AppUtils.log("Failed to create story: $error");
        AppUtils.toastError(
          error is Exception ? error : Exception('Unknown error'),
        );
        throw Exception('Failed to create story');
      }
    } catch (e) {
      AppUtils.log("Exception in createStory: $e");
      rethrow;
    }
  }
}
