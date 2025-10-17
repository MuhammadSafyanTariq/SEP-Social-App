import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/textStyles.dart';

class ImagePreviewScreen extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;
  final VoidCallback? onSend;

  const ImagePreviewScreen({
    Key? key,
    this.imageFile,
    this.imageUrl,
    this.onSend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget imageWidget;

    if (imageFile != null) {
      imageWidget = Image.file(imageFile!);
    } else if (imageUrl != null) {
      imageWidget = Image.network(imageUrl!);
    } else {
      imageWidget = const Center(
        child: Text(
          'No image provided',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: PinchZoom(
              child: imageWidget,
              maxScale: 4.0,
            ),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          if (onSend != null)
            Positioned(
              bottom: 70,
              left: 20,
              right: 20,
              child: GestureDetector(
                onTap: onSend,
                child: AppButton(
                  buttonColor: AppColors.btnColor,
                  label: "Send",
                  labelStyle: 16.txtBoldBlack,
                  radius: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
