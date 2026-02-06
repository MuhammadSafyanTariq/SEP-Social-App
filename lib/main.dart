import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sep/services/networking/urls.dart';
import 'package:sep/services/deep_link_service.dart';
import 'package:sep/translations.dart';
import 'package:sep/utils/extensions/loaderUtils.dart';
import 'feature/presentation/controller/auth_Controller/auth_ctrl.dart';
import 'feature/presentation/controller/auth_Controller/get_stripe_ctrl.dart';
import 'feature/presentation/controller/auth_Controller/networkCtrl.dart';
import 'feature/presentation/controller/auth_Controller/profileCtrl.dart';
import 'feature/presentation/controller/language_controller.dart';
import 'feature/presentation/screens/loginsignup/onBoarding/language.dart';
import 'feature/presentation/Home/homeScreen.dart';
import 'services/storage/preferences.dart';
import 'services/firebaseServices.dart';
import 'utils/extensions/contextExtensions.dart';
import 'utils/appUtils.dart';
import 'utils/gpu_error_handler.dart';

final GlobalKey<NavigatorState> navState = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up global error handler for GPU device lost errors
  FlutterError.onError = (FlutterErrorDetails details) {
    // Handle GPU errors through our handler
    final wasGpuError = GpuErrorHandler.instance.isGpuDeviceLost;
    GpuErrorHandler.instance.handleFlutterError(details);
    
    // Only present error if it wasn't a GPU error (GPU errors are suppressed)
    if (!wasGpuError || !GpuErrorHandler.instance.isGpuDeviceLost) {
      FlutterError.presentError(details);
    }
  };

  // Lock orientation to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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

  // Initialize Deep Link Service
  await DeepLinkService.instance.initialize(navigatorKey: navState);

  final engine = createAgoraRtcEngine();
  await engine.initialize(RtcEngineContext(appId: agoraAppId));

  MobileAds.instance.initialize();

  Stripe.publishableKey =
      "pk_live_51RQkfPF7GWl0gz6oggK8qEi9q8HgBJeZzneF9utkZXsReup0jHbiN9QXF0XqRhYUOFMqoaF0WdA28Gsifyx9esKO00cznRBhbr";
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
            home: const InitialScreen(),
          );
        }),
      ),
    );
  }
}

/// Initial screen that handles navigation without showing Flutter splash UI
/// Shows home screen with loading spinner instead of white screen
class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  bool _shouldShowHome = false;

  @override
  void initState() {
    super.initState();
    // Defer navigation until after first frame so Navigator is ready (avoids _debugLocked assertion)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndNavigate();
    });
  }

  void _initializeAndNavigate() async {
    // Initialize Firebase (same as Splash widget)
    try {
      await FirebaseServices.init(context);
      // Don't await listener to avoid blocking navigation
      FirebaseServices.listener().catchError((e) {
        AppUtils.log('Firebase listener error: $e');
      });
    } catch (e) {
      AppUtils.log('Firebase init error: $e');
    }

    // Show home screen immediately
    if (!mounted) return;
    
    setState(() {
      _shouldShowHome = Preferences.authToken != null;
    });

    // Small delay to ensure Flutter renders first frame and dismisses native splash
    await Future.delayed(const Duration(milliseconds: 300));

    // Navigate if needed (only if not showing home)
    if (!mounted) return;
    
    if (!_shouldShowHome) {
      context.pushAndClearNavigator(Language());
    }
  }

  @override
  Widget build(BuildContext context) {
    // If user is logged in, show home screen directly (it handles its own loading states)
    if (_shouldShowHome) {
      return const HomeScreen();
    }
    
    // While checking login status, show loading spinner
    return Scaffold(
      backgroundColor: Colors.white,
      body: const Center(
        child: CircularProgressIndicator(),
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
