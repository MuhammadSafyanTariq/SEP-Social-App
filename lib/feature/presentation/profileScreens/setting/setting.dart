import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/AppBar2.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/styles/app_strings.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/auth_ctrl.dart';
import 'package:sep/feature/presentation/profileScreens/setting/Conavel%20Screens/privacypolicy.dart';

import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import 'package:sep/utils/extensions/widget.dart';
import '../../../../components/coreComponents/TextView.dart';
import '../../../../components/styles/appColors.dart';
import '../../../../utils/appUtils.dart';
import '../../../data/repository/iAuthRepository.dart';
import '../../../data/repository/iTempRepository.dart';
import '../../../domain/respository/templateRepository.dart';
import '../../controller/auth_Controller/profileCtrl.dart';
import '../../screens/loginsignup/login.dart';
import '../../store/store_view_screen.dart';
import '../../Saved Posts/saved_posts_screen.dart';
import 'AppPrefrences/changeLanguages.dart';
import 'AppPrefrences/faq.dart';
import 'Conavel Screens/contactus.dart';
import 'Conavel Screens/feedback.dart';
import 'Conavel Screens/termandconditions.dart';
import 'PrivacyandSecurity/BlockUser.dart';
import 'PrivacyandSecurity/WhoCanSeeMyProfile.dart';
import 'PrivacyandSecurity/WhoCanShareMyPost.dart';
import 'changePassSetting.dart';
import 'editProfile.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final TempRepository _repo = ITempRepository();

  String? get sharemypostt => ProfileCtrl.find.profileData.value.shareMyPost;
  String? get seemyprofile => ProfileCtrl.find.profileData.value.seeMyProfile;

  bool? get notificationn => ProfileCtrl.find.profileData.value.isNotification;

  var isNotificationOn = false.obs;

  @override
  void initState() {
    super.initState();
    isNotificationOn.value = notificationn ?? true;

    print("Switch value?????: $seemyprofile");

    print("Switch value???????????????????????: $notificationn");
  }

  void toggleNotification(bool value) async {
    try {
      await _repo.notificationallow(isNotification: value);
      isNotificationOn.value = value;
    } catch (e) {
      print('API call failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          AppBar2(
            title: AppStrings.settings.tr,
            titleStyle: 18.txtMediumBlack,
            prefixImage: "back",
            onPrefixTap: () => Navigator.pop(context),
            backgroundColor: Colors.white,
            hasTopSafe: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.sdp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personalisation Section
                  _buildSectionHeader(AppStrings.personalisation.tr),
                  _buildSettingsCard([
                    _buildUserProfileTile(),
                    Divider(height: 1, color: AppColors.grey.withOpacity(0.3)),
                    _buildSettingsTile(
                      title: AppStrings.changePassword.tr,
                      icon: Icons.lock_outline,
                      onTap: _showChangePasswordBottomSheet,
                      showToggle: false,
                    ),
                    Divider(height: 1, color: AppColors.grey.withOpacity(0.3)),
                    _buildSettingsTile(
                      title: 'My Store',
                      icon: Icons.store_outlined,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StoreViewScreen(),
                        ),
                      ),
                      showToggle: false,
                    ),
                    Divider(height: 1, color: AppColors.grey.withOpacity(0.3)),
                    _buildSettingsTile(
                      title: 'Saved Posts',
                      icon: Icons.bookmark_outlined,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SavedPostsScreen(),
                        ),
                      ),
                      showToggle: false,
                    ),
                  ]),

                  // App Preferences Section
                  _buildSectionHeader(AppStrings.appPreferences.tr),
                  _buildSettingsCard([
                    _buildSettingsTile(
                      title: AppStrings.language.tr,
                      icon: Icons.language_outlined,
                      onTap: () => context.pushNavigator(Changelanguages()),
                      showToggle: false,
                    ),
                    Divider(height: 1, color: AppColors.grey.withOpacity(0.3)),
                    _buildSettingsTile(
                      title: AppStrings.faq.tr,
                      icon: Icons.help_outline,
                      onTap: () => context.pushNavigator(FAQScreen()),
                      showToggle: false,
                    ),
                  ]),

                  // Notifications Section
                  _buildSectionHeader(AppStrings.notification.tr),
                  _buildSettingsCard([
                    _buildSettingsTile(
                      title: AppStrings.notificat.tr,
                      icon: Icons.notifications_outlined,
                      onTap: () {},
                      showToggle: true,
                      toggleValue: isNotificationOn.value,
                      onToggleChanged: toggleNotification,
                    ),
                  ]),

                  // Privacy & Security Section
                  _buildSectionHeader(AppStrings.privacyAndSecurity.tr),
                  _buildSettingsCard([
                    _buildSettingsTile(
                      title: AppStrings.whoCanSeeMyProfile.tr,
                      icon: Icons.visibility_outlined,
                      onTap: () => context.pushNavigator(WhoCanSeeMyProfile()),
                      showToggle: false,
                    ),
                    Divider(height: 1, color: AppColors.grey.withOpacity(0.3)),
                    _buildSettingsTile(
                      title: AppStrings.whoCanShareMyPost.tr,
                      icon: Icons.share_outlined,
                      onTap: () => context.pushNavigator(Whocansharemypost()),
                      showToggle: false,
                    ),
                    Divider(height: 1, color: AppColors.grey.withOpacity(0.3)),
                    _buildSettingsTile(
                      title: AppStrings.blockedUser.tr,
                      icon: Icons.block_outlined,
                      onTap: () => context.pushNavigator(Blockuser()),
                      showToggle: false,
                    ),
                  ]),

                  // Legal & Support Section
                  _buildSectionHeader("Legal & Support"),
                  _buildSettingsCard([
                    _buildSettingsTile(
                      title: AppStrings.privacyPolicySettings.tr,
                      icon: Icons.privacy_tip_outlined,
                      onTap: () => context.pushNavigator(PrivacyPolicy()),
                      showToggle: false,
                    ),
                    Divider(height: 1, color: AppColors.grey.withOpacity(0.3)),
                    _buildSettingsTile(
                      title: AppStrings.termsAndCondation.tr,
                      icon: Icons.article_outlined,
                      onTap: () => context.pushNavigator(Termandconditions()),
                      showToggle: false,
                    ),
                    Divider(height: 1, color: AppColors.grey.withOpacity(0.3)),
                    _buildSettingsTile(
                      title: AppStrings.contactUs.tr,
                      icon: Icons.contact_support_outlined,
                      onTap: () => context.pushNavigator(Contactus()),
                      showToggle: false,
                    ),
                    Divider(height: 1, color: AppColors.grey.withOpacity(0.3)),
                    _buildSettingsTile(
                      title: AppStrings.feedback.tr,
                      icon: Icons.feedback_outlined,
                      onTap: () => context.pushNavigator(FeedbackScreen()),
                      showToggle: false,
                    ),
                  ]),

                  // Logout Section
                  _buildSectionHeader("Logout"),
                  _buildSettingsCard([
                    _buildSettingsTile(
                      title: "Delete Account",
                      icon: Icons.person_remove_outlined,
                      titleColor: Colors.red,
                      onTap: _showDeleteAccountDialog,
                      showToggle: false,
                    ),
                    Divider(height: 1, color: AppColors.grey.withOpacity(0.3)),
                    _buildSettingsTile(
                      title: "Log Out",
                      icon: Icons.logout_outlined,
                      titleColor: Colors.red,
                      onTap: _showLogoutDialog,
                      showToggle: false,
                    ),
                  ]),

                  50.height, // Bottom spacing
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 24.sdp, bottom: 8.sdp, left: 4.sdp),
      child: TextView(
        text: title,
        style: 14.txtMediumBlack.copyWith(
          color: AppColors.grey.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.sdp),
        border: Border.all(color: AppColors.grey.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildUserProfileTile() {
    return InkWell(
      onTap: () => context.pushNavigator(EditProfile()),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.sdp, vertical: 12.sdp),
        child: Row(
          children: [
            // Profile Image
            Obx(() {
              String imageUrl = AppUtils.configImageUrl(
                ProfileCtrl.find.profileData.value.image ?? '',
              );
              return ImageView(
                url: imageUrl,
                size: 50.sdp,
                radius: 25.sdp,
                imageType: ImageType.network,
                defaultImage: AppImages.dummyProfile,
                fit: BoxFit.cover,
              );
            }),
            12.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => TextView(
                      text:
                          ProfileCtrl.find.profileData.value.name ?? "Username",
                      style: 16.txtMediumBlack,
                    ),
                  ),
                  4.height,
                  TextView(
                    text: "Set profile, email, etc",
                    style: 14.txtRegularGrey,
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              'assets/icons/doublearrow.svg',
              width: 20.sdp,
              height: 20.sdp,
              color: AppColors.greenlight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required VoidCallback onTap,
    required bool showToggle,
    IconData? icon,
    Color? titleColor,
    bool? toggleValue,
    Function(bool)? onToggleChanged,
  }) {
    return InkWell(
      onTap: showToggle ? null : onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.sdp, vertical: 16.sdp),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 24.sdp,
                color: titleColor ?? AppColors.blackText,
              ),
              12.width,
            ],
            Expanded(
              child: TextView(
                text: title,
                style: 16.txtMediumBlack.copyWith(
                  color: titleColor ?? AppColors.blackText,
                ),
              ),
            ),
            if (showToggle && toggleValue != null && onToggleChanged != null)
              Obx(
                () => Switch(
                  value: isNotificationOn.value,
                  activeColor: AppColors.greenlight,
                  onChanged: onToggleChanged,
                ),
              )
            else
              SvgPicture.asset(
                'assets/icons/doublearrow.svg',
                width: 20.sdp,
                height: 20.sdp,
                color: titleColor == Colors.red
                    ? Colors.red
                    : AppColors.greenlight,
              ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.sdp)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.sdp),
                topRight: Radius.circular(20.sdp),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: 10.vertical,
                  child: Center(
                    child: Container(
                      width: 70.sdp,
                      height: 5.sdp,
                      decoration: BoxDecoration(
                        color: AppColors.grey,
                        borderRadius: BorderRadius.circular(10.sdp),
                      ),
                    ),
                  ),
                ),
                Expanded(child: ChangePasswordScreen()),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.sdp),
          ),
          backgroundColor: Colors.white,
          insetPadding: 20.horizontal,
          contentPadding: EdgeInsets.zero,
          titlePadding: EdgeInsets.zero,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: 16.vertical,
                child: TextView(
                  text: "Delete Account",
                  style: 24.txtMediumBlack,
                  textAlign: TextAlign.center,
                ),
              ),
              Divider(thickness: 1, color: AppColors.Grey, height: 1),
            ],
          ),
          content: Padding(
            padding: 16.all,
            child: TextView(
              text:
                  "Are you sure you want to delete your account? This action cannot be undone.",
              textAlign: TextAlign.center,
              style: 16.txtRegularprimary,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppButton(
                    radius: 25.sdp,
                    width: 110.sdp,
                    label: "Cancel",
                    labelStyle: 14.txtMediumbtncolor,
                    buttonColor: AppColors.white,
                    buttonBorderColor: AppColors.btnColor,
                    margin: 20.right,
                    onTap: context.pop,
                  ),
                  AppButton(
                    radius: 25.sdp,
                    width: 110.sdp,
                    label: "Delete",
                    labelStyle: 14.txtMediumWhite,
                    buttonColor: Colors.red,
                    onTap: () async {
                      Navigator.pop(context);

                      try {
                        final authRepo = IAuthRepository();
                        final response = await authRepo
                            .deleteAccount()
                            .applyLoader;

                        if (response.isSuccess) {
                          AppUtils.toast("Account deleted successfully");
                          Get.offAll(() => Login());
                        } else {
                          AppUtils.toastError(
                            "Failed to delete account. Please try again.",
                          );
                        }
                      } catch (e) {
                        AppUtils.toastError(
                          "An error occurred. Please try again.",
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.sdp),
          ),
          backgroundColor: Colors.white,
          insetPadding: 20.horizontal,
          contentPadding: EdgeInsets.zero,
          titlePadding: EdgeInsets.zero,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: 16.vertical,
                child: TextView(
                  text: AppStrings.logout.tr,
                  style: 24.txtMediumBlack,
                  textAlign: TextAlign.center,
                ),
              ),
              Divider(thickness: 1, color: AppColors.Grey, height: 1),
            ],
          ),
          content: Padding(
            padding: 16.all,
            child: TextView(
              text: "Are you sure you want to log out?",
              textAlign: TextAlign.center,
              style: 16.txtRegularprimary,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppButton(
                    radius: 25.sdp,
                    width: 110.sdp,
                    label: "Cancel",
                    labelStyle: 14.txtMediumbtncolor,
                    buttonColor: AppColors.white,
                    buttonBorderColor: AppColors.btnColor,
                    margin: 20.right,
                    onTap: context.pop,
                  ),
                  AppButton(
                    radius: 25.sdp,
                    width: 110.sdp,
                    label: "Log Out",
                    labelStyle: 14.txtMediumWhite,
                    buttonColor: AppColors.btnColor,
                    onTap: () {
                      onLogout(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Remove all the old complex UI code and keep the rest of the implementation
  static Future<void> onLogout(BuildContext context) async {
    context.stopLoader;
    AuthCtrl.find.logout().applyLoader.then((value) {
      Get.offAll(Login());
    });
  }
}
