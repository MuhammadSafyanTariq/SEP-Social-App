import 'package:flutter/material.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/components/styles/appColors.dart';
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
    // Remove "SEP#Celebrate" prefix and any trailing text after the celebration message
    String text = caption;
    if (text.startsWith('SEP#Celebrate')) {
      text = text.substring('SEP#Celebrate'.length).trim();
      // Remove any additional formatting that might have been added
      if (text.startsWith('+')) {
        text = text.substring(1).trim();
      }
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
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
            height:
                MediaQuery.of(context).size.width -
                40, // 1:1 aspect ratio (square)
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                children: [
                  // Background celebration image
                  Positioned.fill(
                    child: ImageView(
                      url: AppImages.celebrateBack,
                      fit: BoxFit.cover,
                      imageType: ImageType.asset,
                    ),
                  ),
                  // Text overlay positioned at 0.6 of height
                  Positioned(
                    left: 20,
                    right: 20,
                    top:
                        (MediaQuery.of(context).size.width - 20) *
                        0.6, // 0.6 of container height
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        celebrationText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.greenlight,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.8),
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
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
