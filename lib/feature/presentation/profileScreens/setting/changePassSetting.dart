import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import '../../../../components/coreComponents/AppButton.dart';
import '../../../../components/coreComponents/appBar2.dart';
import '../../../../components/coreComponents/common_password_input_field.dart';
import '../../../../components/styles/appColors.dart';
import '../../../../components/styles/appImages.dart';
import '../../../../components/styles/app_strings.dart';
import '../../../../utils/appUtils.dart';
import '../../../data/repository/iAuthRepository.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool isLoading = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  RxBool _isValid = RxBool(false);
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _currentPasswordController.addListener(_updateButtonState);
    _newPasswordController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      isButtonEnabled =
          _currentPasswordController.text.trim().isNotEmpty &&
          _newPasswordController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!formKey.currentState!.validate()) {
      AppUtils.log("Form validation failed");
      return;
    }

    String currentPassword = _currentPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();

    try {
      AppUtils.log("Calling change password API...");
      final authService = IAuthRepository();
      final response = await authService
          .changePasswordProfile(
            oldpassword: currentPassword,
            newpassword: newPassword,
          )
          .applyLoader;

      if (response.isSuccess) {
        AppUtils.log("Password changed successfully!");
        AppUtils.toast("Password Changed Successfully");
        context.pop();
      } else {
        AppUtils.log("Password change failed: ${response.error}");
        AppUtils.toastError("Passwords do not match");
      }
    } catch (e) {
      AppUtils.log("Error: $e");
      AppUtils.toastError(AppStrings.anErrorOccurred.tr);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar2(
          backgroundColor: AppColors.white,
          prefixImage: AppImages.backBtn,
          title: AppStrings.changepass.tr,
          titleStyle: 20.txtMediumBlack,
          onPrefixTap: () {
            context.pop();
          },
          suffixWidget: Container(width: 30),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: 20.left + 20.right,
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  CommonPasswordInputField(
                    marginBottom: 16,
                    controller: _currentPasswordController,
                    hint: "Current Password",
                    radius: 20.sdp,
                    validator: (value) {
                      final trimmedValue = value?.trim() ?? '';
                      if (trimmedValue.isEmpty)
                        return AppStrings.pleaseEnterYourPassword.tr;
                      if (trimmedValue.contains(' '))
                        return AppStrings.passwordMustNotContainSpace.tr;
                      if (!trimmedValue.isPassword)
                        return AppStrings.passwordMustBeAtLeast.tr;
                      return null;
                    },
                  ),
                  CommonPasswordInputField(
                    controller: _newPasswordController,
                    hint: AppStrings.newPassword.tr,
                    radius: 20.sdp,
                    validator: (value) {
                      final trimmedValue = value?.trim() ?? '';
                      if (trimmedValue.isEmpty)
                        return AppStrings.pleaseEnterYourPassword.tr;
                      if (trimmedValue.contains(' '))
                        return AppStrings.passwordMustNotContainSpace.tr;
                      if (!trimmedValue.isPassword)
                        return AppStrings.passwordMustBeAtLeast.tr;
                      return null;
                    },
                  ),
                  AppButton(
                    margin: 30.top,
                    label: AppStrings.update.tr,
                    labelStyle: 18.txtMediumWhite,
                    buttonColor: isButtonEnabled
                        ? AppColors.btnColor
                        : Colors.grey,
                    onTap: isButtonEnabled ? _updatePassword : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
