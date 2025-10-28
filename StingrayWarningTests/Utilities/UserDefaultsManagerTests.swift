import XCTest
@testable import Stingray_Warning

/// Unit tests for UserDefaultsManager
class UserDefaultsManagerTests: XCTestCase {
    
    var mockUserDefaults: MockUserDefaults!
    
    override func setUp() {
        super.setUp()
        mockUserDefaults = MockUserDefaults()
        // Note: In a real implementation, we'd need to inject the mock
        // For now, we'll test the public interface
    }
    
    override func tearDown() {
        mockUserDefaults = nil
        super.tearDown()
    }
    
    // MARK: - Synchronous Operations Tests
    
    func testSetAndGet() {
        // Given
        let key = "test_key"
        let value = "test_value"
        
        // When
        UserDefaultsManager.set(value, forKey: key)
        let retrievedValue = UserDefaultsManager.get(forKey: key, defaultValue: "")
        
        // Then
        XCTAssertEqual(retrievedValue, value)
    }
    
    func testSetAndGetWithDifferentTypes() {
        // Given
        let stringKey = "string_key"
        let stringValue = "test_string"
        let boolKey = "bool_key"
        let boolValue = true
        let intKey = "int_key"
        let intValue = 42
        let doubleKey = "double_key"
        let doubleValue = 3.14
        
        // When
        UserDefaultsManager.set(stringValue, forKey: stringKey)
        UserDefaultsManager.set(boolValue, forKey: boolKey)
        UserDefaultsManager.set(intValue, forKey: intKey)
        UserDefaultsManager.set(doubleValue, forKey: doubleKey)
        
        let retrievedString = UserDefaultsManager.get(forKey: stringKey, defaultValue: "")
        let retrievedBool = UserDefaultsManager.getBool(forKey: boolKey)
        let retrievedInt = UserDefaultsManager.get(forKey: intKey, defaultValue: 0)
        let retrievedDouble = UserDefaultsManager.get(forKey: doubleKey, defaultValue: 0.0)
        
        // Then
        XCTAssertEqual(retrievedString, stringValue)
        XCTAssertEqual(retrievedBool, boolValue)
        XCTAssertEqual(retrievedInt, intValue)
        XCTAssertEqual(retrievedDouble, doubleValue)
    }
    
    func testGetWithDefaultValue() {
        // Given
        let key = "nonexistent_key"
        let defaultValue = "default_value"
        
        // When
        let retrievedValue = UserDefaultsManager.get(forKey: key, defaultValue: defaultValue)
        
        // Then
        XCTAssertEqual(retrievedValue, defaultValue)
    }
    
    func testGetBoolWithDefaultValue() {
        // Given
        let key = "nonexistent_bool_key"
        let defaultValue = true
        
        // When
        let retrievedValue = UserDefaultsManager.getBool(forKey: key, defaultValue: defaultValue)
        
        // Then
        XCTAssertEqual(retrievedValue, defaultValue)
    }
    
    func testGetStringWithDefaultValue() {
        // Given
        let key = "nonexistent_string_key"
        let defaultValue = "default_string"
        
        // When
        let retrievedValue = UserDefaultsManager.getString(forKey: key, defaultValue: defaultValue)
        
        // Then
        XCTAssertEqual(retrievedValue, defaultValue)
    }
    
    func testGetData() {
        // Given
        let key = "data_key"
        let data = "test_data".data(using: .utf8)!
        
        // When
        UserDefaultsManager.set(data, forKey: key)
        let retrievedData = UserDefaultsManager.getData(forKey: key)
        
        // Then
        XCTAssertEqual(retrievedData, data)
    }
    
    func testGetDataWithNilValue() {
        // Given
        let key = "nonexistent_data_key"
        
        // When
        let retrievedData = UserDefaultsManager.getData(forKey: key)
        
        // Then
        XCTAssertNil(retrievedData)
    }
    
    func testRemove() {
        // Given
        let key = "remove_key"
        let value = "remove_value"
        
        UserDefaultsManager.set(value, forKey: key)
        XCTAssertEqual(UserDefaultsManager.get(forKey: key, defaultValue: ""), value)
        
        // When
        UserDefaultsManager.remove(forKey: key)
        
        // Then
        XCTAssertEqual(UserDefaultsManager.get(forKey: key, defaultValue: ""), "")
    }
    
    // MARK: - Asynchronous Operations Tests
    
