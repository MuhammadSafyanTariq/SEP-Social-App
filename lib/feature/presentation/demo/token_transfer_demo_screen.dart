import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/auth_ctrl.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/feature/presentation/helpers/token_transfer_helper.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/coreComponents/AppButton.dart';

class TokenTransferDemoScreen extends StatefulWidget {
  @override
  _TokenTransferDemoScreenState createState() =>
      _TokenTransferDemoScreenState();
}

class _TokenTransferDemoScreenState extends State<TokenTransferDemoScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController recipientController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Token Transfer Demo'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Balance Display
            Obx(() {
              final profileData = ProfileCtrl.find.profileData.value;
              final tokenBalance = profileData.walletTokens ?? 0;
              final dollarBalance = profileData.walletBalance ?? 0;

              return Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextView(
                      text: 'Current Balance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    TextView(
                      text: 'Tokens: $tokenBalance',
                      style: TextStyle(fontSize: 16),
                    ),
                    TextView(
                      text: 'Wallet: \$${dollarBalance}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            }),

            SizedBox(height: 24),

            // API Response Format Documentation
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextView(
                    text: 'Token Transfer API Response Format',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  TextView(
                    text: '''
{
  "status": true,
  "code": 200,
  "message": "Transaction successfully",
  "data": {
    "tokenAmount": 1,
    "commissionTokens": 0,
    "netTokensToReceiver": 1,
    "dollarValue": 0.05,
    "dollarCommission": 0.0,
    "senderNewBalance": 120,
    "receiverNewBalance": 120.05
  }
}''',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Transfer Form
            TextView(
              text: 'Send Tokens',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 16),

            // Amount Input
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Token Amount',
                border: OutlineInputBorder(),
                hintText: 'Enter number of tokens',
              ),
            ),

            SizedBox(height: 16),

            // Recipient Input
            TextField(
              controller: recipientController,
              decoration: InputDecoration(
                labelText: 'Recipient ID',
                border: OutlineInputBorder(),
                hintText: 'Enter recipient user ID',
              ),
            ),

            SizedBox(height: 24),

            // Send Button
            AppButton(
              label: isLoading ? 'Sending...' : 'Send Tokens',
              onTap: isLoading ? null : _sendTokens,
              buttonColor: isLoading ? Colors.grey : Colors.blue,
            ),

            SizedBox(height: 24),

            // Quick Actions
            TextView(
              text: 'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Send 1 Token',
                    onTap: () => _quickSend(1),
                    buttonColor: Colors.orange,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'Send 5 Tokens',
                    onTap: () => _quickSend(5),
                    buttonColor: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sendTokens() async {
    final amount = amountController.text.trim();
    final recipient = recipientController.text.trim();

    if (amount.isEmpty || recipient.isEmpty) {
      AppUtils.toastError('Please fill in all fields');
      return;
    }

    final tokenAmount = int.tryParse(amount);
    if (tokenAmount == null || tokenAmount <= 0) {
      AppUtils.toastError('Please enter a valid token amount');
      return;
    }

    // Check balance
    final currentBalance = ProfileCtrl.find.profileData.value.walletTokens ?? 0;
    if (currentBalance < tokenAmount) {
      AppUtils.toastError('Insufficient token balance');
      return;
    }

    setState(() => isLoading = true);

    try {
      final responseData = await AuthCtrl.find.createMoneyWalletTransaction(
        amount,
        recipient,
      );

      // Log the response for debugging
      AppUtils.log(TokenTransferHelper.formatTransferResponse(responseData));

      // Show success message with commission details
      TokenTransferHelper.showTransferSuccessMessage(
        responseData,
        defaultTokenAmount: tokenAmount,
        recipientType: 'Recipient',
      );

      // Refresh profile data
      await ProfileCtrl.find.getProfileDetails();

      // Clear form
      amountController.clear();
      recipientController.clear();
    } catch (e) {
      AppUtils.toastError('Transfer failed: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _quickSend(int amount) {
    amountController.text = amount.toString();
    // Set a demo recipient ID if empty
    if (recipientController.text.isEmpty) {
      recipientController.text = 'demo_recipient_id';
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    recipientController.dispose();
    super.dispose();
  }
}
