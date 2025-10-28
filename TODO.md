# Stingray Warning iOS App - Development Todo List

## Phase 1: Project Setup

### 1.1 Initial Setup
- [ ] Install XcodeGen if not already installed: `brew install xcodegen`
- [ ] Create basic directory structure:
  ```
  ├── project.yml
  ├── StingrayWarning/
  │   ├── App/
  │   ├── Monitoring/
  │   ├── UI/
  │   ├── Models/
  │   └── Resources/
  └── README.md
  ```

### 1.2 Create XcodeGen Configuration
- [ ] Create `project.yml` with basic project structure
- [ ] Configure app name: "Stingray Warning"
- [ ] Set bundle identifier: `com.yourdomain.stingraywarning`
- [ ] Set minimum iOS version: iOS 14.0+ (for CoreTelephony features)
- [ ] Configure required frameworks:
  - CoreTelephony
  - UserNotifications
  - CoreLocation (for location context)
  - BackgroundTasks
- [ ] Add Info.plist entries:
  - `NSUserTrackingUsageDescription` (if needed)
  - `UIBackgroundModes`: `["processing", "fetch"]`
  - Privacy descriptions for location services

### 1.3 Generate and Verify Project
- [ ] Run `xcodegen generate`
- [ ] Open generated Xcode project
- [ ] Verify project builds successfully
- [ ] Commit initial project structure to git

## Phase 2: Core Monitoring Infrastructure

### 2.1 Create Network Monitor Model
- [ ] Create `NetworkThreatLevel.swift` enum (None, Low, Medium, High, Critical)
- [ ] Create `NetworkEvent.swift` struct to store detection events
  - Timestamp
  - Radio technology
  - Carrier info
  - Threat level
  - Description
- [ ] Create `NetworkAnomaly.swift` struct for tracking suspicious patterns

### 2.2 Implement Cellular Security Monitor
- [ ] Create `CellularSecurityMonitor.swift` class
- [ ] Initialize `CTTelephonyNetworkInfo` instance
- [ ] Implement 2G detection method:
  ```swift
  func isConnectedTo2G() -> Bool
  ```
- [ ] Implement carrier validation method:
  ```swift
  func validateCarrier() -> Bool
  ```
- [ ] Create method to track network changes:
  ```swift
  func trackNetworkChange()
  ```
- [ ] Implement threat evaluation algorithm:
  ```swift
  func evaluateThreatLevel() -> NetworkThreatLevel
  ```

### 2.3 Add Notification Observer
- [ ] Register for `CTServiceRadioAccessTechnologyDidChangeNotification`
- [ ] Implement notification handler to log changes
- [ ] Add debouncing logic to prevent notification spam
- [ ] Track change frequency (count changes per time window)

### 2.4 Implement Baseline Learning
- [ ] Create method to establish normal network behavior
- [ ] Store baseline data (expected carriers, typical tech changes)
- [ ] Implement comparison logic for anomaly detection
- [ ] Add UserDefaults persistence for learned baselines

## Phase 3: Background Monitoring

### 3.1 Configure Background Tasks
- [ ] Register background task identifier in Info.plist
- [ ] Create `BackgroundTaskManager.swift`
- [ ] Implement BGProcessingTask for periodic monitoring
- [ ] Schedule background refresh tasks
- [ ] Test background task execution

### 3.2 Implement Persistence Layer
- [ ] Create `EventStore.swift` for storing detection events
- [ ] Use Core Data or file-based storage for event history
- [ ] Implement event pruning (keep last 7 days)
- [ ] Add methods to query historical anomalies

### 3.3 Battery Optimization
- [ ] Implement adaptive monitoring intervals
- [ ] Reduce monitoring frequency when battery is low
- [ ] Use efficient notification patterns
- [ ] Add user setting for monitoring aggressiveness

## Phase 4: Alert System

### 4.1 Local Notifications
- [ ] Create `NotificationManager.swift`
- [ ] Request notification permissions on first launch
- [ ] Implement notification templates for different threat levels
- [ ] Add notification actions (Dismiss, View Details)
- [ ] Implement notification throttling (max 1 per hour for Low, immediate for High)

### 4.2 Alert Content
- [ ] Design notification text for 2G detection
- [ ] Design notification text for rapid network changes
- [ ] Design notification text for carrier anomalies
- [ ] Add educational content explaining the threat
- [ ] Include timestamp and location context

### 4.3 In-App Alerts
- [ ] Create custom alert view controller
- [ ] Show detailed threat information
- [ ] Add "Learn More" educational content
- [ ] Implement alert history view

## Phase 5: User Interface

### 5.1 Main Dashboard
- [ ] Create `DashboardViewController.swift`
- [ ] Show current network status (carrier, technology, signal)
- [ ] Display current threat level with color coding
- [ ] Add "Last checked" timestamp
- [ ] Show count of anomalies detected today/week

### 5.2 Current Status View
- [ ] Display current radio technology (2G/3G/4G/5G)
- [ ] Show carrier name and MCC/MNC codes
- [ ] Add visual indicator (green = safe, yellow = caution, red = threat)
- [ ] Display real-time monitoring status (Active/Paused)

### 5.3 Event History View
- [ ] Create `EventHistoryViewController.swift`
- [ ] Display list of detection events with timestamps
- [ ] Filter by threat level
- [ ] Show event details on tap
- [ ] Add export functionality (CSV or JSON)

### 5.4 Settings View
- [ ] Create `SettingsViewController.swift`
- [ ] Add toggle for background monitoring
- [ ] Add notification preferences
- [ ] Include sensitivity slider (conservative to aggressive)
- [ ] Add expected carrier configuration
- [ ] Include battery optimization settings

