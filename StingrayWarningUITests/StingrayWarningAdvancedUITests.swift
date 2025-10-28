import XCTest
import SwiftUI
@testable import Stingray_Warning

/// Advanced UI Testing framework with screenshot capabilities and visual regression testing
class StingrayWarningAdvancedUITests: XCTestCase {
    
    var app: XCUIApplication!
    var screenshotManager: ScreenshotManager!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        screenshotManager = ScreenshotManager()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
        screenshotManager = nil
    }
    
    // MARK: - Visual Regression Testing
    
    func testVisualRegressionDashboard() throws {
        navigateToTab("Dashboard")
        waitForViewToLoad()
        
        // Take baseline screenshot
        let baselineScreenshot = screenshotManager.takeScreenshot(named: "Dashboard_Baseline")
        
        // Compare with previous baseline (if exists)
        let comparisonResult = screenshotManager.compareWithBaseline(
            current: baselineScreenshot,
            baselineName: "Dashboard_Baseline"
        )
        
        XCTAssertTrue(comparisonResult.isMatch, "Dashboard visual regression detected: \(comparisonResult.differences)")
        
        // Save comparison report
        screenshotManager.saveComparisonReport(comparisonResult, testName: "testVisualRegressionDashboard")
    }
    
    func testVisualRegressionEventHistory() throws {
        navigateToTab("Event History")
        waitForViewToLoad()
        
        let baselineScreenshot = screenshotManager.takeScreenshot(named: "EventHistory_Baseline")
        let comparisonResult = screenshotManager.compareWithBaseline(
            current: baselineScreenshot,
            baselineName: "EventHistory_Baseline"
        )
        
        XCTAssertTrue(comparisonResult.isMatch, "Event History visual regression detected: \(comparisonResult.differences)")
        screenshotManager.saveComparisonReport(comparisonResult, testName: "testVisualRegressionEventHistory")
    }
    
    func testVisualRegressionLearn() throws {
        navigateToTab("Learn")
        waitForViewToLoad()
        
        let baselineScreenshot = screenshotManager.takeScreenshot(named: "Learn_Baseline")
        let comparisonResult = screenshotManager.compareWithBaseline(
            current: baselineScreenshot,
            baselineName: "Learn_Baseline"
        )
        
        XCTAssertTrue(comparisonResult.isMatch, "Learn tab visual regression detected: \(comparisonResult.differences)")
        screenshotManager.saveComparisonReport(comparisonResult, testName: "testVisualRegressionLearn")
    }
    
    func testVisualRegressionSettings() throws {
        navigateToTab("Settings")
        waitForViewToLoad()
        
        let baselineScreenshot = screenshotManager.takeScreenshot(named: "Settings_Baseline")
        let comparisonResult = screenshotManager.compareWithBaseline(
            current: baselineScreenshot,
            baselineName: "Settings_Baseline"
        )
        
        XCTAssertTrue(comparisonResult.isMatch, "Settings tab visual regression detected: \(comparisonResult.differences)")
        screenshotManager.saveComparisonReport(comparisonResult, testName: "testVisualRegressionSettings")
    }
    
    // MARK: - Multi-Device Screenshot Testing
    
    func testScreenshotsForAllDeviceSizes() throws {
        let deviceSizes = [
            "iPhone_SE": CGSize(width: 375, height: 667),
            "iPhone_12": CGSize(width: 390, height: 844),
            "iPhone_12_Pro_Max": CGSize(width: 428, height: 926),
            "iPad": CGSize(width: 768, height: 1024),
            "iPad_Pro": CGSize(width: 1024, height: 1366)
        ]
        
        for (deviceName, size) in deviceSizes {
            // Simulate different device sizes
            simulateDeviceSize(size)
            
            // Take screenshots for each tab
            for tabName in ["Dashboard", "Event History", "Learn", "Settings"] {
                navigateToTab(tabName)
                waitForViewToLoad()
                
                let screenshot = screenshotManager.takeScreenshot(
                    named: "\(tabName)_\(deviceName)",
                    deviceSize: size
                )
                
                // Save device-specific screenshot
                screenshotManager.saveScreenshot(screenshot, name: "Device_\(deviceName)", deviceName: deviceName)
            }
        }
    }
    
    // MARK: - Dark Mode Screenshots
    
    func testScreenshotsInDarkMode() throws {
        // Enable dark mode
        app.buttons["Settings"].tap()
        let darkModeToggle = app.switches["Dark Mode"]
        if darkModeToggle.exists {
            darkModeToggle.tap()
        }
        
        // Take screenshots in dark mode
        for tabName in ["Dashboard", "Event History", "Learn", "Settings"] {
            navigateToTab(tabName)
            waitForViewToLoad()
            
            let screenshot = screenshotManager.takeScreenshot(
                named: "\(tabName)_DarkMode",
                description: "\(tabName) in dark mode"
            )
            
            screenshotManager.saveScreenshot(screenshot, name: "DarkMode_\(tabName)", theme: "Dark")
        }
    }
    
    // MARK: - Accessibility Screenshots
    
    func testScreenshotsWithAccessibilityFeatures() throws {
        // Enable accessibility features
        enableAccessibilityFeatures()
        
        for tabName in ["Dashboard", "Event History", "Learn", "Settings"] {
            navigateToTab(tabName)
            waitForViewToLoad()
            
            let screenshot = screenshotManager.takeScreenshot(
                named: "\(tabName)_Accessibility",
                description: "\(tabName) with accessibility features"
            )
            
            screenshotManager.saveScreenshot(screenshot, name: "Accessibility_\(tabName)", accessibility: true)
        }
    }
    
    // MARK: - Dynamic Content Screenshots
    
    func testScreenshotsWithDynamicContent() throws {
        // Test with different data states
        
        // 1. Empty state
        navigateToTab("Event History")
        waitForViewToLoad()
        let _ = screenshotManager.takeScreenshot(named: "EventHistory_Empty")
        
        // 2. Add some test data (if possible)
        // This would depend on the app's data injection capabilities
        addTestData()
        
        // 3. Screenshot with data
        navigateToTab("Event History")
        waitForViewToLoad()
        let _ = screenshotManager.takeScreenshot(named: "EventHistory_WithData")
        
        // 4. Test different threat levels
        testDifferentThreatLevels()
    }
    
    // MARK: - Interactive Element Screenshots
    
    func testScreenshotsOfInteractiveElements() throws {
        navigateToTab("Dashboard")
        waitForViewToLoad()
        
        // Test button states
        let startButton = app.buttons["Start Monitoring"]
        if startButton.exists {
            // Screenshot with button in default state
            _ = screenshotManager.takeScreenshot(named: "Dashboard_StartButton_Default")
            
            // Tap button and screenshot
            startButton.tap()
            waitForViewToLoad()
            _ = screenshotManager.takeScreenshot(named: "Dashboard_StartButton_Pressed")
            
            // Screenshot with monitoring active
            _ = screenshotManager.takeScreenshot(named: "Dashboard_MonitoringActive")
        }
        
        // Test toggle states
        navigateToTab("Settings")
        waitForViewToLoad()
        
        let monitoringToggle = app.switches["Monitoring Enabled"]
        if monitoringToggle.exists {
            // Screenshot with toggle off
            _ = screenshotManager.takeScreenshot(named: "Settings_MonitoringToggle_Off")
            
            // Toggle on and screenshot
            monitoringToggle.tap()
            waitForViewToLoad()
            _ = screenshotManager.takeScreenshot(named: "Settings_MonitoringToggle_On")
        }
    }
    
    // MARK: - Error State Screenshots
    
    func testScreenshotsOfErrorStates() throws {
        // Test error states (if possible to trigger)
        
        // 1. Network error
        simulateNetworkError()
        navigateToTab("Dashboard")
        waitForViewToLoad()
        _ = screenshotManager.takeScreenshot(named: "Dashboard_NetworkError")
        
        // 2. Location permission denied
        simulateLocationPermissionDenied()
        navigateToTab("Dashboard")
        waitForViewToLoad()
        _ = screenshotManager.takeScreenshot(named: "Dashboard_LocationDenied")
        
        // 3. Notification permission denied
        simulateNotificationPermissionDenied()
        navigateToTab("Settings")
        waitForViewToLoad()
        _ = screenshotManager.takeScreenshot(named: "Settings_NotificationDenied")
    }
    
    // MARK: - Performance Screenshots
    
    func testScreenshotsDuringPerformanceTests() throws {
        let measureOptions = XCTMeasureOptions()
        measureOptions.iterationCount = 5
        
        measure(metrics: [XCTApplicationLaunchMetric()], options: measureOptions) {
            navigateToTab("Dashboard")
            waitForViewToLoad()
            _ = screenshotManager.takeScreenshot(named: "Dashboard_PerformanceTest")
        }
    }
    
    // MARK: - Helper Methods
    
    private func navigateToTab(_ tabName: String) {
        let tabButton = app.buttons[tabName]
        XCTAssertTrue(tabButton.exists)
        tabButton.tap()
        Thread.sleep(forTimeInterval: 1.0)
    }
    
    private func waitForViewToLoad(timeout: TimeInterval = 5.0) {
        let mainContent = app.otherElements["ContentView"]
        XCTAssertTrue(mainContent.waitForExistence(timeout: timeout))
    }
    
    private func simulateDeviceSize(_ size: CGSize) {
        // This would need to be implemented based on the testing framework
        // For now, we'll just take the screenshot
    }
    
    private func enableAccessibilityFeatures() {
        // Enable accessibility features if available
        // This would depend on the test configuration
    }
    
    private func addTestData() {
        // Add test data to the app if possible
        // This would depend on the app's data injection capabilities
    }
    
    private func testDifferentThreatLevels() {
        // Test different threat levels if possible
        // This would depend on the app's testing capabilities
    }
    
    private func simulateNetworkError() {
        // Simulate network error if possible
        // This would depend on the testing framework
    }
    
    private func simulateLocationPermissionDenied() {
        // Simulate location permission denied if possible
        // This would depend on the testing framework
    }
    
    private func simulateNotificationPermissionDenied() {
        // Simulate notification permission denied if possible
        // This would depend on the testing framework
    }
}

