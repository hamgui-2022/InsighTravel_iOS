import SwiftUI

struct BookingHistoryDetailView: View {
    let booking: BookingHistoryItem
    @ObservedObject var viewModel: BookingHistoryViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showCancelConfirm = false

    private var item: BookingHistoryDetailItem? { booking.payload.item }
    private var passenger: BookingHistoryPassenger? { booking.payload.passengerInfo }
    private var isCancelled: Bool { booking.status == .cancelled }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                cancelButton

                if booking.bookingType == .flight {
                    flightSections
                } else {
                    hotelSections
                }
            }
            .padding(16)
        }
        .background(Color.chatBackground)
        .navigationTitle(booking.bookingType == .flight ? "항공 예약" : "숙소 예약")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "예약 \(booking.bookingCode)를 취소할까요?",
            isPresented: $showCancelConfirm,
            titleVisibility: .visible
        ) {
            Button("예약 취소", role: .destructive) {
                Task {
                    await viewModel.cancelBooking(booking)
                    if viewModel.errorMessage == nil {
                        dismiss()
                    }
                }
            }
            Button("닫기", role: .cancel) {}
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(booking.title ?? "예약")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.primary)
            HStack(spacing: 8) {
                BookingTypeBadge(type: booking.bookingType)
                BookingStatusBadge(status: booking.status)
                Spacer()
            }
            Text(booking.destination ?? "-")
                .font(.system(size: 13))
                .foregroundStyle(Color.secondary)

            HStack {
                Text("예약번호")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Spacer()
                Text(booking.bookingCode)
                    .font(.system(size: 13, weight: .semibold).monospaced())
                    .foregroundStyle(Color.primary)
            }
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

    private var cancelButton: some View {
        Button {
            showCancelConfirm = true
        } label: {
            HStack {
                if viewModel.isCancelling {
                    ProgressView()
                        .tint(.white)
                }
                Text(isCancelled ? "이미 취소됨" : "예약 취소")
                    .font(.system(size: 15, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isCancelled ? Color.gray.opacity(0.4) : Color.red)
            )
            .foregroundStyle(Color.white)
        }
        .buttonStyle(.plain)
        .disabled(isCancelled || viewModel.isCancelling)
    }

    // MARK: - Flight

    private var flightSections: some View {
        VStack(alignment: .leading, spacing: 16) {
            Section_("예약 정보") {
                detailGrid([
                    ("구간", "\(item?.origin ?? "-") → \(item?.destinationKR ?? item?.destination ?? "-")"),
                    ("출국일", BookingHistoryFormatter.date(booking.startDate)),
                    ("귀국일", BookingHistoryFormatter.date(booking.endDate)),
                    ("항공사", item?.airline ?? "-"),
                    ("편명", item?.flightNumber ?? "-"),
                    ("가격", item?.price ?? "-"),
                ])
                tagRow([
                    "수하물 \(item?.baggage ?? "-")",
                    "좌석 \(item?.cabin ?? "-")",
                    item?.stops ?? "-",
                ])
            }

            Section_("가는편") {
                routeBox(
                    leftTime: item?.depTime,
                    leftAirport: item?.origin,
                    center: item?.duration,
                    rightTime: item?.depArrTime,
                    rightAirport: item?.destinationKR ?? item?.destination
                )
            }

            if item?.isRoundtrip == true || passenger?.isRoundtrip == true {
                Section_("오는편") {
                    routeBox(
                        leftTime: item?.retDepTime,
                        leftAirport: item?.destinationKR ?? item?.destination,
                        center: item?.retDuration,
                        rightTime: item?.retArrTime,
                        rightAirport: item?.origin
                    )
                }
            }

            Section_("탑승객 정보") {
                detailGrid([
                    ("이름", passenger?.name ?? "-"),
                    ("생년월일", passenger?.birth ?? "-"),
                    ("국적", passenger?.nationality ?? "-"),
                    ("여권번호", passenger?.passport ?? "-"),
                    ("이메일", passenger?.email ?? "-"),
                    ("연락처", passenger?.phone ?? "-"),
                    ("인원", "\(passenger?.guests ?? "-")명"),
                ])
            }
        }
    }

    // MARK: - Hotel

    private var hotelSections: some View {
        VStack(alignment: .leading, spacing: 16) {
            Section_("숙소 정보") {
                detailGrid([
                    ("숙소명", item?.name ?? "-"),
                    ("지역", booking.destination ?? "-"),
                    ("체크인", BookingHistoryFormatter.date(booking.startDate)),
                    ("체크아웃", BookingHistoryFormatter.date(booking.endDate)),
                    ("가격", item?.price ?? "-"),
                    ("평점", item?.rating.map { String(format: "%.1f", $0) } ?? "-"),
                ])
            }

            Section_("투숙객 정보") {
                detailGrid([
                    ("이름", passenger?.name ?? "-"),
                    ("이메일", passenger?.email ?? "-"),
                    ("연락처", passenger?.phone ?? "-"),
                    ("인원", "\(passenger?.guests ?? "-")명"),
                ])
            }
        }
    }

    // MARK: - Building blocks

    private func detailGrid(_ rows: [(String, String)]) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(alignment: .top, spacing: 12) {
                    Text(row.0)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                        .frame(width: 80, alignment: .leading)
                    Text(row.1)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 8)
                Divider()
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func tagRow(_ tags: [String]) -> some View {
        HStack(spacing: 8) {
            ForEach(Array(tags.enumerated()), id: \.offset) { _, tag in
                Text(tag)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.gray.opacity(0.15)))
            }
            Spacer()
        }
    }

    private func routeBox(
        leftTime: String?,
        leftAirport: String?,
        center: String?,
        rightTime: String?,
        rightAirport: String?
    ) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(leftTime ?? "-")
                    .font(.system(size: 18, weight: .bold))
                Text(leftAirport ?? "-")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.secondary)
            }
            Spacer()
            Text(center ?? "-")
                .font(.system(size: 11))
                .foregroundStyle(Color.secondary)
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(rightTime ?? "-")
                    .font(.system(size: 18, weight: .bold))
                Text(rightAirport ?? "-")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.secondary)
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    @ViewBuilder
    private func Section_<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.primary)
            content()
        }
    }
}
