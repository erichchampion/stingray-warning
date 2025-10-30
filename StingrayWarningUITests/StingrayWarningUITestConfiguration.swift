import XCTest

/// Configuration and setup for UI tests
class StingrayWarningUITestConfiguration: XCTestCase {
    
    // MARK: - Test Configuration
    
    static func configureUITests() {
        // Set up test environment
        let app = XCUIApplication()
        
        // Configure launch arguments
        app.launchArguments = [
            "--uitesting",
            "--disable-animations",
            "--screenshot-mode"
        ]
        
        // Configure launch environment
        app.launchEnvironment = [
            "UITESTING": "1",
            "SCREENSHOT_MODE": "1",
            "DISABLE_ANIMATIONS": "1"
        ]
        
        // Launch the app
        app.launch()
    }
    
    // MARK: - Device Configuration
    
    static func configureForDevice(_ deviceType: DeviceType) {
        switch deviceType {
        case .iPhoneSE:
            configureForiPhoneSE()
        case .iPhone12:
            configureForiPhone12()
        case .iPhone12ProMax:
            configureForiPhone12ProMax()
        case .iPad:
            configureForiPad()
        case .iPadPro:
            configureForiPadPro()
        }
    }
    
    private static func configureForiPhoneSE() {
        // iPhone SE specific configuration
        XCUIDevice.shared.orientation = .portrait
    }
    
    private static func configureForiPhone12() {
        // iPhone 12 specific configuration
        XCUIDevice.shared.orientation = .portrait
    }
    
    private static func configureForiPhone12ProMax() {
        // iPhone 12 Pro Max specific configuration
        XCUIDevice.shared.orientation = .portrait
    }
    
    private static func configureForiPad() {
        // iPad specific configuration
        XCUIDevice.shared.orientation = .portrait
    }
    
    private static func configureForiPadPro() {
        // iPad Pro specific configuration
        XCUIDevice.shared.orientation = .portrait
    }
    
    // MARK: - Accessibility Configuration
    
    static func enableAccessibilityFeatures() {
        // Enable accessibility features for testing
        let app = XCUIApplication()
        
        // Configure accessibility settings
        app.launchEnvironment["ACCESSIBILITY_ENABLED"] = "1"
        app.launchEnvironment["VOICE_OVER_ENABLED"] = "1"
        app.launchEnvironment["DYNAMIC_TYPE_ENABLED"] = "1"
    }
    
    static func disableAccessibilityFeatures() {
        // Disable accessibility features
        let app = XCUIApplication()
        
        app.launchEnvironment["ACCESSIBILITY_ENABLED"] = "0"
        app.launchEnvironment["VOICE_OVER_ENABLED"] = "0"
        app.launchEnvironment["DYNAMIC_TYPE_ENABLED"] = "0"
    }
    
    // MARK: - Theme Configuration
    
    static func configureForLightMode() {
        let app = XCUIApplication()
        app.launchEnvironment["THEME"] = "light"
    }
    
    static func configureForDarkMode() {
        let app = XCUIApplication()
        app.launchEnvironment["THEME"] = "dark"
    }
    
    // MARK: - Network Configuration
    
    static func configureForNetworkTesting() {
        let app = XCUIApplication()
        app.launchEnvironment["NETWORK_TESTING"] = "1"
        app.launchEnvironment["MOCK_NETWORK"] = "1"
    }
    
    static func configureForOfflineTesting() {
        let app = XCUIApplication()
        app.launchEnvironment["OFFLINE_MODE"] = "1"
        app.launchEnvironment["MOCK_NETWORK"] = "1"
    }
    
    // MARK: - Location Configuration
    
    static func configureForLocationTesting() {
        let app = XCUIApplication()
        app.launchEnvironment["LOCATION_TESTING"] = "1"
        app.launchEnvironment["MOCK_LOCATION"] = "1"
        app.launchEnvironment["MOCK_LOCATION_LAT"] = "37.7749"
        app.launchEnvironment["MOCK_LOCATION_LON"] = "-122.4194"
    }
    
    static func configureForLocationDenied() {
        let app = XCUIApplication()
        app.launchEnvironment["LOCATION_DENIED"] = "1"
    }
    
    // MARK: - Notification Configuration
    
    static func configureForNotificationTesting() {
        let app = XCUIApplication()
        app.launchEnvironment["NOTIFICATION_TESTING"] = "1"
        app.launchEnvironment["MOCK_NOTIFICATIONS"] = "1"
    }
    
    static func configureForNotificationDenied() {
        let app = XCUIApplication()
        app.launchEnvironment["NOTIFICATION_DENIED"] = "1"
    }
    
    // MARK: - Data Configuration
    
    static func configureWithTestData() {
        let app = XCUIApplication()
        app.launchEnvironment["TEST_DATA"] = "1"
        app.launchEnvironment["MOCK_EVENTS"] = "1"
        app.launchEnvironment["MOCK_ANOMALIES"] = "1"
    }
    
