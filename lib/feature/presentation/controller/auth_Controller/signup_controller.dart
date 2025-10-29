import 'package:get/get.dart';
import 'package:sep/services/networking/urls.dart';

import '../../../../utils/appUtils.dart';
import '../../../data/models/dataModels/responseDataModel.dart';
import '../../../data/models/dataModels/signupModel.dart';


class SignupController extends GetxController {
  RxString imagePath = ''.obs;

  var name = ''.obs;
  var email = ''.obs;
  var phone = ''.obs;
  var countryCode = ''.obs;
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
