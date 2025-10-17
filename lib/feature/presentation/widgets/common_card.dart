import 'package:flutter/cupertino.dart';

import '../../../components/styles/appColors.dart';

class CommonCard extends StatelessWidget {
  CommonCard({
    super.key,
    this.child,
    this.margin,
    this.padding,
    required this.onTap,
    this.borderClr,
    this.hasShadow = true,
    this.bkColor,
    this.width,
  });

  Widget? child;
  EdgeInsets? margin;
  EdgeInsets? padding;
  VoidCallback onTap;
  Color? borderClr;
  Color? bkColor;
  bool hasShadow;
  double? width;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: padding ?? const EdgeInsets.all(16),
        margin: margin ?? const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: bkColor ?? AppColors.white,
          boxShadow: hasShadow
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.3),
                    spreadRadius: double.maxFinite,
                    // blurRadius: 2
                  ),
                ]
              : null,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: borderClr ?? AppColors.primaryColor),
        ),
        child: child,
      ),
    );
  }
}
