import SwiftUI

// Soft error card shown when a backend response fails.
struct ErrorMessageCardView: View {
    let detailMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("응답을 불러오지 못했어요")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.primary)

            if let detailMessage, !detailMessage.isEmpty {
                Text(detailMessage)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary)
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.accentColor.opacity(0.12), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}
