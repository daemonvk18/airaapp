import UIKit
import Flutter

//add a bit of code to allow notifications
import flutter_local_notifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    //add this...
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback {(registry) in 
    GeneratedPluginRegistrant.register(with:registry)}

    GeneratedPluginRegistrant.register(with: self)

    //add this as well...
    if #available(iOS 10.0, *) {
  UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
