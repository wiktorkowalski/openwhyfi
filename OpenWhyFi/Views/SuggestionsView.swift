import SwiftUI

struct SuggestionsView: View {
    let suggestions: [Suggestion]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Suggestions")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                if suggestions.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("All good")
                            .foregroundStyle(.secondary)
                    }
                    .font(.caption)
                }
            }

            if !suggestions.isEmpty {
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
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: suggestion.icon)
                .foregroundStyle(severityColor)
                .frame(width: 14)
                .font(.caption)

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
