// import 'package:flutter/material.dart';
// import 'package:intl_phone_number_input/intl_phone_number_input.dart';
// import 'package:suffi/components/styles/appColors.dart';
//
// class Commoninputnumberfield extends StatelessWidget {
//   final String hint;
//   final TextInputType inputType;
//   final TextEditingController? controller;
//
//   const Commoninputnumberfield({
//     required this.hint,
//     required this.inputType,
//     this.controller,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: AppColors.grey,
//         ),
//       ),
//       child: InternationalPhoneNumberInput(
//         onInputChanged: (PhoneNumber number) {
//           print(number.phoneNumber);
//         },
//         onInputValidated: (bool value) {
//           print(value);
//         },
//         selectorConfig: SelectorConfig(
//           selectorType: PhoneInputSelectorType.DROPDOWN,
//           showFlags: true,
//           useEmoji: true,
//         ),
//         ignoreBlank: false,
//         autoValidateMode: AutovalidateMode.disabled,
//         selectorTextStyle: TextStyle(color: Colors.black),
//         initialValue: PhoneNumber(isoCode: 'IN'),
//         textFieldController: controller,
//         inputDecoration: InputDecoration(
//           hintText: hint,
//           border: InputBorder.none, // Removes the border line
//           contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         ),
//         keyboardType: inputType == TextInputType.phone
//             ? TextInputType.numberWithOptions(signed: true, decimal: false)
//             : inputType,
//         onSaved: (PhoneNumber number) {
//           print('On Saved: $number');
//         },
//       ),
//     );
//   }
// }
