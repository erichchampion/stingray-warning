import XCTest
import SwiftUI
@testable import Stingray_Warning

/// UI Tests for taking screenshots of each view in the Stingray Warning app
class StingrayWarningUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Screenshot Helper Methods
    
    /// Takes a screenshot and saves it with a descriptive name
    private func takeScreenshot(named name: String, description: String = "") {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        
        // Add description if provided
        if !description.isEmpty {
            attachment.userInfo = ["Description": description]
        }
        
        add(attachment)
        
        // Also save to Documents directory for easy access
        saveScreenshotToDocuments(screenshot: screenshot, name: name)
    }
    
    /// Saves screenshot to Documents directory
    private func saveScreenshotToDocuments(screenshot: XCUIScreenshot, name: String) {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let screenshotsDirectory = documentsPath.appendingPathComponent("Screenshots")
        
        // Create screenshots directory if it doesn't exist
        try? FileManager.default.createDirectory(at: screenshotsDirectory, withIntermediateDirectories: true)
        
        let screenshotURL = screenshotsDirectory.appendingPathComponent("\(name).png")
        
        do {
            try screenshot.pngRepresentation.write(to: screenshotURL)
            print("Screenshot saved to: \(screenshotURL.path)")
        } catch {
            print("Failed to save screenshot: \(error)")
        }
    }
    
    /// Waits for view to be fully loaded before taking screenshot
    private func waitForViewToLoad(timeout: TimeInterval = 5.0) {
        // Wait for the Dashboard tab to be visible (this indicates the app is loaded)
        let dashboardTab = app.buttons["Dashboard"]
        XCTAssertTrue(dashboardTab.waitForExistence(timeout: timeout))
    }
    
    /// Navigates to a specific tab
    private func navigateToTab(_ tabName: String) {
        let tabButton = app.buttons[tabName]
        XCTAssertTrue(tabButton.exists)
        tabButton.tap()
        
        // Wait for tab to load
        Thread.sleep(forTimeInterval: 1.0)
    }
    
    // MARK: - Main App Screenshots
    
    func testTakeScreenshotOfLaunchScreen() throws {
        // Take screenshot immediately after launch
        takeScreenshot(named: "01_LaunchScreen", description: "App launch screen")
    }
    
    func testTakeScreenshotOfDashboardTab() throws {
        // Navigate to Dashboard tab (should be default)
        waitForViewToLoad()
        
        // Take screenshot of Dashboard in initial state
        takeScreenshot(named: "02_DashboardTab_Initial", description: "Main dashboard with monitoring controls - initial state")
        
        // Test Start/Stop button states
        let startStopButton = app.buttons["Start Monitoring"]
        if startStopButton.exists {
            // Screenshot before starting monitoring
            takeScreenshot(named: "03_DashboardTab_BeforeStart", description: "Dashboard before starting monitoring")
            
            // Start monitoring
            startStopButton.tap()
            Thread.sleep(forTimeInterval: 2.0) // Wait for monitoring to start
            takeScreenshot(named: "04_DashboardTab_MonitoringActive", description: "Dashboard with monitoring active")
            
            // Take additional screenshot showing active state details
            takeScreenshot(named: "05_DashboardTab_MonitoringActive_Detailed", description: "Dashboard with monitoring active - detailed view")
            
            // Stop monitoring
            let stopButton = app.buttons["Stop Monitoring"]
            if stopButton.exists {
                stopButton.tap()
                Thread.sleep(forTimeInterval: 2.0) // Wait for monitoring to stop
                takeScreenshot(named: "06_DashboardTab_MonitoringStopped", description: "Dashboard with monitoring stopped")
                
                // Take additional screenshot showing stopped state details
                takeScreenshot(named: "07_DashboardTab_MonitoringStopped_Detailed", description: "Dashboard with monitoring stopped - detailed view")
            }
        } else {
            // If Start Monitoring button doesn't exist, look for alternative button names
            let alternativeStartButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'start' OR label CONTAINS[c] 'monitor'"))
            if alternativeStartButton.count > 0 {
                let startButton = alternativeStartButton.element(boundBy: 0)
                startButton.tap()
                Thread.sleep(forTimeInterval: 2.0)
                takeScreenshot(named: "04_DashboardTab_MonitoringActive_Alternative", description: "Dashboard with monitoring active - alternative button")
                
                // Look for stop button
                let alternativeStopButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'stop' OR label CONTAINS[c] 'pause'"))
                if alternativeStopButton.count > 0 {
                    let stopButton = alternativeStopButton.element(boundBy: 0)
                    stopButton.tap()
                    Thread.sleep(forTimeInterval: 2.0)
                    takeScreenshot(named: "06_DashboardTab_MonitoringStopped_Alternative", description: "Dashboard with monitoring stopped - alternative button")
                }
            }
        }
        
        // Test status indicator states
        let statusIndicator = app.otherElements.matching(identifier: "StatusIndicator")
        if statusIndicator.count > 0 {
            takeScreenshot(named: "08_DashboardTab_StatusIndicator", description: "Dashboard status indicator")
        }
        
        // Test issue level display
        let issueLevelBadge = app.otherElements.matching(identifier: "IssueLevelBadge")
        if issueLevelBadge.count > 0 {
            takeScreenshot(named: "09_DashboardTab_IssueLevelBadge", description: "Dashboard issue level badge")
        }
        
        // Test action buttons
        let actionButtons = app.buttons.matching(identifier: "ActionButton")
        if actionButtons.count > 0 {
            takeScreenshot(named: "10_DashboardTab_ActionButtons", description: "Dashboard action buttons")
        }
    }
    
    func testTakeScreenshotOfMonitoringStates() throws {
        // Navigate to Dashboard tab
        navigateToTab("Dashboard")
        waitForViewToLoad()
        
        // Test monitoring states comprehensively
        
        // 1. Initial state (monitoring stopped)
        takeScreenshot(named: "Monitoring_01_InitialState", description: "Dashboard initial state - monitoring stopped")
        
        // 2. Before starting monitoring
        takeScreenshot(named: "Monitoring_02_BeforeStart", description: "Dashboard before starting monitoring")
        
        // 3. Start monitoring
        let startButton = app.buttons["Start Monitoring"]
        if startButton.exists {
            startButton.tap()
            Thread.sleep(forTimeInterval: 3.0) // Wait for monitoring to fully start
            
            // 4. Monitoring active - main view
            takeScreenshot(named: "Monitoring_03_Active_Main", description: "Dashboard with monitoring active - main view")
            
            // 5. Monitoring active - status details
            takeScreenshot(named: "Monitoring_04_Active_Status", description: "Dashboard with monitoring active - status details")
            
            // 6. Monitoring active - issue level
            takeScreenshot(named: "Monitoring_05_Active_IssueLevel", description: "Dashboard with monitoring active - issue level display")
            
            // 7. Stop monitoring
            let stopButton = app.buttons["Stop Monitoring"]
            if stopButton.exists {
                stopButton.tap()
                Thread.sleep(forTimeInterval: 3.0) // Wait for monitoring to fully stop
                
                // 8. Monitoring stopped - main view
                takeScreenshot(named: "Monitoring_06_Stopped_Main", description: "Dashboard with monitoring stopped - main view")
                
                // 9. Monitoring stopped - status details
                takeScreenshot(named: "Monitoring_07_Stopped_Status", description: "Dashboard with monitoring stopped - status details")
                
                // 10. Monitoring stopped - issue level
                takeScreenshot(named: "Monitoring_08_Stopped_IssueLevel", description: "Dashboard with monitoring stopped - issue level display")
            }
        }
        
        // Test button state changes
        let allButtons = app.buttons
        for i in 0..<allButtons.count {
            let button = allButtons.element(boundBy: i)
            if button.label.contains("Monitoring") || button.label.contains("Start") || button.label.contains("Stop") {
                takeScreenshot(named: "Monitoring_Button_\(button.label.replacingOccurrences(of: " ", with: "_"))", description: "Monitoring button: \(button.label)")
            }
        }
        
        // Test status indicators
        let statusElements = app.otherElements.matching(identifier: "StatusIndicator")
        for i in 0..<statusElements.count {
            let _ = statusElements.element(boundBy: i)
            takeScreenshot(named: "Monitoring_StatusIndicator_\(i)", description: "Status indicator \(i)")
        }
        
        // Test issue level badges
        let issueBadges = app.otherElements.matching(identifier: "IssueLevelBadge")
        for i in 0..<issueBadges.count {
            let _ = issueBadges.element(boundBy: i)
            takeScreenshot(named: "Monitoring_IssueBadge_\(i)", description: "Issue level badge \(i)")
        }
    }
    
    func testTakeScreenshotOfEventHistoryTab() throws {
        // Navigate to Event History tab
        navigateToTab("History")
        
        // Take screenshot of empty state
        takeScreenshot(named: "05_EventHistoryTab_Empty", description: "Event History tab with no events")
        
        // Test filter buttons
        let allButton = app.buttons["All"]
        let issuesOnlyButton = app.buttons["Issues Only"]
        
        if allButton.exists {
            allButton.tap()
            Thread.sleep(forTimeInterval: 0.5)
            takeScreenshot(named: "06_EventHistoryTab_AllFilter", description: "Event History with All filter selected")
        }
        
        if issuesOnlyButton.exists {
            issuesOnlyButton.tap()
            Thread.sleep(forTimeInterval: 0.5)
            takeScreenshot(named: "07_EventHistoryTab_IssuesOnlyFilter", description: "Event History with Issues Only filter selected")
        }
        
        // Test time range filters
        let allTimeButton = app.buttons["All Time"]
        let oneWeekButton = app.buttons["1 Week"]
        let oneDayButton = app.buttons["1 Day"]
        
        if allTimeButton.exists {
            allTimeButton.tap()
            Thread.sleep(forTimeInterval: 0.5)
            takeScreenshot(named: "08_EventHistoryTab_AllTimeFilter", description: "Event History with All Time filter selected")
        }
        
        if oneWeekButton.exists {
            oneWeekButton.tap()
            Thread.sleep(forTimeInterval: 0.5)
            takeScreenshot(named: "09_EventHistoryTab_OneWeekFilter", description: "Event History with 1 Week filter selected")
        }
        
        if oneDayButton.exists {
            oneDayButton.tap()
            Thread.sleep(forTimeInterval: 0.5)
            takeScreenshot(named: "10_EventHistoryTab_OneDayFilter", description: "Event History with 1 Day filter selected")
        }
        
        // Test Clear button
        let clearButton = app.buttons["Clear"]
        if clearButton.exists {
            clearButton.tap()
            Thread.sleep(forTimeInterval: 0.5)
            takeScreenshot(named: "11_EventHistoryTab_ClearConfirmation", description: "Event History Clear confirmation dialog")
        }
    }
    
    func testTakeScreenshotOfLearnTab() throws {
        // Navigate to Learn tab
        navigateToTab("Learn")
        
        // Take screenshot of main Learn view (now simplified with network monitoring content)
        takeScreenshot(named: "12_LearnTab_Main", description: "Learn tab main view - Network Monitoring")
        
        // Scroll through the content to see all sections
        app.swipeUp()
        Thread.sleep(forTimeInterval: 0.5)
        takeScreenshot(named: "13_LearnTab_Scrolled", description: "Learn tab scrolled to show all content")
        
        // Scroll back
        app.swipeDown()
        Thread.sleep(forTimeInterval: 0.5)
    }
    
    func testTakeScreenshotOfSettingsTab() throws {
        // Navigate to Settings tab
        navigateToTab("Settings")
        
        // Take screenshot of Settings view
        takeScreenshot(named: "17_SettingsTab_Main", description: "Settings tab main view")
        
        // Test monitoring toggle
        let monitoringToggle = app.switches["Monitoring Enabled"]
        if monitoringToggle.exists {
            takeScreenshot(named: "18_SettingsTab_MonitoringToggle", description: "Settings tab with monitoring toggle")
            
            // Toggle monitoring
            monitoringToggle.tap()
            Thread.sleep(forTimeInterval: 0.5)
            takeScreenshot(named: "19_SettingsTab_MonitoringToggle_Changed", description: "Settings tab with monitoring toggle changed")
        }
        
        // Test notifications toggle
        let notificationsToggle = app.switches["Notifications Enabled"]
        if notificationsToggle.exists {
            takeScreenshot(named: "20_SettingsTab_NotificationsToggle", description: "Settings tab with notifications toggle")
            
            // Toggle notifications
            notificationsToggle.tap()
            Thread.sleep(forTimeInterval: 0.5)
            takeScreenshot(named: "21_SettingsTab_NotificationsToggle_Changed", description: "Settings tab with notifications toggle changed")
        }
        
        // Test background refresh toggle
        let backgroundRefreshToggle = app.switches["Background Refresh Enabled"]
        if backgroundRefreshToggle.exists {
            takeScreenshot(named: "22_SettingsTab_BackgroundRefreshToggle", description: "Settings tab with background refresh toggle")
            
            // Toggle background refresh
            backgroundRefreshToggle.tap()
            Thread.sleep(forTimeInterval: 0.5)
            takeScreenshot(named: "23_SettingsTab_BackgroundRefreshToggle_Changed", description: "Settings tab with background refresh toggle changed")
        }
        
        // Test external links
        let privacyPolicyButton = app.buttons["Privacy Policy"]
        if privacyPolicyButton.exists {
            takeScreenshot(named: "24_SettingsTab_PrivacyPolicyButton", description: "Settings tab with Privacy Policy button")
        }
        
        let contactSupportButton = app.buttons["Contact Support"]
        if contactSupportButton.exists {
            takeScreenshot(named: "25_SettingsTab_ContactSupportButton", description: "Settings tab with Contact Support button")
        }
        
        let visitWebsiteButton = app.buttons["Visit Website"]
        if visitWebsiteButton.exists {
            takeScreenshot(named: "26_SettingsTab_VisitWebsiteButton", description: "Settings tab with Visit Website button")
        }
        
        // Test app version display
        let versionText = app.staticTexts.matching(identifier: "App Version")
        if versionText.count > 0 {
            takeScreenshot(named: "27_SettingsTab_AppVersion", description: "Settings tab with app version display")
        }
    }
    
    // MARK: - Detailed UI Component Screenshots
    
    func testTakeScreenshotOfIssueLevelBadges() throws {
        // Navigate to Event History tab
        navigateToTab("History")
        
        // Look for issue level badges
        let issueBadges = app.otherElements.matching(identifier: "IssueLevelBadge")
        if issueBadges.count > 0 {
            takeScreenshot(named: "28_IssueLevelBadges", description: "Issue level badges in Event History")
        }
    }
    
    func testTakeScreenshotOfActionButtons() throws {
        // Navigate to Dashboard tab
        navigateToTab("Dashboard")
        
        // Look for action buttons
        let actionButtons = app.buttons.matching(identifier: "ActionButton")
        if actionButtons.count > 0 {
            takeScreenshot(named: "29_ActionButtons", description: "Action buttons on Dashboard")
        }
    }
    
    func testTakeScreenshotOfStatusIndicators() throws {
        // Navigate to Dashboard tab
        navigateToTab("Dashboard")
        
        // Look for status indicators
        let statusIndicators = app.otherElements.matching(identifier: "StatusIndicator")
        if statusIndicators.count > 0 {
            takeScreenshot(named: "30_StatusIndicators", description: "Status indicators on Dashboard")
        }
    }
    
    func testTakeScreenshotOfEducationCards() throws {
        // Navigate to Learn tab
        navigateToTab("Learn")
        
        // Look for education cards
        let educationCards = app.otherElements.matching(identifier: "EducationCard")
        if educationCards.count > 0 {
            takeScreenshot(named: "31_EducationCards", description: "Education cards in Learn tab")
        }
    }
    
    func testTakeScreenshotOfWarningCards() throws {
        // Navigate to Learn tab
        navigateToTab("Learn")
        
        // Look for warning cards
        let warningCards = app.otherElements.matching(identifier: "WarningCard")
        if warningCards.count > 0 {
            takeScreenshot(named: "32_WarningCards", description: "Warning cards in Learn tab")
        }
    }
    
    func testTakeScreenshotOfSuccessCards() throws {
        // Navigate to Learn tab
        navigateToTab("Learn")
        
        // Look for success cards
        let successCards = app.otherElements.matching(identifier: "SuccessCard")
        if successCards.count > 0 {
            takeScreenshot(named: "33_SuccessCards", description: "Success cards in Learn tab")
        }
    }
    
    func testTakeScreenshotOfEmptyStateView() throws {
        // Navigate to Event History tab
        navigateToTab("History")
        
        // Look for empty state view
        let emptyStateView = app.otherElements.matching(identifier: "EmptyStateView")
        if emptyStateView.count > 0 {
            takeScreenshot(named: "34_EmptyStateView", description: "Empty state view in Event History")
        }
    }
    
    // MARK: - Different Device Orientations
    
    func testTakeScreenshotInPortraitOrientation() throws {
        // Ensure portrait orientation
        XCUIDevice.shared.orientation = .portrait
        Thread.sleep(forTimeInterval: 1.0)
        
        // Take screenshot of Dashboard in portrait
        navigateToTab("Dashboard")
        takeScreenshot(named: "35_Dashboard_Portrait", description: "Dashboard in portrait orientation")
        
        // Take screenshot of Event History in portrait
        navigateToTab("History")
        takeScreenshot(named: "36_EventHistory_Portrait", description: "Event History in portrait orientation")
        
        // Take screenshot of Learn in portrait
        navigateToTab("Learn")
        takeScreenshot(named: "37_Learn_Portrait", description: "Learn tab in portrait orientation")
        
        // Take screenshot of Settings in portrait
        navigateToTab("Settings")
        takeScreenshot(named: "38_Settings_Portrait", description: "Settings tab in portrait orientation")
    }
    
    func testTakeScreenshotInLandscapeOrientation() throws {
        // Ensure landscape orientation
        XCUIDevice.shared.orientation = .landscapeLeft
        Thread.sleep(forTimeInterval: 1.0)
        
        // Take screenshot of Dashboard in landscape
        navigateToTab("Dashboard")
        takeScreenshot(named: "39_Dashboard_Landscape", description: "Dashboard in landscape orientation")
        
        // Take screenshot of Event History in landscape
        navigateToTab("History")
        takeScreenshot(named: "40_EventHistory_Landscape", description: "Event History in landscape orientation")
        
        // Take screenshot of Learn in landscape
        navigateToTab("Learn")
        takeScreenshot(named: "41_Learn_Landscape", description: "Learn tab in landscape orientation")
        
        // Take screenshot of Settings in landscape
        navigateToTab("Settings")
        takeScreenshot(named: "42_Settings_Landscape", description: "Settings tab in landscape orientation")
    }
    
    // MARK: - Different Device Sizes (if available)
    
    func testTakeScreenshotOnDifferentDeviceSizes() throws {
        // This test will work on different device sizes when run on different simulators
        let deviceSize = UIScreen.main.bounds.size
        let sizeDescription = "\(Int(deviceSize.width))x\(Int(deviceSize.height))"
        
        // Take screenshot of Dashboard
        navigateToTab("Dashboard")
        takeScreenshot(named: "43_Dashboard_\(sizeDescription)", description: "Dashboard on \(sizeDescription) device")
        
        // Take screenshot of Event History
        navigateToTab("History")
        takeScreenshot(named: "44_EventHistory_\(sizeDescription)", description: "Event History on \(sizeDescription) device")
        
        // Take screenshot of Learn
        navigateToTab("Learn")
        takeScreenshot(named: "45_Learn_\(sizeDescription)", description: "Learn tab on \(sizeDescription) device")
        
        // Take screenshot of Settings
        navigateToTab("Settings")
        takeScreenshot(named: "46_Settings_\(sizeDescription)", description: "Settings tab on \(sizeDescription) device")
    }
    
    // MARK: - Accessibility Screenshots
    
    func testTakeScreenshotWithAccessibilityFeatures() throws {
        // Enable accessibility features if available
        // Note: This would need to be configured in the test target
        
        // Take screenshot of Dashboard with accessibility
        navigateToTab("Dashboard")
        takeScreenshot(named: "47_Dashboard_Accessibility", description: "Dashboard with accessibility features")
        
        // Take screenshot of Event History with accessibility
        navigateToTab("History")
        takeScreenshot(named: "48_EventHistory_Accessibility", description: "Event History with accessibility features")
        
        // Take screenshot of Learn with accessibility
        navigateToTab("Learn")
        takeScreenshot(named: "49_Learn_Accessibility", description: "Learn tab with accessibility features")
        
        // Take screenshot of Settings with accessibility
        navigateToTab("Settings")
        takeScreenshot(named: "50_Settings_Accessibility", description: "Settings tab with accessibility features")
    }
    
    // MARK: - Performance Screenshots
    
    func testTakeScreenshotWithPerformanceMetrics() throws {
        // Start performance measurement
        let measureOptions = XCTMeasureOptions()
        measureOptions.iterationCount = 1
        
        measure(metrics: [XCTApplicationLaunchMetric()], options: measureOptions) {
            // Take screenshot during performance measurement
            navigateToTab("Dashboard")
            takeScreenshot(named: "51_Dashboard_Performance", description: "Dashboard during performance measurement")
        }
    }
    
    // MARK: - Error State Screenshots
    
    func testTakeScreenshotOfErrorStates() throws {
        // Navigate to Dashboard
        navigateToTab("Dashboard")
        
        // Try to trigger error states (if possible)
        // This would depend on the app's error handling implementation
        
        // Take screenshot of normal state
        takeScreenshot(named: "52_Dashboard_NormalState", description: "Dashboard in normal state")
        
        // If there are ways to trigger error states, add them here
        // For example, disabling network, location services, etc.
    }
    
    // MARK: - Complete App Flow Screenshots
    
    func testTakeScreenshotOfCompleteAppFlow() throws {
        // Complete app flow from launch to all tabs
        
        // 1. Launch screen
        takeScreenshot(named: "53_Flow_Launch", description: "App launch")
        
        // 2. Dashboard
        navigateToTab("Dashboard")
        takeScreenshot(named: "54_Flow_Dashboard", description: "Dashboard tab")
        
        // 3. Event History
        navigateToTab("History")
        takeScreenshot(named: "55_Flow_EventHistory", description: "Event History tab")
        
        // 4. Learn
        navigateToTab("Learn")
        takeScreenshot(named: "56_Flow_Learn", description: "Learn tab")
        
        // 5. Settings
        navigateToTab("Settings")
        takeScreenshot(named: "57_Flow_Settings", description: "Settings tab")
        
        // 6. Back to Dashboard
        navigateToTab("Dashboard")
        takeScreenshot(named: "58_Flow_Dashboard_Return", description: "Return to Dashboard")
    }
}
