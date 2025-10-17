//
// import 'dart:io';
//
// import 'package:country_picker/country_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:intl_phone_number_input/intl_phone_number_input.dart';
// import 'package:sep/components/styles/textStyles.dart';
// import 'package:sep/feature/data/models/dataModels/profile_data/profile_data_model.dart';
// import 'package:sep/feature/presentation/Home/homeScreen.dart';
// import 'package:sep/services/networking/urls.dart';
// import 'package:sep/utils/appUtils.dart';
// import 'package:sep/utils/extensions/contextExtensions.dart';
// import 'package:sep/utils/extensions/extensions.dart';
// import 'package:sep/utils/extensions/size.dart';
// import 'package:sep/utils/extensions/widget.dart';
// import '../../../../components/appLoader.dart';
// import '../../../../components/coreComponents/AppButton.dart';
// import '../../../../components/coreComponents/EditText.dart';
// import '../../../../components/coreComponents/ImageView.dart';
// import '../../../../components/coreComponents/TextView.dart';
// import '../../../../components/coreComponents/appBSheet.dart';
// import '../../../../components/coreComponents/appBar2.dart';
// import '../../../../components/coreComponents/editProfileImage.dart';
// import '../../../../components/styles/appColors.dart';
// import '../../../../components/styles/appImages.dart';
// import '../../../../components/styles/app_strings.dart';
// import '../../../../core/core/model/imageDataModel.dart';
// import '../../controller/auth_Controller/profileCtrl.dart';
// import '../../controller/auth_Controller/signup_controller.dart';
// import '../../screens/forgotpassword/signup/signup.dart';
//
// class EditProfile extends StatefulWidget {
//   const EditProfile({super.key});
//
//   @override
//   _EditProfileState createState() => _EditProfileState();
// }
//
// class _EditProfileState extends State<EditProfile> {
//   final ProfileCtrl profileCtrl = Get.find<ProfileCtrl>();
//   TextEditingController nameController= TextEditingController();
//   TextEditingController emailController= TextEditingController();
//   TextEditingController phoneController= TextEditingController();
//   final ImagePicker _picker = ImagePicker();
//   Country? selectedCountry;
//
//   final _formKey = GlobalKey<FormState>();
//   var selectedImagePath = "".obs;
//   PhoneNumber? initialNumber;
//   String? selectedCountryCode;
//   Rx<String?>countryCode = Rx(null);
//   final phoneCtrl = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
// AppUtils.log(profileCtrl.profileData.value.phone);
//
//     // profileCtrl.profileData.value.getMobileNumber.then((value){
//     //   phoneCtrl.text = value;
//     // });
//
//     updateCode();
//
//
//     nameController = TextEditingController(text: profileCtrl.profileData.value.name ?? "");
//     emailController = TextEditingController(text: profileCtrl.profileData.value.email ?? "");
//   }
//
//   void updateCode() async{
//     final value = await profileCtrl.profileData.value.countryCode;
//
//     final pp = (profileCtrl.profileData.value.phone ?? '').replaceAll('+', '');
//     phoneCtrl.text = pp.replaceFirst(value, '');
//
//
//     // setState(() {
//       countryCode.value = value;
//       countryCode.refresh();
//     // });
//
//
//
//
//     // profileCtrl.profileData.value.countryCode.then((value){
//     //   AppUtils.log(value);
//     //
//     //
//     //   setState(() {
//     //     countryCode.value = value;
//     //     countryCode.refresh();
//     //   });
//     // });
//   }
//
//
//   @override
//   void dispose() {
//     nameController.dispose();
//     emailController.dispose();
//     phoneController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.black,
//       body: Padding(
//         padding: const EdgeInsets.all(10.0),
//         child: Column(
//           children: [
//             AppBar2(
//               padding: EdgeInsets.only(top: 20),
//               titleAlign: TextAlign.center,
//               prefixImage: AppImages.backBtn,
//               title: AppStrings.editProfile.tr,
//               titleStyle: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white),
//               onPrefixTap: () => Get.back(),
//               suffixWidget: Container(width: 25),
//             ),
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       SizedBox(height: 10),
//                       Obx(() {
//                         final image = profileCtrl.profileData.value.image;
//                         AppUtils.log("Original Image Path: $image");
//
//                         bool isNetworkImage =
//                             image != null && image.startsWith("http");
//                         bool isServerImage = image != null &&
//                             image.startsWith("/public/uploads/");
//                         bool isFileImage = image != null &&
//                             image.startsWith("/") &&
//                             !isNetworkImage &&
//                             !isServerImage;
//                         bool isAssetImage = image == null || image.isEmpty;
//
//                         String finalImage = AppImages.editProfileImg;
//
//                         if (isNetworkImage) {
//                           finalImage = image;
//                         } else if (isServerImage) {
//                           finalImage = "$baseUrl$image";
//                         } else if (isFileImage) {
//                           finalImage = image;
//                         }
//
//                         AppUtils.log("Final Image Path: $finalImage");
//
//                         return CircleAvatar(
//                           key: UniqueKey(),
//                           radius: 50,
//                           backgroundImage: isNetworkImage || isServerImage
//                               ? NetworkImage(finalImage) as ImageProvider
//                               : isFileImage
//                               ? FileImage(File(finalImage)) as ImageProvider
//                               : AssetImage(AppImages.editProfileImg),
//                           child: isAssetImage
//                               ? ImageView(url: AppImages.editProfileImg)
//                               : null,
//                         );
//                       }),
//                       TextView(
//                         onTap: () => _showImagePicker(context),
//                         text: AppStrings.changePhoto.tr,
//                         style: 16.txtregularBtncolor,
//                         margin: EdgeInsets.only(top: 20, left: 20),
//                       ),
//
//                       Divider(thickness: 1, color: AppColors.white, height: 30),
//                       _buildTextField(
//                           "Name", nameController, TextInputType.name),
//                       _buildTextField(
//                           "Email", emailController, TextInputType.emailAddress,
//                           readOnly: true),
//
//                       _buildPhoneField(),
//
//                       Row(
//                         children: [
//                           TextView(
//                             textAlign: TextAlign.start,
//                             text: "Date of Birth",
//                             style: TextStyle(fontSize: 14, color: Colors.white),
//                             margin: EdgeInsets.symmetric(vertical: 10),
//                           ),
//                         ],
//                       ),
//
//                       _buildDateOfBirthPicker(),
//                       _buildGenderDropdown(),
//
//                       _buildTextField(
//                           "Email", emailController, TextInputType.emailAddress,
//                           readOnly: true),
//
//                       _buildTextField(
//                           "Email", emailController, TextInputType.emailAddress,
//                           readOnly: true),
//                       SizedBox(height: 30),
//                       AppButton(
//                         label: AppStrings.update.tr,
//                         labelStyle:
//                         TextStyle(fontSize: 18, color: Colors.white),
//                         buttonColor: AppColors.greenlight,
//                         onTap: () => _updateProfile(),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildGenderDropdown() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         TextView(
//           textAlign: TextAlign.start,
//           text: "Gender",
//           style: TextStyle(fontSize: 14, color: Colors.white),
//           margin: EdgeInsets.symmetric(vertical: 10),
//         ),
//         Obx(() => DropdownButtonFormField<String>(
//           value: profileCtrl.profileData.value.gender,
//           decoration: InputDecoration(
//             filled: true,
//             fillColor: Colors.white,
//             contentPadding:
//             EdgeInsets.symmetric(horizontal: 15, vertical: 12),
//             border:
//             OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//           ),
//           items: ["Male", "Female", "Other"].map((String gender) {
//             return DropdownMenuItem(
//               value: gender,
//               child: Text(gender, style: 15.txtBoldBlack),
//             );
//           }).toList(),
//           onChanged: (selectedGender) {
//             profileCtrl.profileData.value = profileCtrl.profileData.value
//                 .copyWith(gender: selectedGender);
//             profileCtrl.profileData.refresh();
//           },
//         )),
//       ],
//     );
//   }
//
//   Widget _buildDateOfBirthPicker() {
//     return Obx(() => GestureDetector(
//       onTap: _selectDateOfBirth,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
//         decoration: BoxDecoration(
//           border: Border.all(color: AppColors.white),
//           borderRadius: BorderRadius.circular(10),
//           color: AppColors.white,
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             TextView(text: _formattedDateOfBirth(), style: 15.txtBoldBlack),
//             ImageView(url: "assets/images/calender.png", size: 20),
//           ],
//         ),
//       ),
//     ));
//   }
//
//   Widget _buildTextField(
//       String label, TextEditingController controller, TextInputType type,
//       {bool readOnly = false, VoidCallback? onTap}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         TextView(
//           textAlign: TextAlign.start,
//           text: label,
//           style: TextStyle(fontSize: 14, color: Colors.white),
//           margin: EdgeInsets.symmetric(vertical: 10),
//         ),
//         GestureDetector(
//           onTap: onTap,
//           child: EditText(
//             hint: "Enter $label",
//             inputType: type,
//             controller: controller,
//             readOnly: readOnly,
//           ),
//         ),
//       ],
//     );
//   }
//
//   String _formattedDateOfBirth() {
//     final dobString = profileCtrl.profileData.value.dob;
//     if (dobString != null && dobString.isNotEmpty) {
//       try {
//         final parsedDate = DateTime.parse(dobString);
//         return DateFormat('dd, MMM yyyy').format(parsedDate);
//       } catch (e) {
//         AppUtils.log('Error parsing date: $e');
//         return "Invalid Date";
//       }
//     } else {
//       return "DD, MMM YYYY";
//     }
//   }
//
//   Future<void> _selectDateOfBirth() async {
//     DateTime? pickedDate = await showDatePicker(
//       context: Get.context!,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//     );
//
//     if (pickedDate != null) {
//       profileCtrl.profileData.value = profileCtrl.profileData.value.copyWith(
//         dob: DateFormat('yyyy-MM-dd').format(pickedDate),
//       );
//       profileCtrl.profileData.refresh();
//     }
//   }
//
//   void _showImagePicker(BuildContext context) {
//     appBSheet(
//       context,
//       EditImageBSheetView(
//         onItemTap: (source) async {
//           Navigator.pop(context);
//           final path = await _imagePickerOpen(source.imageSource);
//           if (path != null) {
//             selectedImagePath.value = path; // Store the selected image path
//             profileCtrl.profileData.value =
//                 profileCtrl.profileData.value.copyWith(image: path);
//             profileCtrl.profileData.refresh();
//           }
//         },
//       ),
//     );
//   }
//
//
//   // Widget _buildPhoneField() {
//   //   return Obx(
//   //         ()=> Visibility(
//   //           visible: countryCode.value != null,
//   //           child: PhoneField(
//   //                   phoneCtrl: phoneCtrl,
//   //                   countryCode: countryCode.value,
//   //                   onChange: (phoneCode,phoneNumber){
//   //           AppUtils.log('phoneCode +++ $phoneCode');
//   //           countryCode.value = phoneCode;
//   //                   },
//   //                 ),
//   //         ),
//   //   );
//   //
//   //
//   //
//   //x
//   // }
//
//
//   Widget _buildPhoneField() {
//     return Obx(
//           ()=> Visibility(
//         // visible: countryCode.value != null,
//         child: PhoneField(
//           phoneCtrl: phoneCtrl,
//           countryCode: countryCode.value,
//           onChange: (phoneCode,phoneNumber){
//             AppUtils.log('phoneCode +++ ${phoneCode} countryCode.value}');
//             AppUtils.log('phoneCode +++ ${countryCode.value}');
//             countryCode.value = phoneCode;
//           },
//         ),
//       ),
//     );
//
//
//
//
//   }
//
//
//
//   Future<String?> _imagePickerOpen(ImageSource source) async {
//     final XFile? image = await _picker.pickImage(source: source);
//     return image?.path;
//   }
//
//   void _updateProfile() async {
//     if (_formKey.currentState!.validate()) {
//       AppLoader.showLoader(context);
//
//       AppUtils.log("Selected Image Path: ${selectedImagePath.value}");
//       AppUtils.log(
//           "Existing Profile Image: ${profileCtrl.profileData.value.image}");
//
//       profileCtrl.profileData.value = profileCtrl.profileData.value.copyWith(
//         image: selectedImagePath.value.isNotEmpty
//             ? selectedImagePath.value
//             : profileCtrl.profileData.value.image,
//       );
//       profileCtrl.profileData.refresh();
//       AppUtils.log(
//           "Profile Image Updated Locally Before API: ${profileCtrl.profileData.value.image}");
//       // AppUtils.log('${countryCode.value}${phoneCtrl.getText}');
//       // return ;
//       await profileCtrl.updateProfile(
//         name: nameController.text.trim(),
//         email: emailController.text.trim(),
//         phone: '+${countryCode.value}${phoneCtrl.getText}'
//         // phoneController.text.trim()
//
//
//         ,
//         dob: profileCtrl.profileData.value.dob ?? "",
//         gender: profileCtrl.profileData.value.gender ?? "Other",
//         image: profileCtrl.profileData.value.image,
//         localImage: selectedImagePath.value,
//
//
//       );
//
//       AppLoader.hideLoader(context);
//       AppUtils.toast("Profile Update Successfully");
//
//       await Future.delayed(Duration(milliseconds: 100));
//
//       await profileCtrl.getProfileDetails();
//
//       // await profileCtrl.getProfileDetails();
//       profileCtrl.profileData.refresh();
//
//       AppUtils.log(
//           "Updated Profile Image After API Call: ${profileCtrl.profileData.value.image}");
//
//       context.pop();
//       context.pop();
//
//       // context.pushAndClearNavigator(HomeScreen());
//     }
//   }
// }
//
//
// // void _showCountryPicker() {
// //   showCountryPicker(
// //     context: context,
// //     showPhoneCode: true,
// //     onSelect: (Country country) {
// //       countryData.value = country;
// //       countryData.refresh();
// //       // setState(() {
// //       //   selectedCountry = country;
// //       //   phoneController.clear(); // Clear only phone number
// //       //   editpController.updateCountryCode('+${country.phoneCode}');
// //       // });
// //     },
// //     countryListTheme: CountryListThemeData(
// //       borderRadius: BorderRadius.circular(10.0),
// //       inputDecoration: InputDecoration(
// //         labelText: AppStrings.searchCountry.tr,
// //         prefixIcon: Icon(Icons.search),
// //         border: OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(8.0),
// //         ),
// //       ),
// //     ),
// //   );
// // }
//
//
//
//
//
// //   Column(
// //   crossAxisAlignment: CrossAxisAlignment.start,
// //   children: [
// //     TextView(
// //       textAlign: TextAlign.start,
// //       text: AppStrings.phone.tr,
// //       style: 14.txtRegularWhite,
// //       margin: 10.vertical,
// //     ),
// //     8.width,
// //     Row(
// //       children: [
// //         GestureDetector(
// //           onTap: _showCountryPicker,
// //           child: Obx(
// // ()=> Row(
// //               children: [
// //                 Text(countryData.value?.flagEmoji ?? '🌍', style: 20.txtMediumBlackText),
// //                 4.width,
// //                 Text(countryData.value?.phoneCode ?? '', style: 13.txtMediumBlackText),
// //                 Icon(Icons.keyboard_arrow_down),
// //               ],
// //             ),
// //           ),
// //         ),
// //         8.width,
// //         Expanded(
// //           child: EditText(
// //             hint: '',
// //             maxLength: 15, // Limit only for the phone number
// //             controller: phoneController,
// //             inputType: TextInputType.phone,
// //             inputFormat: [LengthLimitingTextInputFormatter(15)],
// //             onChange: (value) {
// //               editpController.updatePhone('${selectedCountry?.phoneCode ?? ''}$value');
// //             },
// //             validator: (value) {
// //               if (value == null || value.isEmpty) {
// //                 return AppStrings.pleaseEnterPhoneNumber.tr;
// //               } else if (!RegExp(r'^[0-9]{8,15}$').hasMatch(value)) {
// //                 return AppStrings.pleaseEnterValidPhoneNumber.tr;
// //               }
// //               return null;
// //             },
// //             margin: 10.bottom,
// //           ),
// //         ),
// //       ],
// //     ),
// //   ],
// // );