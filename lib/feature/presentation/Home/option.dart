import 'dart:io';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sep/components/appLoader.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import 'package:sep/utils/extensions/widget.dart';
import 'package:share_plus/share_plus.dart';
import '../../../components/coreComponents/AppButton.dart';
import '../../../components/coreComponents/TextView.dart';
import '../../../components/styles/appColors.dart';
import '../../../services/storage/preferences.dart';
import '../../data/models/dataModels/post_data.dart';
import '../../data/models/dataModels/profile_data/profile_data_model.dart';
import 'block.dart';
import 'otherreport.dart';

class Options extends StatelessWidget {
  final String? postUserId;
  final String? postId;
  final ProfileDataModel data;
  final Function onBlockSuccess;

  String? name;
  final PostData postData;

  Options({
    super.key,
    required this.name,
    required this.postUserId,
    required this.data,
    required this.onBlockSuccess,
    required this.postData,
    this.postId,
  });

  Widget _buildOption({
    required String text,
    required TextStyle style,
    required VoidCallback onTap, // onTap functionality
    bool isLast = false,
  }) {
    AppUtils.log(data.toJson());
    return Column(
      children: [
        InkWell(
          onTap: onTap, // Assigning onTap function
          splashColor: AppColors.Grey.withOpacity(0.2), // Adds touch feedback
          borderRadius:
              BorderRadius.circular(8), // Slight rounding for better UX
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextView(text: text, style: style, textAlign: TextAlign.left),
                const Icon(Icons.arrow_forward_ios, size: 20),
              ],
            ),
          ),
        ),
        if (!isLast) Divider(thickness: 1, color: AppColors.Grey),
      ],
    );
  }

  // late var loginUserId = Preferences.profile?.id.toString();

  @override
  Widget build(BuildContext context) {
    AppUtils.log("postuserid>>>>>>>>>>>>>>>>>>>>>${postUserId.toString()}");
    AppUtils.log("name>>>>>>>>>>>>>>>>>>>>>${name}");
    // AppUtils.log("loginuserid>>>>>>>>>>>>>>>>>>>>>${loginUserId}");
    // AppUtils.log("image>>>>${postImage.fileUrl}");
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: ListView(
          children: [
            postUserId == Preferences.uid ||
                    (data.followers ?? []).contains(Preferences.uid)
                ? SizedBox.shrink()
                : _buildOption(
                    text: 'Link Up',
                    style: 17.txtMediumBlack,
                    onTap: () {
                      context.pop();
                      ProfileCtrl.find.followRequest(data.id!).applyLoader;
                      print('Mute This Follow tapped');
                      // Example: Perform mute functionality
                    },
                  ),
            // : Container(),

            Visibility(
              visible: false,
              child: _buildOption(
                text: 'Share',
                style: 17.txtMediumBlack,
                onTap: () {
                  print('Comments tapped');
                  // Example: Navigate to Comments screen
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => CommentsScreen()));
                },
              ),
            ),

            Visibility(
              visible: false,
              child: _buildOption(
                text: 'Hide This Post',
                style: 17.txtMediumBlack,
                onTap: () {
                  print('Mute This Post tapped');
                  // Example: Perform mute functionality
                },
              ),
            ),
            postUserId.toString() == Preferences.uid
                ? SizedBox.shrink()
                : Visibility(
                    // visible: false,
                    child: _buildOption(
                      text: 'Report',
                      style: 17.txtMediumBlack,
                      onTap: () {
                        context.pop();
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (BuildContext context) {
                            return Container(
                              height: MediaQuery.of(context).size.height * 0.75,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Center(
                                      child: Container(
                                        width: 70,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: AppColors.grey,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      child: ReportSheet(
                                    postUserId: postUserId!,
                                    postId: postId!,
                                  )),
                                ],
                              ),
                            );
                          },
                        ); // Example: Save post action
                      },
                    ),
                  ),

            postUserId.toString() == Preferences.uid
                ? SizedBox.shrink()
                : _buildOption(
                    text: 'Block ${name}',
                    style: 17.txtMediumRed,
                    onTap: () {
                      print('Block Nelson Carroll tapped');
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (BuildContext context) {
                          return Container(
                            height: MediaQuery.of(context).size.height * 0.7,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Center(
                                    child: Container(
                                      width: 70,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: AppColors.grey,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Block(
                                    name: name.toString(),
                                    data: data,
                                    onBlock: () {
                                      onBlockSuccess.call();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    isLast: true,
                  ),
            Divider(
              color: AppColors.grey,
            ),
            _buildOption(
              text: 'Share',
              style: 17.txtMediumBlack,
              onTap: () async {
                final fileUrl = postData.files?.first.file.fileUrl ?? "";

                if (fileUrl.isEmpty) {
                  AppUtils.log("No file to share");
                  return;
                }

                AppUtils.log("shareFile::$fileUrl");

                String appLink = Platform.isAndroid
                    ? "https://play.google.com/store/apps/details?id=com.app.sep"
                    : "https://apps.apple.com/in/app/sep-media/id6743032925";

                String textToShare = '''
Check out this post by ${data.name}

Download the app: $appLink
''';
                AppLoader.showLoader(context);

                try {
                  final response = await http.get(Uri.parse(fileUrl));
                  final bytes = response.bodyBytes;
                  final tempDir = await getTemporaryDirectory();

                  String extension = fileUrl.split('.').last.toLowerCase();
                  String mimeType;

                  switch (extension) {
                    case 'mp4':
                    case 'mov':
                    case 'avi':
                      mimeType = 'video/$extension';
                      extension = 'mp4';
                      break;
                    case 'jpg':
                    case 'jpeg':
                    case 'png':
                      mimeType = 'image/$extension';
                      break;
                    default:
                      mimeType = 'application/octet-stream';
                  }

                  final filePath = '${tempDir.path}/shared_file.$extension';
                  final localFile = File(filePath);
                  await localFile.writeAsBytes(bytes);
                  Navigator.of(context).pop();
                  final xFile = XFile(
                    localFile.path,
                    name: 'shared_file.$extension',
                    mimeType: mimeType,
                  );

                  final box = context.findRenderObject() as RenderBox?;
                  final result = await SharePlus.instance.share(
                    ShareParams(
                      text: textToShare,
                      files: [xFile],
                      sharePositionOrigin:
                          box!.localToGlobal(Offset.zero) & box.size,
                    ),
                  );

                  AppUtils.log("Share result: ${result.status}");
                } catch (e) {
                  AppLoader.hideLoader(context);
                  AppUtils.log("Error sharing: $e");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ReportSheet extends StatefulWidget {
  final String postUserId;
  final String postId;

  const ReportSheet({Key? key, required this.postUserId, required this.postId})
      : super(key: key);

  @override
  _ReportSheetState createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  List<String> options = [
    'Hate Speech or Symbols',
    'Harassment or Bullying',
    'Violence or Threats',
    'Nudity or Sexual Content',
    'Self-Harm or Suicide',
    'False Information',
    'Spam or Scams',
    'Impersonation',
    'Illegal Activities',
    'Terrorism or Extremism',
    'Animal or Child Abuse',
    'Graphic Violence or Gore',
    'Unauthorized Sales',
    'Privacy Violations',
    'Underage Use',
    "Other"
  ];

  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            8.height,
            Center(
              child: TextView(
                text: "Report",
                style: 20.txtMediumBlack,
              ),
            ),
            25.height,
            Expanded(
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextView(
                      text: "Why are you reporting this post?",
                      style: 20.txtMediumBlack,
                      // margin: 10.left,
                    ),
                    10.height,
                    TextView(
                      text:
                          "Your report is anonymous. If someone is in immediate danger, call the local emergency services - don’t wait.",
                      style: 16.txtRegularBlack,
                      // margin: 10.left,
                    ),
                    10.height,
                    ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: options.length,
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => SizedBox(
                        height: 16,
                      ),
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextView(
                                    text: options[index],
                                    style: 19.txtMediumBlack,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                index == options.length - 1
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(right: 12.0),
                                        child: Icon(Icons.arrow_forward_ios,
                                            size: 16,
                                            color: AppColors.btnColor),
                                      )
                                    : Checkbox(
                                        value: selectedIndex == index,
                                        activeColor: AppColors.btnColor,
                                        checkColor: Colors.white,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            selectedIndex =
                                                value! ? index : null;
                                          });
                                        },
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        side: BorderSide(
                                            color: AppColors.btnColor),
                                      )
                              ],
                            ),
                            Positioned.fill(child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                });

                                if (index == options.length - 1) {
                                  context.replaceNavigator(OtherReport(
                                    postId: widget.postId,
                                  ));
                                }
                              },
                            ))
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            AppButton(
              onTap: () {
                if (selectedIndex != null) {
                  final title = options[selectedIndex!];
                  ProfileCtrl.find
                      .reportPostRequest(
                      widget.postId, title, null)
                      .applyLoader
                      .then((value) {
                    ProfileCtrl.find.globalPostList.removeWhere((element)=> element.id == widget.postId);
                    ProfileCtrl.find.globalPostList.refresh();
                    context.pop();
                  }).catchError((error){
                    AppUtils.toastError(error);
                  });
                }
              },
              margin: EdgeInsets.only(bottom: context.bottomSafeArea + 10),
              label: 'Done',
              buttonColor: AppColors.greenlight,
            )
          ],
        ),
      ),
    );
  }
}