    static func configureWithEmptyData() {
        let app = XCUIApplication()
        app.launchEnvironment["EMPTY_DATA"] = "1"
        app.launchEnvironment["CLEAR_DATA"] = "1"
    }
    
    // MARK: - Performance Configuration
    
    static func configureForPerformanceTesting() {
        let app = XCUIApplication()
        app.launchEnvironment["PERFORMANCE_TESTING"] = "1"
        app.launchEnvironment["DISABLE_ANIMATIONS"] = "1"
        app.launchEnvironment["DISABLE_LOGGING"] = "1"
    }
    
    // MARK: - Screenshot Configuration
    
    static func configureForScreenshotTesting() {
        let app = XCUIApplication()
        app.launchEnvironment["SCREENSHOT_MODE"] = "1"
        app.launchEnvironment["DISABLE_ANIMATIONS"] = "1"
        app.launchEnvironment["STATIC_CONTENT"] = "1"
    }
    
    // MARK: - Error Simulation
    
    static func configureForErrorTesting() {
        let app = XCUIApplication()
        app.launchEnvironment["ERROR_TESTING"] = "1"
        app.launchEnvironment["SIMULATE_ERRORS"] = "1"
    }
    
    static func configureForNetworkError() {
        let app = XCUIApplication()
        app.launchEnvironment["NETWORK_ERROR"] = "1"
        app.launchEnvironment["SIMULATE_NETWORK_ERROR"] = "1"
    }
    
    static func configureForLocationError() {
        let app = XCUIApplication()
        app.launchEnvironment["LOCATION_ERROR"] = "1"
        app.launchEnvironment["SIMULATE_LOCATION_ERROR"] = "1"
    }
    
    static func configureForNotificationError() {
        let app = XCUIApplication()
        app.launchEnvironment["NOTIFICATION_ERROR"] = "1"
        app.launchEnvironment["SIMULATE_NOTIFICATION_ERROR"] = "1"
    }
}

// MARK: - Device Type Enum

enum DeviceType {
    case iPhoneSE
    case iPhone12
    case iPhone12ProMax
    case iPad
    case iPadPro
}

// MARK: - Test Data Configuration

class TestDataConfiguration {
    
    static func configureWithSampleEvents() {
        let app = XCUIApplication()
        app.launchEnvironment["SAMPLE_EVENTS"] = "1"
        app.launchEnvironment["EVENT_COUNT"] = "10"
    }
    
    static func configureWithSampleAnomalies() {
        let app = XCUIApplication()
        app.launchEnvironment["SAMPLE_ANOMALIES"] = "1"
        app.launchEnvironment["ANOMALY_COUNT"] = "5"
    }
    
    static func configureWithHighIssueEvents() {
        let app = XCUIApplication()
        app.launchEnvironment["HIGH_ISSUE_EVENTS"] = "1"
        app.launchEnvironment["ISSUE_LEVEL"] = "high"
    }
    
    static func configureWithCriticalIssueEvents() {
        let app = XCUIApplication()
        app.launchEnvironment["CRITICAL_ISSUE_EVENTS"] = "1"
        app.launchEnvironment["ISSUE_LEVEL"] = "critical"
    }
    
    static func configureWith2GEvents() {
        let app = XCUIApplication()
        app.launchEnvironment["2G_EVENTS"] = "1"
        app.launchEnvironment["RADIO_TECHNOLOGY"] = "GSM"
    }
    
    static func configureWith5GEvents() {
        let app = XCUIApplication()
        app.launchEnvironment["5G_EVENTS"] = "1"
        app.launchEnvironment["RADIO_TECHNOLOGY"] = "NRNSA"
    }
}

// MARK: - Screenshot Configuration

class ScreenshotConfiguration {
    
    static func configureForAppStoreScreenshots() {
        let app = XCUIApplication()
        app.launchEnvironment["APP_STORE_SCREENSHOTS"] = "1"
        app.launchEnvironment["DISABLE_ANIMATIONS"] = "1"
        app.launchEnvironment["STATIC_CONTENT"] = "1"
        app.launchEnvironment["PERFECT_DATA"] = "1"
    }
    
    static func configureForDocumentationScreenshots() {
        let app = XCUIApplication()
        app.launchEnvironment["DOCUMENTATION_SCREENSHOTS"] = "1"
        app.launchEnvironment["DISABLE_ANIMATIONS"] = "1"
        app.launchEnvironment["CLEAN_UI"] = "1"
    }
    
    static func configureForTestingScreenshots() {
        let app = XCUIApplication()
        app.launchEnvironment["TESTING_SCREENSHOTS"] = "1"
        app.launchEnvironment["DISABLE_ANIMATIONS"] = "1"
        app.launchEnvironment["VERBOSE_LOGGING"] = "1"
    }
}
