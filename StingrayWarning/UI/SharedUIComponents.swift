import SwiftUI

/// Shared UI components used across the app to maintain consistency and reduce duplication
struct SharedUIComponents {
    
    // MARK: - Threat Level Badge
    struct ThreatLevelBadge: View {
        let level: NetworkThreatLevel
        
        var body: some View {
            Text(level.rawValue.uppercased())
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(level.color)
                .cornerRadius(4)
        }
    }
    
    // MARK: - Status Indicator
    struct StatusIndicator: View {
        let isActive: Bool
        let title: String
        
        var body: some View {
            HStack(spacing: 8) {
                Circle()
                    .fill(isActive ? .green : .red)
                    .frame(width: 8, height: 8)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(isActive ? .green : .red)
            }
        }
    }
    
    // MARK: - Education Header
    struct EducationHeader: View {
        let title: String
        let icon: String
        let color: Color
        
        var body: some View {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
        }
    }
    
    // MARK: - Education Card
    struct EducationCard<Content: View>: View {
        let content: Content
        
        init(@ViewBuilder content: () -> Content) {
            self.content = content()
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                content
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Warning Card
    struct WarningCard<Content: View>: View {
        let content: Content
        
        init(@ViewBuilder content: () -> Content) {
            self.content = content()
        }
        
        var body: some View {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                content
                    .font(.body)
                    .fontWeight(.medium)
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Success Card
    struct SuccessCard<Content: View>: View {
        let content: Content
        
        init(@ViewBuilder content: () -> Content) {
            self.content = content()
        }
        
        var body: some View {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                content
                    .font(.body)
                    .fontWeight(.medium)
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Action Button
    struct ActionButton: View {
        let title: String
        let icon: String
        let color: Color
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.title2)
                    Text(title)
                        .font(.caption)
                }
                .foregroundColor(color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(color.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Statistic Item
    struct StatisticItem: View {
        let title: String
        let value: String
        let color: Color
        
        var body: some View {
            VStack(spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Empty State View
    struct EmptyStateView: View {
        let icon: String
        let title: String
        let message: String
        
        init(icon: String = "clock", title: String = "No Events Found", message: String = "No events match your current filters. Try adjusting the time range or threat level filter.") {
            self.icon = icon
            self.title = title
            self.message = message
        }
        
        var body: some View {
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 50))
                    .foregroundColor(.secondary)
                
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
    }
}

// MARK: - NetworkThreatLevel Color Extension
extension NetworkThreatLevel {
    var color: Color {
        switch self {
        case .none: return .green
        case .low: return .yellow
        case .medium: return .orange
        case .high: return .red
        case .critical: return .purple
        }
    }
}
