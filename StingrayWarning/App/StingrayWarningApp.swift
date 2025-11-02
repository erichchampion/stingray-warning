import SwiftUI

@main
struct TwoGApp: App {
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
        backgroundTaskManager.registerBackgroundTasks() // Register background tasks during app launch
        cellularMonitor.setBackgroundTaskManager(backgroundTaskManager)
        
        // Set up event store
        cellularMonitor.setEventStore(eventStore)
        
        // Request notification permissions
        notificationManager.requestPermissions()
        
        // Automatically start monitoring on startup
        cellularMonitor.startMonitoring()
        
        // Start background monitoring if permission has been granted
        if backgroundTaskManager.isBackgroundAppRefreshEnabled {
            backgroundTaskManager.startBackgroundMonitoring()
        }
    }
}
