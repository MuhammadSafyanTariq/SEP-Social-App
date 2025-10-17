import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import '../styles/appColors.dart';

class CommonPasswordInputField extends StatefulWidget {
  final String hint;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final TextEditingController controller;
  final TextInputType? inputType;
  final List<TextInputFormatter>? inputFormatter;
  final bool? isShowHelperText;
  final Widget? leading;
  final FocusNode? focusNode;
  final bool? autoFocus;
  final String? errorText;
  final TextInputAction? textInputAction;
  final Color? fillColor;
  final double? marginLeft;
  final double? marginRight;
  final double? marginTop;
  final double? marginBottom;
  final double? radius;

  CommonPasswordInputField({
    Key? key,
    required this.controller,
    required this.hint,
    this.onChanged,
    this.validator,
    this.errorText,
    this.inputType,
    this.inputFormatter,
    this.isShowHelperText,
    this.leading,
    this.focusNode,
    this.textInputAction,
    this.autoFocus,
    this.onFieldSubmitted,
    this.fillColor,
    this.marginLeft,
    this.marginBottom,
    this.marginRight,
    this.marginTop,
    this.radius,
  }) : super(key: key);

  @override
  State<CommonPasswordInputField> createState() =>
      _CommonPasswordInputFieldState();
}

class _CommonPasswordInputFieldState extends State<CommonPasswordInputField> {
  RxBool isObscure = true.obs;

  OutlineInputBorder get inputBorder => OutlineInputBorder(
    borderRadius: BorderRadius.circular(widget.radius ?? 10.0),
    borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.5)),
  );

  OutlineInputBorder get errorInputBorder => OutlineInputBorder(
    borderRadius: BorderRadius.circular(widget.radius ?? 10.0),
    borderSide: const BorderSide(color: Colors.red),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: widget.marginLeft ?? 0,
        right: widget.marginRight ?? 0,
        top: widget.marginTop ?? 8,
        bottom: widget.marginBottom ?? 8,
      ),
      child: Obx(
        () => TextFormField(
          // enableInteractiveSelection: false,
          onTapOutside: (event) {
            FocusScope.of(context).unfocus();
            // FocusManager.instance.primaryFocus?.unfocus();
          },
          controller: widget.controller,
          focusNode: widget.focusNode,
          autofocus: widget.autoFocus ?? false,
          textInputAction: widget.textInputAction,
          style: 14.txtMediumBlack,
          keyboardType: TextInputType.visiblePassword,
          cursorColor: AppColors.primaryBlue,
          obscureText: isObscure.value,
          obscuringCharacter: '*',
          decoration: InputDecoration(
            hintText: widget.hint.tr,
            hintStyle: 16.txtRegularGrey,
            prefixIcon: widget.leading,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  isObscure.value = !isObscure.value;
                });
              },
              icon: Icon(
                isObscure.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.greyHint,
                size: 22,
              ),
            ),
            filled: true,
            fillColor: widget.fillColor ?? AppColors.white,
            // helperText: isShowHelperText??true? 'message_password_helper'.tr : null,
            helperMaxLines: 2,
            helperStyle: 12.txtRegularGreyHint,
            errorMaxLines: 3,
            errorText: widget.errorText,
            errorStyle: 12.txtRegularError,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            border: inputBorder,
            errorBorder: errorInputBorder,
            enabledBorder: inputBorder,
            disabledBorder: inputBorder,
            focusedBorder: inputBorder,
            focusedErrorBorder: inputBorder,
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          inputFormatters: widget.inputFormatter,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
        ),
      ),
    );
  }
}
