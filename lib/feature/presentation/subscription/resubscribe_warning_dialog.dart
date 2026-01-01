import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/feature/presentation/subscription/subscription_required_screen.dart';
import 'package:sep/services/subscription/subscription_service.dart';
import 'package:sep/utils/appUtils.dart';

/// Dialog to warn users about expired subscription during grace period
class ResubscribeWarningDialog extends StatelessWidget {
  final int daysRemaining;
  final VoidCallback? onResubscribed;

  const ResubscribeWarningDialog({
    Key? key,
    required this.daysRemaining,
    this.onResubscribed,
  }) : super(key: key);

  /// Show the resubscribe warning dialog
  static Future<void> showIfNeeded(BuildContext context) async {
    final subscriptionService = SubscriptionService();

    // Check if should show warning
    final shouldShow = await subscriptionService.shouldShowResubscribeWarning();
    if (!shouldShow) return;

    // Get subscription data for details
    final data = await subscriptionService.getSubscriptionData();
    if (data == null) return;

    final expiresAt = data['subscriptionExpiresAt'];
    if (expiresAt == null) return;

    // Calculate days since expiration
    final expirationDate = DateTime.parse(expiresAt);
    final now = DateTime.now();
    final daysSinceExpiration = now.difference(expirationDate).inDays;
    final daysRemaining = 3 - daysSinceExpiration;

    if (daysRemaining < 0) return;

    // Show dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          ResubscribeWarningDialog(daysRemaining: daysRemaining),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: Colors.orange.shade700,
              ),
            ),

            const SizedBox(height: 20),

            // Title
            const TextView(
              text: "Subscription Expired",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            // Warning Message
            TextView(
              text:
                  "Your seller subscription has expired. Your store and products are currently not visible to other users.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Days Remaining Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.shade200, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 18,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 8),
                  TextView(
                    text: daysRemaining == 0
                        ? "Last day to resubscribe"
                        : "$daysRemaining day${daysRemaining > 1 ? 's' : ''} left to resubscribe",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Info Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextView(
                      text:
                          "Resubscribe now to make your store visible again and continue selling.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade900,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: TextView(
                      text: "Later",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      final result = await Get.to(
                        () => SubscriptionRequiredScreen(
                          onSubscribed: onResubscribed,
                        ),
                      );

                      if (result == true && onResubscribed != null) {
                        onResubscribed!();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.btnColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const TextView(
                      text: "Resubscribe Now",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
