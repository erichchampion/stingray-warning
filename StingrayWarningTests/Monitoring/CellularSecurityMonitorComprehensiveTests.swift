import XCTest
import CoreTelephony
import CoreLocation
@testable import Stingray_Warning

/// Comprehensive unit tests for CellularSecurityMonitor
class CellularSecurityMonitorComprehensiveTests: XCTestCase {
    
    var monitor: CellularSecurityMonitor!
    var mockEventStore: MockEventStore!
    var mockBackgroundTaskManager: MockBackgroundTaskManager!
    
    override func setUp() {
        super.setUp()
        
        // Clear UserDefaults to ensure clean state for each test
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
        monitor = CellularSecurityMonitor()
        mockEventStore = MockEventStore()
        mockBackgroundTaskManager = MockBackgroundTaskManager()
        
        monitor.setEventStore(mockEventStore)
        monitor.setBackgroundTaskManager(mockBackgroundTaskManager)
    }
    
    override func tearDown() {
        monitor = nil
        mockEventStore = nil
        mockBackgroundTaskManager = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        // Given & When
        let newMonitor = CellularSecurityMonitor()
        
        // Then
        XCTAssertNotNil(newMonitor)
        XCTAssertEqual(newMonitor.currentThreatLevel, .none)
        XCTAssertFalse(newMonitor.isMonitoring)
        XCTAssertNil(newMonitor.lastCheckTime)
        XCTAssertNil(newMonitor.currentNetworkInfo)
    }
    
    func testInitializationWithDependencies() {
        // Given & When
        let monitor = CellularSecurityMonitor()
        let eventStore = MockEventStore()
        let backgroundManager = MockBackgroundTaskManager()
        
        monitor.setEventStore(eventStore)
        monitor.setBackgroundTaskManager(backgroundManager)
        
        // Then
        XCTAssertNotNil(monitor)
        // Dependencies should be set (tested implicitly through other tests)
    }
    
    // MARK: - Monitoring Control Tests
    
    func testStartMonitoring() {
        // Given
        XCTAssertFalse(monitor.isMonitoring)
        
        // When
        monitor.startMonitoring()
        
        // Then
        XCTAssertTrue(monitor.isMonitoring)
        XCTAssertNotNil(monitor.lastCheckTime)
    }
    
    func testStopMonitoring() {
        // Given
        monitor.startMonitoring()
        XCTAssertTrue(monitor.isMonitoring)
        
        // When
        monitor.stopMonitoring()
        
        // Then
        XCTAssertFalse(monitor.isMonitoring)
    }
    
    func testMultipleStartMonitoring() {
        // Given
        monitor.startMonitoring()
        XCTAssertTrue(monitor.isMonitoring)
        
        // When
        monitor.startMonitoring()
        monitor.startMonitoring()
        
        // Then
        XCTAssertTrue(monitor.isMonitoring)
        // Should handle multiple starts gracefully
    }
    
    func testMultipleStopMonitoring() {
        // Given
        monitor.startMonitoring()
        monitor.stopMonitoring()
        XCTAssertFalse(monitor.isMonitoring)
        
        // When
        monitor.stopMonitoring()
        monitor.stopMonitoring()
        
        // Then
        XCTAssertFalse(monitor.isMonitoring)
        // Should handle multiple stops gracefully
    }
    
    // MARK: - Network Event Processing Tests
    
    func testProcessNetworkEventWith2GConnection() {
        // Given
        let event = TestDataFactory.create2GNetworkEvent()
        
        // When
        monitor.processNetworkEvent(event)
        
        // Then
        XCTAssertEqual(mockEventStore.addedEvents.count, 1)
        XCTAssertEqual(mockEventStore.addedEvents.first?.threatLevel, .medium)
        XCTAssertTrue(mockEventStore.addedEvents.first?.is2GConnection ?? false)
    }
    
    func testProcessNetworkEventWith5GConnection() {
        // Given
        let event = TestDataFactory.create5GNetworkEvent()
        
        // When
        monitor.processNetworkEvent(event)
        
        // Then
        XCTAssertEqual(mockEventStore.addedEvents.count, 1)
        XCTAssertEqual(mockEventStore.addedEvents.first?.threatLevel, NetworkThreatLevel.none)
        XCTAssertFalse(mockEventStore.addedEvents.first?.is2GConnection ?? true)
    }
    
    func testProcessNetworkEventWithHighThreat() {
        // Given
        let event = TestDataFactory.createHighThreatEvent()
        
        // When
        monitor.processNetworkEvent(event)
        
        // Then
        XCTAssertEqual(mockEventStore.addedEvents.count, 1)
        XCTAssertEqual(mockEventStore.addedEvents.first?.threatLevel, .high)
    }
    
