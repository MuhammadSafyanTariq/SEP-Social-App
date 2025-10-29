import 'package:flutter/services.dart';
import 'package:intl/intl.dart';


class InputFormats {
  static final List<TextInputFormatter> phoneNo = [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)];
  static final List<TextInputFormatter> number = [FilteringTextInputFormatter.digitsOnly];
  static final List<TextInputFormatter> numberInclude_ = [
    // FilteringTextInputFormatter.digitsOnly,
  FilteringTextInputFormatter.allow(
      // RegExp(r'^[0-9\-]+$'),
  RegExp(r'[0-9\-]')
      // RegExp(r'^[0-9\-]*$')
      // '-1234567890'

  )
  // RegExp(r'[^-]'))

    // FilteringTextInputFormatter.allow(
    //
    //     RegExp(r'^[0-9\-]*$')
    //
    // )

  ];
  static final List<TextInputFormatter> amount = [FilteringTextInputFormatter.digitsOnly,
    FilteringTextInputFormatter.allow(
        RegExp(r'^[0-9]+(\.[0-9]{0,2})?$')

    ),
    ThousandsFormatter(),
  ];
}

class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text;
    if (newText.isEmpty) {
      return newValue;
    }
    int selectionIndex = newValue.selection.end;
    final String newTextFormatted = NumberFormat("#,##,##,###")
        .format(double.tryParse(newText.replaceAll(",", "")));
    if (newText == newTextFormatted) {
      return newValue;
    }
    selectionIndex += -(newText.length - newTextFormatted.length);
    return TextEditingValue(
      text: newTextFormatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}