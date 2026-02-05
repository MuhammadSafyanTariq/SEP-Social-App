import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:get/get.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/appUtils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // Check if entire text is a URL
  bool _isEntireTextUrl(String text) {
    final trimmed = text.trim();
    final urlPattern = RegExp(
      r'^https?:\/\/[^\s]+$',
      caseSensitive: false,
    );
    return urlPattern.hasMatch(trimmed);
  }

  // Parse text and extract URLs, returning TextSpans with clickable links
  List<TextSpan> _parseTextWithLinks(String text) {
    final RegExp linkRegExp = RegExp(
      r'(https?:\/\/[^\s]+)',
      caseSensitive: false,
    );
    final List<TextSpan> spans = [];
    final matches = linkRegExp.allMatches(text);

    int start = 0;
    for (final Match match in matches) {
      // Add text before the link
      if (match.start > start) {
        spans.add(TextSpan(
          text: text.substring(start, match.start),
          style: widget.textStyle ?? 14.txtRegularBlack,
        ));
      }

      // Add clickable link
      final String url = match.group(0)!;
      spans.add(
        TextSpan(
          text: url,
          style: (widget.textStyle ?? 14.txtRegularBlack).copyWith(
            color: Colors.blueAccent,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              try {
                final Uri uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              } catch (e) {
                // Handle error silently or show a toast
                AppUtils.log('Error launching URL: $e');
              }
            },
        ),
      );

      start = match.end;
    }

    // Add remaining text after the last link
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: widget.textStyle ?? 14.txtRegularBlack,
      ));
    }

    // If no links found, return a single TextSpan with the entire text
    if (spans.isEmpty) {
      spans.add(TextSpan(
        text: text,
        style: widget.textStyle ?? 14.txtRegularBlack,
      ));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    // Check if entire text is a URL (for link preview)
    final isEntireTextUrl = _isEntireTextUrl(widget.text);

    if (isEntireTextUrl) {
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

    // Parse text with links for clickable URLs
    final textSpans = _parseTextWithLinks(widget.text);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Check if text exceeds max lines
        final textPainter = TextPainter(
          text: TextSpan(
            children: textSpans,
            style: widget.textStyle ?? 14.txtRegularBlack,
          ),
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        showReadMore = textPainter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: textSpans,
                style: widget.textStyle ?? 14.txtRegularBlack,
              ),
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