    func testProcessNetworkEventWithNilTechnology() {
        // Given
        let event = TestDataFactory.createNetworkEvent(radioTechnology: nil)
        
        // When
        monitor.processNetworkEvent(event)
        
        // Then
        XCTAssertEqual(mockEventStore.addedEvents.count, 1)
        XCTAssertNil(mockEventStore.addedEvents.first?.radioTechnology)
    }
    
    func testProcessNetworkEventWithEmptyTechnology() {
        // Given
        let event = TestDataFactory.createNetworkEvent(radioTechnology: "")
        
        // When
        monitor.processNetworkEvent(event)
        
        // Then
        XCTAssertEqual(mockEventStore.addedEvents.count, 1)
        XCTAssertEqual(mockEventStore.addedEvents.first?.radioTechnology, "")
    }
    
    // MARK: - Issue Detection Tests
    
    func testIssueDetectionWith2GNetwork() {
        // Given
        let event = TestDataFactory.createNetworkEvent(
            radioTechnology: "CTRadioAccessTechnologyGSM",
            threatLevel: .none
        )
        
        // When
        monitor.processNetworkEvent(event)
        
        // Then
        // Should detect 2G as medium issue
        XCTAssertEqual(mockEventStore.addedEvents.count, 1)
        XCTAssertEqual(mockEventStore.addedEvents.first?.threatLevel, .medium)
    }
    
    func testIssueDetectionWithEdgeNetwork() {
        // Given
        let event = TestDataFactory.createNetworkEvent(
            radioTechnology: "CTRadioAccessTechnologyEdge",
            threatLevel: .none
        )
        
        // When
        monitor.processNetworkEvent(event)
        
        // Then
        // Should detect Edge as medium issue
        XCTAssertEqual(mockEventStore.addedEvents.count, 1)
        XCTAssertEqual(mockEventStore.addedEvents.first?.threatLevel, .medium)
    }
    
    func testIssueDetectionWithLTENetwork() {
        // Given
        let event = TestDataFactory.createNetworkEvent(
            radioTechnology: "CTRadioAccessTechnologyLTE",
            threatLevel: .none
        )
        
        // When
        monitor.processNetworkEvent(event)
        
        // Then
        // Should detect LTE as no issue
        XCTAssertEqual(mockEventStore.addedEvents.count, 1)
        XCTAssertEqual(mockEventStore.addedEvents.first?.threatLevel, NetworkThreatLevel.none)
    }
    
    func testIssueDetectionWith5GNetwork() {
        // Given
        let event = TestDataFactory.createNetworkEvent(
            radioTechnology: "CTRadioAccessTechnologyNRNSA",
            threatLevel: .none
        )
        
        // When
        monitor.processNetworkEvent(event)
        
        // Then
        // Should detect 5G as no issue
        XCTAssertEqual(mockEventStore.addedEvents.count, 1)
        XCTAssertEqual(mockEventStore.addedEvents.first?.threatLevel, NetworkThreatLevel.none)
    }
    
    func testIssueDetectionWithUnknownCarrier() {
        // Given
        let event = TestDataFactory.createNetworkEvent(
            carrierName: "Unknown Carrier",
            threatLevel: .none
        )
        
        // When
        monitor.processNetworkEvent(event)
        
        // Then
        // Should detect unknown carrier as high issue
        XCTAssertEqual(mockEventStore.addedEvents.count, 1)
        XCTAssertEqual(mockEventStore.addedEvents.first?.threatLevel, .high)
    }
    
    func testIssueDetectionWithRogueCarrier() {
        // Given
        let event = TestDataFactory.createNetworkEvent(
            carrierName: "Rogue Base Station",
            threatLevel: .none
        )
        
        // When
        monitor.processNetworkEvent(event)
        
        // Then
        // Should detect rogue carrier as critical issue
        XCTAssertEqual(mockEventStore.addedEvents.count, 1)
        XCTAssertEqual(mockEventStore.addedEvents.first?.threatLevel, .critical)
    }
    
    // MARK: - Anomaly Detection Tests
    
    func testAnomalyDetectionWithRapidTechnologyChange() {
        // Given
        let events = TestDataFactory.createRapidTechnologyChangeScenario()
        
        // When
        for event in events {
            monitor.processNetworkEvent(event)
        }
        
        // Then
        // Should detect rapid technology change anomaly
        XCTAssertEqual(mockEventStore.addedEvents.count, 4)
        // Should create anomaly for rapid changes
    }
    
