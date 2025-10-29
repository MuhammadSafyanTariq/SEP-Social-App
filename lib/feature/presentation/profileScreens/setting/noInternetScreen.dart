import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/utils/extensions/size.dart';
import '../../../../components/coreComponents/ImageView.dart';
import '../../../../components/coreComponents/TextView.dart';
import '../../../../components/styles/appColors.dart';
import '../../../../components/styles/appImages.dart';
import '../../../../components/styles/app_strings.dart';
import '../../controller/auth_Controller/networkCtrl.dart';
import 'package:get/get.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final networkController = Get.find<NetworkController>();

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Obx(() {
        if (networkController.isConnected.value) {
          Future.delayed(Duration.zero, () {
            Get.back();
          });
        }

        return Padding(
          padding: 40.left + 40.right,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: ImageView(
                  url: AppImages.noInternet,
                  height: 230.sdp,
                  width: 240.sdp,
                  margin: 20.bottom
                ),
              ),
              TextView(
                text: AppStrings.noInternet,
                style: 30.txtBoldWhite,
              ),
              TextView(
                text: AppStrings.checkInternet,
                style: 16.txtMediumWhite,
                margin: 10.top + 20.bottom,
                textAlign: TextAlign.center,
              ),
              AppButton(
                label: AppStrings.tryAgain,
                labelStyle: 17.txtMediumWhite,
                buttonColor: AppColors.btnColor,
                onTap: () async {
                  await networkController.refreshConnection();
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}

