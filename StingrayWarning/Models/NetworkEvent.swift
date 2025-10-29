import Foundation
import CoreTelephony

/// Represents a network detection event
struct NetworkEvent: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let radioTechnology: String?
    let carrierName: String?
    let carrierCountryCode: String?
    let carrierMobileCountryCode: String?
    let carrierMobileNetworkCode: String?
    let threatLevel: NetworkThreatLevel
    let description: String
    
    
    init(
        radioTechnology: String? = nil,
        carrierName: String? = nil,
        carrierCountryCode: String? = nil,
        carrierMobileCountryCode: String? = nil,
        carrierMobileNetworkCode: String? = nil,
        threatLevel: NetworkThreatLevel,
        description: String
    ) {
        self.id = UUID()
        self.timestamp = Date()
        self.radioTechnology = radioTechnology
        self.carrierName = carrierName
        self.carrierCountryCode = carrierCountryCode
        self.carrierMobileCountryCode = carrierMobileCountryCode
        self.carrierMobileNetworkCode = carrierMobileNetworkCode
        self.threatLevel = threatLevel
        self.description = description
    }
    
    /// Human-readable summary of the event
    var summary: String {
        var components: [String] = []
        
        if let tech = radioTechnology {
            components.append("Technology: \(tech)")
        }
        
        if let carrier = carrierName {
            components.append("Carrier: \(carrier)")
        }
        
        if let mcc = carrierMobileCountryCode, let mnc = carrierMobileNetworkCode {
            components.append("MCC/MNC: \(mcc)/\(mnc)")
        }
        
        components.append("Threat: \(threatLevel.description)")
        
        return components.joined(separator: " • ")
    }
    
    /// Whether this event represents a 2G connection
    var is2GConnection: Bool {
        guard let tech = radioTechnology else { return false }
        let twoGTechnologies = ["CTRadioAccessTechnologyGSM", "CTRadioAccessTechnologyGPRS", "CTRadioAccessTechnologyEdge"]
        return twoGTechnologies.contains(tech)
    }
    
    /// Whether this event represents a suspicious carrier
    var isSuspiciousCarrier: Bool {
        // Note: Carrier validation removed due to deprecated APIs in iOS 16+
        // Carrier information APIs now return placeholder values
        return false
    }
}

 
