import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/loaderUtils.dart';
import 'package:sep/utils/extensions/size.dart';
import '../../../../components/coreComponents/AppButton.dart';
import '../../../../components/coreComponents/ImageView.dart';
import '../../../../components/coreComponents/common_password_input_field.dart';
import '../../../../components/styles/appColors.dart';
import '../../../../components/styles/appImages.dart';
import '../../../../components/styles/app_strings.dart';
import '../../../../utils/appUtils.dart';
import '../../../data/repository/iAuthRepository.dart';
import '../loginsignup/login.dart';

class PasswordChangeController extends GetxController {
  static PasswordChangeController get find =>
      Get.put(PasswordChangeController(), permanent: true);
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();

  reset() {
    passwordController.clear();
    confirmPasswordController.clear();
    isValidReset.value = false;
  }

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  RxBool isValidReset = RxBool(false);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> changePassword(
    BuildContext context,
    String email,
    String otp,
    String id,
  ) async {
    if (!formKey.currentState!.validate()) {
      AppUtils.log("Form validation failed");
      return;
    }

    AppUtils.log("User ID: $id");

    try {
      final authService = IAuthRepository();
      AppUtils.log("Calling change password API");

      final response = await authService
          .resetPass(
            email: email,
            otp: otp,
            newPassword: passwordController.text.trim(),
            id: id,
          )
          .applyLoader;
      if (response.isSuccess) {
        LoaderUtils.show();
        AppUtils.toast(" Your Password is Reset SuccessFully");
        context.pushAndClearNavigator(Login());
        LoaderUtils.dismiss();
      } else {
        AppUtils.toastError(
          response.error?.toString() ?? 'Something went wrong',
        );
      }
    } catch (e) {
      AppUtils.toastError("Failed to change password: $e");
    } finally {
      // isLoading.value = false;
    }
  }
}

// Function to show reset password bottom sheet
void showResetPasswordBottomSheet(
  BuildContext context,
  String email,
  String otp,
  String? id,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Resetpass(email: email, otp: otp, id: id),
  );
}

class Resetpass extends StatelessWidget {
  Resetpass({super.key, required this.otp, required this.email, this.id});

  final String otp;
  final String email;
  final String? id;

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => PasswordChangeController());
    final PasswordChangeController controller = Get.find();
    return Container(
      height: ContextExtensionss(context).height * 0.4,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.sdp),
          topRight: Radius.circular(20.sdp),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20),
          // Header with title and close button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.sdp),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.all(8.sdp),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.sdp),
                      border: Border.all(color: AppColors.greenlight),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.greenlight,
                      size: 16.sdp,
                    ),
                  ),
                ),
                SizedBox(width: 16.sdp),
                Expanded(
                  child: Text(
                    AppStrings.resetPassword.tr,
                    style: 20.txtSBoldprimary,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.sdp),

          // Form content
          Flexible(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(
                left: 20.sdp,
                right: 20.sdp,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20.sdp,
              ),
              child: Form(
                key: controller.formKey,
                onChanged: () {
                  controller.isValidReset.value =
                      (controller.formKey.currentState?.validate() ?? false);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommonPasswordInputField(
                      controller: controller.passwordController,
                      hint: AppStrings.enterPassword.tr,
                      inputType: TextInputType.visiblePassword,
                      radius: 20.0,
                      leading: Padding(
                        padding: EdgeInsets.all(16.sdp),
                        child: ImageView(url: AppImages.password, size: 16.sdp),
                      ),
                      validator: (value) => (value?.trim().isEmpty ?? true)
                          ? AppStrings.pleaseEnterYourPassword.tr
                          : null,
                      marginBottom: 16.sdp,
                    ),
                    CommonPasswordInputField(
                      controller: controller.confirmPasswordController,
                      hint: AppStrings.confirmYourPass.tr,
                      inputType: TextInputType.visiblePassword,
                      radius: 20.0,
                      leading: Padding(
                        padding: EdgeInsets.all(16.sdp),
                        child: ImageView(url: AppImages.password, size: 16.sdp),
                      ),
                      validator: (value) => (value?.trim().isEmpty ?? true)
                          ? AppStrings.pleaseConfirmYourPass.tr
                          : (value != controller.passwordController.text.trim())
                          ? AppStrings.passwordDoNotMatch.tr
                          : null,
                      marginBottom: 30.sdp,
                    ),
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          buttonColor: controller.isValidReset.value
                              ? AppColors.btnColor
                              : AppColors.greyHint.withOpacity(0.3),
                          labelStyle: 16.txtsemiBoldWhite,
                          height: 54.sdp,
                          label: controller.isLoading.value
                              ? AppStrings.processing.tr
                              : AppStrings.submit.tr,
                          onTap: () {
                            if (controller.passwordController.text
                                    .trim()
                                    .isNotEmpty &&
                                controller.confirmPasswordController.text
                                    .trim()
                                    .isNotEmpty &&
                                controller.passwordController.text.trim() ==
                                    controller.confirmPasswordController.text
                                        .trim()) {
                              controller.changePassword(
                                context,
                                email,
                                otp,
                                id!,
                              );
                            } else {
                              AppUtils.toastError(AppStrings.pleaseFillBoth.tr);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
