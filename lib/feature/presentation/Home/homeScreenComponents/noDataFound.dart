import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/utils/extensions/size.dart';

import '../../../../components/coreComponents/ImageView.dart';
import '../../../../components/coreComponents/TextView.dart';
import '../../../../components/styles/appColors.dart';
import '../../../../components/styles/appImages.dart';
import '../../../../components/styles/app_strings.dart';

Widget NoDataFound() {
  return Scaffold(
    backgroundColor: AppColors.black,
    body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
            child: ImageView(
              url: AppImages.noPost,
              height: 130.sdp,
              width: 130.sdp,
              margin: 20.bottom,
            )),
        TextView(
          text: AppStrings.noPostYet.tr,
          style: 30.txtBoldWhite,
        ),
        TextView(
          text: AppStrings.whenSomeOne.tr,
          style: 16.txtMediumWhite,
          margin: 10.top,
        )
      ],
    ),
  );
}