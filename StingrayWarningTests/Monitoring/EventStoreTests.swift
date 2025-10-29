import XCTest
@testable import Stingray_Warning

/// Unit tests for EventStore data persistence and management
class EventStoreTests: XCTestCase {
    
    var eventStore: EventStore!
    var mockUserDefaults: MockUserDefaults!
    
    override func setUp() {
        super.setUp()
        mockUserDefaults = MockUserDefaults()
        eventStore = EventStore()
        // Note: In a real implementation, we'd need to inject the mock UserDefaults
        // For now, we'll test the public interface
    }
    
    override func tearDown() {
        eventStore = nil
        mockUserDefaults = nil
        super.tearDown()
    }
    
    // MARK: - Event Management Tests
    
    func testAddEvent() {
        // Given
        let event = TestDataFactory.createNetworkEvent()
        
        // When
        eventStore.addEvent(event)
        
        // Then
        XCTAssertEqual(eventStore.events.count, 1)
        XCTAssertEqual(eventStore.events.first?.id, event.id)
        XCTAssertEqual(eventStore.events.first?.threatLevel, event.threatLevel)
    }
    
    func testAddMultipleEvents() {
        // Given
        let events = [
            TestDataFactory.createNetworkEvent(threatLevel: .none),
            TestDataFactory.createNetworkEvent(threatLevel: .low),
            TestDataFactory.createNetworkEvent(threatLevel: .medium)
        ]
        
        // When
        for event in events {
            eventStore.addEvent(event)
        }
        
        // Then
        XCTAssertEqual(eventStore.events.count, 3)
        XCTAssertEqual(eventStore.events[0].threatLevel, .none)
        XCTAssertEqual(eventStore.events[1].threatLevel, .low)
        XCTAssertEqual(eventStore.events[2].threatLevel, .medium)
    }
    
    func testAddAnomaly() {
        // Given
        let anomaly = TestDataFactory.createNetworkAnomaly()
        
        // When
        eventStore.addAnomaly(anomaly)
        
        // Then
        XCTAssertEqual(eventStore.anomalies.count, 1)
        XCTAssertEqual(eventStore.anomalies.first?.id, anomaly.id)
        XCTAssertEqual(eventStore.anomalies.first?.anomalyType, anomaly.anomalyType)
    }
    
    func testAddMultipleAnomalies() {
        // Given
        let anomalies = [
            TestDataFactory.createNetworkAnomaly(anomalyType: .suspicious2GConnection),
            TestDataFactory.createNetworkAnomaly(anomalyType: .rapidTechnologyChange),
            TestDataFactory.createNetworkAnomaly(anomalyType: .imsiCatcherSuspected)
        ]
        
        // When
        for anomaly in anomalies {
            eventStore.addAnomaly(anomaly)
        }
        
        // Then
        XCTAssertEqual(eventStore.anomalies.count, 3)
        XCTAssertEqual(eventStore.anomalies[0].anomalyType, .suspicious2GConnection)
        XCTAssertEqual(eventStore.anomalies[1].anomalyType, .rapidTechnologyChange)
        XCTAssertEqual(eventStore.anomalies[2].anomalyType, .imsiCatcherSuspected)
    }
    
    // MARK: - Query Tests
    
    func testGetEventsWithThreatLevel() {
        // Given
        let events = [
            TestDataFactory.createNetworkEvent(threatLevel: .none),
            TestDataFactory.createNetworkEvent(threatLevel: .low),
            TestDataFactory.createNetworkEvent(threatLevel: .medium),
            TestDataFactory.createNetworkEvent(threatLevel: .high),
            TestDataFactory.createNetworkEvent(threatLevel: .critical)
        ]
        
        for event in events {
            eventStore.addEvent(event)
        }
        
        // When
        let highThreatEvents = eventStore.getEvents(threatLevel: .high)
        let criticalThreatEvents = eventStore.getEvents(threatLevel: .critical)
        let noThreatEvents = eventStore.getEvents(threatLevel: NetworkThreatLevel.none)
        
        // Then
        XCTAssertEqual(highThreatEvents.count, 1)
        XCTAssertEqual(criticalThreatEvents.count, 1)
        XCTAssertEqual(noThreatEvents.count, 1)
        XCTAssertEqual(highThreatEvents.first?.threatLevel, .high)
        XCTAssertEqual(criticalThreatEvents.first?.threatLevel, .critical)
        XCTAssertEqual(noThreatEvents.first?.threatLevel, NetworkThreatLevel.none)
    }
    
