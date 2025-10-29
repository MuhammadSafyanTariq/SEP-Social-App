import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/show_poll_screen.dart';
import 'package:sep/services/storage/preferences.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import 'package:sep/utils/extensions/widget.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/post_card_header.dart';
import 'package:sep/feature/presentation/Home/homeScreenComponents/read_more_text.dart';
import '../../../../components/coreComponents/ImageView.dart';
import '../../../../components/styles/appColors.dart';
import '../../../../services/networking/urls.dart';
import '../../../data/models/dataModels/post_data.dart';
import '../../controller/auth_Controller/profileCtrl.dart';
import '../../widgets/timer.dart';

class PollCard extends StatefulWidget {
  final String question;
  final List<Option> options;
  final PostCardHeader header;
  final Widget footer;

  // final DateTime starttime;
  // final DateTime endtime;
  final PostData data;
  final Function(String) onPollAction;
  final bool showPollButton;

  const PollCard({
    Key? key,
    required this.question,
    required this.options,
    // required this.starttime,
    required this.header,
    // required this.endtime,
    required this.data,
    required this.onPollAction,
    required this.footer,
    this.showPollButton = true,
  }) : super(key: key);

  @override
  State<PollCard> createState() => _PollCardState();
}

enum PollState { initState, notStarted, inProgress, complete }

class _PollCardState extends State<PollCard> {
  final ProfileCtrl profileCtrl = Get.put(ProfileCtrl());

  Stream<DateTime> get timeStream => Stream<DateTime>.periodic(
    Duration(milliseconds: 500),
    (computationCount) => DateTime.now(),
  );

  Rx<PollState> pollState = Rx(PollState.initState);

  Duration duration = Duration.zero;
  Timer? timer;
  String? selectedOptionId;
  bool hasSelected = false;
  bool isCountdownActive = true;
  bool isPollEnded = false;

  DateTime get getCloseTime =>
      (widget.data.createdAt!.localDateTime ?? DateTime.now()).add(
        Duration(minutes: widget.data.duration ?? 0),
      );

  void initState() {
    super.initState();
    loadSelectedOption();
    DateTime currentTime = DateTime.now();
    AppUtils.log("Current Time: $currentTime");
    timeStream.listen((currentTime) {
      pollState.value = getPollState;
    });

    //AppUtils.log(widget.data.toJson());

    widget.data.duration ?? 0;

    // AppUtils.log('utc date :: ${widget.data.createdAt}');
    //
    //
    // String utcString = widget.data.createdAt!;
    // DateTime utcTime = DateTime.parse(utcString);
    // DateTime localTime = utcTime.toLocal();
    //
    // AppUtils.log('local date :: ${localTime}');
  }

  void updateTimer() {
    if (mounted && duration > Duration.zero) {
      duration -= const Duration(seconds: 1);
    } else {
      isCountdownActive = false;
      isPollEnded = true;
      print("Poll ended");
      timer?.cancel();
    }
  }

  void handleOptionSelected(String optionId) async {
    AppUtils.log(optionId);
    if (selectedOptionId == optionId) {
      // Deselecting the same option - don't call action
      selectedOptionId = null;
      hasSelected = false;
      AppUtils.log("Vote deselected - no action taken");
      return; // Don't proceed with null vote
    } else {
      selectedOptionId = optionId;
      hasSelected = true;
    }
    widget.onPollAction(selectedOptionId!);
  }

