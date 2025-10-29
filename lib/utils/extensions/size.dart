import 'package:flutter/cupertino.dart';
import '../platformInfo.dart';


extension Size on num{
  double get getDouble => toDouble();
  double get sdp {return getResponsiveSize(this);}
  EdgeInsets get vertical => EdgeInsets.symmetric(vertical: getDouble.sdp);
  EdgeInsets get allSide => EdgeInsets.all(getDouble.sdp);
  EdgeInsets get horizontal => EdgeInsets.symmetric(horizontal: getDouble.sdp);
  EdgeInsets get top => EdgeInsets.only(top: getDouble.sdp);
  EdgeInsets get left => EdgeInsets.only(left: getDouble.sdp);
  EdgeInsets get right => EdgeInsets.only(right: getDouble.sdp);
  EdgeInsets get bottom => EdgeInsets.only(bottom: getDouble.sdp);
  EdgeInsets get all => EdgeInsets.all(getDouble.sdp);
}

double getResponsiveSize(num value){
  if(PlatformInfo.isPhone){
    // print('isPhone...');
    return value.getDouble;
  }else if(PlatformInfo.isTab || PlatformInfo.isLargeTab || PlatformInfo.isSmallTab){
    // print('isTab...');
    return value.getDouble * 1.5;
  }else if(PlatformInfo.isDesktop){
    // print('isDesktop...');
    return value.getDouble * 2;
  }else
  return value.getDouble;
}