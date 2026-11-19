import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // A push that arrives while the app is open goes to the app delegate,
    // which hands it to every plugin: Firebase shows it as a banner (see
    // `setForegroundNotificationPresentationOptions`) and tells the app
    // (`onMessage`). Without this, nothing is set up to take it until
    // Firebase sets itself up late — the plugins register only once the
    // scene's engine starts — and a push while the app is open is lost.
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
