import XCTest
@testable import TwoG

/// Unit tests for NetworkThreatLevel enum
class NetworkThreatLevelTests: XCTestCase {
    
    // MARK: - Enum Tests
    
    func testAllThreatLevels() {
        // Given & When
        let allLevels = NetworkThreatLevel.allCases
        
        // Then
        XCTAssertEqual(allLevels.count, 5)
        XCTAssertTrue(allLevels.contains(.none))
        XCTAssertTrue(allLevels.contains(.low))
        XCTAssertTrue(allLevels.contains(.medium))
        XCTAssertTrue(allLevels.contains(.high))
        XCTAssertTrue(allLevels.contains(.critical))
    }
    
    func testThreatLevelDescriptions() {
        // Given & When & Then
        XCTAssertEqual(NetworkThreatLevel.none.description, "No Issue Detected")
        XCTAssertEqual(NetworkThreatLevel.low.description, "Low Risk")
        XCTAssertEqual(NetworkThreatLevel.medium.description, "Medium Risk")
        XCTAssertEqual(NetworkThreatLevel.high.description, "High Risk")
        XCTAssertEqual(NetworkThreatLevel.critical.description, "Critical Risk")
    }
    
    func testThreatLevelRawValues() {
        // Given & When & Then
        XCTAssertEqual(NetworkThreatLevel.none.rawValue, "none")
        XCTAssertEqual(NetworkThreatLevel.low.rawValue, "low")
        XCTAssertEqual(NetworkThreatLevel.medium.rawValue, "medium")
        XCTAssertEqual(NetworkThreatLevel.high.rawValue, "high")
        XCTAssertEqual(NetworkThreatLevel.critical.rawValue, "critical")
    }
    
    // MARK: - Priority Tests
    
    func testPriorityValues() {
        // Given & When & Then
        XCTAssertEqual(NetworkThreatLevel.none.priority, 0)
        XCTAssertEqual(NetworkThreatLevel.low.priority, 1)
        XCTAssertEqual(NetworkThreatLevel.medium.priority, 2)
        XCTAssertEqual(NetworkThreatLevel.high.priority, 3)
        XCTAssertEqual(NetworkThreatLevel.critical.priority, 4)
    }
    
    func testPriorityOrdering() {
        // Given & When & Then
        XCTAssertLessThan(NetworkThreatLevel.none.priority, NetworkThreatLevel.low.priority)
        XCTAssertLessThan(NetworkThreatLevel.low.priority, NetworkThreatLevel.medium.priority)
        XCTAssertLessThan(NetworkThreatLevel.medium.priority, NetworkThreatLevel.high.priority)
        XCTAssertLessThan(NetworkThreatLevel.high.priority, NetworkThreatLevel.critical.priority)
    }
    
    func testPriorityComparison() {
        // Given
        let levels = NetworkThreatLevel.allCases
        
        // When & Then
        for i in 0..<levels.count {
            for j in (i+1)..<levels.count {
                XCTAssertLessThan(levels[i].priority, levels[j].priority)
            }
        }
    }
    
    // MARK: - Alert Requirements Tests
    
    func testRequiresImmediateAlert() {
        // Given & When & Then
        XCTAssertFalse(NetworkThreatLevel.none.requiresImmediateAlert)
        XCTAssertFalse(NetworkThreatLevel.low.requiresImmediateAlert)
        XCTAssertFalse(NetworkThreatLevel.medium.requiresImmediateAlert)
        XCTAssertTrue(NetworkThreatLevel.high.requiresImmediateAlert)
        XCTAssertTrue(NetworkThreatLevel.critical.requiresImmediateAlert)
    }
    
    func testRequiresNotification() {
        // Given & When & Then
        XCTAssertFalse(NetworkThreatLevel.none.requiresNotification)
        XCTAssertTrue(NetworkThreatLevel.low.requiresNotification)
        XCTAssertTrue(NetworkThreatLevel.medium.requiresNotification)
        XCTAssertTrue(NetworkThreatLevel.high.requiresNotification)
        XCTAssertTrue(NetworkThreatLevel.critical.requiresNotification)
    }
    
