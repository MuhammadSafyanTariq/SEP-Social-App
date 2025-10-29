import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/widget.dart';
import '../../../components/coreComponents/EditText.dart';
import '../../../components/coreComponents/TextView.dart';
import '../../../components/styles/app_strings.dart';

class Addnewaddress extends StatelessWidget {
  const Addnewaddress({super.key});

  @override
  Widget build(BuildContext context) {

    final ValueNotifier<String> _selectedCountryCode =
    ValueNotifier<String>('+91');
    final List<Map<String, String>> _countries = [
      {'code': '+91', 'flag': '🇮🇳'},
      {'code': '+1', 'flag': '🇺🇸'},
      {'code': '+44', 'flag': '🇬🇧'},
    ];
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: (){context.pop();},
            child: Icon(Icons.arrow_back_ios,color: AppColors.primaryColor,size: 20,)),

        centerTitle: true,
        title: TextView(text: "Add New Address",style: 17.txtSBoldprimary,),
        backgroundColor: AppColors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: Padding(
        padding: 20.left + 20.right,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextView(
                textAlign: TextAlign.start,
                text: 'Contact Details',
                style: 18.txtBoldWhite,
                margin: 2.vertical,
              ),
              TextView(
                textAlign: TextAlign.start,
                text: 'First Name',
                style: 14.txtRegularWhite,
                margin: 10.vertical,
              ),
              EditText(
                hint: 'Enter First Name ',
                hintStyle: 16.txtRegularGrey,
                inputType: TextInputType.emailAddress,
                margin: 10.bottom,
              ),

              TextView(
                textAlign: TextAlign.start,
                text: 'Last Name',
                style: 14.txtRegularWhite,
                margin: 10.vertical,
              ),
              EditText(
                hint: 'Enter Last Name ',
                hintStyle: 16.txtRegularGrey,
                inputType: TextInputType.emailAddress,
                margin: 10.bottom,
              ),

              TextView(
                textAlign: TextAlign.start,
                text: AppStrings.phone.tr,
                style: 14.txtRegularWhite,
                margin: 10.vertical,
              ),
              Container(
                height: 50.sdp,
                decoration: BoxDecoration(
                  border:
                  Border.all(color: AppColors.grey.withOpacity(0.6.sdp)),
                  borderRadius: BorderRadius.circular(10.0.sdp),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: 8.horizontal,
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                              color: AppColors.grey.withOpacity(0.6.sdp)),
                        ),
                      ),
                      child: ValueListenableBuilder<String>(
                        valueListenable: _selectedCountryCode,
                        builder: (context, value, child) {
                          return DropdownButton<String>(
                            value: value,
                            items: _countries
                                .map(
                                  (country) => DropdownMenuItem<String>(
                                value: country['code'],
                                child: Row(
                                  children: [
                                    TextView(
                                      margin: 8.right,
                                      text: country['flag']!,
                                      style: 26.txtRegularGrey,
                                    ),
                                  ],
                                ),
                              ),
                            )
                                .toList(),
                            onChanged: (newValue) {
                              _selectedCountryCode.value = newValue!;
                            },
                            underline: const SizedBox(),
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              size: 20.sdp,
                            ),
                          );
                        },
                      ),
                    ),
                    8.width,
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(12),
                        ],
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: AppStrings.phonehint.tr,
                          hintStyle: 16.txtRegularGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              10.height,
              TextView(
                textAlign: TextAlign.start,
                text: 'Address Details',
                style: 18.txtBoldWhite,
                margin: 10.vertical,
              ),


              TextView(
                textAlign: TextAlign.start,
                text: 'House / Flat / Building / Apartment',
                style: 14.txtRegularWhite,
                margin: 10.vertical,
              ),

              EditText(
                hint: 'Enter Details  ',
                hintStyle: 16.txtRegularGrey,
                inputType: TextInputType.emailAddress,
                margin: 10.bottom,
              ),


              TextView(
                textAlign: TextAlign.start,
                text: 'Street / Locality',
                style: 14.txtRegularWhite,
                margin: 10.vertical,
              ),

              EditText(
                hint: 'Enter Details  ',
                hintStyle: 16.txtRegularGrey,
                inputType: TextInputType.emailAddress,
                margin: 10.bottom,
              ),


              TextView(
                textAlign: TextAlign.start,
                text: 'Landmark (optional)',
                style: 14.txtRegularWhite,
                margin: 10.vertical,
              ),

              EditText(
                hint: 'Enter Details  ',
                hintStyle: 16.txtRegularGrey,
                inputType: TextInputType.emailAddress,
                margin: 10.bottom,
              ),

              TextView(
                textAlign: TextAlign.start,
                text: 'City, State',
                style: 14.txtRegularWhite,
                margin: 10.vertical,
              ),

              EditText(
                hint: 'Enter Details  ',
                hintStyle: 16.txtRegularGrey,
                inputType: TextInputType.emailAddress,
                margin: 20.bottom,
              ),

              AppButton(
                margin: 20.top + 40.bottom,
                label: "Add Address",
                labelStyle: 18.txtMediumWhite,
                buttonColor: AppColors.btnColor,
                onTap:() {context.pop();},
              )
            ],
          ),
        ),
      ),
    );
  }
}
