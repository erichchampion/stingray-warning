import Foundation
 

/// Centralized constants for the Stingray Warning app
struct AppConstants {
    
    // MARK: - Time Intervals
    struct TimeIntervals {
        static let second: TimeInterval = 1
        static let minute: TimeInterval = 60
        static let hour: TimeInterval = 3600
        static let day: TimeInterval = 86400
        static let week: TimeInterval = 604800
        static let month: TimeInterval = 2592000
        
        // App-specific intervals
        static let anomalyDetectionWindow: TimeInterval = 300 // 5 minutes
        static let backgroundProcessingDelay: TimeInterval = 15 * minute // 15 minutes
        static let backgroundRefreshDelay: TimeInterval = 5 * minute // 5 minutes
        static let statusNotificationInterval: TimeInterval = day // 24 hours
    }
    
    // MARK: - Data Limits
    struct Limits {
        static let maxRecentEvents = 1000
        static let maxStoredEvents = 2000
        static let maxStoredAnomalies = 1500
        static let rapidChangeThreshold = 3
        static let eventRetentionDays = 7
        static let maxRecentEventsForAnomalyDetection = 100
    }
    
    // MARK: - UserDefaults Keys
    struct UserDefaultsKeys {
        static let monitoringEnabled = "monitoringEnabled"
        static let networkBaseline = "NetworkBaseline"
        static let notificationEnabled = "notificationEnabled"
        static let backgroundMonitoringEnabled = "backgroundMonitoringEnabled"
        static let sensitivityLevel = "sensitivityLevel"
        static let expectedCarrierName = "expectedCarrierName"
        static let expectedMCC = "expectedMCC"
        static let expectedMNC = "expectedMNC"
        static let batteryOptimizationEnabled = "batteryOptimizationEnabled"
        static let dataRetentionDays = "dataRetentionDays"
        static let storedNetworkEvents = "StoredNetworkEvents"
        static let storedNetworkAnomalies = "StoredNetworkAnomalies"
        
        // Additional keys for testing
        static let autoStartMonitoring = "autoStartMonitoring"
        static let enableNotifications = "enableNotifications"
    }
    
    // MARK: - Background Task Identifiers
    struct BackgroundTaskIdentifiers {
        static let securityMonitoring = "us.defroster.stingraywarning.security-monitoring"
        static let backgroundRefresh = "us.defroster.stingraywarning.background-refresh"
    }
    
    // MARK: - Notification Identifiers
    struct NotificationIdentifiers {
        static let threatDetected = "threatDetected"
        static let statusUpdate = "statusUpdate"
        static let criticalAlert = "criticalAlert"
    }
    
    // MARK: - Threat Level Scoring
    struct ThreatScoring {
        static let twoGConnectionScore = 3
        static let rapidChangeScore = 2
        static let baselineMismatchScore = 1
        static let suspiciousCarrierScore = 4 // Base score for suspicious carriers
        
        static let noneThreshold = 0
        static let lowThreshold = 1
        static let mediumThreshold = 2
        static let highThreshold = 3
        static let criticalThreshold = 4
    }
    
    
    
    // MARK: - App Information
    struct AppInfo {
        static let version = "1.0.0"
        static let bundleIdentifier = "us.defroster.stingraywarning"
    }
}
