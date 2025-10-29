import 'package:flutter/material.dart';
import 'package:sep/components/coreComponents/ImageView.dart';
import 'package:sep/components/coreComponents/TextView.dart';
import 'package:sep/components/coreComponents/AppButton.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/components/styles/appImages.dart';
import 'package:sep/components/styles/textStyles.dart';
import 'package:sep/utils/extensions/contextExtensions.dart';
import 'package:sep/utils/extensions/extensions.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsWebViewScreen extends StatefulWidget {
  @override
  _TermsWebViewScreenState createState() => _TermsWebViewScreenState();
}

class _TermsWebViewScreenState extends State<TermsWebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted).applyLoader
      ..loadRequest(Uri.parse("https://septerms.vercel.app"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: ImageView(
          url: AppImages.backBtn,
          size: 25.sdp,
          onTap: () {
            context.pop();
          },
          margin: 15.top,
        ),
        elevation: 0,
        backgroundColor: AppColors.white,
        title: TextView(
          text: "Terms & Conditions",
          style: 20.txtSBoldprimary,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
          Padding(
            padding: EdgeInsets.all(16.sdp),
            child: AppButton(
              margin: 20.bottom,
              radius: 10,
              label: "Accept Terms of Use",
              labelStyle: 14.txtBoldBlack,
              onTap: () {
                context.pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
