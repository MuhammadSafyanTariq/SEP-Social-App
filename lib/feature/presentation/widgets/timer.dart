import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/utils/extensions/size.dart';

enum PollState { notStarted, inProgress, complete }

class CountdownTimer extends StatefulWidget {
  final DateTime startTime;
  final DateTime endTime;
  final ValueChanged<bool> onPollEnded; // Callback to notify poll end
  final Color? countdownColor; // New field for dynamic color

  const CountdownTimer({
    Key? key,
    required this.startTime,
    required this.endTime,
    required this.onPollEnded,
    this.countdownColor, // Optional color parameter
  }) : super(key: key);

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Duration duration;
  Timer? timer;
  PollState pollState = PollState.notStarted;

  @override
  void initState() {
    super.initState();
    updateDuration();
    timer = Timer.periodic(const Duration(seconds: 1), (_) => updateTimer());
  }

  void updateDuration() {
    DateTime now = DateTime.now();
    DateTime localStartTime = widget.startTime.toLocal();
    DateTime localEndTime = widget.endTime.toLocal();

    if (now.isBefore(localStartTime)) {
      duration = localStartTime.difference(now);
      changePollState(PollState.notStarted);
    } else if (now.isAfter(localStartTime) && now.isBefore(localEndTime)) {
      duration = localEndTime.difference(now);
      changePollState(PollState.inProgress);
    } else {
      duration = Duration.zero;
      changePollState(PollState.complete);
      timer?.cancel();
    }
  }

  void updateTimer() {
    if (!mounted) return;

    setState(() {
      DateTime now = DateTime.now();
      if (now.isBefore(widget.startTime)) {
        duration = widget.startTime.difference(now);
        changePollState(PollState.notStarted);
      } else if (now.isAfter(widget.startTime) &&
          now.isBefore(widget.endTime)) {
        duration = widget.endTime.difference(now);
        changePollState(PollState.inProgress);
      } else {
        duration = Duration.zero;
        changePollState(PollState.complete);
        timer?.cancel();
      }
    });
  }

  void changePollState(PollState newState) {
    if (pollState != newState) {
      pollState = newState;
      widget.onPollEnded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildCountdownDisplay();
  }

  Widget buildCountdownDisplay() {
    int days = duration.inDays;
    int hours = duration.inHours % 24;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildTimeBox(days, "Days"),
        buildSeparator(),
        buildTimeBox(hours, "Hours"),
        buildSeparator(),
        buildTimeBox(minutes, "Minutes"),
        buildSeparator(),
        buildTimeBox(seconds, "Seconds"),
      ],
    );
  }

  Widget buildSeparator() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 5),
    child: Text(
      ":",
      style: TextStyle(
        fontSize: 24,
        color: Colors.grey,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget buildTimeBox(int value, String label) {
    return Column(
      children: [
        Container(
          width: 42.sdp,
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[400]!, width: 1.5),
          ),
          child: Center(
            child: Column(
              children: [
                Text(
                  value.toString().padLeft(2, '0'),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 7,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
