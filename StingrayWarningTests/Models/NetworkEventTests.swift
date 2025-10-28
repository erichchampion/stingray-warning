import XCTest
@testable import Stingray_Warning

/// Unit tests for NetworkEvent model
class NetworkEventTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testDefaultInitialization() {
        // Given & When
        let event = TestDataFactory.createNetworkEvent()
        
        // Then
        XCTAssertNotNil(event.id)
        XCTAssertNotNil(event.timestamp)
        XCTAssertEqual(event.radioTechnology, "CTRadioAccessTechnologyLTE")
        XCTAssertEqual(event.carrierName, "Test Carrier")
        XCTAssertEqual(event.carrierCountryCode, "US")
        XCTAssertEqual(event.carrierMobileCountryCode, "310")
        XCTAssertEqual(event.carrierMobileNetworkCode, "260")
        XCTAssertEqual(event.threatLevel, .none)
        XCTAssertEqual(event.description, "Test network event")
        XCTAssertNil(event.locationContext)
    }
    
    func testInitializationWithNilValues() {
        // Given & When
        let event = TestDataFactory.createNetworkEvent(
            radioTechnology: nil,
            carrierName: nil,
            carrierCountryCode: nil,
            carrierMobileCountryCode: nil,
            carrierMobileNetworkCode: nil,
            threatLevel: .critical,
            description: "Test with nil values"
        )
        
        // Then
        XCTAssertNotNil(event.id)
        XCTAssertNotNil(event.timestamp)
        XCTAssertNil(event.radioTechnology)
        XCTAssertNil(event.carrierName)
        XCTAssertNil(event.carrierCountryCode)
        XCTAssertNil(event.carrierMobileCountryCode)
        XCTAssertNil(event.carrierMobileNetworkCode)
        XCTAssertEqual(event.threatLevel, .critical)
        XCTAssertEqual(event.description, "Test with nil values")
        XCTAssertNil(event.locationContext)
    }
    
    func testInitializationWithLocationContext() {
        // Given
        let locationContext = TestDataFactory.createLocationContext()
        
        // When
        let event = TestDataFactory.createNetworkEvent(
            threatLevel: .medium,
            description: "Test with location",
            locationContext: locationContext
        )
        
        // Then
        XCTAssertNotNil(event.locationContext)
        XCTAssertEqual(event.locationContext?.latitude, 37.7749)
        XCTAssertEqual(event.locationContext?.longitude, -122.4194)
        XCTAssertEqual(event.locationContext?.accuracy, 10.0)
    }
    
    func testUUIDGeneration() {
        // Given & When
        let event1 = TestDataFactory.createNetworkEvent()
        let event2 = TestDataFactory.createNetworkEvent()
        
        // Then
        XCTAssertNotEqual(event1.id, event2.id)
        XCTAssertNotEqual(event1.timestamp, event2.timestamp)
    }
    
    // MARK: - Codable Tests
    
    func testCodableConformance() {
        // Given
        let originalEvent = TestDataFactory.createNetworkEvent(
            radioTechnology: "CTRadioAccessTechnologyLTE",
            carrierName: "Verizon",
            carrierCountryCode: "US",
            carrierMobileCountryCode: "310",
            carrierMobileNetworkCode: "260",
            threatLevel: .high,
            description: "Test codable event"
        )
        
        // When
        let encodedData = try? JSONEncoder().encode(originalEvent)
        XCTAssertNotNil(encodedData)
        
        let decodedEvent = try? JSONDecoder().decode(NetworkEvent.self, from: encodedData!)
        XCTAssertNotNil(decodedEvent)
        
        // Then
        XCTAssertEqual(decodedEvent?.radioTechnology, originalEvent.radioTechnology)
        XCTAssertEqual(decodedEvent?.carrierName, originalEvent.carrierName)
        XCTAssertEqual(decodedEvent?.carrierCountryCode, originalEvent.carrierCountryCode)
        XCTAssertEqual(decodedEvent?.carrierMobileCountryCode, originalEvent.carrierMobileCountryCode)
        XCTAssertEqual(decodedEvent?.carrierMobileNetworkCode, originalEvent.carrierMobileNetworkCode)
        XCTAssertEqual(decodedEvent?.threatLevel, originalEvent.threatLevel)
        XCTAssertEqual(decodedEvent?.description, originalEvent.description)
    }
    
    func testCodableWithNilValues() {
        // Given
        let originalEvent = TestDataFactory.createNetworkEvent(
            radioTechnology: nil,
            carrierName: nil,
            carrierCountryCode: nil,
            carrierMobileCountryCode: nil,
            carrierMobileNetworkCode: nil,
            threatLevel: .none,
            description: "Test nil values"
        )
        
        // When
        let encodedData = try? JSONEncoder().encode(originalEvent)
        XCTAssertNotNil(encodedData)
        
        let decodedEvent = try? JSONDecoder().decode(NetworkEvent.self, from: encodedData!)
        XCTAssertNotNil(decodedEvent)
        
        // Then
        XCTAssertNil(decodedEvent?.radioTechnology)
        XCTAssertNil(decodedEvent?.carrierName)
        XCTAssertNil(decodedEvent?.carrierCountryCode)
        XCTAssertNil(decodedEvent?.carrierMobileCountryCode)
        XCTAssertNil(decodedEvent?.carrierMobileNetworkCode)
        XCTAssertEqual(decodedEvent?.threatLevel, NetworkThreatLevel.none)
        XCTAssertEqual(decodedEvent?.description, "Test nil values")
    }
    
    // MARK: - Computed Properties Tests
    
    func testSummaryWithAllData() {
        // Given
        let event = TestDataFactory.createNetworkEvent(
            radioTechnology: "CTRadioAccessTechnologyLTE",
            carrierName: "Verizon",
            carrierMobileCountryCode: "310",
            carrierMobileNetworkCode: "260",
            threatLevel: .high,
            description: "Test summary"
        )
        
        // When
        let summary = event.summary
        
        // Then
        XCTAssertTrue(summary.contains("Technology: CTRadioAccessTechnologyLTE"))
        XCTAssertTrue(summary.contains("Carrier: Verizon"))
        XCTAssertTrue(summary.contains("MCC/MNC: 310/260"))
        XCTAssertTrue(summary.contains("Threat: High Risk"))
    }
    
    func testSummaryWithPartialData() {
        // Given
        let event = TestDataFactory.createNetworkEvent(
            radioTechnology: "CTRadioAccessTechnologyLTE",
            carrierName: nil,
            carrierMobileCountryCode: nil,
            carrierMobileNetworkCode: nil,
            threatLevel: .none,
            description: "Test partial summary"
        )
        
        // When
        let summary = event.summary
        
        // Then
        XCTAssertTrue(summary.contains("Technology: CTRadioAccessTechnologyLTE"))
        XCTAssertFalse(summary.contains("Carrier:"))
        XCTAssertFalse(summary.contains("MCC/MNC:"))
        XCTAssertTrue(summary.contains("Threat: No Threat Detected"))
    }
    
    func testSummaryWithNilTechnology() {
        // Given
        let event = TestDataFactory.createNetworkEvent(
            radioTechnology: nil,
            carrierName: "Verizon",
            carrierMobileCountryCode: "310",
            carrierMobileNetworkCode: "260",
            threatLevel: .medium,
            description: "Test nil technology"
        )
        
        // When
        let summary = event.summary
        
        // Then
        XCTAssertFalse(summary.contains("Technology:"))
        XCTAssertTrue(summary.contains("Carrier: Verizon"))
        XCTAssertTrue(summary.contains("MCC/MNC: 310/260"))
        XCTAssertTrue(summary.contains("Threat: Medium Risk"))
    }
    
    // MARK: - 2G Connection Tests
    
    func testIs2GConnectionWithGSM() {
        // Given
        let event = TestDataFactory.createNetworkEvent(
            radioTechnology: "CTRadioAccessTechnologyGSM",
            threatLevel: .medium
        )
        
        // When & Then
        XCTAssertTrue(event.is2GConnection)
    }
    
    func testIs2GConnectionWithEdge() {
        // Given
        let event = TestDataFactory.createNetworkEvent(
            radioTechnology: "CTRadioAccessTechnologyEdge",
            threatLevel: .medium
        )
        
        // When & Then
        XCTAssertTrue(event.is2GConnection)
    }
    
    func testIs2GConnectionWithLTE() {
        // Given
        let event = TestDataFactory.createNetworkEvent(
            radioTechnology: "CTRadioAccessTechnologyLTE",
            threatLevel: .none
        )
        
        // When & Then
        XCTAssertFalse(event.is2GConnection)
    }
    
    func testIs2GConnectionWith5G() {
        // Given
        let event = TestDataFactory.createNetworkEvent(
            radioTechnology: "CTRadioAccessTechnologyNRNSA",
            threatLevel: .none
        )
        
        // When & Then
        XCTAssertFalse(event.is2GConnection)
    }
    
    func testIs2GConnectionWithNilTechnology() {
        // Given
        let event = TestDataFactory.createNetworkEvent(
            radioTechnology: nil,
            threatLevel: .none
        )
        
        // When & Then
        XCTAssertFalse(event.is2GConnection)
    }
    
    func testIs2GConnectionWithEmptyString() {
        // Given
        let event = TestDataFactory.createNetworkEvent(
            radioTechnology: "",
            threatLevel: .none
        )
        
        // When & Then
        XCTAssertFalse(event.is2GConnection)
    }
    
    // MARK: - Suspicious Carrier Tests
    
    func testIsSuspiciousCarrier() {
        // Given
        let event = TestDataFactory.createNetworkEvent(
            carrierName: "Unknown Carrier",
            threatLevel: .high
        )
        
        // When & Then
        // Note: Currently always returns false due to deprecated APIs
        XCTAssertFalse(event.isSuspiciousCarrier)
    }
    
    func testIsSuspiciousCarrierWithNilCarrier() {
        // Given
        let event = TestDataFactory.createNetworkEvent(
            carrierName: nil,
            threatLevel: .none
        )
        
        // When & Then
        XCTAssertFalse(event.isSuspiciousCarrier)
    }
    
    // MARK: - Edge Cases
    
    func testEmptyDescription() {
        // Given
        let event = TestDataFactory.createNetworkEvent(
            description: ""
        )
        
        // When & Then
        XCTAssertEqual(event.description, "")
    }
    
    func testVeryLongDescription() {
        // Given
        let longDescription = String(repeating: "A", count: 1000)
        let event = TestDataFactory.createNetworkEvent(
            description: longDescription
        )
        
        // When & Then
        XCTAssertEqual(event.description, longDescription)
    }
    
    func testSpecialCharactersInDescription() {
        // Given
        let specialDescription = "Test with special chars: !@#$%^&*()_+-=[]{}|;':\",./<>?"
        let event = TestDataFactory.createNetworkEvent(
            description: specialDescription
        )
        
        // When & Then
        XCTAssertEqual(event.description, specialDescription)
    }
    
    func testUnicodeCharactersInDescription() {
        // Given
        let unicodeDescription = "Test with unicode: 🚨📱🔒⚠️"
        let event = TestDataFactory.createNetworkEvent(
            description: unicodeDescription
        )
        
        // When & Then
        XCTAssertEqual(event.description, unicodeDescription)
    }
    
    // MARK: - Performance Tests
    
    func testInitializationPerformance() {
        measure {
            for _ in 0..<1000 {
                _ = TestDataFactory.createNetworkEvent()
            }
        }
    }
    
    func testSummaryPerformance() {
        // Given
        let event = TestDataFactory.createNetworkEvent()
        
        measure {
            for _ in 0..<1000 {
                _ = event.summary
            }
        }
    }
    
    func testCodablePerformance() {
        // Given
        let event = TestDataFactory.createNetworkEvent()
        
        measure {
            for _ in 0..<100 {
                let data = try? JSONEncoder().encode(event)
                _ = try? JSONDecoder().decode(NetworkEvent.self, from: data!)
            }
        }
    }
}
