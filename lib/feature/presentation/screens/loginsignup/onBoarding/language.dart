import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/widget.dart';
import '../../../../../components/coreComponents/AppButton.dart';
import '../../../../../components/coreComponents/ImageView.dart';
import '../../../../../components/styles/appColors.dart';
import '../../../../../components/styles/appImages.dart';
import '../../../../../components/styles/app_strings.dart';
import '../../../../../components/styles/textStyles.dart';
import '../../../../../utils/appUtils.dart';
import '../../../controller/language_controller.dart';
import '../../welcome.dart';

class Language extends StatelessWidget {
  final LanguageController _languageController = Get.put(LanguageController());

  Language({super.key});

  Widget _buildLanguageButton(String language, String label) {
    return Obx(() {
      final isSelected = _languageController.selectedLanguage.value == language;
      return Container(
        height: 54,
        margin: EdgeInsets.symmetric(horizontal: 20.sdp, vertical: 5.sdp),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.btnColor
                : AppColors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              _languageController.updateLanguage(language);
              AppUtils.log(
                'Language changed to: ${_languageController.selectedLanguage.value}',
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.sdp),
              child: Row(
                children: [
                  Expanded(child: Text(label, style: 16.txtMediumBlackText)),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.btnColor : AppColors.grey,
                        width: 2,
                      ),
                      color: Colors.transparent,
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.btnColor,
                              ),
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(12.sdp),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: 40.top,
                  child: Text(
                    AppStrings.selectLanguage.tr,
                    style: 24.txtSBoldprimary,
                  ),
                ),
              ),

              ImageView(
                url: AppImages.translation,
                height: 180.sdp,
                width: 180.sdp,
                margin: 20.top + 20.bottom,
              ),

              _buildLanguageButton('en', AppStrings.english.tr),
              10.height,
              _buildLanguageButton('es', AppStrings.spanish.tr),
              10.height,
              _buildLanguageButton('zh', AppStrings.chineseMandarin.tr),
              10.height,
              _buildLanguageButton('fr', AppStrings.french.tr),
              10.height,
              _buildLanguageButton('bn', AppStrings.bengali.tr),

              40.height,
              AppButton(
                label: AppStrings.cnontinue.tr,
                labelStyle: 17.txtBoldWhite,
                height: 54,
                radius: 20,
                buttonColor: AppColors.btnColor,
                margin: 20.horizontal,
                onTap: () {
                  if (_languageController.selectedLanguage.value.isNotEmpty) {
                    context.pushAndClearNavigator(Welcome());
                  } else {
                    Get.snackbar(
                      "Error".tr,
                      "Please select a language!".tr,
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: AppColors.red,
                      colorText: AppColors.white,
                      borderRadius: 20,
                      margin: 10.all,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
