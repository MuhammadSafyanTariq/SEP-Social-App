import 'package:flutter/material.dart';

/// Standardized dialog styles matching the screenshot design
class DialogStyles {
  // Colors
  static const Color dialogBackground = Colors.white; // #FFFFFF
  static const Color titleColor = Color(0xFF333333); // Dark gray/black
  static const Color bodyColor = Color(0xFF737373); // Medium gray
  static const Color buttonTextColor = Color(0xFF333333); // Dark gray/black
  static const Color barrierColor = Colors.black; // #000000

  // Font sizes
  static const double titleFontSize = 20.0; // Largest text
  static const double bodyFontSize = 15.0; // Standard body text
  static const double buttonFontSize = 16.0; // Slightly larger than body

  // Font weights
  static const FontWeight titleWeight = FontWeight.bold;
  static const FontWeight bodyWeight = FontWeight.normal;
  static const FontWeight buttonWeight = FontWeight.bold;

  // Font family - using system default sans-serif
  static const String? fontFamily = null; // null = system default

  /// Title text style for dialogs
  static TextStyle get titleStyle => TextStyle(
        fontSize: titleFontSize,
        fontWeight: titleWeight,
        color: titleColor,
        fontFamily: fontFamily,
      );

  /// Body text style for dialogs
  static TextStyle get bodyStyle => TextStyle(
        fontSize: bodyFontSize,
        fontWeight: bodyWeight,
        color: bodyColor,
        fontFamily: fontFamily,
        height: 1.5, // Line height for readability
      );

  /// Button text style for dialogs
  static TextStyle get buttonStyle => TextStyle(
        fontSize: buttonFontSize,
        fontWeight: buttonWeight,
        color: buttonTextColor,
        fontFamily: fontFamily,
      );

  /// Bold text within body (for Terms of Service, Privacy Policy, etc.)
  static TextStyle get bodyBoldStyle => TextStyle(
        fontSize: bodyFontSize,
        fontWeight: FontWeight.bold,
        color: bodyColor,
        fontFamily: fontFamily,
        height: 1.5,
      );
}
