import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/auth_ctrl.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/dateTimeUtils.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';

import '../../../../components/appLoader.dart';
import '../../../../components/coreComponents/AppButton.dart';
import '../../../../components/coreComponents/EditText.dart';
import '../../../../components/coreComponents/ImageView.dart';
import '../../../../components/coreComponents/TextView.dart';
import '../../../../components/coreComponents/appBSheet.dart';
import '../../../../components/coreComponents/appBar2.dart';
import '../../../../components/coreComponents/editProfileImage.dart';
import '../../../../components/styles/appColors.dart';
import '../../../../components/styles/appImages.dart';
import '../../../../components/styles/app_strings.dart';
import '../../../../core/core/model/imageDataModel.dart';
import '../../Add post/CreatePost.dart';
import '../../controller/auth_Controller/profileCtrl.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final ProfileCtrl profileCtrl = Get.find<ProfileCtrl>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController webUrlController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();
  // var selectedImagePath = "".obs;
  PhoneNumber? initialNumber;
  String? selectedCountryCode;
  Rx<String?> countryCode = Rx(null);
  late final phoneCtrl = TextEditingController();
  String? _selectedCountry;
  bool emailReadOnlyState = false;
  Rx<Country?> countryData = Rx(null);
  Rx<ImageDataModel> profileImageData = Rx(ImageDataModel());

  String? emailError;

  @override
  void initState() {
    super.initState();
    profileImageData.value = profileCtrl.profileImageData;
    nameController = TextEditingController(
      text: profileCtrl.profileData.value.name ?? "",
    );
    emailController = TextEditingController(
      text: profileCtrl.profileData.value.email ?? "",
    );
    webUrlController = TextEditingController(
      text: profileCtrl.profileData.value.website ?? "",
    );
    bioController = TextEditingController(
      text: profileCtrl.profileData.value.bio ?? "",
    );
    emailReadOnlyState = emailController.getText.isEmail;
    _selectedCountry = profileCtrl.profileData.value.country;
    loadPhoneNumber();

    AppUtils.log(profileImageData.value.network);
  }

  Future<void> loadPhoneNumber() async {
    try {
      final code = profileCtrl.profileData.value.countryCode ?? '';
      final phone = isNull(profileCtrl.profileData.value.phone)
          ? ''
          : profileCtrl.profileData.value.phone ?? "";
      phoneCtrl.text = phone;
      countryCode.value = code.replaceAll("+", "");

      String flag = countryData.value?.flagEmoji ?? '';
      AppUtils.log("Phone number: $phone");
      AppUtils.log("Country code: $code");
      AppUtils.log("Flag: $flag");

      countryCode.refresh();
    } catch (e) {
      AppUtils.log("Error loading phone info: $e");
      countryCode.value = '';
      countryCode.refresh();
    }
  }

  bool isNull(String? data) {
    if (!data.isNotNullEmpty) {
      return true;
    } else {
      return data!.trim() == 'null';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    webUrlController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<String?> validateEmail() async {
    try {
      await AuthCtrl.find.isEmailExist(
        emailController.getText,
        showToastEr: false,
      );
      setState(() {
        emailError = null;
      });

      return null;
    } catch (e) {
      setState(() {
        emailError = e.toString().replaceFirst('Exception:', '').trim();
      });
      // emailError = e.toString();
      return e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            AppBar2(
              padding: EdgeInsets.only(top: 20),
              titleAlign: TextAlign.center,
              prefixImage: AppImages.backBtn,
              title: AppStrings.editProfile.tr,
              titleStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              onPrefixTap: () => Get.back(),
              suffixWidget: Container(width: 35),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Obx(
                        () => EditProfileImage(
                          size: 100,
                          imageData: profileImageData.value,
                        ),
                      ),

                      TextView(
                        onTap: () => _showImagePicker(context),
                        text: AppStrings.changePhoto.tr,
                        style: 16.txtregularBtncolor,
                        margin: EdgeInsets.only(top: 20),
                      ),

                      Divider(thickness: 1, color: AppColors.white, height: 30),
                      EditText(
                        hint: "Enter Name",
                        hintStyle: 16.txtRegularGrey,
                        inputType: TextInputType.name,
                        radius: 20,
                        prefixIcon: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 20.sdp,
                              color: AppColors.grey,
                            ),
                          ],
                        ),
                        margin: 16.bottom,
                        controller: nameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      EditText(
                        hint: "Enter Email",
                        hintStyle: 16.txtRegularGrey,
                        radius: 20,
                        inputType: TextInputType.emailAddress,
                        prefixIcon: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ImageView(
                              url: AppImages.email,
                              size: 20.sdp,
                              tintColor: AppColors.grey,
                            ),
                          ],
                        ),
                        margin: 16.bottom,
                        controller: emailController,
                        readOnly: emailReadOnlyState,
                        onChange: (value) {
                          validateEmail();
                        },
                        validator: (value) {
                          if (!value.isNotNullEmpty) {
                            return 'Please enter your email address';
                          } else if (!value.isEmailAddress) {
                            return 'Please enter valid email address';
                          } else if (emailError.isNotNullEmpty) {
                            return emailError;
                          }
                          return null;
                        },
                      ),
                      _buildPhoneField(),
                      SizedBox(height: 16.sdp),
                      _buildDateOfBirthPicker(),
                      SizedBox(height: 16.sdp),
                      _buildGenderDropdown(),
                      SizedBox(height: 16.sdp),
                      EditText(
                        hint: "Add Website url",
                        hintStyle: 16.txtRegularGrey,
                        inputType: TextInputType.url,
                        radius: 20,
                        prefixIcon: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.link,
                              size: 20.sdp,
                              color: AppColors.grey,
                            ),
                          ],
                        ),
                        margin: 16.bottom,
                        controller: webUrlController,
                        validator: (value) {
                          if (!value.isNotNullEmpty) {
                            return null;
                          } else if (!value!.isURL) {
                            return 'Please enter valid website url';
                          }
                          return null;
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return CountryPickerDropdown(
                                onCountrySelected: (String country) {
                                  setState(() {
                                    _selectedCountry = country;
                                  });
                                },
                              );
                            },
                          );
                        },
                        child: Container(
                          height: 56.sdp,
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 16.sdp),
                          margin: EdgeInsets.only(bottom: 16.sdp),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(20.sdp),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 20.sdp,
                                color: AppColors.grey,
                              ),
                              SizedBox(width: 12.sdp),
                              Expanded(
                                child: Text(
                                  _selectedCountry?.isNotEmpty ?? false
                                      ? _selectedCountry!
                                      : 'Enter location',
                                  style: TextStyle(
                                    color:
                                        (_selectedCountry?.isNotEmpty ?? false)
                                        ? Colors.black
                                        : Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      EditText(
                        hint: "Add some description...",
                        hintStyle: 16.txtRegularGrey,
                        inputType: TextInputType.multiline,
                        radius: 20,
                        noOfLines: 4,
                        prefixIcon: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: 16.sdp),
                            Icon(
                              Icons.description_outlined,
                              size: 20.sdp,
                              color: AppColors.grey,
                            ),
                          ],
                        ),
                        margin: 16.bottom,
                        controller: bioController,
                      ),
                      SizedBox(height: 30),
                      AppButton(
                        label: AppStrings.update.tr,
                        labelStyle: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        buttonColor: AppColors.greenlight,
                        onTap: () => _updateProfile(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Obx(
      () => Container(
        height: 56.sdp,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.sdp),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(20.sdp),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(Icons.person_outline, size: 20.sdp, color: AppColors.grey),
            SizedBox(width: 12.sdp),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: isNull(profileCtrl.profileData.value.gender)
                      ? 'Male'
                      : profileCtrl.profileData.value.gender.isNotNullEmpty
                      ? profileCtrl.profileData.value.gender
                      : 'Male',
                  hint: Text(
                    'Select Gender',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  items: ["Male", "Female", "Other"].map((String gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(
                        gender,
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    );
                  }).toList(),
                  onChanged: (selectedGender) {
                    profileCtrl.profileData.value = profileCtrl
                        .profileData
                        .value
                        .copyWith(gender: selectedGender);
                    profileCtrl.profileData.refresh();
                  },
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down, color: AppColors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateOfBirthPicker() {
    return Obx(
      () => GestureDetector(
        onTap: _selectDateOfBirth,
        child: Container(
          height: 56.sdp,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.sdp),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(20.sdp),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 20.sdp,
                color: AppColors.grey,
              ),
              SizedBox(width: 12.sdp),
              Expanded(
                child: Text(
                  _formattedDateOfBirth(),
                  style: TextStyle(
                    color: _formattedDateOfBirth() == "DD, MM YYYY"
                        ? Colors.grey
                        : Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formattedDateOfBirth() {
    final dobString = profileCtrl.profileData.value.dob;
    if (dobString != null && dobString.isNotEmpty) {
      try {
        final parsedDate = DateTime.parse(dobString);
        return DateFormat('dd, MMM yyyy').format(parsedDate);
      } catch (e) {
        AppUtils.log('Error parsing date: $e');
        return "Invalid Date";
      }
    } else {
      return "DD, MM YYYY";
    }
  }

  Future<void> _selectDateOfBirth() async {
    final dob = profileCtrl.profileData.value.dob;

    final DateTime today = DateTime.now();
    final DateTime initialDate = dob.isNotNullEmpty
        ? dob!.yyyyMMdd
        : DateTime(today.year - 18, today.month, today.day);

    DateTime? pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: initialDate,
      firstDate: today.subtract(Duration(days: 365 * 100)),
      lastDate: initialDate,
    );

    if (pickedDate != null) {
      profileCtrl.profileData.value = profileCtrl.profileData.value.copyWith(
        dob: DateFormat('yyyy-MM-dd').format(pickedDate),
      );
      profileCtrl.profileData.refresh();
    }
  }

  void _showImagePicker(BuildContext context) {
    appBSheet(
      context,
      EditImageBSheetView(
        onItemTap: (source) async {
          Navigator.pop(context);
          final path = await _imagePickerOpen(source.imageSource);
          if (path.isNotNullEmpty) {
            profileImageData.value.file = path;
            profileImageData.value.type = ImageType.file;
            profileImageData.refresh();
            // selectedImagePath.value = path; // Store the selected image path
            // profileCtrl.profileData.value =
            //     profileCtrl.profileData.value.copyWith(image: path);
            // profileCtrl.profileData.refresh();
          }
        },
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      child: EditText(
        hint: "Enter Phone Number",
        hintStyle: 16.txtRegularGrey,
        inputType: TextInputType.phone,
        radius: 20,
        prefixIcon: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_outlined, size: 20.sdp, color: AppColors.grey),
          ],
        ),
        controller: phoneCtrl,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter your phone number';
          }
          return null;
        },
      ),
    );
  }

  Future<String?> _imagePickerOpen(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    return image?.path;
  }

  void _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      AppLoader.showLoader(context);

      String selectedCountryCode = "+${countryCode.value}";
      String selectedFlagEmoji = countryData.value?.flagEmoji ?? '';
      AppUtils.log("??????????${selectedFlagEmoji}${selectedCountryCode}");
      await profileCtrl.updateProfile(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneCtrl.text.trim(),
        countryCode: "${selectedFlagEmoji}${selectedCountryCode}",
        country: _selectedCountry,
        webSite: webUrlController.getText,
        bio: bioController.getText,
        dob: profileCtrl.profileData.value.dob ?? "",
        gender: profileCtrl.profileData.value.gender ?? "Other",
        image: profileCtrl.profileData.value.image,
        localImage: profileImageData.value.file,
      );

      AppLoader.hideLoader(context);
      AppUtils.toast("Profile Update Successfully");

      await Future.delayed(Duration(milliseconds: 100));

      await profileCtrl.getProfileDetails();

      profileCtrl.profileData.refresh();

      AppUtils.log(
        "Updated Profile Image After API Call: ${profileCtrl.profileData.value.image}",
      );

      context.pop();
      context.pop();

      // context.pushAndClearNavigator(HomeScreen());
    }
  }
}

Widget editProfileTextFormField(
  String label,
  TextEditingController controller,
  TextInputType type, {
  bool readOnly = false,
  VoidCallback? onTap,
  EditText? field,
  TextStyle labelStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  ),
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: labelStyle),
      const SizedBox(height: 8),
      field ??
          TextFormField(
            controller: controller,
            keyboardType: type,
            readOnly: readOnly,
            onTap: onTap,
            decoration: InputDecoration(border: OutlineInputBorder()),
          ),
    ],
  );
}




