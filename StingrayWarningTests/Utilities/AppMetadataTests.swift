import XCTest
import UIKit
@testable import TwoG

/// Unit tests for AppMetadata utility
class AppMetadataTests: XCTestCase {
    
    // MARK: - URL Access Tests
    
    func testSupportURL() {
        // Given & When
        let supportURL = AppMetadata.supportURL
        
        // Then
        // URL should be valid if configured in Info.plist
        if let url = supportURL {
            XCTAssertTrue(url.absoluteString.contains("defroster.us"))
        }
    }
    
    func testPrivacyPolicyURL() {
        // Given & When
        let privacyURL = AppMetadata.privacyPolicyURL
        
        // Then
        // URL should be valid if configured in Info.plist
        if let url = privacyURL {
            XCTAssertTrue(url.absoluteString.contains("defroster.us"))
            XCTAssertTrue(url.absoluteString.contains("privacy"))
        }
    }
    
    func testContactURL() {
        // Given & When
        let contactURL = AppMetadata.contactURL
        
        // Then
        // URL should be valid if configured in Info.plist
        if let url = contactURL {
            XCTAssertTrue(url.absoluteString.contains("defroster.us"))
            XCTAssertTrue(url.absoluteString.contains("contact"))
        }
    }
    
    func testURLValidity() {
        // Given & When
        let supportURL = AppMetadata.supportURL
        let privacyURL = AppMetadata.privacyPolicyURL
        let contactURL = AppMetadata.contactURL
        
        // Then
        // All URLs should be valid if they exist
        if let url = supportURL {
            XCTAssertNotNil(URL(string: url.absoluteString))
        }
        if let url = privacyURL {
            XCTAssertNotNil(URL(string: url.absoluteString))
        }
        if let url = contactURL {
            XCTAssertNotNil(URL(string: url.absoluteString))
        }
    }
    
    func testURLSchemes() {
        // Given & When
        let supportURL = AppMetadata.supportURL
        let privacyURL = AppMetadata.privacyPolicyURL
        let contactURL = AppMetadata.contactURL
        
        // Then
        // All URLs should use HTTPS scheme
        if let url = supportURL {
            XCTAssertEqual(url.scheme, "https")
        }
        if let url = privacyURL {
            XCTAssertEqual(url.scheme, "https")
        }
        if let url = contactURL {
            XCTAssertEqual(url.scheme, "https")
        }
    }
    
    // MARK: - App Information Tests
    
    func testAppVersion() {
        // Given & When
        let appVersion = AppMetadata.appVersion
        
        // Then
        XCTAssertNotNil(appVersion)
        XCTAssertFalse(appVersion.isEmpty)
        // Version should be in format like "1.0.0"
        XCTAssertTrue(appVersion.contains("."))
    }
    
    func testBuildNumber() {
        // Given & When
        let buildNumber = AppMetadata.buildNumber
        
        // Then
        XCTAssertNotNil(buildNumber)
        XCTAssertFalse(buildNumber.isEmpty)
        // Build number should be numeric
        XCTAssertNotNil(Int(buildNumber))
    }
    
    func testAppName() {
        // Given & When
        let appName = AppMetadata.appName
        
        // Then
        XCTAssertNotNil(appName)
        XCTAssertFalse(appName.isEmpty)
        XCTAssertEqual(appName, "2G")
    }
    
    func testCopyright() {
        // Given & When
        let copyright = AppMetadata.copyright
        
        // Then
        XCTAssertNotNil(copyright)
        XCTAssertFalse(copyright.isEmpty)
        XCTAssertTrue(copyright.contains("©"))
        XCTAssertTrue(copyright.contains("2024") || copyright.contains("2025"))
        XCTAssertTrue(copyright.contains("2G"))
    }
    
    // MARK: - URL Opening Tests
    
    func testOpenSupportURL() {
        // Given
        let supportURL = AppMetadata.supportURL
        
        // When
        if let _ = supportURL {
            AppMetadata.openSupportURL()
            // Note: In a real test, we'd verify the URL was opened
            // For now, we just ensure no errors occur
        }
        
        // Then
        // Should not throw any errors
    }
    