    func testAnomalyDetectionWithNormalNetwork() {
        // Given
        let events = TestDataFactory.createNormalNetworkScenario()
        
        // When
        for event in events {
            monitor.processNetworkEvent(event)
        }
        
        // Then
        // Should not detect anomalies for normal network
        // Only the first event should be stored due to filtering of duplicate no-threat events
        XCTAssertEqual(mockEventStore.addedEvents.count, 1)
        // No anomalies should be created
    }
    
    func testAnomalyDetectionWithSuspiciousCarrier() {
        // Given
        let events = TestDataFactory.createSuspiciousCarrierScenario()
        
        // When
        for event in events {
            monitor.processNetworkEvent(event)
        }
        
        // Then
        // Should detect suspicious carrier anomaly
        // First event (Verizon, .none) and second event (Unknown Carrier, .high) should be stored
        // Third event (Verizon, .none) should also be stored since it's not identical to the previous event
        XCTAssertEqual(mockEventStore.addedEvents.count, 3)
        // Should create anomaly for suspicious carrier
    }
    
    // MARK: - State Management Tests
    
    func testCurrentThreatLevelUpdates() {
        // Given
        XCTAssertEqual(monitor.currentThreatLevel, .none)
        
        // When
        let highThreatEvent = TestDataFactory.createHighThreatEvent()
        monitor.processNetworkEvent(highThreatEvent)
        
        // Then
        // Current issue level should be updated
        XCTAssertEqual(monitor.currentThreatLevel, .high)
    }
    
    func testCurrentNetworkInfoUpdates() {
        // Given
        XCTAssertNil(monitor.currentNetworkInfo)
        
        // When
        let event = TestDataFactory.createNetworkEvent()
        monitor.processNetworkEvent(event)
        
        // Then
        // Current network info should be updated
        XCTAssertNotNil(monitor.currentNetworkInfo)
        XCTAssertEqual(monitor.currentNetworkInfo?.radioTechnology, event.radioTechnology)
    }
    
    func testLastCheckTimeUpdates() {
        // Given
        XCTAssertNil(monitor.lastCheckTime)
        
        // When
        monitor.startMonitoring()
        
        // Then
        XCTAssertNotNil(monitor.lastCheckTime)
        XCTAssertTrue(monitor.lastCheckTime! <= Date())
    }
    
    // MARK: - Background Task Integration Tests
    
    func testBackgroundTaskIntegration() {
        // Given
        monitor.startMonitoring()
        
        // When
        monitor.performSecurityCheck()
        
        // Then
        // Background check should be performed
        // Task manager should be notified
    }
    
    func testBackgroundTaskWithNoEvents() {
        // Given
        monitor.startMonitoring()
        
        // When
        monitor.performSecurityCheck()
        
        // Then
        // Should handle no events gracefully
        // No errors should occur
    }
    
    func testBackgroundTaskWithEvents() {
        // Given
        monitor.startMonitoring()
        let event = TestDataFactory.createNetworkEvent()
        monitor.processNetworkEvent(event)
        
        // When
        monitor.performSecurityCheck()
        
        // Then
        // Should process existing events
        // No errors should occur
    }
    
    // MARK: - Error Handling Tests
    
    func testProcessNetworkEventWithInvalidData() {
        // Given
        let event = TestDataFactory.createNetworkEvent(
            radioTechnology: nil,
            carrierName: nil,
            carrierCountryCode: nil,
            carrierMobileCountryCode: nil,
            carrierMobileNetworkCode: nil,
            threatLevel: .none,
            description: ""
        )
        
        // When
        monitor.processNetworkEvent(event)
        
        // Then
        // Should handle invalid data gracefully
        XCTAssertEqual(mockEventStore.addedEvents.count, 1)
    }
    
    func testProcessNetworkEventWithSpecialCharacters() {
        // Given
        let event = TestDataFactory.createNetworkEvent(
            description: "Test with special chars: !@#$%^&*()_+-=[]{}|;':\",./<>?"
        )
        
        // When
        monitor.processNetworkEvent(event)
        
        // Then
        // Should handle special characters gracefully
        XCTAssertEqual(mockEventStore.addedEvents.count, 1)
    }
    
    func testProcessNetworkEventWithUnicodeCharacters() {
        // Given
        let event = TestDataFactory.createNetworkEvent(
            description: "Test with unicode: 🚨📱🔒⚠️"
        )
        
        // When
        monitor.processNetworkEvent(event)
        
        // Then
        // Should handle unicode characters gracefully
        XCTAssertEqual(mockEventStore.addedEvents.count, 1)
    }
    
