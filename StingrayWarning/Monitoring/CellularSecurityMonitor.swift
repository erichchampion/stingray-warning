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
    
    private let maxRecentEvents = AppConstants.Limits.maxRecentEvents
    private let anomalyDetectionWindow = AppConstants.TimeIntervals.anomalyDetectionWindow
    private let rapidChangeThreshold = AppConstants.Limits.rapidChangeThreshold
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupLocationManager()
        loadBaselineData()
        setupNotificationObserver()
        restoreMonitoringState()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Set the event store reference
    func setEventStore(_ store: EventStore) {
        self.eventStore = store
    }
    
    /// Set the background task manager reference
    func setBackgroundTaskManager(_ manager: BackgroundTaskManager) {
        self.backgroundTaskManager = manager
    }
    
    // MARK: - Internal Methods (for testing)
    
    #if DEBUG
    internal var testEventStore: EventStore? {
        return self.eventStore
    }
    
    internal var testBackgroundTaskManager: BackgroundTaskManager? {
        return self.backgroundTaskManager
    }
    #endif
    
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
        return UserDefaultsManager.getMonitoringEnabled()
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
        locationManager.desiredAccuracy = AppConstants.LocationSettings.desiredAccuracy
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
        do {
            if let baseline = try UserDefaultsManager.getCodable(NetworkBaseline.self, forKey: AppConstants.UserDefaultsKeys.networkBaseline) {
                self.baselineData = baseline
            }
        } catch {
            // Handle error silently - baseline will be established on next check
        }
    }
    
    private func saveBaselineData() {
        guard let baseline = baselineData else { return }
        do {
            try UserDefaultsManager.setCodable(baseline, forKey: AppConstants.UserDefaultsKeys.networkBaseline)
        } catch {
            // Handle error silently
        }
    }
    
    private func saveMonitoringState() {
        UserDefaultsManager.setMonitoringEnabled(isMonitoring)
    }
    
    private func restoreMonitoringState() {
        let wasMonitoring = UserDefaultsManager.getMonitoringEnabled()
        isMonitoring = wasMonitoring
        // Don't set hasStartedMonitoring here - that will be set when startMonitoring() actually runs
    }
    
    private func performInitialCheck() {
        performSecurityCheck()
        establishBaselineIfNeeded()
    }
    
    private func schedulePeriodicChecks() {
        // Schedule background task for periodic monitoring
        if let bgManager = backgroundTaskManager {
            bgManager.startBackgroundMonitoring()
        }
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
    
    private func evaluateThreatLevel(radioTechnology: String?, carrierName: String? = nil) -> NetworkThreatLevel {
        var threatScore = 0
        
        // Check for 2G connection
        if let tech = radioTechnology, is2GTechnology(tech) {
            threatScore += AppConstants.ThreatScoring.twoGConnectionScore
        }
        
        // Basic carrier validation based on carrier name patterns
        // Note: This is a simplified approach since carrier APIs are deprecated
        if let carrier = carrierName {
            threatScore += getSuspiciousCarrierScore(carrier)
        }
        
        // Check for rapid technology changes
        if hasRapidTechnologyChanges() {
            threatScore += AppConstants.ThreatScoring.rapidChangeScore
        }
        
        // Check against baseline
        if baselineData != nil, !matchesBaseline(radioTechnology: radioTechnology) {
            threatScore += AppConstants.ThreatScoring.baselineMismatchScore
        }
        
        // Convert score to threat level
        switch threatScore {
        case AppConstants.ThreatScoring.noneThreshold: return .none
        case AppConstants.ThreatScoring.lowThreshold: return .low
        case AppConstants.ThreatScoring.mediumThreshold...AppConstants.ThreatScoring.highThreshold: return .medium
        case AppConstants.ThreatScoring.highThreshold+1...AppConstants.ThreatScoring.criticalThreshold: return .high
        default: return .critical
        }
    }
    
    private func is2GTechnology(_ technology: String) -> Bool {
        let twoGTechnologies = ["CTRadioAccessTechnologyGSM", "CTRadioAccessTechnologyGPRS", "CTRadioAccessTechnologyEdge"]
        return twoGTechnologies.contains(technology)
    }
    
    private func getSuspiciousCarrierScore(_ carrierName: String) -> Int {
        switch carrierName {
        case "Unknown Carrier", "Unknown", "Unknown Network":
            return 4 // High threat
        case "Rogue Base Station", "Fake Carrier", "IMSI Catcher":
            return 5 // Critical threat
        default:
            return 0 // No threat
        }
    }
    
    private func hasRapidTechnologyChanges() -> Bool {
        let recentWindow = Date().addingTimeInterval(-anomalyDetectionWindow)
        let recentEventsInWindow = recentEvents.filter { $0.timestamp >= recentWindow }
        
        // Count only events where the technology actually changed from the previous event
        var technologyChanges = 0
        var previousTechnology: String? = nil
        
        for event in recentEventsInWindow {
            if let currentTech = event.radioTechnology, currentTech != previousTechnology {
                technologyChanges += 1
                previousTechnology = currentTech
            }
        }
        
        return technologyChanges >= rapidChangeThreshold
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
    
    func processNetworkEvent(_ event: NetworkEvent) {
        // Use the original threat level if it's explicitly set to something other than .none
        // Otherwise, re-evaluate based on radio technology and carrier name
        let finalThreatLevel: NetworkThreatLevel
        if event.threatLevel != .none {
            finalThreatLevel = event.threatLevel
        } else {
            finalThreatLevel = evaluateThreatLevel(radioTechnology: event.radioTechnology, carrierName: event.carrierName)
        }
        
        // Create updated event with final threat level
        let updatedEvent = NetworkEvent(
            radioTechnology: event.radioTechnology,
            carrierName: event.carrierName,
            carrierCountryCode: event.carrierCountryCode,
            carrierMobileCountryCode: event.carrierMobileCountryCode,
            carrierMobileNetworkCode: event.carrierMobileNetworkCode,
            threatLevel: finalThreatLevel,
            description: event.description,
            locationContext: event.locationContext
        )
        
        // Check if this event should be filtered out to reduce noise
        if shouldFilterEvent(updatedEvent) {
            // Still update current state for UI, but don't store the event
            currentNetworkInfo = updatedEvent
            currentThreatLevel = updatedEvent.threatLevel
            return
        }
        
        // Add to recent events
        recentEvents.append(updatedEvent)
        
        // Trim to max size
        if recentEvents.count > maxRecentEvents {
            recentEvents.removeFirst(recentEvents.count - maxRecentEvents)
        }
        
        // Add to event store
        eventStore?.addEvent(updatedEvent)
        
        // Update current state
        currentNetworkInfo = updatedEvent
        currentThreatLevel = updatedEvent.threatLevel
        
        // Check for anomalies
        detectAnomalies(for: updatedEvent)
        
        // Send notifications if needed
        if updatedEvent.threatLevel.requiresNotification {
            sendNotification(for: updatedEvent)
        }
    }
    
    private func shouldFilterEvent(_ event: NetworkEvent) -> Bool {
        // Don't store events if they are identical to the previous event
        guard let lastEvent = recentEvents.last else { return false }
        
        // Special case: don't filter events with nil radio technology
        if event.radioTechnology == nil || lastEvent.radioTechnology == nil {
            return false
        }
        
        // Check if radio technology is the same
        let sameTechnology = event.radioTechnology == lastEvent.radioTechnology
        
        // Check if carrier name is the same
        let sameCarrier = event.carrierName == lastEvent.carrierName
        
        // Check if threat level is the same
        let sameThreatLevel = event.threatLevel == lastEvent.threatLevel
        
        // Filter out if technology, carrier, and threat level are all the same
        return sameTechnology && sameCarrier && sameThreatLevel
    }
    
    private func detectAnomalies(for event: NetworkEvent) {
        // Check for rapid technology changes
        if hasRapidTechnologyChanges() {
            let anomaly = NetworkAnomaly(
                anomalyType: .rapidTechnologyChange,
                severity: .medium,
                description: "Rapid technology changes detected",
                relatedEvents: Array(recentEvents.suffix(rapidChangeThreshold).map { $0.id }),
                confidence: 0.8
            )
            activeAnomalies.append(anomaly)
            eventStore?.addAnomaly(anomaly)
        }
        
        // Check for suspicious 2G connections
        if event.is2GConnection && event.threatLevel.rawValue >= NetworkThreatLevel.medium.rawValue {
            let anomaly = NetworkAnomaly(
                anomalyType: .suspicious2GConnection,
                severity: event.threatLevel == .critical ? .high : .medium,
                description: "Suspicious 2G connection detected",
                relatedEvents: [event.id],
                confidence: 0.7
            )
            activeAnomalies.append(anomaly)
            eventStore?.addAnomaly(anomaly)
        }
        
        // Check for baseline mismatches
        if let _ = baselineData, !matchesBaseline(radioTechnology: event.radioTechnology) {
            let anomaly = NetworkAnomaly(
                anomalyType: .unusualSignalPattern,
                severity: .low,
                description: "Network behavior deviates from baseline",
                relatedEvents: [event.id],
                confidence: 0.6
            )
            activeAnomalies.append(anomaly)
            eventStore?.addAnomaly(anomaly)
        }
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
