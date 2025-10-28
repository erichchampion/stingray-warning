import Foundation

/// Represents the threat level of a detected network anomaly
enum NetworkThreatLevel: String, CaseIterable, Codable {
    case none = "none"
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
    
    /// Human-readable description of the threat level
    var description: String {
        switch self {
        case .none:
            return "No Threat Detected"
        case .low:
            return "Low Risk"
        case .medium:
            return "Medium Risk"
        case .high:
            return "High Risk"
        case .critical:
            return "Critical Threat"
        }
    }
    
    /// Priority score for sorting and alerting
    var priority: Int {
        switch self {
        case .none: return 0
        case .low: return 1
        case .medium: return 2
        case .high: return 3
        case .critical: return 4
        }
    }
    
    /// Whether this threat level should trigger an immediate alert
    var requiresImmediateAlert: Bool {
        return self == .high || self == .critical
    }
    
    /// Whether this threat level should trigger a notification
    var requiresNotification: Bool {
        return self != .none
    }
}
