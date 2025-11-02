import SwiftUI

struct ContentView: View {
    @EnvironmentObject var cellularMonitor: CellularSecurityMonitor
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var backgroundTaskManager: BackgroundTaskManager
    @EnvironmentObject var eventStore: EventStore
    
    var body: some View {
        DashboardView()
    }
}

struct DashboardView: View {
    @EnvironmentObject var cellularMonitor: CellularSecurityMonitor
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var eventStore: EventStore
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Fixed title section
                VStack(spacing: 12) {
                    Text("Dashboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
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
                            
                            // Recent 2G Connections Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recent 2G Connections")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Recent2GConnectionsCard()
                            }
                            
                            // About Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("About")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                AboutCard()
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
                SharedUIComponents.StatusIndicator(isActive: cellularMonitor.isMonitoring, title: cellularMonitor.isMonitoring ? "Active" : "Inactive")
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



struct Recent2GConnectionsCard: View {
    @EnvironmentObject var cellularMonitor: CellularSecurityMonitor
    @EnvironmentObject var eventStore: EventStore
    
    // Get only 2G connection events, sorted by most recent
    private var twoGEvents: [NetworkEvent] {
        eventStore.events
            .filter { $0.is2GConnection }
            .sorted { $0.timestamp > $1.timestamp }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .foregroundColor(.orange)
                Spacer()
            }
            
            if twoGEvents.isEmpty {
                Text("No 2G connections detected")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(Array(twoGEvents.prefix(10))) { event in
                    TwoGEventRow(event: event)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct AboutCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("About this App")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("This application monitors your cellular network connection and notifies you when you are switched to a 2G network.")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Divider()
                    .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 6) {
                    if let supportURL = AppMetadata.supportURL {
                        Link(destination: supportURL) {
                            HStack {
                                Image(systemName: "questionmark.circle")
                                    .foregroundColor(.blue)
                                Text("Support")
                                    .foregroundColor(.blue)
                                Spacer()
                            }
                        }
                    }
                    
                    if let privacyURL = AppMetadata.privacyPolicyURL {
                        Link(destination: privacyURL) {
                            HStack {
                                Image(systemName: "hand.raised")
                                    .foregroundColor(.blue)
                                Text("Privacy Policy")
                                    .foregroundColor(.blue)
                                Spacer()
                            }
                        }
                    }
                    
                    if let contactURL = AppMetadata.contactURL {
                        Link(destination: contactURL) {
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(.blue)
                                Text("Contact")
                                    .foregroundColor(.blue)
                                Spacer()
                            }
                        }
                    }
                }
                .font(.subheadline)
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

struct IssueLevelIcon: View {
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

struct TwoGEventRow: View {
    let event: NetworkEvent
    
    private func userFriendlyTechnologyName(_ technology: String?) -> String {
        guard let tech = technology else { return "Unknown" }
        
        switch tech {
        case "CTRadioAccessTechnologyGSM":
            return "GSM"
        case "CTRadioAccessTechnologyGPRS":
            return "GPRS"
        case "CTRadioAccessTechnologyEdge":
            return "EDGE"
        default:
            return tech.replacingOccurrences(of: "CTRadioAccessTechnology", with: "")
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(userFriendlyTechnologyName(event.radioTechnology))
                    .font(.caption)
                    .fontWeight(.medium)
                Text(event.radioTechnology ?? "Unknown")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(event.timestamp, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("2G")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.orange)
                .cornerRadius(4)
        }
        .padding(.vertical, 4)
    }
}

struct IssueLevelBadge: View {
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
