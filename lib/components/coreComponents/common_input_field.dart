import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sep/components/styles/textStyles.dart';

import '../styles/appColors.dart';

class CommonInputField extends StatelessWidget {
  final String hint;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final TextInputType? inputType;
  final double? marginLeft;
  final double? marginRight;
  final double? marginTop;
  final double? marginBottom;
  final Widget? leading;
  final Widget? trailing;
  final List<TextInputFormatter>? inputFormatter;
  final TextCapitalization? textCapitalization;
  final String? errorText;
  final bool? isEnable;
  final RxBool? isShowTrailing;
  final Color? fillColor;
  final Color? borderColor;
  final int? maxLines;
  final FocusNode? focusNode;
  final bool? autoFocus;
  final bool? obscure;
  final double? height;
  final int? maxLength;
  final VoidCallback? onTap;
  final bool? selectionPoint;
  final bool readOnly;
  final EdgeInsets? margin;

  final TextInputAction? textInputAction;
  final OutlineInputBorder? underLineBorder;
  final EdgeInsets? edgesInsects;

  final inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.5)),
  );
  final errorInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    borderSide: const BorderSide(color: Colors.red),
  );

  CommonInputField({
    Key? key,
    this.controller,
    required this.hint,
    this.onChanged,
    this.validator,
    this.inputType,
    this.inputFormatter,
    this.marginLeft,
    this.marginRight,
    this.marginTop,
    this.marginBottom,
    this.leading,
    this.trailing,
    this.textCapitalization,
    this.errorText,
    this.isEnable,
    this.readOnly = false,
    this.isShowTrailing,
    this.fillColor,
    this.borderColor,
    this.maxLines,
    this.focusNode,
    this.onFieldSubmitted,
    this.autoFocus,
    this.underLineBorder,
    this.edgesInsects,
    this.obscure = false,
    this.height,
    this.textInputAction,
    this.maxLength,
    this.onTap,
    this.selectionPoint,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin:
          margin ??
          EdgeInsets.only(
            left: marginLeft ?? 16,
            right: marginRight ?? 16,
            top: marginTop ?? 8,
            bottom: marginBottom ?? 8,
          ),
      child: TextFormField(
        onTapOutside: (event) {
          FocusScope.of(context).unfocus();
        },
        onTap: onTap,
        maxLength: maxLength,
        obscureText: obscure ?? false,
        obscuringCharacter: "*",
        controller: controller,
        readOnly: readOnly,
        style: 14.txtRegularBlack,
        keyboardType: inputType ?? TextInputType.text,
        cursorColor: AppColors.primaryBlue,
        maxLines: maxLines ?? 1,
        textInputAction: textInputAction,

        decoration: InputDecoration(
          counterText: "",
          hintText: hint.tr,
          hintStyle: 14.txtRegularGrey,
          fillColor: fillColor ?? AppColors.colorF5,
          filled: true,
          errorText: errorText,
          prefixIcon: leading,
          suffixIcon: trailing,
          border: underLineBorder ?? inputBorder,
          errorBorder: underLineBorder ?? errorInputBorder,
          enabledBorder: underLineBorder ?? inputBorder,
          disabledBorder: underLineBorder ?? inputBorder,
          focusedBorder: underLineBorder ?? inputBorder,
          focusedErrorBorder: underLineBorder ?? errorInputBorder,
          errorStyle: 12.txtRegularError,
          contentPadding:
              edgesInsects ??
              const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          alignLabelWithHint: true,
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        inputFormatters: inputFormatter,
        validator: validator,
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
      ),
    );
  }
}
