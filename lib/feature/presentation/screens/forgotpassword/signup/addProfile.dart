import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sep/components/coreComponents/EditText.dart';
import 'package:sep/components/coreComponents/appDropDown.dart';
import 'package:sep/components/coreComponents/LogoWidget.dart';
import 'package:sep/components/coreComponents/ProgressIndicator3Steps.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/widget.dart';
import 'package:sep/utils/extensions/dateTimeUtils.dart';
import '../../../../../components/coreComponents/AppButton.dart';
import '../../../../../components/coreComponents/ImageView.dart';
import '../../../../../components/styles/appColors.dart';
import '../../../../../components/styles/appImages.dart';
import '../../../../../components/styles/app_strings.dart';
import '../../../../../core/core/model/imageDataModel.dart';
import '../../../Add post/countryPickerDropdown.dart';
import '../../../controller/auth_Controller/auth_ctrl.dart';
import '../../../controller/auth_Controller/signup_controller.dart';
import '../../loading.dart';
import '../../loginsignup/privacyWebViewScreen.dart';
import '../../loginsignup/termsWebViewScreen.dart';

class AddProfile extends StatefulWidget {
  final String? imageUrl;
  final String? countrycode;
  const AddProfile({super.key, this.imageUrl, this.countrycode});

  @override
  _AddProfileState createState() => _AddProfileState();
}

class _AddProfileState extends State<AddProfile> {
  final SignupController signupController = Get.put(SignupController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();

  bool isCheckedTerms = false;
  bool isCheckedPrivacy = false;
  int currentSection = 1; // 1 for profile section, 2 for password section

  bool get isButtonEnabled => isCheckedTerms && isCheckedPrivacy;
  bool isLoading = false;
  ImageDataModel imageData = ImageDataModel(asset: AppImages.prifileImg);
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  TextEditingController webUrlController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  RxString dateOfBirth = RxString('');
  String gender = AppStrings.male.tr;
  Timer? _debounce;
  String? _selectedCountry;

  @override
  void initState() {
    super.initState();

    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      AppUtils.log("Received Image URL: ${widget.imageUrl}");
      signupController.updateImage(widget.imageUrl!);
    } else {
      AppUtils.log("No image URL received.");
    }
  }