  Future<void> loadSelectedOption() async {
    hasSelected = selectedOptionId != null;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // DateTime? get startDate => widget.data.startTime?.yyyy_MM_ddTHH_mm_ss;

  // DateTime? get endDate => widget.data.endTime?.yyyy_MM_ddTHH_mm_ss;

  // bool get startTimeState => !endTimeState
  //     // (startDate?.isBefore(DateTime.now()) ?? false) ||
  //     // (startDate?.isAtSameMomentAs(DateTime.now()) ?? false)
  //
  // ;

  bool get endTimeState => getCloseTime.isAfter(DateTime.now());
  bool get isPollEndedNow => DateTime.now().isAfter(getCloseTime);

  PollState get getPollState {
    // if (!startTimeState) {
    //   return PollState.notStarted;
    // } else {
    //   if (endTimeState) {
    //     return PollState.inProgress;
    //   }
    //   return PollState.complete;
    // }

    if (endTimeState) {
      return PollState.inProgress;
    }
    return PollState.complete;
  }

  Color _getTimerColor() {
    final now = DateTime.now();
    final timeRemaining = getCloseTime.difference(now);

    if (timeRemaining.inMinutes > 60) {
      return AppColors.greenlight;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    var winner;
    if (getPollState == PollState.inProgress ||
        getPollState == PollState.complete) {
      winner = widget.data.options.reduce((a, b) {
        return (a.voteCount ?? 0) > (b.voteCount ?? 0) ? a : b;
      });
    }

    AppUtils.log("winner>>>>$winner");
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(10),
      color: Colors.white,
      child: Column(
        children: [
          widget.header,
          // TextView(text: '${widget.data.createdAt}',style: 20.txtMediumPrimary,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                ReadMoreText(text: widget.question),
                const SizedBox(height: 10),

                TextView(
                  text:
                      'Click on your choice and share your thoughts in the comments! Tap the image to expand. Play nice and Happy Polling!',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                  ),
                  margin: 5.bottom,
                ),

                // Poll options list
                Obx(() {
                  final ended =
                      pollState.value == PollState.complete || isPollEndedNow;
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => PollOptionCard(
                      voteList: widget.data.votes,
                      onPollAction: (value) {
                        if (pollState.value == PollState.inProgress) {
                          handleOptionSelected(value);
                        }
                      },
                      data: widget.data.options[index],
                      totalVoteCounts: totalCounts,
                      isPollEnded: ended,
                    ),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemCount: widget.data.options.length,
                  );
                }),
              ],
            ),
          ),

