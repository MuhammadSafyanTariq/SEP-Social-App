import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/AppBar2.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/presentation/controller/settings_ctrl/settingscontroller.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../components/coreComponents/AppButton.dart';
import '../../../../../components/styles/appColors.dart';
import '../../../../../components/styles/app_strings.dart';
import '../../../../../services/storage/preferences.dart';
import '../../../controller/auth_Controller/profileCtrl.dart';

class Contactus extends StatefulWidget {
  const Contactus({super.key});

  @override
  _ContactusState createState() => _ContactusState();
}

class _ContactusState extends State<Contactus> {
  final ProfileCtrl profileCtrl = Get.find<ProfileCtrl>();

  bool isLoading = false;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    AppUtils.log("<><><><><><><><>><><${profileCtrl.profileData.value.email}>");

    try {
      SettingsCtrl.find
          .contactuss(
            profileCtrl.profileData.value.email ?? "",
            titleController.text.trim(),
            messageController.text.trim(),
          )
          .applyLoader
          .then((value) {
            AppUtils.log(Preferences.email);
            context.pop();
          });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          AppBar2(
            title: "Contact Us",
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
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: "Enter Your Title here",
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.sdp),
                    TextFormField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: "Your Message",
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a message';
                        } else if (value.length < 2) {
                          return 'Message must be at least 5 characters long';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 32.sdp),
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : SizedBox(
                            width: double.infinity,
                            child: AppButton(
                              label: 'Submit',
                              labelStyle: 18.txtMediumWhite,
                              buttonColor: AppColors.btnColor,
                              radius: 20.sdp,
                              onTap: _submitForm,
                            ),
                          ),
                    SizedBox(height: 40.sdp),
                    _buildSocialMediaSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.socialMedia.tr,
          style: 24.txtMediumBlack.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 24.sdp),
        _buildSocialMediaItemWithImage(
          imagePath: 'assets/images/facebook.png',
          title: AppStrings.stayUpdatedFacebook.tr,
          onTap: () => _launchURL('https://facebook.com'),
        ),
        SizedBox(height: 20.sdp),
        _buildSocialMediaItemWithImage(
          imagePath: 'assets/images/instagram.png',
          title: AppStrings.exploreVisualWorldInstagram.tr,
          onTap: () => _launchURL('https://instagram.com'),
        ),
        SizedBox(height: 20.sdp),
        _buildSocialMediaItemWithImage(
          imagePath: 'assets/images/twitter.png',
          title: AppStrings.exploreVisualWorldTwitter.tr,
          onTap: () => _launchURL('https://twitter.com'),
        ),
      ],
    );
  }

  Widget _buildSocialMediaItemWithImage({
    required String imagePath,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.sdp),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.sdp),
          border: Border.all(color: AppColors.grey.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50.sdp,
              height: 50.sdp,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(25.sdp),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25.sdp),
                child: Image.asset(
                  imagePath,
                  width: 50.sdp,
                  height: 50.sdp,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to default icons if images are not found
                    IconData fallbackIcon;
                    Color fallbackColor;

                    if (imagePath.contains('facebook')) {
                      fallbackIcon = Icons.facebook;
                      fallbackColor = Color(0xFF1877F2);
                    } else if (imagePath.contains('instagram')) {
                      fallbackIcon = Icons.camera_alt;
                      fallbackColor = Color(0xFFE4405F);
                    } else {
                      fallbackIcon = Icons.alternate_email;
                      fallbackColor = Color(0xFF1DA1F2);
                    }

                    return Container(
                      width: 50.sdp,
                      height: 50.sdp,
                      decoration: BoxDecoration(
                        color: fallbackColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25.sdp),
                      ),
                      child: Icon(
                        fallbackIcon,
                        color: fallbackColor,
                        size: 24.sdp,
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 16.sdp),
            Expanded(
              child: Text(
                title,
                style: 16.txtMediumBlack.copyWith(height: 1.4),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.grey, size: 16.sdp),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        AppUtils.toastError('Could not launch $url');
      }
    } catch (e) {
      AppUtils.toastError('Error launching URL: $e');
    }
  }
}