    func testGetEventsWithNilThreatLevel() {
        // Given
        let events = [
            TestDataFactory.createNetworkEvent(threatLevel: .none),
            TestDataFactory.createNetworkEvent(threatLevel: .low),
            TestDataFactory.createNetworkEvent(threatLevel: .medium)
        ]
        
        for event in events {
            eventStore.addEvent(event)
        }
        
        // When
        let allEvents = eventStore.getEvents(threatLevel: nil)
        
        // Then
        XCTAssertEqual(allEvents.count, 3)
    }
    
    func testGetEventsWithDateRange() {
        // Given
        let now = Date()
        let pastEvent = TestDataFactory.createNetworkEvent()
        let recentEvent = TestDataFactory.createNetworkEvent()
        let futureEvent = TestDataFactory.createNetworkEvent()
        
        // Add events with different timestamps
        eventStore.addEvent(pastEvent)
        eventStore.addEvent(recentEvent)
        eventStore.addEvent(futureEvent)
        
        // When
        let startDate = now.addingTimeInterval(-3600) // 1 hour ago
        let endDate = now.addingTimeInterval(3600) // 1 hour from now
        let eventsInRange = eventStore.getEvents(from: startDate, to: endDate)
        
        // Then
        // All events should be in range since they're created with current timestamp
        XCTAssertEqual(eventsInRange.count, 3)
    }
    
    func testGetEventsWithEmptyDateRange() {
        // Given
        let event = TestDataFactory.createNetworkEvent()
        eventStore.addEvent(event)
        
        // When
        let futureStart = Date().addingTimeInterval(3600)
        let futureEnd = Date().addingTimeInterval(7200)
        let eventsInRange = eventStore.getEvents(from: futureStart, to: futureEnd)
        
        // Then
        XCTAssertEqual(eventsInRange.count, 0)
    }
    
    func testGetRecentEvents() {
        // Given
        let events = [
            TestDataFactory.createNetworkEvent(threatLevel: .none),
            TestDataFactory.createNetworkEvent(threatLevel: .low),
            TestDataFactory.createNetworkEvent(threatLevel: .medium),
            TestDataFactory.createNetworkEvent(threatLevel: .high),
            TestDataFactory.createNetworkEvent(threatLevel: .critical)
        ]
        
        for event in events {
            eventStore.addEvent(event)
        }
        
        // When
        let recentEvents = eventStore.getRecentEvents()
        
        // Then
        XCTAssertEqual(recentEvents.count, 3)
        // Should return the most recent events (last 3 added)
        XCTAssertEqual(recentEvents[0].threatLevel, NetworkThreatLevel.medium)
        XCTAssertEqual(recentEvents[1].threatLevel, NetworkThreatLevel.high)
        XCTAssertEqual(recentEvents[2].threatLevel, NetworkThreatLevel.critical)
    }
    
    func testGetRecentEventsWithLimit() {
        // Given
        let events = Array(0..<10).map { _ in TestDataFactory.createNetworkEvent() }
        
        for event in events {
            eventStore.addEvent(event)
        }
        
        // When
        let recentEvents = eventStore.getRecentEvents(limit: 5)
        
        // Then
        XCTAssertEqual(recentEvents.count, 5)
    }
    
