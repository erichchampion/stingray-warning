import Foundation
import CoreTelephony
import CoreLocation
import UserNotifications

/// Main class for monitoring cellular network security
class CellularSecurityMonitor: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentThreatLevel: NetworkThreatLevel = .none
    @Published var isMonitoring: Bool = false
    @Published var lastCheckTime: Date?
    @Published var currentNetworkInfo: NetworkEvent?
    
    // MARK: - Private Properties
    private let networkInfo = CTTelephonyNetworkInfo()
    private let locationManager = CLLocationManager()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private var baselineData: NetworkBaseline?
    private var recentEvents: [NetworkEvent] = []
    private var activeAnomalies: [NetworkAnomaly] = []
    private weak var eventStore: EventStore?
    private weak var backgroundTaskManager: BackgroundTaskManager?
    private var hasStartedMonitoring = false // Track if monitoring has actually been started
    
    private let maxRecentEvents = 100
    private let anomalyDetectionWindow: TimeInterval = 300 // 5 minutes
    private let rapidChangeThreshold = 3 // changes per window
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupLocationManager()
        loadBaselineData()
        setupNotificationObserver()
        restoreMonitoringState()
    }
    
    /// Set the event store reference
    func setEventStore(_ store: EventStore) {
        self.eventStore = store
    }
    
    /// Set the background task manager reference
    func setBackgroundTaskManager(_ manager: BackgroundTaskManager) {
        self.backgroundTaskManager = manager
    }
    
    // MARK: - Public Methods
    
    /// Start monitoring cellular network security
    func startMonitoring() {
        guard !isMonitoring else { 
            // If already monitoring, ensure we have current data
            if !hasStartedMonitoring {
                // Monitoring state was restored but actual monitoring never started
                hasStartedMonitoring = true
                performInitialCheck()
                schedulePeriodicChecks()
            }
            return 
        }
        
        isMonitoring = true
        hasStartedMonitoring = true
        saveMonitoringState()
        performInitialCheck()
        schedulePeriodicChecks()
    }
    
    /// Stop monitoring cellular network security
    func stopMonitoring() {
        isMonitoring = false
        hasStartedMonitoring = false
        saveMonitoringState()
        // Stop background monitoring
        backgroundTaskManager?.stopBackgroundMonitoring()
    }
    
    /// Check if monitoring should be automatically started based on persistent state
    func shouldAutoStartMonitoring() -> Bool {
        return UserDefaults.standard.bool(forKey: "monitoringEnabled")
    }
    
    /// Perform an immediate security check
    func performSecurityCheck() {
        let event = createNetworkEvent()
        processNetworkEvent(event)
        lastCheckTime = Date()
    }
    
    // MARK: - Private Methods
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkTechnologyDidChange),
            name: .CTServiceRadioAccessTechnologyDidChange,
            object: nil
        )
    }
    
    private func loadBaselineData() {
        // Load baseline data from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "NetworkBaseline"),
           let baseline = try? JSONDecoder().decode(NetworkBaseline.self, from: data) {
            self.baselineData = baseline
        }
    }
    
    private func saveBaselineData() {
        guard let baseline = baselineData else { return }
        if let data = try? JSONEncoder().encode(baseline) {
            UserDefaults.standard.set(data, forKey: "NetworkBaseline")
        }
    }
    
    private func saveMonitoringState() {
        UserDefaults.standard.set(isMonitoring, forKey: "monitoringEnabled")
    }
    
    private func restoreMonitoringState() {
        let wasMonitoring = UserDefaults.standard.bool(forKey: "monitoringEnabled")
        isMonitoring = wasMonitoring
        // Don't set hasStartedMonitoring here - that will be set when startMonitoring() actually runs
    }
    
    private func performInitialCheck() {
        performSecurityCheck()
        establishBaselineIfNeeded()
    }
    
    private func schedulePeriodicChecks() {
        // Schedule background task for periodic monitoring
        backgroundTaskManager?.startBackgroundMonitoring()
    }
    
    private func createNetworkEvent() -> NetworkEvent {
        let serviceCurrentRadioAccessTechnology = networkInfo.serviceCurrentRadioAccessTechnology
        
        var radioTechnology: String?
        
        if let serviceRadioAccessTechnology = serviceCurrentRadioAccessTechnology {
            radioTechnology = serviceRadioAccessTechnology.first?.value
        }
        
        // Note: Carrier information APIs are deprecated in iOS 16+ and return placeholder values
        // Focus on radio technology detection which is still functional
        let threatLevel = evaluateThreatLevel(radioTechnology: radioTechnology)
        
        let description = generateEventDescription(
            radioTechnology: radioTechnology,
            threatLevel: threatLevel
        )
        
        return NetworkEvent(
            radioTechnology: radioTechnology,
            carrierName: nil, // Deprecated API
            carrierCountryCode: nil, // Deprecated API
            carrierMobileCountryCode: nil, // Deprecated API
            carrierMobileNetworkCode: nil, // Deprecated API
            threatLevel: threatLevel,
            description: description
        )
    }
    
    private func evaluateThreatLevel(radioTechnology: String?) -> NetworkThreatLevel {
        var threatScore = 0
        
        // Check for 2G connection
        if let tech = radioTechnology, is2GTechnology(tech) {
            threatScore += 3
        }
        
        // Note: Carrier validation removed due to deprecated APIs in iOS 16+
        // Carrier information APIs now return placeholder values
        
        // Check for rapid technology changes
        if hasRapidTechnologyChanges() {
            threatScore += 2
        }
        
        // Check against baseline
        if baselineData != nil, !matchesBaseline(radioTechnology: radioTechnology) {
            threatScore += 1
        }
        
        // Convert score to threat level
        switch threatScore {
        case 0: return .none
        case 1: return .low
        case 2...3: return .medium
        case 4...5: return .high
        default: return .critical
        }
    }
    
    private func is2GTechnology(_ technology: String) -> Bool {
        let twoGTechnologies = ["CTRadioAccessTechnologyGPRS", "CTRadioAccessTechnologyEdge"]
        return twoGTechnologies.contains(technology)
    }
    
    private func hasRapidTechnologyChanges() -> Bool {
        let recentWindow = Date().addingTimeInterval(-anomalyDetectionWindow)
        let recentChanges = recentEvents.filter { $0.timestamp >= recentWindow }
        return recentChanges.count >= rapidChangeThreshold
    }
    
    private func matchesBaseline(radioTechnology: String?) -> Bool {
        guard let baseline = baselineData else { return true }
        
        if let tech = radioTechnology, let baselineTech = baseline.expectedRadioTechnology {
            return tech == baselineTech
        }
        
        // Note: Carrier matching removed due to deprecated APIs
        return true
    }
    
    private func generateEventDescription(radioTechnology: String?, threatLevel: NetworkThreatLevel) -> String {
        var components: [String] = []
        
        if let tech = radioTechnology {
            components.append("Radio: \(tech)")
        } else {
            components.append("Radio: Unknown")
        }
        
        // Note: Carrier information removed due to deprecated APIs in iOS 16+
        components.append("Threat: \(threatLevel.description)")
        
        return components.joined(separator: " • ")
    }
    
    private func processNetworkEvent(_ event: NetworkEvent) {
        // Add to recent events
        recentEvents.append(event)
        
        // Trim to max size
        if recentEvents.count > maxRecentEvents {
            recentEvents.removeFirst(recentEvents.count - maxRecentEvents)
        }
        
        // Add to event store
        eventStore?.addEvent(event)
        
        // Update current state
        currentNetworkInfo = event
        currentThreatLevel = event.threatLevel
        
        // Check for anomalies
        detectAnomalies(for: event)
        
        // Send notifications if needed
        if event.threatLevel.requiresNotification {
            sendNotification(for: event)
        }
    }
    
    private func detectAnomalies(for event: NetworkEvent) {
        // Implement anomaly detection logic
        // This would analyze patterns in recentEvents to identify suspicious behavior
    }
    
    private func sendNotification(for event: NetworkEvent) {
        // Implement notification sending logic
        // This would create and send local notifications based on threat level
    }
    
    private func establishBaselineIfNeeded() {
        guard baselineData == nil else { return }
        
        // Collect baseline data over time
        // This would be implemented to learn normal network behavior
    }
    
    @objc private func networkTechnologyDidChange() {
        guard isMonitoring else { return }
        performSecurityCheck()
    }
}

// MARK: - CLLocationManagerDelegate
extension CellularSecurityMonitor: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Handle location updates for context
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle location errors
    }
}

// MARK: - Supporting Types
struct NetworkBaseline: Codable {
    let expectedRadioTechnology: String?
    let expectedCarrierName: String?
    let expectedMobileCountryCode: String?
    let expectedMobileNetworkCode: String?
    let establishedDate: Date
    let sampleCount: Int
    
    init(expectedRadioTechnology: String? = nil, 
         expectedCarrierName: String? = nil,
         expectedMobileCountryCode: String? = nil,
         expectedMobileNetworkCode: String? = nil,
         sampleCount: Int = 0) {
        self.expectedRadioTechnology = expectedRadioTechnology
        self.expectedCarrierName = expectedCarrierName
        self.expectedMobileCountryCode = expectedMobileCountryCode
        self.expectedMobileNetworkCode = expectedMobileNetworkCode
        self.establishedDate = Date()
        self.sampleCount = sampleCount
    }
}
