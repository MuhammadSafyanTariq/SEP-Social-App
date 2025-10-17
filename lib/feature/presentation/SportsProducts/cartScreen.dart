import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/coreComponents/appBar2.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/components/styles/app_strings.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import 'package:sep/utils/extensions/widget.dart';

import '../../../components/coreComponents/EditText.dart';
import '../../../components/coreComponents/TextView.dart';
import 'addNewAddress.dart';

class Cartscreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: 16.all,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBar2(
                prefixImage: AppImages.backBtn,
                title: AppStrings.yourCart.tr,
                titleStyle: 22.txtSBoldprimary,
                onPrefixTap: () {
                  context.pop();
                },
                suffixWidget: Container(width: 25,),
              ),
              12.height,
              EditText(
                hint: AppStrings.pinCode.tr,
                hintStyle: 15.txtMediumgrey,
                inputType: TextInputType.emailAddress,
                suffixIcon: Padding(
                  padding: 15.all,
                  child: TextView(
                    text: AppStrings.changes.tr,
                    style: 13.txtMediumbtncolor,
                  ),
                ),
                margin: 20.bottom,
              ),
              Row(
                children: [
                  ImageView(url: AppImages.truck, size: 25.sdp,tintColor: AppColors.primaryColor,),
                  10.width,
                  TextView(
                    text:AppStrings.hurryYouHave.tr,
                    style: 15.txtMediumPrimary,
                  ),
                ],
              ),

              EditText(
                margin: 20.top,
                readOnly: true,
                prefixIcon: Padding(
                  padding: 13.all,
                  child: ImageView(
                    url: AppImages.truck,
                    size: 20,
                    tintColor: AppColors.btnColor,
                  ),
                ),
                hint: AppStrings.addDelivaryAddress.tr,
                hintStyle: 16.txtregularBtncolor,
                inputType: TextInputType.emailAddress,
                suffixIcon: Padding(
                  padding: 15.all,
                  child: Icon(
                    Icons.arrow_forward_ios_sharp,
                    color: AppColors.btnColor,
                  ),
                ),
                onTap: () {context.pushNavigator(Addnewaddress());},
              ),
              TextView(
                margin: 24.top + 8.bottom,
                text: AppStrings.itemsForDelivery.tr,
                style: 18.txtSBoldprimary,
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: 10.right+10.left+10.bottom,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextView(
                            text: '1/1 Items Selected',
                            style: 15.txtSBoldprimary,
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: ImageView(
                              url: AppImages.deleteproduct,
                              height: 32.sdp,
                              width: 30.sdp,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          ImageView(
                            url: AppImages.ball,
                            height: 50.sdp,
                            width: 50.sdp,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextView(
                                  text: 'Football',
                                  style: 16.txtMediumBlack,
                                ),
                                TextView(
                                  text:
                                      'Score big with unbeatable deals in our football sale!',
                                  style: 12.txtRegularprimary,
                                  margin: 10.bottom,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: 65.left,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 80.sdp,
                              height: 30.sdp,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black, width: 1),
                                borderRadius: BorderRadius.circular(5)
                              ),
                              padding: 8.horizontal,
                              child: DropdownButton<int>(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                value: 1,
                                isExpanded: true,
                                underline: SizedBox(),
                                items: List.generate(
                                  10,
                                      (index) => DropdownMenuItem(
                                    child: TextView(
                                      text: 'Qty: ${index + 1}',
                                      style: 12.txtBoldBlack,
                                    ),
                                    value: index + 1,
                                  ),
                                ),
                                onChanged: (value) {

                                },
                                dropdownColor: Colors.white,
                              ),
                            ),

                            Align(
                              alignment: Alignment.topLeft,
                              child: TextView(
                                margin: 10.top,
                                text: '\$ 89',
                                style: 16.txtBoldBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TextView(
                margin: 24.top + 8.bottom,
                text: AppStrings.orderSummary.tr,
                style: 18.txtSBoldprimary,
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: 12.all,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextView(
                            text: AppStrings.totalPrice.tr,
                            style: 15.txtRegularprimary,
                            margin: 10.top + 10.bottom,
                          ),
                          TextView(
                            text: '\$89',
                            style: 15.txtBoldBlack,
                          ),
                        ],
                      ),
                      8.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextView(
                            text: AppStrings.convenienceFee.tr,
                            style: 15.txtRegularprimary,
                          ),
                          TextView(
                            text: '\$10',
                            style: 15.txtBoldBlack,
                          ),
                        ],
                      ),
                      Divider(height: 24, thickness: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextView(
                            text: AppStrings.totalAmount.tr,
                            style: 15.txtBoldBlack,
                          ),
                          TextView(
                            text: '\$99',
                            style: 15.txtBoldBlack,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              24.height,
              Divider(thickness: 1, color: AppColors.grey,),
              10.height,
              Padding(
                padding: 30.horizontal ,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.btnColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  ),
                  onPressed: () {
                    context.pushNavigator(Addnewaddress());
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: 20.left,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextView(
                              text: '1 item',
                              style: 12.txtBoldWhite,
                            ),
                            TextView(
                              text: '\$99',
                              style: 15.txtBoldWhite,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1.sdp,
                        height: 40.sdp,
                        color: AppColors.white,
                        margin: 12.horizontal,
                      ),
                      Padding(
                        padding: 30.right,
                        child: TextView(
                          text: AppStrings.proceedToCheckout.tr,
                          style: 18.txtMediumWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
}
