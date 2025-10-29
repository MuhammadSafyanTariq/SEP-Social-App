import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/presentation/screens/loginsignup/onBoarding/onBoarding.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/widget.dart';
import '../../../components/coreComponents/AppButton.dart';
import '../../../components/styles/appColors.dart';
import '../../../components/styles/appImages.dart';
import '../../../components/styles/app_strings.dart';
import 'loginsignup/login.dart';

class Welcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.welcome),
            fit: BoxFit.fitHeight,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.transparent,
                AppColors.white.withValues(alpha: 0.7),
                AppColors.white.withValues(alpha: 0.9),
                AppColors.white,
              ],
              stops: [0.0, 0.5, 0.7, 0.85, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Spacer(flex: 3),

                // Welcome text section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.sdp),
                  child: Column(
                    children: [
                      Text(
                        AppStrings.welcomee.tr,
                        style: 28.txtSBoldprimary,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                40.height,

                // Buttons section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.sdp),
                  child: Column(
                    children: [
                      // Login Button
                      AppButton(
                        label: AppStrings.login.tr,
                        labelStyle: 17.txtBoldWhite,
                        height: 54,
                        radius: 20,
                        buttonColor: AppColors.btnColor,
                        onTap: () {
                          context.pushNavigator(Login());
                        },
                      ),

                      16.height,

                      // Sign Up Button
                      AppButton(
                        label: AppStrings.signup.tr,
                        labelStyle: 17.txtMediumgrey,
                        height: 54,
                        radius: 20,
                        buttonColor: Colors.transparent,
                        buttonBorderColor: AppColors.border,
                        onTap: () {
                          context.pushNavigator(OnboardingScreen());
                        },
                      ),
                    ],
                  ),
                ),

                40.height,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
