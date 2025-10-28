import SwiftUI

struct EventHistoryView: View {
    @StateObject private var eventStore = EventStore()
    @State private var selectedFilter: ThreatLevelFilter = .all
    @State private var selectedTimeRange: TimeRange = .day
    @State private var showingExportSheet = false
    @State private var showingClearAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Controls
                VStack(spacing: 12) {
                    // Threat Level Filter
                    Picker("Threat Level", selection: $selectedFilter) {
                        ForEach(ThreatLevelFilter.allCases, id: \.self) { filter in
                            Text(filter.title).tag(filter)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    // Time Range Filter
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.title).tag(range)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Statistics Summary
                StatisticsSummaryView(
                    events: filteredEvents,
                    timeRange: selectedTimeRange
                )
                .padding(.horizontal)
                
                // Events List
                if filteredEvents.isEmpty {
                    EmptyStateView()
                } else {
                    List(filteredEvents) { event in
                        EventRowView(event: event)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Delete", role: .destructive) {
                                    deleteEvent(event)
                                }
                            }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Event History")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Export") {
                        showingExportSheet = true
                    }
                    
                    Button("Clear", role: .destructive) {
                        showingClearAlert = true
                    }
                }
            }
            .sheet(isPresented: $showingExportSheet) {
                ExportDataView(eventStore: eventStore)
            }
            .alert("Clear All Data", isPresented: $showingClearAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    eventStore.clearAllData()
                }
            } message: {
                Text("This will permanently delete all stored events and anomalies. This action cannot be undone.")
            }
        }
    }
    
    private var filteredEvents: [NetworkEvent] {
        var events = eventStore.events
        
        // Filter by threat level
        if selectedFilter != .all {
            events = events.filter { $0.threatLevel == selectedFilter.threatLevel }
        }
        
        // Filter by time range
        let now = Date()
        let startDate: Date
        
        switch selectedTimeRange {
        case .hour:
            startDate = now.addingTimeInterval(-3600)
        case .day:
            startDate = now.addingTimeInterval(-86400)
        case .week:
            startDate = now.addingTimeInterval(-604800)
        case .month:
            startDate = now.addingTimeInterval(-2592000)
        case .all:
            startDate = Date.distantPast
        }
        
        events = events.filter { $0.timestamp >= startDate }
        
        return events.sorted { $0.timestamp > $1.timestamp }
    }
    
    private func deleteEvent(_ event: NetworkEvent) {
        // Remove from event store
        if let index = eventStore.events.firstIndex(where: { $0.id == event.id }) {
            eventStore.events.remove(at: index)
        }
    }
}

enum ThreatLevelFilter: CaseIterable {
    case all
    case none
    case low
    case medium
    case high
    case critical
    
    var title: String {
        switch self {
        case .all: return "All"
        case .none: return "None"
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .critical: return "Critical"
        }
    }
    
    var threatLevel: NetworkThreatLevel? {
        switch self {
        case .all: return nil
        case .none: return .none
        case .low: return .low
        case .medium: return .medium
        case .high: return .high
        case .critical: return .critical
        }
    }
}

enum TimeRange: CaseIterable {
    case hour
    case day
    case week
    case month
    case all
    
    var title: String {
        switch self {
        case .hour: return "1 Hour"
        case .day: return "1 Day"
        case .week: return "1 Week"
        case .month: return "1 Month"
        case .all: return "All Time"
        }
    }
}

struct StatisticsSummaryView: View {
    let events: [NetworkEvent]
    let timeRange: TimeRange
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Summary")
                    .font(.headline)
                Spacer()
                Text(timeRange.title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 20) {
                StatisticItem(
                    title: "Total Events",
                    value: "\(events.count)",
                    color: .blue
                )
                
                StatisticItem(
                    title: "Threats Detected",
                    value: "\(threatEvents.count)",
                    color: .red
                )
                
                StatisticItem(
                    title: "2G Connections",
                    value: "\(twoGEvents.count)",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var threatEvents: [NetworkEvent] {
        events.filter { $0.threatLevel != .none }
    }
    
    private var twoGEvents: [NetworkEvent] {
        events.filter { $0.is2GConnection }
    }
}

struct StatisticItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct EventRowView: View {
    let event: NetworkEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ThreatLevelBadge(level: event.threatLevel)
                Spacer()
                Text(event.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(event.description)
                .font(.body)
            
            if let summary = event.summary {
                Text(summary)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if event.is2GConnection {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text("2G Connection Detected")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            if event.isSuspiciousCarrier {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                    Text("Unknown Carrier")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No Events Found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("No events match your current filters. Try adjusting the time range or threat level filter.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

struct ExportDataView: View {
    let eventStore: EventStore
    @Environment(\.dismiss) private var dismiss
    @State private var exportFormat: ExportFormat = .json
    @State private var includeAnomalies = true
    @State private var showingShareSheet = false
    @State private var exportData: String?
    
    enum ExportFormat: CaseIterable {
        case json
        case csv
        
        var title: String {
            switch self {
            case .json: return "JSON"
            case .csv: return "CSV"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Export Options")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Format")
                            .font(.subheadline)
                        Picker("Format", selection: $exportFormat) {
                            ForEach(ExportFormat.allCases, id: \.self) { format in
                                Text(format.title).tag(format)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    Toggle("Include Anomalies", isOn: $includeAnomalies)
                    
                    Text("Export includes all events and anomalies stored locally on your device. No personal information is included.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                Spacer()
                
                Button("Export Data") {
                    exportData = generateExportData()
                    showingShareSheet = true
                }
                .buttonStyle(.borderedProminent)
                .disabled(exportData == nil)
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let data = exportData {
                    ShareSheet(items: [data])
                }
            }
        }
    }
    
    private func generateExportData() -> String? {
        switch exportFormat {
        case .json:
            return exportAsJSON()
        case .csv:
            return exportAsCSV()
        }
    }
    
    private func exportAsJSON() -> String? {
        var exportObject: [String: Any] = [:]
        
        exportObject["events"] = eventStore.events
        if includeAnomalies {
            exportObject["anomalies"] = eventStore.anomalies
        }
        exportObject["exportDate"] = Date()
        exportObject["appVersion"] = "1.0.0"
        
        do {
            let data = try JSONSerialization.data(withJSONObject: exportObject, options: .prettyPrinted)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Failed to export as JSON: \(error)")
            return nil
        }
    }
    
    private func exportAsCSV() -> String? {
        var csv = "Timestamp,Threat Level,Description,Radio Technology,Carrier Name,MCC,MNC,Is 2G,Suspicious Carrier\n"
        
        for event in eventStore.events {
            let row = [
                ISO8601DateFormatter().string(from: event.timestamp),
                event.threatLevel.rawValue,
                "\"\(event.description.replacingOccurrences(of: "\"", with: "\"\""))\"",
                event.radioTechnology ?? "",
                event.carrierName ?? "",
                event.carrierMobileCountryCode ?? "",
                event.carrierMobileNetworkCode ?? "",
                event.is2GConnection ? "Yes" : "No",
                event.isSuspiciousCarrier ? "Yes" : "No"
            ].joined(separator: ",")
            
            csv += row + "\n"
        }
        
        return csv
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    EventHistoryView()
}
