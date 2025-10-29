import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import 'package:sep/utils/extensions/widget.dart';
import '../../../../components/coreComponents/AppButton.dart';
import '../../../../components/coreComponents/TextView.dart';
import '../../../../components/coreComponents/appBar2.dart';
import '../../../../components/styles/appColors.dart';
import '../../../../components/styles/appImages.dart';
import '../../../../components/styles/app_strings.dart';
import '../../../../services/networking/apiMethods.dart';
import '../../../../utils/appUtils.dart';
import '../../../data/repository/iAuthRepository.dart';
import 'signup/addProfile.dart';

class Otpscreen extends StatefulWidget {
  final String otp;
  final String email;

  Otpscreen({required this.otp, required this.email});

  @override
  _OtpscreenState createState() => _OtpscreenState();
}

class _OtpscreenState extends State<Otpscreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _controllers = [];
  late String currentOtp;
  final TextEditingController _pinController = TextEditingController();

  String get otp => currentOtp;

  @override
  void initState() {
    super.initState();
    currentOtp = widget.otp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBar2(
              prefixImage: AppImages.backBtn,
              leadIconSize: 16,
              onPrefixTap: context.pop,
              title: AppStrings.otp.tr,
              titleAlign: TextAlign.center,
              titleStyle: 25.txtBoldBlack,
              backgroundColor: AppColors.white,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 24),
              color: AppColors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextView(
                    margin: 16.left + 8.top + 12.bottom,
                    text: AppStrings.anOtp.tr,
                    style: 15.txtRegularGreyHint,
                  ),
                  40.height,
                  Center(child: Text("Testing OTP: $currentOtp".tr)),
                  40.height,
                  Form(
                    key: _formKey,
                    child: Center(
                      child: Pinput(
                        mainAxisAlignment: MainAxisAlignment.center,
                        controller: _pinController,
                        length: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            Get.snackbar(
                              'Validation Error',
                              'PIN cannot be empty',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.transparent,
                              colorText: Colors.black,
                              borderRadius: 8,
                              margin: 10.all,
                            );
                          }
                          if (value?.length != 4) {
                            Get.snackbar(
                              'Validation Error',
                              'PIN must be 4 digits',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.transparent,
                              colorText: Colors.black,
                              borderRadius: 8,
                              margin: 10.all,
                            );
                          }
                        },
                        onCompleted: (pin) {
                          AppUtils.log('PIN completed: $pin');
                        },
                        onChanged: (pin) {
                          AppUtils.log('PIN changed: $pin');
                        },
                      ),
                    ),

                    // Pinput(
                    //   crossAxisAlignment: CrossAxisAlignment.center,
                    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //   autofocus: true,
                    //   keyboardType: TextInputType.number,
                    //   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    //   validator: (s) {
                    //     if(s == null){
                    //       return 'Pin is incorrect';}
                    //     return s.length == 4? null : 'Pin is incorrect';
                    //   },
                    //   pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                    //   showCursor: true,
                    //   onCompleted: (pin) => print(pin)
                    //
                    //   ,
                    // )

                    // OTPFields(
                    //   onOtpChanged: (controllers) {
                    //     _controllers.clear();
                    //     _controllers.addAll(controllers);
                    //   },
                    // )
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextView(
                  textAlign: TextAlign.start,
                  margin: 20.right + 12.bottom,
                  text: AppStrings.resend.tr,
                  style: 15.txtMediumbtncolor,
                  onTap: () async {
                    final authService = IAuthRepository();
                    try {
                      // Show loader
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return Center(
                            child: SpinKitCircle(
                              color: AppColors.btnColor,
                              size: 50.0,
                            ),
                          );
                        },
                      );

                      AppUtils.log("Calling resend OTP API");

                      final response = await authService.resetPass(
                        email: widget.email,
                        otp: widget.otp,
                        id: "",
                      );

                      Navigator.of(context).pop();

                      if (response.isSuccess) {
                        setState(() {
                          final resendOtpModel = response.data!;
                          AppUtils.log(
                            'New OTP from response: ${resendOtpModel.data?.otp}',
                          );
                          currentOtp = resendOtpModel.data?.otp ?? '0000';
                        });
                        AppUtils.log(">>>>>$currentOtp");

                        Get.snackbar(
                          "Success",
                          "OTP resent to ${widget.email}",
                          backgroundColor: Colors.transparent,
                          colorText: Colors.black,
                        );
                      } else {
                        Get.snackbar(
                          "Error",
                          response.error?.toString() ?? "Failed to resend OTP",
                          backgroundColor: Colors.transparent,
                          colorText: Colors.black,
                        );
                      }
                    } catch (e) {
                      Navigator.of(context).pop();
                      Get.snackbar(
                        "Error",
                        "An unexpected error occurred. Please try again.",
                        backgroundColor: Colors.transparent,
                        colorText: Colors.black,
                      );
                    }
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 100),
              child: AppButton(
                buttonColor: AppColors.btnColor,
                labelStyle: 17.txtRegularWhite,
                margin: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 70,
                ),
                label: AppStrings.submit.tr,
                onTap: () async {
                  if (_formKey.currentState!.validate() &&
                      _pinController.getText.length == 4) {
                    // String enteredOtp = _controllers.map((controller) => controller.text).join();
                    String enteredOtp = _pinController.getText;

                    if (enteredOtp.length == 4) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return Center(
                            child: SpinKitCircle(
                              color: AppColors.btnColor,
                              size: 50.0,
                            ),
                          );
                        },
                      );

                      try {
                        final authService = IAuthRepository();
                        final response = await authService.otpVerify(
                          otp: enteredOtp,
                          email: widget.email,
                        );
                        Navigator.of(context).pop();

                        if (response.isSuccess) {
                          Get.snackbar(
                            "Success",
                            "OTP verification successful",
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.transparent,
                            colorText: Colors.black,
                            borderRadius: 10,
                            margin: const EdgeInsets.all(10),
                          );

                          // context.pushNavigator(AddProfile());
                        } else {
                          Get.snackbar(
                            "Error",
                            response.error?.toString() ??
                                "OTP verification failed",
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.transparent,
                            colorText: Colors.black,
                            borderRadius: 10,
                            margin: const EdgeInsets.all(10),
                          );
                        }
                      } catch (e) {
                        Navigator.of(context).pop();
                        Get.snackbar(
                          "Error",
                          "An unexpected error occurred. Please try again.",
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.transparent,
                          colorText: Colors.black,
                          borderRadius: 10,
                          margin: const EdgeInsets.all(10),
                        );
                      }
                    } else {
                      Get.snackbar(
                        "Error",
                        "Please enter a valid OTP in all fields",
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: Colors.transparent,
                        colorText: Colors.black,
                        borderRadius: 10,
                        margin: const EdgeInsets.all(10),
                      );
                    }
                  } else {
                    Get.snackbar(
                      "Error",
                      "Please enter valid otp",
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.transparent,
                      colorText: Colors.black,
                      borderRadius: 10,
                      margin: const EdgeInsets.all(10),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OTPFields extends StatefulWidget {
  final Function(List<TextEditingController>) onOtpChanged;

  OTPFields({required this.onOtpChanged});

  @override
  _OTPFieldsState createState() => _OTPFieldsState();
}

class _OTPFieldsState extends State<OTPFields> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  @override
  void initState() {
    super.initState();
    widget.onOtpChanged(_controllers);
  }

  @override
  Widget build(BuildContext context) {
    return true
        ? Pinput(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (s) {
              if (s == null) {
                return 'Pin is incorrect';
              }
              return s.length == 4 ? null : 'Pin is incorrect';
            },
            pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
            showCursor: true,
            onCompleted: (pin) => print(pin),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              return SizedBox(
                width: 60,
                child: Pinput(
                  autofocus: true,
                  length: 1,
                  // defaultPinTheme: defaultPinTheme,
                  // focusedPinTheme: focusedPinTheme,
                  // submittedPinTheme: submittedPinTheme,
                  validator: (s) {
                    return s == '2222' ? null : 'Pin is incorrect';
                  },
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  showCursor: true,
                  onCompleted: (pin) => print(pin),
                ),

                // TextFormField(
                //   controller: _controllers[index],
                //   focusNode: _focusNodes[index],
                //   keyboardType: TextInputType.number,
                //
                //   maxLength: 1,
                //   textAlign: TextAlign.center,
                //   style: const TextStyle(fontSize: 24),
                //   decoration: InputDecoration(
                //     counterText: "",
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //   ),
                //   validator: (value) {
                //     if (!value.isNotNullEmpty) {
                //       return '';
                //     }
                //     return null;
                //   },
                //   onChanged: (value) {
                //     if (value.isNotEmpty && index < 3) {
                //       _focusNodes[index + 1].requestFocus();
                //     } else if (value.isEmpty && index > 0) {
                //       _focusNodes[index - 1].requestFocus();
                //     }
                //     widget.onOtpChanged(_controllers);
                //   },
                // )
              );
            }),
          );
  }
}
