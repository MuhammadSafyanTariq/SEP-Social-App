import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import '../../../components/coreComponents/TextView.dart';
import '../../../components/styles/appColors.dart';
import '../../../utils/appUtils.dart';
import '../controller/auth_Controller/get_stripe_ctrl.dart';
import '../controller/auth_Controller/profileCtrl.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedCurrency = 'EUR';
  String selectedSymbol = '\$';
  int? selectedPackage;
  TextEditingController customAmountController = TextEditingController();

  List<int> packages = [10, 25, 50, 100];

  final GetStripeCtrl stripeCtrl = Get.find<GetStripeCtrl>();

  double get transactionAmount {
    final customAmount = double.tryParse(customAmountController.text.trim());
    if (customAmount != null && customAmount > 0)
      return customAmount.toDouble();
    return selectedPackage?.toDouble() ?? 0.0;
  }

  void _onPay() async {
    if (transactionAmount <= 0) {
      AppUtils.toast("Please enter a valid amount.");
      return;
    }

    if (stripeCtrl.selectedCardId.value.isEmpty) {
      AppUtils.toastError("No card selected.");
      return;
    }

    AppUtils.log(
      "Paying ${transactionAmount.toStringAsFixed(2)} $selectedCurrency",
    );

    final amountInCents = (transactionAmount).toInt().toString();

    await stripeCtrl
        .makePayment(amount: amountInCents, currency: selectedCurrency)
        .applyLoader
        .then((value) async {
          context.pop();
          context.pop();
          await stripeCtrl.refreshTransactionList();
          await ProfileCtrl.find.getProfileDetails();
        });
  }

  @override
  void dispose() {
    customAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // Custom AppBar2
          AppBar2(
            title: 'Payment',
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
              child: Padding(
                padding: EdgeInsets.all(20.sdp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.sdp),
                    TextView(
                      text: "Amount",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12.sdp),
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
                            text: selectedSymbol,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.greenlight,
                            ),
                          ),
                          SizedBox(width: 12.sdp),
                          Expanded(
                            child: TextField(
                              maxLength: 5,
                              controller: customAmountController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                hintText: "Enter amount",
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                                counterText: "",
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
                    SizedBox(height: 20.sdp),

                    Center(
                      child: Container(
                        padding: EdgeInsets.all(24.sdp),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.sdp),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            TextView(
                              text:
                                  "$selectedSymbol${transactionAmount.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.greenlight,
                              ),
                            ),
                            SizedBox(height: 8.sdp),
                            TextView(
                              text: "Transaction Amount",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24.sdp),

                    TextView(
                      text: "Quick Amounts",
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
                              customAmountController.text = amount.toString();
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.sdp,
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
                              text: "$selectedSymbol$amount",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 40.sdp),
                    AppButton(
                      radius: 20.sdp,
                      buttonColor: AppColors.greenlight,
                      label: "Continue",
                      labelStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      isFilledButton: true,
                      onTap: _onPay,
                    ),
                    SizedBox(height: 20.sdp),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
