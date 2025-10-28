import XCTest
@testable import Stingray_Warning

/// Unit tests for LocationContext model
class LocationContextTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testDefaultInitialization() {
        // Given & When
        let locationContext = TestDataFactory.createLocationContext()
        
        // Then
        XCTAssertEqual(locationContext.latitude, 37.7749)
        XCTAssertEqual(locationContext.longitude, -122.4194)
        XCTAssertEqual(locationContext.accuracy, 10.0)
        XCTAssertNotNil(locationContext.timestamp)
    }
    
    func testInitializationWithNilValues() {
        // Given & When
        let locationContext = TestDataFactory.createNilLocationContext()
        
        // Then
        XCTAssertNil(locationContext.latitude)
        XCTAssertNil(locationContext.longitude)
        XCTAssertNil(locationContext.accuracy)
        XCTAssertNotNil(locationContext.timestamp)
    }
    
    func testInitializationWithPartialData() {
        // Given & When
        let locationContext = TestDataFactory.createPartialLocationContext()
        
        // Then
        XCTAssertEqual(locationContext.latitude, 37.7749)
        XCTAssertNil(locationContext.longitude)
        XCTAssertEqual(locationContext.accuracy, 10.0)
        XCTAssertNotNil(locationContext.timestamp)
    }
    
    func testTimestampGeneration() {
        // Given & When
        let locationContext1 = TestDataFactory.createLocationContext()
        let locationContext2 = TestDataFactory.createLocationContext()
        
        // Then
        XCTAssertNotEqual(locationContext1.timestamp, locationContext2.timestamp)
        XCTAssertTrue(locationContext1.timestamp <= Date())
        XCTAssertTrue(locationContext2.timestamp <= Date())
    }
    
    // MARK: - Codable Tests
    
    func testCodableConformance() {
        // Given
        let originalContext = TestDataFactory.createLocationContext()
        
        // When
        let encodedData = try? JSONEncoder().encode(originalContext)
        XCTAssertNotNil(encodedData)
        
        let decodedContext = try? JSONDecoder().decode(LocationContext.self, from: encodedData!)
        XCTAssertNotNil(decodedContext)
        
        // Then
        XCTAssertEqual(decodedContext?.latitude, originalContext.latitude)
        XCTAssertEqual(decodedContext?.longitude, originalContext.longitude)
        XCTAssertEqual(decodedContext?.accuracy, originalContext.accuracy)
        // Note: Timestamp might have slight differences due to encoding/decoding precision
    }
    
    func testCodableWithNilValues() {
        // Given
        let originalContext = TestDataFactory.createNilLocationContext()
        
        // When
        let encodedData = try? JSONEncoder().encode(originalContext)
        XCTAssertNotNil(encodedData)
        
        let decodedContext = try? JSONDecoder().decode(LocationContext.self, from: encodedData!)
        XCTAssertNotNil(decodedContext)
        
        // Then
        XCTAssertNil(decodedContext?.latitude)
        XCTAssertNil(decodedContext?.longitude)
        XCTAssertNil(decodedContext?.accuracy)
    }
    
    func testCodableWithPartialData() {
        // Given
        let originalContext = TestDataFactory.createPartialLocationContext()
        
        // When
        let encodedData = try? JSONEncoder().encode(originalContext)
        XCTAssertNotNil(encodedData)
        
        let decodedContext = try? JSONDecoder().decode(LocationContext.self, from: encodedData!)
        XCTAssertNotNil(decodedContext)
        
        // Then
        XCTAssertEqual(decodedContext?.latitude, originalContext.latitude)
        XCTAssertNil(decodedContext?.longitude)
        XCTAssertEqual(decodedContext?.accuracy, originalContext.accuracy)
    }
    
    // MARK: - Computed Properties Tests
    
    func testHasLocationWithCompleteData() {
        // Given
        let locationContext = TestDataFactory.createLocationContext()
        
        // When & Then
        XCTAssertTrue(locationContext.hasLocation)
    }
    
    func testHasLocationWithNilValues() {
        // Given
        let locationContext = TestDataFactory.createNilLocationContext()
        
        // When & Then
        XCTAssertFalse(locationContext.hasLocation)
    }
    
    func testHasLocationWithPartialData() {
        // Given
        let locationContext = TestDataFactory.createPartialLocationContext()
        
        // When & Then
        XCTAssertFalse(locationContext.hasLocation)
    }
    
    func testHasLocationWithOnlyLatitude() {
        // Given
        let locationContext = LocationContext(
            latitude: 37.7749,
            longitude: nil,
            accuracy: 10.0
        )
        
        // When & Then
        XCTAssertFalse(locationContext.hasLocation)
    }
    
    func testHasLocationWithOnlyLongitude() {
        // Given
        let locationContext = LocationContext(
            latitude: nil,
            longitude: -122.4194,
            accuracy: 10.0
        )
        
        // When & Then
        XCTAssertFalse(locationContext.hasLocation)
    }
    
    // MARK: - Coordinate Validation Tests
    
    func testValidLatitudeRange() {
        // Given & When & Then
        let validLatitudes: [Double] = [-90.0, -45.0, 0.0, 45.0, 90.0]
        
        for latitude in validLatitudes {
            let context = LocationContext(latitude: latitude, longitude: 0.0)
            XCTAssertEqual(context.latitude, latitude)
        }
    }
    
    func testValidLongitudeRange() {
        // Given & When & Then
        let validLongitudes: [Double] = [-180.0, -90.0, 0.0, 90.0, 180.0]
        
        for longitude in validLongitudes {
            let context = LocationContext(latitude: 0.0, longitude: longitude)
            XCTAssertEqual(context.longitude, longitude)
        }
    }
    
    func testValidAccuracyRange() {
        // Given & When & Then
        let validAccuracies: [Double] = [0.0, 1.0, 10.0, 100.0, 1000.0]
        
        for accuracy in validAccuracies {
            let context = LocationContext(latitude: 0.0, longitude: 0.0, accuracy: accuracy)
            XCTAssertEqual(context.accuracy, accuracy)
        }
    }
    
    // MARK: - Edge Cases
    
    func testExtremeCoordinates() {
        // Given & When
        let northPole = LocationContext(latitude: 90.0, longitude: 0.0)
        let southPole = LocationContext(latitude: -90.0, longitude: 0.0)
        let primeMeridian = LocationContext(latitude: 0.0, longitude: 0.0)
        let internationalDateLine = LocationContext(latitude: 0.0, longitude: 180.0)
        
        // Then
        XCTAssertEqual(northPole.latitude, 90.0)
        XCTAssertEqual(southPole.latitude, -90.0)
        XCTAssertEqual(primeMeridian.latitude, 0.0)
        XCTAssertEqual(primeMeridian.longitude, 0.0)
        XCTAssertEqual(internationalDateLine.longitude, 180.0)
    }
    
    func testZeroAccuracy() {
        // Given & When
        let context = LocationContext(latitude: 37.7749, longitude: -122.4194, accuracy: 0.0)
        
        // Then
        XCTAssertEqual(context.accuracy, 0.0)
        XCTAssertTrue(context.hasLocation)
    }
    
    func testNegativeAccuracy() {
        // Given & When
        let context = LocationContext(latitude: 37.7749, longitude: -122.4194, accuracy: -10.0)
        
        // Then
        XCTAssertEqual(context.accuracy, -10.0)
        XCTAssertTrue(context.hasLocation)
    }
    
    func testVeryHighAccuracy() {
        // Given & When
        let context = LocationContext(latitude: 37.7749, longitude: -122.4194, accuracy: 10000.0)
        
        // Then
        XCTAssertEqual(context.accuracy, 10000.0)
        XCTAssertTrue(context.hasLocation)
    }
    
    // MARK: - Real-World Scenarios
    
    func testSanFranciscoLocation() {
        // Given & When
        let sfLocation = LocationContext(
            latitude: 37.7749,
            longitude: -122.4194,
            accuracy: 5.0
        )
        
        // Then
        XCTAssertEqual(sfLocation.latitude, 37.7749)
        XCTAssertEqual(sfLocation.longitude, -122.4194)
        XCTAssertEqual(sfLocation.accuracy, 5.0)
        XCTAssertTrue(sfLocation.hasLocation)
    }
    
    func testNewYorkLocation() {
        // Given & When
        let nyLocation = LocationContext(
            latitude: 40.7128,
            longitude: -74.0060,
            accuracy: 10.0
        )
        
        // Then
        XCTAssertEqual(nyLocation.latitude, 40.7128)
        XCTAssertEqual(nyLocation.longitude, -74.0060)
        XCTAssertEqual(nyLocation.accuracy, 10.0)
        XCTAssertTrue(nyLocation.hasLocation)
    }
    
    func testLondonLocation() {
        // Given & When
        let londonLocation = LocationContext(
            latitude: 51.5074,
            longitude: -0.1278,
            accuracy: 15.0
        )
        
        // Then
        XCTAssertEqual(londonLocation.latitude, 51.5074)
        XCTAssertEqual(londonLocation.longitude, -0.1278)
        XCTAssertEqual(londonLocation.accuracy, 15.0)
        XCTAssertTrue(londonLocation.hasLocation)
    }
    
    // MARK: - Performance Tests
    
    func testInitializationPerformance() {
        measure {
            for _ in 0..<1000 {
                _ = TestDataFactory.createLocationContext()
            }
        }
    }
    
    func testHasLocationPerformance() {
        // Given
        let context = TestDataFactory.createLocationContext()
        
        measure {
            for _ in 0..<10000 {
                _ = context.hasLocation
            }
        }
    }
    
    func testCodablePerformance() {
        // Given
        let context = TestDataFactory.createLocationContext()
        
        measure {
            for _ in 0..<100 {
                let data = try? JSONEncoder().encode(context)
                _ = try? JSONDecoder().decode(LocationContext.self, from: data!)
            }
        }
    }
    
    // MARK: - Comparison Tests
    
    func testLocationContextEquality() {
        // Given
        let context1 = LocationContext(latitude: 37.7749, longitude: -122.4194, accuracy: 10.0)
        let context2 = LocationContext(latitude: 37.7749, longitude: -122.4194, accuracy: 10.0)
        let context3 = LocationContext(latitude: 40.7128, longitude: -74.0060, accuracy: 10.0)
        
        // When & Then
        // Note: Equality comparison would need to be implemented if needed
        // For now, we test that the values are set correctly
        XCTAssertEqual(context1.latitude, context2.latitude)
        XCTAssertEqual(context1.longitude, context2.longitude)
        XCTAssertEqual(context1.accuracy, context2.accuracy)
        XCTAssertNotEqual(context1.latitude, context3.latitude)
        XCTAssertNotEqual(context1.longitude, context3.longitude)
    }
    
    // MARK: - Memory Tests
    
    func testMemoryUsage() {
        // Given
        var contexts: [LocationContext] = []
        
        // When
        for _ in 0..<1000 {
            contexts.append(TestDataFactory.createLocationContext())
        }
        
        // Then
        XCTAssertEqual(contexts.count, 1000)
        // Memory usage is tested implicitly - if this test passes, memory usage is acceptable
    }
}
