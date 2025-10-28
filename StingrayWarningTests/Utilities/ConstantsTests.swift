import XCTest
import CoreLocation
@testable import Stingray_Warning

/// Unit tests for AppConstants
class ConstantsTests: XCTestCase {
    
    // MARK: - Time Intervals Tests
    
    func testTimeIntervals() {
        // Given & When & Then
        XCTAssertEqual(AppConstants.TimeIntervals.second, 1)
        XCTAssertEqual(AppConstants.TimeIntervals.minute, 60)
        XCTAssertEqual(AppConstants.TimeIntervals.hour, 3600)
        XCTAssertEqual(AppConstants.TimeIntervals.day, 86400)
        XCTAssertEqual(AppConstants.TimeIntervals.week, 604800)
        XCTAssertEqual(AppConstants.TimeIntervals.month, 2592000)
    }
    
    func testTimeIntervalCalculations() {
        // Given & When & Then
        XCTAssertEqual(AppConstants.TimeIntervals.minute, AppConstants.TimeIntervals.second * 60)
        XCTAssertEqual(AppConstants.TimeIntervals.hour, AppConstants.TimeIntervals.minute * 60)
        XCTAssertEqual(AppConstants.TimeIntervals.day, AppConstants.TimeIntervals.hour * 24)
        XCTAssertEqual(AppConstants.TimeIntervals.week, AppConstants.TimeIntervals.day * 7)
        XCTAssertEqual(AppConstants.TimeIntervals.month, AppConstants.TimeIntervals.day * 30)
    }
    
    func testAppSpecificTimeIntervals() {
        // Given & When & Then
        XCTAssertEqual(AppConstants.TimeIntervals.anomalyDetectionWindow, 300) // 5 minutes
        XCTAssertEqual(AppConstants.TimeIntervals.backgroundProcessingDelay, 15 * AppConstants.TimeIntervals.minute) // 15 minutes
        XCTAssertEqual(AppConstants.TimeIntervals.backgroundRefreshDelay, 5 * AppConstants.TimeIntervals.minute) // 5 minutes
        XCTAssertEqual(AppConstants.TimeIntervals.statusNotificationInterval, AppConstants.TimeIntervals.day) // 24 hours
    }
    
    func testTimeIntervalConsistency() {
        // Given & When & Then
        XCTAssertGreaterThan(AppConstants.TimeIntervals.backgroundProcessingDelay, AppConstants.TimeIntervals.backgroundRefreshDelay)
        XCTAssertGreaterThan(AppConstants.TimeIntervals.statusNotificationInterval, AppConstants.TimeIntervals.anomalyDetectionWindow)
        XCTAssertGreaterThan(AppConstants.TimeIntervals.day, AppConstants.TimeIntervals.hour)
        XCTAssertGreaterThan(AppConstants.TimeIntervals.hour, AppConstants.TimeIntervals.minute)
        XCTAssertGreaterThan(AppConstants.TimeIntervals.minute, AppConstants.TimeIntervals.second)
    }
    
    // MARK: - Limits Tests
    
    func testDataLimits() {
        // Given & When & Then
        XCTAssertEqual(AppConstants.Limits.maxRecentEvents, 100)
        XCTAssertEqual(AppConstants.Limits.maxStoredEvents, 1000)
        XCTAssertEqual(AppConstants.Limits.maxStoredAnomalies, 500)
        XCTAssertEqual(AppConstants.Limits.rapidChangeThreshold, 3)
        XCTAssertEqual(AppConstants.Limits.eventRetentionDays, 7)
        XCTAssertEqual(AppConstants.Limits.maxRecentEventsForAnomalyDetection, 100)
    }
    
    func testLimitConsistency() {
        // Given & When & Then
        XCTAssertGreaterThan(AppConstants.Limits.maxStoredEvents, AppConstants.Limits.maxRecentEvents)
        XCTAssertGreaterThan(AppConstants.Limits.maxStoredAnomalies, AppConstants.Limits.maxRecentEvents)
        XCTAssertGreaterThan(AppConstants.Limits.maxRecentEvents, AppConstants.Limits.rapidChangeThreshold)
        XCTAssertGreaterThan(AppConstants.Limits.eventRetentionDays, 0)
        XCTAssertGreaterThan(AppConstants.Limits.maxRecentEventsForAnomalyDetection, 0)
    }
    
