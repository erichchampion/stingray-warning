import SwiftUI

struct EventHistoryView: View {
    @StateObject private var eventStore = EventStore()
    @State private var selectedFilter: ThreatLevelFilter = .all
    @State private var selectedTimeRange: TimeRange = .day
    @State private var showingClearAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Clear button (centered under title)
                VStack(spacing: 16) {
                    ActionButton(
                        title: "Clear",
                        icon: "trash",
                        color: .red
                    ) {
                        showingClearAlert = true
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
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
                
                // Main Content
                GeometryReader { geometry in
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            // Statistics Summary
                            StatisticsSummaryView(
                                events: filteredEvents,
                                timeRange: selectedTimeRange
                            )
                            
                            // Events List
                            if filteredEvents.isEmpty {
                                SharedUIComponents.EmptyStateView()
                            } else {
                                LazyVStack(spacing: 8) {
                                    ForEach(filteredEvents) { event in
                                        EventRowView(event: event)
                                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                                Button("Delete", role: .destructive) {
                                                    deleteEvent(event)
                                                }
                                            }
                                    }
                                }
                            }
                        }
                        .padding()
                        .frame(minHeight: geometry.size.height)
                    }
                }
            }
            .navigationTitle("Event History")
            .navigationBarTitleDisplayMode(.large)
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
        if selectedFilter == .threatsOnly {
            events = events.filter { $0.threatLevel != .none }
        }
        
        // Filter by time range
        let now = Date()
        let startDate: Date
        
        switch selectedTimeRange {
        case .hour:
            startDate = now.addingTimeInterval(-AppConstants.TimeIntervals.hour)
        case .day:
            startDate = now.addingTimeInterval(-AppConstants.TimeIntervals.day)
        case .week:
            startDate = now.addingTimeInterval(-AppConstants.TimeIntervals.week)
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
    case threatsOnly
    
    var title: String {
        switch self {
        case .all: return "All"
        case .threatsOnly: return "Threats Only"
        }
    }
}

enum TimeRange: CaseIterable {
    case hour
    case day
    case week
    case all
    
    var title: String {
        switch self {
        case .hour: return "1 Hour"
        case .day: return "1 Day"
        case .week: return "1 Week"
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
                                        SharedUIComponents.ThreatLevelBadge(level: event.threatLevel)
                Spacer()
                Text(event.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(event.description)
                .font(.body)
            
            Text(event.summary)
                .font(.caption)
                .foregroundColor(.secondary)
            
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

#Preview {
    EventHistoryView()
}
