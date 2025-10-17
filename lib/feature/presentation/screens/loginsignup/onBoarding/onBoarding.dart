import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/components/styles/app_strings.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/presentation/screens/forgotpassword/signup/signup.dart';
import 'package:sep/feature/presentation/screens/loginsignup/login.dart';
import 'package:sep/feature/presentation/screens/loginsignup/onBoarding/language.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/widget.dart';
import '../../../../../components/styles/appColors.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "title": AppStrings.sports.tr,
      "description": AppStrings.push.tr,
      "image": AppImages.sport,
    },
    {
      "title": AppStrings.entertainment.tr,
      "description": AppStrings.unwind.tr,
      "image": AppImages.enter,
    },
    {
      "title": AppStrings.perception.tr,
      "description": AppStrings.shaping.tr,
      "image": AppImages.vote,
    },
  ];

  void _goToNextPage() {
    if (_currentIndex < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      context.pushAndClearNavigator(Signup());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top section with back button
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.sdp,
                vertical: 16.sdp,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      context.pushAndClearNavigator(Language());
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.sdp),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.sdp),
                        border: Border.all(color: AppColors.greenlight),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.greenlight,
                        size: 20.sdp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            10.height,
            // Title section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.sdp),
              child: Text(
                _onboardingData[_currentIndex]["title"]!,
                style: 24.txtSBoldprimary,
                textAlign: TextAlign.center,
              ),
            ),

            20.height,

            // Main content area
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return Column(
                    children: [
                      SizedBox(height: 40.sdp),

                      // Image section
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 40.sdp),
                          child: Image.asset(
                            data["image"]!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      SizedBox(height: 40.sdp),

                      // Description with 250 width constraint
                      Container(
                        width: 250.sdp,
                        child: Text(
                          data["description"]!,
                          style: 16.txtRegularprimary,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                        ),
                      ),

                      SizedBox(height: 60.sdp),
                    ],
                  );
                },
              ),
            ),

            // Bottom section with page indicator and next button
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24.sdp,
                vertical: 20.sdp,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicators on the left
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) => Container(
                        margin: EdgeInsets.only(right: 8.sdp),
                        height: 8.sdp,
                        width: _currentIndex == index ? 24.sdp : 8.sdp,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.sdp),
                          color: _currentIndex == index
                              ? AppColors.btnColor
                              : AppColors.btnColor.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),

                  // Next button on the right
                  GestureDetector(
                    onTap: _goToNextPage,
                    child: Container(
                      width: 56.sdp,
                      height: 56.sdp,
                      decoration: BoxDecoration(
                        color: AppColors.btnColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _currentIndex == _onboardingData.length - 1
                            ? Icons.check
                            : Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 20.sdp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
