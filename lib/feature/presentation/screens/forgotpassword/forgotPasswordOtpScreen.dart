import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import '../../../../components/coreComponents/AppButton.dart';
import '../../../../components/coreComponents/ImageView.dart';
import '../../../../components/coreComponents/TextView.dart';
import '../../../../components/coreComponents/appBar2.dart';
import '../../../../components/styles/appColors.dart';
import '../../../../components/styles/app_strings.dart';
import '../../../../utils/appUtils.dart';
import '../../../data/repository/iAuthRepository.dart';
import 'resetPass.dart';

class Forgotpasswordotpscreen extends StatefulWidget {
  const Forgotpasswordotpscreen({
    super.key,
    required this.otp,
    required this.email,
    required this.id,
  });

  final String otp;
  final String email;
  final String id;

  @override
  State<Forgotpasswordotpscreen> createState() =>
      _ForgotpasswordotpscreenState();
}

class _ForgotpasswordotpscreenState extends State<Forgotpasswordotpscreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pinController = TextEditingController();
  late String currentOtp;

  RxBool _isValid = RxBool(false);

  String validOtp = '';

  @override
  void initState() {
    super.initState();
    currentOtp = widget.otp;
    validOtp = widget.otp;
  }

  Future<void> _resendOtp() async {
    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (BuildContext context) {
    //     return const Center(
    //       child: SpinKitCircle(
    //         color: AppColors.btnColor,
    //         size: 50.0,
    //       ),
    //     );
    //   },
    // );

    final authService = IAuthRepository();
    final response = await authService
        .forgotPassword(email: widget.email)
        .applyLoader;
    // Navigator.of(context).pop();

    if (response.isSuccess) {
      final otpResponse = response.data!;
      setState(() {
        currentOtp = otpResponse.data?.otp?.toString() ?? '';
      });

      validOtp = otpResponse.data?.otp?.toString() ?? '';

      // Get.snackbar(
      //   "Success".tr,
      //   'OTP sent to your email: ${widget.email}.'.tr,
      //   snackPosition: SnackPosition.TOP,
      //   backgroundColor: Colors.transparent,
      //   colorText: Colors.black,
      //   borderRadius: 10.sdp,
      //   margin: 10.all,
      // );
    } else {
      AppUtils.toastError(
        response.error?.toString() ?? AppStrings.failedToSendResend.tr,
      );

      // Get.snackbar(
      //   "Error".tr,
      //   response.error?.toString() ?? "Failed to resend OTP.".tr,
      //   snackPosition: SnackPosition.TOP,
      //   backgroundColor: Colors.transparent,
      //   colorText: Colors.black,
      //   borderRadius: 10.sdp,
      //   margin: 10.all,
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 0,
        // bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 45,
        ),
        // height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 50),
                Center(
                  child: Container(
                    width: 70,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 8.0,
                      left: 10,
                      top: 8,
                      right: 10,
                    ),
                    child: ImageView(url: 'assets/images/cross.png'),
                  ),
                ),
              ],
            ),
            AppBar2(
              backgroundColor: AppColors.white,
              onLeadTap: context.pop,
              title: AppStrings.verificationCode.tr,
              titleAlign: TextAlign.center,
              titleStyle: 25.txtSBoldprimary,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: TextView(
                margin: 45.left + 8.top + 40.right + 15.bottom,
                text: AppStrings.pleaseEnterCode.tr,
                style: 14.txtRegularBlack,
              ),
            ),
            Form(
              key: _formKey,
              onChanged: () {
                _isValid.value =
                    (_formKey.currentState?.validate() ?? false) &&
                    validOtp.trim() == _pinController.getText;
              },
              child: Pinput(
                mainAxisAlignment: MainAxisAlignment.center,
                controller: _pinController,
                length: 4,
                defaultPinTheme: PinTheme(
                  margin: EdgeInsets.only(right: 10, left: 10),
                  width: 58.sdp,
                  height: 55.sdp,
                  textStyle: 20.txtBoldBtncolor,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.Grey, width: 1),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(
                () => AppButton(
                  buttonColor: _isValid.value
                      ? AppColors.btnColor
                      : AppColors.greyHint.withValues(alpha: 0.3),
                  labelStyle: 17.txtMediumWhite,
                  margin: const EdgeInsets.symmetric(vertical: 30),
                  label: AppStrings.submit.tr,
                  onTap: () async {
                    if (_formKey.currentState!.validate() &&
                        _pinController.text.length == 4) {
                      final enteredOtp = _pinController.text;
                      final authService = IAuthRepository();
                      final response = await authService
                          .emailOtpVerify(otp: enteredOtp, id: widget.id)
                          .applyLoader;
                      AppUtils.log(
                        "otp >>>>>>>>$enteredOtp, id >>>>${widget.id}",
                      );
                      if (response.isSuccess) {
                        final id = widget.id;
                        AppUtils.log("msg>>>>>>>id ::: $id");

                        openResetPasswordBS(
                          context,
                          enteredOtp,
                          widget.email,
                          widget.id,
                        );
                      } else {
                        AppUtils.toastError(
                          response.error?.toString() ??
                              "OTP verification failed",
                        );
                      }
                    }
                  },
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextView(
                  text: AppStrings.didntReceiveOtp.tr,
                  style: 15.txtMediumprimary,
                ),
                TextView(
                  textAlign: TextAlign.start,
                  margin: 10.left,
                  text: AppStrings.resend.tr,
                  style: 15.txtMediumbtncolor,
                  onTap: _resendOtp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OTPFields extends StatefulWidget {
  final Function(List<TextEditingController>) onOtpChanged;

  const OTPFields({super.key, required this.onOtpChanged});

  @override
  _OTPFieldsState createState() => _OTPFieldsState();
}

class _OTPFieldsState extends State<OTPFields> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );

  @override
  void initState() {
    super.initState();
    widget.onOtpChanged(_controllers);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (index) {
        return SizedBox(
          width: 60,
          child: TextFormField(
            controller: _controllers[index],
            keyboardType: TextInputType.number,
            maxLength: 1,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24),
            decoration: InputDecoration(
              counterText: "",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.fieldIsRequired.tr;
              }
              return null;
            },
            onChanged: (value) {
              widget.onOtpChanged(_controllers);
            },
          ),
        );
      }),
    );
  }
}

void openResetPasswordBS(
  BuildContext context,
  String enteredOtp,
  String email,
  String id,
) {
  PasswordChangeController.find.reset();
  showModalBottomSheet(
    context: context,

    // barrierDismissible: false,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Container(
                    width: 70,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Resetpass(otp: enteredOtp, email: email, id: id),
              ),
            ],
          ),
        ),
      );
    },
  );
}
