import Foundation
import UserNotifications

/// Manages local notifications for security alerts
class NotificationManager: NSObject, ObservableObject {
    
    @Published var hasPermissions: Bool = false
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        notificationCenter.delegate = self
        checkPermissions()
    }
    
    /// Request notification permissions from the user
    func requestPermissions() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.hasPermissions = granted
            }
            
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    /// Check current notification permissions
    private func checkPermissions() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.hasPermissions = settings.authorizationStatus == .authorized
            }
        }
    }
    
    /// Send a security alert notification
    func sendSecurityAlert(for event: NetworkEvent) {
        guard hasPermissions else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Security Alert"
        content.body = event.description
        content.sound = .default
        content.badge = 1
        
        // Add threat level to category
        content.categoryIdentifier = "SECURITY_ALERT"
        
        // Set user info for handling
        content.userInfo = [
            "eventId": event.id.uuidString,
            "threatLevel": event.threatLevel.rawValue,
            "timestamp": event.timestamp.timeIntervalSince1970
        ]
        
        // Create request with unique identifier
        let request = UNNotificationRequest(
            identifier: event.id.uuidString,
            content: content,
            trigger: nil // Immediate delivery
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error)")
            }
        }
    }
    
    /// Send a critical threat notification
    func sendCriticalAlert(for anomaly: NetworkAnomaly) {
        guard hasPermissions else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🚨 Critical Security Threat"
        content.body = anomaly.description
        content.sound = .default
        content.badge = 1
        
        content.categoryIdentifier = "CRITICAL_ALERT"
        
        content.userInfo = [
            "anomalyId": anomaly.id.uuidString,
            "anomalyType": anomaly.anomalyType.rawValue,
            "severity": anomaly.severity.rawValue,
            "confidence": anomaly.confidence
        ]
        
        let request = UNNotificationRequest(
            identifier: anomaly.id.uuidString,
            content: content,
            trigger: nil
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to send critical notification: \(error)")
            }
        }
    }
    
    /// Schedule a periodic status notification
    func scheduleStatusNotification() {
        guard hasPermissions else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Stingray Warning"
        content.body = "Security monitoring is active"
        content.sound = .default
        
        // Schedule for 24 hours from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 86400, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "STATUS_UPDATE",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule status notification: \(error)")
            }
        }
    }
    
    /// Cancel all pending notifications
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    /// Cancel specific notification
    func cancelNotification(withIdentifier identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .badge, .sound])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        // Handle notification tap
        if let eventId = userInfo["eventId"] as? String {
            handleEventNotificationTap(eventId: eventId)
        } else if let anomalyId = userInfo["anomalyId"] as? String {
            handleAnomalyNotificationTap(anomalyId: anomalyId)
        }
        
        completionHandler()
    }
    
    private func handleEventNotificationTap(eventId: String) {
        // Navigate to event details
        print("Tapped notification for event: \(eventId)")
    }
    
    private func handleAnomalyNotificationTap(anomalyId: String) {
        // Navigate to anomaly details
        print("Tapped notification for anomaly: \(anomalyId)")
    }
}
