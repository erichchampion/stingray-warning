import Foundation
import CoreData

/// Manages persistent storage of network events and anomalies
class EventStore: ObservableObject {
    
    @Published var events: [NetworkEvent] = []
    @Published var anomalies: [NetworkAnomaly] = []
    
    private let maxStoredEvents = 1000
    private let maxStoredAnomalies = 500
    private let eventRetentionDays = 7
    
    private let eventsKey = "StoredNetworkEvents"
    private let anomaliesKey = "StoredNetworkAnomalies"
    
    init() {
        loadStoredData()
    }
    
    // MARK: - Event Management
    
    /// Add a new network event
    func addEvent(_ event: NetworkEvent) {
        events.append(event)
        
        // Trim to max size
        if events.count > maxStoredEvents {
            events.removeFirst(events.count - maxStoredEvents)
        }
        
        // Remove old events
        cleanupOldEvents()
        
        // Save to persistent storage
        saveEvents()
    }
    
    /// Get events filtered by threat level
    func getEvents(threatLevel: NetworkThreatLevel? = nil) -> [NetworkEvent] {
        if let level = threatLevel {
            return events.filter { $0.threatLevel == level }
        }
        return events
    }
    
    /// Get events from a specific date range
    func getEvents(from startDate: Date, to endDate: Date) -> [NetworkEvent] {
        return events.filter { event in
            event.timestamp >= startDate && event.timestamp <= endDate
        }
    }
    
    /// Get recent events (last 24 hours)
    func getRecentEvents() -> [NetworkEvent] {
        let oneDayAgo = Date().addingTimeInterval(-24 * 60 * 60)
        return events.filter { $0.timestamp >= oneDayAgo }
    }
    
    /// Get events count by threat level
    func getEventCounts() -> [NetworkThreatLevel: Int] {
        var counts: [NetworkThreatLevel: Int] = [:]
        
        for level in NetworkThreatLevel.allCases {
            counts[level] = events.filter { $0.threatLevel == level }.count
        }
        
        return counts
    }
    
    // MARK: - Anomaly Management
    
    /// Add a new network anomaly
    func addAnomaly(_ anomaly: NetworkAnomaly) {
        anomalies.append(anomaly)
        
        // Trim to max size
        if anomalies.count > maxStoredAnomalies {
            anomalies.removeFirst(anomalies.count - maxStoredAnomalies)
        }
        
        // Remove old anomalies
        cleanupOldAnomalies()
        
        // Save to persistent storage
        saveAnomalies()
    }
    
    /// Get anomalies filtered by type
    func getAnomalies(type: AnomalyType? = nil) -> [NetworkAnomaly] {
        if let anomalyType = type {
            return anomalies.filter { $0.anomalyType == anomalyType }
        }
        return anomalies
    }
    
    /// Get active anomalies
    func getActiveAnomalies() -> [NetworkAnomaly] {
        return anomalies.filter { $0.isActive }
    }
    
    /// End an anomaly
    func endAnomaly(_ anomalyId: UUID) {
        if let index = anomalies.firstIndex(where: { $0.id == anomalyId }) {
            var updatedAnomaly = anomalies[index]
            updatedAnomaly = NetworkAnomaly(
                anomalyType: updatedAnomaly.anomalyType,
                severity: updatedAnomaly.severity,
                description: updatedAnomaly.description,
                relatedEvents: updatedAnomaly.relatedEvents,
                confidence: updatedAnomaly.confidence,
                locationContext: updatedAnomaly.locationContext
            )
            anomalies[index] = updatedAnomaly
            saveAnomalies()
        }
    }
    
    // MARK: - Statistics
    
    /// Get daily statistics
    func getDailyStatistics(for date: Date) -> DailyStatistics {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let dayEvents = getEvents(from: startOfDay, to: endOfDay)
        let dayAnomalies = anomalies.filter { anomaly in
            calendar.isDate(anomaly.startTime, inSameDayAs: date)
        }
        
        return DailyStatistics(
            date: date,
            totalEvents: dayEvents.count,
            threatLevelCounts: getEventCounts(),
            anomaliesDetected: dayAnomalies.count,
            averageThreatLevel: calculateAverageThreatLevel(events: dayEvents)
        )
    }
    
    /// Get weekly statistics
    func getWeeklyStatistics() -> WeeklyStatistics {
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
        
        let weekEvents = getEvents(from: weekAgo, to: now)
        let weekAnomalies = anomalies.filter { $0.startTime >= weekAgo }
        
        return WeeklyStatistics(
            startDate: weekAgo,
            endDate: now,
            totalEvents: weekEvents.count,
            totalAnomalies: weekAnomalies.count,
            averageEventsPerDay: Double(weekEvents.count) / 7.0,
            threatLevelDistribution: getEventCounts()
        )
    }
    
    // MARK: - Data Export
    
    /// Export events to JSON
    func exportEventsToJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(events)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Failed to export events: \(error)")
            return nil
        }
    }
    
    /// Export anomalies to JSON
    func exportAnomaliesToJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(anomalies)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Failed to export anomalies: \(error)")
            return nil
        }
    }
    
    /// Clear all stored data
    func clearAllData() {
        events.removeAll()
        anomalies.removeAll()
        saveEvents()
        saveAnomalies()
    }
    
    // MARK: - Private Methods
    
    private func loadStoredData() {
        loadEvents()
        loadAnomalies()
    }
    
    private func loadEvents() {
        if let data = UserDefaults.standard.data(forKey: eventsKey),
           let decodedEvents = try? JSONDecoder().decode([NetworkEvent].self, from: data) {
            events = decodedEvents
        }
    }
    
    private func loadAnomalies() {
        if let data = UserDefaults.standard.data(forKey: anomaliesKey),
           let decodedAnomalies = try? JSONDecoder().decode([NetworkAnomaly].self, from: data) {
            anomalies = decodedAnomalies
        }
    }
    
    private func saveEvents() {
        if let data = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(data, forKey: eventsKey)
        }
    }
    
    private func saveAnomalies() {
        if let data = try? JSONEncoder().encode(anomalies) {
            UserDefaults.standard.set(data, forKey: anomaliesKey)
        }
    }
    
    private func cleanupOldEvents() {
        let cutoffDate = Date().addingTimeInterval(-TimeInterval(eventRetentionDays * 24 * 60 * 60))
        events.removeAll { $0.timestamp < cutoffDate }
    }
    
    private func cleanupOldAnomalies() {
        let cutoffDate = Date().addingTimeInterval(-TimeInterval(eventRetentionDays * 24 * 60 * 60))
        anomalies.removeAll { $0.startTime < cutoffDate }
    }
    
    private func calculateAverageThreatLevel(events: [NetworkEvent]) -> Double {
        guard !events.isEmpty else { return 0.0 }
        
        let totalScore = events.reduce(0) { $0 + $1.threatLevel.priority }
        return Double(totalScore) / Double(events.count)
    }
}

// MARK: - Supporting Types

struct DailyStatistics {
    let date: Date
    let totalEvents: Int
    let threatLevelCounts: [NetworkThreatLevel: Int]
    let anomaliesDetected: Int
    let averageThreatLevel: Double
}

struct WeeklyStatistics {
    let startDate: Date
    let endDate: Date
    let totalEvents: Int
    let totalAnomalies: Int
    let averageEventsPerDay: Double
    let threatLevelDistribution: [NetworkThreatLevel: Int]
}
