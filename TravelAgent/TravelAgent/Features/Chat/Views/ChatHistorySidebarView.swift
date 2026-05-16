import SwiftUI

// MARK: - Chat History Sidebar
struct ChatHistorySidebarView: View {
    let items: [ChatSession]
    let selectedID: String?
    let onClose: () -> Void
    let onNewChat: () -> Void
    let onSelect: (ChatSession) -> Void
    let onOpenBookingHistory: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("InsighTravel")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.primary)

                Spacer(minLength: 0)

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                        .frame(width: 28, height: 28)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(Circle())
                }
            }

            HStack(spacing: 8) {
                Button(action: onNewChat) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .semibold))
                        Text("새 여행 계획")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.outgoingBubble)
                    .clipShape(Capsule())
                }

                Button(action: onOpenBookingHistory) {
                    HStack(spacing: 8) {
                        Image(systemName: "ticket")
                            .font(.system(size: 12, weight: .semibold))
                        Text("예약 내역")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(Color.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.gray.opacity(0.25), lineWidth: 1))
                }
            }

            Text("최근 여행 기록")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.secondary)

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(items) { item in
                        Button(action: { onSelect(item) }) {
                            HStack {
                                Text(item.title)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.primary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)

                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(item.id == selectedID ? Color.outgoingBubble.opacity(0.12) : Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(item.id == selectedID ? Color.outgoingBubble : Color.gray.opacity(0.15), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, 12)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 20)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.white)
    }
}
