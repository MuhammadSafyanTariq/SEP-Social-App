import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/textStyle.dart';

import '../../../../components/coreComponents/AppButton.dart';
import '../../../../components/coreComponents/ImageView.dart';
import '../../../../components/coreComponents/TextView.dart';
import '../../../../components/styles/appColors.dart';
import '../../../../components/styles/appImages.dart';
import '../../controller/agora_chat_ctrl.dart';
import '../live_stream_ctrl.dart';

class LiveStatusButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppButton(
          buttonColor: AppColors.red,
          isFilledButton: false,
          label: 'LIVE',
          labelStyle: 14.txtsemiBoldWhite,
          radius: 8,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        const SizedBox(width: 5),
        AppButton(
          buttonColor: AppColors.grey,
          isFilledButton: false,
          radius: 8,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              ImageView(
                url: AppImages.seen,
                size: 18,
                tintColor: AppColors.white,
              ),
              const SizedBox(width: 7),
              Obx(
                () => TextView(
                  text: AgoraChatCtrl.find.liveCountValue,
                  style: 14.txtMediumWhite,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        // Recording indicator
        Obx(() {
          final isRecording = LiveStreamCtrl.find.isRecording.value;
          if (!isRecording) return const SizedBox.shrink();

          return AppButton(
            buttonColor: AppColors.red,
            isFilledButton: false,
            radius: 8,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.fiber_manual_record, color: Colors.white, size: 16),
                const SizedBox(width: 5),
                TextView(text: 'REC', style: 14.txtsemiBoldWhite),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class StartStreamButton extends StatelessWidget {
  final VoidCallback onPressed;

  const StartStreamButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white.withValues(alpha: 0.2),
              border: Border.all(
                color: AppColors.grey.withValues(alpha: 0.8),
                width: 2.5,
              ),
            ),
            child: Center(
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.grey.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        TextView(
          text: 'LIVE',
          style: 14.txtBoldGrey.withShadow(AppColors.grey),
          margin: EdgeInsets.only(bottom: context.bottomSafeArea),
        ),
      ],
    );
  }
}

OutlineInputBorder get _inputBorder => OutlineInputBorder(
  borderRadius: BorderRadius.circular(50),
  borderSide: BorderSide(color: AppColors.grey, width: 2),
);

class ChatInputBox extends StatefulWidget {
  const ChatInputBox({Key? key}) : super(key: key);

  @override
  State<ChatInputBox> createState() => _ChatInputBoxState();
}

class _ChatInputBoxState extends State<ChatInputBox> {
  final TextEditingController _msgCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _msgCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgCtrl.getText;
    if (text.isNotNullEmpty) {
      AgoraChatCtrl.find.sendMessage(text);
      _msgCtrl.clear();
      // Unfocus to close keyboard after sending
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: 48,
            maxWidth: constraints.maxWidth,
          ),
          child: TextFormField(
            focusNode: _focusNode,
            onTapOutside: (event) => FocusScope.of(context).unfocus(),
            controller: _msgCtrl,
            maxLines: 1,
            textInputAction: TextInputAction.send,
            onFieldSubmitted: (_) => _sendMessage(),
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  color: Colors.white.withOpacity(0.5),
                  offset: Offset(0, 0),
                  blurRadius: 2,
                ),
              ],
            ),
            decoration: InputDecoration(
              hintText: 'Type something...',
              hintStyle: TextStyle(
                fontSize: isSmallScreen ? 12 : 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
              border: _inputBorder,
              fillColor: Colors.white.withOpacity(0.9),
              enabledBorder: _inputBorder,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(color: AppColors.btnColor, width: 2),
              ),
              filled: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 6 : 10,
              ),
              suffixIcon: GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  margin: EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: AppColors.btnColor,
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: isSmallScreen ? 18 : 20,
                  ),
                ),
              ),
              suffixIconConstraints: BoxConstraints(
                minWidth: isSmallScreen ? 44 : 48,
                minHeight: isSmallScreen ? 44 : 48,
              ),
              isDense: true,
            ),
          ),
        );
      },
    );
  }
}

class IconControl extends StatelessWidget {
  final IconData? icon;
  final String? url;
  final VoidCallback onTap;

  const IconControl({this.icon, required this.onTap, this.url});

  static const double _iconSize = 20;
  static const double _padding = 6;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(_padding),
          decoration: BoxDecoration(
            color: AppColors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: icon != null
              ? Icon(
                  icon,
                  size: _iconSize,
                  color: Colors.white,
                )
              : ImageView(
                  url: url ?? '',
                  size: _iconSize,
                  tintColor: Colors.white,
                ),
        ),
      ),
    );
  }
}
