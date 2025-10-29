import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sep/components/coreComponents/AppBar2.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/app_strings.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/data/models/dataModels/settings_model/faq_item_model.dart';
import 'package:sep/feature/data/repository/iTempRepository.dart';
import 'package:sep/feature/domain/respository/templateRepository.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import 'package:sep/utils/extensions/widget.dart';
import '../../../../../utils/appUtils.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final TempRepository _repo = ITempRepository();
  RxList<FaqItemModel> faqItems = RxList([]);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => fetchFAQs());
    // Add some dummy data for now if API fails
    _addDummyData();
  }

  void _addDummyData() {
    // Add some sample FAQ items to show content
    faqItems.addAll([
      FaqItemModel(
        id: "1",
        question: AppStrings.howDoIEarnRewards.tr,
        answer: AppStrings.earnRewardsAnswer.tr,
        isExpanded: false,
        showFullAnswer: false,
      ),
      FaqItemModel(
        id: "2",
        question: AppStrings.howCanIChangeMyPassword.tr,
        answer: AppStrings.changePasswordAnswer.tr,
        isExpanded: false,
        showFullAnswer: false,
      ),
      FaqItemModel(
        id: "3",
        question: AppStrings.whatAreTheDifferentRewardTiers.tr,
        answer: AppStrings.rewardTiersAnswer.tr,
        isExpanded: false,
        showFullAnswer: false,
      ),
      FaqItemModel(
        id: "4",
        question: AppStrings.howDoIReportABug.tr,
        answer: AppStrings.reportBugAnswer.tr,
        isExpanded: false,
        showFullAnswer: false,
      ),
      FaqItemModel(
        id: "5",
        question: AppStrings.howDoIUpdateMyProfileInformation.tr,
        answer: AppStrings.updateProfileAnswer.tr,
        isExpanded: false,
        showFullAnswer: false,
      ),
      FaqItemModel(
        id: "6",
        question: AppStrings.howDoIReportABug.tr,
        answer: AppStrings.reportBugAnswer.tr,
        isExpanded: false,
        showFullAnswer: false,
      ),
      FaqItemModel(
        id: "7",
        question: AppStrings.howDoIUpdateMyProfileInformation.tr,
        answer: AppStrings.updateProfileAnswer.tr,
        isExpanded: false,
        showFullAnswer: false,
      ),
    ]);
  }

  Future<void> fetchFAQs() async {
    try {
      final response = await _repo
          .frequentaskquestion(question: "helloll")
          .applyLoader;
      if (response.isNotEmpty) {
        faqItems.assignAll(response);
      }
    } catch (e) {
      AppUtils.log("FAQ fetch error: $e");
    }

    // if (mounted) {
    //   setState(() {
    //     // isLoading = false;
    //
    //     if (response.isSuccess && response.data != null) {
    //       debugPrint("API Response: ${response.data}");
    //
    //       if (response.data!.data is List) {
    //         faqItems = (response.data!.data as List)
    //             .map((item) {
    //           debugPrint("Item: $item");
    //           return FAQItem(
    //             question: item["question"] ?? "Unknown",
    //             answer: item["answer"] ?? "No answer available.",
    //           );
    //         })
    //             .toList();
    //       } else {
    //         AppUtils.toastError("Invalid data format received from API.");
    //       }
    //     } else {
    //       AppUtils.toastError(response.error?.toString() ?? "Failed to fetch FAQs");
    //     }
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          AppBar2(
            title: AppStrings.faqTitle.tr,
            titleStyle: 18.txtMediumBlack,
            prefixImage: "back",
            onPrefixTap: () => Navigator.pop(context),
            backgroundColor: Colors.white,
            hasTopSafe: true,
          ),
          Expanded(
            child: Obx(() {
              if (faqItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.help_outline,
                        size: 64.sdp,
                        color: AppColors.grey,
                      ),
                      16.height,
                      TextView(
                        text: AppStrings.noFaqsAvailable.tr,
                        style: 18.txtMediumBlack,
                      ),
                      8.height,
                      TextView(
                        text: AppStrings.checkBackLater.tr,
                        style: 14.txtRegularGrey,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // FAQ Items
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(16.sdp),
                      itemCount: faqItems.length,
                      itemBuilder: (context, index) {
                        return FAQTile(item: faqItems[index]);
                      },
                    ),

                    // Still Need Help Section
                    Container(
                      margin: EdgeInsets.all(16.sdp),
                      padding: EdgeInsets.all(20.sdp),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.sdp),
                        border: Border.all(
                          color: AppColors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextView(
                            text: AppStrings.stillNeedHelp.tr,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.blackText,
                            ),
                          ),
                          12.height,
                          TextView(
                            text: AppStrings.stillNeedHelpDescription.tr,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.grey,
                              height: 1.4,
                            ),
                          ),
                          20.height,
                          Container(
                            width: double.infinity,
                            height: 50.sdp,
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Implement chatbot functionality
                                AppUtils.toast("Coming soon!");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.btnColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.sdp),
                                ),
                                elevation: 0,
                              ),
                              child: TextView(
                                text: AppStrings.chatbotAI.tr,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    20.height, // Bottom spacing
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;
  final bool isExpanded;
  final bool showFullAnswer;

  FAQItem({
    required this.question,
    required this.answer,
    this.isExpanded = false,
    this.showFullAnswer = false,
  });

  FAQItem copyWith({bool? isExpanded, bool? showFullAnswer}) {
    return FAQItem(
      question: question,
      answer: answer,
      isExpanded: isExpanded ?? this.isExpanded,
      showFullAnswer: showFullAnswer ?? this.showFullAnswer,
    );
  }
}

class FAQTile extends StatefulWidget {
  final FaqItemModel item;

  const FAQTile({Key? key, required this.item}) : super(key: key);

  @override
  _FAQTileState createState() => _FAQTileState();
}

class _FAQTileState extends State<FAQTile> {
  Rx<FaqItemModel?> item = Rx(null);

  @override
  void initState() {
    super.initState();
    item.value = widget.item;
  }

  void toggleExpanded() {
    item.value = item.value?.copyWith(
      isExpanded: !(item.value?.isExpanded ?? false),
    );
    item.refresh();
  }

  void toggleFullAnswer() {
    item.value = item.value?.copyWith(
      showFullAnswer: !(item.value?.showFullAnswer ?? false),
      isExpanded: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      bool hasMoreText = (item.value?.answer?.length ?? 0) > 150;
      String previewText = hasMoreText
          ? "${item.value?.answer?.substring(0, 150) ?? ''}..."
          : (item.value?.answer ?? '');

      return Container(
        margin: EdgeInsets.only(bottom: 8.sdp),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(0),
          border: Border(
            bottom: BorderSide(
              color: AppColors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: toggleExpanded,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.sdp,
                  vertical: 16.sdp,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextView(
                        text: item.value?.question ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.blackText,
                        ),
                      ),
                    ),
                    Container(
                      width: 24.sdp,
                      height: 24.sdp,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (item.value?.isExpanded ?? false)
                            ? AppColors.btnColor
                            : AppColors.btnColor,
                      ),
                      child: Icon(
                        (item.value?.isExpanded ?? false)
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 18.sdp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (item.value?.isExpanded ?? false) ...[
              Padding(
                padding: EdgeInsets.only(
                  left: 16.sdp,
                  right: 16.sdp,
                  bottom: 16.sdp,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (item.value?.showFullAnswer ?? false) || !hasMoreText
                            ? (item.value?.answer ?? '')
                            : previewText,
                        style: TextStyle(
                          color: AppColors.grey.withOpacity(0.8),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      if (hasMoreText) ...[
                        8.height,
                        InkWell(
                          onTap: toggleFullAnswer,
                          child: TextView(
                            text: (item.value?.showFullAnswer ?? false)
                                ? AppStrings.readLess.tr
                                : AppStrings.readMore.tr,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.btnColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}
