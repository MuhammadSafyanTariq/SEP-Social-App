import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/AppBar2.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/app_strings.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import 'package:sep/utils/extensions/widget.dart';
import '../../../../../utils/appUtils.dart';
import '../../../controller/auth_Controller/profileCtrl.dart';
import '../../../controller/settings_ctrl/settingscontroller.dart';

class Whocansharemypost extends StatefulWidget {
  @override
  _ProfileVisibilityScreenState createState() =>
      _ProfileVisibilityScreenState();
}

class _ProfileVisibilityScreenState extends State<Whocansharemypost> {
  int selectedIndex = -1;
  final List<String> options = [
    AppStrings.everybody.tr,
    AppStrings.myFriends.tr,
    AppStrings.nobody.tr,
  ];
  String? Semypostdata;

  String? get state => ProfileCtrl.find.profileData.value.shareMyPost;

  Future<void> _updateProfileVisibility(int index) async {
    // Map translated text back to API values
    String selectedValue = _getApiValueForIndex(index);

    setState(() {
      selectedIndex = index;
    });

    try {
      await SettingsCtrl.find.sharemypost(selectedValue).then((value) {
        AppUtils.log("Profile visibility changed to $selectedIndex");
        AppUtils.log("Profile visibility changed to $selectedValue");
      });
    } catch (error) {
      AppUtils.toastError("Failed to update: $error");
    }
  }

  String _getApiValueForIndex(int index) {
    switch (index) {
      case 0:
        return 'Everybody';
      case 1:
        return 'My Friends';
      case 2:
        return 'Nobody';
      default:
        return 'Everybody';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          AppBar2(
            title: AppStrings.whoCanShareMyPost.tr,
            titleStyle: 18.txtMediumBlack,
            prefixImage: "back",
            onPrefixTap: () => Navigator.pop(context),
            backgroundColor: Colors.white,
            hasTopSafe: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.sdp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description text
                  Container(
                    padding: EdgeInsets.all(16.sdp),
                    margin: EdgeInsets.only(bottom: 24.sdp),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.sdp),
                      border: Border.all(
                        color: AppColors.primaryBlue.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.share_outlined,
                          color: AppColors.primaryBlue,
                          size: 20.sdp,
                        ),
                        12.width,
                        Expanded(
                          child: TextView(
                            text: AppStrings.controlWhoCanSharePosts.tr,
                            style: 14.txtMediumBlack.copyWith(
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Options
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.sdp),
                      border: Border.all(
                        color: AppColors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: List.generate(options.length, (index) {
                        return Column(
                          children: [
                            Obx(
                              () => InkWell(
                                onTap: () {
                                  if (selectedIndex != index) {
                                    _updateProfileVisibility(index);
                                  }
                                },
                                borderRadius: BorderRadius.circular(12.sdp),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.sdp,
                                    vertical: 16.sdp,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getIconForOption(index),
                                        color: AppColors.grey,
                                        size: 24.sdp,
                                      ),
                                      16.width,
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextView(
                                              text: options[index],
                                              style: 16.txtMediumBlack,
                                            ),
                                            4.height,
                                            TextView(
                                              text: _getDescriptionForOption(
                                                index,
                                              ),
                                              style: 12.txtRegularGrey,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 24.sdp,
                                        height: 24.sdp,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: _isSelected(index)
                                                ? AppColors.btnColor
                                                : AppColors.grey,
                                            width: 2,
                                          ),
                                          color: _isSelected(index)
                                              ? AppColors.btnColor
                                              : Colors.transparent,
                                        ),
                                        child: _isSelected(index)
                                            ? Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 16.sdp,
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (index < options.length - 1)
                              Divider(
                                height: 1,
                                color: AppColors.grey.withOpacity(0.2),
                                indent: 56.sdp,
                              ),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForOption(int index) {
    switch (index) {
      case 0:
        return Icons.public;
      case 1:
        return Icons.people;
      case 2:
        return Icons.block;
      default:
        return Icons.public;
    }
  }

  String _getDescriptionForOption(int index) {
    switch (index) {
      case 0:
        return AppStrings.anybodyCanSharePosts.tr;
      case 1:
        return AppStrings.friendsCanSharePosts.tr;
      case 2:
        return AppStrings.nobodyCanSharePosts.tr;
      default:
        return "";
    }
  }

  bool _isSelected(int index) {
    String apiValue = _getApiValueForIndex(index);
    return (state == 'everyBody' && index == 0) || (state == apiValue);
  }
}