    // MARK: - Codable Tests
    
    func testCodableConformance() {
        // Given
        let originalLevel = NetworkThreatLevel.critical
        
        // When
        let encodedData = try? JSONEncoder().encode(originalLevel)
        XCTAssertNotNil(encodedData)
        
        let decodedLevel = try? JSONDecoder().decode(NetworkThreatLevel.self, from: encodedData!)
        XCTAssertNotNil(decodedLevel)
        
        // Then
        XCTAssertEqual(decodedLevel, originalLevel)
    }
    
    func testCodableWithAllLevels() {
        // Given
        let allLevels = NetworkThreatLevel.allCases
        
        // When & Then
        for level in allLevels {
            let encodedData = try? JSONEncoder().encode(level)
            XCTAssertNotNil(encodedData)
            
            let decodedLevel = try? JSONDecoder().decode(NetworkThreatLevel.self, from: encodedData!)
            XCTAssertNotNil(decodedLevel)
            XCTAssertEqual(decodedLevel, level)
        }
    }
    
    func testCodableWithInvalidValue() {
        // Given
        let invalidData = "\"invalid\"".data(using: .utf8)!
        
        // When & Then
        XCTAssertThrowsError(try JSONDecoder().decode(NetworkThreatLevel.self, from: invalidData))
    }
    
    // MARK: - Sorting Tests
    
    func testThreatLevelSorting() {
        // Given
        let unsortedLevels: [NetworkThreatLevel] = [.critical, .none, .medium, .high, .low]
        
        // When
        let sortedLevels = unsortedLevels.sorted { $0.priority < $1.priority }
        
        // Then
        XCTAssertEqual(sortedLevels, [.none, .low, .medium, .high, .critical])
    }
    
    func testThreatLevelSortingDescending() {
        // Given
        let unsortedLevels: [NetworkThreatLevel] = [.none, .critical, .medium, .high, .low]
        
        // When
        let sortedLevels = unsortedLevels.sorted { $0.priority > $1.priority }
        
        // Then
        XCTAssertEqual(sortedLevels, [.critical, .high, .medium, .low, .none])
    }
    
    // MARK: - Filtering Tests
    
    func testFilteringByThreatLevel() {
        // Given
        let events = [
            TestDataFactory.createNetworkEvent(threatLevel: .none),
            TestDataFactory.createNetworkEvent(threatLevel: .low),
            TestDataFactory.createNetworkEvent(threatLevel: .medium),
            TestDataFactory.createNetworkEvent(threatLevel: .high),
            TestDataFactory.createNetworkEvent(threatLevel: .critical)
        ]
        
        // When
        let highThreatEvents = events.filter { $0.threatLevel == .high }
        let criticalThreatEvents = events.filter { $0.threatLevel == .critical }
        let noThreatEvents = events.filter { $0.threatLevel == .none }
        
        // Then
        XCTAssertEqual(highThreatEvents.count, 1)
        XCTAssertEqual(criticalThreatEvents.count, 1)
        XCTAssertEqual(noThreatEvents.count, 1)
    }
    
    func testFilteringByPriority() {
        // Given
        let events = [
            TestDataFactory.createNetworkEvent(threatLevel: .none),
            TestDataFactory.createNetworkEvent(threatLevel: .low),
            TestDataFactory.createNetworkEvent(threatLevel: .medium),
            TestDataFactory.createNetworkEvent(threatLevel: .high),
            TestDataFactory.createNetworkEvent(threatLevel: .critical)
        ]
        
        // When
        let highPriorityEvents = events.filter { $0.threatLevel.priority >= 3 }
        let lowPriorityEvents = events.filter { $0.threatLevel.priority < 2 }
        
        // Then
        XCTAssertEqual(highPriorityEvents.count, 2) // high and critical
        XCTAssertEqual(lowPriorityEvents.count, 2) // none and low
    }
    
