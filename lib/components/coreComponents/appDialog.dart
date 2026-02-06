import 'package:flutter/material.dart';

import 'dialog_styles.dart';

appDialog(BuildContext context, Widget child,
    {bool barrierDismissible = true, Color bgColor = DialogStyles.dialogBackground, Key? key}) {

  final alertDialog = AlertDialog(
    key: key,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(
          // AppFonts.s16
            6))),
    backgroundColor: bgColor,
    shadowColor: Colors.transparent,
    insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40
      // horizontal: AppFonts.s16, vertical: AppFonts.s40
    ),
    content: SizedBox(width: double.maxFinite, child: child),
  );


  showDialog(
      context: context,
      useSafeArea: true,
      barrierDismissible: barrierDismissible,
      barrierColor: DialogStyles.barrierColor.withOpacity(0.5), // Black barrier with opacity
      builder: (_) => FractionallySizedBox(
        widthFactor: 0.9,
        child: Material(
          type: MaterialType.transparency,
          child: alertDialog,
        ),
      )



          // AnimateDialog(
          //   childView: alertDialog,
          // )
  );
}

class AnimateDialog extends StatelessWidget {
  final Widget childView;

  const AnimateDialog({super.key, required this.childView});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
        tween: Tween<double>(begin: 0, end: 1),
        builder: (BuildContext context, double value, Widget? child) {
          return Transform.scale(
            scale: value,
            child: childView,
          );
        });
  }
}
