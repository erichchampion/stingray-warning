import Foundation
import XCTest
import CoreTelephony
import CoreLocation
import UserNotifications
import BackgroundTasks
@testable import Stingray_Warning

// MARK: - Test Data Factory

/// Factory for creating test data objects
class TestDataFactory {
    
    // MARK: - NetworkEvent Creation
    
    static func createNetworkEvent(
        radioTechnology: String? = "CTRadioAccessTechnologyLTE",
        carrierName: String? = "Test Carrier",
        carrierCountryCode: String? = "US",
        carrierMobileCountryCode: String? = "310",
        carrierMobileNetworkCode: String? = "260",
        threatLevel: NetworkThreatLevel = .none,
        description: String? = nil,
        locationContext: LocationContext? = nil
    ) -> NetworkEvent {
        return NetworkEvent(
            radioTechnology: radioTechnology,
            carrierName: carrierName,
            carrierCountryCode: carrierCountryCode,
            carrierMobileCountryCode: carrierMobileCountryCode,
            carrierMobileNetworkCode: carrierMobileNetworkCode,
            threatLevel: threatLevel,
            description: description ?? "Test network event",
            locationContext: locationContext
        )
    }
    
    static func create2GNetworkEvent() -> NetworkEvent {
        return createNetworkEvent(
            radioTechnology: "CTRadioAccessTechnologyGSM",
            threatLevel: .medium,
            description: "2G network detected"
        )
    }
    
    static func create5GNetworkEvent() -> NetworkEvent {
        return createNetworkEvent(
            radioTechnology: "CTRadioAccessTechnologyNRNSA",
            threatLevel: .none,
            description: "5G network detected"
        )
    }
    
    static func createHighThreatEvent() -> NetworkEvent {
        return createNetworkEvent(
            radioTechnology: "CTRadioAccessTechnologyGSM",
            carrierName: "Unknown Carrier",
            threatLevel: .high,
            description: "Suspicious network detected"
        )
    }
    
    // MARK: - NetworkAnomaly Creation
    
    static func createNetworkAnomaly(
        anomalyType: AnomalyType = .suspicious2GConnection,
        severity: NetworkThreatLevel = .medium,
        description: String? = nil,
        relatedEvents: [UUID] = [],
        confidence: Double = 0.8,
        locationContext: LocationContext? = nil
    ) -> NetworkAnomaly {
        return NetworkAnomaly(
            anomalyType: anomalyType,
            severity: severity,
            description: description ?? "Test anomaly",
            relatedEvents: relatedEvents,
            confidence: confidence,
            locationContext: locationContext
        )
    }
    
    static func createActiveAnomaly() -> NetworkAnomaly {
        return createNetworkAnomaly(
            anomalyType: .imsiCatcherSuspected,
            severity: .critical,
            description: "Active IMSI catcher detected"
        )
    }
    
    static func createCompletedAnomaly() -> NetworkAnomaly {
        let anomaly = createNetworkAnomaly(
            anomalyType: .rapidTechnologyChange,
            severity: .high,
            description: "Completed rapid technology change"
        )
        // Note: We can't modify endTime directly, so this represents a completed anomaly conceptually
        return anomaly
    }
    
    // MARK: - LocationContext Creation
    
    static func createLocationContext(
        latitude: Double? = 37.7749,
        longitude: Double? = -122.4194,
        accuracy: Double? = 10.0
    ) -> LocationContext {
        return LocationContext(
            latitude: latitude,
            longitude: longitude,
            accuracy: accuracy
        )
    }
    
    static func createPartialLocationContext() -> LocationContext {
        return LocationContext(
            latitude: 37.7749,
            longitude: nil,
            accuracy: 10.0
        )
    }
    
    static func createNilLocationContext() -> LocationContext {
        return LocationContext(
            latitude: nil,
            longitude: nil,
            accuracy: nil
        )
    }
    
    // MARK: - Test Scenarios
    
    static func createRapidTechnologyChangeScenario() -> [NetworkEvent] {
        return [
            createNetworkEvent(radioTechnology: "CTRadioAccessTechnologyLTE", threatLevel: .none),
            createNetworkEvent(radioTechnology: "CTRadioAccessTechnologyGSM", threatLevel: .medium),
            createNetworkEvent(radioTechnology: "CTRadioAccessTechnologyLTE", threatLevel: .low),
            createNetworkEvent(radioTechnology: "CTRadioAccessTechnologyGSM", threatLevel: .high)
        ]
    }
    
    static func createNormalNetworkScenario() -> [NetworkEvent] {
        return [
            createNetworkEvent(radioTechnology: "CTRadioAccessTechnologyLTE", threatLevel: .none),
            createNetworkEvent(radioTechnology: "CTRadioAccessTechnologyLTE", threatLevel: .none),
            createNetworkEvent(radioTechnology: "CTRadioAccessTechnologyLTE", threatLevel: .none)
        ]
    }
    
    static func createSuspiciousCarrierScenario() -> [NetworkEvent] {
        return [
            createNetworkEvent(carrierName: "Verizon", threatLevel: .none),
            createNetworkEvent(carrierName: "Unknown Carrier", threatLevel: .high),
            createNetworkEvent(carrierName: "Verizon", threatLevel: .none)
        ]
    }
}

// MARK: - Async Test Helpers

/// Utilities for testing asynchronous operations
class AsyncTestHelpers {
    
