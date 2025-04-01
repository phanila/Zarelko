import Flutter
import UIKit

import flutter_local_notifications
import workmanager

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // This is required to make any communication available in the action isolate.
     FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
       GeneratedPluginRegistrant.register(with: registry)
     }

    GeneratedPluginRegistrant.register(with: self)

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    WorkmanagerPlugin.registerBGProcessingTask(withIdentifier: "task-identifier")
    WorkmanagerPlugin.registerPeriodicTask(withIdentifier: "be.tramckrijte.workmanagerExample.iOSBackgroundAppRefresh", frequency: NSNumber(value: 20 * 60))

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