### 5.5 Education View
- [ ] Create "What is an IMSI Catcher?" explanation
- [ ] Add "How This App Protects You" section
- [ ] Include "Limitations" disclaimer
- [ ] Add links to additional resources
- [ ] Show detected message types and what they mean

## Phase 6: Enhanced Detection Features

### 6.1 Location Context
- [ ] Request location permissions (when-in-use)
- [ ] Track location when anomalies detected
- [ ] Identify if user is stationary vs. moving
- [ ] Flag anomalies when stationary as more suspicious
- [ ] Show anomaly locations on map view

### 6.2 Pattern Analysis
- [ ] Implement time-series analysis of network changes
- [ ] Detect unusual patterns (oscillating between 2G/4G)
- [ ] Calculate standard deviation from baseline
- [ ] Flag clusters of rapid changes
- [ ] Generate weekly security reports

### 6.3 Carrier Database
- [ ] Create JSON file with known legitimate carriers by country
- [ ] Include MCC/MNC codes for validation
- [ ] Add method to validate against database
- [ ] Update database via remote config (future)

### 6.4 Statistical Analysis
- [ ] Calculate p-values for anomaly significance
- [ ] Implement rolling window statistics
- [ ] Track false positive rate
- [ ] Add confidence scores to alerts

## Phase 7: Testing & Validation

### 7.1 Unit Tests
- [ ] Create test suite for `CellularSecurityMonitor`
- [ ] Test 2G detection logic
- [ ] Test threat evaluation algorithm
- [ ] Test baseline learning and comparison
- [ ] Test notification throttling logic

### 7.2 Integration Tests
- [ ] Test background task execution
- [ ] Test notification delivery
- [ ] Test event persistence
- [ ] Test UI updates from monitoring events

### 7.3 Real-World Testing
- [ ] Test in areas with known 2G coverage
- [ ] Test with airplane mode on/off cycles
- [ ] Test with multiple carrier scenarios
- [ ] Verify battery impact over 24 hours
- [ ] Test notification timing and throttling

### 7.4 Edge Cases
- [ ] Test with no cellular connection
- [ ] Test with dual SIM devices
- [ ] Test during carrier handoffs
- [ ] Test in roaming scenarios
- [ ] Test with VPN active

## Phase 8: Polish & Documentation

### 8.1 UI Polish
- [ ] Design app icon with radar/security theme
- [ ] Add app launch screen
- [ ] Implement dark mode support
- [ ] Add smooth animations for status changes
- [ ] Ensure accessibility (VoiceOver support)

### 8.2 Code Documentation
- [ ] Add documentation comments to all public APIs
- [ ] Create architecture diagram
- [ ] Document monitoring algorithm
- [ ] Explain threat scoring logic
- [ ] Add inline comments for complex logic

### 8.3 User Documentation
- [ ] Create README with setup instructions
- [ ] Write user guide for app features
- [ ] Add FAQ section
- [ ] Document privacy policy
- [ ] Add troubleshooting guide

### 8.4 Compliance & Privacy
- [ ] Ensure no PII is collected
- [ ] Add privacy policy to app
- [ ] Verify all required Info.plist descriptions
- [ ] Document data retention policy
- [ ] Prepare App Store privacy disclosures

## Phase 9: Advanced Features (Optional)

### 9.1 Crowdsourced Alerts
- [ ] Design backend API for reporting anomalies
- [ ] Implement anonymous submission
- [ ] Show community alerts for current location
- [ ] Add heatmap of reported incidents

### 9.2 Apple Watch Companion
- [ ] Create Watch app with current status
- [ ] Show threat level complications
- [ ] Deliver haptic alerts on detection

### 9.3 Widget Support
- [ ] Create iOS 14+ home screen widget
- [ ] Show current threat level
- [ ] Display last check time
- [ ] Update widget on anomaly detection

### 9.4 Shortcuts Integration
- [ ] Add Siri Shortcuts support
- [ ] Create "Check Security Status" shortcut
- [ ] Add "Enable/Disable Monitoring" action
- [ ] Provide automation triggers

## Phase 10: Release Preparation

### 10.1 App Store Assets
- [ ] Create app screenshots (all required sizes)
- [ ] Write app description
- [ ] Prepare app preview video
- [ ] Design promotional artwork
- [ ] Prepare keywords for ASO

### 10.2 Beta Testing
- [ ] Set up TestFlight
- [ ] Recruit beta testers
- [ ] Gather feedback on usability
- [ ] Fix reported bugs
- [ ] Iterate on UI/UX

### 10.3 Final Checks
- [ ] Run static analysis tools
- [ ] Check for memory leaks
- [ ] Verify all strings are localized
- [ ] Test on minimum iOS version
- [ ] Perform security audit of code

### 10.4 Submission
- [ ] Create App Store Connect listing
- [ ] Upload build via Xcode
- [ ] Submit for review
- [ ] Respond to any App Store feedback
- [ ] Monitor initial user reviews

---

## Critical Implementation Notes

**Background Limitations**: iOS restricts background execution significantly. The app can use:
- Background fetch (periodic, system-determined intervals)
- BGProcessingTask (for longer processing when device is idle)
- Push notifications for immediate alerts (requires server)

**Battery Concerns**: Continuous CoreTelephony monitoring is not very battery intensive, but excessive logging and notifications can be. Implement smart throttling.

**Detection Accuracy**: This app will have significantly limited detection capabilities compared to dedicated SDR hardware. Set user expectations appropriately in the app's educational content.

**Privacy First**: Never collect user location, identifiers, or communications. Only monitor network metadata for local analysis.

**Legal Disclaimer**: Include clear disclaimer that this is a security awareness tool with limitations, and should not be solely relied upon for protection against sophisticated attacks.
