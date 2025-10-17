import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../../services/networking/urls.dart';
import '../../../../utils/appUtils.dart';

class EditprofileCtrl extends GetxController {
  static EditprofileCtrl get find => Get.put(EditprofileCtrl(), permanent: true);

  RxString imagePath = ''.obs;

  var name = ''.obs;
  var email = ''.obs;
  var phone = ''.obs;
  var countryCode = '+91'.obs;
  var profileImagePath = ''.obs;

  final Urls _apiMethod = Urls();

  void updateName(String newName) {
    name.value = newName;
  }

  void updateEmail(String newEmail) {
    email.value = newEmail;
  }

  void updatePhone(String newPhone) {
    phone.value = newPhone;
  }

  void updateCountryCode(String newCode) {
    countryCode.value = newCode;
  }

  void updateProfileImage(String path) {
    profileImagePath.value = path;
  }

  void updateImage(String newImagePath) {
    imagePath.value = newImagePath;
    AppUtils.log("Updated Image Path: $newImagePath");
  }
}


