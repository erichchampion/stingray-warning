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
    
    private let maxRecentEvents = 100
    private let anomalyDetectionWindow: TimeInterval = 300 // 5 minutes
    private let rapidChangeThreshold = 3 // changes per window
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupLocationManager()
        loadBaselineData()
        setupNotificationObserver()
    }
    
    /// Set the event store reference
    func setEventStore(_ store: EventStore) {
        self.eventStore = store
    }
    
    // MARK: - Public Methods
    
    /// Start monitoring cellular network security
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        isMonitoring = true
        performInitialCheck()
        schedulePeriodicChecks()
    }
    
    /// Stop monitoring cellular network security
    func stopMonitoring() {
        isMonitoring = false
        // Cancel any scheduled checks
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
    
    private func performInitialCheck() {
        performSecurityCheck()
        establishBaselineIfNeeded()
    }
    
    private func schedulePeriodicChecks() {
        // Schedule background task for periodic monitoring
        // This would be implemented with BGTaskScheduler
    }
    
    private func createNetworkEvent() -> NetworkEvent {
        let serviceCurrentRadioAccessTechnology = networkInfo.serviceCurrentRadioAccessTechnology
        
        var radioTechnology: String?
        var carrierName: String?
        var carrierCountryCode: String?
        var carrierMobileCountryCode: String?
        var carrierMobileNetworkCode: String?
        
        if let serviceRadioAccessTechnology = serviceCurrentRadioAccessTechnology {
            radioTechnology = serviceRadioAccessTechnology.first?.value
        }
        
        if let carrierInfo = networkInfo.serviceSubscriberCellularProviders?.first?.value {
            carrierName = carrierInfo.carrierName
            carrierCountryCode = carrierInfo.isoCountryCode
            carrierMobileCountryCode = carrierInfo.mobileCountryCode
            carrierMobileNetworkCode = carrierInfo.mobileNetworkCode
        }
        
        let threatLevel = evaluateThreatLevel(
            radioTechnology: radioTechnology,
            carrierInfo: networkInfo.serviceSubscriberCellularProviders?.first?.value
        )
        
        let description = generateEventDescription(
            radioTechnology: radioTechnology,
            carrierName: carrierName,
            threatLevel: threatLevel
        )
        
        return NetworkEvent(
            radioTechnology: radioTechnology,
            carrierName: carrierName,
            carrierCountryCode: carrierCountryCode,
            carrierMobileCountryCode: carrierMobileCountryCode,
            carrierMobileNetworkCode: carrierMobileNetworkCode,
            threatLevel: threatLevel,
            description: description
        )
    }
    
    private func evaluateThreatLevel(radioTechnology: String?, carrierInfo: CTCarrier?) -> NetworkThreatLevel {
        var threatScore = 0
        
        // Check for 2G connection
        if let tech = radioTechnology, is2GTechnology(tech) {
            threatScore += 3
        }
        
        // Check for unknown carrier
        if carrierInfo?.carrierName == nil || carrierInfo?.carrierName?.isEmpty == true {
            threatScore += 2
        }
        
        // Check for rapid technology changes
        if hasRapidTechnologyChanges() {
            threatScore += 2
        }
        
        // Check against baseline
        if baselineData != nil, !matchesBaseline(radioTechnology: radioTechnology, carrierInfo: carrierInfo) {
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
    
    private func matchesBaseline(radioTechnology: String?, carrierInfo: CTCarrier?) -> Bool {
        guard let baseline = baselineData else { return true }
        
        if let tech = radioTechnology, let baselineTech = baseline.expectedRadioTechnology {
            return tech == baselineTech
        }
        
        if let carrier = carrierInfo?.carrierName, let baselineCarrier = baseline.expectedCarrierName {
            return carrier == baselineCarrier
        }
        
        return true
    }
    
    private func generateEventDescription(radioTechnology: String?, carrierName: String?, threatLevel: NetworkThreatLevel) -> String {
        var components: [String] = []
        
        if let tech = radioTechnology {
            components.append("Radio: \(tech)")
        }
        
        if let carrier = carrierName {
            components.append("Carrier: \(carrier)")
        } else {
            components.append("Unknown carrier")
        }
        
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
