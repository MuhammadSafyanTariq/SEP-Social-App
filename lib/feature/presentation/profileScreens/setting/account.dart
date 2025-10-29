// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:sep/utils/extensions/contextExtensions.dart';
// import 'package:sep/utils/extensions/size.dart';
// import 'package:sep/utils/extensions/textStyle.dart';
// import 'package:sep/utils/extensions/widget.dart';
// import '../../../../components/coreComponents/AppButton.dart';
// import '../../../../components/coreComponents/EditText.dart';
// import '../../../../components/coreComponents/ImageView.dart';
// import '../../../../components/coreComponents/TextView.dart';
// import '../../../../components/coreComponents/appBar2.dart';
// import '../../../../components/styles/appColors.dart';
// import '../../../../components/styles/appImages.dart';
// import '../../../../components/styles/app_strings.dart';
// import '../../../../utils/appUtils.dart';
// import '../../../data/models/dataModels/getUserDetailModel.dart';
// import '../../../data/models/dataModels/responseDataModel.dart';
// import '../../../data/repository/iAuthRepository.dart';
// import 'changePassSetting.dart';
// import 'editProfile.dart';
//
// class Account extends StatefulWidget {
//   const Account({super.key});
//
//   @override
//   _AccountState createState() => _AccountState();
// }
//
//
// class _AccountState extends State<Account> {
//   String? image;
//   String? name;
//   String? email;
//   String? phone;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchDetails();
//   }
//
//   Future<void> _fetchDetails() async {
//     // UserController.find.fetchUserDetails();
//     try {
//       final response = await IAuthRepository().getProfileDetails();
//       AppUtils.log('API Response:>>>>>>>>>>>>>>>>>>>>>>>>>>> $response');
//
//       if (response.isSuccess) {
//         image = response.data?.data.image ?? '';
//         name = response.data?.data.name ?? '';
//         email = response.data?.data.email ?? '';
//         phone = response.data?.data.phone ?? '';
//
//         AppUtils.log(">>>>>>>>>>>>>>>>$image");
//         setState(() {});
//       } else {
//         AppUtils.log('Failed to fetch user details: ${response.error}');
//       }
//     } catch (e) {
//       AppUtils.log('Error fetching details: $e');
//     }
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       body: Column(
//         children: [
//           AppBar2(
//             prefixImage: AppImages.backBtn,
//             title:AppStrings.myAccount.tr,
//             titleStyle: 20.txtMediumBlack,
//             suffixImage: AppImages.edit,
//             leadIconSize: 20,
//             onSuffixTap: () {
//               context.pushNavigator(EditProfile(name: name, email: email , phone: phone,image : image, isProfileComplete: false,));
//             },
//             onPrefixTap: () {
//               context.pop();
//             },
//           ),
//           Padding(
//             padding: 20.horizontal,
//             child: GetBuilder<UserController>(
//               builder: (ctrl) {
//                 return Column(
//                   children: [
//                     if (ctrl.image.value.isNotNullEmpty)
//                       ClipOval(
//                         child: Image.network(
//                           ctrl.image.value,
//                           height: 107.sdp,
//                           width: 107.sdp,
//                           fit: BoxFit.cover,
//                         ),
//                       )
//                     else
//                       ClipOval(
//                         child: ImageView(url: AppImages.prifileImg,size: 100,)
//                       ),
//
//
//                     20.height,
//                     const Divider(
//                       thickness: 0.5,
//                     ),
//                   ],
//                 );
//               }
//             ),
//           ),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: 20.horizontal,
//               child: GetBuilder<UserController>(
//                 builder: (ctrl) {
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       TextView(
//                         textAlign: TextAlign.start,
//                         text: AppStrings.name.tr,
//                         style: 14.txtRegularGrey,
//                         margin: 10.vertical,
//                       ),
//
//                       EditText(
//                         // textView: TextView(text: ctrl.name.value,),
//                         readOnly: true,
//                         hint: ctrl.name.value.tr,
//                         hintStyle: 16.txtRegularBlack,
//                         inputType: TextInputType.name,
//                         // controller: nameController,
//                       ),
//                       // EditText(
//                       //   hint: "$name",
//                       //   readOnly: true,
//                       //   inputType: TextInputType.text,
//                       //   controller: TextEditingController(),
//                       // ),
//                       TextView(
//                         textAlign: TextAlign.start,
//                         text: AppStrings.email.tr,
//                         style: 14.txtRegularGrey,
//                         margin: 10.vertical,
//                       ),
//
//                       EditText(
//                         readOnly: true,
//                         hint: ctrl.email.value.tr,
//                         hintStyle: 16.txtRegularBlack,
//                         inputType: TextInputType.name,
//                         // controller: emailController,
//                       ),
//                       // EditText(
//                       //   hint: "$email",
//                       //   readOnly: true,
//                       //   inputType: TextInputType.emailAddress,
//                       //   controller: TextEditingController(),
//                       // ),
//                       TextView(
//                         textAlign: TextAlign.start,
//                         text: AppStrings.phone.tr,
//                         style: 14.txtRegularGrey,
//                         margin: 10.vertical,
//                       ),
//
//                       EditText(
//                         readOnly: true,
//                         hintStyle: 16.txtRegularBlack,
//                         hint: "+91 ${ctrl.phone.value}".tr,
//                         inputType: TextInputType.name,
//                         // controller: phoneController,
//                       ),
//                       // EditText(
//                       //   hint: "$phone",
//                       //   readOnly: true,
//                       //   inputType: TextInputType.phone,
//                       //   controller: TextEditingController(),
//                       // ),
//                       30.height,
//                       const Divider(
//                         thickness: 0.5,
//                       ),
//                       AppButton(
//                         padding: 10.vertical,
//                         margin: 30.top,
//                         radius: 10,
//                         label: AppStrings.changepass.tr,
//                         labelStyle: 18.txtMediumbtncolor,
//                         buttonColor: AppColors.white,
//                         buttonBorderColor: AppColors.btnColor,
//                         prefix: Padding(
//                           padding: 20.right,
//                           child: ImageView(
//                             url: AppImages.password,
//                             height: 24.sdp,
//                             width: 24.sdp,
//                             tintColor: AppColors.btnColor,
//                           ),
//                         ),
//                         suffix: Padding(
//                           padding: 60.left,
//                           child: const Icon(
//                             Icons.keyboard_arrow_right,
//                             color: AppColors.btnColor,
//                           ),
//                         ),
//                         onTap: () {
//                           context.pushNavigator(const Changepasssetting());
//                         },
//                       ),
//                       AppButton(
//                         padding: 10.vertical,
//                         margin: 20.top,
//                         radius: 10,
//                         label: AppStrings.deleteAcc.tr,
//                         labelStyle: 18.txtMediumbtnred,
//                         buttonColor: AppColors.white,
//                         buttonBorderColor: AppColors.red,
//                         prefix: Padding(
//                           padding: 20.right,
//                           child: ImageView(
//                             url: AppImages.deleteimg,
//                             height: 24.sdp,
//                             width: 24.sdp,
//                             tintColor: AppColors.red,
//                           ),
//                         ),
//                         suffix: Padding(
//                           padding: 90.left,
//                           child: const Icon(
//                             Icons.keyboard_arrow_right,
//                             color: AppColors.red,
//                           ),
//                         ),
//                         onTap: () async {
//                           showDialog(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return AlertDialog(
//                                 buttonPadding: 10.all,
//                                 backgroundColor: AppColors.white,
//                                 title: TextView(
//                                   text:  AppStrings.deleteAcc.tr,
//                                   style: 24.txtBoldBtncolor,
//                                   textAlign: TextAlign.center,
//                                 ),
//                                 content: TextView(
//                                   text:
//                                   AppStrings.areYouSureToWantLogout.tr,
//                                   textAlign: TextAlign.center,
//                                   style: 16.txtRegularGrey,
//                                 ),
//                                 actionsAlignment: MainAxisAlignment.center,
//                                 actions: [
//                                   Row(
//                                     children: [
//                                       AppButton(
//                                         radius: 10.sdp,
//                                         width: 110.sdp,
//                                         label: AppStrings.no.tr,
//                                         labelStyle: 14.txtMediumbtncolor,
//                                         buttonColor: AppColors.white,
//                                         buttonBorderColor: AppColors.btnColor,
//                                         margin: 20.right,
//                                         onTap: context.pop,
//                                       ),
//                                       AppButton(
//                                         radius: 10.sdp,
//                                         width: 110.sdp,
//                                         label: AppStrings.yes.tr,
//                                         labelStyle: 14.txtMediumWhite,
//                                         buttonColor: AppColors.btnColor,
//                                         onTap: () async {
//                                           showDialog(
//                                             context: context,
//                                             barrierDismissible: false,
//                                             builder: (BuildContext context) {
//                                               return const Center(
//                                                 child: SpinKitCircle(
//                                                   color: AppColors.btnColor,
//                                                   size: 50.0,
//                                                 ),
//                                               );
//                                             },
//                                           );
//                                           // Navigator.pop(context);
//
//                                           try {
//                                             final response = await deleteAccount();
//                                             Navigator.pop(context);
//                                             if (response.isSuccess) {
//                                               Get.snackbar('Success'.tr,
//                                                   'Your account has been deleted.'.tr,
//                                                   snackPosition: SnackPosition.TOP,
//                                                   backgroundColor:
//                                                   Colors.transparent,
//                                                   colorText: Colors.black);
//                                               context.pushAndClearNavigator(const Login());
//                                             } else {
//                                               Get.snackbar('Error'.tr,
//                                                   'Failed to delete account.'.tr,
//                                                   snackPosition: SnackPosition.TOP,
//                                                   backgroundColor:
//                                                   Colors.transparent,
//                                                   colorText: Colors.black);
//                                             }
//                                           } catch (e) {
//                                             Navigator.pop(context);
//                                             Get.snackbar('Error'.tr,
//                                                 'An unexpected error occurred.'.tr,
//                                                 snackPosition: SnackPosition.TOP,
//                                                 backgroundColor: Colors.transparent,
//                                                 colorText: Colors.black);
//                                           }
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               );
//                             },
//                           );
//                         },
//                       ),
//                     ],
//                   );
//                 }
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// Future<ResponseData<Map<String, dynamic>>> deleteAccount() async {
//   try {
//     final response = await IAuthRepository().deleteAccount();
//
//     AppUtils.log("API response: ${response.isSuccess ? 'Success' : 'Failed'}");
//     AppUtils.log("API response error: ${response.error}");
//
//     if (response.isSuccess) {
//       await _clearUserData();
//       AppUtils.log('User deleted successfully.');
//     }
//     return response;
//   } catch (e) {
//     AppUtils.log('Delete exception: $e');
//     return ResponseData(
//       isSuccess: false,
//       error: Exception('Delete failed due to an exception: $e'),
//     );
//   }
// }
//
// Future<void> _clearUserData() async {
//   await Preferences.onLogout();
//   AppUtils.log('User data cleared from Preferences.');
// }
//
// Future<ResponseData<GetUserDetailModel>> getDetails() async {
//   try {
//     final response = await IAuthRepository().getProfileDetails();
//
//     if (response.isSuccess) {
//       AppUtils.log('fetch detail successfully.');
//     }
//     return response;
//   } catch (e) {
//     AppUtils.log('error: $e');
//     return ResponseData(
//       isSuccess: false,
//       error: Exception('error exception: $e'),
//     );
//   }
// }
