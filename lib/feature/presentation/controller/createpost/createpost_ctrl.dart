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
          error is Exception ? error : Exception('Unknown error'));
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
      if(fileType == 'post'){
        if (location != null && location.containsKey("latitude") && location.containsKey("longitude")) {
          AppUtils.log("Latitude before parsing: ${location["latitude"]}");
          AppUtils.log("Longitude before parsing: ${location["longitude"]}");

          location["latitude"] = double.tryParse(location["latitude"].toString()) ?? 0.0;
          location["longitude"] = double.tryParse(location["longitude"].toString()) ?? 0.0;
        } else {
          throw Exception("Invalid location format: missing latitude/longitude");
        }
        formattedLocation = {
          "type": "Point",
          "coordinates": [location["latitude"], location["longitude"]],
        };
      }else if(fileType == 'poll'){
        pollOptionsData ??= [];
        for(var item in (pollOptions ?? <PollItemModel>[])){
         final result = await _repo.uploadPhoto(imageFile: File(item.file ?? ''));
         if(result.isSuccess){
           List urls = result.data?? [];
           PollItemModel data = item.copyWith(image:urls.first );
           pollOptionsData.add(data);
         }else{
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
        startTime: startTime, address: location?['country'], duration: duration
      );

      if (response.isSuccess) {
        return;
      } else {
        final error = response.getError;
        AppUtils.toastError(error is Exception ? error : Exception('Unknown error'));
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

}


