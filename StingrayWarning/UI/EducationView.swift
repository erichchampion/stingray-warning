import SwiftUI

struct EducationView: View {
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        NetworkMonitoringView()
                    }
                    .padding()
                    .frame(minHeight: geometry.size.height)
                }
            }
            .navigationTitle("Learn")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Education Content Views

struct NetworkMonitoringView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SharedUIComponents.EducationHeader(
                title: "Network Monitoring",
                icon: "antenna.radiowaves.left.and.right",
                color: .blue
            )
            
            SharedUIComponents.EducationCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("About This App")
                        .font(.headline)
                    Text("This application monitors your cellular network connection and notifies you about network conditions that may affect your device's performance.")
                }
            }
            
            SharedUIComponents.EducationCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Frequent Network Switching")
                        .font(.headline)
                    Text("When your device frequently switches between different network technologies or carriers, it can cause connection issues, dropped calls, and poor data performance. This app alerts you when it detects these rapid network changes so you're aware of potential connectivity problems.")
                }
            }
            
            SharedUIComponents.EducationCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("2G Network Detection")
                        .font(.headline)
                    Text("2G networks provide very slow data speeds and limited functionality compared to modern 4G and 5G networks. When your device connects to a 2G network, you may experience significantly slower internet speeds, longer loading times, and reduced app performance. This app will notify you when you're connected to a 2G network so you're aware of the performance limitations.")
                }
            }
            
            SharedUIComponents.EducationCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Background Monitoring")
                        .font(.headline)
                    Text("The app monitors your network connection in the background, so you'll be notified of these conditions even when the app isn't actively open on your screen.")
                }
            }
            
            SharedUIComponents.SuccessCard {
                Text("All network monitoring is performed locally on your device - no data is sent to external servers.")
            }
        }
    }
}

#Preview {
    EducationView()
}
