import SwiftUI

@main
struct StingrayWarningApp: App {
    @StateObject private var cellularMonitor = CellularSecurityMonitor()
    @StateObject private var notificationManager = NotificationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cellularMonitor)
                .environmentObject(notificationManager)
                .onAppear {
                    setupApp()
                }
        }
    }
    
    private func setupApp() {
        // Request notification permissions
        notificationManager.requestPermissions()
        
        // Start monitoring if user has granted permissions
        if notificationManager.hasPermissions {
            cellularMonitor.startMonitoring()
        }
    }
}
