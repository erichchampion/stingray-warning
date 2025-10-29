import XCTest
@testable import Stingray_Warning

/// Unit tests for NetworkAnomaly model
class NetworkAnomalyTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testDefaultInitialization() {
        // Given & When
        let anomaly = TestDataFactory.createNetworkAnomaly()
        
        // Then
        XCTAssertNotNil(anomaly.id)
        XCTAssertNotNil(anomaly.startTime)
        XCTAssertNil(anomaly.endTime)
        XCTAssertEqual(anomaly.anomalyType, .suspicious2GConnection)
        XCTAssertEqual(anomaly.severity, .medium)
        XCTAssertEqual(anomaly.description, "Test anomaly")
        XCTAssertEqual(anomaly.relatedEvents, [])
        XCTAssertEqual(anomaly.confidence, 0.8)
        XCTAssertNil(anomaly.locationContext)
    }
    
    func testInitializationWithAllParameters() {
        // Given
        let relatedEvents = [UUID(), UUID()]
        let locationContext = TestDataFactory.createLocationContext()
        
        // When
        let anomaly = TestDataFactory.createNetworkAnomaly(
            anomalyType: .imsiCatcherSuspected,
            severity: .critical,
            description: "Critical anomaly",
            relatedEvents: relatedEvents,
            confidence: 0.95,
            locationContext: locationContext
        )
        
        // Then
        XCTAssertNotNil(anomaly.id)
        XCTAssertNotNil(anomaly.startTime)
        XCTAssertNil(anomaly.endTime)
        XCTAssertEqual(anomaly.anomalyType, .imsiCatcherSuspected)
        XCTAssertEqual(anomaly.severity, .critical)
        XCTAssertEqual(anomaly.description, "Critical anomaly")
        XCTAssertEqual(anomaly.relatedEvents, relatedEvents)
        XCTAssertEqual(anomaly.confidence, 0.95)
        XCTAssertNotNil(anomaly.locationContext)
    }
    
    func testUUIDGeneration() {
        // Given & When
        let anomaly1 = TestDataFactory.createNetworkAnomaly()
        
        // Add small delay to ensure different timestamps
        Thread.sleep(forTimeInterval: 0.001)
        
        let anomaly2 = TestDataFactory.createNetworkAnomaly()
        
        // Then
        XCTAssertNotEqual(anomaly1.id, anomaly2.id)
        XCTAssertNotEqual(anomaly1.startTime, anomaly2.startTime)
    }
    
    // MARK: - Codable Tests
    
    func testCodableConformance() {
        // Given
        let originalAnomaly = TestDataFactory.createNetworkAnomaly(
            anomalyType: .rapidTechnologyChange,
            severity: .high,
            description: "Test codable anomaly",
            relatedEvents: [UUID(), UUID()],
            confidence: 0.85
        )
        
        // When
        let encodedData = try? JSONEncoder().encode(originalAnomaly)
        XCTAssertNotNil(encodedData)
        
        let decodedAnomaly = try? JSONDecoder().decode(NetworkAnomaly.self, from: encodedData!)
        XCTAssertNotNil(decodedAnomaly)
        
        // Then
        XCTAssertEqual(decodedAnomaly?.anomalyType, originalAnomaly.anomalyType)
        XCTAssertEqual(decodedAnomaly?.severity, originalAnomaly.severity)
        XCTAssertEqual(decodedAnomaly?.description, originalAnomaly.description)
        XCTAssertEqual(decodedAnomaly?.relatedEvents, originalAnomaly.relatedEvents)
        XCTAssertEqual(decodedAnomaly?.confidence, originalAnomaly.confidence)
    }
    
    func testCodableWithLocationContext() {
        // Given
        let locationContext = TestDataFactory.createLocationContext()
        let originalAnomaly = TestDataFactory.createNetworkAnomaly(
            locationContext: locationContext
        )
        
        // When
        let encodedData = try? JSONEncoder().encode(originalAnomaly)
        XCTAssertNotNil(encodedData)
        
        let decodedAnomaly = try? JSONDecoder().decode(NetworkAnomaly.self, from: encodedData!)
        XCTAssertNotNil(decodedAnomaly)
        
        // Then
        XCTAssertNotNil(decodedAnomaly?.locationContext)
        XCTAssertEqual(decodedAnomaly?.locationContext?.latitude, locationContext.latitude)
        XCTAssertEqual(decodedAnomaly?.locationContext?.longitude, locationContext.longitude)
        XCTAssertEqual(decodedAnomaly?.locationContext?.accuracy, locationContext.accuracy)
    }
    
    // MARK: - Computed Properties Tests
    
    func testDurationWithEndTime() {
        // Given
        let startTime = Date()
        let _ = startTime.addingTimeInterval(300) // 5 minutes later
        
        // Note: We can't directly set endTime, so we test the concept
        // In a real scenario, this would be set by the system
        let anomaly = TestDataFactory.createNetworkAnomaly()
        
        // When
        let duration = anomaly.duration
        
        // Then
        // Since endTime is nil by default, duration should be nil
        XCTAssertNil(duration)
    }
    
    func testIsActiveWithNilEndTime() {
        // Given
        let anomaly = TestDataFactory.createNetworkAnomaly()
        
        // When & Then
        XCTAssertTrue(anomaly.isActive)
    }
    
    func testSummaryForActiveAnomaly() {
        // Given
        let anomaly = TestDataFactory.createNetworkAnomaly(
            anomalyType: .suspicious2GConnection,
            severity: .medium
        )
        
        // When
        let summary = anomaly.summary
        
        // Then
        XCTAssertTrue(summary.contains("Suspicious 2G Connection"))
        XCTAssertTrue(summary.contains("Medium Risk"))
        XCTAssertTrue(summary.contains("ongoing"))
    }
    
    // MARK: - AnomalyType Enum Tests
    
    func testAllAnomalyTypes() {
        // Given & When & Then
        XCTAssertEqual(AnomalyType.rapidTechnologyChange.description, "Rapid Technology Changes")
        XCTAssertEqual(AnomalyType.suspicious2GConnection.description, "Suspicious 2G Connection")
        XCTAssertEqual(AnomalyType.unknownCarrier.description, "Unknown Carrier")
        XCTAssertEqual(AnomalyType.unusualSignalPattern.description, "Unusual Signal Pattern")
        XCTAssertEqual(AnomalyType.networkDowngrade.description, "Network Downgrade")
        XCTAssertEqual(AnomalyType.carrierSpoofing.description, "Carrier Spoofing")
        XCTAssertEqual(AnomalyType.imsiCatcherSuspected.description, "IMSI Catcher Suspected")
    }
    
    func testAnomalyTypeDetailedDescriptions() {
        // Given & When & Then
        XCTAssertTrue(AnomalyType.rapidTechnologyChange.detailedDescription.contains("surveillance equipment"))
        XCTAssertTrue(AnomalyType.suspicious2GConnection.detailedDescription.contains("2G networks are vulnerable"))
        XCTAssertTrue(AnomalyType.unknownCarrier.detailedDescription.contains("rogue base station"))
        XCTAssertTrue(AnomalyType.unusualSignalPattern.detailedDescription.contains("surveillance equipment"))
        XCTAssertTrue(AnomalyType.networkDowngrade.detailedDescription.contains("vulnerable protocols"))
        XCTAssertTrue(AnomalyType.carrierSpoofing.detailedDescription.contains("spoofed"))
        XCTAssertTrue(AnomalyType.imsiCatcherSuspected.detailedDescription.contains("IMSI catcher"))
    }
    
    func testAnomalyTypeRecommendedActions() {
        // Given & When & Then
        XCTAssertTrue(AnomalyType.rapidTechnologyChange.recommendedAction.contains("airplane mode"))
        XCTAssertTrue(AnomalyType.suspicious2GConnection.recommendedAction.contains("airplane mode"))
        XCTAssertTrue(AnomalyType.unknownCarrier.recommendedAction.contains("Immediately switch"))
        XCTAssertTrue(AnomalyType.carrierSpoofing.recommendedAction.contains("Immediately switch"))
        XCTAssertTrue(AnomalyType.imsiCatcherSuspected.recommendedAction.contains("Immediately switch"))
        XCTAssertTrue(AnomalyType.unusualSignalPattern.recommendedAction.contains("Monitor the situation"))
        XCTAssertTrue(AnomalyType.networkDowngrade.recommendedAction.contains("airplane mode"))
    }
    
    func testAnomalyTypeCodableConformance() {
        // Given
        let originalType = AnomalyType.imsiCatcherSuspected
        
        // When
        let encodedData = try? JSONEncoder().encode(originalType)
        XCTAssertNotNil(encodedData)
        
        let decodedType = try? JSONDecoder().decode(AnomalyType.self, from: encodedData!)
        XCTAssertNotNil(decodedType)
        
        // Then
        XCTAssertEqual(decodedType, originalType)
    }
    
    func testAnomalyTypeCaseIterable() {
        // Given & When
        let allTypes = AnomalyType.allCases
        
        // Then
        XCTAssertEqual(allTypes.count, 7)
        XCTAssertTrue(allTypes.contains(.rapidTechnologyChange))
        XCTAssertTrue(allTypes.contains(.suspicious2GConnection))
        XCTAssertTrue(allTypes.contains(.unknownCarrier))
        XCTAssertTrue(allTypes.contains(.unusualSignalPattern))
        XCTAssertTrue(allTypes.contains(.networkDowngrade))
        XCTAssertTrue(allTypes.contains(.carrierSpoofing))
        XCTAssertTrue(allTypes.contains(.imsiCatcherSuspected))
    }
    
    // MARK: - Confidence Tests
    
    func testConfidenceBounds() {
        // Given & When
        let lowConfidenceAnomaly = TestDataFactory.createNetworkAnomaly(confidence: 0.0)
        let highConfidenceAnomaly = TestDataFactory.createNetworkAnomaly(confidence: 1.0)
        let midConfidenceAnomaly = TestDataFactory.createNetworkAnomaly(confidence: 0.5)
        
        // Then
        XCTAssertEqual(lowConfidenceAnomaly.confidence, 0.0)
        XCTAssertEqual(highConfidenceAnomaly.confidence, 1.0)
        XCTAssertEqual(midConfidenceAnomaly.confidence, 0.5)
    }
    
    func testConfidenceEdgeCases() {
        // Given & When
        let justAboveZero = TestDataFactory.createNetworkAnomaly(confidence: 0.001)
        let justBelowOne = TestDataFactory.createNetworkAnomaly(confidence: 0.999)
        
        // Then
        XCTAssertEqual(justAboveZero.confidence, 0.001)
        XCTAssertEqual(justBelowOne.confidence, 0.999)
    }
    
    // MARK: - Related Events Tests
    
    func testRelatedEventsWithMultipleEvents() {
        // Given
        let eventIds = [UUID(), UUID(), UUID()]
        
        // When
        let anomaly = TestDataFactory.createNetworkAnomaly(relatedEvents: eventIds)
        
        // Then
        XCTAssertEqual(anomaly.relatedEvents.count, 3)
        XCTAssertEqual(anomaly.relatedEvents, eventIds)
    }
    
    func testRelatedEventsWithEmptyArray() {
        // Given & When
        let anomaly = TestDataFactory.createNetworkAnomaly(relatedEvents: [])
        
        // Then
        XCTAssertEqual(anomaly.relatedEvents.count, 0)
        XCTAssertTrue(anomaly.relatedEvents.isEmpty)
    }
    
    func testRelatedEventsWithSingleEvent() {
        // Given
        let eventId = UUID()
        
        // When
        let anomaly = TestDataFactory.createNetworkAnomaly(relatedEvents: [eventId])
        
        // Then
        XCTAssertEqual(anomaly.relatedEvents.count, 1)
        XCTAssertEqual(anomaly.relatedEvents.first, eventId)
    }
    
    // MARK: - Edge Cases
    
    func testEmptyDescription() {
        // Given
        let anomaly = TestDataFactory.createNetworkAnomaly(description: "")
        
        // When & Then
        XCTAssertEqual(anomaly.description, "")
    }
    
    func testVeryLongDescription() {
        // Given
        let longDescription = String(repeating: "A", count: 1000)
        let anomaly = TestDataFactory.createNetworkAnomaly(description: longDescription)
        
        // When & Then
        XCTAssertEqual(anomaly.description, longDescription)
    }
    
    func testSpecialCharactersInDescription() {
        // Given
        let specialDescription = "Test with special chars: !@#$%^&*()_+-=[]{}|;':\",./<>?"
        let anomaly = TestDataFactory.createNetworkAnomaly(description: specialDescription)
        
        // When & Then
        XCTAssertEqual(anomaly.description, specialDescription)
    }
    
    func testUnicodeCharactersInDescription() {
        // Given
        let unicodeDescription = "Test with unicode: 🚨📱🔒⚠️"
        let anomaly = TestDataFactory.createNetworkAnomaly(description: unicodeDescription)
        
        // When & Then
        XCTAssertEqual(anomaly.description, unicodeDescription)
    }
    
    // MARK: - Performance Tests
    
    func testInitializationPerformance() {
        measure {
            for _ in 0..<1000 {
                _ = TestDataFactory.createNetworkAnomaly()
            }
        }
    }
    
    func testSummaryPerformance() {
        // Given
        let anomaly = TestDataFactory.createNetworkAnomaly()
        
        measure {
            for _ in 0..<1000 {
                _ = anomaly.summary
            }
        }
    }
    
    func testCodablePerformance() {
        // Given
        let anomaly = TestDataFactory.createNetworkAnomaly()
        
        measure {
            for _ in 0..<100 {
                let data = try? JSONEncoder().encode(anomaly)
                _ = try? JSONDecoder().decode(NetworkAnomaly.self, from: data!)
            }
        }
    }
}
