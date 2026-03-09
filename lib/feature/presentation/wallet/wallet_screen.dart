import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';
import 'package:sep/components/appLoader.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/services/networking/urls.dart';
import '../../data/models/dataModels/profile_data/profile_data_model.dart';
import '../controller/auth_Controller/get_stripe_ctrl.dart';
import 'packages_screen.dart';
import 'paypal_topup_screen.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/styles/appImages.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with WidgetsBindingObserver {
  final GetStripeCtrl stripeCtrl = Get.put(GetStripeCtrl());
  final ProfileCtrl profileCtrl = Get.find<ProfileCtrl>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    stripeCtrl.getTransactionList();
    // Refresh profile data to get latest coin balance
    profileCtrl.getProfileDetails();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app becomes active (user returns from another screen)
      profileCtrl.getProfileDetails();
      stripeCtrl.getTransactionList();
    }
  }

  void _refreshData() {
    profileCtrl.getProfileDetails();
    stripeCtrl.getTransactionList();
  }

  /// Replaces "token"/"tokens" with "coin"/"coins" for display (app uses "coins").
  static String _descriptionToCoins(String description) {
    if (description.isEmpty) return description;
    return description
        .replaceAll(RegExp(r'\btokens\b', caseSensitive: false), 'coins')
        .replaceAll(RegExp(r'\btoken\b', caseSensitive: false), 'coin');
  }

  /// Formats backend createdAt (ISO 8601) for display, e.g. "Mar 3, 2026".
  static String _formatTransactionDate(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return '—';
    try {
      final date = DateTime.parse(createdAt);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (_) {
      return createdAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Obx(() {
        final transactions = stripeCtrl.transactionList;
        final profileData = ProfileCtrl.find.profileData.value;
        // Coins (backend: walletTokens) used for gifts & games.
        final coinBalance =
            profileData.walletTokens ?? profileData.tokenBalance ?? 0;

        return Column(
          children: [
            AppBar2(
              title: 'Wallet',
              titleStyle: 20.txtBoldBlack,
              prefixImage: 'back',
              onPrefixTap: () => context.pop(),
              backgroundColor: Colors.white,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _refreshData();
                },
                child: ListView(
                  padding: EdgeInsets.all(20.sdp),
                  children: [
                    // Coins card only (USD balance removed)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.sdp),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.sdp),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextView(
                            text: 'COINS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.greenlight,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 4.sdp),
                          TextView(
                            text: 'Used for gifts & games',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8.sdp),
                          Row(
                            children: [
                              ImageView(
                                url: AppImages.token,
                                size: 28.sdp,
                              ),
                              SizedBox(width: 8.sdp),
                              TextView(
                                text: coinBalance.toString(),
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.sdp),
                          AppButton(
                            radius: 20.sdp,
                            buttonColor: AppColors.primaryColor,
                            label: "Add Coins",
                            labelStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            isFilledButton: true,
                            onTap: () async {
                              final userId = Preferences.uid ?? "";
                              if (userId.isEmpty) {
                                AppUtils.toastError("User ID not found");
                                return;
                              }
                              await context.pushNavigator(
                                PayPalTopUpScreen(
                                  userId: userId,
                                  onBalanceUpdated: (_) {
                                    _refreshData();
                                  },
                                ),
                              );
                              _refreshData();
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32.sdp),

                    // Transaction History Section
                    TextView(
                      text: 'Transaction History',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: 16.sdp),

                    if (stripeCtrl.isTransactionLoading.value)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.sdp),
                          child: AppLoader.loaderWidget(),
                        ),
                      )
                    else if (transactions.isEmpty)
                      Container(
                        padding: EdgeInsets.all(40.sdp),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.sdp),
                        ),
                        child: TextView(
                          text: 'No transactions available.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      ...transactions.map(
                        (transaction) => TransactionTile(
                          name: _descriptionToCoins(
                              transaction.description ?? 'Transaction'),
                          date: _formatTransactionDate(transaction.createdAt),
                          amount:
                              (transaction.amount ?? 0) *
                              (transaction.type == "credit" ? 1 : -1),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class Transaction {
  final String name;
  final String date;
  final double amount;

  Transaction({required this.name, required this.date, required this.amount});
}

class TransactionTile extends StatelessWidget {
  final String name;
  final String date;
  final double amount;

  const TransactionTile({
    super.key,
    required this.name,
    required this.date,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = amount >= 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12.sdp),
      padding: EdgeInsets.all(16.sdp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.sdp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Obx(() {
            final profileImage = ProfileCtrl.find.profileData.value.image;
            print("TransactionTile - Profile Image: $profileImage");

            // Build full image URL
            String? imageUrl;
            if (profileImage != null && profileImage.isNotEmpty) {
              if (profileImage.startsWith('http')) {
                imageUrl = profileImage;
              } else {
                // Relative path - prepend base URL
                imageUrl = '${Urls.appApiBaseUrl}$profileImage';
              }
              print("TransactionTile - Full Image URL: $imageUrl");
            }

            return CircleAvatar(
              radius: 24.sdp,
              backgroundColor: Colors.grey[200],
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
              child: imageUrl == null
                  ? Icon(Icons.person, size: 28.sdp, color: Colors.grey[400])
                  : null,
            );
          }),
          SizedBox(width: 12.sdp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextView(
                  text: name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.sdp),
                TextView(
                  text: date,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          TextView(
            text:
                '${isPositive ? '+' : '-'}\$${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isPositive ? AppColors.greenlight : Colors.red[600],
            ),
          ),
        ],
      ),
    );
  }
}
