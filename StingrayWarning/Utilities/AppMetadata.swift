import Foundation
import UIKit

/// Utility class for accessing app metadata and URLs from Info.plist
class AppMetadata {
    
    // MARK: - URL Access
    
    /// Support URL from Info.plist
    static var supportURL: URL? {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "SupportURL") as? String else {
            return nil
        }
        return URL(string: urlString)
    }
    
    /// Privacy Policy URL from Info.plist
    static var privacyPolicyURL: URL? {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "PrivacyPolicyURL") as? String else {
            return nil
        }
        return URL(string: urlString)
    }
    
    /// Contact URL from Info.plist
    static var contactURL: URL? {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "ContactURL") as? String else {
            return nil
        }
        return URL(string: urlString)
    }
    
    /// Terms of Service URL from Info.plist
    static var termsOfServiceURL: URL? {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "TermsOfServiceURL") as? String else {
            return nil
        }
        return URL(string: urlString)
    }
    
    /// Marketing URL from Info.plist
    static var marketingURL: URL? {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "MarketingURL") as? String else {
            return nil
        }
        return URL(string: urlString)
    }
    
    /// App Store URL from Info.plist
    static var appStoreURL: URL? {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "AppStoreURL") as? String else {
            return nil
        }
        return URL(string: urlString)
    }
    
    // MARK: - App Information
    
    /// App version string
    static var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    }
    
    /// Build number
    static var buildNumber: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
    }
    
    /// App name
    static var appName: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? 
               Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Unknown"
    }
    
    /// Copyright information
    static var copyright: String {
        return Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String ?? ""
    }
    
    /// App category
    static var appCategory: String {
        return Bundle.main.object(forInfoDictionaryKey: "LSApplicationCategoryType") as? String ?? ""
    }
    
    // MARK: - URL Actions
    
    /// Opens the support URL in Safari
    static func openSupportURL() {
        guard let url = supportURL else { return }
        UIApplication.shared.open(url)
    }
    
    /// Opens the privacy policy URL in Safari
    static func openPrivacyPolicyURL() {
        guard let url = privacyPolicyURL else { return }
        UIApplication.shared.open(url)
    }
    
    /// Opens the contact URL in Safari
    static func openContactURL() {
        guard let url = contactURL else { return }
        UIApplication.shared.open(url)
    }
    
    /// Opens the terms of service URL in Safari
    static func openTermsOfServiceURL() {
        guard let url = termsOfServiceURL else { return }
        UIApplication.shared.open(url)
    }
    
    /// Opens the marketing URL in Safari
    static func openMarketingURL() {
        guard let url = marketingURL else { return }
        UIApplication.shared.open(url)
    }
    
    /// Opens the App Store URL in Safari
    static func openAppStoreURL() {
        guard let url = appStoreURL else { return }
        UIApplication.shared.open(url)
    }
    
    // MARK: - Debug Information
    
    /// Returns all available Info.plist keys for debugging
    static var debugInfo: [String: Any] {
        return Bundle.main.infoDictionary ?? [:]
    }
}
