import Foundation

/// Represents a detected network anomaly pattern
struct NetworkAnomaly: Codable, Identifiable {
    let id: UUID
    let startTime: Date
    let endTime: Date?
    let anomalyType: AnomalyType
    let severity: NetworkThreatLevel
    let description: String
    let relatedEvents: [UUID] // References to NetworkEvent IDs
    let confidence: Double // 0.0 to 1.0
    let locationContext: LocationContext?
    
    init(
        anomalyType: AnomalyType,
        severity: NetworkThreatLevel,
        description: String,
        relatedEvents: [UUID] = [],
        confidence: Double = 0.5,
        locationContext: LocationContext? = nil
    ) {
        self.id = UUID()
        self.startTime = Date()
        self.endTime = nil
        self.anomalyType = anomalyType
        self.severity = severity
        self.description = description
        self.relatedEvents = relatedEvents
        self.confidence = confidence
        self.locationContext = locationContext
    }
    
    /// Duration of the anomaly (if ended)
    var duration: TimeInterval? {
        guard let endTime = endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }
    
    /// Whether the anomaly is currently active
    var isActive: Bool {
        return endTime == nil
    }
    
    /// Human-readable summary of the anomaly
    var summary: String {
        let durationText = isActive ? "ongoing" : "\(Int(duration ?? 0))s"
        return "\(anomalyType.description) (\(severity.description)) - \(durationText)"
    }
}

/// Types of network anomalies that can be detected
enum AnomalyType: String, CaseIterable, Codable {
    case rapidTechnologyChange = "rapid_technology_change"
    case suspicious2GConnection = "suspicious_2g_connection"
    case unknownCarrier = "unknown_carrier"
    case unusualSignalPattern = "unusual_signal_pattern"
    case networkDowngrade = "network_downgrade"
    case carrierSpoofing = "carrier_spoofing"
    case imsiCatcherSuspected = "imsi_catcher_suspected"
    
    var description: String {
        switch self {
        case .rapidTechnologyChange:
            return "Rapid Technology Changes"
        case .suspicious2GConnection:
            return "Suspicious 2G Connection"
        case .unknownCarrier:
            return "Unknown Carrier"
        case .unusualSignalPattern:
            return "Unusual Signal Pattern"
        case .networkDowngrade:
            return "Network Downgrade"
        case .carrierSpoofing:
            return "Carrier Spoofing"
        case .imsiCatcherSuspected:
            return "IMSI Catcher Suspected"
        }
    }
    
    var detailedDescription: String {
        switch self {
        case .rapidTechnologyChange:
            return "Multiple rapid changes between network technologies detected, which may indicate active surveillance equipment."
        case .suspicious2GConnection:
            return "Connection to 2G network detected. 2G networks are vulnerable to interception and should be avoided when possible."
        case .unknownCarrier:
            return "Connection to an unknown or unregistered carrier detected, which may indicate a rogue base station."
        case .unusualSignalPattern:
            return "Unusual signal strength patterns detected that may indicate nearby surveillance equipment."
        case .networkDowngrade:
            return "Network technology downgraded unexpectedly, potentially forcing connection to vulnerable protocols."
        case .carrierSpoofing:
            return "Carrier information appears to be spoofed or inconsistent with expected values."
        case .imsiCatcherSuspected:
            return "Multiple indicators suggest the presence of an IMSI catcher or similar surveillance device."
        }
    }
    
    /// Recommended action for this anomaly type
    var recommendedAction: String {
        switch self {
        case .rapidTechnologyChange, .suspicious2GConnection, .networkDowngrade:
            return "Consider switching to airplane mode and reconnecting, or moving to a different location."
        case .unknownCarrier, .carrierSpoofing, .imsiCatcherSuspected:
            return "Immediately switch to airplane mode and avoid sensitive communications."
        case .unusualSignalPattern:
            return "Monitor the situation and consider moving to a different location if patterns persist."
        }
    }
}
