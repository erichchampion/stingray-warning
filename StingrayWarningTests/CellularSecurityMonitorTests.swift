import XCTest
@testable import Stingray_Warning

/// Unit tests for CellularSecurityMonitor event filtering functionality
/// Following TDD principles: Red -> Green -> Refactor
class CellularSecurityMonitorTests: XCTestCase {
    
    var monitor: CellularSecurityMonitor!
    var mockEventStore: MockEventStore!
    
    override func setUp() {
        super.setUp()
        monitor = CellularSecurityMonitor()
        mockEventStore = MockEventStore()
        monitor.setEventStore(mockEventStore)
    }
    
    override func tearDown() {
        monitor = nil
        mockEventStore = nil
        super.tearDown()
    }
    
    // MARK: - Event Filtering Tests
    
    func testShouldFilterEvent_WhenSameTechnologyAndNoThreat_ReturnsTrue() {
        // Given: First event with 5G technology and no threat
        let firstEvent = createNetworkEvent(
            radioTechnology: "CTRadioAccessTechnologyNRNSA",
            threatLevel: .none
        )
        
        // When: Processing the first event
        monitor.processNetworkEvent(firstEvent)
        
        // Then: Event should be stored (not filtered)
        XCTAssertEqual(mockEventStore.addedEvents.count, 1)
        XCTAssertEqual(mockEventStore.addedEvents.first?.radioTechnology, "CTRadioAccessTechnologyNRNSA")
        
        // Given: Second event with same technology and no threat
        let secondEvent = createNetworkEvent(
            radioTechnology: "CTRadioAccessTechnologyNRNSA",
            threatLevel: .none
        )
        
        // When: Processing the second event
        monitor.processNetworkEvent(secondEvent)
        
        // Then: Second event should be filtered out (not stored)
        XCTAssertEqual(mockEventStore.addedEvents.count, 1, "Duplicate no-threat events should be filtered")
    }
    
    func testShouldNotFilterEvent_WhenDifferentTechnology_ReturnsFalse() {
        // Given: First event with 5G technology
        let firstEvent = createNetworkEvent(
            radioTechnology: "CTRadioAccessTechnologyNRNSA",
            threatLevel: .none
        )
        
        // When: Processing the first event
        monitor.processNetworkEvent(firstEvent)
        
        // Given: Second event with different technology (4G)
        let secondEvent = createNetworkEvent(
            radioTechnology: "CTRadioAccessTechnologyLTE",
            threatLevel: .none
        )
        
        // When: Processing the second event
        monitor.processNetworkEvent(secondEvent)
        
        // Then: Both events should be stored (technology changed)
        XCTAssertEqual(mockEventStore.addedEvents.count, 2, "Events with different technologies should not be filtered")
        XCTAssertEqual(mockEventStore.addedEvents[0].radioTechnology, "CTRadioAccessTechnologyNRNSA")
        XCTAssertEqual(mockEventStore.addedEvents[1].radioTechnology, "CTRadioAccessTechnologyLTE")
    }
    
    func testShouldNotFilterEvent_WhenSameTechnologyButDifferentThreatLevel_ReturnsFalse() {
        // Given: First event with 5G technology and no threat
        let firstEvent = createNetworkEvent(
            radioTechnology: "CTRadioAccessTechnologyNRNSA",
            threatLevel: .none
        )
        
        // When: Processing the first event
        monitor.processNetworkEvent(firstEvent)
        
        // Given: Second event with same technology but medium threat
        let secondEvent = createNetworkEvent(
            radioTechnology: "CTRadioAccessTechnologyNRNSA",
            threatLevel: .medium
        )
        
        // When: Processing the second event
        monitor.processNetworkEvent(secondEvent)
        
        // Then: Both events should be stored (threat level changed)
        XCTAssertEqual(mockEventStore.addedEvents.count, 2, "Events with different threat levels should not be filtered")
        XCTAssertEqual(mockEventStore.addedEvents[0].threatLevel, NetworkThreatLevel.none)
        XCTAssertEqual(mockEventStore.addedEvents[1].threatLevel, NetworkThreatLevel.medium)
    }
    
