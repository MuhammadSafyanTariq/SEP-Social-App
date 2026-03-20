import 'dart:io' show Platform;

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:facebook_app_events/facebook_app_events.dart';

/// Small wrapper around `facebook_app_events` to keep event calls centralized.
class FacebookAppEventsService {
  FacebookAppEventsService._();

  static final FacebookAppEventsService instance =
      FacebookAppEventsService._();

  final FacebookAppEvents _facebookAppEvents = FacebookAppEvents();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // iOS requires ATT permission before Meta can read IDFA for ad attribution.
    if (Platform.isIOS) {
      await AppTrackingTransparency.requestTrackingAuthorization();
    }

    _initialized = true;
  }

  /// Tracks app open/activation.
  ///
  /// Note: install + open events can also be handled automatically from the
  /// Meta Events Dashboard by enabling Automatic App Events.
  void logAppOpen() {
    _facebookAppEvents.logEvent(name: 'fb_mobile_activate_app');
  }

  /// Tracks in-app activity (screen views) as a custom Meta event.
  void logInAppActivity({required String screen}) {
    _facebookAppEvents.logEvent(
      name: 'InAppActivity',
      parameters: <String, dynamic>{
        'screen': screen,
      },
    );
  }

  /// Track a purchase/conversion event (call this after successful checkout).
  void logPurchase({required double value, required String currency}) {
    _facebookAppEvents.logEvent(
      name: 'purchase',
      parameters: <String, dynamic>{
        'value': value,
        'currency': currency,
      },
    );
  }

  /// Example subscription event (call after successful subscription).
  void logSubscribe() {
    _facebookAppEvents.logEvent(name: 'Subscribe');
  }

  /// Example registration event (call after successful signup/registration).
  void logCompleteRegistration() {
    _facebookAppEvents.logEvent(name: 'CompleteRegistration');
  }
}

