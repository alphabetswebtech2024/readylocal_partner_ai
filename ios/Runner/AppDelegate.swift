import Flutter
import GoogleMaps
import UIKit
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Same key as the Android manifest. Maps SDK for iOS must be enabled for it in Google Cloud.
    GMSServices.provideAPIKey("AIzaSyDT13KjoYrl2kDUeA5Tvx5G7cjMcU-JlaI")
    // Lets job alerts show while the app is open and report taps.
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
