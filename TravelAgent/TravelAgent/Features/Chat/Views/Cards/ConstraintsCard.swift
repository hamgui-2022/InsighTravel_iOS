import SwiftUI

// Displays required conditions and softer preferences extracted from the conversation.
// Currently not used by ChatView; kept as a placeholder for future structured constraint data.
struct ConstraintsCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("여행 조건")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.primary)

            VStack(alignment: .leading, spacing: 8) {
                Text("필수 조건")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.secondary)

                HStack(spacing: 8) {
                    ConstraintChipView(text: "고정된 일정", icon: "calendar")
                    ConstraintChipView(text: "예산 제한", icon: "banknote")
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("선호 사항")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.secondary)

                HStack(spacing: 8) {
                    PreferenceChipView(text: "미식 중심", icon: "fork.knife")
                    PreferenceChipView(text: "여유로운 일정", icon: "leaf")
                }

                HStack(spacing: 8) {
                    PreferenceChipView(text: "경치 좋은 장소", icon: "mountain.2")
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
    }
}

struct ConstraintChipView: View {
    let text: String
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.accentColor)
            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.accentColor)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white)
        .clipShape(Capsule())
    }
}

struct PreferenceChipView: View {
    let text: String
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.secondary)
            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.85))
        .clipShape(Capsule())
    }
}
