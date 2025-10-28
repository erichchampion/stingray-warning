import SwiftUI

struct EducationView: View {
    @State private var selectedSection: EducationSection = .whatIsIMSI
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Section Picker
                Picker("Education Section", selection: $selectedSection) {
                    ForEach(EducationSection.allCases, id: \.self) { section in
                        Text(section.title).tag(section)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content
                GeometryReader { geometry in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 20) {
                        switch selectedSection {
                        case .whatIsIMSI:
                            WhatIsIMSICatcherView()
                        case .protection:
                            ProtectionView()
                        case .bestPractices:
                            BestPracticesView()
                        }
                        }
                        .padding()
                        .frame(minHeight: geometry.size.height)
                    }
                }
            }
            .navigationTitle("Learn")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

enum EducationSection: CaseIterable {
    case whatIsIMSI
    case protection
    case bestPractices
    
    var title: String {
        switch self {
        case .whatIsIMSI: return "IMSI Catchers"
        case .protection: return "Protection"
        case .bestPractices: return "Best Practices"
        }
    }
}

// MARK: - Education Content Views

struct WhatIsIMSICatcherView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SharedUIComponents.EducationHeader(
                title: "What is an IMSI Catcher?",
                icon: "antenna.radiowaves.left.and.right",
                color: .red
            )
            
            SharedUIComponents.EducationCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("IMSI Catcher Definition")
                        .font(.headline)
                    Text("An IMSI Catcher (also known as a Stingray, Cell Site Simulator, or Fake Base Station) is a surveillance device that mimics a legitimate cell tower to intercept mobile communications.")
                }
            }
            
            SharedUIComponents.EducationCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("How They Work")
                        .font(.headline)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1. Device broadcasts a stronger signal than nearby towers")
                        Text("2. Your phone connects to the fake tower")
                        Text("3. Device intercepts calls, texts, and data")
                        Text("4. May downgrade your connection to vulnerable protocols")
                    }
                }
            }
            
            SharedUIComponents.EducationCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Common Uses")
                        .font(.headline)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Law enforcement surveillance")
                        Text("• Corporate espionage")
                        Text("• Criminal activity monitoring")
                        Text("• Mass surveillance operations")
                    }
                }
            }
            
            SharedUIComponents.WarningCard {
                Text("IMSI Catchers can intercept your communications, track your location, and compromise your privacy without your knowledge.")
            }
        }
    }
}

struct ProtectionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // How App Protects Section
            EducationHeader(
                title: "How This App Protects You",
                icon: "shield.checkered",
                color: .blue
            )
            
            SharedUIComponents.EducationCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Real-Time Monitoring")
                        .font(.headline)
                    Text("Continuously monitors your cellular connection for suspicious patterns and anomalies that may indicate surveillance equipment.")
                }
            }
            
            SharedUIComponents.EducationCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("2G Detection")
                        .font(.headline)
                    Text("Alerts you when connected to 2G networks, which are vulnerable to interception and commonly used by IMSI catchers.")
                }
            }
            
            SharedUIComponents.EducationCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Carrier Validation")
                        .font(.headline)
                    Text("Checks for unknown or suspicious carriers that may indicate fake base stations.")
                }
            }
            
            SharedUIComponents.EducationCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Pattern Analysis")
                        .font(.headline)
                    Text("Detects unusual network behavior patterns like rapid technology changes that may indicate active surveillance.")
                }
            }
            
            SharedUIComponents.EducationCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Background Monitoring")
                        .font(.headline)
                    Text("Runs monitoring in the background to detect threats even when the app isn't actively open.")
                }
            }
            
            SharedUIComponents.SuccessCard {
                Text("All analysis is performed locally on your device - no data is sent to external servers.")
            }
            
            // Detection Types Section
            EducationHeader(
                title: "Detection Types",
                icon: "magnifyingglass",
                color: .green
            )
            
            ForEach(AnomalyType.allCases, id: \.self) { anomalyType in
                SharedUIComponents.EducationCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(anomalyType.description)
                            .font(.headline)
                        Text(anomalyType.detailedDescription)
                            .font(.body)
                        
                        HStack {
                            Text("Recommended Action:")
                                .font(.caption)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        Text(anomalyType.recommendedAction)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Limitations Section
            EducationHeader(
                title: "App Limitations",
                icon: "exclamationmark.triangle",
                color: .orange
            )
            
            SharedUIComponents.EducationCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Detection Capabilities")
                        .font(.headline)
                    Text("This app has significantly limited detection capabilities compared to dedicated SDR (Software Defined Radio) hardware used by security professionals.")
                }
            }
            
            SharedUIComponents.EducationCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Sophisticated Attacks")
                        .font(.headline)
                    Text("Advanced IMSI catchers may be undetectable by consumer apps. Professional-grade equipment can mimic legitimate carriers perfectly.")
                }
            }
            
            SharedUIComponents.EducationCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("False Positives")
                        .font(.headline)
                    Text("The app may generate false alarms due to legitimate network conditions like poor coverage or carrier maintenance.")
                }
            }
            
            SharedUIComponents.EducationCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("iOS Limitations")
                        .font(.headline)
                    Text("iOS restricts access to low-level cellular information, limiting the app's ability to detect sophisticated threats.")
                }
            }
            
            SharedUIComponents.WarningCard {
                Text("This app should be used as a security awareness tool, not as your sole protection against surveillance.")
            }
        }
    }
}


struct BestPracticesView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Security Best Practices Section
            EducationHeader(
                title: "Security Best Practices",
                icon: "checkmark.shield",
                color: .green
            )
            
            SharedUIComponents.EducationCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("General Security")
                        .font(.headline)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Use VPN when possible")
                        Text("• Avoid public WiFi for sensitive activities")
                        Text("• Keep your device updated")
                        Text("• Use encrypted messaging apps")
                        Text("• Be cautious with app permissions")
                    }
                }
            }
            
            SharedUIComponents.EducationCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("When Alerts Occur")
                        .font(.headline)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Switch to airplane mode")
                        Text("• Move to a different location")
                        Text("• Avoid sensitive communications")
                        Text("• Wait for normal network conditions")
                        Text("• Report suspicious activity if appropriate")
                    }
                }
            }
            
            SharedUIComponents.EducationCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Physical Security")
                        .font(.headline)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Be aware of your surroundings")
                        Text("• Avoid predictable patterns")
                        Text("• Use Faraday bags for sensitive devices")
                        Text("• Consider professional security assessments")
                    }
                }
            }
            
            SharedUIComponents.SuccessCard {
                Text("Remember: Security is about layers of protection, not relying on any single tool.")
            }
            
            // Additional Resources Section
            EducationHeader(
                title: "Additional Resources",
                icon: "book",
                color: .blue
            )
            
            SharedUIComponents.EducationCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Technical Resources")
                        .font(.headline)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Electronic Frontier Foundation (EFF)")
                        Text("• Privacy International")
                        Text("• GSM Security Research")
                        Text("• Mobile Security Best Practices")
                    }
                }
            }
            
            SharedUIComponents.EducationCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Professional Tools")
                        .font(.headline)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• SDR-based detection systems")
                        Text("• Professional security assessments")
                        Text("• Faraday shielding solutions")
                        Text("• Encrypted communication tools")
                    }
                }
            }
            
            SharedUIComponents.EducationCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Legal Considerations")
                        .font(.headline)
                    Text("Be aware of local laws regarding surveillance detection and reporting. Some jurisdictions have specific regulations about IMSI catcher detection.")
                }
            }
        }
    }
}


#Preview {
    EducationView()
}
