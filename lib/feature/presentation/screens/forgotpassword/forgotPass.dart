import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/widget.dart';
import '../../../../components/coreComponents/AppButton.dart';
import '../../../../components/coreComponents/EditText.dart';
import '../../../../components/coreComponents/ImageView.dart';
import '../../../../components/coreComponents/TextView.dart';
import '../../../../components/coreComponents/appBar2.dart';
import '../../../../components/styles/appColors.dart';
import '../../../../components/styles/appImages.dart';
import '../../../../components/styles/app_strings.dart';
import '../../../../utils/appUtils.dart';
import '../../../data/repository/iAuthRepository.dart';
import 'forgotPasswordOtpScreen.dart';

class Forgotpass extends StatefulWidget {
  Forgotpass({super.key});

  @override
  _ForgotpassState createState() => _ForgotpassState();
}

class _ForgotpassState extends State<Forgotpass> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  RxBool isValid = RxBool(false);

  void _updateEmailValidation() {
    isValid.value = _formKey.currentState?.validate() ?? false;
  }

  Future<int?> _forgotPassword(BuildContext context, String email) async {
    if (!_formKey.currentState!.validate()) return null;

    try {
      final authService = IAuthRepository();
      final response = await authService
          .forgotPassword(email: email)
          .applyLoader;

      if (response.isSuccess) {
        final otp = response.data?.data?.otp;
        final id = response.data?.data?.id;
        if (otp != null && id != null) {
          _showOtpBottomSheet(context, otp, email, id.toString());
        }
        return otp;
      } else {
        AppUtils.toastError(AppStrings.emailNotFound.tr);
        return null;
      }
    } catch (e) {
      AppUtils.log('Forgot Password API error: $e');
      AppUtils.toastError(AppStrings.somethingWentWrong.tr);
      return null;
    }
  }

  void _showOtpBottomSheet(
    BuildContext context,
    int otp,
    String email,
    String id,
  ) {
    showModalBottomSheet(
      isDismissible: false,
      enableDrag: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Forgotpasswordotpscreen(otp: '$otp', email: email, id: id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Padding(
        padding: 15.all,
        child: Form(
          key: _formKey,
          onChanged: _updateEmailValidation,
          child: Column(
            children: [
              AppBar2(
                prefixImage: AppImages.backBtn,
                leadIconSize: 16,
                onPrefixTap: context.pop,
                title: AppStrings.forgotPass.tr,
                titleAlign: TextAlign.center,
                titleStyle: 25.txtSBoldprimary,
                backgroundColor: AppColors.white,
              ),
              8.height,

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextView(
                    text: AppStrings.enterYourRegisteredEmail.tr,
                    margin: 25.top,
                    style: 12.txtRegularGrey,
                  ),
                  16.height,
                  EditText(
                    hint: AppStrings.enterMail.tr,
                    radius: 20,
                    inputType: TextInputType.emailAddress,
                    prefixIcon: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [ImageView(url: AppImages.email, size: 20.sdp)],
                    ),
                    controller: _emailController,
                    validator: (value) {
                      if (!value!.isNotNullEmpty) {
                        return AppStrings.pleaseEnterYourEmail.tr;
                      }
                      if (!value.isEmailAddress) {
                        return AppStrings.pleaseEnterValidEmail.tr;
                      }
                      return null;
                    },
                  ),

                  Obx(
                    () => AppButton(
                      buttonColor: isValid.value
                          ? AppColors.btnColor
                          : Colors.grey,
                      labelStyle: 17.txtRegularBlack,
                      margin: 20.vertical,
                      label: AppStrings.sendCode.tr,
                      onTap: isValid.value
                          ? () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                String email = _emailController.text.trim();
                                await _forgotPassword(context, email);
                              }
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
