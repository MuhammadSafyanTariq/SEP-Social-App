import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/presentation/Home/homeScreen.dart';
import 'package:sep/feature/presentation/screens/forgotpassword/signup/signup.dart';
import 'package:sep/feature/presentation/screens/loginsignup/termsWebViewScreen.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/dateTimeUtils.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../components/coreComponents/AppButton.dart';
import '../../../../components/coreComponents/EditText.dart';
import '../../../../components/coreComponents/ImageView.dart';
import '../../../../components/coreComponents/LogoWidget.dart';
import '../../../../components/coreComponents/TextView.dart';
import '../../../../components/styles/appColors.dart';
import '../../../../components/styles/appImages.dart';
import '../../../../components/styles/app_strings.dart';
import '../../../../utils/appUtils.dart';
import '../../../data/models/dataModels/auth_models/sociallogin_model.dart';
import '../../../data/repository/iAuthRepository.dart';
import '../../controller/auth_Controller/auth_ctrl.dart';
import '../forgotpassword/forgotPass.dart';
import '../loading.dart';
import 'package:flutter/gestures.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.sdp),
          child: Column(
            children: [
              // Logo
              const LogoWidget(),

              SizedBox(height: 20.sdp),

              // Title
              Text(AppStrings.login.tr, style: 20.txtSBoldprimary),

              SizedBox(height: 8.sdp),

              // Description
              Text(
                AppStrings.loginDescription.tr,
                style: 12.txtMediumGreyText,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 40.sdp),

              const Expanded(child: EmailLoginForm()),
            ],
          ),
        ),
      ),
    );
  }
}

class EmailLoginForm extends StatefulWidget {
  const EmailLoginForm({super.key});

  @override
  State<EmailLoginForm> createState() => _EmailLoginFormState();
}