    // MARK: - Alert Logic Tests
    
    func testAlertLogicCombination() {
        // Given
        let events = [
            TestDataFactory.createNetworkEvent(threatLevel: .none),
            TestDataFactory.createNetworkEvent(threatLevel: .low),
            TestDataFactory.createNetworkEvent(threatLevel: .medium),
            TestDataFactory.createNetworkEvent(threatLevel: .high),
            TestDataFactory.createNetworkEvent(threatLevel: .critical)
        ]
        
        // When
        let immediateAlertEvents = events.filter { $0.threatLevel.requiresImmediateAlert }
        let notificationEvents = events.filter { $0.threatLevel.requiresNotification }
        
        // Then
        XCTAssertEqual(immediateAlertEvents.count, 2) // high and critical
        XCTAssertEqual(notificationEvents.count, 4) // all except none
    }
    
    func testAlertLogicConsistency() {
        // Given & When & Then
        for level in NetworkThreatLevel.allCases {
            // If it requires immediate alert, it should also require notification
            if level.requiresImmediateAlert {
                XCTAssertTrue(level.requiresNotification)
            }
            
            // Priority should be consistent with alert requirements
            if level.requiresImmediateAlert {
                XCTAssertGreaterThanOrEqual(level.priority, 3)
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testThreatLevelEquality() {
        // Given & When & Then
        XCTAssertEqual(NetworkThreatLevel.none, NetworkThreatLevel.none)
        XCTAssertEqual(NetworkThreatLevel.critical, NetworkThreatLevel.critical)
        XCTAssertNotEqual(NetworkThreatLevel.none, NetworkThreatLevel.critical)
    }
    
    func testThreatLevelHashable() {
        // Given
        let levels = NetworkThreatLevel.allCases
        let levelSet = Set(levels)
        
        // When & Then
        XCTAssertEqual(levelSet.count, levels.count)
    }
    
    // MARK: - Performance Tests
    
    func testPriorityPerformance() {
        // Given
        let level = NetworkThreatLevel.critical
        
        measure {
            for _ in 0..<10000 {
                _ = level.priority
            }
        }
    }
    
    func testAlertRequirementPerformance() {
        // Given
        let level = NetworkThreatLevel.high
        
        measure {
            for _ in 0..<10000 {
                _ = level.requiresImmediateAlert
                _ = level.requiresNotification
            }
        }
    }
    
    func testCodablePerformance() {
        // Given
        let level = NetworkThreatLevel.medium
        
        measure {
            for _ in 0..<1000 {
                let data = try? JSONEncoder().encode(level)
                _ = try? JSONDecoder().decode(NetworkThreatLevel.self, from: data!)
            }
        }
    }
    
    // MARK: - String Conversion Tests
    
    func testStringConversion() {
        // Given & When & Then
        XCTAssertEqual(String(describing: NetworkThreatLevel.none), "none")
        XCTAssertEqual(String(describing: NetworkThreatLevel.low), "low")
        XCTAssertEqual(String(describing: NetworkThreatLevel.medium), "medium")
        XCTAssertEqual(String(describing: NetworkThreatLevel.high), "high")
        XCTAssertEqual(String(describing: NetworkThreatLevel.critical), "critical")
    }
    
    func testRawValueInitialization() {
        // Given & When & Then
        XCTAssertEqual(NetworkThreatLevel(rawValue: "none"), NetworkThreatLevel.none)
        XCTAssertEqual(NetworkThreatLevel(rawValue: "low"), .low)
        XCTAssertEqual(NetworkThreatLevel(rawValue: "medium"), .medium)
        XCTAssertEqual(NetworkThreatLevel(rawValue: "high"), .high)
        XCTAssertEqual(NetworkThreatLevel(rawValue: "critical"), .critical)
        XCTAssertNil(NetworkThreatLevel(rawValue: "invalid"))
    }
}
