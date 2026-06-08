import UserNotifications

class NotificationManager {

    static func requestPermission() {

        UNUserNotificationCenter.current()
            .requestAuthorization(
                options: [.alert, .badge, .sound]
            ) { granted, error in

                if granted {
                    print("Notification permission granted")
                } else {
                    print("Notification permission denied")
                }
            }
    }
}

