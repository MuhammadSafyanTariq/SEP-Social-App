import 'package:flutter/material.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';

import '../styles/appColors.dart';

Future<T?> appBSheet<T>(BuildContext context, Widget child, {Color? barrierColor}) {
  return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      barrierColor: barrierColor,
      backgroundColor: AppColors.white,
    constraints: BoxConstraints(
      maxHeight: context.getHeight * 0.9
    ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(
            // AppFonts.s30
            30), topLeft: Radius.circular(
            // AppFonts.s30
            30)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(
              top:
              // AppFonts.s20
              20),
          child: Padding(
            padding: EdgeInsets.only(bottom: context.bottomSafeArea +
                MediaQuery.of(context).viewInsets.bottom
            ),
            child: child,
          ),
        );




        //   DraggableScrollableSheet(
        //   expand: false,
        //   builder: (context, scrollController) {
        //     return SingleChildScrollView(
        //       controller: scrollController,
        //       child: Padding(
        //         padding: const EdgeInsets.only(
        //             top:
        //             // AppFonts.s20
        //             20),
        //         child: Padding(
        //           padding: EdgeInsets.only(bottom: context.bottomSafeArea),
        //           child: child,
        //         ),
        //       ),
        //     );
        //   },
        // )
      });
}
