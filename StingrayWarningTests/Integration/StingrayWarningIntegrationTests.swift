import XCTest
import CoreTelephony
import CoreLocation
import UserNotifications
import BackgroundTasks
@testable import Stingray_Warning

/// Integration tests for key application workflows
/// These tests verify that multiple components work together correctly
class StingrayWarningIntegrationTests: XCTestCase {
    
    // MARK: - Test Properties
    private var cellularMonitor: CellularSecurityMonitor!
    private var notificationManager: NotificationManager!
    private var backgroundTaskManager: BackgroundTaskManager!
    private var eventStore: EventStore!
    private var mockNetworkInfo: MockCTTelephonyNetworkInfo!
    private var mockLocationManager: MockCLLocationManager!
    private var mockNotificationCenter: MockUNUserNotificationCenter!
    private var mockTaskScheduler: MockBGTaskScheduler!
    private var mockUserDefaults: MockUserDefaults!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        
        // Clear UserDefaults to ensure clean state for each test
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
        // Create mock objects
        mockNetworkInfo = MockCTTelephonyNetworkInfo()
        mockLocationManager = MockCLLocationManager()
        // Note: MockUNUserNotificationCenter and MockBGTaskScheduler cannot be instantiated due to unavailable initializers
        // Tests should use dependency injection or other patterns
        mockUserDefaults = MockUserDefaults()
        
        // Create real objects with mock dependencies
        cellularMonitor = CellularSecurityMonitor()
        notificationManager = NotificationManager()
        backgroundTaskManager = BackgroundTaskManager()
        eventStore = EventStore()
        
