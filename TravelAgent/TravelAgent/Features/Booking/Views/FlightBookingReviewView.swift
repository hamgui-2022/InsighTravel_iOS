import SwiftUI

struct FlightBookingReviewData: Hashable {
    let summary: SelectedFlightSummaryData
    let routeText: String
    let dateText: String
    let passengerText: String
    let totalPriceText: String
}

struct FlightBookingReviewView: View {
    let data: FlightBookingReviewData
    let onBack: () -> Void
    let onConfirmBooking: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView {
                VStack(spacing: 24) {
                    SelectedFlightSummaryCard(data: data.summary)

                    HotelPriceTotalCard(
                        totalLabel: "총 결제 금액",
                        totalPriceText: data.totalPriceText,
                        nightCountText: "왕복 기준",
                        trustBadgeText: "안심 예약"
                    )

                    PolicyNoticeCard(
                        text: "예약 확정 전에는 무료 취소가 가능합니다. 확정 후에는 항공사 규정을 따릅니다.",
                        linkText: "이용약관 보기"
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .background(Color.chatBackground)
        .safeAreaInset(edge: .bottom) {
            bottomCTA
        }
    }

    private var topBar: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.primary)
                        .frame(width: 36, height: 36)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(Circle())
                }

                Spacer(minLength: 0)

                Text("예약 검토")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.primary)

                Spacer(minLength: 0)

                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                        .frame(width: 36, height: 36)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            Divider()
        }
        .background(Color.white)
    }

    private var bottomCTA: some View {
        VStack(spacing: 12) {
            HStack {
                Text("결제 전 마지막으로 내용을 확인하세요")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Spacer(minLength: 0)
            }

            Button(action: onConfirmBooking) {
                HStack(spacing: 8) {
                    Spacer(minLength: 0)
                    Text("예약 확정하기")
                        .font(.system(size: 16, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                    Spacer(minLength: 0)
                }
                .foregroundStyle(Color.white)
                .frame(height: 54)
                .background(Color.outgoingBubble)
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: -2)
    }
}
