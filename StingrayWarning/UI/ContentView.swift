import SwiftUI

struct ContentView: View {
    @EnvironmentObject var cellularMonitor: CellularSecurityMonitor
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var backgroundTaskManager: BackgroundTaskManager
    @EnvironmentObject var eventStore: EventStore
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
        .onAppear {
            setupApp()
        }
    }
    
    private func setupApp() {
        // All setup is now handled at the app level in StingrayWarningApp.setupApp()
        // This method is kept for any future ContentView-specific setup
    }
}

struct DashboardView: View {
    @EnvironmentObject var cellularMonitor: CellularSecurityMonitor
    @EnvironmentObject var notificationManager: NotificationManager
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Fixed title section
                VStack(spacing: 12) {
                    Text("Dashboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Quick Actions Bar
                    HStack {
                        SharedUIComponents.ActionButton(
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
                        
                        Spacer()
                        
                        SharedUIComponents.ActionButton(
                            title: "Check Now",
                            icon: "arrow.clockwise",
                            color: .blue
                        ) {
                            cellularMonitor.performSecurityCheck()
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Main Content
                GeometryReader { geometry in
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            // Current Status Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Current Status")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                CurrentStatusCard()
                            }
                            
                            // Threat Level Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Threat Level")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                ThreatLevelCard()
                            }
                            
                            // Recent Activity Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recent Activity")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                RecentEventsCard()
                            }
                        }
                        .padding()
                        .frame(minHeight: geometry.size.height)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct CurrentStatusCard: View {
    @EnvironmentObject var cellularMonitor: CellularSecurityMonitor
    
    private func userFriendlyTechnologyName(_ technology: String?) -> String {
        guard let tech = technology else { return "Unknown" }
        
        switch tech {
        case "CTRadioAccessTechnologyGPRS", "CTRadioAccessTechnologyEdge":
            return "2G"
        case "CTRadioAccessTechnologyWCDMA", "CTRadioAccessTechnologyHSDPA", "CTRadioAccessTechnologyHSUPA", "CTRadioAccessTechnologyCDMA1x", "CTRadioAccessTechnologyCDMAEVDORev0", "CTRadioAccessTechnologyCDMAEVDORevA", "CTRadioAccessTechnologyCDMAEVDORevB", "CTRadioAccessTechnologyeHRPD":
            return "3G"
        case "CTRadioAccessTechnologyLTE":
            return "4G LTE"
        case "CTRadioAccessTechnologyNRNSA", "CTRadioAccessTechnologyNR":
            return "5G"
        default:
            return tech.replacingOccurrences(of: "CTRadioAccessTechnology", with: "")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .foregroundColor(.blue)
                Spacer()
                SharedUIComponents.StatusIndicator(isActive: cellularMonitor.isMonitoring)
            }
            
            if let networkInfo = cellularMonitor.currentNetworkInfo {
                VStack(alignment: .leading, spacing: 8) {
                    StatusRow(label: "Tech", value: userFriendlyTechnologyName(networkInfo.radioTechnology))
                    
                    // Full-width technical details row
                    HStack {
                        Text("Details")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(networkInfo.radioTechnology ?? "Unknown")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.trailing)
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


struct RecentEventsCard: View {
    @EnvironmentObject var cellularMonitor: CellularSecurityMonitor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.blue)
                Spacer()
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
            SharedUIComponents.ThreatLevelBadge(level: event.threatLevel)
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


#Preview {
    ContentView()
        .environmentObject(CellularSecurityMonitor())
        .environmentObject(NotificationManager())
}