  void _updateButtonState() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1), () {
      setState(() {});
    });
  }

  String formatDateOfBirth(String dob) {
    if (dob.isNotEmpty) {
      try {
        DateTime date = DateTime.parse(dob);
        return DateFormat('MM/dd/yyyy').format(date);
      } catch (e) {
        return "";
      }
    }
    return dob;
  }

  void showErrorDialog(String message) {
    AppUtils.toastError(Exception(message));
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime today = DateTime.now();
    final DateTime initialDate = DateTime(
      today.year - 18,
      today.month,
      today.day,
    );

    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today.subtract(Duration(days: 365 * 100)),
      lastDate: initialDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.greenlight, // Header background color
              primaryContainer: AppColors.greenlight, // Selected day background
              secondary: AppColors.greenlight, // Selected day text color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Default text color
              surface: Colors.white, // Calendar background
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.greenlight, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      dateOfBirth.value = selectedDate.yyyyMMdd;
    }
  }

  Future _submitProfile() async {
    try {
      AppUtils.log("=== STARTING REGISTRATION PROCESS ===");

      AppUtils.log("🔍 Step 1: Checking _passwordFormKey");
      AppUtils.log("  - _passwordFormKey: $_passwordFormKey");
      AppUtils.log(
        "  - _passwordFormKey.currentState: ${_passwordFormKey.currentState}",
      );

      // Since we're in a multi-section form, only validate the current section
      // The profile section was already validated when user moved from section 1 to section 2

      AppUtils.log("🔍 Current section: $currentSection");

      if (currentSection == 1) {
        // Validate profile form (first section)
        AppUtils.log("🔍 Step 2: Checking profile form");
        final formState = _formKey.currentState;
        if (formState == null) {
          AppUtils.log("❌ Profile form state is null!");
          showErrorDialog("Form validation error. Please try again.");
          return;
        }

        AppUtils.log("🔍 Step 3: Validating profile form");
        if (!formState.validate()) {
          AppUtils.log("❌ Profile form validation failed");
          return;
        }
      } else {
        // We're in section 2 (password section)
        // Validate password form
        AppUtils.log("🔍 Step 2: Checking password form");
        final passwordFormState = _passwordFormKey.currentState;
        if (passwordFormState == null) {
          AppUtils.log("❌ Password form state is null!");
          showErrorDialog("Form validation error. Please try again.");
          return;
        }

        AppUtils.log("🔍 Step 3: Validating password form");
        if (!passwordFormState.validate()) {
          AppUtils.log("❌ Password form validation failed");
          return;
        }
      }

      if (!isCheckedTerms) {
        AppUtils.log("❌ Terms not accepted");
        showErrorDialog(AppStrings.pleaseAcceptTerms.tr);
        return;
      }

      if (!isCheckedPrivacy) {
        AppUtils.log("❌ Privacy policy not accepted");
        showErrorDialog(AppStrings.pleaseAgreePrivacyPolicy.tr);
        return;
      }

      if (dateOfBirth.value.isEmpty) {
        AppUtils.log("❌ Date of birth not provided");
        showErrorDialog(AppStrings.pleaseEnterDateOfBirth.tr);
        return;
      }

      if (gender.isEmpty) {
        AppUtils.log("❌ Gender not selected");
        showErrorDialog(AppStrings.pleaseSelectGender.tr);
        return;
      }

      AppUtils.log("✅ All validations passed, starting registration...");
      AppUtils.log("📋 Registration Data:");
      AppUtils.log("  - Name: ${signupController.name.value}");
      AppUtils.log("  - Email: ${signupController.email.value}");
      AppUtils.log("  - Phone: ${signupController.phone.value}");
      AppUtils.log("  - Country Code: ${widget.countrycode ?? ""}");
      AppUtils.log("  - Date of Birth: ${dateOfBirth.value}");
      AppUtils.log("  - Gender: $gender");
      AppUtils.log("  - Country: ${_selectedCountry ?? ''}");
      AppUtils.log("  - Image path: ${signupController.imagePath.value}");
      AppUtils.log("  - Bio: ${bioController.text.trim()}");
      AppUtils.log("  - Website: ${webUrlController.text.trim()}");

      // Set loading state
      setState(() {
        isLoading = true;
      });

      AppUtils.log("🔄 Calling AuthCtrl.register...");

      // Debug null checks before registration
      AppUtils.log("🔍 Debugging potential null values:");
      AppUtils.log("  - AuthCtrl.find: ${AuthCtrl.find}");
      AppUtils.log("  - signupController: $signupController");
      AppUtils.log("  - signupController.name: ${signupController.name}");
      AppUtils.log(
        "  - signupController.name.value: ${signupController.name.value}",
      );
      AppUtils.log("  - signupController.email: ${signupController.email}");
      AppUtils.log(
        "  - signupController.email.value: ${signupController.email.value}",
      );
      AppUtils.log("  - signupController.phone: ${signupController.phone}");
      AppUtils.log(
        "  - signupController.phone.value: ${signupController.phone.value}",
      );
      AppUtils.log("  - widget.countrycode: ${widget.countrycode}");
      AppUtils.log("  - _passwordController: $_passwordController");
      AppUtils.log("  - _passwordController.text: ${_passwordController.text}");
      AppUtils.log("  - dateOfBirth: $dateOfBirth");
      AppUtils.log("  - dateOfBirth.value: ${dateOfBirth.value}");
      AppUtils.log("  - gender: $gender");
      AppUtils.log("  - _selectedCountry: $_selectedCountry");
      AppUtils.log(
        "  - signupController.imagePath: ${signupController.imagePath}",
      );
      AppUtils.log(
        "  - signupController.imagePath.value: ${signupController.imagePath.value}",
      );
      AppUtils.log("  - bioController: $bioController");
      AppUtils.log("  - bioController.text: ${bioController.text}");
      AppUtils.log("  - webUrlController: $webUrlController");
      AppUtils.log("  - webUrlController.text: ${webUrlController.text}");

      // Get AuthController
      final authController = AuthCtrl.find;

      // All validations passed, proceed with registration
      await authController
          .register(
            signupController.name.value,
            signupController.email.value,
            signupController.phone.value,
            widget.countrycode ?? "",
            _passwordController.text.trim(),
            dateOfBirth.value,
            gender,
            _selectedCountry ?? '',
            signupController.imagePath.value,
            bioController.text.trim(),
            webUrlController.text.trim(),
            signupController.referralCode.value,
          )
          .applyLoader;

      // If we reach here, registration was successful
      AppUtils.log("✅ Registration completed successfully!");
      AppUtils.log("🔄 Navigating to loading screen...");

      if (mounted) {
        context.pushAndClearNavigator(Loading());
        AppUtils.log("✅ Navigation completed");
      } else {
        AppUtils.log("❌ Widget is not mounted, cannot navigate");
      }
    } catch (e) {
      AppUtils.log("❌ Registration failed with error: $e");
      AppUtils.log("❌ Error type: ${e.runtimeType}");
      AppUtils.log("❌ Stack trace: ${StackTrace.current}");

      if (mounted) {
        setState(() {
          isLoading = false;
        });
        AppUtils.log("🔄 Loading state reset to false");
      }

      // Provide user-friendly error messages
      String errorMessage = "Registration failed. Please try again.";

      if (e.toString().contains("500") ||
          e.toString().toLowerCase().contains("server error")) {
        errorMessage =
            "Server error occurred. Our team is working on it. Please try again later or contact support.";
      } else if (e.toString().toLowerCase().contains("network") ||
          e.toString().toLowerCase().contains("connection")) {
        errorMessage =
            "Network error. Please check your internet connection and try again.";
      } else if (e.toString().toLowerCase().contains("email") &&
          e.toString().toLowerCase().contains("exists")) {
        errorMessage =
            "This email is already registered. Please use a different email or try logging in.";
      } else if (e.toString().isNotEmpty &&
          !e.toString().toLowerCase().contains("exception")) {
        errorMessage = "Registration failed: ${e.toString()}";
      }

      showErrorDialog(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.sdp),
          child: Column(
            children: [
              // Top section same as signup screen
              _buildTopSection(),

              // Content sections
              Expanded(
                child: currentSection == 1
                    ? _buildFirstSection()
                    : _buildSecondSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Column(
      children: [
        // Logo
        const LogoWidget(),

        SizedBox(height: 20.sdp),

        // Title
        Text(AppStrings.addProfile.tr, style: 20.txtSBoldprimary),

        SizedBox(height: 8.sdp),

        // Description
        Text(
          AppStrings.signupDescription.tr,
          style: 12.txtMediumGreyText,
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 16.sdp),

        // Progress Indicator - Step 2 of 3
        ProgressIndicator3Steps(currentStep: 2),

        SizedBox(height: 20.sdp),
      ],
    );
  }

  Widget _buildFirstSection() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateOfBirthField(),
            8.height,
            _buildGenderDropdown(),
            8.height,
            EditText(
              hint: "Add Website url",
              inputType: TextInputType.url,
              controller: webUrlController,
              radius: 20,
              validator: (value) {
                if (!value.isNotNullEmpty) {
                  return null;
                } else if (!value!.isURL) {
                  return 'Please enter valid website url';
                }
                return null;
              },
            ),
            16.height,
            EditText(
              hint: "Add some description...",
              inputType: TextInputType.multiline,
              noOfLines: 4,
              controller: bioController,
              radius: 20,
            ),
            16.height,
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
                height: 54,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.centerLeft,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _selectedCountry?.isNotEmpty ?? false
                            ? _selectedCountry!
                            : 'Enter location',
                        style: TextStyle(
                          color: (_selectedCountry?.isNotEmpty ?? false)
                              ? Colors.black
                              : Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: ImageView(url: AppImages.locations, size: 50.sdp),
                    ),
                  ],
                ),
              ),
            ),

            20.height,

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: AppStrings.cnontinue.tr,
                labelStyle: 16.txtsemiBoldWhite,
                height: 54.sdp,
                buttonColor: AppColors.btnColor,
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      currentSection = 2;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondSection() {
    return SingleChildScrollView(
      child: Form(
        key: _passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPasswordField(),

            _buildConfirmPasswordField(),

            20.height,

            GestureDetector(
              onTap: () {
                context.pushNavigator(TermsWebViewScreen());
              },
              child: _buildCheckbox(
                AppStrings.acceptTermAndConditions.tr,
                isChecked: isCheckedTerms,
                onChanged: (value) {
                  setState(() => isCheckedTerms = value!);
                },
              ),
            ),

            10.height,

            GestureDetector(
              onTap: () {
                context.pushNavigator(Privacywebviewscreen());
              },
              child: _buildCheckbox(
                AppStrings.iAgreePrivacyPolicy.tr,
                isChecked: isCheckedPrivacy,
                onChanged: (value) {
                  setState(() => isCheckedPrivacy = value!);
                },
              ),
            ),

            30.height,

            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateOfBirthField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => EditText(
            radius: 20,
            suffixIcon: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ImageView(url: "assets/images/calender.png", size: 20.sdp),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: ImageView(
                url: AppImages.birth,
                size: 18,
                margin: 15.right + 12.left,
              ),
            ),
            hint: AppStrings.dateSelect.tr,
            controller: TextEditingController(
              text: dateOfBirth.value.isNotNullEmpty
                  ? dateOfBirth.value.yyyyMMdd.ddcMMcyyyy
                  : "",
            ),
            readOnly: true,
            onTap: _selectDateOfBirth,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.pleaseEnterYourDate.tr;
              }
              return null;
            },
            margin: 10.bottom,
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      margin: EdgeInsets.only(bottom: 10.sdp),
      child: AppDropDown.singleSelect(
        list: [AppStrings.male.tr, AppStrings.female.tr, AppStrings.other.tr],
        selectedValue: gender,
        hint: AppStrings.selectGender.tr,
        onSingleChange: (selectedValue) {
          setState(() {
            gender = selectedValue;
          });
        },
        singleValueBuilder: (value) => value,
        itemBuilder: (value) => value,
        isFilled: true,
        borderColor: AppColors.grey.withOpacity(0.3),

        radius: 20,
        error: "",
        prefixIcon: ImageView(
          url: AppImages.gender,
          size: 20,
          margin: 10.right,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return EditText(
      controller: _passwordController,
      hint: AppStrings.enterPassword.tr,
      inputType: TextInputType.visiblePassword,
      obscureText: true,
      radius: 20,
      prefixIcon: Padding(
        padding: 16.all,
        child: ImageView(url: AppImages.password, size: 16.sdp),
      ),
      validator: (value) {
        _updateButtonState();
        final trimmedValue = value?.trim() ?? '';
        if (trimmedValue.isEmpty) return AppStrings.pleaseEnterYourPassword.tr;
        if (trimmedValue.contains(' '))
          return AppStrings.passwordMustNotContainSpace.tr;
        if (!trimmedValue.isPassword)
          return AppStrings.passwordMustBeAtLeast.tr;
        return null;
      },
      margin: EdgeInsets.only(bottom: 20.sdp),
    );
  }

  Widget _buildConfirmPasswordField() {
    return EditText(
      controller: _confirmPasswordController,
      hint: AppStrings.confirmYourPass.tr,
      inputType: TextInputType.visiblePassword,
      obscureText: true,
      radius: 20,
      prefixIcon: Padding(
        padding: 16.all,
        child: ImageView(url: AppImages.password, size: 16.sdp),
      ),
      validator: (value) {
        _updateButtonState();
        final trimmedValue = value?.trim() ?? '';
        if (trimmedValue.isEmpty) return AppStrings.pleaseConfirmYourPass.tr;
        if (trimmedValue.contains(' '))
          return AppStrings.passwordMustNotContainSpace.tr;
        if (!trimmedValue.isPassword)
          return AppStrings.passwordMustBeAtLeast.tr;
        if (trimmedValue != _passwordController.text.trim())
          return AppStrings.passwordDoNotMatch.tr;
        return null;
      },
      margin: EdgeInsets.only(top: 10.sdp),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: AppButton(
        label: isLoading ? "Submitting..." : AppStrings.submit.tr,
        labelStyle: 16.txtsemiBoldWhite,
        height: 54.sdp,
        buttonColor: (isButtonEnabled && !isLoading)
            ? AppColors.btnColor
            : Colors.grey,
        onTap: (isButtonEnabled && !isLoading)
            ? () async {
                AppUtils.log("Submit button pressed");
                AppUtils.log("Gender: $gender");
                AppUtils.log("Date of Birth: ${dateOfBirth.value}");
                AppUtils.log("Name: ${signupController.name.value}");
                AppUtils.log("Email: ${signupController.email.value}");
                AppUtils.log("Phone: ${signupController.phone.value}");
                AppUtils.log("Image path: ${signupController.imagePath.value}");

                await _submitProfile();
              }
            : !isLoading
            ? () {
                // Show validation errors when button is disabled
                AppUtils.log("Submit button pressed but conditions not met");
                if (!isCheckedTerms || !isCheckedPrivacy) {
                  if (!isCheckedTerms) {
                    showErrorDialog(AppStrings.pleaseAcceptTerms.tr);
                  } else if (!isCheckedPrivacy) {
                    showErrorDialog(AppStrings.pleaseAgreePrivacyPolicy.tr);
                  }
                } else {
                  // Force validation to show field errors
                  _passwordFormKey.currentState!.validate();
                  _formKey.currentState!.validate();
                }
              }
            : null, // Disable button completely when loading
      ),
    );
  }
}

Widget _buildCheckbox(
  String label, {
  required bool isChecked,
  required ValueChanged<bool?> onChanged,
}) {
  return Container(
    alignment: Alignment.centerLeft,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          child: Checkbox(
            splashRadius: 5,
            value: isChecked,
            onChanged: onChanged,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: const BorderSide(color: AppColors.primaryColor, width: 2),
            checkColor: AppColors.black,
            activeColor: AppColors.btnColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: label.contains("Terms")
                  ? AppStrings.iAccept.tr
                  : AppStrings.iAgree.tr,
              style: 14.txtRegularGrey,
              children: [
                TextSpan(
                  text: label.contains("Terms")
                      ? AppStrings.termsandCondation.tr
                      : AppStrings.privacyPolicy.tr,
                  style: 14.txtRegularbtncolor,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
