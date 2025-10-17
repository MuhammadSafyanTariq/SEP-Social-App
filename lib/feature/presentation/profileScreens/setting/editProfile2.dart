// import 'dart:io'; // Import this to handle File type
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:sep/components/styles/textStyles.dart';
// import 'package:sep/feature/data/repository/iAuthRepository.dart';
// import 'package:sep/feature/presentation/profileScreens/setting/setting.dart';
// import 'package:sep/utils/extensions/contextExtensions.dart';
// import 'package:sep/utils/extensions/extensions.dart';
// import 'package:sep/utils/extensions/size.dart';
// import 'package:sep/utils/extensions/textStyle.dart';
// import 'package:sep/utils/extensions/widget.dart';
// import '../../../../components/coreComponents/AppButton.dart';
// import '../../../../components/coreComponents/EditText.dart';
// import '../../../../components/coreComponents/ImageView.dart';
// import '../../../../components/coreComponents/TextView.dart';
// import '../../../../components/coreComponents/appBSheet.dart';
// import '../../../../components/coreComponents/appBar2.dart';
// import '../../../../components/coreComponents/appDropDown.dart';
// import '../../../../components/coreComponents/editProfileImage.dart';
// import '../../../../components/styles/appColors.dart';
// import '../../../../components/styles/appImages.dart';
// import '../../../../components/styles/app_strings.dart';
// import '../../../../core/core/model/imageDataModel.dart';
// import '../../../../services/storage/preferences.dart';
// import '../../../../utils/appUtils.dart';
// import '../../../../utils/extensions/dateTimeUtils.dart';
// import '../../controller/auth_Controller/profileCtrl.dart';
//
// class EditProfile2 extends StatefulWidget {
//
//   const EditProfile2({
//     super.key,
//   });
//
//   @override
//   _EditProfileState createState() => _EditProfileState();
// }
// class _EditProfileState extends State<EditProfile2> {
//   final ProfileCtrl profileCtrl = Get.find<ProfileCtrl>();
//
//   late TextEditingController nameController;
//   late TextEditingController emailController;
//   late TextEditingController phoneController;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Initialize controllers with initial values from profileData
//     nameController = TextEditingController(text: profileCtrl.profileData.value.name ?? "");
//     emailController = TextEditingController(text: profileCtrl.profileData.value.email ?? "");
//     phoneController = TextEditingController(text: profileCtrl.profileData.value.phone ?? "");
//   }
//
//   @override
//   void dispose() {
//     nameController.dispose();
//     emailController.dispose();
//     phoneController.dispose();
//     super.dispose();
//   }
//
//   final _formKey = GlobalKey<FormState>();
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
//               padding: 20.top,
//               titleAlign: TextAlign.center,
//               prefixImage: AppImages.backBtn,
//               title: AppStrings.editProfile.tr,
//               titleStyle: 20.txtBoldWhite,
//               onPrefixTap: () {
//                 context.pop();
//               },
//               suffixWidget: Container(width: 25),
//             ),
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       10.height,
//                       Obx(() => EditText(
//                         hint: 'Enter Email',
//                         readOnly: true, // Make email non-editable
//                         inputType: TextInputType.emailAddress,
//                         controller: TextEditingController(
//                           text: profileCtrl.profileData.value.email ?? "",
//                         ),
//                       )
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
// }
//
//
