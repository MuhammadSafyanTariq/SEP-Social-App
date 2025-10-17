import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:sep/components/coreComponents/AppBar2.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/presentation/controller/settings_ctrl/settingscontroller.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import '../../../../../components/coreComponents/AppButton.dart';
import '../../../../../components/styles/appColors.dart';
import '../../../../../core/core/model/imageDataModel.dart';
import '../../../../../utils/appUtils.dart';
import '../../../../data/repository/iAuthRepository.dart';
import '../../../controller/auth_Controller/signup_controller.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final IAuthRepository authRepository = IAuthRepository();
  Rx<ImageDataModel> imageData = Rx(ImageDataModel());
  final SignupController signupController = Get.put(SignupController());

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController messageController = TextEditingController();
  String? selectedOption;
  File? _selectedImage;
  bool isLoading = false;
  String? uploadedImageUrl;

  final List<String> feedbackOptions = [
    "Bug Report",
    "Performance Issues",
    "Feature Request",
    "UI/UX Feedback",
    "Other",
  ];

  Future<String?> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      imageData.value = ImageDataModel(file: image.path, type: ImageType.file);
      imageData.refresh();
      AppUtils.log("Picked Image Path: ${image.path}");
      signupController.updateImage(image.path);
      return image.path;
    }
    return null;
  }

  void _showFeedbackOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.sdp),
              topRight: Radius.circular(20.sdp),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12.sdp),
                width: 40.sdp,
                height: 4.sdp,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.sdp),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.all(16.sdp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.btnColor,
                        ),
                      ),
                    ),
                    Text("Feedback Type", style: 18.txtMediumBlack),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Done",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.btnColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: Colors.grey[200]),

              // Options list
              Container(
                constraints: BoxConstraints(maxHeight: 300.sdp),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: feedbackOptions.length,
                  itemBuilder: (context, index) {
                    final option = feedbackOptions[index];
                    final isSelected = selectedOption == option;

                    return Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.btnColor.withOpacity(0.1)
                            : Colors.transparent,
                      ),
                      child: ListTile(
                        title: Text(
                          option,
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected
                                ? AppColors.btnColor
                                : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check,
                                color: AppColors.btnColor,
                                size: 20.sdp,
                              )
                            : null,
                        onTap: () {
                          setState(() {
                            selectedOption = option;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 20.sdp),
            ],
          ),
        );
      },
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.sdp),
              topRight: Radius.circular(20.sdp),
            ),
          ),
          child: Wrap(
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 12.sdp, bottom: 20.sdp),
                  width: 40.sdp,
                  height: 4.sdp,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.sdp),
                  ),
                ),
              ),

              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.sdp),
                  decoration: BoxDecoration(
                    color: AppColors.btnColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.sdp),
                  ),
                  child: Icon(Icons.camera_alt, color: AppColors.btnColor),
                ),
                title: Text('Camera', style: 16.txtMediumBlack),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),

              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.sdp),
                  decoration: BoxDecoration(
                    color: AppColors.btnColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.sdp),
                  ),
                  child: Icon(Icons.photo_library, color: AppColors.btnColor),
                ),
                title: Text('Gallery', style: 16.txtMediumBlack),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),

              SizedBox(height: 20.sdp),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitFeedback() async {
    if (messageController.text.isEmpty) {
      AppUtils.toastError("Message cannot be empty");
      return;
    }

    if (_formKey.currentState!.validate() && selectedOption != null) {
      setState(() => isLoading = true);

      if (imageData.value.file != null) {
        File selectedFile = File(imageData.value.file!);
        AppUtils.log("Uploading image: ${selectedFile.path}");

        try {
          final response = await authRepository
              .uploadPhoto(imageFile: selectedFile)
              .applyLoader;

          if (response.isSuccess) {
            AppUtils.log("Image uploaded successfully: ${response.data}");

            final Map<String, dynamic>? responseData =
                response.data as Map<String, dynamic>?;

            if (responseData != null && responseData.containsKey("data")) {
              final Map<String, dynamic>? data = responseData["data"];

              if (data != null && data.containsKey("urls")) {
                final List<dynamic>? urls = data["urls"];

                if (urls != null && urls.isNotEmpty) {
                  uploadedImageUrl = urls.first;
                  AppUtils.log("Uploaded Image URL: $uploadedImageUrl");
                } else {
                  AppUtils.log("Image uploaded, but no URLs returned.");
                }
              } else {
                AppUtils.log("Response does not contain 'urls' key.");
              }
            } else {
              AppUtils.log("Invalid API response format.");
            }
          } else {
            AppUtils.log("Image upload failed: ${response.error}");
          }
        } catch (e) {
          AppUtils.log("Upload Error: $e");
        }
      } else {
        AppUtils.log("No image uploaded, proceeding without an image.");
      }

      try {
        await SettingsCtrl.find
            .feedbacck(
              selectedOption!,
              messageController.text,
              uploadedImageUrl ?? '',
            )
            .applyLoader
            .then((value) {
              context.pop();
            });
        AppUtils.toast("Your Feedback added successfully");
      } catch (e) {
        AppUtils.log("Error submitting feedback: $e");
      }
      setState(() => isLoading = false);
    } else {
      if (selectedOption == null) {
        AppUtils.toastError("Please select a feedback type.");
      } else {
        AppUtils.log("Form is not valid or option is not selected");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          AppBar2(
            title: "Feedback",
            titleStyle: 18.txtMediumBlack,
            prefixImage: "back",
            onPrefixTap: () => Navigator.pop(context),
            backgroundColor: Colors.white,
            hasTopSafe: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.sdp),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _showFeedbackOptionsBottomSheet,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.sdp),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.sdp),
                          border: Border.all(
                            color: AppColors.grey.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedOption ?? "Feedback For",
                              style: selectedOption != null
                                  ? 16.txtMediumBlack
                                  : TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                    ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey[600],
                              size: 24.sdp,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.sdp),
                    TextFormField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: "Write your feedback",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.sdp),
                          borderSide: BorderSide(
                            color: AppColors.grey.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.sdp),
                          borderSide: BorderSide(
                            color: AppColors.grey.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.sdp),
                          borderSide: BorderSide(color: AppColors.btnColor),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.all(16.sdp),
                      ),
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                    ),
                    SizedBox(height: 16.sdp),
                    Obx(
                      () => GestureDetector(
                        onTap: _showImagePickerOptions,
                        child: Container(
                          width: double.infinity,
                          height: 200.sdp,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20.sdp),
                            border: Border.all(
                              color: AppColors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: imageData.value.file != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20.sdp),
                                  child: Image.file(
                                    File(imageData.value.file!),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      size: 50.sdp,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 10.sdp),
                                    Text(
                                      "Pick an image",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.sdp),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        onTap: _submitFeedback,
                        label: 'Submit',
                        labelStyle: 18.txtMediumWhite,
                        buttonColor: AppColors.btnColor,
                        radius: 20.sdp,
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
