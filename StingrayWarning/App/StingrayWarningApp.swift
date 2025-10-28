import SwiftUI

@main
struct StingrayWarningApp: App {
    @StateObject private var cellularMonitor = CellularSecurityMonitor()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var backgroundTaskManager = BackgroundTaskManager()
    @StateObject private var eventStore = EventStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cellularMonitor)
                .environmentObject(notificationManager)
                .environmentObject(backgroundTaskManager)
                .environmentObject(eventStore)
                .onAppear {
                    setupApp()
                }
        }
    }
    
    private func setupApp() {
        print("🔧 App setup starting...")
        
        // Set up background task manager
        backgroundTaskManager.setCellularMonitor(cellularMonitor)
        cellularMonitor.setBackgroundTaskManager(backgroundTaskManager)
        print("✅ Background task manager connected")
        
        // Set up event store
        cellularMonitor.setEventStore(eventStore)
        print("✅ Event store connected")
        
        // Request notification permissions
        notificationManager.requestPermissions()
        print("📱 Notification permissions requested")
        
        // Check auto-start conditions
        let shouldAutoStart = cellularMonitor.shouldAutoStartMonitoring()
        let hasPermissions = notificationManager.hasPermissions
        print("🔍 Auto-start check: shouldAutoStart=\(shouldAutoStart), hasPermissions=\(hasPermissions)")
        
        // Start monitoring if it was previously enabled (notifications are optional)
        if shouldAutoStart {
            print("🚀 Starting monitoring automatically...")
            cellularMonitor.startMonitoring()
        } else {
            print("⏸️ Auto-start conditions not met, monitoring not started")
        }
        
        // Note: Notifications are optional - monitoring works without them
        if !hasPermissions {
            print("ℹ️ Notification permissions not granted - monitoring will work without notifications")
        }
    }
}
