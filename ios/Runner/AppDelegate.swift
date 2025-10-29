import Flutter
import UIKit
import Firebase
import Stripe

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {


    StripeAPI.defaultPublishableKey = "pk_test_51Re7gJQHPe7BrzsMAlHyRB8OStcbZbHn3Nin4vPB4g98y2oTRrADCrblJwzAYshE2Px1rsxxdnaKh7Mc1HSRUeR600qHFLanGd"
    

    GeneratedPluginRegistrant.register(with: self)
    

    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      if granted {
        print("Notification permission granted.")
        DispatchQueue.main.async {
          application.registerForRemoteNotifications()
        }
      } else {
        print("Notification permission denied.")
      }
    }

    UNUserNotificationCenter.current().delegate = self

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
