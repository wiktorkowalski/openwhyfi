import SwiftUI

struct SuggestionsView: View {
    let suggestions: [Suggestion]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Suggestions")
                .font(.subheadline)
                .fontWeight(.semibold)

            if suggestions.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Network looks healthy")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            } else {
                ForEach(suggestions.prefix(3)) { suggestion in
                    SuggestionRow(suggestion: suggestion)
                }
            }
        }
        .padding()
        .background(Color(.windowBackgroundColor))
        .cornerRadius(8)
    }
}

struct SuggestionRow: View {
    let suggestion: Suggestion

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: suggestion.icon)
                .foregroundStyle(severityColor)
                .frame(width: 16)

            VStack(alignment: .leading, spacing: 2) {
                Text(suggestion.title)
                    .font(.caption)
                    .fontWeight(.medium)
                Text(suggestion.detail)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var severityColor: Color {
        switch suggestion.severity {
        case .critical: return .red
        case .warning: return .orange
        case .info: return .blue
        }
    }
}
