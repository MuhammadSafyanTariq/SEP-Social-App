import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sep/feature/presentation/Home/searchScreen.dart';
import 'package:sep/feature/presentation/chatScreens/chatScreen.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/auto_play_video_player.dart';

import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/feature/presentation/SportsProducts/sportsProduct.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';

import 'package:sep/utils/extensions/size.dart';

import '../../../../components/styles/appColors.dart';
import '../../../../components/styles/appIcons.dart';
import '../../../components/styles/appImages.dart';
import '../../data/repository/payment_repo.dart';
import '../Add post/typeSelectionScreen.dart';
import '../controller/agora_chat_ctrl.dart';
import '../controller/auth_Controller/networkCtrl.dart';
import '../controller/chat_ctrl.dart';
import '../game_screens/game_screen.dart';
import '../notifactionScreens/notificationScreen.dart';
import '../profileScreens/profileScreen.dart';
import '../profileScreens/setting/noInternetScreen.dart';
import '../profileScreens/setting/setting.dart';
import '../wallet/wallet_screen.dart';
import 'contentScreen.dart';
import 'CommonBannerAdWidget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProfileCtrl profileCtrl = Get.find<ProfileCtrl>();

  // int get msgCount => ChatCtrl.find.recentChat.fold<int>(0, (previousValue, element) => (element.unreadCount?[Preferences.uid] ?? 0) > 0 ? previousValue ++ : previousValue,);

  int get msgCount {
    int count = ChatCtrl.find.recentChat.fold<int>(
      0,
      (previousValue, element) =>
          (element.unreadCount?[Preferences.uid] ?? 0) > 0
          ? previousValue + 1
          : previousValue,
    );
    AppUtils.log('Unread message count: $count');
    return count;
  }

  int _currentIndex = 0;
  final PageController _pageController = PageController();
  late var profileimage = Preferences.profile;
  String? imageonly;

  // Ad timer variables
  Timer? _adTimer;
  bool _showAd = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      profileCtrl.getProfileDetails();
      ChatCtrl.find.connectSocket();
      final stripeId = profileCtrl.profileData.value.stripeCustomerId;
      if (stripeId == null || stripeId.isEmpty) {
        stripeCreateAccount();
      }

      // Start ad timer
      _startAdTimer();
    });
    _connect(() {
      AgoraChatCtrl.find.onLiveStreamChannelList();
      AgoraChatCtrl.find.getLiveStreamChannelList();
    });
  }

  void _startAdTimer() {
    // Show ad every 5 minutes
    _adTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      setState(() {
        _showAd = true;
      });

      // Hide ad after 30 seconds
      Future.delayed(Duration(seconds: 30), () {
        if (mounted) {
          setState(() {
            _showAd = false;
          });
        }
      });
    });

    // Show ad immediately on first load
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showAd = true;
        });

        // Hide after 30 seconds
        Future.delayed(Duration(seconds: 30), () {
          if (mounted) {
            setState(() {
              _showAd = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  bool connectionCallBack = false;

  void _connect(Function() call) {
    connectionCallBack = false;
    AgoraChatCtrl.find.connect(() {
      if (connectionCallBack) return;
      connectionCallBack = true;
      call();
    });
  }

  void stripeCreateAccount() {
    PaymentRepo.createAccountStripe(
      email: profileCtrl.profileData.value.email ?? "",
    );
  }

  List<Widget> get _screens {
    return [
      Contentscreen(
        getLiveStreamList: () {
          _connect(() {
            AgoraChatCtrl.find.getLiveStreamChannelList();
          });
        },
      ),
      SportsProduct(), // Shop screen
      Container(), // Placeholder for add screen (not used since we navigate to TypeSelectionScreen)
      GameScreen(),
      ProfileScreen(),
    ];
  }

  void _navigateToScreen(int index) {
    if (index == 2) {
      // Add button is now at index 2 - Navigate to type selection screen
      // Pause all videos when navigating away
      try {
        VideoControllerManager.find.pauseAll();
      } catch (e) {
        AppUtils.log('Error pausing videos: $e');
      }
      context.pushNavigator(TypeSelectionScreen());
    } else {
      // Pause videos when leaving home screen (index 0)
      if (_currentIndex == 0 && index != 0) {
        try {
          VideoControllerManager.find.pauseAll();
        } catch (e) {
          AppUtils.log('Error pausing videos: $e');
        }
      }

      setState(() {
        _currentIndex = index;
      });
      _pageController.jumpToPage(index);
    }
  }

  int totalUnread = 1;

  @override
  Widget build(BuildContext context) {
    final networkController = Get.find<NetworkController>();
    return Obx(() {
      if (!networkController.isConnected.value) {
        Future.delayed(Duration.zero, () {
          Get.to(() => NoInternetScreen());
        });
      }
      return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          excludeHeaderSemantics: false,
          elevation: 0,
          backgroundColor: Colors.white,
          leading: null,
          title: _currentIndex == 0
              ? Row(
                  children: [
                    Text(
                      "SEP Media",
                      style: TextStyle(
                        fontFamily: GoogleFonts.oregano().fontFamily,
                        fontSize: 28,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                )
              : _currentIndex == 1
              ? const Text(
                  "SEP Marketplace",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                )
              : _currentIndex == 2
              ? const Text(
                  "Post",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                )
              : _currentIndex == 3
              ? const Text(
                  "Games",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                )
              : const Text(
                  "My Profile",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
          actions: [
            if (_currentIndex == 4)
              Padding(
                padding: 10.right + 10.left,
                child: InkWell(
                  onTap: () {
                    context.pushNavigator(WalletScreen());
                  },
                  child: Image.asset(
                    color: AppColors.primaryColor,
                    AppImages.walletImg,
                    height: 24.sdp,
                    width: 24.sdp,
                  ),
                ),
              ),

            if (_currentIndex == 0) ...[
              Obx(() {
                final unreadCount = msgCount;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Navigate to messages screen
                        context.pushNavigator(ChatScreen());
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: Icon(
                              Icons.mail_outline_rounded,
                              size: 24,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: -4,
                              top: -4,
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Center(
                                  child: Text(
                                    unreadCount > 99
                                        ? '99+'
                                        : unreadCount.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      context.pushNavigator(Search());
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: Icon(
                        Icons.search_rounded,
                        size: 24,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      context.pushNavigator(Notificationscreen());
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        size: 24,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
            ],
            if (_currentIndex == 4)
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: AppColors.primaryColor,
                  size: 30.sdp,
                ),
                onPressed: () {
                  context.pushNavigator(Setting());
                },
              ),

            // Padding(
            //   padding: 20.right + 5.left,
            //   child: InkWell(
            //     onTap: () {
            //       context.pushNavigator(Notificationscreen());
            //     },
            //     child: Image.asset(
            //       color: AppColors.primaryColor,
            //       AppIcons.homenotification,
            //       height: 24.sdp,
            //       width: 24.sdp,
            //     ),
            //   ),
            // ),
          ],
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Banner Ad above navigation bar
            if (_showAd)
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: CommonBannerAdWidget(
                        adUnitId: Platform.isAndroid
                            ? 'ca-app-pub-3940256099942544/6300978111'
                            : 'ca-app-pub-3940256099942544/2934735716',
                      ),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showAd = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Bottom Navigation Bar
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 85,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    currentIndex: _currentIndex,
                    selectedItemColor: AppColors.btnColor,
                    unselectedItemColor: Colors.grey.shade400,
                    selectedLabelStyle: TextStyle(
                      color: AppColors.btnColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    unselectedLabelStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                    onTap: (index) {
                      _navigateToScreen(index);
                    },
                    items: [
                      // Home
                      BottomNavigationBarItem(
                        icon: Container(
                          padding: EdgeInsets.all(8),
                          child: SvgPicture.asset(
                            AppIcons.homeSvg,
                            height: 22,
                            width: 22,
                            color: _currentIndex == 0
                                ? AppColors.btnColor
                                : Colors.grey.shade400,
                          ),
                        ),
                        label: 'Home',
                      ),
                      // Shop
                      BottomNavigationBarItem(
                        icon: Container(
                          padding: EdgeInsets.all(8),
                          child: SvgPicture.asset(
                            AppIcons.shopSvg,
                            height: 22,
                            width: 22,
                            color: _currentIndex == 1
                                ? AppColors.btnColor
                                : Colors.grey.shade400,
                          ),
                        ),
                        label: 'Shop',
                      ),
                      // Add (Placeholder - actual button is floating above)
                      BottomNavigationBarItem(
                        icon: SizedBox(height: 22, width: 22),
                        label: '',
                      ),
                      // Games
                      BottomNavigationBarItem(
                        icon: Container(
                          padding: EdgeInsets.all(8),
                          child: SvgPicture.asset(
                            AppIcons.gameSvg,
                            height: 22,
                            width: 22,
                            color: _currentIndex == 3
                                ? AppColors.btnColor
                                : Colors.grey.shade400,
                          ),
                        ),
                        label: 'Games',
                      ),
                      // Profile
                      BottomNavigationBarItem(
                        icon: Container(
                          padding: EdgeInsets.all(8),
                          child: SvgPicture.asset(
                            AppIcons.profileSvg,
                            height: 22,
                            width: 22,
                            color: _currentIndex == 4
                                ? AppColors.btnColor
                                : Colors.grey.shade400,
                          ),
                        ),
                        label: 'Profile',
                      ),
                    ],
                  ),
                ),
                // Floating Add Button
                Positioned(
                  left: MediaQuery.of(context).size.width / 2 - 40,
                  bottom: 30,
                  child: GestureDetector(
                    onTap: () {
                      _navigateToScreen(2);
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.btnColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Icon(Icons.add, size: 32, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _screens,
        ),
      );
    });
  }
}
