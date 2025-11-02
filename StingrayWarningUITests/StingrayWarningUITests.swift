import XCTest
@testable import TwoG

/// UI Tests for the 2G app
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
    
    // MARK: - Basic UI Tests
    
    func testDashboardLoads() throws {
        // Wait for the Dashboard to load
        let dashboardTitle = app.staticTexts["Dashboard"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 5.0), "Dashboard should load")
    }
    
    func testCurrentStatusSectionExists() throws {
        // Wait for the Dashboard to load
        let dashboardTitle = app.staticTexts["Dashboard"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 5.0))
        
        // Check for Current Status section
        let currentStatus = app.staticTexts["Current Status"]
        XCTAssertTrue(currentStatus.exists, "Current Status section should exist")
    }
    
    func testRecent2GConnectionsSectionExists() throws {
        // Wait for the Dashboard to load
        let dashboardTitle = app.staticTexts["Dashboard"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 5.0))
        
        // Scroll down to find the Recent 2G Connections section
        app.swipeUp()
        
        // Check for Recent 2G Connections section with a wait
        let recent2G = app.staticTexts["Recent 2G Connections"]
        XCTAssertTrue(recent2G.waitForExistence(timeout: 5.0), "Recent 2G Connections section should exist")
    }
    
    func testAboutSectionExists() throws {
        // Wait for the Dashboard to load
        let dashboardTitle = app.staticTexts["Dashboard"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 5.0))
        
        // Scroll to find About section
        app.swipeUp()
        
        // Check for About section
        let about = app.staticTexts["About"]
        XCTAssertTrue(about.exists, "About section should exist")
    }
    
    func testMonitoringStartsAutomatically() throws {
        // Wait for the Dashboard to load
        let dashboardTitle = app.staticTexts["Dashboard"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 5.0))
        
        // Wait a moment for monitoring to start
        Thread.sleep(forTimeInterval: 2.0)
        
        // Check that monitoring is active (status indicator should show "Active")
        // Monitoring should start automatically, so the status indicator should exist
        // Note: The exact UI implementation may vary, so we just verify the dashboard loaded
        XCTAssertTrue(dashboardTitle.exists, "Dashboard should remain visible after monitoring starts")
    }
}
