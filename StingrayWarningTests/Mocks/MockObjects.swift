import XCTest
import CoreTelephony
import CoreLocation
import UserNotifications
import BackgroundTasks
@testable import Stingray_Warning

// MARK: - Mock UserDefaults

/// Mock implementation of UserDefaults for testing
class MockUserDefaults: UserDefaults {
    
    private var storage: [String: Any] = [:]
    
    override func set(_ value: Any?, forKey defaultName: String) {
        storage[defaultName] = value
    }
    
    override func object(forKey defaultName: String) -> Any? {
        return storage[defaultName]
    }
    
    override func data(forKey defaultName: String) -> Data? {
        return storage[defaultName] as? Data
    }
    
    override func removeObject(forKey defaultName: String) {
        storage.removeValue(forKey: defaultName)
    }
    
    override func synchronize() -> Bool {
        return true
    }
    
    func clearAll() {
        storage.removeAll()
    }
}

// MARK: - Mock CLLocationManager

/// Mock implementation of CLLocationManager for testing
class MockCLLocationManager: CLLocationManager {
    
    // MARK: - Mock Properties
    
    var mockDelegate: CLLocationManagerDelegate?
    var mockAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    var mockLocation: CLLocation?
    var mockLocationServicesEnabled: Bool = true
    var mockAccuracyAuthorization: CLAccuracyAuthorization = .fullAccuracy
    
    // MARK: - Mock Implementation
    
    override var delegate: CLLocationManagerDelegate? {
        get { return mockDelegate }
        set { mockDelegate = newValue }
    }
    
    override var authorizationStatus: CLAuthorizationStatus {
        return mockAuthorizationStatus
    }
    
    override var location: CLLocation? {
        return mockLocation
    }
    
    override var accuracyAuthorization: CLAccuracyAuthorization {
        return mockAccuracyAuthorization
    }
    
    // MARK: - Mock Methods
    
    override func requestWhenInUseAuthorization() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.mockAuthorizationStatus = .authorizedWhenInUse
            // Note: didChangeAuthorization is deprecated, but we're not using it in the main app
            // This mock is only for testing purposes
        }
    }
    
    override func requestAlwaysAuthorization() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.mockAuthorizationStatus = .authorizedAlways
            // Note: didChangeAuthorization is deprecated, but we're not using it in the main app
            // This mock is only for testing purposes
        }
    }
    
    override func startUpdatingLocation() {
        // Mock implementation
    }
    
    override func stopUpdatingLocation() {
        // Mock implementation
    }
    
    // MARK: - Test Helpers
    
    func simulateLocationUpdate(_ location: CLLocation) {
        mockLocation = location
        mockDelegate?.locationManager?(self, didUpdateLocations: [location])
    }
    
    func simulateLocationError(_ error: Error) {
        mockDelegate?.locationManager?(self, didFailWithError: error)
    }
    
    func simulatePermissionDenied() {
        mockAuthorizationStatus = .denied
        // Note: didChangeAuthorization is deprecated, but we're not using it in the main app
        // This mock is only for testing purposes
    }
    
    func simulatePermissionGranted() {
        mockAuthorizationStatus = .authorizedWhenInUse
        // Note: didChangeAuthorization is deprecated, but we're not using it in the main app
        // This mock is only for testing purposes
    }
}

// MARK: - Mock CTTelephonyNetworkInfo

/// Mock implementation of CTTelephonyNetworkInfo for testing
/// Note: CTCarrier is deprecated in iOS 16.0, so we only mock the radio access technology
class MockCTTelephonyNetworkInfo: CTTelephonyNetworkInfo {
    
    // MARK: - Mock Properties
    
    var mockServiceCurrentRadioAccessTechnology: [String: String] = [:]
    
    // MARK: - Mock Implementation
    
    override var serviceCurrentRadioAccessTechnology: [String: String]? {
        return mockServiceCurrentRadioAccessTechnology.isEmpty ? nil : mockServiceCurrentRadioAccessTechnology
    }
    
    // MARK: - Test Helpers
    
