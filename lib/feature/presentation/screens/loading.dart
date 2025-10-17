import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/components/styles/app_strings.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/presentation/Home/homeScreen.dart';
import 'package:sep/feature/presentation/screens/welcome.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';

import '../../../components/styles/appColors.dart';
import '../../../services/storage/preferences.dart';
import 'loginsignup/login.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));
    if (Preferences.authToken != null && Preferences.authToken!.isNotEmpty) {
      context.pushAndClearNavigator(HomeScreen());
    } else {
      context.pushAndClearNavigator(Login());
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.black,
        body: Center(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ImageView(url: AppImages.Done),
                TextView(
                    text: AppStrings.congratulation.tr,
                    style: 30.txtboldgreen,
                    margin: 32.top),
                TextView(
                  text:AppStrings.yourAccountIsReady.tr,
                  style: 20.txtRegularbtncolor,
                  textAlign: TextAlign.center,
                  margin: 25.top,
                ),

                Container(
                  margin: 20.top,
                  child: SpinKitCircle(
                    color: AppColors.btnColor, // Green Loader
                    size: 70.0,
                  ),
                ),
              ]),
        ));
  }
}
