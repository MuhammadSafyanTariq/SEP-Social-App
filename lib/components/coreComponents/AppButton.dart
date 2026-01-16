import 'package:flutter/material.dart';
import 'package:sep/components/styles/textStyles.dart';
import '../styles/appColors.dart';
import 'TapWidget.dart';
import 'TextView.dart';

class AppButton extends StatelessWidget {
  final String? label;
  final TextStyle? labelStyle;
  final Function()? onTap;
  final double? radius;
  final Color? buttonColor;
  final Color? buttonBorderColor;
  final double? buttonBorderWidth; // Added: Border width property
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool isFilledButton;
  final Widget? child;
  final Widget? prefix;
  final Widget? suffix;
  final Alignment alignment;
  final double? width;
  final double? height;
  final bool isLoading;
  final Widget? startImage;
  final TextOverflow? textOverflow;
  final int? maxLines;

  const AppButton({
    super.key,
    this.label,
    this.onTap,
    this.radius,
    this.labelStyle,
    this.buttonColor,
    this.buttonBorderColor,
    this.buttonBorderWidth,
    this.padding,
    this.margin,
    this.isFilledButton = true,
    this.child,
    this.prefix,
    this.suffix,
    this.alignment = Alignment.center,
    this.width,
    this.height,
    this.isLoading = false,
    this.startImage,
    this.textOverflow,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    // 12.sdp;
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Stack(
        children: [
          Align(
            alignment: alignment,
            child: Container(
              padding:
                  padding ?? EdgeInsets.symmetric(horizontal: 18, vertical: 15),
              width: width ?? (isFilledButton ? double.maxFinite : null),
              height: height,
              decoration: BoxDecoration(
                color: buttonColor ?? AppColors.primaryColor,
                borderRadius: BorderRadius.circular(radius ?? 20),
                border: Border.all(
                  color: buttonBorderColor ?? Colors.transparent,
                  width:
                      buttonBorderWidth ??
                      1, // Use custom border width or default to 1
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prefix != null && !isLoading) prefix!,
                  isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white, // Adjust based on theme
                            strokeWidth: 2,
                          ),
                        )
                      : TextView(
                          text: label ?? '',
                          style: labelStyle ?? 14.txtMediumWhite,
                          overflow: textOverflow,
                          maxlines: maxLines,
                        ),
                  if (child != null) child!,
                  if (suffix != null && !isLoading) suffix!,
                ],
              ),
            ),
          ),
          Positioned.fill(child: TapWidget(onTap: isLoading ? null : onTap)),
        ],
      ),
    );
  }
}
