import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:mat_month_picker_dialog/mat_month_picker_dialog.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:kioski/utils/extensions/loaderUtils.dart';
import '../../components/coreComponents/appBSheet.dart';
import '../../components/coreComponents/appDialog.dart';
import '../../components/coreComponents/loader.dart';
import '../../components/styles/appColors.dart';
import '../../services/networking/urls.dart';
import 'loaderUtils.dart';


//------------------------------[dimensions]------------------------------------
extension DimensionExtn on BuildContext {
  double get height => MediaQuery.of(this).size.height;
  double get getHeight => MediaQuery.of(this).size.height;
  double get getWidth => MediaQuery.of(this).size.width;
  Size get size => MediaQuery.of(this).size;
  double get width => MediaQuery.of(this).size.width;
  double get bottomSafeArea => MediaQuery.of(this).viewPadding.bottom;
  double get topSafeArea => MediaQuery.of(this).viewPadding.top;
}





//--------------------------------[ Navigation ]-------------------------------
extension NavigatorExtn on BuildContext {
// navigate to next screen
  Future<dynamic> pushNavigator(Widget screen) => Navigator.push(
      this, MaterialPageRoute(
    builder: (context) => screen, ));
// push and replace ......
  Future<dynamic> replaceNavigator(Widget screen) => Navigator.pushReplacement(
      this, MaterialPageRoute(
    builder: (context) => screen, ));
// clear stack and navigate to screen....
  void pushAndClearNavigator(Widget screen) {
    LoaderUtils.dismiss();
    LoaderUtils.dismiss();
    Navigator.pushAndRemoveUntil(
        this, MaterialPageRoute(
      builder: (context) => screen, ),
            (route) => false);
  }

//pop back...
  void pop({value}) => Navigator.pop(this, value); }






//------------------------------[Locale]----------------------------------------------
extension LocaleExtn on BuildContext{
  // AppLocalizations get locale => AppLocalizations.of(this)!;
  // Future<AppLocalizations> get localeEn => AppLocalizations.delegate.load(Locale('en'));
  // Future<AppLocalizations> get localeHi => AppLocalizations.delegate.load(Locale('hi'));
  // bool get isHindi => locale.lang == 'hi';
  // bool get isEnglish => locale.lang == 'en';
}











_lastDate()=> DateTime.now().add(const Duration(days: 365 * 50));
_firstDate()=> DateTime.now().subtract(const Duration(days: 365 * 50));