    func testSetAsync() {
        // Given
        let key = "async_key"
        let value = "async_value"
        let expectation = XCTestExpectation(description: "Async set completed")
        
        // When
        UserDefaultsManager.setAsync(value, forKey: key) {
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSetCodableAsync() {
        // Given
        let key = "codable_key"
        let event = TestDataFactory.createNetworkEvent()
        let expectation = XCTestExpectation(description: "Async codable set completed")
        
        // When
        UserDefaultsManager.setCodableAsync(event, forKey: key) { _ in
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetCodable() {
        // Given
        let key = "codable_key"
        let originalEvent = TestDataFactory.createNetworkEvent()
        
        UserDefaultsManager.setCodableAsync(originalEvent, forKey: key) { _ in }
        
        // Wait for async operation to complete
        let expectation = XCTestExpectation(description: "Async operation completed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // When
        do {
            let retrievedEvent = try UserDefaultsManager.getCodable(NetworkEvent.self, forKey: key)
            
            // Then
            XCTAssertNotNil(retrievedEvent)
            XCTAssertEqual(retrievedEvent?.threatLevel, originalEvent.threatLevel)
            XCTAssertEqual(retrievedEvent?.description, originalEvent.description)
        } catch {
            XCTFail("Failed to retrieve codable: \(error)")
        }
    }
    
    func testGetCodableAsync() {
        // Given
        let key = "codable_async_key"
        let originalEvent = TestDataFactory.createNetworkEvent()
        let expectation = XCTestExpectation(description: "Async codable get completed")
        
        UserDefaultsManager.setCodableAsync(originalEvent, forKey: key) { _ in }
        
        // Wait for set operation to complete
        let setExpectation = XCTestExpectation(description: "Set operation completed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            setExpectation.fulfill()
        }
        wait(for: [setExpectation], timeout: 1.0)
        
        // When
        UserDefaultsManager.getCodableAsync(NetworkEvent.self, forKey: key) { result in
            switch result {
            case .success(let retrievedEvent):
                XCTAssertNotNil(retrievedEvent)
                XCTAssertEqual(retrievedEvent?.threatLevel, originalEvent.threatLevel)
                XCTAssertEqual(retrievedEvent?.description, originalEvent.description)
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetCodableAsyncWithNilValue() {
        // Given
        let key = "nonexistent_codable_key"
        let expectation = XCTestExpectation(description: "Async codable get with nil completed")
        
        // When
        UserDefaultsManager.getCodableAsync(NetworkEvent.self, forKey: key) { result in
            switch result {
            case .success(let retrievedEvent):
                XCTAssertNil(retrievedEvent)
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Error Handling Tests
    
    func testSetCodableAsyncWithInvalidData() {
        // Given
        let key = "invalid_codable_key"
        let expectation = XCTestExpectation(description: "Invalid codable set completed")
        
        // When
        UserDefaultsManager.setCodableAsync("invalid_data", forKey: key) { _ in
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetCodableAsyncWithInvalidData() {
        // Given
        let key = "invalid_codable_key"
        let expectation = XCTestExpectation(description: "Invalid codable get completed")
        
        // Set invalid data
        UserDefaultsManager.set("invalid_data", forKey: key)
        
        // When
        UserDefaultsManager.getCodableAsync(NetworkEvent.self, forKey: key) { result in
            switch result {
            case .success(_):
                XCTFail("Should have failed with invalid data")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Edge Cases
    
    func testSetWithNilValue() {
        // Given
        let key = "nil_key"
        let value: String? = nil
        
        // When
        UserDefaultsManager.set(value, forKey: key)
        let retrievedValue = UserDefaultsManager.get(forKey: key, defaultValue: "default")
        
        // Then
        XCTAssertEqual(retrievedValue, "default")
    }
    
    func testSetWithEmptyString() {
        // Given
        let key = "empty_string_key"
        let value = ""
        
        // When
        UserDefaultsManager.set(value, forKey: key)
        let retrievedValue = UserDefaultsManager.get(forKey: key, defaultValue: "default")
        
        // Then
        XCTAssertEqual(retrievedValue, value)
    }
    
    func testSetWithVeryLongString() {
        // Given
        let key = "long_string_key"
        let value = String(repeating: "A", count: 10000)
        
        // When
        UserDefaultsManager.set(value, forKey: key)
        let retrievedValue = UserDefaultsManager.get(forKey: key, defaultValue: "")
        
        // Then
        XCTAssertEqual(retrievedValue, value)
    }
    
    func testSetWithSpecialCharacters() {
        // Given
        let key = "special_chars_key"
        let value = "Special chars: !@#$%^&*()_+-=[]{}|;':\",./<>?"
        
        // When
        UserDefaultsManager.set(value, forKey: key)
        let retrievedValue = UserDefaultsManager.get(forKey: key, defaultValue: "")
        
        // Then
        XCTAssertEqual(retrievedValue, value)
    }
    
    func testSetWithUnicodeCharacters() {
        // Given
        let key = "unicode_key"
        let value = "Unicode: 🚨📱🔒⚠️"
        
        // When
        UserDefaultsManager.set(value, forKey: key)
        let retrievedValue = UserDefaultsManager.get(forKey: key, defaultValue: "")
        
        // Then
        XCTAssertEqual(retrievedValue, value)
    }
    
    // MARK: - Performance Tests
    
    func testSynchronousOperationsPerformance() {
        // Given
        let key = "perf_key"
        let value = "perf_value"
        
        // When & Then
        measure {
            for i in 0..<1000 {
                UserDefaultsManager.set("\(value)_\(i)", forKey: "\(key)_\(i)")
                _ = UserDefaultsManager.get(forKey: "\(key)_\(i)", defaultValue: "")
            }
        }
    }
    
    func testAsynchronousOperationsPerformance() {
        // Given
        let key = "async_perf_key"
        let value = "async_perf_value"
        let expectation = XCTestExpectation(description: "Async performance test completed")
        expectation.expectedFulfillmentCount = 100
        
        // When & Then
        measure {
            for i in 0..<100 {
                UserDefaultsManager.setAsync("\(value)_\(i)", forKey: "\(key)_\(i)") {
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testCodableOperationsPerformance() {
        // Given
        let key = "codable_perf_key"
        let event = TestDataFactory.createNetworkEvent()
        let expectation = XCTestExpectation(description: "Codable performance test completed")
        expectation.expectedFulfillmentCount = 50
        
        // When & Then
        measure {
            for i in 0..<50 {
                UserDefaultsManager.setCodableAsync(event, forKey: "\(key)_\(i)") { _ in
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Integration Tests
    
    func testUserDefaultsManagerIntegration() {
        // Given
        let stringKey = "integration_string"
        let stringValue = "integration_value"
        let boolKey = "integration_bool"
        let boolValue = true
        let eventKey = "integration_event"
        let event = TestDataFactory.createNetworkEvent()
        
        // When
        UserDefaultsManager.set(stringValue, forKey: stringKey)
        UserDefaultsManager.set(boolValue, forKey: boolKey)
        UserDefaultsManager.setCodableAsync(event, forKey: eventKey) { _ in }
        
        // Wait for async operation
        let expectation = XCTestExpectation(description: "Integration test completed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertEqual(UserDefaultsManager.get(forKey: stringKey, defaultValue: ""), stringValue)
        XCTAssertEqual(UserDefaultsManager.getBool(forKey: boolKey), boolValue)
        
        do {
            let retrievedEvent = try UserDefaultsManager.getCodable(NetworkEvent.self, forKey: eventKey)
            XCTAssertNotNil(retrievedEvent)
            XCTAssertEqual(retrievedEvent?.threatLevel, event.threatLevel)
        } catch {
            XCTFail("Failed to retrieve codable: \(error)")
        }
    }
    
    func testUserDefaultsManagerWithRealData() {
        // Given
        let events = Array(0..<10).map { _ in MockDataGenerators.generateRealisticNetworkEvent() }
        let anomalies = Array(0..<5).map { _ in MockDataGenerators.generateRealisticAnomaly() }
        
        // When
        for (index, event) in events.enumerated() {
            UserDefaultsManager.setCodableAsync(event, forKey: "event_\(index)") { _ in }
        }
        
        for (index, anomaly) in anomalies.enumerated() {
            UserDefaultsManager.setCodableAsync(anomaly, forKey: "anomaly_\(index)") { _ in }
        }
        
        // Wait for async operations
        let expectation = XCTestExpectation(description: "Real data test completed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        for (index, event) in events.enumerated() {
            do {
                let retrievedEvent = try UserDefaultsManager.getCodable(NetworkEvent.self, forKey: "event_\(index)")
                XCTAssertNotNil(retrievedEvent)
                XCTAssertEqual(retrievedEvent?.threatLevel, event.threatLevel)
            } catch {
                XCTFail("Failed to retrieve event \(index): \(error)")
            }
        }
        
        for (index, anomaly) in anomalies.enumerated() {
            do {
                let retrievedAnomaly = try UserDefaultsManager.getCodable(NetworkAnomaly.self, forKey: "anomaly_\(index)")
                XCTAssertNotNil(retrievedAnomaly)
                XCTAssertEqual(retrievedAnomaly?.anomalyType, anomaly.anomalyType)
            } catch {
                XCTFail("Failed to retrieve anomaly \(index): \(error)")
            }
        }
    }
}