          // Timer moved up with improved design
          Obx(
            () => pollState.value == PollState.inProgress
                ? Container(
                    margin: EdgeInsets.only(top: 15, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 35),
                        Center(
                          child: CountdownTimer(
                            startTime: getCloseTime,
                            endTime: getCloseTime,
                            countdownColor: _getTimerColor(),
                            onPollEnded: (value) {
                              if (value) {
                                pollState.value = PollState.complete;
                              }
                            },
                          ),
                        ),
                        Visibility(
                          visible: widget.showPollButton,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: ImageView(
                            url: AppImages.poll,
                            tintColor: Colors.black,
                            size: 30,
                            margin: const EdgeInsets.only(right: 25),
                            onTap: () {
                              context.pushNavigator(ShowPollScreen());
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : pollState.value == PollState.notStarted
                ? SizedBox()
                : getPollState == PollState.complete
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Visibility(
                      visible: true,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ImageView(
                            url: AppImages.winnerImg,
                            height: 80,
                            width: 75,
                            margin: EdgeInsets.only(right: 10),
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextView(
                                  text: "WINNER:",
                                  style: 20.txtboldgreen,
                                  maxlines: null,
                                  overflow: TextOverflow.visible,
                                ),
                                TextView(
                                  text: winner != null
                                      ? "${winner.name}"
                                      : "No winner yet",
                                  style: 20.txtboldred,
                                  maxlines: null,
                                  overflow: TextOverflow.visible,
                                ),

                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextView(
                                            text: "THANK YOU FOR PLAYING!",
                                            style: 15.txtMediumPrimary,
                                          ),
                                          TextView(
                                            text:
                                                "RESULTS ARE FOR ENTERTAINMENT PURPOSES ONLY",
                                            style: 10.txtMediumPrimary,
                                            margin: EdgeInsets.only(bottom: 5),
                                            maxlines: null,
                                            overflow: TextOverflow.visible,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible: widget.showPollButton,
                                      child: ImageView(
                                        url: AppImages.poll,
                                        tintColor: AppColors.btnColor,
                                        size: 25,
                                        margin: 15.right,
                                        onTap: () {
                                          context.pushNavigator(
                                            ShowPollScreen(),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                //// old ui..........
                                Visibility(
                                  visible: false,
                                  child: SizedBox(
                                    height: 25,
                                    width: double.infinity,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.white,
                                                Colors.red,
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    3.5,
                                                  ),
                                                  child: ImageView(
                                                    url: AppImages.poll,
                                                    size: 15,
                                                    tintColor:
                                                        AppColors.primaryColor,
                                                  ),
                                                ),
                                                Text(
                                                  'VIEW MORE POLLS',
                                                  style: 12.txtMediumPrimary,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: widget.showPollButton,
                                          child: ImageView(
                                            url: AppImages.poll,
                                            tintColor: AppColors.btnColor,
                                            size: 25,
                                            margin: 15.right,
                                            onTap: () {
                                              context.pushNavigator(
                                                ShowPollScreen(),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ),

          Obx(
            () => TextView(
              text: pollState.value.name,
              style: TextStyle(color: Colors.transparent, fontSize: 1),
            ),
          ),

          // Minimalistic like and comment section moved to bottom of widget tree
          widget.footer,
        ],
      ),
    );
  }

  int get totalCounts {
    final options = widget.data.options;
    return options.fold(
      0,
      (previousValue, element) => previousValue + (element.voteCount ?? 0),
    );
  }
}

class PollOptionCard extends StatelessWidget {
  final Option data;
  final List<Vote> voteList;
  final int totalVoteCounts;
  final Function(String)? onPollAction;
  final bool isPollEnded;

  const PollOptionCard({
    Key? key,
    required this.data,
    required this.totalVoteCounts,
    required this.onPollAction,
    required this.voteList,
    required this.isPollEnded,
  }) : super(key: key);

  bool get isSelected {
    List<Vote> list = voteList;
    final index = list.indexWhere(
      (element) => element.userId == Preferences.uid,
    );
    if (index > -1) {
      return list[index].optionId == data.id;
    }
    return false;
  }

  Color get color => isSelected ? AppColors.btnColor : AppColors.greynew;

  BoxDecoration decoration(Color bgColor, Color borderColor) => BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: borderColor, width: 1),
    color: bgColor,
  );

  double get getPercentage {
    if (totalVoteCounts == 0) return 0.0;
    return (data.voteCount ?? 0) / totalVoteCounts;
  }

  String get getPercentageText {
    if (totalVoteCounts == 0) return '0%';
    final percentage = ((data.voteCount ?? 0) / totalVoteCounts * 100);
    return '${percentage.toStringAsFixed(0)}%';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: !isPollEnded
          ? () {
              if (data.id == null || data.id!.isEmpty) {
                AppUtils.log("ERROR: Option ID null. Data: ${data.toJson()}");
                AppUtils.toastError("Poll option missing ID - contact support");
                return;
              }
              onPollAction?.call(data.id!);
            }
          : null,
      child: Container(
        decoration: decoration(Colors.white, color),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Row with image, text, vote button, and percentage
            Row(
              children: [
                // Image
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierColor: Colors.black87,
                      builder: (context) {
                        return Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: const EdgeInsets.all(10),
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: PhotoView(
                                imageProvider: NetworkImage(
                                  data.image?.isNotEmpty == true
                                      ? '$baseUrl${data.image}'
                                      : '',
                                ),
                                backgroundDecoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: ImageView(
                    url: "$baseUrl${data.image}".isNotEmpty
                        ? '$baseUrl${data.image}'
                        : '',
                    fit: BoxFit.cover,
                    radius: 10,
                    fastLoading: true,
                    imageType: ImageType.network,
                    size: 50,
                    margin: const EdgeInsets.only(right: 12),
                  ),
                ),

                // Text
                Expanded(
                  child: Text(
                    data.name ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),

                // Vote Button
                if (!isPollEnded)
                  Container(
                    height: 40,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.grey.shade400
                          : AppColors.greenlight,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (isSelected
                                      ? Colors.grey.shade400
                                      : AppColors.greenlight)
                                  .withOpacity(0.3),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Vote',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(width: 12),

                // Percentage
                Text(
                  getPercentageText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isSelected ? AppColors.btnColor : Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: getPercentage,
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isSelected ? AppColors.btnColor : AppColors.greenlight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
