// import 'package:flutter/material.dart';
// import 'package:sep/components/coreComponents/TextView.dart';
// import 'package:sep/components/styles/appColors.dart';
// import 'package:sep/components/styles/textStyles.dart';
// import 'package:sep/utils/extensions/size.dart';

// class ProgressLine extends StatelessWidget {
//   final int currentStep;
//   final int totalSteps;

//   const ProgressLine({
//     Key? key,
//     required this.currentStep,
//     required this.totalSteps,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     bool isStepCompleted = currentStep == totalSteps;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 0.0),
//           child: TextView(
//             textAlign: TextAlign.center,
//             text: 'Step $currentStep of $totalSteps',
//             style:12.txtBoldWhite,
//             margin: 5.bottom,
//           ),
//         ),
//         Container(
//           height: 5.0,
//           margin: const EdgeInsets.symmetric(horizontal: 0.0),
//           child: Stack(
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(2.0),
//                 ),
//               ),
//               FractionallySizedBox(
//                 widthFactor: currentStep / totalSteps,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: AppColors.btnColor,
//                     borderRadius: BorderRadius.circular(2.0),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
