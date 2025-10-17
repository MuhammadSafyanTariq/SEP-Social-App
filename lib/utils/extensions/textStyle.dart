import 'package:flutter/material.dart';
import 'package:sep/utils/extensions/size.dart';
import '../../components/styles/appColors.dart';

enum TextWeight {regular,medium, semiBold, bold,}

class Family{
static const String light = '';
static const String regular = '';
static const String medium = '';
static const String semiBold = '';
static const String bold = '';
}

extension TextStyles on num{
  TextStyle get txtMediumBlack => textStyle(color: AppColors.primaryColor, size: this, weight: TextWeight.medium, fontFamily: Family.medium);
  TextStyle get txtMediumPrimary => textStyle(color: AppColors.primaryColor, size: this, weight: TextWeight.medium, fontFamily: Family.medium);
  TextStyle get txtMediumprimary => textStyle(color: AppColors.primaryColor, size: this, weight: TextWeight.medium, fontFamily: Family.medium);
  TextStyle get mediumwhite => textStyle(color: AppColors.white, size: this, weight: TextWeight.medium, fontFamily: Family.medium);
  TextStyle get mediumBlack => textStyle(color: AppColors.orange, size: this, weight: TextWeight.semiBold, fontFamily: Family.medium);
  TextStyle get txtRegularGreyHint => textStyle(color: AppColors.greyHint, size: this, weight: TextWeight.semiBold, fontFamily: Family.regular);
  TextStyle get txtmarkread => textStyle(color: AppColors.btnColor, size: this, weight: TextWeight.semiBold, fontFamily: Family.regular);
  TextStyle get txtCategory => textStyle(color: AppColors.btnColor, size: this, weight: TextWeight.semiBold, fontFamily: Family.medium);
  TextStyle get txtMediumRed => textStyle(color: AppColors.red, size: this, weight: TextWeight.medium, fontFamily: Family.medium);
  TextStyle get txtRegularRed => textStyle(color: AppColors.red, size: this, weight: TextWeight.regular, fontFamily: Family.light);

}


TextStyle textStyle({required Color color, required num size, required TextWeight weight,required fontFamily }){
  return TextStyle(fontSize: size.getDouble.sdp, color: color, fontWeight: weight.fontWeight,fontFamily: 'font');
}

extension TextWeights on TextWeight{
  FontWeight get fontWeight {
    if(this == TextWeight.regular){
      return FontWeight.w400;
    }else if(this == TextWeight.medium){
      return FontWeight.w500;
    }else if(this == TextWeight.semiBold){
      return FontWeight.w600;
    }else if(this == TextWeight.bold){
      return FontWeight.w700;
    }else{
      return FontWeight.w400;
    }
  }
}


extension OnTextStyle on TextStyle{
  TextStyle  withShadow(Color color){
    final style = copyWith(
      shadows: [
        Shadow(
          offset: Offset(2, 2),
          blurRadius: 20.0,
          color: color,
        )
      ]
    );
    return style;
  }
}