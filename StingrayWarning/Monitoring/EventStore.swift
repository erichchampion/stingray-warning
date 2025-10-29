import Foundation
import CoreData

/// Manages persistent storage of network events and anomalies
class EventStore: ObservableObject {
    
    @Published var events: [NetworkEvent] = []
    @Published var anomalies: [NetworkAnomaly] = []
    
    private let maxStoredEvents = AppConstants.Limits.maxStoredEvents
    private let maxStoredAnomalies = AppConstants.Limits.maxStoredAnomalies
    private let eventRetentionDays = AppConstants.Limits.eventRetentionDays
    
    private let eventsKey = AppConstants.UserDefaultsKeys.storedNetworkEvents
    private let anomaliesKey = AppConstants.UserDefaultsKeys.storedNetworkAnomalies
    
    init() {
        loadStoredData()
    }
    
    // MARK: - Event Management
    
    /// Add a new network event
    func addEvent(_ event: NetworkEvent) {
        events.append(event)
        
        // Trim to max size using efficient operation
        trimEvents()
        
        // Remove old events
        cleanupOldEvents()
        
        // Save to persistent storage asynchronously
        saveEventsAsync()
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
    
    /// Get recent events (last N events, default 3)
    func getRecentEvents(limit: Int = 3) -> [NetworkEvent] {
        return Array(events.suffix(limit))
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
        
        // Trim to max size using efficient operation
        trimAnomalies()
        
        // Remove old anomalies
        cleanupOldAnomalies()
        
        // Save to persistent storage asynchronously
        saveAnomaliesAsync()
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
        saveEventsAsync()
        saveAnomaliesAsync()
    }
    
    // MARK: - Private Methods
    
    private func loadStoredData() {
        loadEvents()
        loadAnomalies()
    }
    
    private func loadEvents() {
        UserDefaultsManager.getCodableAsync([NetworkEvent].self, forKey: eventsKey) { result in
            switch result {
            case .success(let decodedEvents):
                if let events = decodedEvents {
                    self.events = events
                }
            case .failure(let error):
                print("Failed to load events: \(error)")
            }
        }
    }
    
    private func loadAnomalies() {
        UserDefaultsManager.getCodableAsync([NetworkAnomaly].self, forKey: anomaliesKey) { result in
            switch result {
            case .success(let decodedAnomalies):
                if let anomalies = decodedAnomalies {
                    self.anomalies = anomalies
                }
            case .failure(let error):
                print("Failed to load anomalies: \(error)")
            }
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
        let cutoffDate = Date().addingTimeInterval(-TimeInterval(eventRetentionDays) * AppConstants.TimeIntervals.day)
        events.removeAll { $0.timestamp < cutoffDate }
    }
    
    private func cleanupOldAnomalies() {
        let cutoffDate = Date().addingTimeInterval(-TimeInterval(eventRetentionDays) * AppConstants.TimeIntervals.day)
        anomalies.removeAll { $0.startTime < cutoffDate }
    }
    
    // MARK: - Optimized Array Operations
    
    private func trimEvents() {
        if events.count > maxStoredEvents {
            let removeCount = events.count - maxStoredEvents
            events.removeSubrange(0..<removeCount)
        }
    }
    
    private func trimAnomalies() {
        if anomalies.count > maxStoredAnomalies {
            let removeCount = anomalies.count - maxStoredAnomalies
            anomalies.removeSubrange(0..<removeCount)
        }
    }
    
    // MARK: - Async Storage Operations
    
    private func saveEventsAsync() {
        UserDefaultsManager.setCodableAsync(events, forKey: eventsKey) { result in
            switch result {
            case .success:
                break // Successfully saved
            case .failure(let error):
                print("Failed to save events asynchronously: \(error)")
            }
        }
    }
    
    private func saveAnomaliesAsync() {
        UserDefaultsManager.setCodableAsync(anomalies, forKey: anomaliesKey) { result in
            switch result {
            case .success:
                break // Successfully saved
            case .failure(let error):
                print("Failed to save anomalies asynchronously: \(error)")
            }
        }
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