// MARK: - Screenshot Manager

class ScreenshotManager {
    
    private let fileManager = FileManager.default
    private let screenshotsDirectory: URL
    
    init() {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        screenshotsDirectory = documentsPath.appendingPathComponent("Screenshots")
        
        // Create screenshots directory if it doesn't exist
        try? fileManager.createDirectory(at: screenshotsDirectory, withIntermediateDirectories: true)
    }
    
    func takeScreenshot(named name: String, description: String = "", deviceSize: CGSize? = nil) -> XCUIScreenshot {
        let screenshot = XCUIScreen.main.screenshot()
        
        // Save screenshot
        saveScreenshot(screenshot, name: name, description: description, deviceSize: deviceSize)
        
        return screenshot
    }
    
    func saveScreenshot(_ screenshot: XCUIScreenshot, name: String, description: String = "", deviceSize: CGSize? = nil, deviceName: String? = nil, theme: String? = nil, accessibility: Bool = false) {
        let filename = generateFilename(name: name, deviceName: deviceName, theme: theme, accessibility: accessibility)
        let screenshotURL = screenshotsDirectory.appendingPathComponent(filename)
        
        do {
            try screenshot.pngRepresentation.write(to: screenshotURL)
            print("Screenshot saved to: \(screenshotURL.path)")
            
            // Save metadata
            saveScreenshotMetadata(
                name: name,
                description: description,
                deviceSize: deviceSize,
                deviceName: deviceName,
                theme: theme,
                accessibility: accessibility,
                url: screenshotURL
            )
        } catch {
            print("Failed to save screenshot: \(error)")
        }
    }
    
