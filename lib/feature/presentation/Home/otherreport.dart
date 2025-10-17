import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/textStyle.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../../../components/coreComponents/AppButton.dart';
import '../../../../../components/coreComponents/EditText.dart';
import '../../../../../components/coreComponents/ImageView.dart';
import '../../../../../components/coreComponents/TextView.dart';
import '../../../../../components/coreComponents/appBar2.dart';
import '../../../../../components/coreComponents/common_password_input_field.dart';
import '../../../../../components/styles/appColors.dart';
import '../../../../../components/styles/appImages.dart';
import '../../../../../components/styles/app_strings.dart';


class OtherReport extends StatefulWidget {
  final String postId;
  const OtherReport({super.key, required this.postId});

  @override
  _OtherReportState createState() => _OtherReportState();
}

class _OtherReportState extends State<OtherReport> {
  final TextEditingController _currentPasswordController =
  TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _reEnterPasswordController =
  TextEditingController();
  bool isLoading = false;
  TextEditingController titleController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Stack(
          children: [
            Column(
              children: [
                AppBar2(
                  prefixImage: AppImages.backBtn,
                  suffixWidget: SizedBox(width: 30,),
                  title: "Other",
                  titleStyle: 20.txtMediumprimary,
                  onPrefixTap: () {
                    context.pop();
                  },
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextView(
                            margin: 18.top,
                            text: 'Title',
                            style: 14.txtMediumbtncolor,
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: EditText(
                              hint: 'Enter  Your Title here',
                              inputType: TextInputType.name,
                              controller: titleController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return AppStrings.pleaseEnterName.tr;
                                }
                                return null;
                              },
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: TextView(
                              text: 'Reason',
                              style: 14.txtMediumbtncolor,
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: TextField(
                              controller: messageController,
                              decoration: InputDecoration(
                                hintText: "Reason",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.all(10),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
                              maxLines: 5,
                              keyboardType: TextInputType.multiline,
                            ),
                          ),



                          AppButton(
                            onTap: (){
                              if(_formKey.currentState!.validate()){
                                ProfileCtrl.find.reportPostRequest(widget.postId, titleController.getText, messageController.getText).applyLoader.then((value){
                                  ProfileCtrl.find.globalPostList.removeWhere((element)=> element.id == widget.postId);
                                  ProfileCtrl.find.globalPostList.refresh();
                                  context.pop();
                                }).catchError((e){
                                  AppUtils.toastError(e);
                                });
                              }

                            },
                            margin: 50.top + 30.left + 30.right,
                            label: 'Submit',
                            labelStyle: 18.txtMediumWhite,
                            buttonColor: AppColors.btnColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (isLoading)
              Container(
                color: Colors.grey.withOpacity(0.5),
                child: const Center(
                  child: SpinKitCircle(
                    color: AppColors.btnColor,
                    size: 50.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
