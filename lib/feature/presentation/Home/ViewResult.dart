import 'package:flutter/material.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/textStyle.dart';
import 'package:sep/utils/extensions/widget.dart';

import '../../../components/coreComponents/ImageView.dart';
import '../../../components/coreComponents/TextView.dart';
import '../../../components/styles/appColors.dart';
import '../../../components/styles/appImages.dart';
import '../../data/models/dataModels/post_data.dart';
import 'homeScreenComponents/pollCard.dart';


class ViewResult extends StatefulWidget {
  final List<Option> options;
  final List<Vote> votes;
  const ViewResult({
    super.key,
    required this.options,
    required this.votes,
  });

  @override
  State<ViewResult> createState() => _ViewResultState();
}

class _ViewResultState extends State<ViewResult> {
  @override
  Widget build(BuildContext context) {

    final int totalVotes = widget.votes.length;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        elevation: 0,
        leading: GestureDetector(
            onTap: () {
              context.pop();
            },
            child: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor, size: 20)),
        centerTitle: true,
        title: Text("Poll Result", style: 18.txtMediumPrimary),
        backgroundColor: AppColors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17.0, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              20.height,
              // TextView(text: "Who would you like to vote for?", style: 18.txtMediumPrimary),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextView(text: "Winner :${widget.options.first.name} ", style: 40.txtMediumPrimary,margin: 10.top + 30.bottom,),
                ],
              ),
              20.height,
              Center(child: ImageView(url: AppImages.winner, size: 125)),
              45.height,
              // Column(
              //   children: widget.options.map((option) {
              //     return Column(
              //       children: [
              //         PollOptionCard(
              //           data: option,
              //           totalVoteCounts: totalVotes,
              //           voteList: widget.votes,
              //           isPollEnded: true,
              //           onPollAction: null,
              //         ),
              //         20.height,
              //       ],
              //     );
              //   }).toList(),
              // ),
              40.height,
            ],
          ),
        ),
      ),

    );
  }
}
