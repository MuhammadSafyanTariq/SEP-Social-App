import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/components/styles/app_strings.dart';
import 'package:sep/feature/presentation/game_screens/gun_firing_game/gun_firing_Screen.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/widget.dart';
import 'flappy_game/FlameGameScreen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.sdp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    10.height,

                    // Play & Earn Rewards Section
                    TextView(
                      text: AppStrings.playEarnRewards.tr,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    8.height,
                    TextView(
                      text: AppStrings.haveFunWinPoints.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey,
                      ),
                    ),
                    24.height,

                    // Featured Games Section
                    TextView(
                      text: AppStrings.featuredGames.tr,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    16.height,

                    // Game Cards Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.sdp,
                      mainAxisSpacing: 16.sdp,
                      childAspectRatio: 0.8,
                      children: [
                        _buildEnhancedGameCard(
                          context,
                          title: AppStrings.flappyBird.tr,
                          subtitle: '', // Not used anymore
                          imagePath: AppImages.flappyBird,
                          backgroundColor: AppColors.white,
                          onTap: () {
                            context.pushNavigator(FlameGameScreen());
                          },
                        ),
                        _buildEnhancedGameCard(
                          context,
                          title: AppStrings.shootingRush.tr,
                          subtitle: '', // Not used anymore
                          imagePath: AppImages.shootinggameImag,
                          backgroundColor: AppColors.white,
                          onTap: () {
                            context.pushNavigator(GunFiringScreen());
                          },
                        ),
                      ],
                    ),

                    20.height,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedGameCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String imagePath,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16.sdp),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.sdp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Square image with all corners rounded
              AspectRatio(
                aspectRatio: 1.0, // Makes it square
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.sdp),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.sdp),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: backgroundColor.withOpacity(0.3),
                          child: Icon(
                            Icons.games,
                            size: 40.sdp,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              12.height,
              // Only title, no subtitle
              TextView(
                text: title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor
                ),
                textAlign: TextAlign.center,
                maxlines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