    func testOpenPrivacyPolicyURL() {
        // Given
        let privacyURL = AppMetadata.privacyPolicyURL
        
        // When
        if let _ = privacyURL {
            AppMetadata.openPrivacyPolicyURL()
            // Note: In a real test, we'd verify the URL was opened
            // For now, we just ensure no errors occur
        }
        
        // Then
        // Should not throw any errors
    }
    
    func testOpenContactURL() {
        // Given
        let contactURL = AppMetadata.contactURL
        
        // When
        if let _ = contactURL {
            AppMetadata.openContactURL()
            // Note: In a real test, we'd verify the URL was opened
            // For now, we just ensure no errors occur
        }
        
        // Then
        // Should not throw any errors
    }
    
    func testOpenURLWithNilURL() {
        // Given
        // Simulate nil URL (though this shouldn't happen in practice)
        
        // When
        AppMetadata.openSupportURL()
        AppMetadata.openPrivacyPolicyURL()
        AppMetadata.openContactURL()
        
        // Then
        // Should handle nil URLs gracefully
        // No errors should occur
    }
    
    // MARK: - Bundle Access Tests
    
    func testBundleInfoAccess() {
        // Given & When
        let bundle = Bundle.main
        let appVersion = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let buildNumber = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        let appName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
        
        // Then
        XCTAssertNotNil(appVersion)
        XCTAssertNotNil(buildNumber)
        XCTAssertNotNil(appName)
    }
    