//--------------------------[Dialog]--------------------------------------------
extension AppStateExtn on BuildContext { // show progress loader....
  void  load({Key? key}) => loader(this, key: key);


// close progressLoader or dialog .....
  void get stopLoader => Navigator.of(this, rootNavigator: true).pop('dialog');
  Future<DateTime?> get datePicker { return showDatePicker(
      context: this,
      initialDate: DateTime.now(), firstDate: _firstDate(), lastDate: _lastDate());
  }
  // Future<DateTime?> dateMonthPicker({DateTime? firstDate, DateTime? lastDate}) async{
  //   return showMonthPicker(
  //       context: this,
  //       initialDate: DateTime.now(),
  //       firstDate: firstDate ?? _firstDate(),
  //       lastDate: lastDate ?? _lastDate()
  //   );
  // }
  Future<DateTime?>  datePickerWithOptions({DateTime? firstDate, DateTime? lastDate}) async { return showDatePicker(
      context: this,
      initialDate: DateTime.now(), firstDate: firstDate ?? _firstDate(), lastDate: lastDate ?? _lastDate());
  }
  Future<TimeOfDay?> get timePicker { return showTimePicker(
      context: this,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => MediaQuery(

        data:
        MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false), child: child!,
      )); }

  // Future<TimeRange> get timeRangePicker async{
  //   TimeRange result = await showTimeRangePicker(
  //     context: this,
  //     backgroundColor: AppColors.white,
  //     disabledColor: AppColors.white,
  //     handlerColor: AppColors.white,
  //     selectedColor: AppColors.white,
  //     strokeColor: AppColors.white,
  //     // backgroundWidget: AppColors.white
  //   );
  //   return result;
  // }


  // TimeRangePicker get timeRangePicker {
  //   return TimeRangePicker(
  //     initialFromHour: DateTime.now().hour,
  //     initialFromMinutes: DateTime.now().minute,
  //     initialToHour: DateTime.now().hour,
  //     initialToMinutes: DateTime.now().minute,
  //     backText: "Back",
  //     nextText: "Next",
  //     cancelText: "Cancel",
  //     selectText: "Select",
  //     editable: true,
  //     is24Format: false,
  //     disableTabInteraction: true,
  //     iconCancel: Icon(Icons.cancel_presentation, size: 12),
  //     iconNext: Icon(Icons.arrow_forward, size: 12),
  //     iconBack: Icon(Icons.arrow_back, size: 12),
  //     iconSelect: Icon(Icons.check, size: 12),
  //     inactiveBgColor: AppColors.greyHint
  //
  //     // Colors.grey[800]
  //     ,
  //     timeContainerStyle: BoxDecoration(
  //         color: Colors.grey[800],
  //         borderRadius: BorderRadius.circular(7)),
  //     separatorStyle: TextStyle(color: Colors.grey[900], fontSize: 30),
  //     onSelect: (from, to) {
  //
  //       // _messangerKey.currentState.showSnackBar(
  //       //     SnackBar(content: Text("From : $from, To : $to")));
  //       Navigator.pop(this);
  //     },
  //     onCancel: () => Navigator.pop(this),
  //   );
  // }






  // // 12 Hour Format and custom style
  // Future<void> showTimeRangePicker12Hour(BuildContext context) {
  //   return showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text("Choose event time"),
  //           content: TimeRangePicker(
  //             initialFromHour: DateTime.now().hour,
  //             initialFromMinutes: DateTime.now().minute,
  //             initialToHour: DateTime.now().hour,
  //             initialToMinutes: DateTime.now().minute,
  //             backText: "Back",
  //             nextText: "Next",
  //             cancelText: "Cancel",
  //             selectText: "Select",
  //             editable: true,
  //             is24Format: false,
  //             disableTabInteraction: true,
  //             iconCancel: Icon(Icons.cancel_presentation, size: 12),
  //             iconNext: Icon(Icons.arrow_forward, size: 12),
  //             iconBack: Icon(Icons.arrow_back, size: 12),
  //             iconSelect: Icon(Icons.check, size: 12),
  //             inactiveBgColor: Colors.grey[800],
  //             timeContainerStyle: BoxDecoration(
  //                 color: Colors.grey[800],
  //                 borderRadius: BorderRadius.circular(7)),
  //             separatorStyle: TextStyle(color: Colors.grey[900], fontSize: 30),
  //             onSelect: (from, to) {
  //               _messangerKey.currentState.showSnackBar(
  //                   SnackBar(content: Text("From : $from, To : $to")));
  //               Navigator.pop(context);
  //             },
  //             onCancel: () => Navigator.pop(context),
  //           ),
  //         );
  //       });
  // }
// show popup dialog ....
  void openDialog(Widget child,{bool barrierDismissible = true, Color bgColor = AppColors.white,Key? key}) => appDialog(this, child,barrierDismissible: barrierDismissible, bgColor: bgColor);



// show popup dialog ....
//   void openFailureDialog(String message) => appDialog(
//       this, FailureMessageDialog(
//     message: message, onTap: () {
//     stopLoader; },
//     dismiss: () { stopLoader;
//     }, ));




// show bottom sheet ....
Future<T?> openBottomSheet<T>(Widget child) => appBSheet<T>(this,child);
// check whether is portrait mode state ...
  bool get isPortraitMode =>
      MediaQuery.of(this).orientation == Orientation.portrait;






}



