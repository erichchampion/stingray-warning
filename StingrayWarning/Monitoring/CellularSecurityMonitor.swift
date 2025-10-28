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
    
    private func evaluateThreatLevel(radioTechnology: String?) -> NetworkThreatLevel {
        var threatScore = 0
        
        // Check for 2G connection
        if let tech = radioTechnology, is2GTechnology(tech) {
            threatScore += AppConstants.ThreatScoring.twoGConnectionScore
        }
        
        // Note: Carrier validation removed due to deprecated APIs in iOS 16+
        // Carrier information APIs now return placeholder values
        
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
        case AppConstants.ThreatScoring.mediumThreshold...3: return .medium
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
        // Check if this event should be filtered out to reduce noise
        if shouldFilterEvent(event) {
            // Still update current state for UI, but don't store the event
            currentNetworkInfo = event
            currentThreatLevel = event.threatLevel
            return
        }
        
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
    
    private func shouldFilterEvent(_ event: NetworkEvent) -> Bool {
        // Don't store events if they are the same as the previous event and threat level is none
        guard let lastEvent = recentEvents.last else { return false }
        
        // Check if radio technology is the same
        let sameTechnology = event.radioTechnology == lastEvent.radioTechnology
        
        // Check if threat level is none
        let isNoThreat = event.threatLevel == .none
        
        // Filter out if both conditions are true
        return sameTechnology && isNoThreat
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
