import 'package:flutter/material.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/styles/appColors.dart';

class LiveStreamTopicDialog {
  static Future<String?> show(BuildContext context) async {
    final TextEditingController topicController = TextEditingController();

    try {
      print('LiveStreamTopicDialog.show called');

      return await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          print('Building topic dialog');
          return Dialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              constraints: BoxConstraints(
                maxWidth: 400,
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    "Set Live Stream Topic",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    "Enter a topic for your live stream (optional)",
                    style: TextStyle(fontSize: 14, color: AppColors.grey),
                  ),

                  const SizedBox(height: 20),

                  // Text Input
                  TextField(
                    controller: topicController,
                    maxLines: 2,
                    maxLength: 50,
                    decoration: InputDecoration(
                      hintText: "e.g., Gaming Session, Chat Time, Tutorial...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primaryColor),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: "Skip",
                          onTap: () {
                            print('Skip button pressed');
                            Navigator.of(context).pop("");
                          },
                          buttonColor: AppColors.grey.withOpacity(0.3),
                          labelStyle: TextStyle(color: AppColors.black),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: "Start Live",
                          onTap: () {
                            print(
                              'Start Live button pressed with topic: ${topicController.text.trim()}',
                            );
                            Navigator.of(
                              context,
                            ).pop(topicController.text.trim());
                          },
                          buttonColor: AppColors.primaryColor,
                          labelStyle: TextStyle(color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      print('Error in LiveStreamTopicDialog.show: $e');
      // Return empty string to continue with live stream
      return "";
    }
  }
}