    // MARK: - Performance Tests
    
    func testProcessNetworkEventPerformance() {
        // Given
        let events = Array(0..<100).map { _ in TestDataFactory.createNetworkEvent() }
        
        // When & Then
        measure {
            for event in events {
                monitor.processNetworkEvent(event)
            }
        }
    }
    
    func testStartMonitoringPerformance() {
        // When & Then
        measure {
            monitor.startMonitoring()
        }
    }
    
    func testStopMonitoringPerformance() {
        // Given
        monitor.startMonitoring()
        
        // When & Then
        measure {
            monitor.stopMonitoring()
        }
    }
    
    func testBackgroundCheckPerformance() {
        // Given
        monitor.startMonitoring()
        let events = Array(0..<50).map { _ in TestDataFactory.createNetworkEvent() }
        
        for event in events {
            monitor.processNetworkEvent(event)
        }
        
        // When & Then
        measure {
            monitor.performSecurityCheck()
        }
    }
    
    // MARK: - Edge Cases
    
    func testProcessNetworkEventWithVeryLongDescription() {
        // Given
        let longDescription = String(repeating: "A", count: 1000)
        let event = TestDataFactory.createNetworkEvent(description: longDescription)
        
        // When
        monitor.processNetworkEvent(event)
        
        // Then
        // Should handle very long descriptions
        XCTAssertEqual(mockEventStore.addedEvents.count, 1)
    }
    
    func testProcessNetworkEventWithRapidSuccession() {
        // Given
        let events = Array(0..<1000).map { _ in TestDataFactory.createNetworkEvent() }
        
        // When
        for event in events {
            monitor.processNetworkEvent(event)
        }
        
        // Then
        // Should handle rapid succession of events
        // Only the first event should be stored due to filtering of duplicate no-threat events
        XCTAssertEqual(mockEventStore.addedEvents.count, 1)
    }
    
    func testProcessNetworkEventWithMixedThreatLevels() {
        // Given
        let events = [
            TestDataFactory.createNetworkEvent(threatLevel: .none),
            TestDataFactory.createNetworkEvent(threatLevel: .low),
            TestDataFactory.createNetworkEvent(threatLevel: .medium),
            TestDataFactory.createNetworkEvent(threatLevel: .high),
            TestDataFactory.createNetworkEvent(threatLevel: .critical)
        ]
        
        // When
        for event in events {
            monitor.processNetworkEvent(event)
        }
        
        // Then
        // Should handle mixed threat levels
        XCTAssertEqual(mockEventStore.addedEvents.count, 5)
    }
    
    // MARK: - Integration Tests
    
    func testCellularSecurityMonitorIntegration() {
        // Given
        let monitor = CellularSecurityMonitor()
        let eventStore = MockEventStore()
        let backgroundManager = MockBackgroundTaskManager()
        
        monitor.setEventStore(eventStore)
        monitor.setBackgroundTaskManager(backgroundManager)
        
        // When
        monitor.startMonitoring()
        
        let events = [
            TestDataFactory.create2GNetworkEvent(),
            TestDataFactory.create5GNetworkEvent(),
            TestDataFactory.createHighThreatEvent()
        ]
        
        for event in events {
            monitor.processNetworkEvent(event)
        }
        
        monitor.performSecurityCheck()
        monitor.stopMonitoring()
        
        // Then
        // Complete integration should work without errors
        // startMonitoring() creates 1 event, test creates 3 events, performSecurityCheck() creates 1 more event
        XCTAssertEqual(eventStore.addedEvents.count, 5)
        XCTAssertFalse(monitor.isMonitoring)
    }
    
    func testCellularSecurityMonitorWithRealData() {
        // Given
        let monitor = CellularSecurityMonitor()
        let eventStore = MockEventStore()
        
        monitor.setEventStore(eventStore)
        
        // When
        monitor.startMonitoring()
        
        let realisticEvents = Array(0..<10).map { _ in MockDataGenerators.generateRealisticNetworkEvent() }
        
        for event in realisticEvents {
            monitor.processNetworkEvent(event)
        }
        
        // Then
        // Should handle realistic data
        // startMonitoring() creates 1 event, test creates 10 events
        XCTAssertEqual(eventStore.addedEvents.count, 11)
    }
}

// MARK: - Mock BackgroundTaskManager for Testing

class MockBackgroundTaskManager: BackgroundTaskManager {
    var backgroundCheckCalled = false
    
    override func setCellularMonitor(_ monitor: CellularSecurityMonitor) {
        // Mock implementation
    }
    
    func simulateBackgroundCheck() {
        backgroundCheckCalled = true
    }
}
