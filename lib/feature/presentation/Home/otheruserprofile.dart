import 'package:flutter/material.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';

import '../../../components/coreComponents/ImageView.dart';

class OtheruserProfile extends StatefulWidget {
  const OtheruserProfile({Key? key}) : super(key: key);

  @override
  State<OtheruserProfile> createState() => _OtheruserProfileState();
}

class _OtheruserProfileState extends State<OtheruserProfile> {
  int _selectedTab = 0;
  PageController _pageController = PageController(initialPage: 0);

  String _getJoinedText() {
    // This is a placeholder - in a real app, you'd pass the createdAt date
    // For now, returning a default message
    return 'Recently joined';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Cover Photo Section
            SliverToBoxAdapter(child: _buildCoverPhotoSection()),
            // Profile Info Section
            SliverToBoxAdapter(child: _buildProfileInfoSection()),
            // Stats Section
            SliverToBoxAdapter(child: _buildStatsSection()),
            // Action Buttons (Link/Message)
            SliverToBoxAdapter(child: _buildActionButtons()),
            // Tabs Section
            SliverToBoxAdapter(child: _buildTabsSection()),
            // Posts Grid Section
            SliverToBoxAdapter(child: _buildPostsGridSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverPhotoSection() {
    return Container(
      height: 240,
      width: double.infinity,
      child: Stack(
        children: [
          // Cover Photo or Default Background
          Container(
            height: 200,
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, AppColors.greenSplash, Colors.black],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ImageView(
                      url: AppImages.splashLogo,
                      height: 70,
                      width: 70,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Back button
          Positioned(
            top: 10,
            left: 10,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          // More options button
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.more_vert, color: Colors.white, size: 20),
            ),
          ),
          // Profile Picture (overlapping)
          Positioned(
            bottom: 0,
            left: MediaQuery.of(context).size.width / 2 - 50,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: ClipOval(
                child: ImageView(
                  url: "assets/images/prf.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Name
          TextView(
            text: 'John Doe',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4),
          // Join Date
          TextView(
            text: _getJoinedText(),
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
          SizedBox(height: 8),
          // Bio (if any)
          TextView(
            text: 'Living life to the fullest! 🌟',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatItem('10', 'Posts'),
              Container(
                height: 30,
                width: 1,
                color: Colors.grey[400],
                margin: EdgeInsets.symmetric(horizontal: 20),
              ),
              _buildStatItem('10', 'Linked Me'),
              Container(
                height: 30,
                width: 1,
                color: Colors.grey[400],
                margin: EdgeInsets.symmetric(horizontal: 20),
              ),
              _buildStatItem('10', 'Link Ups'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        TextView(
          text: count,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 2),
        TextView(
          text: label,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: AppColors.btnColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: TextView(
                  text: "Linked",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.btnColor, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: TextView(
                  text: "Message",
                  style: TextStyle(
                    color: AppColors.btnColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _buildTab(
            icon: Icons.image_outlined,
            label: 'Images',
            isSelected: _selectedTab == 0,
            onTap: () {
              setState(() {
                _selectedTab = 0;
                _pageController.jumpToPage(0);
              });
            },
          ),
          _buildTab(
            icon: Icons.videocam_outlined,
            label: 'Videos',
            isSelected: _selectedTab == 1,
            onTap: () {
              setState(() {
                _selectedTab = 1;
                _pageController.jumpToPage(1);
              });
            },
          ),
          _buildTab(
            icon: Icons.poll_outlined,
            label: 'Polls',
            isSelected: _selectedTab == 2,
            onTap: () {
              setState(() {
                _selectedTab = 2;
                _pageController.jumpToPage(2);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: isSelected
                ? Border(
                    bottom: BorderSide(color: AppColors.btnColor, width: 2),
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.btnColor : Colors.grey[600],
                size: 24,
              ),
              SizedBox(height: 4),
              TextView(
                text: label,
                style: TextStyle(
                  color: isSelected ? AppColors.btnColor : Colors.grey[600],
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostsGridSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedTab = index;
            });
          },
          children: [
            // Images Page (GridView)
            _buildImagesGrid(),
            // Videos Page (GridView)
            _buildVideosGrid(),
            // Polls Page
            _buildPollsContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return _buildGridItem(index);
      },
    );
  }

  Widget _buildVideosGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return _buildVideoGridItem(index);
      },
    );
  }

  Widget _buildGridItem(int index) {
    return GestureDetector(
      onTap: () {
        // Handle image tap
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[200],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ImageView(url: "assets/images/grids.png", fit: BoxFit.cover),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoGridItem(int index) {
    return GestureDetector(
      onTap: () {
        // Handle video tap
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[200],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ImageView(url: "assets/images/grids.png", fit: BoxFit.cover),
              // Video play overlay
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.play_arrow, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPollsContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.poll_outlined, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          TextView(
            text: 'No polls available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class MoreOptionsMenu extends StatelessWidget {
  final Function(int) onSelected;

  const MoreOptionsMenu({Key? key, required this.onSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: onSelected,
      itemBuilder: (context) => [
        _buildMenuItem(0, "Share", Colors.black),
        _buildMenuItem(1, "Report", Colors.black, showDivider: true),
        _buildMenuItem(2, "Block", Colors.red),
      ],
      icon: Icon(Icons.more_vert, color: Colors.white),
    );
  }

  PopupMenuItem<int> _buildMenuItem(
    int value,
    String text,
    Color textColor, {
    bool showDivider = false,
  }) {
    return PopupMenuItem<int>(
      value: value,
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showDivider)
            Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              height: 1,
              color: Colors.green,
            ),
        ],
      ),
    );
  }
}
