// ignore_for_file: unused_local_variable

import 'package:get/get.dart';
import 'package:sep/utils/appUtils.dart';
import '../../../data/repository/iTempRepository.dart';
import '../../../domain/respository/templateRepository.dart';

class SettingsCtrl extends GetxController {
  static SettingsCtrl get find => Get.put(SettingsCtrl(), permanent: true);
  final TempRepository _repo = ITempRepository();


  Future termsandconditions()async{
    final result = await _repo.getTermsAndCondations();
    if(result.isSuccess){
      final data = result.data!;
      return;
    }else{
      AppUtils.toastError(result.getError!);
      throw '';
    }
  }


  Future privacypolicy()async{
    final result = await _repo.getPrivacyAndPolicy();
    if(result.isSuccess){
      final data = result.data!;
      return;
    }else{
      AppUtils.toastError(result.getError!);
      throw '';
    }
  }

  Future<bool> contactuss(String email, String title, String description) async {
    try {
      final response = await _repo.contactus(
        email: email, title: title, description: description,
      );

      if (response.isSuccess) {
        AppUtils.toast("Message sent successfully!");
        return true;
      } else {
        final error = response.getError;
        if (error != null) {
          AppUtils.toastError(error.toString());
        } else {
          AppUtils.toastError("Failed to send message");
        }
        return false;
      }
    } catch (e) {
      AppUtils.toastError("Something went wrong. Please try again.");
      return false;
    }
  }


  Future<void> feedbacck(
    String title,
      String description,
      String image,
      ) async {
    final response = await _repo.feedback(
      title: title,
      message: description,
      image: image,
    );
    AppUtils.log(">>>>>>>>$image");

    if (response.isSuccess) {
      return;
    } else {
      final error = response.getError;
      if (error != null) {
        AppUtils.toastError(error);
      } else {
        AppUtils.toastError(response.getError!);
      }
      throw '';
    }
  }




  // Future<void> frequentlyAskQuestion(
  //     String question,
  //     ) async {
  //   final response = await _repo.frequentaskquestion(
  //      question: question,
  //   );
  //
  //   if (response.isSuccess) {
  //     return;
  //   } else {
  //     final error = response.getError;
  //     if (error != null) {
  //       AppUtils.toastError(error is Exception ? error : Exception('Unknown error'));
  //     } else {
  //       AppUtils.toastError(response.getError!);
  //     }
  //     throw '';
  //   }
  // }



  Future<void> seeProfile(
      String seeprofile,
      ) async {
    final response = await _repo.seemyprofile(
       seemyprofile: seeprofile,
    );

    if (response.isSuccess) {
      return;

    } else {
      final error = response.getError;
      if (error != null) {
        AppUtils.toastError(error);
      } else {
        AppUtils.toastError(response.getError!);
      }
      throw '';
    }
  }


  Future<void> sharemypost(
      String sharemypost,
      ) async {
    final response = await _repo.sharemypost(
      sharemypost: sharemypost,
    );

    if (response.isSuccess) {
      return;

    } else {
      final error = response.getError;
      if (error != null) {
        AppUtils.toastError(error);
      } else {
        AppUtils.toastError(response.getError!);
      }
      throw '';
    }
  }


  // Future<void> notifications(
  //     String sharemypost,
  //     ) async {
  //   final response = await _repo.notificationallow(
  //      isNotification: null,
  //   );
  //
  //   if (response.isSuccess) {
  //     return;
  //
  //   } else {
  //     final error = response.getError;
  //     if (error != null) {
  //       AppUtils.toastError(error is Exception ? error : Exception('Unknown error'));
  //     } else {
  //       AppUtils.toastError(response.getError!);
  //     }
  //     throw '';
  //   }
  // }
  // Future<void> sharemypost(
  //     String sharemyPost,
  //     ) async {
  //   final response = await _repo.sharemypost(
  //      sharemypost: sharemyPost,
  //   );
  //
  //   if (response.isSuccess) {
  //     return;
  //   } else {
  //     final error = response.getError;
  //     if (error != null) {
  //       AppUtils.toastError(error is Exception ? error : Exception('Unknown error'));
  //     } else {
  //       AppUtils.toastError(response.getError!);
  //     }
  //     throw '';
  //   }
  // }


}