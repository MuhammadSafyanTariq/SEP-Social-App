import 'package:flutter/material.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/utils/extensions/widget.dart';

class CommonGameCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const CommonGameCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final cardWidth = screenWidth * 0.9;
    final imageHeight = cardWidth * 9 / 27;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                imagePath,
                width: cardWidth,
                height: imageHeight,
                fit: BoxFit.cover,
              ),
            ),
            12.height,
            TextView(
              text: title,
              style: 16.txtBoldWhite,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
