import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/auth_ctrl.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:country_picker/country_picker.dart';
import '../../../../../components/coreComponents/AppButton.dart';
import '../../../../../components/coreComponents/appBSheet.dart';
import '../../../../../components/coreComponents/editProfileImage.dart';
import '../../../../../components/coreComponents/EditText.dart';
import '../../../../../components/coreComponents/ImageView.dart';
import '../../../../../components/coreComponents/LogoWidget.dart';

import '../../../../../components/coreComponents/ProgressIndicator3Steps.dart';
import '../../../../../components/styles/appColors.dart';
import '../../../../../components/styles/appImages.dart';
import '../../../../../components/styles/app_strings.dart';
import '../../../../../core/core/model/imageDataModel.dart';
import '../../../../../utils/appUtils.dart';
import '../../../../../utils/inputFormats.dart';
import '../../../../data/repository/iAuthRepository.dart';
import '../../../controller/auth_Controller/signup_controller.dart';
import '../../loginsignup/login.dart';
import 'addProfile.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
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
              Text(AppStrings.signup.tr, style: 20.txtSBoldprimary),

              SizedBox(height: 8.sdp),

              // Description
              Text(
                AppStrings.signupDescription.tr,
                style: 12.txtMediumGreyText,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 16.sdp),

              // Progress Indicator
              ProgressIndicator3Steps(currentStep: 1),

              SizedBox(height: 12.sdp),

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
  _EmailLoginFormState createState() => _EmailLoginFormState();
}

class _EmailLoginFormState extends State<EmailLoginForm> {
  final SignupController signupController = Get.put(SignupController());
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final IAuthRepository authRepository = IAuthRepository();
  RxString _selectedCountryCode = RxString('+1 ');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Rx<ImageDataModel> imageData = Rx(ImageDataModel());
  RxBool isValid = RxBool(false);

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      signupController.updateName(_nameController.text);
    });
    _emailController.addListener(() {
      signupController.updateEmail(_emailController.text);
    });
    _phoneController.addListener(() {
      signupController.updatePhone(_phoneController.text);
      isValid.value = _formKey.currentState?.validate() ?? false;
    });
  }

  Future _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      String? imageUrl;

      // Upload image if one is selected
      if (imageData.value.file != null) {
        Future<String> uploadImage(File url) async {
          final response = await authRepository.uploadPhoto(imageFile: url);
          if (response.isSuccess) {
            return response.data!.first;
          } else {
            AppUtils.toastError(response.getError);
            throw '';
          }
        }

        imageUrl = await uploadImage(File(imageData.value.file!));
      }

      String fullPhoneNumber = _phoneController.text;
      signupController.updatePhone(fullPhoneNumber);

      await AuthCtrl.find
          .isEmailExist(_emailController.text)
          .then((value) {
            context.pushNavigator(
              AddProfile(
                imageUrl: imageUrl,
                countrycode: _selectedCountryCode.value,
              ),
            );
          })
          .catchError((error) {
            AppUtils.log("Email existence check failed: $error");
          });
      AppUtils.log("Full phone number: $fullPhoneNumber");
    } catch (e) {
      AppUtils.log("Error during form submission: $e");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        onChanged: () {
          isValid.value = _formKey.currentState?.validate() ?? false;
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Profile Image Section
            Center(
              child: Column(
                children: [
                  Obx(
                    () => EditProfileImage(
                      isEditable: true,
                      size: 120.sdp,
                      imageData: imageData.value,
                      radius: 60.sdp,
                      onChange: (newImage) async {
                        if (newImage.file != null) {
                          imageData.value = newImage;
                          imageData.refresh();

                          AppUtils.log("Image Path: ${newImage.file}");

                          try {
                            final File imageFile = File(
                              newImage.file as String,
                            );
                            final response = await authRepository.uploadPhoto(
                              imageFile: imageFile,
                            );

                            if (response.isSuccess) {
                              AppUtils.log(
                                "Image uploaded successfully: ${response.data}",
                              );
                            } else {
                              AppUtils.log(
                                "Image upload failed: ${response.error}",
                              );
                            }
                          } catch (e) {
                            AppUtils.log("Upload Error: $e");
                          }
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 12.sdp),
                  GestureDetector(
                    onTap: () => _showImagePicker(context),
                    child: Text(
                      AppStrings.uploadPhoto.tr,
                      style: 14.txtMediumbtncolor,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30.sdp),

            // Name Field
            EditText(
              hint: AppStrings.enterName.tr,
              hintStyle: 16.txtRegularGrey,
              inputType: TextInputType.text,
              radius: 20,
              prefixIcon: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 20.sdp,
                    color: AppColors.grey,
                  ),
                ],
              ),
              margin: 16.bottom,
              controller: _nameController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.pleaseEnterName.tr;
                }
                return null;
              },
            ),

            // Email Field
            EditText(
              hint: AppStrings.enterMail.tr,
              hintStyle: 16.txtRegularGrey,
              radius: 20,
              inputType: TextInputType.emailAddress,
              prefixIcon: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ImageView(
                    url: AppImages.email,
                    size: 20.sdp,
                    tintColor: AppColors.grey,
                  ),
                ],
              ),
              margin: 16.bottom,
              controller: _emailController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.pleaseEnterYourEmail.tr;
                }
                if (!value.isEmailAddress) {
                  return AppStrings.pleaseEnterValidEmail.tr;
                }
                return null;
              },
            ),
            SizedBox(height: 16.sdp),

            // Phone Field
            _buildPhoneField(),

            SizedBox(height: 30.sdp),

            _buildContinueButton(),

            SizedBox(height: 20.sdp),

            _buildSignInOption(),

            SizedBox(height: 20.sdp),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return PhoneField(
      phoneCtrl: _phoneController,
      onChange: (countryCode, phoneNumber) {
        _selectedCountryCode.value = countryCode;
      },
    );
  }

  Widget _buildContinueButton() {
    return Obx(() {
      return SizedBox(
        width: double.infinity,
        child: AppButton(
          label: AppStrings.cnontinue.tr,
          labelStyle: 16.txtsemiBoldWhite,
          height: 54.sdp,
          onTap: isValid.value
              ? () {
                  AppUtils.log("Continue button pressed - form is valid");
                  _submitForm().applyLoader;
                }
              : () {
                  AppUtils.log("Continue button pressed - form is invalid");
                  AppUtils.log("Name: ${_nameController.text}");
                  AppUtils.log("Email: ${_emailController.text}");
                  AppUtils.log("Phone: ${_phoneController.text}");
                },
          buttonColor: isValid.value
              ? AppColors.btnColor
              : AppColors.grey.withOpacity(0.3),
        ),
      );
    });
  }

  Widget _buildSignInOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(AppStrings.Already.tr, style: 14.txtMediumGreyText),
        SizedBox(width: 4.sdp),
        GestureDetector(
          onTap: () {
            context.pushAndClearNavigator(Login());
          },
          child: Text(AppStrings.signin.tr, style: 14.txtBoldBtnColor),
        ),
      ],
    );
  }

  void _showImagePicker(BuildContext context) {
    appBSheet(
      context,
      EditImageBSheetView(
        onItemTap: (source) async {
          Navigator.pop(context);
          final path = await _pickImage(source.imageSource);
          if (path != null) {
            imageData.value.file = path;
            imageData.value.type = ImageType.file;
            imageData.refresh();
          }
        },
      ),
    );
  }

  Future<String?> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      imageData.value.file = image.path;
      imageData.value.type = ImageType.file;
      imageData.refresh();

      AppUtils.log("Picked Image Path: ${image.path}");

      signupController.updateImage(image.path);
      return image.path;
    }
    return null;
  }
}

