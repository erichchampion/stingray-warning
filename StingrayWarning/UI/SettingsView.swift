import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var cellularMonitor: CellularSecurityMonitor
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var backgroundTaskManager: BackgroundTaskManager
    @StateObject private var eventStore = EventStore()
    
    @AppStorage("monitoringEnabled") private var monitoringEnabled = true
    @AppStorage("notificationEnabled") private var notificationEnabled = true
    @AppStorage("backgroundMonitoringEnabled") private var backgroundMonitoringEnabled = true
    @AppStorage("sensitivityLevel") private var sensitivityLevel = 2.0 // 1-5 scale
    @AppStorage("expectedCarrierName") private var expectedCarrierName = ""
    @AppStorage("expectedMCC") private var expectedMCC = ""
    @AppStorage("expectedMNC") private var expectedMNC = ""
    @AppStorage("batteryOptimizationEnabled") private var batteryOptimizationEnabled = true
    @AppStorage("dataRetentionDays") private var dataRetentionDays = 7.0
    
    var body: some View {
        NavigationStack {
            List {
                // Monitoring Section
                Section("Monitoring") {
                    Toggle("Enable Monitoring", isOn: $monitoringEnabled)
                        .onChange(of: monitoringEnabled) { enabled in
                            if enabled {
                                cellularMonitor.startMonitoring()
                            } else {
                                cellularMonitor.stopMonitoring()
                            }
                        }
                    
                    Toggle("Background Monitoring", isOn: $backgroundMonitoringEnabled)
                        .onChange(of: backgroundMonitoringEnabled) { enabled in
                            if enabled {
                                backgroundTaskManager.startBackgroundMonitoring()
                            } else {
                                backgroundTaskManager.stopBackgroundMonitoring()
                            }
                        }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sensitivity Level")
                            .font(.headline)
                        HStack {
                            Text("Conservative")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Slider(value: $sensitivityLevel, in: 1...5, step: 1)
                            Text("Aggressive")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Text(sensitivityDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                // Notifications Section
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $notificationEnabled)
                        .onChange(of: notificationEnabled) { enabled in
                            if enabled {
                                notificationManager.requestPermissions()
                            }
                        }
                    
                    if !notificationManager.hasPermissions {
                        Button("Grant Notification Permissions") {
                            notificationManager.requestPermissions()
                        }
                        .foregroundColor(.blue)
                    }
                    
                    NavigationLink("Notification Settings") {
                        NotificationSettingsView()
                    }
                }
                
                // Expected Carrier Section
                Section("Expected Carrier") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("⚠️ Carrier information is not available in iOS 16+")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Text("Apple has deprecated carrier information APIs in iOS 16+. The app now focuses on radio technology detection (2G/3G/4G/5G) which is still functional for security monitoring.")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Text("The app will still detect:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("• 2G network connections (high risk)")
                            Text("• Rapid technology changes")
                            Text("• Network downgrades")
                            Text("• Unusual connection patterns")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
                
                // Battery & Performance Section
                Section("Battery & Performance") {
                    Toggle("Battery Optimization", isOn: $batteryOptimizationEnabled)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Data Retention")
                            .font(.headline)
                        HStack {
                            Text("1 day")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Slider(value: $dataRetentionDays, in: 1...30, step: 1)
                            Text("30 days")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Text("Keep data for \(Int(dataRetentionDays)) days")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                // Background Tasks Section
                Section("Background Tasks") {
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(backgroundTaskManager.isBackgroundTaskRegistered ? "Registered" : "Not Registered")
                            .foregroundColor(backgroundTaskManager.isBackgroundTaskRegistered ? .green : .red)
                    }
                    
                    HStack {
                        Text("Background Refresh")
                        Spacer()
                        Text(backgroundTaskManager.backgroundRefreshStatusDescription)
                            .foregroundColor(backgroundTaskManager.isBackgroundAppRefreshEnabled ? .green : .red)
                    }
                    
                    if let lastExecution = backgroundTaskManager.lastBackgroundExecution {
                        HStack {
                            Text("Last Execution")
                            Spacer()
                            Text(lastExecution, style: .relative)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button("Test Background Task") {
                        backgroundTaskManager.requestBackgroundProcessingTime { success in
                            print("Background task test: \(success)")
                        }
                    }
                }
                
                // Data Management Section
                Section("Data Management") {
                    NavigationLink("Event History") {
                        EventHistoryView()
                    }
                    
                    Button("Export Data") {
                        exportData()
                    }
                    
                    Button("Clear All Data", role: .destructive) {
                        clearAllData()
                    }
                }
                
                // About Section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    NavigationLink("Privacy Policy") {
                        PrivacyPolicyView()
                    }
                    
                    NavigationLink("Terms of Service") {
                        TermsOfServiceView()
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                setupEventStore()
            }
        }
    }
    
    private var sensitivityDescription: String {
        switch Int(sensitivityLevel) {
        case 1: return "Only alerts for critical threats"
        case 2: return "Alerts for high and critical threats"
        case 3: return "Alerts for medium, high, and critical threats"
        case 4: return "Alerts for low, medium, high, and critical threats"
        case 5: return "Alerts for all detected threats"
        default: return "Standard sensitivity"
        }
    }
    
    private func setupEventStore() {
        // Set up event store reference
    }
    
    private func exportData() {
        // Implement data export functionality
        if let eventsJSON = eventStore.exportEventsToJSON() {
            // Present share sheet or save to files
            print("Events exported: \(eventsJSON)")
        }
    }
    
    private func clearAllData() {
        eventStore.clearAllData()
    }
}

// MARK: - Supporting Views

struct NotificationSettingsView: View {
    @AppStorage("lowThreatNotifications") private var lowThreatNotifications = false
    @AppStorage("mediumThreatNotifications") private var mediumThreatNotifications = true
    @AppStorage("highThreatNotifications") private var highThreatNotifications = true
    @AppStorage("criticalThreatNotifications") private var criticalThreatNotifications = true
    @AppStorage("notificationSound") private var notificationSound = true
    @AppStorage("notificationBadge") private var notificationBadge = true
    
    var body: some View {
        List {
            Section("Threat Level Notifications") {
                Toggle("Low Risk", isOn: $lowThreatNotifications)
                Toggle("Medium Risk", isOn: $mediumThreatNotifications)
                Toggle("High Risk", isOn: $highThreatNotifications)
                Toggle("Critical Risk", isOn: $criticalThreatNotifications)
            }
            
            Section("Notification Style") {
                Toggle("Sound", isOn: $notificationSound)
                Toggle("Badge", isOn: $notificationBadge)
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Last updated: \(Date(), style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Group {
                    Text("Data Collection")
                        .font(.headline)
                    Text("Stingray Warning does not collect, store, or transmit any personal information. All analysis is performed locally on your device.")
                    
                    Text("Network Information")
                        .font(.headline)
                    Text("The app monitors cellular network metadata (radio technology, carrier information) for security analysis. This information is processed locally and not shared.")
                    
                    Text("Location Data")
                        .font(.headline)
                    Text("Location data is used only to provide context for security alerts and is not stored or transmitted.")
                    
                    Text("Third-Party Services")
                        .font(.headline)
                    Text("This app does not use third-party analytics or tracking services.")
                }
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Terms of Service")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Last updated: \(Date(), style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Group {
                    Text("Disclaimer")
                        .font(.headline)
                    Text("This app is designed as a security awareness tool with significant limitations. It should not be solely relied upon for protection against sophisticated cellular attacks.")
                    
                    Text("Limitations")
                        .font(.headline)
                    Text("Detection capabilities are limited compared to dedicated SDR hardware. The app provides general security awareness and should be used in conjunction with other security measures.")
                    
                    Text("User Responsibility")
                        .font(.headline)
                    Text("Users are responsible for their own security decisions and should not rely solely on this app for protection.")
                }
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
        .environmentObject(CellularSecurityMonitor())
        .environmentObject(NotificationManager())
        .environmentObject(BackgroundTaskManager())
}
