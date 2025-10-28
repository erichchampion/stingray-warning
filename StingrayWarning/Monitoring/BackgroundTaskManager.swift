import Foundation
import BackgroundTasks
import UIKit

/// Manages background tasks for continuous security monitoring
class BackgroundTaskManager: ObservableObject {
    
    private let backgroundTaskIdentifier = AppConstants.BackgroundTaskIdentifiers.securityMonitoring
    private let backgroundRefreshIdentifier = AppConstants.BackgroundTaskIdentifiers.backgroundRefresh
    
    @Published var isBackgroundTaskRegistered = false
    @Published var lastBackgroundExecution: Date?
    
    private weak var cellularMonitor: CellularSecurityMonitor?
    
    init() {
        registerBackgroundTasks()
    }
    
    /// Set the cellular monitor reference
    func setCellularMonitor(_ monitor: CellularSecurityMonitor) {
        self.cellularMonitor = monitor
    }
    
    /// Register background tasks with the system
    private func registerBackgroundTasks() {
        // Register BGProcessingTask for periodic security checks
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: backgroundTaskIdentifier,
            using: nil
        ) { [weak self] task in
            self?.handleBackgroundProcessing(task: task as! BGProcessingTask)
        }
        
        // Register BGAppRefreshTask for background app refresh
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: backgroundRefreshIdentifier,
            using: nil
        ) { [weak self] task in
            self?.handleBackgroundRefresh(task: task as! BGAppRefreshTask)
        }
        
        isBackgroundTaskRegistered = true
    }
    
    /// Schedule the next background processing task
    func scheduleBackgroundProcessing() {
        let request = BGProcessingTaskRequest(identifier: backgroundTaskIdentifier)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        request.earliestBeginDate = Date(timeIntervalSinceNow: AppConstants.TimeIntervals.backgroundProcessingDelay)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to schedule background processing: \(error)")
        }
    }
    
    /// Schedule the next background app refresh
    func scheduleBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundRefreshIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: AppConstants.TimeIntervals.backgroundRefreshDelay)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to schedule background refresh: \(error)")
        }
    }
    
    /// Handle background processing task
    private func handleBackgroundProcessing(task: BGProcessingTask) {
        // Schedule the next task
        scheduleBackgroundProcessing()
        
        // Set expiration handler
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        // Perform security check
        performBackgroundSecurityCheck { [weak self] success in
            self?.lastBackgroundExecution = Date()
            task.setTaskCompleted(success: success)
        }
    }
    
    /// Handle background app refresh task
    private func handleBackgroundRefresh(task: BGAppRefreshTask) {
        // Schedule the next refresh
        scheduleBackgroundRefresh()
        
        // Set expiration handler
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        // Perform quick security check
        performBackgroundSecurityCheck { [weak self] success in
            self?.lastBackgroundExecution = Date()
            task.setTaskCompleted(success: success)
        }
    }
    
    /// Perform security check in background
    private func performBackgroundSecurityCheck(completion: @escaping (Bool) -> Void) {
        guard let monitor = cellularMonitor else {
            completion(false)
            return
        }
        
        // Perform security check
        monitor.performSecurityCheck()
        
        // Simulate some processing time
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2.0) {
            completion(true)
        }
    }
    
    /// Cancel all scheduled background tasks
    func cancelAllBackgroundTasks() {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: backgroundTaskIdentifier)
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: backgroundRefreshIdentifier)
    }
    
    /// Check if background app refresh is enabled
    var isBackgroundAppRefreshEnabled: Bool {
        return UIApplication.shared.backgroundRefreshStatus == .available
    }
    
    /// Get background refresh status description
    var backgroundRefreshStatusDescription: String {
        switch UIApplication.shared.backgroundRefreshStatus {
        case .available:
            return "Available"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        @unknown default:
            return "Unknown"
        }
    }
}

// MARK: - Background Task Extensions
extension BackgroundTaskManager {
    
    /// Start background monitoring
    func startBackgroundMonitoring() {
        guard isBackgroundAppRefreshEnabled else {
            return
        }
        
        scheduleBackgroundProcessing()
        scheduleBackgroundRefresh()
    }
    
    /// Stop background monitoring
    func stopBackgroundMonitoring() {
        cancelAllBackgroundTasks()
    }
    
    /// Request background processing time for immediate execution
    func requestBackgroundProcessingTime(completion: @escaping (Bool) -> Void) {
        var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
        
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "Security Check") {
            // Clean up when task is about to expire
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
        
        // Perform the security check
        performBackgroundSecurityCheck { success in
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
            completion(success)
        }
    }
}