class _EmailLoginFormState extends State<EmailLoginForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_updateButtonState);
    passwordController.addListener(_updateButtonState);
    //  _getFcmToken(); // Get FCM token on initialization
  }

  // Future<void> _getFcmToken() async {
  //   // Request permission for notifications
  //   NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
  //
  //   if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  //     print('User  granted permission');
  //
  //     // Get the FCM token
  //     String? fcmToken = await FirebaseMessaging.instance.getToken();
  //     print('FCM Token: $fcmToken');
  //
  //     // You can save the token to your backend or local storage if needed
  //   } else {
  //     print('User  declined or has not accepted permission');
  //   }
  // }
  void _updateButtonState() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1), () {
      setState(() {});
    });
  }

  bool get _isFormValid =>
      emailController.text.isNotEmpty && passwordController.text.isNotEmpty;

  @override
  void dispose() {
    // emailController.removeListener(_updateButtonState);
    // passwordController.removeListener(_updateButtonState);
    emailController.dispose();
    passwordController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final currentContext = context;
      AuthCtrl.find
          .login(emailController.text, passwordController.text)
          .applyLoader
          .then((value) {
            //  _getFcmToken();
            if (mounted) {
              currentContext.pushAndClearNavigator(HomeScreen());
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Email Field
            EditText(
              hint: AppStrings.email.tr,
              hintStyle: 16.txtRegularGrey,
              inputType: TextInputType.emailAddress,
              radius: 20,
              prefixIcon: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.sdp),
                child: ImageView(
                  url: AppImages.email,
                  size: 20.sdp,
                  tintColor: AppColors.grey,
                ),
              ),
              margin: EdgeInsets.only(bottom: 16.sdp),
              controller: emailController,
              validator: (value) {
                if (!value.isNotNullEmpty) {
                  return AppStrings.pleaseEnterYourEmail.tr;
                }
                if (!value.isEmailAddress) {
                  return AppStrings.pleaseEnterValidEmail.tr;
                }
                return null;
              },
            ),

            // Password Field
            EditText(
              controller: passwordController,
              hint: AppStrings.password.tr,
              inputType: TextInputType.visiblePassword,
              obscureText: true,
              radius: 20,
              prefixIcon: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.sdp),
                child: ImageView(
                  url: AppImages.password,
                  size: 20.sdp,
                  tintColor: AppColors.grey,
                ),
              ),
              validator: (value) {
                if (!value!.isNotNullEmpty) {
                  return AppStrings.pleaseEnterYourPassword.tr;
                }
                if (!value.isPassword) {
                  return AppStrings.passwordMustBeAtLeast.tr;
                }
                return null;
              },
              margin: EdgeInsets.only(bottom: 10.sdp),
            ),

            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(top: 8.sdp, bottom: 30.sdp),
                child: GestureDetector(
                  onTap: () {
                    context.pushNavigator(Forgotpass());
                  },
                  child: Text(
                    AppStrings.forgotPassword.tr,
                    style: 15.txtRegularbtncolor,
                  ),
                ),
              ),
            ),

            // Checkbox for Terms
            Row(
              children: [
                SizedBox(
                  width: 20,
                  child: Checkbox(
                    value: true,
                    onChanged: (value) {},
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: const BorderSide(
                      color: AppColors.primaryColor,
                      width: 2,
                    ),
                    checkColor: AppColors.white,
                    activeColor: AppColors.btnColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                SizedBox(width: 10.sdp),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: AppStrings.byContinueTermsCondition.tr + ' ',
                      style: 12.txtRegularGrey,
                      children: [
                        TextSpan(
                          text: AppStrings.termsOfUse,
                          style: 12.txtRegularbtncolor,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.to(() => TermsWebViewScreen());
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 30.sdp),

            // Login Button
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: AppStrings.login.tr,
                labelStyle: 16.txtsemiBoldWhite,
                height: 54.sdp,
                onTap: _isFormValid ? _submitForm : null,
                buttonColor: _isFormValid
                    ? AppColors.btnColor
                    : AppColors.greyHint.withValues(alpha: 0.3),
              ),
            ),

            SizedBox(height: 30.sdp),

            // Or Login With Divider
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: AppColors.grey.withValues(alpha: 0.3),
                    thickness: 1.sdp,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.sdp),
                  child: Text(AppStrings.orLogin.tr, style: 14.txtRegularGrey),
                ),
                Expanded(
                  child: Divider(
                    color: AppColors.grey.withValues(alpha: 0.3),
                    thickness: 1.sdp,
                  ),
                ),
              ],
            ),

            SizedBox(height: 30.sdp),

            // Social Login Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (Platform.isAndroid) ...[
                  GestureDetector(
                    onTap: () => _handleGoogleSignIn(context),
                    child: Container(
                      width: 60.sdp,
                      height: 60.sdp,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageView(url: AppImages.google, size: 24.sdp),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20.sdp),
                ],
                if (Platform.isIOS)
                  GestureDetector(
                    onTap: () async {
                      await _handleAppleSignIn(context);
                    },
                    child: Container(
                      width: 60.sdp,
                      height: 60.sdp,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageView(url: AppImages.apple, size: 24.sdp),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 40.sdp),

            // Sign Up Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppStrings.donthave.tr, style: 14.txtRegularGrey),
                SizedBox(width: 5.sdp),
                GestureDetector(
                  onTap: () {
                    context.pushNavigator(const Signup());
                  },
                  child: Text(
                    AppStrings.register.tr,
                    style: 14.txtRegularbtncolor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _handleGoogleSignIn(BuildContext context) async {
  try {
    AppUtils.log("Starting Google Sign-In...");

    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
    );

    // Sign out first to ensure clean state
    await googleSignIn.signOut();
    AppUtils.log("Signed out from previous session");

    final GoogleSignInAccount? account = await googleSignIn.signIn();

    if (account == null) {
      AppUtils.log("Google sign-in canceled by user.");
      AppUtils.toast("Sign-in cancelled.");
      return;
    }

    AppUtils.log("Google account selected: ${account.email}");

    final String email = account.email;
    final String? name = account.displayName;
    final String socialId = account.id;
    final String socialType = 'google';

    AppUtils.log("Google Sign-In Info:");
    AppUtils.log("Name: $name");
    AppUtils.log("Email: $email");
    AppUtils.log("Social ID: $socialId");
    AppUtils.log("Social Type: $socialType");

    AppUtils.log("Sending login request to API...");

    final response = await IAuthRepository().socialLogin(
      name: name,
      email: email,
      socialId: socialId,
      socialType: socialType,
    );

    AppUtils.log("API Response Success: ${response.isSuccess}");
    AppUtils.log("API Response Data: ${response.data}");
    AppUtils.log("API Response Error: ${response.error}");

    if (response.isSuccess) {
      final SocialloginModel userData = response.data!;
      AppUtils.log("Login Successful. User Data: ${userData.toJson()}");

      AppUtils.toast("${AppStrings.welcome.tr} $name!");
      context.pushAndClearNavigator(Loading());
    } else {
      final error = response.error ?? "Unknown error";
      AppUtils.log("Login Failed: $error");
      AppUtils.toastError("Login Failed: $error");
    }
  } on PlatformException catch (e) {
    AppUtils.log("PlatformException during Google Sign-In:");
    AppUtils.log("Error Code: ${e.code}");
    AppUtils.log("Error Message: ${e.message}");
    AppUtils.log("Error Details: ${e.details}");

    if (e.code == 'sign_in_failed') {
      AppUtils.toastError(
        "Google Sign-In failed. Please check your configuration and try again.",
      );
    } else if (e.code == 'network_error') {
      AppUtils.toastError("Network error. Please check your connection.");
    } else if (e.code == 'sign_in_canceled') {
      AppUtils.toast("Sign-in cancelled.");
    } else {
      AppUtils.toastError("Sign-in error: ${e.message ?? e.code}");
    }
  } catch (e, stackTrace) {
    AppUtils.log("Exception occurred during Google Sign-In: $e");
    AppUtils.log("StackTrace: $stackTrace");
    AppUtils.toastError("An error occurred. Please try again.");
  }
}

Future<void> _handleAppleSignIn(BuildContext context) async {
  try {
    final AuthorizationCredentialAppleID credential =
        await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

    final String? appleToken = credential.identityToken;
    final String email = credential.email ?? "";
    final String name =
        "${credential.givenName ?? ''} ${credential.familyName ?? ''}".trim();
    final String socialId = credential.userIdentifier ?? "";
    final String socialType = AppUtils.deviceType;

    AppUtils.log(
      "Apple Sign-In Info: Name: $name, Email: $email, Token: $appleToken, Social ID: $socialId, Social Type: $socialType",
    );
    final repo = IAuthRepository();
    final response = await repo.socialLogin(
      name: name,
      email: email,
      socialId: socialId,
      socialType: socialType,
      // savePreferences: false
    );
    if (response.isSuccess) {
      final SocialloginModel userData = response.data!;

      final user = userData.data?.user;
      final currentContext = context;
      if (user?.name.isNotNullEmpty ?? false) {
        repo.updatePreferences(user?.toJson() ?? {}, userData.data?.token);
        currentContext.pushAndClearNavigator(Loading());
      } else {
        final nameCtrl = TextEditingController(text: user?.name);
        final emailCtrl = TextEditingController(text: user?.email);

        final isNameEditable = nameCtrl.getText.isNotNullEmpty;
        final isEmailEditable = emailCtrl.getText.isNotNullEmpty;
        final key = GlobalKey<FormState>();
        currentContext.openBottomSheet(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: key,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextView(
                          text: 'Add Profile',
                          style: 16.txtBoldBtncolor,
                        ),
                      ),
                      ImageView(
                        onTap: () {
                          context.pop();
                        },
                        url: AppImages.crossbtn,
                        size: 20,
                      ),
                    ],
                  ),

                  EditText(
                    readOnly: isNameEditable,
                    margin: EdgeInsets.only(top: 20),
                    hint: 'Enter your name',
                    controller: nameCtrl,
                    validator: (value) {
                      return value.isNotNullEmpty
                          ? null
                          : 'Please enter your name';
                    },
                  ),
                  EditText(
                    readOnly: isEmailEditable,
                    margin: EdgeInsets.symmetric(vertical: 16),
                    hint: 'Enter your email address',
                    controller: emailCtrl,
                    validator: (value) {
                      return value.isEmailAddress
                          ? null
                          : 'Please enter valid email address';
                    },
                  ),

                  AppButton(
                    margin: EdgeInsets.only(top: 20),
                    label: 'Save',
                    onTap: () {
                      repo
                          .profileUpdate(
                            name: nameCtrl.getText,
                            email: emailCtrl.getText,
                            accessToken: userData.data?.token,
                            dob: DateTime.now().yyyyMMdd,
                          )
                          .applyLoader
                          .then((value) {
                            currentContext.pop();
                            repo.updatePreferences(
                              user?.toJson() ?? {},
                              userData.data?.token,
                            );
                            currentContext.pushAndClearNavigator(Loading());
                          });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }
      // if(userData.data?.user?.)

      AppUtils.log("User Data: \${userData.toJson()}");
      AppUtils.toast("${AppStrings.welcome.tr} $name!");

      // final SocialLoginDataModel userData = response.data!;
      //
      // final isProfileComplete = userData.data?.userData?.isProfileComplete;
      //
      // AppUtils.log("User Data: ${userData.toJson()}");
      // Get.snackbar(
      //   'Login Successful',
      //   'Welcome, ${userData.data?.userData?.name ?? 'User'}!',
      //   snackPosition: SnackPosition.TOP,
      //   backgroundColor: Colors.transparent,
      //   colorText: Colors.black,
      // );
      // context.pushAndClearNavigator(EditProfile(name: name, email: email, isProfileComplete: false,));
    } else {
      final error = response.error;
      AppUtils.log("Login Failed: $error");
      Get.snackbar(
        'Login Failed',
        '$error',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.transparent,
        colorText: Colors.black,
      );
    }
  } catch (e) {
    AppUtils.log("Exception occurred: $e");
    Get.snackbar(
      'Error',
      "$e",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.transparent,
      colorText: Colors.black,
    );
  }
}
