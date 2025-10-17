import 'package:flutter/material.dart';
import 'package:sep/utils/extensions/extensions.dart';

import 'appColors.dart';

extension TextStyles on num {
  TextStyle get txtRegularBlackText =>
      _textStyle(this, AppColors.black, Family.regular);

  TextStyle get txtRegularError =>
      _textStyle(this, AppColors.red, Family.regular);

  // TextStyle get txtRegularWhite => _textStyle(this,AppColors.white,Family.regular);
  TextStyle get txtRegularWhite =>
      _textStyle(this, AppColors.greenlight, Family.regular);
  TextStyle get txtRegularBlack =>
      _textStyle(this, AppColors.black, Family.regular);
  TextStyle get txtRegularRetake1 =>
      _textStyle(this, AppColors.retake.withValues(alpha: 0.7), Family.regular);
  TextStyle get txtRegularprimary =>
      _textStyle(this, AppColors.primaryColor, Family.regular);
  TextStyle get txtRegularblue =>
      _textStyle(this, AppColors.primaryBlue, Family.regular);
  TextStyle get txtRegularbtncolor =>
      _textStyle(this, AppColors.btnColor, Family.regular);
  TextStyle get txtRegularHyperLink => _textStyle(
    this,
    AppColors.primaryBlue,
    Family.regular,
    textDecoration: TextDecoration.underline,
  );

  TextStyle get txtMediumWhite =>
      _textStyle(this, AppColors.white, Family.medium);
  TextStyle get txtMediumYellow =>
      _textStyle(this, AppColors.yellow, Family.medium);
  TextStyle get txtMediumbtncolor =>
      _textStyle(this, AppColors.btnColor, Family.medium);
  TextStyle get txtMediumbtnred =>
      _textStyle(this, AppColors.red, Family.semiBold);
  TextStyle get txtMediumgrey =>
      _textStyle(this, AppColors.grey, Family.medium);
  TextStyle get txtMediumWhitesplash =>
      _textStyle(this, AppColors.white, Family.splash);
  TextStyle get txtMediumBlackText =>
      _textStyle(this, AppColors.blackText, Family.bold);
  TextStyle get txtsearch => _textStyle(this, AppColors.Grey, Family.medium);
  TextStyle get txtMedgreen =>
      _textStyle(this, AppColors.btnColor, Family.semiBold);
  TextStyle get txtSBoldBlack =>
      _textStyle(this, AppColors.white, Family.semiBold);
  TextStyle get txtSBoldprimary =>
      _textStyle(this, AppColors.primaryColor, Family.semiBold);
  TextStyle get txtRegularMainBlack =>
      _textStyle(this, AppColors.primaryColor, Family.regular);
  TextStyle get txtBoldGrey =>
      _textStyle(this, AppColors.greyHint, Family.semiBold);
  TextStyle get txtsemiBoldWhite =>
      _textStyle(this, AppColors.white, Family.semiBold);

  TextStyle get txtBoldExWhite =>
      _textStyle(this, AppColors.white, Family.extraBold);
  TextStyle get txtBoldExWhiteStrokeBlack => _textStyle(
    this,
    AppColors.white,
    Family.extraBold,
    stroke: AppColors.primaryColor,
  );
  TextStyle get txtBoldWhite => _textStyle(this, AppColors.white, Family.bold);
  TextStyle get txtBoldBlack =>
      _textStyle(this, AppColors.primaryColor, Family.bold);
  TextStyle get txtBoldBtncolor =>
      _textStyle(this, AppColors.btnColor, Family.bold);
  TextStyle get txtExBoldBtncolor =>
      _textStyle(this, AppColors.btnColor, Family.extraBold);
  TextStyle get txtBoldUserName =>
      _textStyle(this, AppColors.liveUserNameColor, Family.bold);
  TextStyle get txtRegularGrey =>
      _textStyle(this, AppColors.grey, Family.regular);
  // TextStyle get txtBoldBlackText => _textStyle(this,AppColors.blackText,Family.bold);
  TextStyle get txtregularBtncolor =>
      _textStyle(this, AppColors.btnColor, Family.medium);
  TextStyle get txtboldBtncolor =>
      _textStyle(this, AppColors.btnColor, Family.semiBold);
  TextStyle get txtboldgreen =>
      _textStyle(this, AppColors.btnColor, Family.bold);
  TextStyle get txtboldred => _textStyle(this, AppColors.red, Family.bold);

  TextStyle get newgreyText => _textStyle(this, AppColors.grey, Family.regular);
  TextStyle get txtshare =>
      _textStyle(this, AppColors.primaryBlue, Family.semiBold);
  TextStyle get txtfieldgrey =>
      _textStyle(this, AppColors.txtfieldtext, Family.regular);

  // Additional styles for signup screen
  TextStyle get txtMediumGreyText =>
      _textStyle(this, AppColors.grey, Family.medium);
  TextStyle get txtBoldBtnColor =>
      _textStyle(this, AppColors.btnColor, Family.bold);
}

class Family {
  static const String light = 'Urbanist-Light';
  static const String regular = 'Urbanist-Regular';
  static const String medium = 'Urbanist-Medium';
  static const String semiBold = 'Urbanist-SemiBold';
  static const String bold = 'Urbanist-Bold';
  static const String extraBold = 'Urbanist-ExtraBold';
  static const String splash = 'UnifrakturMaguntia-Regular';
}

TextStyle _textStyle(
  num size,
  color,
  family, {
  TextDecoration? textDecoration,
  Color? stroke,
}) =>
    // TextStyle(
    // fontSize: 40,
    // foreground: Paint()
    // ..style = PaintingStyle.stroke
    // ..strokeWidth = 2
    // ..color = Colors.black, // Border color
    // );
    TextStyle(
      fontSize: size.numToDouble,
      color: stroke != null ? null : color,
      fontFamily: family,
      decoration: textDecoration,
      foreground: stroke != null
          ? (Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1
              ..color = stroke)
          : null,
      // decorationStyle: TextDecorationStyle.solid
    );

// TextStyle(
// fontSize: 40,
// foreground: Paint()
// ..style = PaintingStyle.stroke
// ..strokeWidth = 2
// ..color = Colors.black, // Border color
// )
