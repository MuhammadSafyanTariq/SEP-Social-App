import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';

class GiftHistoryScreen extends StatefulWidget {
  const GiftHistoryScreen({Key? key}) : super(key: key);

  @override
  State<GiftHistoryScreen> createState() => _GiftHistoryScreenState();
}

class _GiftHistoryScreenState extends State<GiftHistoryScreen> {
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
          text: 'Gift History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.blackText,
          ),
        ),
      ),
      body: Obx(
        () {
          if (profileCtrl.isGiftHistoryLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final gifts = profileCtrl.giftHistory;
          if (gifts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
              ),
            );
          }

          final totalAmount = gifts.fold<double>(
            0.0,
            (sum, g) =>
                sum +
                (double.tryParse((g['amount'] ?? 0).toString()) ?? 0.0),
          );

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: gifts.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index == 0) {
                // Summary card
                return Container(
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
                );
              }

              final g = gifts[index - 1];
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextView(
                                text: giftName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.blackText,
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
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isCashedOut
                            ? AppColors.greenlight.withOpacity(0.1)
                            : AppColors.grey.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: TextView(
                        text: isCashedOut ? 'Cashed out' : 'Pending',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isCashedOut
                              ? AppColors.greenlight
                              : AppColors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