class PhoneField extends StatefulWidget {
  final String? countryCode;
  final String? phoneNumber;
  final TextEditingController phoneCtrl;
  final Function(String, String)? onChange;
  const PhoneField({
    super.key,
    this.countryCode,
    this.phoneNumber,
    this.onChange,
    required this.phoneCtrl,
  });

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField> {
  Rx<Country?> countryData = Rx(null);
  final CountryService _countryService = CountryService();
  List<Country> list = [];

  @override
  void initState() {
    super.initState();
    list = _countryService.getAll();
    _setInitialCountryByLocation();
  }

  Future<void> _setInitialCountryByLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          String? isoCountryCode = placemarks.first.isoCountryCode;
          AppUtils.log('User ISO Country Code: $isoCountryCode');

          if (isoCountryCode != null) {
            final index = list.indexWhere(
              (element) =>
                  element.countryCode.toUpperCase() ==
                  isoCountryCode.toUpperCase(),
            );
            if (index > -1) {
              countryData.value = list[index];
              countryData.refresh();
              widget.onChange?.call(
                countryData.value!.phoneCode,
                widget.phoneCtrl.getText,
              );
            }
          }
        }
      }
    } catch (e) {
      AppUtils.log('Location fetch failed: $e');
    }
  }

  Widget _buildCountryCodeDropdown() {
    return GestureDetector(
      onTap: () {
        showCountryPicker(
          context: context,
          showPhoneCode: true,
          onSelect: (Country country) {
            AppUtils.log(country.phoneCode);
            countryData.value = country;
            countryData.refresh();
            widget.onChange?.call(country.phoneCode, widget.phoneCtrl.getText);
          },
          countryListTheme: CountryListThemeData(
            borderRadius: BorderRadius.circular(10.0),
            inputDecoration: InputDecoration(
              labelText: AppStrings.searchCountry.tr,
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: AppColors.grey.withOpacity(0.6)),
          ),
        ),
        child: Obx(
          () => Row(
            children: [
              Text(
                countryData.value?.flagEmoji ?? '',
                style: TextStyle(fontSize: 26, color: AppColors.grey),
              ),
              Icon(Icons.keyboard_arrow_down, size: 20.sdp),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return EditText(
      hint: AppStrings.phone.tr,
      hintStyle: 16.txtRegularGrey,
      controller: widget.phoneCtrl,
      inputType: TextInputType.phone,
      inputFormat: InputFormats.phoneNo,
      maxLength: 15,
      radius: 20,
      prefixIcon: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.sdp),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCountryCodeDropdown(),
            SizedBox(width: 8.sdp),
            Obx(
              () => Text(
                countryData.value != null
                    ? '+${countryData.value!.phoneCode}'
                    : '',
                style: 16.txtRegularGrey,
              ),
            ),
            Container(
              height: 20.sdp,
              width: 1,
              color: AppColors.grey.withOpacity(0.3),
              margin: EdgeInsets.symmetric(horizontal: 8.sdp),
            ),
          ],
        ),
      ),
      validator: (value) {
        if (!value.isNotNullEmpty) {
          return AppStrings.pleaseEnterPhoneNumber.tr;
        } else if (!value.isPhone) {
          return AppStrings.pleaseEnterValidPhoneNumber.tr;
        } else if (value!.trim().length < 8) {
          return AppStrings.pleaseEnterValidPhoneNumber.tr;
        }
        return null;
      },
      onChange: (value) {
        widget.onChange?.call(
          countryData.value?.phoneCode ?? '',
          widget.phoneCtrl.text,
        );
      },
    );
  }
}
