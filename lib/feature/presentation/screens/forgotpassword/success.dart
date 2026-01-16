import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/widget.dart';

import '../../../../components/coreComponents/ImageView.dart';
import '../../../../components/styles/appColors.dart';
import '../../../../components/styles/appImages.dart';
import '../../../../components/styles/app_strings.dart';
import '../../Home/homeScreen.dart';

class Successscreen extends StatefulWidget {
  const Successscreen({super.key});

  @override
  State<Successscreen> createState() => _SuccessscreenState();
}

class _SuccessscreenState extends State<Successscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF00C853),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF00C853).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(Icons.check, color: Colors.white, size: 60),
              ),
              SizedBox(height: 30),
              TextView(
                text: "Password Changed",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C2C2C),
                ),
              ),
              SizedBox(height: 15),
              TextView(
                text: "Your password was changed successfully.",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B6B6B),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 50),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    context.pushAndClearNavigator(HomeScreen());
                  },
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Color(0xFF00C853),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF00C853).withOpacity(0.3),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "Return to Home",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