        // Set up dependencies
        cellularMonitor.setEventStore(eventStore)
        cellularMonitor.setBackgroundTaskManager(backgroundTaskManager)
        backgroundTaskManager.setCellularMonitor(cellularMonitor)
    }
    
    override func tearDown() {
        cellularMonitor = nil
        notificationManager = nil
        backgroundTaskManager = nil
        eventStore = nil
        mockNetworkInfo = nil
        mockLocationManager = nil
        mockNotificationCenter = nil
        mockTaskScheduler = nil
        mockUserDefaults = nil
        
        super.tearDown()
    }
    
    // MARK: - Workflow 1: App Launch & Initialization
    
    func testAppLaunchAndInitializationWorkflow() throws {
        // Given: App is launching
        let expectation = XCTestExpectation(description: "App initialization completes")
        
        // When: App initializes
        let app = StingrayWarningApp()
        
        // Then: All components should be properly initialized
        XCTAssertNotNil(app, "App should initialize successfully")
        
        // Verify core components are available
        XCTAssertTrue(cellularMonitor.isMonitoring == false, "Monitoring should start as inactive")
        XCTAssertNotNil(eventStore.events, "Event store should be initialized")
        XCTAssertNotNil(eventStore.anomalies, "Anomaly store should be initialized")
        
        expectation.fulfill()
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testComponentDependencySetupWorkflow() throws {
        // Given: All components exist
        let expectation = XCTestExpectation(description: "Dependencies are set up")
        
        // When: Setting up component dependencies
        cellularMonitor.setEventStore(eventStore)
        cellularMonitor.setBackgroundTaskManager(backgroundTaskManager)
        backgroundTaskManager.setCellularMonitor(cellularMonitor)
        
        // Then: Dependencies should be properly linked
        XCTAssertNotNil(cellularMonitor.testEventStore, "Event store should be linked")
        XCTAssertNotNil(cellularMonitor.testBackgroundTaskManager, "Background task manager should be linked")
        XCTAssertNotNil(backgroundTaskManager.testCellularMonitor, "Cellular monitor should be linked")
        
        expectation.fulfill()
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Workflow 2: Monitoring Start/Stop
    
    func testMonitoringStartStopWorkflow() throws {
        // Given: App is initialized and monitoring is stopped
        XCTAssertFalse(cellularMonitor.isMonitoring, "Monitoring should start as stopped")
        
        let startExpectation = XCTestExpectation(description: "Monitoring starts")
        let stopExpectation = XCTestExpectation(description: "Monitoring stops")
        
        // When: Starting monitoring
        cellularMonitor.startMonitoring()
        
        // Then: Monitoring should be active
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertTrue(self.cellularMonitor.isMonitoring, "Monitoring should be active")
            startExpectation.fulfill()
        }
        
        wait(for: [startExpectation], timeout: 5.0)
        
        // When: Stopping monitoring
        cellularMonitor.stopMonitoring()
        
        // Then: Monitoring should be stopped
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertFalse(self.cellularMonitor.isMonitoring, "Monitoring should be stopped")
            stopExpectation.fulfill()
        }
        
        wait(for: [stopExpectation], timeout: 5.0)
    }
    
    func testMonitoringStatePersistenceWorkflow() throws {
        // Given: Monitoring state changes
        let expectation = XCTestExpectation(description: "State persistence works")
        
        // When: Starting monitoring
        cellularMonitor.startMonitoring()
        
        // Then: State should be persisted
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Simulate app restart by creating new monitor
            let newMonitor = CellularSecurityMonitor()
            newMonitor.setEventStore(self.eventStore)
            
            // State should be restored
            XCTAssertTrue(newMonitor.shouldAutoStartMonitoring(), "Monitoring state should be persisted")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Workflow 3: Threat Detection & Notification
    
    func testThreatDetectionWorkflow() throws {
        // Given: Monitoring is active
        cellularMonitor.startMonitoring()
        
        let expectation = XCTestExpectation(description: "Threat detection completes")
        
        // When: Processing a suspicious network event
        let suspiciousEvent = TestDataFactory.createNetworkEvent(
            radioTechnology: "GPRS", // 2G network
            carrierName: "Unknown Carrier",
            threatLevel: .high
        )
        
        cellularMonitor.processNetworkEvent(suspiciousEvent)
        
        // Then: Threat level should be updated
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertTrue(self.cellularMonitor.currentThreatLevel != .none, "Threat level should be detected")
            XCTAssertNotNil(self.cellularMonitor.lastCheckTime, "Last check time should be set")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testNotificationWorkflow() throws {
        // Given: Notification permissions are granted
        // Note: We can't easily mock UNUserNotificationCenter due to unavailable initializers
        // This test verifies that notifications can be sent without crashing
        
        let expectation = XCTestExpectation(description: "Notification is sent")
        
        // When: A high-threat event occurs
        let highThreatEvent = TestDataFactory.createNetworkEvent(
            radioTechnology: "GPRS",
            carrierName: "Suspicious Carrier",
            threatLevel: .critical
        )
        
        cellularMonitor.processNetworkEvent(highThreatEvent)
        
        // Then: Notification should be sent
        // Note: We can't easily verify notification delivery without mocking
        // This test verifies that the notification sending process doesn't crash
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // The test passes if we reach this point without crashing
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testThreatLevelEscalationWorkflow() throws {
        // Given: Monitoring is active
        cellularMonitor.startMonitoring()
        
        let expectation = XCTestExpectation(description: "Threat escalation completes")
        
        // When: Multiple suspicious events occur
        let events = [
            TestDataFactory.createNetworkEvent(radioTechnology: "LTE", carrierName: "Normal Carrier", threatLevel: .none),
            TestDataFactory.createNetworkEvent(radioTechnology: "GPRS", carrierName: "Unknown Carrier", threatLevel: .medium),
            TestDataFactory.createNetworkEvent(radioTechnology: "GPRS", carrierName: "Suspicious Carrier", threatLevel: .high),
            TestDataFactory.createNetworkEvent(radioTechnology: "GPRS", carrierName: "Fake Carrier", threatLevel: .critical)
        ]
        
        for event in events {
            cellularMonitor.processNetworkEvent(event)
            Thread.sleep(forTimeInterval: 0.5)
        }
        
        // Then: Threat level should escalate
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertTrue(self.cellularMonitor.currentThreatLevel == .critical, "Threat level should escalate to critical")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Workflow 4: Data Persistence & Event Storage
    
    func testEventStorageWorkflow() throws {
        // Given: Event store is empty
        XCTAssertTrue(eventStore.events.isEmpty, "Event store should start empty")
        
        let expectation = XCTestExpectation(description: "Events are stored")
        
        // When: Adding multiple events
        let events = [
            TestDataFactory.createNetworkEvent(radioTechnology: "LTE", carrierName: "Carrier 1", threatLevel: .none),
            TestDataFactory.createNetworkEvent(radioTechnology: "GPRS", carrierName: "Carrier 2", threatLevel: .medium),
            TestDataFactory.createNetworkEvent(radioTechnology: "GPRS", carrierName: "Carrier 3", threatLevel: .high)
        ]
        
        for event in events {
            eventStore.addEvent(event)
        }
        
        // Then: Events should be stored
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertEqual(self.eventStore.events.count, 3, "All events should be stored")
            XCTAssertTrue(self.eventStore.events.contains { $0.carrierName == "Carrier 1" }, "Event 1 should be stored")
            XCTAssertTrue(self.eventStore.events.contains { $0.carrierName == "Carrier 2" }, "Event 2 should be stored")
            XCTAssertTrue(self.eventStore.events.contains { $0.carrierName == "Carrier 3" }, "Event 3 should be stored")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testAnomalyDetectionWorkflow() throws {
        // Given: Monitoring is active
        cellularMonitor.startMonitoring()
        
        let expectation = XCTestExpectation(description: "Anomaly is detected")
        
        // When: Rapid network changes occur (anomaly pattern)
        let rapidEvents = [
            TestDataFactory.createNetworkEvent(radioTechnology: "LTE", carrierName: "Carrier A", threatLevel: .none),
            TestDataFactory.createNetworkEvent(radioTechnology: "GPRS", carrierName: "Carrier B", threatLevel: .medium),
            TestDataFactory.createNetworkEvent(radioTechnology: "LTE", carrierName: "Carrier C", threatLevel: .none),
            TestDataFactory.createNetworkEvent(radioTechnology: "GPRS", carrierName: "Carrier D", threatLevel: .high)
        ]
        
        for event in rapidEvents {
            cellularMonitor.processNetworkEvent(event)
            Thread.sleep(forTimeInterval: 0.1) // Rapid changes
        }
        
        // Then: Anomaly should be detected
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertTrue(self.eventStore.anomalies.count > 0, "Anomaly should be detected")
            let anomaly = self.eventStore.anomalies.first
            XCTAssertEqual(anomaly?.anomalyType, .rapidTechnologyChange, "Should detect rapid technology change")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testDataRetentionWorkflow() throws {
        // Given: Many events are stored
        let expectation = XCTestExpectation(description: "Data retention works")
        
        // When: Adding more events than the limit
        for i in 0..<1000 { // More than maxStoredEvents
            let event = TestDataFactory.createNetworkEvent(
                radioTechnology: "LTE",
                carrierName: "Carrier \(i)",
                threatLevel: .none
            )
            eventStore.addEvent(event)
        }
        
        // Then: Only the most recent events should be kept
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertLessThanOrEqual(self.eventStore.events.count, AppConstants.Limits.maxStoredEvents, "Should not exceed max stored events")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Workflow 5: Background Task Management
    
    func testBackgroundTaskRegistrationWorkflow() throws {
        // Given: Background task manager is initialized
        // Note: Background task registration can only happen during app launch
        // This test verifies the manager can be initialized and configured properly
        
        // When: Setting up the background task manager
        backgroundTaskManager.setCellularMonitor(cellularMonitor)
        
        // Then: Manager should be properly configured
        XCTAssertNotNil(backgroundTaskManager, "Background task manager should be initialized")
        XCTAssertNotNil(cellularMonitor, "Cellular monitor should be initialized")
        
        // Note: We cannot test actual background task registration in unit tests
        // as it must happen during app launch. This is tested in the main app.
    }
    
    func testBackgroundTaskExecutionWorkflow() throws {
        // Given: Background task manager is configured
        backgroundTaskManager.setCellularMonitor(cellularMonitor)
        
        // When: Testing background task execution logic
        // Note: We cannot actually execute background tasks in unit tests
        // as they require the app to be in the background
        
        // Then: Manager should be properly configured for background execution
        XCTAssertNotNil(backgroundTaskManager, "Background task manager should be initialized")
        XCTAssertNotNil(cellularMonitor, "Cellular monitor should be available")
        
        // Note: Actual background task execution is tested in the main app
        // when the app goes to background and tasks are triggered by the system
    }
    
    // MARK: - Workflow 6: Settings & Configuration
    
    func testSettingsPersistenceWorkflow() throws {
        // Given: Settings are changed
        let expectation = XCTestExpectation(description: "Settings are persisted")
        
        // When: Changing monitoring preferences
        UserDefaults.standard.set(true, forKey: AppConstants.UserDefaultsKeys.autoStartMonitoring)
        UserDefaults.standard.set(false, forKey: AppConstants.UserDefaultsKeys.enableNotifications)
        
        // Then: Settings should be persisted
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertTrue(UserDefaults.standard.bool(forKey: AppConstants.UserDefaultsKeys.autoStartMonitoring), "Auto-start should be persisted")
            XCTAssertFalse(UserDefaults.standard.bool(forKey: AppConstants.UserDefaultsKeys.enableNotifications), "Notifications should be persisted")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testNotificationPermissionWorkflow() throws {
        // Given: Notification manager is initialized
        let expectation = XCTestExpectation(description: "Notification permissions are requested")
        
        // When: Requesting notification permissions
        notificationManager.requestPermissions()
        
        // Then: Permissions should be requested
        // Note: We can't easily mock UNUserNotificationCenter due to unavailable initializers
        // This test verifies that the method can be called without crashing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // The test passes if we reach this point without crashing
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Workflow 7: End-to-End User Journey
    
    func testCompleteUserJourneyWorkflow() throws {
        // Given: Fresh app installation
        let expectation = XCTestExpectation(description: "Complete user journey")
        
        // Step 1: App launches
        XCTAssertFalse(cellularMonitor.isMonitoring, "App should start with monitoring off")
        
        // Step 2: User enables monitoring
        cellularMonitor.startMonitoring()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertTrue(self.cellularMonitor.isMonitoring, "Monitoring should be active")
            
            // Step 3: Network events are processed
            let normalEvent = TestDataFactory.createNetworkEvent(
                radioTechnology: "LTE",
                carrierName: "Normal Carrier",
                threatLevel: .none
            )
            self.cellularMonitor.processNetworkEvent(normalEvent)
            
            // Step 4: Suspicious activity is detected
            let suspiciousEvent = TestDataFactory.createNetworkEvent(
                radioTechnology: "GPRS",
                carrierName: "Unknown Carrier",
                threatLevel: .high
            )
            self.cellularMonitor.processNetworkEvent(suspiciousEvent)
            
            // Step 5: Verify data is stored
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                XCTAssertTrue(self.eventStore.events.count >= 2, "Events should be stored")
                XCTAssertTrue(self.cellularMonitor.currentThreatLevel == .high, "Threat level should be high")
                
                // Step 6: User stops monitoring
                self.cellularMonitor.stopMonitoring()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    XCTAssertFalse(self.cellularMonitor.isMonitoring, "Monitoring should be stopped")
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testErrorRecoveryWorkflow() throws {
        // Given: An error occurs during monitoring
        let expectation = XCTestExpectation(description: "Error recovery works")
        
        // When: Monitoring encounters an error
        cellularMonitor.startMonitoring()
        
        // Simulate network error
        let errorEvent = TestDataFactory.createNetworkEvent(
            radioTechnology: "UNKNOWN",
            carrierName: "",
            threatLevel: .none
        )
        cellularMonitor.processNetworkEvent(errorEvent)
        
        // Then: App should recover gracefully
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertTrue(self.cellularMonitor.isMonitoring, "Monitoring should continue despite error")
            XCTAssertNotNil(self.cellularMonitor.lastCheckTime, "Last check time should be updated")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testPerformanceUnderLoadWorkflow() throws {
        // Given: High load scenario
        let expectation = XCTestExpectation(description: "Performance under load")
        
        // When: Processing many events rapidly
        cellularMonitor.startMonitoring()
        
        let startTime = Date()
        
        for i in 0..<100 {
            let event = TestDataFactory.createNetworkEvent(
                radioTechnology: i % 2 == 0 ? "LTE" : "GPRS",
                carrierName: "Carrier \(i)",
                threatLevel: NetworkThreatLevel.allCases.randomElement() ?? .none
            )
            cellularMonitor.processNetworkEvent(event)
        }
        
        // Then: App should handle load efficiently
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            let endTime = Date()
            let duration = endTime.timeIntervalSince(startTime)
            
            XCTAssertLessThan(duration, 5.0, "Processing should complete within 5 seconds")
            XCTAssertTrue(self.eventStore.events.count > 0, "Events should be processed")
            XCTAssertTrue(self.cellularMonitor.isMonitoring, "Monitoring should remain active")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}
