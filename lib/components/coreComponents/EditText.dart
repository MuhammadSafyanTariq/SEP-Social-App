import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import '../styles/appColors.dart';
import '../styles/decoration.dart';
import 'TextView.dart';
class EditText extends StatefulWidget {
  final TextEditingController? controller;
  final bool? readOnly;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? radius;
  final Color? borderColor;
  final Color? filledColor;
  final bool isFilled;
  final String? hint;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final String? label;
  final TextStyle? labelStyle;
  final TextInputType? inputType;
  final int noOfLines;
  final String? suffixText;
  final TextStyle? suffixTextStyle;
  final Widget? prefixIcon;
  final TextAlign? textAlign;
  final int? maxLength;
  final Function(String)? onChange;
  final FocusNode? node;
  final Widget? suffixIcon;
  final InputDecoration? decoration;
  final AutovalidateMode? autovalidateMode;
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormat;
  final String? error;
  final BoxConstraints? prefixIconConstraints;
  final Function()? onTap;
  final bool isOptional;
  final bool obscureText;
  final String? Function(String?)? validator;
  //final bool enabled; // New enabled property

  const EditText({
    super.key,
    this.controller,
    this.readOnly,
    this.padding,
    this.margin,
    this.radius,
    this.borderColor,
    this.filledColor,
    this.isFilled = false,
    this.isOptional = false,
    this.hint,
    this.hintStyle,
    this.textStyle,
    this.label,
    this.labelStyle,
    this.inputType,
    this.noOfLines = 1,
    this.suffixText,
    this.suffixTextStyle,
    this.prefixIcon,
    this.textAlign,
    this.maxLength,
    this.onChange,
    this.node,
    this.suffixIcon,
    this.suffix,
    this.inputFormat,
    this.obscureText = false,
    this.error,
    this.onTap,
    this.prefixIconConstraints,
    this.validator,
    this.decoration,
    this.autovalidateMode,
    //this.enabled = true, // Default to true (enabled)
  });

  @override
  State<EditText> createState() => _EditTextState();
}

class _EditTextState extends State<EditText> {
  String? _error;

  @override
  Widget build(BuildContext context) {
    final borderStyle = AppDecoration.inputBorder(
      borderColor: _error != null ? Colors.red : AppColors.border,
      radius: widget.radius,
    );

    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: widget.label != null,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextView(
                  text: widget.label ?? '',
                  style: widget.labelStyle ?? 12.txtMediumBlack,
                  margin: const EdgeInsets.only(bottom: 4),
                ),
                if (widget.isOptional)
                  TextView(
                    text: '(Optional)',
                    style: 12.txtBoldWhite,
                    margin: const EdgeInsets.only(bottom: 4, left: 5),
                  ),
              ],
            ),
          ),
          TextFormField(
            autovalidateMode: widget.autovalidateMode ?? AutovalidateMode.onUserInteraction,
            validator: widget.validator,
            onTap: widget.onTap,
            focusNode: widget.node,
            // style: widget.textStyle ?? 14.txtBoldWhite,
            style: widget.textStyle ?? 14.txtSBoldprimary,
            textAlign: widget.textAlign ?? TextAlign.start,
            inputFormatters: widget.inputFormat,
            obscureText: widget.obscureText,
            onTapOutside: (event) => FocusScope.of(context).unfocus(),
           // enabled: widget.enabled, // Use the enabled property here
            decoration: InputDecoration(

              filled: true,
              fillColor: widget.filledColor ?? AppColors.white,
              isDense: true,
              hintText: widget.hint,
              hintStyle: widget.hintStyle ?? 16.txtRegularGrey,
              enabledBorder: borderStyle,
              border: borderStyle,
              focusedBorder: borderStyle,
              suffixStyle: widget.suffixTextStyle,
              suffixText: widget.suffixText,
              suffixIcon: widget.suffixIcon,
              suffix: widget.suffix,
              prefixIcon: widget.prefixIcon,
              contentPadding: widget.padding,
              prefixIconConstraints: widget.prefixIconConstraints,
            ),

            maxLength: widget.maxLength,
            minLines: widget.noOfLines,
            maxLines: widget.noOfLines,
            keyboardType: widget.inputType,
            readOnly: widget.readOnly ?? false,
            controller: widget.controller,
            onChanged: (value) {
              if (widget.onChange != null) {
                widget.onChange!(value);
              }
            },
            buildCounter: (context, {required currentLength, required isFocused, required maxLength}) =>
            const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
