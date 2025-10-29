import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:sep/components/appLoader.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/size.dart';
import '../controller/auth_Controller/get_stripe_ctrl.dart';
import 'add_card_screen.dart';
import 'packages_screen.dart';

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
    // Refresh profile data to get latest token balance
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Obx(() {
        final transactions = stripeCtrl.transactionList;
        final balance = ProfileCtrl.find.profileData.value.walletBalance ?? '0';
        final profileData = ProfileCtrl.find.profileData.value;
        final tokenBalance =
            profileData.walletTokens ?? profileData.tokenBalance ?? 0;

        // Debug logging to track balance updates
        print(
          "Wallet Screen - tokenBalance: ${profileData.tokenBalance}, walletTokens: ${profileData.walletTokens}",
        );
        print("Wallet Screen - Using token balance: $tokenBalance");

        return Column(
          children: [
            // Custom AppBar2
            AppBar2(
              title: 'Wallet',
              titleStyle: 20.txtBoldBlack,
              prefixImage: 'back',
              onPrefixTap: () => context.pop(),
              backgroundColor: Colors.white,
            ),
            // Main content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _refreshData();
                },
                child: ListView(
                  padding: EdgeInsets.all(20.sdp),
                  children: [
                    // Balance and Token Cards
                    Row(
                      children: [
                        // Balance Card (Left Half)
                        Expanded(
                          child: Container(
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
                                  text: 'BALANCE',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.greenlight,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(height: 8.sdp),
                                TextView(
                                  text: '\$${balance}',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 16.sdp),
                                AppButton(
                                  radius: 20.sdp,
                                  buttonColor: AppColors.greenlight,
                                  label: "Add Balance",
                                  labelStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                  isFilledButton: true,
                                  onTap: () {
                                    context.pushNavigator(
                                      AddCreditCardScreen(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(width: 16.sdp),

                        // Token Card (Right Half)
                        Expanded(
                          child: Container(
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
                                  text: 'TOKENS',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.greenlight,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(height: 8.sdp),
                                Row(
                                  children: [
                                    ImageView(
                                      url: AppImages.token,
                                      size: 30.sdp,
                                    ),
                                    SizedBox(width: 6.sdp),
                                    TextView(
                                      text: tokenBalance.toString(),
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.sdp),
                                AppButton(
                                  radius: 20.sdp,
                                  buttonColor: AppColors.greenlight,
                                  label: "Add Token",
                                  labelStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                  isFilledButton: true,
                                  onTap: () {
                                    context.pushNavigator(PackagesScreen());
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
                          name: transaction.description ?? 'Transaction',
                          date:
                              'Sep 25', // Static date for now since transaction.createdAt is String
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
          CircleAvatar(
            radius: 24.sdp,
            backgroundImage: const AssetImage(AppImages.dummyProfile),
          ),
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
