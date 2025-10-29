import 'package:flutter/material.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import '../styles/appColors.dart';
import 'ImageView.dart';
import 'TextView.dart';

class AppBar2 extends StatelessWidget {
  final EdgeInsets? padding;
  final Widget? leadWidget; // Change from String to Widget
  final String? leadicon; // Change from String to Widget

  final bool isLeadVisible;
  final double? leadIconSize;
  final double? leadIconBottomMargin;
  final Function()? onLeadTap;
  final Widget? tail;
  final String? title;
  final TextStyle? titleStyle;
  final Widget? child;
  final Color? appBarColor;
  final bool hasShadow;
  final bool hasTopSafe;
  final TextAlign? titleAlign;
  final String? prefixImage;
  final String? suffixImage;
  final Function()? onPrefixTap;
  final Function()? onSuffixTap;
  final Widget? suffixWidget;
  final Color backgroundColor; // Background color property

  const AppBar2({
    super.key,
    this.padding,
    this.leadWidget, // Use leadWidget instead of leadIcon
    this.onLeadTap,
    this.leadIconSize,
    this.tail,
    this.isLeadVisible = true,
    this.title,
    this.titleStyle,
    this.child,
    this.leadIconBottomMargin,
    this.appBarColor = Colors.white,
    this.hasShadow = true,
    this.hasTopSafe = true,
    this.titleAlign = TextAlign.center,
    this.prefixImage,
    this.suffixImage,
    this.onPrefixTap,
    this.onSuffixTap,
    this.suffixWidget,

    this.leadicon,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    Widget leadwidget() {
      return Visibility(
        visible: isLeadVisible,
        child: leadWidget ?? Container(), // Use leadWidget here
      );
    }

    Widget leadView() {
      return Visibility(
        visible: false, // Disabled to avoid showing two back icons
        child: ImageView(
          onTap: onLeadTap,
          url: leadicon ?? AppImages.backBtn,
          size: leadIconSize ?? 24,
          margin: leadIconBottomMargin != null
              ? EdgeInsets.fromLTRB(0, 0, 0, leadIconBottomMargin!)
              : const EdgeInsets.only(right: 10),
        ),
      );
    }

    // Widget for prefix image
    Widget prefixView() {
      return Visibility(
        visible: prefixImage != null,
        child: GestureDetector(
          onTap: onPrefixTap,
          child: Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.greenlight),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.greenlight,
              size: 20,
            ),
          ),
        ),
      );
    }

    // Suffix widget or image
    Widget suffixView() {
      return Visibility(
        visible: suffixWidget != null || suffixImage != null,
        child:
            suffixWidget ??
            (suffixImage != null
                ? ImageView(
                    onTap: onSuffixTap,
                    url: suffixImage!,
                    size: leadIconSize ?? 55,
                    margin: const EdgeInsets.only(left: 0),
                  )
                : Container()),
      );
    }

    return SafeArea(
      top: hasTopSafe,
      bottom: false,
      child: Container(
        color: backgroundColor, // Set the background color here
        padding: padding ?? EdgeInsets.all(8.0), // Optional padding
        child: Stack(
          children: [
            // Left side elements
            Row(children: [prefixView(), leadwidget(), leadView()]),

            // Centered title
            Center(
              child: title != null
                  ? TextView(
                      text: title!,
                      style: titleStyle ?? 16.txtMediumBlack,
                      textAlign: titleAlign,
                    )
                  : child ?? Container(),
            ),

            // Right side elements
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Tail (can be a button or icon)
                tail ??
                    Opacity(
                      opacity: 0.0,
                      child: Stack(
                        children: [
                          leadView(),
                          Positioned.fill(child: GestureDetector(onTap: () {})),
                        ],
                      ),
                    ),
                // Suffix widget or image at the end
                suffixView(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