    func testGetRecentEventsWithLimitGreaterThanAvailable() {
        // Given
        let events = [
            TestDataFactory.createNetworkEvent(),
            TestDataFactory.createNetworkEvent()
        ]
        
        for event in events {
            eventStore.addEvent(event)
        }
        
        // When
        let recentEvents = eventStore.getRecentEvents()
        
        // Then
        XCTAssertEqual(recentEvents.count, 2)
    }
    
    // MARK: - Data Management Tests
    
    func testClearAllEvents() {
        // Given
        let events = [
            TestDataFactory.createNetworkEvent(),
            TestDataFactory.createNetworkEvent(),
            TestDataFactory.createNetworkEvent()
        ]
        
        for event in events {
            eventStore.addEvent(event)
        }
        
        XCTAssertEqual(eventStore.events.count, 3)
        
        // When
        eventStore.clearAllData()
        
        // Then
        XCTAssertEqual(eventStore.events.count, 0)
    }
    
    func testClearAllAnomalies() {
        // Given
        let anomalies = [
            TestDataFactory.createNetworkAnomaly(),
            TestDataFactory.createNetworkAnomaly(),
            TestDataFactory.createNetworkAnomaly()
        ]
        
        for anomaly in anomalies {
            eventStore.addAnomaly(anomaly)
        }
        
        XCTAssertEqual(eventStore.anomalies.count, 3)
        
        // When
        eventStore.clearAllData()
        
        // Then
        XCTAssertEqual(eventStore.anomalies.count, 0)
    }
    
    func testClearAllData() {
        // Given
        let events = [TestDataFactory.createNetworkEvent(), TestDataFactory.createNetworkEvent()]
        let anomalies = [TestDataFactory.createNetworkAnomaly(), TestDataFactory.createNetworkAnomaly()]
        
        for event in events {
            eventStore.addEvent(event)
        }
        for anomaly in anomalies {
            eventStore.addAnomaly(anomaly)
        }
        
        XCTAssertEqual(eventStore.events.count, 2)
        XCTAssertEqual(eventStore.anomalies.count, 2)
        
        // When
        eventStore.clearAllData()
        
        // Then
        XCTAssertEqual(eventStore.events.count, 0)
        XCTAssertEqual(eventStore.anomalies.count, 0)
    }
    
    // MARK: - Data Export Tests
    
    func testExportEventsAsJSON() {
        // Given
        let events = [
            TestDataFactory.createNetworkEvent(threatLevel: .low),
            TestDataFactory.createNetworkEvent(threatLevel: .medium),
            TestDataFactory.createNetworkEvent(threatLevel: .high)
        ]
        
        for event in events {
            eventStore.addEvent(event)
        }
        
        // When
        let jsonData = eventStore.exportEventsToJSON()
        
        // Then
        XCTAssertNotNil(jsonData)
        
        // Verify JSON can be decoded
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedEvents = try? decoder.decode([NetworkEvent].self, from: jsonData!.data(using: .utf8)!)
        XCTAssertNotNil(decodedEvents)
        XCTAssertEqual(decodedEvents?.count, 3)
    }
    
    func testExportEventsAsJSONWithNoEvents() {
        // Given
        // No events added
        
        // When
        let jsonData = eventStore.exportEventsToJSON()
        
        // Then
        XCTAssertNotNil(jsonData)
        
        // Should be empty array
        let decodedEvents = try? JSONDecoder().decode([NetworkEvent].self, from: jsonData!.data(using: .utf8)!)
        XCTAssertNotNil(decodedEvents)
        XCTAssertEqual(decodedEvents?.count, 0)
    }
    
