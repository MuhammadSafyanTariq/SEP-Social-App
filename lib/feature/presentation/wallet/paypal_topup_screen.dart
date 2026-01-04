import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/widgets/paypal_webview.dart';
import 'package:sep/services/paypal_service.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';

class PayPalTopUpScreen extends StatefulWidget {
  final String userId;
  final Function(double)? onBalanceUpdated; // Callback to refresh balance

  const PayPalTopUpScreen({
    Key? key,
    required this.userId,
    this.onBalanceUpdated,
  }) : super(key: key);

  @override
  State<PayPalTopUpScreen> createState() => _PayPalTopUpScreenState();
}

class _PayPalTopUpScreenState extends State<PayPalTopUpScreen> {
  final PayPalService _paypalService = PayPalService();
  final TextEditingController _amountController = TextEditingController();
  final ProfileCtrl _profileCtrl = Get.find<ProfileCtrl>();

  bool _isLoading = false;
  int? selectedPackage;
  final List<int> packages = [10, 25, 50, 100];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _initiatePayment() async {
    final amount = double.tryParse(_amountController.text);

    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    if (amount < 1.0) {
      _showError('Minimum amount is \$1.00');
      return;
    }

    setState(() => _isLoading = true);

    // Step 1: Create PayPal order
    final result = await _paypalService.createOrder(
      userId: widget.userId,
      amount: amount,
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      final approvalUrl = result['approvalUrl'];

      // Step 2: Open PayPal checkout in WebView
      // Payment will be automatically processed by backend
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PayPalWebView(
            approvalUrl: approvalUrl,
            onPaymentSuccess: _handlePaymentSuccess,
            onPaymentError: _handlePaymentError,
            onCancelled: _handleCancellation,
          ),
        ),
      );
    } else {
      _showError(result['message'] ?? 'Failed to create order');
    }
  }

  void _handlePaymentSuccess(Map<String, dynamic> data) {
    AppUtils.log('PayPal Success: $data');

    // Refresh profile to get latest balance
    _profileCtrl.getProfileDetails();

    // Show simple success message
    _showSuccess(
      'Payment completed successfully! Your wallet has been updated.',
    );

    // Navigate back after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  void _showSuccess(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.sdp),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.sdp),
              decoration: BoxDecoration(
                color: AppColors.greenlight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AppColors.greenlight,
                size: 50,
              ),
            ),
            SizedBox(height: 20.sdp),
            TextView(
              text: 'Success!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12.sdp),
            TextView(
              text: message,
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.sdp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextView(
            text: label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: isBold ? 16 : 14,
              color: Colors.grey[700],
            ),
          ),
          TextView(
            text: value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: isBold ? 18 : 15,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _handlePaymentError(String message) {
    _showError('Payment failed: $message');
  }

  void _handleCancellation() {
    _showInfo('Payment was cancelled');
  }

  void _showError(String message) {
    AppUtils.toastError(message);
  }

  void _showInfo(String message) {
    AppUtils.toast(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Custom AppBar2
          AppBar2(
            title: 'Top Up Wallet',
            titleStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            prefixImage: 'back',
            onPrefixTap: () => context.pop(),
            backgroundColor: Colors.white,
          ),
          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.sdp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Amount Input Card
                  Container(
                    padding: EdgeInsets.all(20.sdp),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.sdp),
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
                          text: 'Enter Amount',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16.sdp),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.sdp,
                            vertical: 4.sdp,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.greenlight,
                              width: 2,
                            ),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.sdp),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              TextView(
                                text: '\$',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.greenlight,
                                ),
                              ),
                              SizedBox(width: 12.sdp),
                              Expanded(
                                child: TextField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '0.00',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 18,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (_) {
                                    setState(() {
                                      selectedPackage = null;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.sdp),

                  // Quick Amounts
                  TextView(
                    text: 'Quick Amounts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16.sdp),

                  Wrap(
                    spacing: 12.sdp,
                    runSpacing: 12.sdp,
                    children: packages.map((amount) {
                      final isSelected = selectedPackage == amount;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedPackage = amount;
                            _amountController.text = amount.toString();
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.sdp,
                            vertical: 16.sdp,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.greenlight
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20.sdp),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.greenlight
                                  : Colors.grey[300]!,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextView(
                            text: '\$$amount',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 32.sdp),

                  // Pay with PayPal Button
                  AppButton(
                    radius: 20.sdp,
                    buttonColor: AppColors.greenlight,
                    label: _isLoading ? 'Processing...' : 'Pay with PayPal',
                    labelStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    isFilledButton: true,
                    onTap: _isLoading ? null : _initiatePayment,
                  ),

                  SizedBox(height: 24.sdp),

                  // Payment Information Card
                  Container(
                    padding: EdgeInsets.all(20.sdp),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.sdp),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.primaryBlue,
                              size: 20,
                            ),
                            SizedBox(width: 8.sdp),
                            TextView(
                              text: 'Payment Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.sdp),
                        _buildInfoPoint('Secure payment through PayPal'),
                        _buildInfoPoint('First-time users get \$5 bonus'),
                        _buildInfoPoint('Instant wallet top-up'),
                        _buildInfoPoint('Payment processed automatically'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPoint(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.sdp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6.sdp),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 10.sdp),
          Expanded(
            child: TextView(
              text: text,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
