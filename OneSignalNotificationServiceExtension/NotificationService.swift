import UserNotifications

// TODO: Migrate OneSignal to native APNs - re-add OneSignal import after SPM migration
// import OneSignal

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        if let bestAttemptContent = bestAttemptContent {
            // TODO: Re-enable OneSignal processing
            // OneSignal.didReceiveNotificationExtensionRequest(request, with: bestAttemptContent)
            contentHandler(bestAttemptContent)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            // TODO: Re-enable OneSignal processing
            // OneSignal.serviceExtensionTimeWillExpireRequest(request, with: bestAttemptContent)
            contentHandler(bestAttemptContent)
        }
    }
    
}