    /// Wait for an async operation to complete
    static func waitForAsync<T>(
        timeout: TimeInterval = 1.0,
        operation: @escaping (@escaping (T) -> Void) -> Void
    ) -> T? {
        let expectation = XCTestExpectation(description: "Async operation")
        var result: T?
        
        operation { value in
            result = value
            expectation.fulfill()
        }
        
        XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result
    }
    
    /// Wait for an async operation that returns a Result
    static func waitForAsyncResult<T>(
        timeout: TimeInterval = 1.0,
        operation: @escaping (@escaping (Result<T, Error>) -> Void) -> Void
    ) -> Result<T, Error>? {
        let expectation = XCTestExpectation(description: "Async result operation")
        var result: Result<T, Error>?
        
        operation { value in
            result = value
            expectation.fulfill()
        }
        
        XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result
    }
    
    /// Wait for a specific condition to be true
    static func waitForCondition(
        timeout: TimeInterval = 1.0,
        condition: @escaping () -> Bool
    ) -> Bool {
        let expectation = XCTestExpectation(description: "Condition met")
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if condition() {
                expectation.fulfill()
                timer.invalidate()
            }
        }
        
        XCTWaiter().wait(for: [expectation], timeout: timeout)
        timer.invalidate()
        return condition()
    }
}

// MARK: - Mock Data Generators

/// Generators for realistic test data
class MockDataGenerators {
    
    // MARK: - Radio Technology Data
    
    static let radioTechnologies = [
        "CTRadioAccessTechnologyLTE",
        "CTRadioAccessTechnologyGSM",
        "CTRadioAccessTechnologyEdge",
        "CTRadioAccessTechnologyWCDMA",
        "CTRadioAccessTechnologyHSDPA",
        "CTRadioAccessTechnologyHSUPA",
        "CTRadioAccessTechnologyCDMA1x",
        "CTRadioAccessTechnologyCDMAEVDORev0",
        "CTRadioAccessTechnologyCDMAEVDORevA",
        "CTRadioAccessTechnologyCDMAEVDORevB",
        "CTRadioAccessTechnologyNRNSA",
        "CTRadioAccessTechnologyNRSA"
    ]
    
    static let carrierNames = [
        "Verizon",
        "AT&T",
        "T-Mobile",
        "Sprint",
        "Unknown Carrier",
        "Rogue Base Station"
    ]
    
    static let countryCodes = [
        "US", "CA", "MX", "GB", "DE", "FR", "JP", "CN", "AU"
    ]
    
    static let mobileCountryCodes = [
        "310", "311", "312", "313", "314", "315", "316", "317", "318", "319"
    ]
    
    static let mobileNetworkCodes = [
        "260", "280", "410", "480", "490", "500", "510", "520", "530", "540"
    ]
    
    // MARK: - Random Data Generation
    
    static func randomRadioTechnology() -> String {
        return radioTechnologies.randomElement() ?? "CTRadioAccessTechnologyLTE"
    }
    
    static func randomCarrierName() -> String {
        return carrierNames.randomElement() ?? "Unknown Carrier"
    }
    
    static func randomCountryCode() -> String {
        return countryCodes.randomElement() ?? "US"
    }
    
    static func randomMobileCountryCode() -> String {
        return mobileCountryCodes.randomElement() ?? "310"
    }
    
    static func randomMobileNetworkCode() -> String {
        return mobileNetworkCodes.randomElement() ?? "260"
    }
    
    static func randomThreatLevel() -> NetworkThreatLevel {
        return NetworkThreatLevel.allCases.randomElement() ?? .none
    }
    
    static func randomAnomalyType() -> AnomalyType {
        return AnomalyType.allCases.randomElement() ?? .suspicious2GConnection
    }
    
    // MARK: - Realistic Test Data
    
    static func generateRealisticNetworkEvent() -> NetworkEvent {
        return TestDataFactory.createNetworkEvent(
            radioTechnology: randomRadioTechnology(),
            carrierName: randomCarrierName(),
            carrierCountryCode: randomCountryCode(),
            carrierMobileCountryCode: randomMobileCountryCode(),
            carrierMobileNetworkCode: randomMobileNetworkCode(),
            threatLevel: randomThreatLevel(),
            description: "Generated test event"
        )
    }
    
    static func generateRealisticAnomaly() -> NetworkAnomaly {
        return TestDataFactory.createNetworkAnomaly(
            anomalyType: randomAnomalyType(),
            severity: randomThreatLevel(),
            description: "Generated test anomaly",
            confidence: Double.random(in: 0.1...1.0)
        )
    }
    
    static func generateRealisticLocationContext() -> LocationContext {
        return TestDataFactory.createLocationContext(
            latitude: Double.random(in: -90...90),
            longitude: Double.random(in: -180...180),
            accuracy: Double.random(in: 1...100)
        )
    }
    
    // MARK: - Edge Case Data
    
    static func generateEdgeCaseNetworkEvent() -> NetworkEvent {
        return TestDataFactory.createNetworkEvent(
            radioTechnology: nil,
            carrierName: "",
            carrierCountryCode: nil,
            carrierMobileCountryCode: "",
            carrierMobileNetworkCode: nil,
            threatLevel: .critical,
            description: ""
        )
    }
    
    static func generateEdgeCaseAnomaly() -> NetworkAnomaly {
        return TestDataFactory.createNetworkAnomaly(
            anomalyType: .imsiCatcherSuspected,
            severity: .critical,
            description: "",
            relatedEvents: [],
            confidence: 0.0
        )
    }
}
