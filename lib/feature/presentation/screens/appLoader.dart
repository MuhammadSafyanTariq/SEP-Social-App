import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../components/styles/appColors.dart';

class AppLoader {
  static Future<void> showLoader(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: SpinKitCircle(
            color: AppColors.btnColor,
            size: 50.0,
          ),
        );
      },
    );
  }

  static void hideLoader(BuildContext context) {
    Navigator.of(context).pop();
  }
}
