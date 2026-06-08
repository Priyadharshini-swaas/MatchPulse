//
//  MatchPulseApp.swift
//  MatchPulse
//
//  Created by Apple on 21/04/26.
//

//import SwiftUI
//
//@main
//struct MatchPulseApp: App {
//    var body: some Scene {
//        WindowGroup {
//            SplashScreen()
//        }
//    }
//}
import SwiftUI
import UserNotifications
import FirebaseCore
import FirebaseMessaging
import FirebaseCrashlytics
import FirebaseAnalytics
import AVFoundation

class AppDelegate: NSObject,
                   UIApplicationDelegate,
                   UNUserNotificationCenterDelegate,
                   MessagingDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        FirebaseApp.configure()
        Crashlytics.crashlytics().log("App Started")
        Messaging.messaging().delegate = self
//        Analytics.logEvent("app_test_event", parameters: [
//            "platform": "ios"
//        ])
        Analytics.logEvent("app_launch_info", parameters: [
            "device_name": UIDevice.current.model,
            "ios_version": UIDevice.current.systemVersion
        ])
UNUserNotificationCenter.current().delegate = self

        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in

            print("Permission granted: \(granted)")

            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }

        return true
    }

    // MARK: APNs Token

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {

        print("APNs Token Received")

        Messaging.messaging().apnsToken = deviceToken

        Messaging.messaging().token { token, error in

            if let error = error {
                print("FCM Error: \(error)")
                return
            }

            print("FCM Token:")
            print(token ?? "nil")
        }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {

        print("APNs Registration Failed")
        print(error.localizedDescription)
    }

    // MARK: FCM Token Refresh

    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {

        print("FCM Registration Token:")
        print(fcmToken ?? "nil")
    }

    // MARK: Foreground Notification

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void
    ) {

        completionHandler([.banner, .sound, .badge])
    }

    // MARK: Notification Tap

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler:
        @escaping () -> Void
    ) {

        let userInfo = response.notification.request.content.userInfo
        let title = response.notification.request.content.title

        print("Notification Clicked")
        print(userInfo)

        AnalyticsManager.logNotificationTapped(title: title)
        completionHandler()
    }
}
@main
 
struct MatchPulseApp: App {
    
    // register app delegate for Firebase setup
    
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    init() {
           configureAudioSession()
       }
    var body: some Scene {
        
        WindowGroup {
            
            NavigationView {
                
                SplashScreen()
                
            }
            
        }
        
    }
    private func configureAudioSession() {
          do {
              try AVAudioSession.sharedInstance().setCategory(
                  .playback,
                  mode: .moviePlayback,
                  options: []
              )

              try AVAudioSession.sharedInstance().setActive(true)
          } catch {
              print("Audio Session Error: \(error)")
          }
      }
}



