import SwiftUI

struct HotelBookingReviewData: Hashable {
    let hotelName: String
    let hotelDisplayName: String
    let hotelImageName: String
    let locationText: String
    let availabilityBadgeText: String
    let checkInDate: String
    let checkInNote: String
    let checkOutDate: String
    let checkOutNote: String
    let guestSummaryText: String
    let totalPriceText: String
    let nightCountText: String
    let trustBadgeText: String
    let cancellationPolicyText: String
}

struct HotelBookingReviewView: View {
    let data: HotelBookingReviewData
    let onBack: () -> Void
    let onConfirmBooking: () -> Void
    let onEditAccommodation: () -> Void
    let onEditDates: () -> Void
    let onEditGuests: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView {
                VStack(spacing: 24) {
                    HotelReviewHeroCard(
                        imageName: data.hotelImageName,
                        badgeText: data.availabilityBadgeText,
                        hotelName: data.hotelName
                    )

                    BookingDetailsSummaryCard(
                        hotelDisplayName: data.hotelDisplayName,
                        locationText: data.locationText,
                        checkInDate: data.checkInDate,
                        checkInNote: data.checkInNote,
                        checkOutDate: data.checkOutDate,
                        checkOutNote: data.checkOutNote,
                        guestSummaryText: data.guestSummaryText,
                        onEditAccommodation: onEditAccommodation,
                        onEditDates: onEditDates,
                        onEditGuests: onEditGuests
                    )

                    HotelPriceTotalCard(
                        totalLabel: "총 금액 (세금 포함)",
                        totalPriceText: data.totalPriceText,
                        nightCountText: data.nightCountText,
                        trustBadgeText: data.trustBadgeText
                    )

                    PolicyNoticeCard(
                        text: data.cancellationPolicyText,
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

struct HotelReviewHeroCard: View {
    let imageName: String
    let badgeText: String
    let hotelName: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 220)
                .clipped()

            LinearGradient(
                colors: [Color.black.opacity(0.0), Color.black.opacity(0.5)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(badgeText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.outgoingBubble.opacity(0.9))
                    .clipShape(Capsule())

                Text(hotelName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.white)
            }
            .padding(16)
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
    }
}

struct BookingDetailsSummaryCard: View {
    let hotelDisplayName: String
    let locationText: String
    let checkInDate: String
    let checkInNote: String
    let checkOutDate: String
    let checkOutNote: String
    let guestSummaryText: String
    let onEditAccommodation: () -> Void
    let onEditDates: () -> Void
    let onEditGuests: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            accommodationBlock

            Divider()

            datesBlock

            Divider()

            guestsBlock
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private var accommodationBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            ReviewSummaryHeader(title: "숙소", actionTitle: "수정", onTap: onEditAccommodation)

            Text(hotelDisplayName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.primary)

            HStack(spacing: 6) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Text(locationText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
        }
    }

    private var datesBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            ReviewSummaryHeader(title: "일정", actionTitle: "수정", onTap: onEditDates)

            HStack(spacing: 12) {
                ReviewSummaryColumn(
                    title: "체크인",
                    value: checkInDate,
                    note: checkInNote
                )

                ReviewSummaryColumn(
                    title: "체크아웃",
                    value: checkOutDate,
                    note: checkOutNote
                )
            }
        }
    }

    private var guestsBlock: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.outgoingBubble)
                .frame(width: 34, height: 34)
                .background(Color.outgoingBubble.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text("투숙 인원")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Text(guestSummaryText)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.primary)
            }

            Spacer(minLength: 0)

            Button(action: onEditGuests) {
                Text("수정")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.outgoingBubble)
            }
        }
    }
}

struct ReviewSummaryHeader: View {
    let title: String
    let actionTitle: String
    let onTap: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.secondary)
            Spacer(minLength: 0)
            Button(action: onTap) {
                Text(actionTitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.outgoingBubble)
            }
        }
    }
}

struct ReviewSummaryColumn: View {
    let title: String
    let value: String
    let note: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.secondary)
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.primary)
            Text(note)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct HotelPriceTotalCard: View {
    let totalLabel: String
    let totalPriceText: String
    let nightCountText: String
    let trustBadgeText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(totalLabel)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(totalPriceText)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.outgoingBubble)
                Text(nightCountText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }

            Text(trustBadgeText)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.green)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.12))
                .clipShape(Capsule())
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct PolicyNoticeCard: View {
    let text: String
    let linkText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.outgoingBubble)
                Text("안내")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.primary)
            }

            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.secondary)

            Button(action: {}) {
                Text(linkText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.outgoingBubble)
            }
        }
        .padding(16)
        .background(Color(white: 0.95))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct BookingSubmittingView: View {
    var body: some View {
        ZStack {
            Color.chatBackground.ignoresSafeArea()
            VStack(spacing: 12) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Color.outgoingBubble)
                Text("예약을 진행하고 있어요")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.primary)
                Text("잠시만 기다려주세요")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        }
    }
}
