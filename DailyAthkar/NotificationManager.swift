//
//  NotificationManager.swift
//  DailyAthkar
//
//  Native UNUserNotificationCenter scheduling (replaces DLLocalNotifications)
//

import UserNotifications

enum NotificationManager {
    static func scheduleReminders(localized: @escaping (String) -> String) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            center.removeAllPendingNotificationRequests()

            // Morning - 7:30 AM
            schedule(
                id: "morning",
                title: localized("morning alert"),
                body: localized("morning alert body"),
                hour: 7, minute: 30
            )

            // Evening - 5:30 PM
            schedule(
                id: "evening",
                title: localized("evening alert"),
                body: localized("evening alert body"),
                hour: 17, minute: 30
            )
        }
    }

    private static func schedule(id: String, title: String, body: String, hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
