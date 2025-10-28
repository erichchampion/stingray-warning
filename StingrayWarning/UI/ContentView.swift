import SwiftUI

struct ContentView: View {
    @EnvironmentObject var cellularMonitor: CellularSecurityMonitor
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "shield.checkered")
                    Text("Dashboard")
                }
                .tag(0)
            
            EventHistoryView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("History")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(2)
            
            EducationView()
                .tabItem {
                    Image(systemName: "book")
                    Text("Learn")
                }
                .tag(3)
        }
        .accentColor(.blue)
    }
}

struct DashboardView: View {
    @EnvironmentObject var cellularMonitor: CellularSecurityMonitor
    @EnvironmentObject var notificationManager: NotificationManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Current Status Card
                    CurrentStatusCard()
                    
                    // Threat Level Indicator
                    ThreatLevelCard()
                    
                    // Quick Actions
                    QuickActionsCard()
                    
                    // Recent Events
                    RecentEventsCard()
                }
                .padding()
            }
            .navigationTitle("Stingray Warning")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        cellularMonitor.performSecurityCheck()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

struct CurrentStatusCard: View {
    @EnvironmentObject var cellularMonitor: CellularSecurityMonitor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .foregroundColor(.blue)
                Text("Current Status")
                    .font(.headline)
                Spacer()
                StatusIndicator(isActive: cellularMonitor.isMonitoring)
            }
            
            if let networkInfo = cellularMonitor.currentNetworkInfo {
                VStack(alignment: .leading, spacing: 8) {
                    StatusRow(label: "Technology", value: networkInfo.radioTechnology ?? "Unknown")
                    StatusRow(label: "Carrier", value: networkInfo.carrierName ?? "Unknown")
                    if let mcc = networkInfo.carrierMobileCountryCode,
                       let mnc = networkInfo.carrierMobileNetworkCode {
                        StatusRow(label: "MCC/MNC", value: "\(mcc)/\(mnc)")
                    }
                }
            } else {
                Text("No network information available")
                    .foregroundColor(.secondary)
            }
            
            if let lastCheck = cellularMonitor.lastCheckTime {
                Text("Last checked: \(lastCheck, style: .relative) ago")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ThreatLevelCard: View {
    @EnvironmentObject var cellularMonitor: CellularSecurityMonitor
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(threatColor)
                Text("Threat Level")
                    .font(.headline)
                Spacer()
            }
            
            HStack {
                Text(cellularMonitor.currentThreatLevel.description)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(threatColor)
                Spacer()
                ThreatLevelIcon(level: cellularMonitor.currentThreatLevel)
            }
            
            Text(threatDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var threatColor: Color {
        switch cellularMonitor.currentThreatLevel {
        case .none: return .green
        case .low: return .yellow
        case .medium: return .orange
        case .high: return .red
        case .critical: return .purple
        }
    }
    
    private var threatDescription: String {
        switch cellularMonitor.currentThreatLevel {
        case .none: return "No security threats detected"
        case .low: return "Minor security concerns detected"
        case .medium: return "Moderate security risk present"
        case .high: return "High security threat detected"
        case .critical: return "Critical security threat - immediate action recommended"
        }
    }
}

struct QuickActionsCard: View {
    @EnvironmentObject var cellularMonitor: CellularSecurityMonitor
    @EnvironmentObject var notificationManager: NotificationManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bolt")
                    .foregroundColor(.blue)
                Text("Quick Actions")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 12) {
                ActionButton(
                    title: cellularMonitor.isMonitoring ? "Stop" : "Start",
                    icon: cellularMonitor.isMonitoring ? "stop.circle" : "play.circle",
                    color: cellularMonitor.isMonitoring ? .red : .green
                ) {
                    if cellularMonitor.isMonitoring {
                        cellularMonitor.stopMonitoring()
                    } else {
                        cellularMonitor.startMonitoring()
                    }
                }
                
                ActionButton(
                    title: "Check Now",
                    icon: "arrow.clockwise",
                    color: .blue
                ) {
                    cellularMonitor.performSecurityCheck()
                }
                
                ActionButton(
                    title: "Settings",
                    icon: "gear",
                    color: .gray
                ) {
                    // Navigate to settings
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct RecentEventsCard: View {
    @EnvironmentObject var cellularMonitor: CellularSecurityMonitor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.blue)
                Text("Recent Activity")
                    .font(.headline)
                Spacer()
                Button("View All") {
                    // Navigate to history
                }
                .font(.caption)
            }
            
            if cellularMonitor.currentNetworkInfo != nil {
                EventRow(event: cellularMonitor.currentNetworkInfo!)
            } else {
                Text("No recent activity")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Supporting Views

struct StatusIndicator: View {
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isActive ? .green : .red)
                .frame(width: 8, height: 8)
            Text(isActive ? "Active" : "Inactive")
                .font(.caption)
                .foregroundColor(isActive ? .green : .red)
        }
    }
}

struct StatusRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

struct ThreatLevelIcon: View {
    let level: NetworkThreatLevel
    
    var body: some View {
        Image(systemName: iconName)
            .font(.title2)
            .foregroundColor(iconColor)
    }
    
    private var iconName: String {
        switch level {
        case .none: return "checkmark.shield"
        case .low: return "exclamationmark.triangle"
        case .medium: return "exclamationmark.triangle.fill"
        case .high: return "exclamationmark.octagon"
        case .critical: return "exclamationmark.octagon.fill"
        }
    }
    
    private var iconColor: Color {
        switch level {
        case .none: return .green
        case .low: return .yellow
        case .medium: return .orange
        case .high: return .red
        case .critical: return .purple
        }
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(color.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct EventRow: View {
    let event: NetworkEvent
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.description)
                    .font(.caption)
                    .fontWeight(.medium)
                Text(event.timestamp, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
            ThreatLevelBadge(level: event.threatLevel)
        }
        .padding(.vertical, 4)
    }
}

struct ThreatLevelBadge: View {
    let level: NetworkThreatLevel
    
    var body: some View {
        Text(level.rawValue.uppercased())
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(levelColor)
            .cornerRadius(4)
    }
    
    private var levelColor: Color {
        switch level {
        case .none: return .green
        case .low: return .yellow
        case .medium: return .orange
        case .high: return .red
        case .critical: return .purple
        }
    }
}

// MARK: - Placeholder Views

struct EventHistoryView: View {
    var body: some View {
        NavigationView {
            Text("Event History")
                .navigationTitle("History")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            Text("Settings")
                .navigationTitle("Settings")
        }
    }
}

struct EducationView: View {
    var body: some View {
        NavigationView {
            Text("Education")
                .navigationTitle("Learn")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(CellularSecurityMonitor())
        .environmentObject(NotificationManager())
}
