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


    StripeAPI.defaultPublishableKey = "pk_live_51RQkfPF7GWl0gz6oggK8qEi9q8HgBJeZzneF9utkZXsReup0jHbiN9QXF0XqRhYUOFMqoaF0WdA28Gsifyx9esKO00cznRBhbr"
    

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
