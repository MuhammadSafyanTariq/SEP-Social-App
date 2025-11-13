import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/components/styles/app_strings.dart';
import 'package:sep/feature/presentation/game_screens/gun_firing_game/gun_firing_Screen.dart';
import 'package:sep/feature/presentation/game_screens/fruit_ninja_game/fruit_ninja_screen.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/widget.dart';
import 'package:sep/services/networking/apiMethods.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import 'flappy_game/FlameGameScreen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final IApiMethod _apiMethod = IApiMethod();

  // Referral data variables
  bool _isParticipating = false;
  Map<String, dynamic>? _referralData;
  bool _hasReferralCode = false;
  bool _hasCheckedReferralStatus = false;
  List<Map<String, dynamic>> _winnersData = [];
  bool _isLoadingWinners = false;
  String _selectedMonth = '';
  String _selectedYear = '';

  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _initializeWinnersData();
    _checkUserReferralStatus();
  }

  void _onTabChanged() {
    // When user switches to referral tab (index 1), check referral status
    if (_tabController.index == 1 && !_hasCheckedReferralStatus) {
      _checkUserReferralStatus();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _participateInReferral() async {
    if (_isParticipating) return;

    setState(() {
      _isParticipating = true;
    });

    try {
      String? authToken = Preferences.authToken;

      if (authToken == null) {
        _showErrorSnackbar('Authentication required. Please log in.');
        return;
      }

      final response = await _apiMethod.post(
        url: Urls.referralParticipate,
        authToken: authToken,
        body: {},
        headers: {},
      );

      if (response.isSuccess) {
        setState(() {
          _referralData = response.data;
          _hasReferralCode = true; // User now has a referral code
        });
        _showSuccessSnackbar('Successfully joined the referral program!');
        AppUtils.log('Referral participation successful: ${response.data}');
      } else {
        _showErrorSnackbar(
          'Failed to join referral program. Please try again.',
        );
        AppUtils.log('Referral participation failed: ${response.error}');
      }
    } catch (e) {
      _showErrorSnackbar('An error occurred. Please try again.');
      AppUtils.log('Referral participation error: $e');
    } finally {
      setState(() {
        _isParticipating = false;
      });
    }
  }

  Future<void> _checkUserReferralStatus() async {
    try {
      String? authToken = Preferences.authToken;

      if (authToken == null) {
        AppUtils.log('Auth token not available for referral status check');
        return;
      }

      final response = await _apiMethod.get(
        url: Urls.getUserDetails,
        authToken: authToken,
      );

      if (response.isSuccess && response.data != null) {
        // Try different possible data structures
        Map<String, dynamic> userData;

        if (response.data!['user'] != null) {
          userData = response.data!['user'];
        } else if (response.data!['data'] != null &&
            response.data!['data']['user'] != null) {
          userData = response.data!['data']['user'];
        } else if (response.data!['data'] != null) {
          userData = response.data!['data'];
        } else {
          userData = response.data!;
        }

        final referralCode = userData['referralCode'];
        final hasReferralCode =
            referralCode != null && referralCode.toString().isNotEmpty;

        setState(() {
          _hasReferralCode = hasReferralCode;
          _hasCheckedReferralStatus = true;

          if (hasReferralCode) {
            // If user already has referral code, populate _referralData
            _referralData = {'data': userData};
          } else {
            // Clear referral data if no code
            _referralData = null;
          }
        });

        AppUtils.log(
          'User referral status: hasReferralCode = $_hasReferralCode, referralCode = $referralCode',
        );
        AppUtils.log('Full user data structure: $userData');
      } else {
        AppUtils.log('Failed to get user referral status: ${response.error}');
        AppUtils.log('Response data: ${response.data}');
      }
    } catch (e) {
      AppUtils.log('Error checking user referral status: $e');
    }
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  String _getFullImageUrl(String url) {
    if (url.startsWith('http')) return url;
    return '${Urls.appApiBaseUrl}$url';
  }

  void _shareReferralCode() async {
    if (_referralData == null) return;

    final referralCode = _referralData!['data']?['referralCode'] ?? '';

    final shareMessage =
        '''
SEE What I found? SEP a multipurpose social media. Download it now and earn free rewards and full of entertainment. 

Play Store Link: https://play.google.com/store/apps/details?id=com.app.sep
App Store Link: https://apps.apple.com/app/sep/id123456789

Sign up the app using refer code: $referralCode
''';

    try {
      // Load the SEP logo from assets
      final ByteData logoData = await rootBundle.load(AppImages.splashLogo);
      final Uint8List logoBytes = logoData.buffer.asUint8List();

      // Get temporary directory to save the logo
      final Directory tempDir = await getTemporaryDirectory();
      final File logoFile = File('${tempDir.path}/sep_logo.png');
      await logoFile.writeAsBytes(logoBytes);

      // Share with text and logo
      await Share.shareXFiles(
        [XFile(logoFile.path)],
        text: shareMessage,
        subject: 'Join SEP - Social Media App',
      );
    } catch (e) {
      AppUtils.log('Error sharing referral code with image: $e');

      // Fallback to text-only sharing
      try {
        await Share.share(shareMessage, subject: 'Join SEP - Social Media App');
      } catch (fallbackError) {
        AppUtils.log('Error sharing referral code: $fallbackError');
        _showErrorSnackbar('Failed to share referral code');
      }
    }
  }

  void _initializeWinnersData() {
    DateTime now = DateTime.now();
    DateTime previousMonth = DateTime(now.year, now.month - 1);

    _selectedMonth = _months[previousMonth.month - 1];
    _selectedYear = previousMonth.year.toString();

    _fetchWinners();
  }

  Future<void> _fetchWinners() async {
    if (_selectedMonth.isEmpty || _selectedYear.isEmpty) return;

    setState(() {
      _isLoadingWinners = true;
    });

    try {
      String? authToken = Preferences.authToken;

      if (authToken == null) {
        AppUtils.log('Auth token not available for winners');
        return;
      }

      final response = await _apiMethod.get(
        url:
            '${Urls.referralWinners}?month=$_selectedMonth&year=$_selectedYear',
        authToken: authToken,
      );

      if (response.isSuccess && response.data != null) {
        final List<dynamic> winnersList = response.data!['data'] ?? [];
        setState(() {
          _winnersData = List<Map<String, dynamic>>.from(winnersList);
        });
        AppUtils.log(
          'Winners fetched successfully: ${_winnersData.length} winners',
        );
      } else {
        AppUtils.log('Failed to fetch winners: ${response.error}');
        setState(() {
          _winnersData = [];
        });
      }
    } catch (e) {
      AppUtils.log('Error fetching winners: $e');
      setState(() {
        _winnersData = [];
      });
    } finally {
      setState(() {
        _isLoadingWinners = false;
      });
    }
  }

  void _showMonthYearPicker() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String tempMonth = _selectedMonth;
        String tempYear = _selectedYear;

        return AlertDialog(
          title: TextView(
            text: AppStrings.selectWinnerMonth.tr,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: tempMonth.isNotEmpty ? tempMonth : null,
                    decoration: InputDecoration(
                      labelText: AppStrings.selectWinnerMonth.tr,
                      border: OutlineInputBorder(),
                    ),
                    items: _months.map((String month) {
                      return DropdownMenuItem<String>(
                        value: month,
                        child: Text(month),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        tempMonth = newValue ?? '';
                      });
                    },
                  ),
                  SizedBox(height: 16.sdp),
                  DropdownButtonFormField<String>(
                    value: tempYear.isNotEmpty ? tempYear : null,
                    decoration: InputDecoration(
                      labelText: AppStrings.selectWinnerYear.tr,
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(5, (index) {
                      int year = DateTime.now().year - index;
                      return DropdownMenuItem<String>(
                        value: year.toString(),
                        child: Text(year.toString()),
                      );
                    }),
                    onChanged: (String? newValue) {
                      setState(() {
                        tempYear = newValue ?? '';
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (tempMonth.isNotEmpty && tempYear.isNotEmpty) {
                  setState(() {
                    _selectedMonth = tempMonth;
                    _selectedYear = tempYear;
                  });
                  _fetchWinners();
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Tab Bar
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 20.sdp,
                vertical: 10.sdp,
              ),
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25.sdp),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.sdp),
                  color: AppColors.primaryColor,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.primaryColor,
                labelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(text: AppStrings.games.tr),
                  Tab(text: AppStrings.referFriend.tr),
                ],
              ),
            ),

            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildGamesTab(), _buildReferFriendTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamesTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.sdp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          10.height,

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
                subtitle: '',
                imagePath: AppImages.flappyBird,
                backgroundColor: AppColors.white,
                onTap: () {
                  context.pushNavigator(FlameGameScreen());
                },
              ),
              _buildEnhancedGameCard(
                context,
                title: AppStrings.shootingRush.tr,
                subtitle: '',
                imagePath: AppImages.shootinggameImag,
                backgroundColor: AppColors.white,
                onTap: () {
                  context.pushNavigator(GunFiringScreen());
                },
              ),
              _buildEnhancedGameCard(
                context,
                title: 'Fruit Ninja',
                subtitle: '',
                imagePath: AppImages.fruitNinja,
                backgroundColor: AppColors.white,
                onTap: () {
                  context.pushNavigator(FruitNinjaScreen());
                },
              ),
            ],
          ),

          20.height,
        ],
      ),
    );
  }

  Widget _buildReferFriendTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.sdp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          30.height,

          // Referral Program Header
          TextView(
            text: AppStrings.referFriend.tr,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          12.height,

          TextView(
            text: AppStrings.referralDescription.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.grey,
            ),
          ),
          30.height,

          // Referral Data Display (Simplified) - only show if user has referral code
          if (_hasReferralCode && _referralData != null) ...[
            Container(
              padding: EdgeInsets.all(20.sdp),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.sdp),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextView(
                    text: AppStrings.referralProgramDetails.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  16.height,
                  _buildReferralDataRow(
                    'Name',
                    _referralData!['data']?['name'] ?? 'N/A',
                  ),
                  _buildReferralDataRow(
                    'Email',
                    _referralData!['data']?['email'] ?? 'N/A',
                  ),
                  _buildReferralDataRow(
                    'Referral Code',
                    _referralData!['data']?['referralCode'] ?? 'N/A',
                  ),
                  _buildReferralDataRow(
                    'Invites This Month',
                    _referralData!['data']?['referralInvitesThisMonth']
                            ?.toString() ??
                        '0',
                  ),
                  _buildReferralDataRow(
                    'Total Invites',
                    _referralData!['data']?['referralInvitesAllTime']
                            ?.toString() ??
                        '0',
                  ),
                ],
              ),
            ),
            30.height,
          ],

          // Action Button - only show if user doesn't have referral code
          if (!_hasReferralCode) ...[
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isParticipating ? null : _participateInReferral,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16.sdp),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.sdp),
                  ),
                  elevation: 2,
                ),
                child: _isParticipating
                    ? SizedBox(
                        height: 20.sdp,
                        width: 20.sdp,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : TextView(
                        text: AppStrings.participateReferral.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            30.height,
          ],

          // Share Button - only show if user has referral code
          if (_hasReferralCode && _referralData != null) ...[
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _shareReferralCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greenlight,
                  padding: EdgeInsets.symmetric(vertical: 16.sdp),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.sdp),
                  ),
                  elevation: 2,
                ),
                child: TextView(
                  text: AppStrings.shareCode.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            30.height,
          ],

          40.height,

          // Leaderboard Section - COMMENTED OUT
          /*
          _buildLeaderboard(),
          
          40.height,
          */

          // Winners Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextView(
                text: AppStrings.monthlyWinners.tr,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showMonthYearPicker,
                icon: Icon(Icons.calendar_month, size: 16),
                label: TextView(
                  text: '$_selectedMonth $_selectedYear',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.sdp,
                    vertical: 8.sdp,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.sdp),
                  ),
                ),
              ),
            ],
          ),
          12.height,

          TextView(
            text: AppStrings.previousMonthWinners.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.grey,
            ),
          ),
          20.height,

          // Winners List
          _buildWinners(),

          20.height,
        ],
      ),
    );
  }

  Widget _buildWinners() {
    if (_isLoadingWinners) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.sdp),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
        ),
      );
    }

    if (_winnersData.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20.sdp),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.sdp),
        ),
        child: Center(
          child: TextView(
            text: AppStrings.noWinnersData.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.grey,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.sdp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _winnersData.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (context, index) {
          final winner = _winnersData[index];
          final rank = index + 1;

          return _buildWinnerItem(winner, rank);
        },
      ),
    );
  }

  Widget _buildWinnerItem(Map<String, dynamic> winner, int rank) {
    final name = winner['name'] ?? 'Unknown Winner';
    final profileImage = winner['profileImage'] ?? '';
    final invitesCount = winner['referralInvitesThisMonth'] ?? 0;

    // Define rewards for top 5 winners (same as leaderboard)
    String? rewardText;
    Color rewardColor = Color(
      0xFF2E7D32,
    ); // Consistent green color for all rewards
    Widget? rewardIcon;

    switch (rank) {
      case 1:
        rewardText = '\$50';
        rewardIcon = Icon(Icons.attach_money, color: rewardColor, size: 16);
        break;
      case 2:
        rewardText = '160';
        rewardIcon = Image.asset(AppImages.token, width: 16, height: 16);
        break;
      case 3:
        rewardText = '120';
        rewardIcon = Image.asset(AppImages.token, width: 16, height: 16);
        break;
      case 4:
        rewardText = '80';
        rewardIcon = Image.asset(AppImages.token, width: 16, height: 16);
        break;
      case 5:
        rewardText = '40';
        rewardIcon = Image.asset(AppImages.token, width: 16, height: 16);
        break;
      default:
        rewardText = null;
        rewardIcon = null;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.sdp, vertical: 12.sdp),
      child: Row(
        children: [
          // Winner Badge - Light Grey for all positions
          Container(
            width: 32.sdp,
            height: 32.sdp,
            decoration: BoxDecoration(
              color: Colors.grey.shade300, // Light grey for all positions
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.star,
                size: 16.sdp,
                color: Colors.grey.shade600,
              ),
            ),
          ),

          12.width,

          // Profile Image
          CircleAvatar(
            radius: 22.sdp,
            backgroundColor: AppColors.grey.withOpacity(0.3),
            backgroundImage: profileImage.isNotEmpty
                ? NetworkImage(_getFullImageUrl(profileImage))
                : null,
            child: profileImage.isEmpty
                ? Icon(Icons.person, size: 24.sdp, color: AppColors.grey)
                : null,
          ),

          12.width,

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TextView(
                      text: name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxlines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    8.width,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.sdp,
                        vertical: 2.sdp,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10.sdp),
                      ),
                      child: TextView(
                        text: AppStrings.winner.tr,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                4.height,
                TextView(
                  text: '$invitesCount ${AppStrings.invitesCount.tr}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Reward for top 5 winners
          if (rewardText != null && rewardIcon != null) ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12.sdp,
                vertical: 8.sdp,
              ),
              decoration: BoxDecoration(
                color: rewardColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.sdp),
                border: Border.all(
                  color: rewardColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  rewardIcon,
                  6.width,
                  TextView(
                    text: rewardText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: rewardColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReferralDataRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.sdp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: TextView(
              text: '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: TextView(
              text: value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade900,
              ),
            ),
          ),
        ],
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
                  color: AppColors.primaryColor,
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
