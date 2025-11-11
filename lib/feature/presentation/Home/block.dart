import 'package:flutter/material.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/data/models/dataModels/profile_data/profile_data_model.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import 'package:sep/utils/extensions/widget.dart';
import '../../../components/coreComponents/ImageView.dart'; // Make sure this imports the correct image component
import '../../../components/coreComponents/TextView.dart';
import '../../../components/styles/appColors.dart';

class Block extends StatelessWidget {
  String? name;
  ProfileDataModel data;
  Function? onBlock;
   Block({super.key, required this.name,  required this.data, this.onBlock});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Center(
                    child: Container(
                      width: 70,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: ImageView(
                    bgColor: AppColors.greynew,
                    size: 70,
                    radius: 35,
                    url: baseUrl+(data.image ?? ''),
                    imageType: ImageType.network,
                    fit: BoxFit.cover,
                  ),
                ),

                TextView(
                  text: "Block ${name.toString()}",
                  style: 20.txtMediumBlack,margin: EdgeInsets.only(top: 16,bottom: 16),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.block_flipped),
                      Expanded(
                        child: TextView(
                          text: " They won't be able to message you \nor find your profile or content.",
                          style: 16.txtMediumBlack,
                          overflow: TextOverflow.ellipsis, // Handles overflow
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Row(
                    children: [
                      Icon(Icons.notifications_off_outlined),
                      Expanded(
                        child: TextView(
                          text: "They won't be notified that you blocked them.",
                          style: 16.txtMediumBlack,
                          overflow: TextOverflow.ellipsis,  // Handles overflow
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Row(
                    children: [
                      Icon(Icons.settings_outlined),
                      Expanded(
                        child: TextView(
                          text: " You can unblock them anytime in Settings.",
                          style: 16.txtMediumBlack,
                          overflow: TextOverflow.ellipsis,  // Adds ellipsis if text overflows
                        ),
                      ),
                    ],
                  ),
                ),

                AppButton(
                  onTap: (){
                    context.pop();
                    ProfileCtrl.find.unblockBlockUser(userId: data.id!).applyLoader.then((value){
                      onBlock?.call();
                    });
                  },
                  label: "Block",
                  labelStyle: 16.txtMediumWhite,
                  buttonColor: AppColors.btnColor,margin: EdgeInsets.only(top: 40),
                ),
                // TextView(
                //   margin: EdgeInsets.only(top: 15),
                //   text: "Block and Report",
                //   style: 16.txtboldgreen,
                // ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: TextView(
                      text: "Your report is anonymous, except if you're reporting an \nintellectual property infringement.",
                      style: 12.txtRegularBlack,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis, // Handles overflow
                    ),
                  ),
                ),
                20.height,

              ],
            ),
          ),
        ],
      ),
    );
  }
}
