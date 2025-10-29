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

class LiveStatusButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  Row(
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
              Obx(()=> TextView(text: AgoraChatCtrl.find.liveCountValue, style: 14.txtMediumWhite)),
            ],
          ),
        ),
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
              border: Border.all(color: AppColors.grey.withValues(alpha: 0.8), width: 2.5),
            ),
            child: Center(
              child: Container(
                width: 30,
                height: 30,
                decoration:  BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.grey.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        TextView(text: 'LIVE',
          style: 14.txtBoldGrey.withShadow(AppColors.grey),
          margin: EdgeInsets.only(bottom: context.bottomSafeArea),
          )
      ],
    );
  }
}
OutlineInputBorder get _inputBorder =>OutlineInputBorder(
  borderRadius: BorderRadius.circular(50),
  borderSide: BorderSide(color: AppColors.grey, width: 2),
);

class ChatInputBox extends StatelessWidget {
  final TextEditingController _msgCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.zero

      // EdgeInsets.symmetric(horizontal: 16) +
      //     EdgeInsets.only(bottom: context.bottomSafeArea, top: 5)

      ,
      child: TextFormField(
        onTapOutside: (event) =>  FocusScope.of(context).unfocus(),
        controller: _msgCtrl,
        maxLines: null,
        style: 14.txtRegularBlack.withShadow(AppColors.grey),
        decoration:  InputDecoration(
          hintText: 'Type something...',
          // hintStyle: 14.txtBoldGrey,
          hintStyle: 14.txtRegularRetake1,
          border: _inputBorder,
          fillColor: AppColors.grey.withValues(alpha: 0.45),
          enabledBorder: _inputBorder,
          focusedBorder: _inputBorder,
          filled: true,
          suffixIcon: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ImageView(
                onTap: () {
                  final text = _msgCtrl.getText;
                  if (text.isNotNullEmpty) {
                    AgoraChatCtrl.find.sendMessage(text);
                    _msgCtrl.clear();
                  }
                },
                  url: 'assets/images/sendmsg.png', size: 40, margin: EdgeInsets.only(right: 10, top: 3),)
            ],
          )
        ),
      ),
    );




      Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.emoji_emotions_outlined), onPressed: () {}),
          Expanded(
            child: TextFormField(
              onTapOutside: (event) =>  FocusScope.of(context).unfocus(),
              controller: _msgCtrl,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Type something...',
                border: InputBorder.none,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              final text = _msgCtrl.getText;
              if (text.isNotNullEmpty) {
                AgoraChatCtrl.find.sendMessage(text);
                _msgCtrl.clear();
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 5),
              child: ImageView(url: 'assets/images/sendmsg.png', size: 40),
            ),
          ),
        ],
      ),
    );
  }
}

class IconControl extends StatelessWidget {
  final IconData? icon;
  final String? url;
  final VoidCallback onTap;

  const IconControl({ this.icon, required this.onTap, this.url});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: 0.35), // semi-transparent dark bg
              shape: BoxShape.circle,
            ),
           child:  icon != null ?
            Icon(icon, size: 24, color: Colors.black45) :
            ImageView(url: url ?? '', size: 24, tintColor: Colors.black45,)
        ),
      ),
    );
  }
}