// flutter: │ 🐛 {
// flutter: │ 🐛   "status": true,
// flutter: │ 🐛   "code": 200,
// flutter: │ 🐛   "message": "Login success",
// flutter: │ 🐛   "data": {
// flutter: │ 🐛     "user": {
// flutter: │ 🐛       "name": "",
// flutter: │ 🐛       "username": "",
// flutter: │ 🐛       "email": "",
// flutter: │ 🐛       "role": "user",
// flutter: │ 🐛       "countryCode": "",
// flutter: │ 🐛       "socialType": "iOS",
// flutter: │ 🐛       "socialId": "000514.0f0e308914b3416da57aa4afdbc9c6da.0911",
// flutter: │ 🐛       "dob": null,
// flutter: │ 🐛       "isNotification": true,
// flutter: │ 🐛       "isOnline": true,
// flutter: │ 🐛       "followers": [],
// flutter: │ 🐛       "following": [],
// flutter: │ 🐛       "blockUser": [],
// flutter: │ 🐛       "gender": "Male",
// flutter: │ 🐛       "seeMyProfile": "everyBody",
// flutter: │ 🐛       "shareMyPost": "everyBody",
// flutter: │ 🐛       "isActive": false,
// flutter: │ 🐛       "isBlocked": false,
// flutter: │ 🐛       "isBlockedByAdmin": false,
// flutter: │ 🐛       "deviceType": "android",
// flutter: │ 🐛       "deviceToken": "d1Lcio0R7UOSszwFo_DDE6:APA91bFvA8YrdZV_FWUam_m9nLQVkkOpjpZ8cQzHyNqlX3k3AcNHm2gf5ty_XBn__9fmKsnFfBy452QjP9InBhxDNEJcRRFzR_InGJdMvss-YPVNnX6LCTU",
// flutter: │ 🐛       "isDelete": false,
// flutter: │ 🐛       "stripeCustomerId": null,
// flutter: │ 🐛       "stripeAccountId": null,
// flutter: │ 🐛       "walletBalance": 0,
// flutter: │ 🐛       "_id": "68776d0beb035f622fff2bc3",
// flutter: │ 🐛       "createdAt": "2025-07-16T09:12:43.205Z",
// flutter: │ 🐛       "updatedAt": "2025-07-16T09:12:43.205Z",
// flutter: │ 🐛       "__v": 0
// flutter: │ 🐛     },
// flutter: │ 🐛     "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2ODc3NmQwYmViMDM1ZjYyMmZmZjJiYzMiLCJlbWFpbCI6IiIsImlhdCI6MTc1MjY1NzE2MywiZXhwIjoxNzU1MjQ5MTYzfQ.nX8C35oS0VuGKC0p8QbBBw66DILmcuDO2EyK1ZMWHBA"
// flutter: │ 🐛   }
// flutter: │ 🐛 }