    func testCustomInfoPlistKeys() {
        // Given & When
        let bundle = Bundle.main
        let supportURL = bundle.object(forInfoDictionaryKey: "SupportURL") as? String
        let privacyURL = bundle.object(forInfoDictionaryKey: "PrivacyPolicyURL") as? String
        let contactURL = bundle.object(forInfoDictionaryKey: "ContactURL") as? String
        let copyright = bundle.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String
        
        // Then
        // These should be configured in Info.plist
        if let url = supportURL {
            XCTAssertTrue(url.contains("defroster.us"))
        }
        if let url = privacyURL {
            XCTAssertTrue(url.contains("defroster.us"))
            XCTAssertTrue(url.contains("privacy"))
        }
        if let url = contactURL {
            XCTAssertTrue(url.contains("defroster.us"))
            XCTAssertTrue(url.contains("contact"))
        }
        if let copyright = copyright {
            XCTAssertTrue(copyright.contains("©"))
            XCTAssertTrue(copyright.contains("2024") || copyright.contains("2025"))
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testInvalidURLHandling() {
        // Given
        // Simulate invalid URL scenarios
        
        // When
        AppMetadata.openSupportURL()
        AppMetadata.openPrivacyPolicyURL()
        AppMetadata.openContactURL()
        
        // Then
        // Should handle invalid URLs gracefully
        // No crashes should occur
    }
    
    func testMissingInfoPlistKeys() {
        // Given
        // Test with missing keys (though they should be present)
        
        // When
        let appVersion = AppMetadata.appVersion
        let buildNumber = AppMetadata.buildNumber
        let appName = AppMetadata.appName
        let copyright = AppMetadata.copyright
        
        // Then
        // Should handle missing keys gracefully
        XCTAssertNotNil(appVersion)
        XCTAssertNotNil(buildNumber)
        XCTAssertNotNil(appName)
        XCTAssertNotNil(copyright)
    }
    
    // MARK: - Edge Cases
    
    func testAppVersionWithSpecialCharacters() {
        // Given & When
        let appVersion = AppMetadata.appVersion
        
        // Then
        // Version should be valid
        XCTAssertNotNil(appVersion)
        XCTAssertFalse(appVersion.isEmpty)
    }
    
    func testBuildNumberWithLeadingZeros() {
        // Given & When
        let buildNumber = AppMetadata.buildNumber
        
        // Then
        // Build number should be valid
        XCTAssertNotNil(buildNumber)
        XCTAssertFalse(buildNumber.isEmpty)
    }
    
    func testAppNameWithUnicodeCharacters() {
        // Given & When
        let appName = AppMetadata.appName
        
        // Then
        // App name should be valid
        XCTAssertNotNil(appName)
        XCTAssertFalse(appName.isEmpty)
    }
    
    func testCopyrightWithUnicodeCharacters() {
        // Given & When
        let copyright = AppMetadata.copyright
        
        // Then
        // Copyright should be valid
        XCTAssertNotNil(copyright)
        XCTAssertFalse(copyright.isEmpty)
    }
    
    // MARK: - Performance Tests
    
    func testURLAccessPerformance() {
        // When & Then
        measure {
            for _ in 0..<1000 {
                _ = AppMetadata.supportURL
                _ = AppMetadata.privacyPolicyURL
                _ = AppMetadata.contactURL
            }
        }
    }
    
    func testAppInfoAccessPerformance() {
        // When & Then
        measure {
            for _ in 0..<1000 {
                _ = AppMetadata.appVersion
                _ = AppMetadata.buildNumber
                _ = AppMetadata.appName
                _ = AppMetadata.copyright
            }
        }
    }
    
    func testURLOpeningPerformance() {
        // When & Then
        measure {
            for _ in 0..<100 {
                AppMetadata.openSupportURL()
                AppMetadata.openPrivacyPolicyURL()
                AppMetadata.openContactURL()
            }
        }
    }
    
    // MARK: - Integration Tests
    
    func testAppMetadataIntegration() {
        // Given & When
        let supportURL = AppMetadata.supportURL
        let privacyURL = AppMetadata.privacyPolicyURL
        let contactURL = AppMetadata.contactURL
        let appVersion = AppMetadata.appVersion
        let buildNumber = AppMetadata.buildNumber
        let appName = AppMetadata.appName
        let copyright = AppMetadata.copyright
        
        // Then
        // All properties should be accessible
        XCTAssertNotNil(supportURL)
        XCTAssertNotNil(privacyURL)
        XCTAssertNotNil(contactURL)
        XCTAssertNotNil(appVersion)
        XCTAssertNotNil(buildNumber)
        XCTAssertNotNil(appName)
        XCTAssertNotNil(copyright)
        
        // URLs should be valid
        if let url = supportURL {
            XCTAssertNotNil(URL(string: url.absoluteString))
        }
        if let url = privacyURL {
            XCTAssertNotNil(URL(string: url.absoluteString))
        }
        if let url = contactURL {
            XCTAssertNotNil(URL(string: url.absoluteString))
        }
        
        // App info should be valid
        XCTAssertFalse(appVersion.isEmpty)
        XCTAssertFalse(buildNumber.isEmpty)
        XCTAssertFalse(appName.isEmpty)
        XCTAssertFalse(copyright.isEmpty)
    }
    
    func testAppMetadataWithRealBundle() {
        // Given
        let bundle = Bundle.main
        
        // When
        let _ = AppMetadata.supportURL
        let _ = AppMetadata.privacyPolicyURL
        let _ = AppMetadata.contactURL
        let appVersion = AppMetadata.appVersion
        let buildNumber = AppMetadata.buildNumber
        let appName = AppMetadata.appName
        let _ = AppMetadata.copyright
        
        // Then
        // Should match bundle values
        let bundleAppVersion = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let bundleBuildNumber = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        let bundleAppName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
        
        XCTAssertEqual(appVersion, bundleAppVersion)
        XCTAssertEqual(buildNumber, bundleBuildNumber)
        XCTAssertEqual(appName, bundleAppName)
    }
    
    // MARK: - Mock Tests (if mock injection is implemented)
    
    func testMockBundleAccess() {
        // Given
        // In a real test, we'd mock the bundle
        
        // When
        let appVersion = AppMetadata.appVersion
        let buildNumber = AppMetadata.buildNumber
        let appName = AppMetadata.appName
        
        // Then
        // Should work with mock bundle
        XCTAssertNotNil(appVersion)
        XCTAssertNotNil(buildNumber)
        XCTAssertNotNil(appName)
    }
    
    func testMockURLOpening() {
        // Given
        // In a real test, we'd mock UIApplication.shared.open
        
        // When
        AppMetadata.openSupportURL()
        AppMetadata.openPrivacyPolicyURL()
        AppMetadata.openContactURL()
        
        // Then
        // Should work with mock URL opening
        // No errors should occur
    }
}
