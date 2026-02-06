import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/feature/presentation/screens/loginsignup/onBoarding/onBoarding.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/size.dart';
import '../../../components/styles/appColors.dart';
import '../../../components/styles/appImages.dart';
import '../../../components/styles/app_strings.dart';
import 'loginsignup/login.dart';

class Welcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background image - positioned at top with SafeArea, displayed at real width
          SafeArea(
            bottom: false, // Don't add bottom padding, let image extend
            child: Padding(
              padding: const EdgeInsets.only(
                top: 15.0,
              ), // Move image down a bit from top
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: screenWidth,
                  child: Image.asset(
                    AppImages.welcome,
                    fit: BoxFit
                        .contain, // Show image at its real width/height without cropping
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
            ),
          ),

          // Subtle dark overlay to enhance readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.5),
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Spacer to position buttons higher up
                Spacer(), // Minimal spacer to move buttons up
                // Buttons section
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    24.sdp,
                    0,
                    24.sdp,
                    65.sdp,
                  ), // Further reduced bottom padding
                  child: Column(
                    children: [
                      // Login Button - Dark green with glow effect
                      Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.btnColor, // Dark green
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.btnColor.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 0,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              context.pushNavigator(Login());
                            },
                            child: Center(
                              child: Text(
                                AppStrings.login.tr,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Sign Up Button - Dark with light border
                      Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.black.withOpacity(0.8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              context.pushNavigator(OnboardingScreen());
                            },
                            child: Center(
                              child: Text(
                                AppStrings.signup.tr,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
