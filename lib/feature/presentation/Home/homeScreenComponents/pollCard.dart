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
  bool showResults = false;

  DateTime get getCloseTime =>
      (widget.data.createdAt.localDateTime ?? DateTime.now()).add(
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

  @override
  void didUpdateWidget(PollCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload selected option when widget data updates (e.g., after voting)
    if (oldWidget.data.id != widget.data.id ||
        oldWidget.data.votes.length != widget.data.votes.length) {
      loadSelectedOption();
    }
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
    
    // Check if user already voted for this option
    final alreadyVotedForThisOption = widget.data.votes.any(
      (vote) => vote.userId == Preferences.uid && vote.optionId == optionId,
    );
    
    if (alreadyVotedForThisOption) {
      // User already voted for this option, don't allow deselection
      AppUtils.log("Already voted for this option - ignoring click");
      AppUtils.toast("You've already voted for this option");
      return;
    }
    
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
    // Load the selected option from the vote data returned by backend
    final voteList = widget.data.votes;
    final userVote = voteList.firstWhere(
      (vote) => vote.userId == Preferences.uid,
      orElse: () => const Vote(),
    );
    
    if (userVote.optionId != null && userVote.optionId!.isNotEmpty) {
      selectedOptionId = userVote.optionId;
      hasSelected = true;
    } else {
      selectedOptionId = null;
      hasSelected = false;
    }
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
                      'Cast your vote and share your perspective in the comments. Community guidelines apply to all discussions.',
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

                  // Find the option with the highest vote count
                  int maxVoteCount = widget.data.options.fold(
                    0,
                    (max, option) => (option.voteCount ?? 0) > max
                        ? (option.voteCount ?? 0)
                        : max,
                  );

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
                      isLeading:
                          (widget.data.options[index].voteCount ?? 0) ==
                              maxVoteCount &&
                          maxVoteCount > 0,
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
                          child: GestureDetector(
                            onTap: () {
                              context.pushNavigator(ShowPollScreen());
                            },
                            child: Container(
                              margin: const EdgeInsets.only(left: 5, right: 20),
                              child: Icon(
                                Icons.poll,
                                color: AppColors.greynew,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : pollState.value == PollState.notStarted
                ? SizedBox()
                : getPollState == PollState.complete
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        showResults = !showResults;
                      });
                    },
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 600),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return AnimatedBuilder(
                              animation: animation,
                              child: child,
                              builder: (context, child) {
                                final isShowingResults =
                                    child!.key == ValueKey(true);
                                final rotationValue = isShowingResults
                                    ? animation.value
                                    : 1.0 - animation.value;
                                return Transform(
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001)
                                    ..rotateY(3.14159 * rotationValue),
                                  alignment: Alignment.center,
                                  child: child,
                                );
                              },
                            );
                          },
                      child: showResults
                          ? Transform(
                              key: ValueKey(true),
                              alignment: Alignment.center,
                              transform: Matrix4.rotationY(3.14159),
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    center: Alignment.center,
                                    radius: 1.5,
                                    colors: [
                                      Color(0xFF2A1810),
                                      Color(0xFF1A1410),
                                      Color(0xFF0A0A0A),
                                    ],
                                    stops: [0.0, 0.5, 1.0],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Color(0xFFD4AF37).withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFFD4AF37).withOpacity(0.1),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    // Trophy Image with glow
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(
                                              0xFFD4AF37,
                                            ).withOpacity(0.4),
                                            blurRadius: 30,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: ImageView(
                                        url: AppImages.winnerImg,
                                        height: 100,
                                        width: 100,
                                      ),
                                    ),

                                    SizedBox(height: 12),

                                    // Winner Name
                                    Text(
                                      winner != null
                                          ? "${winner.name}"
                                          : "No winner yet",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFFD4AF37),
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                        shadows: [
                                          Shadow(
                                            color: Color(
                                              0xFFD4AF37,
                                            ).withOpacity(0.5),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 15),

                                    // Result Card
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(
                                          0xFF1A1410,
                                        ).withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Color(
                                            0xFFD4AF37,
                                          ).withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            'Thank you for playing',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Color(0xFFD4AF37),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Container(
                                            height: 1,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.transparent,
                                                  Color(
                                                    0xFFD4AF37,
                                                  ).withOpacity(0.3),
                                                  Colors.transparent,
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'Results are for\nentertainment purposes only',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Color(0xFFB8A070),
                                              fontSize: 11,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              key: ValueKey(false),
                              margin: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF2A1810),
                                    Color(0xFF1A1410),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Color(0xFFD4AF37).withOpacity(0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFD4AF37).withOpacity(0.15),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Color(
                                        0xFFD4AF37,
                                      ).withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.emoji_events,
                                      size: 32,
                                      color: Color(0xFFD4AF37),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Poll Has Ended',
                                          style: TextStyle(
                                            color: Color(0xFFD4AF37),
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Tap to view results',
                                          style: TextStyle(
                                            color: Color(0xFFB8A070),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFFD4AF37),
                                    size: 28,
                                  ),
                                ],
                              ),
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
  final bool isLeading;

  const PollOptionCard({
    Key? key,
    required this.data,
    required this.totalVoteCounts,
    required this.onPollAction,
    required this.voteList,
    required this.isPollEnded,
    this.isLeading = false,
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

  Color get color {
    if (isLeading && isPollEnded) {
      return AppColors.greenlight; // Green for leading option when poll ended
    } else if (isSelected) {
      return AppColors.btnColor; // Selected color for user's choice
    } else {
      return AppColors.greynew; // Default grey
    }
  }

  BoxDecoration decoration(Color bgColor, Color borderColor) => BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: borderColor, width: 1),
    color: bgColor,
  );

  double get getPercentage {
    if (totalVoteCounts == 0) return 0.0;
    return (data.voteCount ?? 0) / totalVoteCounts;
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (getPercentage * 100).toStringAsFixed(1);

    return GestureDetector(
      onTap: !isPollEnded
          ? () {
              if (data.id == null || data.id!.isEmpty) {
                AppUtils.log("ERROR: Option ID null. Data: ${data.toJson()}");
                AppUtils.toastError("Poll option missing ID - contact support");
                return;
              }
              // Prevent voting again if already voted for this option
              if (isSelected) {
                AppUtils.toast("You've already voted for this option");
                return;
              }
              onPollAction?.call(data.id!);
            }
          : null,
      child: Container(
        decoration: decoration(Colors.white, color),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                    margin: const EdgeInsets.only(right: 10),
                  ),
                ),
                Expanded(
                  child: Text(
                    data.name ?? '',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
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
                        isSelected ? 'Voted' : 'Vote',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                SizedBox(width: 10),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: getPercentage,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
