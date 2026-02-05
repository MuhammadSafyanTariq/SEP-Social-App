import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/widget.dart';
import '../../../components/coreComponents/ImageView.dart';
import '../../../components/styles/appColors.dart';
import '../../../components/styles/appImages.dart';
import '../../../services/firebaseServices.dart';
import '../../../services/storage/preferences.dart';
import '../Home/homeScreen.dart';
import 'loginsignup/onBoarding/language.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    FirebaseServices.init(context).then((value) {
      FirebaseServices.listener();
    });
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));
    if (Preferences.authToken != null) {
      context.pushAndClearNavigator(const HomeScreen());
    } else {
      context.pushAndClearNavigator(Language());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, AppColors.greenSplash, Colors.black],
              stops: [0.0, 0.5, 1.0],
            ),
          ),

          child: Align(
            alignment: const Alignment(-0.15, 0.10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                AppImages.splashLogo,
                height: 250.sdp,
                width: 250.sdp,
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
