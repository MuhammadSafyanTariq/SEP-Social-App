import 'package:flutter/material.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/utils/extensions/size.dart';

class ProgressIndicator3Steps extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProgressIndicator3Steps({
    Key? key,
    required this.currentStep,
    this.totalSteps = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: List.generate(totalSteps, (index) {
                  final isActive = index < currentStep;
                  return Expanded(
                    child: Container(
                      height: 4.sdp,
                      margin: EdgeInsets.only(
                        right: index < totalSteps - 1 ? 8.sdp : 0,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.btnColor
                            : AppColors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2.sdp),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.sdp),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('$currentStep of $totalSteps', style: 12.txtRegularbtncolor),
          ],
        ),
      ],
    );
  }
}