    func testLimitBoundaries() {
        // Given & When & Then
        XCTAssertGreaterThan(AppConstants.Limits.maxRecentEvents, 0)
        XCTAssertGreaterThan(AppConstants.Limits.maxStoredEvents, 0)
        XCTAssertGreaterThan(AppConstants.Limits.maxStoredAnomalies, 0)
        XCTAssertGreaterThan(AppConstants.Limits.rapidChangeThreshold, 0)
        XCTAssertGreaterThan(AppConstants.Limits.eventRetentionDays, 0)
        XCTAssertGreaterThan(AppConstants.Limits.maxRecentEventsForAnomalyDetection, 0)
    }
    
    // MARK: - UserDefaults Keys Tests
    
    func testUserDefaultsKeys() {
        // Given & When & Then
        XCTAssertEqual(AppConstants.UserDefaultsKeys.storedNetworkEvents, "StoredNetworkEvents")
        XCTAssertEqual(AppConstants.UserDefaultsKeys.storedNetworkAnomalies, "StoredNetworkAnomalies")
        XCTAssertEqual(AppConstants.UserDefaultsKeys.monitoringEnabled, "monitoringEnabled")
        XCTAssertEqual(AppConstants.UserDefaultsKeys.notificationEnabled, "notificationEnabled")
        XCTAssertEqual(AppConstants.UserDefaultsKeys.backgroundMonitoringEnabled, "backgroundMonitoringEnabled")
    }
    
    func testUserDefaultsKeysUniqueness() {
        // Given
        let keys = [
            AppConstants.UserDefaultsKeys.storedNetworkEvents,
            AppConstants.UserDefaultsKeys.storedNetworkAnomalies,
            AppConstants.UserDefaultsKeys.monitoringEnabled,
            AppConstants.UserDefaultsKeys.notificationEnabled,
            AppConstants.UserDefaultsKeys.backgroundMonitoringEnabled
        ]
        
        // When & Then
        let uniqueKeys = Set(keys)
        XCTAssertEqual(uniqueKeys.count, keys.count)
    }
    
    func testUserDefaultsKeysFormat() {
        // Given & When & Then
        let keys = [
            AppConstants.UserDefaultsKeys.storedNetworkEvents,
            AppConstants.UserDefaultsKeys.storedNetworkAnomalies,
            AppConstants.UserDefaultsKeys.monitoringEnabled,
            AppConstants.UserDefaultsKeys.notificationEnabled,
            AppConstants.UserDefaultsKeys.backgroundMonitoringEnabled
        ]
        
        for key in keys {
            XCTAssertFalse(key.isEmpty)
        }
    }
    
    // MARK: - Threat Scoring Tests
    
    func testThreatScoring() {
        // Given & When & Then
        XCTAssertEqual(AppConstants.ThreatScoring.twoGConnectionScore, 3)
        XCTAssertEqual(AppConstants.ThreatScoring.rapidChangeScore, 2)
        XCTAssertEqual(AppConstants.ThreatScoring.baselineMismatchScore, 1)
    }
    
    func testThreatScoringConsistency() {
        // Given & When & Then
        XCTAssertGreaterThan(AppConstants.ThreatScoring.twoGConnectionScore, AppConstants.ThreatScoring.rapidChangeScore)
        XCTAssertGreaterThan(AppConstants.ThreatScoring.rapidChangeScore, AppConstants.ThreatScoring.baselineMismatchScore)
    }
    
    func testThreatScoringBoundaries() {
        // Given & When & Then
        XCTAssertGreaterThan(AppConstants.ThreatScoring.twoGConnectionScore, 0)
        XCTAssertGreaterThan(AppConstants.ThreatScoring.rapidChangeScore, 0)
        XCTAssertGreaterThan(AppConstants.ThreatScoring.baselineMismatchScore, 0)
    }
    
    // MARK: - Background Task Identifiers Tests
    
    func testBackgroundTaskIdentifiers() {
        // Given & When & Then
        XCTAssertEqual(AppConstants.BackgroundTaskIdentifiers.securityMonitoring, "us.defroster.stingraywarning.security-monitoring")
        XCTAssertEqual(AppConstants.BackgroundTaskIdentifiers.backgroundRefresh, "us.defroster.stingraywarning.background-refresh")
    }
    
