import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';




class PlatformInfo{
  static final firstView = WidgetsBinding.instance.platformDispatcher.views.first;

  // static double get  width => firstView.physicalSize.shortestSide;
  static double get  height => firstView.physicalSize.longestSide;
  static BuildContext? get context => Get.context;

  static bool get isPhone => Get.context?.isPhone ?? false;
  static bool get isSmallTab => Get.context?.isSmallTablet ?? false;
  static bool get isTab => Get.context?.isTablet ?? false;
  static bool get isLargeTab => Get.context?.isLargeTablet ?? false;
  static bool get isDesktop =>  Platform.isWindows ||  Platform.isMacOS;
}