    func simulateRadioAccessTechnologyChange(_ technology: String, forService service: String) {
        mockServiceCurrentRadioAccessTechnology[service] = technology
        // Simulate notification
        NotificationCenter.default.post(name: .CTServiceRadioAccessTechnologyDidChange, object: self)
    }
}

// MARK: - Mock UNUserNotificationCenter

/// Mock implementation of UNUserNotificationCenter for testing
class MockUNUserNotificationCenter: UNUserNotificationCenter {
    
    // MARK: - Mock Properties
    
    var mockDelegate: UNUserNotificationCenterDelegate?
    var mockAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    var mockNotificationSettings: UNNotificationSettings?
    var mockPendingNotifications: [UNNotificationRequest] = []
    var mockDeliveredNotifications: [UNNotificationRequest] = []
    var requestAuthorizationCalled: Bool = false
    
    // MARK: - Mock Implementation
    
    override var delegate: UNUserNotificationCenterDelegate? {
        get { return mockDelegate }
        set { mockDelegate = newValue }
    }
    
    // MARK: - Mock Methods
    
    override func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void) {
        requestAuthorizationCalled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.mockAuthorizationStatus = .authorized
            completionHandler(true, nil)
        }
    }
    
    override func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let settings = MockUNNotificationSettings(coder: NSCoder())!
            completionHandler(settings)
        }
    }
    
    override func getDeliveredNotifications(completionHandler: @escaping ([UNNotification]) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // For testing purposes, return empty array since we track requests separately
            completionHandler([])
        }
    }
    
    func simulateNotificationDelivery(_ request: UNNotificationRequest) {
        mockDeliveredNotifications.append(request)
    }
    
    func simulateNotificationTap(_ notification: UNNotification) {
        // Mock notification tap - UNNotificationResponse.init() is unavailable
        // mockDelegate?.userNotificationCenter?(self, didReceive: UNNotificationResponse(), withCompletionHandler: {})
    }
}

// MARK: - Mock UNNotificationSettings

/// Mock implementation of UNNotificationSettings for testing
class MockUNNotificationSettings: UNNotificationSettings {
    
    override var authorizationStatus: UNAuthorizationStatus {
        return .authorized
    }
    
    override var alertSetting: UNNotificationSetting {
        return .enabled
    }
    
    override var badgeSetting: UNNotificationSetting {
        return .enabled
    }
    
    override var soundSetting: UNNotificationSetting {
        return .enabled
    }
    
    override var notificationCenterSetting: UNNotificationSetting {
        return .enabled
    }
    
    override var lockScreenSetting: UNNotificationSetting {
        return .enabled
    }
    
    override var carPlaySetting: UNNotificationSetting {
        return .enabled
    }
    
    override var alertStyle: UNAlertStyle {
        return .alert
    }
    
    override var showPreviewsSetting: UNShowPreviewsSetting {
        return .always
    }
    
    override var criticalAlertSetting: UNNotificationSetting {
        return .enabled
    }
    
    override var providesAppNotificationSettings: Bool {
        return true
    }
    
    override var announcementSetting: UNNotificationSetting {
        return .enabled
    }
}

// MARK: - Mock BGTaskScheduler

/// Mock implementation of BGTaskScheduler for testing
class MockBGTaskScheduler: BGTaskScheduler {
    
    // MARK: - Mock Properties
    
    var mockRegisteredTasks: [String: BGTaskRequest] = [:]
    var mockScheduledTasks: [String: BGTaskRequest] = [:]
    var mockTaskHandlers: [String: (BGTask) -> Void] = [:]
    
    // MARK: - Initialization
    
    // Note: BGTaskScheduler.init() is unavailable, so we can't provide a public initializer
    // Tests should use dependency injection or other patterns
    
    // MARK: - Mock Methods
    
    override func register(forTaskWithIdentifier identifier: String, using queue: DispatchQueue?, launchHandler: @escaping (BGTask) -> Void) -> Bool {
        mockTaskHandlers[identifier] = launchHandler
        return true
    }
    
    override func submit(_ request: BGTaskRequest) throws {
        mockScheduledTasks[request.identifier] = request
    }
    
    override func cancel(taskRequestWithIdentifier identifier: String) {
        mockScheduledTasks.removeValue(forKey: identifier)
    }
    
