import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/feature/data/models/dataModels/profile_data/profile_data_model.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';

/// Dashboard screen: earnings/monetization card + gift history list.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ProfileCtrl profileCtrl = ProfileCtrl.find;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileCtrl.loadReceivedGifts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.newgrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0.5,
        title: const TextView(
          text: 'My Dashboard',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.blackText,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await profileCtrl.getProfileDetails();
          await profileCtrl.loadReceivedGifts();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildEarningsSection(),
              const SizedBox(height: 24),
              _buildGiftHistorySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsSection() {
    return Obx(() {
      final profileData = profileCtrl.profileData.value;
      final isMonetized = profileCtrl.isMonetized;
      final isLoading = profileCtrl.isMonetizationLoading.value;
      final withdrawal = profileData.withdrawalBalanceUsd;
      final giftsBalance = profileData.giftsBalanceUsd;
      final totalEarnings = profileCtrl.totalEarningsUsd.value;
      final totalWithdraw = profileCtrl.totalWithdrawUsd.value;

      if (!isMonetized) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: AppButton(
              label: isLoading ? 'Applying...' : 'Apply for Monetization',
              buttonColor: AppColors.btnColor,
              onTap: isLoading
                  ? null
                  : () {
                      profileCtrl.applyForMonetization();
                    },
            ),
          ),
        );
      }

      final canCashout = giftsBalance >= 50;
      final canPayout = withdrawal >= 50;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.verified, color: AppColors.greenlight, size: 18),
                const SizedBox(width: 6),
                TextView(
                  text: 'Earnings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Current balances
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextView(
                      text: 'Gifts balance',
                      style: TextStyle(fontSize: 12, color: AppColors.grey),
                    ),
                    const SizedBox(height: 2),
                    TextView(
                      text: '\$${giftsBalance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blackText,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextView(
                      text: 'Withdrawable',
                      style: TextStyle(fontSize: 12, color: AppColors.grey),
                    ),
                    const SizedBox(height: 2),
                    TextView(
                      text: '\$${withdrawal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blackText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Lifetime stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextView(
                      text: 'Total earnings',
                      style: TextStyle(fontSize: 12, color: AppColors.grey),
                    ),
                    const SizedBox(height: 2),
                    TextView(
                      text: '\$${totalEarnings.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.blackText,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextView(
                      text: 'Total withdrawn',
                      style: TextStyle(fontSize: 12, color: AppColors.grey),
                    ),
                    const SizedBox(height: 2),
                    TextView(
                      text: '\$${totalWithdraw.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.blackText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (canCashout)
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: profileCtrl.isCashoutLoading.value
                      ? 'Cashout...'
                      : 'Cashout gifts',
                  buttonColor: AppColors.btnColor,
                  onTap: profileCtrl.isCashoutLoading.value
                      ? null
                      : () {
                          profileCtrl.cashoutGifts();
                        },
                ),
              )
            else
              TextView(
                text:
                    'You can cash out once you have at least \$50 in gifts balance.',
                style: TextStyle(fontSize: 12, color: AppColors.grey),
              ),
            const SizedBox(height: 8),
            // PayPal payout button (from withdrawalBalance)
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: profileCtrl.isPayoutLoading.value
                    ? 'Requesting payout...'
                    : 'Request PayPal payout',
                buttonColor: Colors.black,
                onTap: (!canPayout || profileCtrl.isPayoutLoading.value)
                    ? null
                    : () => _openPayoutBottomSheet(context, withdrawal),
              ),
            ),
            if (!canPayout)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: TextView(
                  text:
                      'You can request payout once withdrawable balance reaches \$50.',
                  style: TextStyle(fontSize: 11, color: AppColors.grey),
                ),
              ),
          ],
        ),
      );
    });
  }

  void _openPayoutBottomSheet(BuildContext context, double maxAmount) {
    final amountCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const TextView(
                    text: 'Request PayPal payout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackText,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextView(
                text:
                    'Available withdrawable balance: \$${maxAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount in USD',
                  hintText: 'Minimum \$50, up to your withdrawable balance',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'PayPal email (optional)',
                  hintText: 'Leave empty to use account email',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: 'Submit payout request',
                  buttonColor: AppColors.btnColor,
                  onTap: () async {
                    final raw = amountCtrl.text.trim();
                    final amount = double.tryParse(raw) ?? 0;
                    Navigator.pop(ctx);
                    await profileCtrl.requestPaypalPayout(
                      amount: amount,
                      paypalEmail: emailCtrl.text.trim(),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGiftHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: TextView(
            text: 'Gift History',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.blackText,
            ),
          ),
        ),
        Obx(() {
          if (profileCtrl.isGiftHistoryLoading.value) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final gifts = profileCtrl.giftHistory;
          if (gifts.isEmpty) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: const [
                  Icon(
                    Icons.card_giftcard_outlined,
                    size: 40,
                    color: AppColors.grey,
                  ),
                  SizedBox(height: 12),
                  TextView(
                    text: 'No gifts received yet',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final totalAmount = gifts.fold<double>(
            0.0,
            (sum, g) =>
                sum +
                (double.tryParse((g['amount'] ?? 0).toString()) ?? 0.0),
          );

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TextView(
                          text: 'Total gifts received',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextView(
                          text: '\$${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackText,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.btnColor.withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.card_giftcard_outlined,
                        color: AppColors.btnColor,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: gifts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final g = gifts[index];
                  final sender = g['senderId'] as Map<String, dynamic>? ?? {};
                  final senderName = sender['name'] as String? ?? 'Unknown';
                  final giftName = g['giftName']?.toString() ?? 'Gift';
                  final amountValue =
                      double.tryParse((g['amount'] ?? 0).toString()) ?? 0.0;
                  final amountText = '\$${amountValue.toStringAsFixed(2)}';
                  final status = g['status']?.toString() ?? 'pending';
                  final createdAt = g['createdAt']?.toString() ?? '';

                  String timeText = '';
                  if (createdAt.isNotEmpty) {
                    try {
                      final dt = DateTime.parse(createdAt);
                      timeText =
                          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
                    } catch (_) {}
                  }

                  final isCashedOut = status == 'cashedOut';

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.btnColor,
                                AppColors.btnColor.withOpacity(0.8),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: const Icon(
                            Icons.card_giftcard,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: TextView(
                                      text: giftName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.blackText,
                                      ),
                                    ),
                                  ),
                                  TextView(
                                    text: amountText,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.blackText,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              TextView(
                                text: 'From: $senderName',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey,
                                ),
                              ),
                              if (timeText.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                TextView(
                                  text: timeText,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.greyHint,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        }),
      ],
    );
  }
}
