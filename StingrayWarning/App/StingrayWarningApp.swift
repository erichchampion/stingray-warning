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
        // Set up background task manager
        backgroundTaskManager.setCellularMonitor(cellularMonitor)
        cellularMonitor.setBackgroundTaskManager(backgroundTaskManager)
        
        // Set up event store
        cellularMonitor.setEventStore(eventStore)
        
        // Request notification permissions
        notificationManager.requestPermissions()
        
        // Start monitoring if it was previously enabled (notifications are optional)
        if cellularMonitor.shouldAutoStartMonitoring() {
            cellularMonitor.startMonitoring()
        }
    }
}