    func testExportAnomaliesAsJSON() {
        // Given
        let anomalies = [
            TestDataFactory.createNetworkAnomaly(anomalyType: .suspicious2GConnection),
            TestDataFactory.createNetworkAnomaly(anomalyType: .rapidTechnologyChange)
        ]
        
        for anomaly in anomalies {
            eventStore.addAnomaly(anomaly)
        }
        
        // When
        let jsonData = eventStore.exportAnomaliesToJSON()
        
        // Then
        XCTAssertNotNil(jsonData)
        
        // Verify JSON can be decoded
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedAnomalies = try? decoder.decode([NetworkAnomaly].self, from: jsonData!.data(using: .utf8)!)
        XCTAssertNotNil(decodedAnomalies)
        XCTAssertEqual(decodedAnomalies?.count, 2)
    }
    
    func testExportAnomaliesAsJSONWithNoAnomalies() {
        // Given
        // No anomalies added
        
        // When
        let jsonData = eventStore.exportAnomaliesToJSON()
        
        // Then
        XCTAssertNotNil(jsonData)
        
        // Should be empty array
        let decodedAnomalies = try? JSONDecoder().decode([NetworkAnomaly].self, from: jsonData!.data(using: .utf8)!)
        XCTAssertNotNil(decodedAnomalies)
        XCTAssertEqual(decodedAnomalies?.count, 0)
    }
    
    // MARK: - Edge Cases
    
    func testAddEventWithNilValues() {
        // Given
        let event = TestDataFactory.createNetworkEvent(
            radioTechnology: nil,
            carrierName: nil,
            carrierCountryCode: nil,
            carrierMobileCountryCode: nil,
            carrierMobileNetworkCode: nil,
            threatLevel: .none,
            description: "Test with nil values"
        )
        
        // When
        eventStore.addEvent(event)
        
        // Then
        XCTAssertEqual(eventStore.events.count, 1)
        XCTAssertNil(eventStore.events.first?.radioTechnology)
        XCTAssertNil(eventStore.events.first?.carrierName)
    }
    
    func testAddAnomalyWithEmptyRelatedEvents() {
        // Given
        let anomaly = TestDataFactory.createNetworkAnomaly(relatedEvents: [])
        
        // When
        eventStore.addAnomaly(anomaly)
        
        // Then
        XCTAssertEqual(eventStore.anomalies.count, 1)
        XCTAssertTrue(eventStore.anomalies.first?.relatedEvents.isEmpty ?? false)
    }
    
    func testAddAnomalyWithMultipleRelatedEvents() {
        // Given
        let relatedEvents = [UUID(), UUID(), UUID()]
        let anomaly = TestDataFactory.createNetworkAnomaly(relatedEvents: relatedEvents)
        
        // When
        eventStore.addAnomaly(anomaly)
        
        // Then
        XCTAssertEqual(eventStore.anomalies.count, 1)
        XCTAssertEqual(eventStore.anomalies.first?.relatedEvents.count, 3)
    }
    
    // MARK: - Performance Tests
    
    func testAddEventPerformance() {
        // Given
        let events = Array(0..<100).map { _ in TestDataFactory.createNetworkEvent() }
        
        // When & Then
        measure {
            for event in events {
                eventStore.addEvent(event)
            }
        }
    }
    
    func testQueryPerformance() {
        // Given
        let events = Array(0..<1000).map { _ in TestDataFactory.createNetworkEvent() }
        
        for event in events {
            eventStore.addEvent(event)
        }
        
        // When & Then
        measure {
            _ = eventStore.getEvents(threatLevel: .medium)
            _ = eventStore.getRecentEvents()
        }
    }
    
    func testExportPerformance() {
        // Given
        let events = Array(0..<500).map { _ in TestDataFactory.createNetworkEvent() }
        let anomalies = Array(0..<100).map { _ in TestDataFactory.createNetworkAnomaly() }
        
        for event in events {
            eventStore.addEvent(event)
        }
        for anomaly in anomalies {
            eventStore.addAnomaly(anomaly)
        }
        
        // When & Then
        measure {
            _ = eventStore.exportEventsToJSON()
            _ = eventStore.exportAnomaliesToJSON()
        }
    }
}
