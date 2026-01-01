import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/services/subscription/subscription_service.dart';
import 'package:sep/utils/appUtils.dart';

class SubscriptionRequiredScreen extends StatefulWidget {
  final VoidCallback? onSubscribed;

  const SubscriptionRequiredScreen({Key? key, this.onSubscribed})
    : super(key: key);

  @override
  State<SubscriptionRequiredScreen> createState() =>
      _SubscriptionRequiredScreenState();
}

class _SubscriptionRequiredScreenState
    extends State<SubscriptionRequiredScreen> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool isLoading = false;
  Map<String, dynamic>? subscriptionStatus;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionStatus();
  }

  Future<void> _loadSubscriptionStatus() async {
    setState(() => isLoading = true);
    final status = await _subscriptionService.getSubscriptionData();
    setState(() {
      subscriptionStatus = status;
      isLoading = false;
    });
  }

  Future<void> _handleSubscribe() async {
    setState(() => isLoading = true);

    try {
      final result = await _subscriptionService.subscribe();

      setState(() => isLoading = false);

      if (result.isSuccess && result.data != null) {
        final data = result.data!;
        AppUtils.toast(
          'Subscription activated! Valid for ${data['daysRemaining'] ?? 30} days.',
        );

        // Call the callback if provided
        if (widget.onSubscribed != null) {
          widget.onSubscribed!();
        }

        // Go back to previous screen
        Get.back(result: true);
      } else {
        final errorMessage = result.error?.toString() ?? 'Subscription failed';
        AppUtils.toastError(
          errorMessage.contains('Insufficient balance')
              ? 'Insufficient balance. Please top up your wallet first.'
              : errorMessage
                    .replaceAll('Exception: ', '')
                    .replaceAll('Failed to subscribe: ', ''),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      AppUtils.toastError('An error occurred. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentBalance = subscriptionStatus?['currentBalance'] ?? 0.0;
    final subscriptionPrice = subscriptionStatus?['subscriptionPrice'] ?? 9.99;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const TextView(
          text: "Subscription Required",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.btnColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.storefront,
                      size: 80,
                      color: AppColors.btnColor,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title
                  const TextView(
                    text: "Become a Seller",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Description
                  TextView(
                    text:
                        "Subscribe to create your own store and start selling products to the community.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Pricing Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.btnColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.btnColor.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextView(
                              text: "\$",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.btnColor,
                              ),
                            ),
                            TextView(
                              text: subscriptionPrice.toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                color: AppColors.btnColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextView(
                          text: "per month",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Features List
                  _buildFeatureItem(
                    Icons.store_outlined,
                    "Create Your Own Store",
                  ),
                  _buildFeatureItem(
                    Icons.inventory_2_outlined,
                    "Upload Unlimited Products",
                  ),
                  _buildFeatureItem(
                    Icons.people_outline,
                    "Reach Thousands of Customers",
                  ),
                  _buildFeatureItem(Icons.trending_up, "Manage Orders & Sales"),
                  _buildFeatureItem(Icons.calendar_today, "30 Days Validity"),

                  const SizedBox(height: 32),

                  // Current Balance Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextView(
                          text: "Your Wallet Balance:",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                          ),
                        ),
                        TextView(
                          text: "\$${currentBalance.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Subscribe Button
                  AppButton(label: "Subscribe Now", onTap: _handleSubscribe),

                  const SizedBox(height: 16),

                  // Cancel Button
                  TextButton(
                    onPressed: () => Get.back(),
                    child: TextView(
                      text: "Maybe Later",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.btnColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.btnColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextView(
              text: text,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.green, size: 24),
        ],
      ),
    );
  }
}
