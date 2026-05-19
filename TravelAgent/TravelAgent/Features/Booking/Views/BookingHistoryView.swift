import SwiftUI

struct BookingHistoryView: View {
    @StateObject private var viewModel: BookingHistoryViewModel
    @Environment(\.dismiss) private var dismiss

    init(sessionID: String) {
        _viewModel = StateObject(wrappedValue: BookingHistoryViewModel(sessionID: sessionID))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                tabBar
                Divider()

                if viewModel.isLoading && viewModel.currentItems.isEmpty {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if viewModel.currentItems.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .background(Color.chatBackground)
            .navigationTitle("예약 내역")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("닫기") { dismiss() }
                }
            }
            .task { await viewModel.onAppear() }
            .refreshable { await viewModel.loadCurrentTab() }
            .alert(
                "오류",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                ),
                actions: {
                    Button("확인", role: .cancel) { viewModel.errorMessage = nil }
                },
                message: { Text(viewModel.errorMessage ?? "") }
            )
        }
    }

    private var tabBar: some View {
        HStack(spacing: 8) {
            ForEach(BookingHistoryTab.allCases) { tab in
                Button {
                    viewModel.switchTab(tab)
                } label: {
                    Text(tab.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(viewModel.tab == tab ? Color.white : Color.primary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(viewModel.tab == tab ? Color.outgoingBubble : Color.white)
                        )
                        .overlay(
                            Capsule().stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.headerBackground)
    }

    private var list: some View {
        List {
            ForEach(viewModel.currentItems) { booking in
                NavigationLink {
                    BookingHistoryDetailView(booking: booking, viewModel: viewModel)
                } label: {
                    BookingHistoryRow(booking: booking)
                }
                .listRowBackground(Color.white)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.chatBackground)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Spacer()
            Image(systemName: "tray")
                .font(.system(size: 36))
                .foregroundStyle(Color.gray.opacity(0.5))
            Text(viewModel.tab == .active ? "예약 내역이 없습니다." : "취소된 예약 내역이 없습니다.")
                .font(.system(size: 14))
                .foregroundStyle(Color.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

private struct BookingHistoryRow: View {
    let booking: BookingHistoryItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text(booking.title ?? "예약 내역")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .lineLimit(2)

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 4) {
                    BookingTypeBadge(type: booking.bookingType)
                    BookingStatusBadge(status: booking.status)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                metaRow("예약번호", booking.bookingCode)
                metaRow("목적지", booking.destination ?? "-")
                metaRow("일정", scheduleText)
                metaRow("생성일", BookingHistoryFormatter.dateTime(booking.createdAt))
            }
        }
        .padding(.vertical, 4)
    }

    private var scheduleText: String {
        let start = BookingHistoryFormatter.date(booking.startDate)
        let end = BookingHistoryFormatter.date(booking.endDate)
        return "\(start) ~ \(end)"
    }

    private func metaRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.secondary)
                .frame(width: 56, alignment: .leading)
            Text(value)
                .font(.system(size: 12))
                .foregroundStyle(Color.primary)
                .lineLimit(2)
        }
    }
}

struct BookingTypeBadge: View {
    let type: BookingItemType

    var body: some View {
        Text(type == .hotel ? "숙소" : "항공")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(Color.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(type == .hotel ? Color.outgoingBubble : Color.weatherHeader))
    }
}

struct BookingStatusBadge: View {
    let status: BookingHistoryStatus

    var body: some View {
        Text(status == .confirmed ? "예약 완료" : "취소됨")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(status == .confirmed ? Color.white : Color.primary)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule().fill(status == .confirmed ? Color.green : Color.gray.opacity(0.3))
            )
    }
}

enum BookingHistoryFormatter {
    private static let isoDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "ko_KR")
        return f
    }()

    private static let displayDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy년 M월 d일"
        f.locale = Locale(identifier: "ko_KR")
        return f
    }()

    private static let displayDateTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy년 M월 d일 HH:mm"
        f.locale = Locale(identifier: "ko_KR")
        return f
    }()

    static func date(_ raw: String?) -> String {
        guard let raw, !raw.isEmpty else { return "-" }
        if let d = isoDateFormatter.date(from: raw) {
            return displayDateFormatter.string(from: d)
        }
        return raw
    }

    static func dateTime(_ raw: String?) -> String {
        guard let raw, !raw.isEmpty else { return "-" }
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = iso.date(from: raw) {
            return displayDateTimeFormatter.string(from: d)
        }
        iso.formatOptions = [.withInternetDateTime]
        if let d = iso.date(from: raw) {
            return displayDateTimeFormatter.string(from: d)
        }
        return raw
    }
}
