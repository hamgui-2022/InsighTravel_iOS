import SwiftUI

// Represents the assistant's progress while generating a response.
// Currently not used by ChatView (replaced by PlanningProgressCardView with real step states).
struct LoadingProgressView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("여행을 계획하고 있어요")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.primary)

            VStack(spacing: 12) {
                LoadingStepView(title: "여행 의도 파악 중", status: "완료", isActive: true, isCompleted: true)
                LoadingStepView(title: "계획 생성 중", status: "진행 중", isActive: true, isCompleted: false)
                LoadingStepView(title: "결과 정리 중", status: "대기 중", isActive: false, isCompleted: false)
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
    }
}

struct LoadingStepView: View {
    let title: String
    let status: String
    let isActive: Bool
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(isActive ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: 20, height: 20)
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.accentColor)
                } else if isActive {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 6, height: 6)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.primary)
                Text(status)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.secondary)
            }
        }
    }
}