    func testBackgroundTaskIdentifierFormat() {
        // Given & When & Then
        let identifiers = [
            AppConstants.BackgroundTaskIdentifiers.securityMonitoring,
            AppConstants.BackgroundTaskIdentifiers.backgroundRefresh
        ]
        
        for identifier in identifiers {
            XCTAssertFalse(identifier.isEmpty)
            XCTAssertTrue(identifier.contains("us.defroster.stingraywarning"))
            XCTAssertTrue(identifier.contains("-"))
        }
    }
    
    func testBackgroundTaskIdentifierUniqueness() {
        // Given
        let identifiers = [
            AppConstants.BackgroundTaskIdentifiers.securityMonitoring,
            AppConstants.BackgroundTaskIdentifiers.backgroundRefresh
        ]
        
        // When & Then
        let uniqueIdentifiers = Set(identifiers)
        XCTAssertEqual(uniqueIdentifiers.count, identifiers.count)
    }
    
    // MARK: - App Info Tests
    
    func testAppInfo() {
        // Given & When & Then
        XCTAssertEqual(AppConstants.AppInfo.bundleIdentifier, "us.defroster.stingraywarning")
        XCTAssertEqual(AppConstants.AppInfo.version, "1.0.0")
    }
    
    func testAppInfoConsistency() {
        // Given & When & Then
        XCTAssertFalse(AppConstants.AppInfo.bundleIdentifier.isEmpty)
        XCTAssertFalse(AppConstants.AppInfo.version.isEmpty)
    }
    
    func testAppInfoFormat() {
        // Given & When & Then
        XCTAssertTrue(AppConstants.AppInfo.bundleIdentifier.contains("us.defroster"))
        XCTAssertTrue(AppConstants.AppInfo.version.contains("."))
    }
    
    // MARK: - Location Accuracy Tests
    
    func testLocationAccuracy() {
        // Given & When & Then
        XCTAssertEqual(AppConstants.LocationSettings.desiredAccuracy, kCLLocationAccuracyHundredMeters)
    }
    
    func testLocationAccuracyValue() {
        // Given & When & Then
        XCTAssertEqual(AppConstants.LocationSettings.desiredAccuracy, 100.0)
    }
    
    func testLocationAccuracyConsistency() {
        // Given & When & Then
        XCTAssertGreaterThan(AppConstants.LocationSettings.desiredAccuracy, 0)
        XCTAssertLessThan(AppConstants.LocationSettings.desiredAccuracy, 1000)
    }
    
    // MARK: - Edge Cases
    
    func testConstantsWithZeroValues() {
        // Given & When & Then
        // No constants should be zero unless explicitly intended
        XCTAssertNotEqual(AppConstants.TimeIntervals.second, 0)
        XCTAssertNotEqual(AppConstants.Limits.maxRecentEvents, 0)
        XCTAssertNotEqual(AppConstants.ThreatScoring.twoGConnectionScore, 0)
    }
    
    func testConstantsWithNegativeValues() {
        // Given & When & Then
        // No constants should be negative
        XCTAssertGreaterThan(AppConstants.TimeIntervals.second, 0)
        XCTAssertGreaterThan(AppConstants.Limits.maxRecentEvents, 0)
        XCTAssertGreaterThan(AppConstants.ThreatScoring.twoGConnectionScore, 0)
    }
    
    func testConstantsWithVeryLargeValues() {
        // Given & When & Then
        // Constants should be reasonable in size
        XCTAssertLessThan(AppConstants.Limits.maxStoredEvents, 10000)
        XCTAssertLessThan(AppConstants.TimeIntervals.month, 10000000)
        XCTAssertLessThan(AppConstants.ThreatScoring.twoGConnectionScore, 100)
    }
    
    // MARK: - Performance Tests
    
    func testConstantsAccessPerformance() {
        // When & Then
        measure {
            for _ in 0..<10000 {
                _ = AppConstants.TimeIntervals.second
                _ = AppConstants.Limits.maxRecentEvents
                _ = AppConstants.ThreatScoring.twoGConnectionScore
                _ = AppConstants.UserDefaultsKeys.storedNetworkEvents
                _ = AppConstants.BackgroundTaskIdentifiers.securityMonitoring
                _ = AppConstants.AppInfo.bundleIdentifier
                _ = AppConstants.LocationSettings.desiredAccuracy
            }
        }
    }
    
