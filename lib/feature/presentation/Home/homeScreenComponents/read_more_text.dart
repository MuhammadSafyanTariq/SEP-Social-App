import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:get/get.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:shimmer/shimmer.dart';

class ReadMoreText extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final int maxLines;

  const ReadMoreText({
    Key? key,
    required this.text,
    this.textStyle,
    this.maxLines = 3,
  }) : super(key: key);

  @override
  _ReadMoreTextState createState() => _ReadMoreTextState();
}

class _ReadMoreTextState extends State<ReadMoreText> {
  bool isExpanded = false;
  bool showReadMore = false;
  Map<String, PreviewData> previewDataMap = {};
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    final isUrl = widget.text.isURL;

    if (isUrl) {
      return Container(
        margin: 8.vertical,
        decoration: BoxDecoration(
          color: const Color(0xfff7f7f8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinkPreview(
            enableAnimation: true,
            onPreviewDataFetched: (data) {
              setState(() {
                previewDataMap = {...previewDataMap, widget.text: data};
              });
            },
            previewData: previewDataMap[widget.text],
            text: widget.text,
            width: MediaQuery.of(context).size.width,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: widget.text,
            style: widget.textStyle ?? 14.txtRegularBlack,
          ),
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        showReadMore = textPainter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: widget.textStyle ?? 14.txtRegularBlack,
              maxLines: isExpanded ? null : widget.maxLines,
              overflow: isExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            ),
            if (showReadMore)
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    isExpanded ? "Read Less" : "Read More",
                    style: (widget.textStyle ?? 14.txtRegularbtncolor).copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
