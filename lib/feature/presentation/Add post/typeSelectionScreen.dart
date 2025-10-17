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
            SizedBox(height: 40),

            // Post Option
            _buildSelectionCard(
              title: "Post",
              icon: AppImages.post, // Using post.png
              onTap: () {
                Navigator.pop(context);
                context.pushNavigator(CreatePost(categoryid: ''));
              },
            ),

            SizedBox(height: 20),

            // Poll Option
            _buildSelectionCard(
              title: "Poll",
              icon: AppImages.poll, // Using poll.png
              onTap: () {
                Navigator.pop(context);
                context.pushNavigator(AddPoll());
              },
            ),

            SizedBox(height: 20),

            // Celebrate Option
            _buildSelectionCard(
              title: "Celebrate",
              icon: AppImages.celebrate, // Using celebrate.png
              onTap: () {
                Navigator.pop(context);
                context.pushNavigator(CelebrationScreen());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextView(
                text: title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            ImageView(url: icon, width: 60, height: 60, fit: BoxFit.contain),
          ],
        ),
      ),
    );
  }
}
