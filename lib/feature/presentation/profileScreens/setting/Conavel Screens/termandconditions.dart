// import 'package:flutter/material.dart';
// import 'package:sep/components/styles/textStyles.dart';
// import 'package:sep/components/coreComponents/TextView.dart';
// import 'package:sep/components/styles/appColors.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:sep/feature/data/repository/iTempRepository.dart';
// import 'package:sep/feature/domain/respository/templateRepository.dart';
// import 'package:sep/utils/extensions/extensions.dart';
//
// import '../../../../data/models/dataModels/responseDataModel.dart';
// import '../../../../data/models/dataModels/termsConditionModel.dart';
// import '../../../../data/repository/iAuthRepository.dart';
//
// class Termandconditions extends StatefulWidget {
//   const Termandconditions({super.key});
//
//   @override
//   _TermandconditionsState createState() => _TermandconditionsState();
// }
//
// class _TermandconditionsState extends State<Termandconditions> {
//   late Future<ResponseData<TermsConditionModel>> _termsFuture;
//   final TempRepository tempRepository = ITempRepository();
//   String? description;
//
//   Future<ResponseData<TermsConditionModel>> _fetchTerms() async {
//     return await tempRepository.getTermsAndCondations();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _termsFuture = _fetchTerms();
//     _termsFuture.applyLoader.then((value) {
//       setState(() {
//         description = value.data!.data!.description;
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.primaryColor,
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryColor,
//         centerTitle: true,
//         title: TextView(
//           text: 'Terms of Use',
//           style: 20.txtBoldWhite,
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new,
//               color: AppColors.white, size: 20),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 22.0),
//         child: TextView(
//           text: description.toString() != "null" ? description.toString() : " ",
//           style: 14.txtRegularWhite,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:sep/components/coreComponents/AppBar2.dart';
import 'package:sep/components/styles/appColors.dart';
import 'package:sep/utils/extensions/size.dart';
import 'package:sep/utils/extensions/textStyle.dart';

import '../../../../../utils/extensions/loaderUtils.dart';

class Termandconditions extends StatefulWidget {
  const Termandconditions({super.key});

  @override
  _TermandconditionsState createState() => _TermandconditionsState();
}

class _TermandconditionsState extends State<Termandconditions> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            LoaderUtils.show();
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            LoaderUtils.dismiss();
          },
          onHttpError: (HttpResponseError error) {
            LoaderUtils.dismiss();
          },
          onWebResourceError: (WebResourceError error) {
            LoaderUtils.dismiss();
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse("https://septerms.vercel.app/"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          AppBar2(
            title: "Terms of Use",
            titleStyle: 18.txtMediumBlack,
            prefixImage: "back",
            onPrefixTap: () => Navigator.pop(context),
            backgroundColor: Colors.white,
            hasTopSafe: true,
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.all(16.sdp),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.sdp),
                border: Border.all(
                  color: AppColors.grey.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.sdp),
                child: WebViewWidget(controller: _controller),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