    func testConstantsCalculationPerformance() {
        // When & Then
        measure {
            for _ in 0..<1000 {
                _ = AppConstants.TimeIntervals.minute * 60
                _ = AppConstants.Limits.maxStoredEvents - AppConstants.Limits.maxRecentEvents
                _ = AppConstants.ThreatScoring.twoGConnectionScore - AppConstants.ThreatScoring.rapidChangeScore
            }
        }
    }
    
    // MARK: - Integration Tests
    
    func testConstantsIntegration() {
        // Given & When
        let timeIntervals = AppConstants.TimeIntervals.self
        let limits = AppConstants.Limits.self
        let threatScoring = AppConstants.ThreatScoring.self
        let userDefaultsKeys = AppConstants.UserDefaultsKeys.self
        let backgroundTaskIdentifiers = AppConstants.BackgroundTaskIdentifiers.self
        let appInfo = AppConstants.AppInfo.self
        let locationSettings = AppConstants.LocationSettings.self
        
        // Then
        // All constant groups should be accessible
        XCTAssertNotNil(timeIntervals)
        XCTAssertNotNil(limits)
        XCTAssertNotNil(threatScoring)
        XCTAssertNotNil(userDefaultsKeys)
        XCTAssertNotNil(backgroundTaskIdentifiers)
        XCTAssertNotNil(appInfo)
        XCTAssertNotNil(locationSettings)
    }
    
    func testConstantsWithRealUsage() {
        // Given
        let maxEvents = AppConstants.Limits.maxStoredEvents
        let maxRecentEvents = AppConstants.Limits.maxRecentEvents
        let retentionDays = AppConstants.Limits.eventRetentionDays
        let dayInterval = AppConstants.TimeIntervals.day
        
        // When
        let retentionInterval = TimeInterval(retentionDays) * dayInterval
        let eventsToTrim = maxEvents - maxRecentEvents
        
        // Then
        // Constants should work together logically
        XCTAssertGreaterThan(retentionInterval, 0)
        XCTAssertGreaterThan(eventsToTrim, 0)
        XCTAssertLessThan(eventsToTrim, maxEvents)
    }
    
    func testConstantsWithThreatScoring() {
        // Given
        let threat2G = AppConstants.ThreatScoring.twoGConnectionScore
        let threatRapidChange = AppConstants.ThreatScoring.rapidChangeScore
        let threatBaseline = AppConstants.ThreatScoring.baselineMismatchScore
        
        // When
        let maxThreat = max(threat2G, threatRapidChange, threatBaseline)
        let minThreat = min(threat2G, threatRapidChange, threatBaseline)
        
        // Then
        // Threat scoring should be consistent
        XCTAssertEqual(maxThreat, threat2G)
        XCTAssertEqual(minThreat, threatBaseline)
        XCTAssertGreaterThan(maxThreat, minThreat)
    }
    
    // MARK: - Validation Tests
    
    func testConstantsValidation() {
        // Given & When & Then
        // All constants should be valid
        XCTAssertTrue(AppConstants.TimeIntervals.second > 0)
        XCTAssertTrue(AppConstants.Limits.maxRecentEvents > 0)
        XCTAssertTrue(AppConstants.ThreatScoring.twoGConnectionScore > 0)
        XCTAssertFalse(AppConstants.UserDefaultsKeys.storedNetworkEvents.isEmpty)
        XCTAssertFalse(AppConstants.BackgroundTaskIdentifiers.securityMonitoring.isEmpty)
        XCTAssertFalse(AppConstants.AppInfo.bundleIdentifier.isEmpty)
        XCTAssertTrue(AppConstants.LocationSettings.desiredAccuracy > 0)
    }
    
    func testConstantsTypeSafety() {
        // Given & When & Then
        // Constants should be type-safe and have correct values
        XCTAssertEqual(AppConstants.TimeIntervals.second, 1.0)
        XCTAssertEqual(AppConstants.Limits.maxRecentEvents, 1000)
        XCTAssertEqual(AppConstants.ThreatScoring.twoGConnectionScore, 3)
        XCTAssertEqual(AppConstants.UserDefaultsKeys.storedNetworkEvents, "StoredNetworkEvents")
        XCTAssertEqual(AppConstants.BackgroundTaskIdentifiers.securityMonitoring, "us.defroster.stingraywarning.security-monitoring")
        XCTAssertEqual(AppConstants.AppInfo.bundleIdentifier, "us.defroster.stingraywarning")
        XCTAssertEqual(AppConstants.LocationSettings.desiredAccuracy, kCLLocationAccuracyHundredMeters)
    }
}
