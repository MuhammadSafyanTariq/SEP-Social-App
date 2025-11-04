import 'package:flutter/material.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'CreatePost.dart';
import 'polladd.dart';
import 'celebrationScreen.dart';

class TypeSelectionScreen extends StatelessWidget {
  const TypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextView(
          text: "Post",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            TextView(
              text: "Media Type Selection",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Spacer(), // This pushes the options to the bottom
            // Grid layout for options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionItem(
                  title: "Media",
                  icon: Icons.image,
                  onTap: () {
                    Navigator.pop(context);
                    context.pushNavigator(CreatePost(categoryid: ''));
                  },
                ),
                _buildOptionItem(
                  title: "Poll",
                  icon: Icons.poll_outlined,
                  onTap: () {
                    Navigator.pop(context);
                    context.pushNavigator(AddPoll());
                  },
                ),
                _buildOptionItem(
                  title: "Celebrate",
                  icon: Icons.celebration,
                  onTap: () {
                    Navigator.pop(context);
                    context.pushNavigator(CelebrationScreen());
                  },
                ),
              ],
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 28, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          TextView(
            text: title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
