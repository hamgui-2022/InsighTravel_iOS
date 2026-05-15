import SwiftUI

// MARK: - Hotel Recommendation Card

struct HotelAmenity: Hashable {
    let iconName: String
    let title: String
}

struct HotelRecommendationData: Hashable {
    let imageName: String
    let badgeText: String
    let hotelName: String
    let locationText: String
    let priceText: String
    let priceCaptionText: String
    let amenities: [HotelAmenity]
    let buttonTitle: String
}

struct HotelRecommendationCard: View {
    let data: HotelRecommendationData
    let onTapCTA: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            heroSection

            hotelInfoSection

            Divider()
                .padding(.horizontal, 16)

            amenitiesSection

            Divider()
                .padding(.horizontal, 16)

            Button(action: onTapCTA) {
                HStack(spacing: 8) {
                    Spacer(minLength: 0)
                    Text(data.buttonTitle)
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
            .padding(16)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.1), radius: 14, x: 0, y: 8)
    }

    private var heroSection: some View {
        ZStack(alignment: .topTrailing) {
            Image(data.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 240)
                .clipped()

            Text(data.badgeText)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.outgoingBubble)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.92))
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
                .padding(12)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var hotelInfoSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(data.hotelName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.primary)

                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                    Text(data.locationText)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 4) {
                Text(data.priceText)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.outgoingBubble)
                Text(data.priceCaptionText)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var amenitiesSection: some View {
        HStack(spacing: 0) {
            ForEach(data.amenities.prefix(3), id: \.self) { amenity in
                VStack(spacing: 6) {
                    Image(systemName: amenity.iconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.outgoingBubble)
                    Text(amenity.title)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - Hotel Booking Confirmation Card

struct HotelBookingConfirmationData: Hashable {
    let reservationID: String
    let imageName: String
    let confirmationBadgeText: String
    let hotelName: String
    let stayDateText: String
    let totalPaidLabel: String
    let totalPaidText: String
    let paymentInfoText: String
    let paymentMethodText: String
}

struct HotelBookingConfirmedCard: View {
    let data: HotelBookingConfirmationData

    var body: some View {
        VStack(spacing: 16) {
            successHeader

            confirmationSummaryCard
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.1), radius: 14, x: 0, y: 8)
    }

    private var successHeader: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.outgoingBubble.opacity(0.12))
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Color.outgoingBubble)
            }
            .frame(width: 56, height: 56)

            Text("예약이 완료되었어요")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.primary)

            Text("예약번호: \(data.reservationID)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }

    private var confirmationSummaryCard: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                Image(data.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 190)
                    .clipped()

                Text(data.confirmationBadgeText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.outgoingBubble)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.92))
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
                    .padding(12)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            VStack(alignment: .leading, spacing: 10) {
                Text(data.hotelName)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.primary)

                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                    Text(data.stayDateText)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }

                Divider()

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(data.totalPaidLabel)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.secondary)
                        Text(data.totalPaidText)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Color.primary)
                    }

                    Spacer(minLength: 0)

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(data.paymentInfoText)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.secondary)
                        Text(data.paymentMethodText)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.outgoingBubble)
                    }
                }
            }
            .padding(16)
        }
        .background(Color(white: 0.97))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
