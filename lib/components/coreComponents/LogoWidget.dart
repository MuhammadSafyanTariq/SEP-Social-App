import 'package:flutter/material.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/utils/extensions/size.dart';

class LogoWidget extends StatelessWidget {
  final double? size;

  const LogoWidget({Key? key, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logoSize = size ?? 100.sdp;

    return Container(
      width: logoSize,
      height: logoSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.sdp),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, AppColors.greenSplash, Colors.black],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Center(
        child: Column(
          children: [
            SizedBox(height: logoSize * 0.2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ImageView(
                  url: AppImages.splashLogo,
                  height: logoSize * 0.6,
                  width: logoSize * 0.6,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: logoSize * 0.05),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
