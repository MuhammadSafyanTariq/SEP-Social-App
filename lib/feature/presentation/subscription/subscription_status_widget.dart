import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/services/subscription/subscription_service.dart';
import 'package:sep/feature/presentation/subscription/subscription_required_screen.dart';
import 'package:sep/utils/appUtils.dart';

/// Widget to display subscription status and allow renewal
class SubscriptionStatusWidget extends StatefulWidget {
  final bool showRenewButton;
  final VoidCallback? onSubscribed;

  const SubscriptionStatusWidget({
    Key? key,
    this.showRenewButton = true,
    this.onSubscribed,
  }) : super(key: key);

  @override
  State<SubscriptionStatusWidget> createState() =>
      _SubscriptionStatusWidgetState();
}

class _SubscriptionStatusWidgetState extends State<SubscriptionStatusWidget> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool isLoading = true;
  Map<String, dynamic>? subscriptionData;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionStatus();
  }

  Future<void> _loadSubscriptionStatus() async {
    setState(() => isLoading = true);
    final data = await _subscriptionService.getSubscriptionData();
    setState(() {
      subscriptionData = data;
      isLoading = false;
    });
  }

  Future<void> _handleRenew() async {
    final result = await Get.to(
      () => SubscriptionRequiredScreen(onSubscribed: widget.onSubscribed),
    );

    if (result == true) {
      await _loadSubscriptionStatus();
      if (widget.onSubscribed != null) {
        widget.onSubscribed!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (subscriptionData == null) {
      return const SizedBox.shrink();
    }

    final isActive = subscriptionData!['isActive'] == true;
    final daysRemaining = subscriptionData!['daysRemaining'] ?? 0;
    final expiresAt = subscriptionData!['subscriptionExpiresAt'];
    final status = subscriptionData!['subscriptionStatus'] ?? 'none';

    // Format expiration date
    String formattedDate = '';
    if (expiresAt != null) {
      try {
        final date = DateTime.parse(expiresAt);
        formattedDate = '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        AppUtils.log('Error parsing date: $e');
      }
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.shade50
            : (status == 'expired'
                  ? Colors.orange.shade50
                  : Colors.grey.shade50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? Colors.green.shade200
              : (status == 'expired'
                    ? Colors.orange.shade200
                    : Colors.grey.shade200),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.green.shade100
                      : (status == 'expired'
                            ? Colors.orange.shade100
                            : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isActive ? Icons.check_circle : Icons.info_outline,
                  color: isActive
                      ? Colors.green.shade700
                      : (status == 'expired'
                            ? Colors.orange.shade700
                            : Colors.grey.shade700),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextView(
                      text: isActive
                          ? "Active Subscription"
                          : (status == 'expired'
                                ? "Subscription Expired"
                                : "No Subscription"),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isActive
                            ? Colors.green.shade900
                            : (status == 'expired'
                                  ? Colors.orange.shade900
                                  : Colors.grey.shade900),
                      ),
                    ),
                    if (isActive && formattedDate.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      TextView(
                        text: "Expires: $formattedDate",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (isActive) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: daysRemaining <= 7
                    ? Colors.orange.shade100
                    : Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: daysRemaining <= 7
                        ? Colors.orange.shade700
                        : Colors.green.shade700,
                  ),
                  const SizedBox(width: 8),
                  TextView(
                    text: "$daysRemaining days remaining",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: daysRemaining <= 7
                          ? Colors.orange.shade700
                          : Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (!isActive && widget.showRenewButton) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleRenew,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: TextView(
                  text: status == 'expired'
                      ? "Renew Subscription"
                      : "Subscribe Now",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.btnColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
