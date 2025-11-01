import 'package:flutter/material.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/post_card_header.dart';
import 'package:sep/feature/data/models/dataModels/post_data.dart';

class CelebrationCard extends StatelessWidget {
  final PostCardHeader header;
  final String caption;
  final Widget footer;
  final PostData data;

  const CelebrationCard({
    Key? key,
    required this.header,
    required this.caption,
    required this.footer,
    required this.data,
  }) : super(key: key);

  String get celebrationText {
    // Remove "SEP#Celebrate" prefix, template ID, color, and coordinates to get just the message
    // Format: SEP#Celebrate+templateId+colorHex+posX+posY+message
    String text = caption;
    if (text.startsWith('SEP#Celebrate')) {
      text = text.substring('SEP#Celebrate'.length).trim();
      // Remove leading + if present
      if (text.startsWith('+')) {
        text = text.substring(1);
      }
      // Extract message after template ID, color, and coordinates
      // Skip 4 sections: templateId, colorHex, posX, posY
      for (int i = 0; i < 4 && text.contains('+'); i++) {
        int plusIndex = text.indexOf('+');
        text = text.substring(plusIndex + 1);
      }
      return text.trim();
    }
    return text;
  }

  String get templatePath {
    // Parse template ID from caption format: SEP#Celebrate+templateId+message
    String text = caption;
    if (text.startsWith('SEP#Celebrate')) {
      text = text.substring('SEP#Celebrate'.length).trim();
      // Remove leading + if present
      if (text.startsWith('+')) {
        text = text.substring(1);
      }
      // Extract template ID before the second +
      if (text.contains('+')) {
        int plusIndex = text.indexOf('+');
        String templateId = text.substring(0, plusIndex);

        // Map template ID to asset path
        switch (templateId) {
          case 'template1':
            return AppImages.celebrateTemplate1;
          case 'template2':
            return AppImages.celebrateTemplate2;
          case 'template3':
            return AppImages.celebrateTemplate3;
          case 'template4':
            return AppImages.celebrateTemplate4;
          case 'template5':
            return AppImages.celebrateTemplate5;
          case 'template6':
            return AppImages.celebrateTemplate6;
          case 'template7':
            return AppImages.celebrateTemplate7;
          case 'template8':
            return AppImages.celebrateTemplate8;
          case 'template9':
            return AppImages.celebrateTemplate9;
          case 'default':
          default:
            return AppImages.celebrateBack;
        }
      }
    }
    // Default template if no specific template found
    return AppImages.celebrateBack;
  }

  double get textPositionX {
    // Parse X coordinate from caption format: SEP#Celebrate+templateId+colorHex+posX+posY+message
    String text = caption;
    if (text.startsWith('SEP#Celebrate')) {
      text = text.substring('SEP#Celebrate'.length).trim();
      if (text.startsWith('+')) {
        text = text.substring(1);
      }
      // Skip template ID and color to get to posX
      for (int i = 0; i < 2 && text.contains('+'); i++) {
        int plusIndex = text.indexOf('+');
        text = text.substring(plusIndex + 1);
      }
      // Extract posX (before next +)
      if (text.contains('+')) {
        int plusIndex = text.indexOf('+');
        String posXStr = text.substring(0, plusIndex);
        try {
          return double.parse(posXStr);
        } catch (e) {
          return 0.5; // Default center
        }
      }
    }
    return 0.5; // Default center
  }

  double get textPositionY {
    // Parse Y coordinate from caption format: SEP#Celebrate+templateId+colorHex+posX+posY+message
    String text = caption;
    if (text.startsWith('SEP#Celebrate')) {
      text = text.substring('SEP#Celebrate'.length).trim();
      if (text.startsWith('+')) {
        text = text.substring(1);
      }
      // Skip template ID, color, and posX to get to posY
      for (int i = 0; i < 3 && text.contains('+'); i++) {
        int plusIndex = text.indexOf('+');
        text = text.substring(plusIndex + 1);
      }
      // Extract posY (before next +)
      if (text.contains('+')) {
        int plusIndex = text.indexOf('+');
        String posYStr = text.substring(0, plusIndex);
        try {
          return double.parse(posYStr);
        } catch (e) {
          return 0.5; // Default center
        }
      }
    }
    return 0.5; // Default center
  }

  Color get textColor {
    // Parse color from caption format: SEP#Celebrate+templateId+colorHex+message
    String text = caption;
    if (text.startsWith('SEP#Celebrate')) {
      text = text.substring('SEP#Celebrate'.length).trim();
      if (text.startsWith('+')) {
        text = text.substring(1);
      }
      // Skip template ID to get to color
      if (text.contains('+')) {
        int firstPlus = text.indexOf('+');
        text = text.substring(firstPlus + 1);

        // Extract color hex (before second +)
        if (text.contains('+')) {
          int secondPlus = text.indexOf('+');
          String colorHex = text.substring(0, secondPlus);

          try {
            // Parse hex color
            int colorValue = int.parse(colorHex, radix: 16);
            return Color(colorValue);
          } catch (e) {
            // If parsing fails, return default green
            return Color(0xFF4CAF50);
          }
        }
      }
    }
    // Default green color
    return Color(0xFF4CAF50);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth =
        screenWidth - 20; // Account for card margins (10 per side)

    // Check if it's default template (square) or custom template (rectangular)
    final isDefaultTemplate = templatePath == AppImages.celebrateBack;
    final containerHeight = isDefaultTemplate
        ? containerWidth // Square for default
        : containerWidth * 0.73; // Rectangular for custom templates

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(10),
      color: Colors.white,
      child: Column(
        children: [
          header,
          // Celebration content with background image and text overlay
          Container(
            width: double.infinity,
            height: containerHeight,
            margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  // Background celebration image
                  Positioned.fill(
                    child: ImageView(
                      url: templatePath,
                      fit: BoxFit.cover,
                      imageType: ImageType.asset,
                    ),
                  ),
                  // Text overlay positioned based on x,y coordinates
                  Positioned(
                    left: containerWidth * textPositionX - 150,
                    top: containerHeight * textPositionY - 60,
                    child: Container(
                      width: 300,
                      height: 120,
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          celebrationText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          footer,
        ],
      ),
    );
  }
}
