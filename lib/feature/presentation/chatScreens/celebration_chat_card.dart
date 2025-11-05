import 'package:flutter/material.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/components/styles/appColors.dart';

class CelebrationChatCard extends StatelessWidget {
  final String content;
  final bool isSentByUser;

  const CelebrationChatCard({
    Key? key,
    required this.content,
    required this.isSentByUser,
  }) : super(key: key);

  String get celebrationText {
    // Remove "SEP#Celebrate" prefix, template ID, color, and coordinates to get just the message
    // Format: SEP#Celebrate+templateId+colorHex+posX+posY+message
    String text = content;
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
    String text = content;
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
    String text = content;
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
    String text = content;
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
    String text = content;
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
        (screenWidth * 0.75) - 16; // Account for chat bubble padding

    // Check if it's default template (square) or custom template (rectangular)
    final isDefaultTemplate = templatePath == AppImages.celebrateBack;
    final containerHeight = isDefaultTemplate
        ? containerWidth // Square for default template (same as post)
        : containerWidth *
              0.73; // Rectangular for custom templates (same as post)

    return Container(
      constraints: BoxConstraints(maxWidth: containerWidth),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: isSentByUser ? Radius.circular(12.0) : Radius.zero,
            topRight: isSentByUser ? Radius.zero : Radius.circular(12.0),
            bottomRight: const Radius.circular(12.0),
            bottomLeft: const Radius.circular(12.0),
          ),
        ),
        color: Colors.white,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Celebration label
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.celebration,
                      size: 16,
                      color: AppColors.btnColor,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Celebration',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.btnColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Celebration content with background image and text overlay
              Container(
                width: double.infinity,
                height: containerHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
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
                        left:
                            containerWidth * textPositionX -
                            (containerWidth *
                                0.4), // Proportional to container width
                        top:
                            containerHeight * textPositionY -
                            (containerHeight *
                                0.25), // Proportional to container height
                        child: Container(
                          width:
                              containerWidth *
                              0.8, // Proportional text container width
                          height:
                              containerHeight *
                              0.5, // Proportional text container height
                          padding: EdgeInsets.all(12),
                          child: Center(
                            child: Text(
                              celebrationText.isEmpty ? "🎉" : celebrationText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14, // Same font size as post
                                fontWeight: FontWeight.w600,
                                shadows: [
                                  Shadow(
                                    offset: Offset(1, 1),
                                    blurRadius: 2,
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                ],
                              ),
                              maxLines: 5, // Same max lines as post
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