    override func cancelAllTaskRequests() {
        mockScheduledTasks.removeAll()
    }
    
    // MARK: - Test Helpers
    
    func simulateTaskExecution(identifier: String) {
        if mockTaskHandlers[identifier] != nil {
            // Note: Cannot instantiate MockBGTask due to unavailable initializer
            // This method is disabled until we implement proper dependency injection
        }
    }
    
    func simulateTaskExpiration(identifier: String) {
        if mockTaskHandlers[identifier] != nil {
            // Note: Cannot instantiate MockBGTask due to unavailable initializer
            // This method is disabled until we implement proper dependency injection
        }
    }
    
    func clearAllTasks() {
        mockRegisteredTasks.removeAll()
        mockScheduledTasks.removeAll()
        mockTaskHandlers.removeAll()
    }
}

// MARK: - Mock BGTask

/// Mock implementation of BGTask for testing
class MockBGTask: BGTask {
    
    // MARK: - Mock Properties
    
    var mockIdentifier: String
    var mockExpirationHandler: (() -> Void)?
    var mockCompleted: Bool = false
    
    // MARK: - Initialization
    
    // Note: BGTask.init() is unavailable, so we can't provide a public initializer
    // Tests should use dependency injection or other patterns
    // This class cannot be instantiated directly
    
    // MARK: - Mock Implementation
    
    override var identifier: String {
        return mockIdentifier
    }
    
    override var expirationHandler: (() -> Void)? {
        get { return mockExpirationHandler }
        set { mockExpirationHandler = newValue }
    }
    
    override func setTaskCompleted(success: Bool) {
        mockCompleted = success
    }
}

// MARK: - Mock EventStore

/// Mock implementation of EventStore for testing
class MockEventStore: EventStore {
    
    // MARK: - Mock Properties
    
    var mockEvents: [NetworkEvent] = []
    var mockAnomalies: [NetworkAnomaly] = []
    var addedEvents: [NetworkEvent] = []
    
    // MARK: - Mock Implementation
    
    override var events: [NetworkEvent] {
        get { return mockEvents }
        set { mockEvents = newValue }
    }
    
    override var anomalies: [NetworkAnomaly] {
        get { return mockAnomalies }
        set { mockAnomalies = newValue }
    }
    
    override func addEvent(_ event: NetworkEvent) {
        mockEvents.append(event)
        addedEvents.append(event)
    }
    
    override func addAnomaly(_ anomaly: NetworkAnomaly) {
        mockAnomalies.append(anomaly)
    }
    
    override func getEvents(threatLevel: NetworkThreatLevel? = nil) -> [NetworkEvent] {
        if let level = threatLevel {
            return mockEvents.filter { $0.threatLevel == level }
        }
        return mockEvents
    }
    
    override func getRecentEvents() -> [NetworkEvent] {
        return Array(mockEvents.suffix(100))
    }
    
    override func clearAllData() {
        mockEvents.removeAll()
        mockAnomalies.removeAll()
    }
    
    // MARK: - Test Helpers
    
    func reset() {
        mockEvents.removeAll()
        mockAnomalies.removeAll()
    }
}

// MARK: - Mock CellularSecurityMonitor

/// Mock implementation of CellularSecurityMonitor for testing
class MockCellularSecurityMonitor: CellularSecurityMonitor {
    
    // MARK: - Mock Properties
    
    var mockLastEvent: NetworkEvent?
    var mockLastAnomaly: NetworkAnomaly?
    var mockShouldAutoStart: Bool = false
    var shouldThrowError: Bool = false
    
    // MARK: - Mock Implementation
    
    override func startMonitoring() {
        // Mock implementation
    }
    
    override func stopMonitoring() {
        // Mock implementation
    }
    
    override func shouldAutoStartMonitoring() -> Bool {
        return mockShouldAutoStart
    }
    
    override func performSecurityCheck() {
        // Mock implementation
    }
    
    // MARK: - Test Helpers
    
    func simulateNetworkEvent(_ event: NetworkEvent) {
        mockLastEvent = event
    }
    
    func simulateNetworkAnomaly(_ anomaly: NetworkAnomaly) {
        mockLastAnomaly = anomaly
    }
}