    func testShouldNotFilterEvent_WhenFirstEvent_ReturnsFalse() {
        // Given: First event (no previous events)
        let firstEvent = createNetworkEvent(
            radioTechnology: "CTRadioAccessTechnologyNRNSA",
            threatLevel: .none
        )
        
        // When: Processing the first event
        monitor.processNetworkEvent(firstEvent)
        
        // Then: Event should be stored (first event is never filtered)
        XCTAssertEqual(mockEventStore.addedEvents.count, 1)
        XCTAssertEqual(mockEventStore.addedEvents.first?.radioTechnology, "CTRadioAccessTechnologyNRNSA")
    }
    
    func testShouldNotFilterEvent_WhenNilRadioTechnology_ReturnsFalse() {
        // Given: First event with nil radio technology
        let firstEvent = createNetworkEvent(
            radioTechnology: nil,
            threatLevel: .none
        )
        
        // When: Processing the first event
        monitor.processNetworkEvent(firstEvent)
        
        // Given: Second event with nil radio technology
        let secondEvent = createNetworkEvent(
            radioTechnology: nil,
            threatLevel: .none
        )
        
        // When: Processing the second event
        monitor.processNetworkEvent(secondEvent)
        
        // Then: Both events should be stored (nil technology comparison should not filter)
        XCTAssertEqual(mockEventStore.addedEvents.count, 2, "Events with nil radio technology should not be filtered")
    }
    
    func testShouldFilterMultipleConsecutiveIdenticalEvents() {
        // Given: Multiple identical events
        let identicalEvent = createNetworkEvent(
            radioTechnology: "CTRadioAccessTechnologyNRNSA",
            threatLevel: .none
        )
        
        // When: Processing multiple identical events
        for _ in 0..<5 {
            monitor.processNetworkEvent(identicalEvent)
        }
        
        // Then: Only the first event should be stored
        XCTAssertEqual(mockEventStore.addedEvents.count, 1, "Only the first identical event should be stored")
        XCTAssertEqual(mockEventStore.addedEvents.first?.radioTechnology, "CTRadioAccessTechnologyNRNSA")
    }
    
    func testShouldStoreEventAfterFilteredSequence_WhenTechnologyChanges() {
        // Given: Multiple identical events followed by different technology
        let identicalEvent = createNetworkEvent(
            radioTechnology: "CTRadioAccessTechnologyNRNSA",
            threatLevel: .none
        )
        
        let differentEvent = createNetworkEvent(
            radioTechnology: "CTRadioAccessTechnologyLTE",
            threatLevel: .none
        )
        
        // When: Processing identical events then different technology
        monitor.processNetworkEvent(identicalEvent) // Should be stored
        monitor.processNetworkEvent(identicalEvent) // Should be filtered
        monitor.processNetworkEvent(identicalEvent) // Should be filtered
        monitor.processNetworkEvent(differentEvent) // Should be stored (different technology)
        
        // Then: Only first and last events should be stored
        XCTAssertEqual(mockEventStore.addedEvents.count, 2, "First and technology-change events should be stored")
        XCTAssertEqual(mockEventStore.addedEvents[0].radioTechnology, "CTRadioAccessTechnologyNRNSA")
        XCTAssertEqual(mockEventStore.addedEvents[1].radioTechnology, "CTRadioAccessTechnologyLTE")
    }
    
    // MARK: - Helper Methods
    
    private func createNetworkEvent(radioTechnology: String?, threatLevel: NetworkThreatLevel) -> NetworkEvent {
        return NetworkEvent(
            radioTechnology: radioTechnology,
            threatLevel: threatLevel,
            description: "Test event with \(radioTechnology ?? "nil") technology and \(threatLevel.description) threat level"
        )
    }
}
