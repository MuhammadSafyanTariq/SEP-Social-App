import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/translations.dart';
import 'package:sep/utils/extensions/loaderUtils.dart';
import 'feature/presentation/controller/auth_Controller/auth_ctrl.dart';
import 'feature/presentation/controller/auth_Controller/get_stripe_ctrl.dart';
import 'feature/presentation/controller/auth_Controller/networkCtrl.dart';
import 'feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'feature/presentation/controller/language_controller.dart';
import 'feature/presentation/screens/splash.dart';
import 'services/storage/preferences.dart';

final GlobalKey<NavigatorState> navState = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('Environment variables loaded successfully');
  } catch (e) {
    debugPrint('Failed to load .env file: $e');
  }

  await Preferences.createInstance();
  await Get.putAsync(() async => ProfileCtrl());
  Get.put(NetworkController());
  Get.put(AuthCtrl());
  Get.put(LanguageController());
  Get.put(GetStripeCtrl());

  final engine = createAgoraRtcEngine();
  await engine.initialize(RtcEngineContext(appId: agoraAppId));

  MobileAds.instance.initialize();

  Stripe.publishableKey =
      "pk_test_51RQkfbFQCwX9bvY7xnWoyU41vL46BxIb1hvKfGf5480FLG0bqeMyIi7LCVsPpHNLZHYxAUAy9hKErwCUm1FaGZkr00xxacT1Bv";
  // await Stripe.instance.applySettings();
  try {
    await Stripe.instance.applySettings();
  } catch (e) {
    debugPrint('Stripe initialization failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    return RefreshConfiguration(
      headerBuilder: () =>
          const WaterDropHeader(), // Configure the default header indicator. If you have the same header indicator for each page, you need to set this
      footerBuilder: () =>
          const ClassicFooter(), // Configure default bottom indicator
      headerTriggerDistance: 80.0, // header trigger refresh trigger distance
      springDescription: const SpringDescription(
        stiffness: 170,
        damping: 16,
        mass: 1.9,
      ), // custom spring back animate,the props meaning see the flutter api
      maxOverScrollExtent:
          100, //The maximum dragging range of the head. Set this property if a rush out of the view area occurs
      maxUnderScrollExtent: 0, // Maximum dragging range at the bottom
      enableScrollWhenRefreshCompleted:
          true, //This property is incompatible with PageView and TabBarView. If you need TabBarView to slide left and right, you need to set it to true.
      enableLoadingWhenFailed:
          true, //In the case of load failure, users can still trigger more loads by gesture pull-up.
      hideFooterWhenNotFull:
          false, // Disable pull-up to load more functionality when Viewport is less than one screen
      enableBallisticLoad: true,
      child: LoaderUtils.loaderInit(
        child: Obx(() {
          return GetMaterialApp(
            navigatorKey: navState,
            navigatorObservers: [ScreenTracker.instance],
            // onInit: (){
            //
            // },
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: false,
            ),
            translations: MyTranslations(),
            localizationsDelegates: const [
              // AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('fr', ''),
              Locale('es', ''),
              Locale('zh', ''),
              Locale('bn', ''),
            ],
            locale: languageController.locale,
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
            fallbackLocale: const Locale('en', 'US'),
            home: const Splash(),
          );
        }),
      ),
    );
  }
}

class ScreenTracker extends NavigatorObserver {
  static final ScreenTracker instance = ScreenTracker();
  Widget? currentScreen;

  @override
  void didPush(Route route, Route? previousRoute) {
    if (route is MaterialPageRoute) {
      currentScreen = route.builder(navState.currentContext!);
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (previousRoute is MaterialPageRoute) {
      currentScreen = previousRoute.builder(navState.currentContext!);
    }
    super.didPop(route, previousRoute);
  }
}