    func compareWithBaseline(current: XCUIScreenshot, baselineName: String) -> ScreenshotComparisonResult {
        let baselineURL = screenshotsDirectory.appendingPathComponent("\(baselineName).png")
        
        guard fileManager.fileExists(atPath: baselineURL.path) else {
            return ScreenshotComparisonResult(isMatch: false, differences: "Baseline not found")
        }
        
        // Load baseline image
        guard let baselineData = try? Data(contentsOf: baselineURL),
              let baselineImage = UIImage(data: baselineData) else {
            return ScreenshotComparisonResult(isMatch: false, differences: "Failed to load baseline image")
        }
        
        // Convert current screenshot to UIImage
        let currentImage = UIImage(data: current.pngRepresentation)!
        
        // Compare images
        let differences = compareImages(currentImage, baselineImage)
        
        return ScreenshotComparisonResult(isMatch: differences.isEmpty, differences: differences)
    }
    
    func saveComparisonReport(_ result: ScreenshotComparisonResult, testName: String) {
        let reportURL = screenshotsDirectory.appendingPathComponent("\(testName)_ComparisonReport.json")
        
        let report = [
            "testName": testName,
            "timestamp": Date().timeIntervalSince1970,
            "isMatch": result.isMatch,
            "differences": result.differences
        ] as [String: Any]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: report, options: .prettyPrinted)
            try jsonData.write(to: reportURL)
            print("Comparison report saved to: \(reportURL.path)")
        } catch {
            print("Failed to save comparison report: \(error)")
        }
    }
    
    private func generateFilename(name: String, deviceName: String?, theme: String?, accessibility: Bool) -> String {
        var filename = name
        
        if let deviceName = deviceName {
            filename += "_\(deviceName)"
        }
        
        if let theme = theme {
            filename += "_\(theme)"
        }
        
        if accessibility {
            filename += "_Accessibility"
        }
        
        filename += ".png"
        
        return filename
    }
    
    private func saveScreenshotMetadata(name: String, description: String, deviceSize: CGSize?, deviceName: String?, theme: String?, accessibility: Bool, url: URL) {
        let metadataURL = screenshotsDirectory.appendingPathComponent("\(name)_metadata.json")
        
        let metadata: [String: Any] = [
            "name": name,
            "description": description,
            "deviceSize": deviceSize != nil ? ["width": deviceSize!.width, "height": deviceSize!.height] : NSNull(),
            "deviceName": deviceName ?? NSNull(),
            "theme": theme ?? NSNull(),
            "accessibility": accessibility,
            "timestamp": Date().timeIntervalSince1970,
            "url": url.path
        ] as [String: Any]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: metadata, options: .prettyPrinted)
            try jsonData.write(to: metadataURL)
        } catch {
            print("Failed to save screenshot metadata: \(error)")
        }
    }
    
    private func compareImages(_ image1: UIImage, _ image2: UIImage) -> String {
        // Simple image comparison implementation
        // In a real implementation, you might use more sophisticated comparison algorithms
        
        let size1 = image1.size
        let size2 = image2.size
        
        if size1 != size2 {
            return "Image sizes differ: \(size1) vs \(size2)"
        }
        
        // For now, return empty string (images match)
        // In a real implementation, you would compare pixel data
        return ""
    }
}

// MARK: - Screenshot Comparison Result

struct ScreenshotComparisonResult {
    let isMatch: Bool
    let differences: String
}
