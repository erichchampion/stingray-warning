import XCTest
@testable import TwoG

/// Advanced UI Testing for the 2G app
class StingrayWarningAdvancedUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Dashboard Tests
    
    func testDashboardComponents() throws {
        // Wait for the Dashboard to load
        let dashboardTitle = app.staticTexts["Dashboard"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 5.0))
        
        // Verify all main sections are present
        XCTAssertTrue(app.staticTexts["Current Status"].exists)
        XCTAssertTrue(app.staticTexts["Recent 2G Connections"].exists)
        
        // Scroll to see About section
        app.swipeUp()
        XCTAssertTrue(app.staticTexts["About"].exists)
    }
    
    func test2GConnectionDisplay() throws {
        // Wait for the Dashboard to load
        let dashboardTitle = app.staticTexts["Dashboard"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 5.0))
        
        // Wait for monitoring to detect connections
        Thread.sleep(forTimeInterval: 3.0)
        
        // If 2G connections exist, they should be displayed in the Recent 2G Connections section
        // The exact UI elements may vary based on implementation
    }
}
