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
      body: SafeArea(child: Container(
        color: AppColors.primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ImageView(
                url: AppImages.Done,
              ),
              20.height,
              Center(child: TextView(text: "Success!",style: 30.txtBoldBtncolor,)),
              10.height,
              TextView(text: "Your password was change successfully.",style: 20.txtMediumbtncolor,),
              45.height,

              AppButton(
                margin: 20.top+16.right+16.left,
                label: AppStrings.gotohome,
                labelStyle: 17.txtBoldWhite,
                buttonColor: AppColors.btnColor,
                onTap: () {
                  context.pushAndClearNavigator(HomeScreen());
                },
              ),],
          ),
        ),
      )),
    );
  }
}
