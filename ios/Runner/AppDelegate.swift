
import UIKit
import Flutter
import UserNotifications
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    // A push that arrives while the app is open goes to the app delegate,
    // which hands it to every plugin: Firebase shows it as a banner (see
    // `setForegroundNotificationPresentationOptions`) and tells the app
    // (`onMessage`). Without this, nothing is set up to take it until
    // Firebase sets itself up late — the plugins register only once the
    // scene's engine starts — and a push while the app is open is lost.
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        UNUserNotificationCenter.current().delegate = self

        let result = super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )

        application.registerForRemoteNotifications()

        return result
    }

    func didInitializeImplicitFlutterEngine(
        _ engineBridge: FlutterImplicitEngineBridge
    ) {
        GeneratedPluginRegistrant.register(
            with: engineBridge.pluginRegistry
        )
    }

    override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        print("✅ APNs token received")

        Messaging.messaging().apnsToken = deviceToken

        super.application(
            application,
            didRegisterForRemoteNotificationsWithDeviceToken: deviceToken
        )
    }

    override func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ APNs registration failed: \(error.localizedDescription)")

        super.application(
            application,
            didFailToRegisterForRemoteNotificationsWithError: error
        )
    }

    // Both must go on to `super`: FlutterAppDelegate hands them to the
    // plugins, and only then does Firebase tell the app — `onMessage` (Home
    // refreshes) and `onMessageOpenedApp` / `getInitialMessage` (a tap opens
    // the page the push is about). Answering iOS here instead would show the
    // banner, but the app would never hear of the push or the tap.
    // Firebase answers iOS itself, with what the app asked for in
    // `setForegroundNotificationPresentationOptions`.
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        Messaging.messaging().appDidReceiveMessage(notification.request.content.userInfo)
        super.userNotificationCenter(
            center,
            willPresent: notification,
            withCompletionHandler: completionHandler
        )
    }

    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        Messaging.messaging().appDidReceiveMessage(response.notification.request.content.userInfo)
        super.userNotificationCenter(
            center,
            didReceive: response,
            withCompletionHandler: completionHandler
        )
    }
}
