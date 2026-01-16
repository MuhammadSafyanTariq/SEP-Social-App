import 'package:flutter/material.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import 'package:sep/utils/extensions/widget.dart';

import '../../../components/coreComponents/ImageView.dart';
import '../../../components/coreComponents/TextView.dart';
import '../../../components/styles/appColors.dart';
import '../../../components/styles/appImages.dart';
import '../../data/models/dataModels/post_data.dart';
import 'homeScreenComponents/pollCard.dart';

class ViewResult extends StatefulWidget {
  final List<Option> options;
  final List<Vote> votes;
  const ViewResult({super.key, required this.options, required this.votes});

  @override
  State<ViewResult> createState() => _ViewResultState();
}

class _ViewResultState extends State<ViewResult> {
  @override
  Widget build(BuildContext context) {
    final int totalVotes = widget.votes.length;

    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      appBar: AppBar(
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            context.pop();
          },
          child: Icon(Icons.arrow_back_ios, color: Color(0xFFD4AF37), size: 20),
        ),
        centerTitle: true,
        title: Text(
          "Poll Result",
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Color(0xFF0A0A0A),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.5),
            radius: 1.2,
            colors: [Color(0xFF2A1810), Color(0xFF0A0A0A), Color(0xFF000000)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                40.height,
                // Trophy Image
                Hero(
                  tag: 'trophy',
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFD4AF37).withOpacity(0.3),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: ImageView(url: AppImages.winner, size: 200),
                  ),
                ),
                30.height,
                // Winner Name
                Text(
                  widget.options.first.name ?? 'Winner',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: Color(0xFFD4AF37).withOpacity(0.5),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
                50.height,
                // Result Card
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                  decoration: BoxDecoration(
                    color: Color(0xFF1A1410).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Color(0xFFD4AF37).withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Thank you for playing',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      20.height,
                      Divider(
                        color: Color(0xFFD4AF37).withOpacity(0.2),
                        thickness: 1,
                      ),
                      20.height,
                      Text(
                        'Results are for\nentertainment purposes only',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFB8A070),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
