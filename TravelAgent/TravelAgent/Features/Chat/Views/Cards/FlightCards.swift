import SwiftUI

// MARK: - Flight Search Progress

struct FlightSearchData: Identifiable, Hashable {
    let id = UUID()
    let departureCode: String
    let departureCity: String
    let arrivalCode: String
    let arrivalCity: String
    let dateRange: String
    let travelers: String
    let steps: [FlightSearchStep]
}

struct FlightSearchStep: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let state: StepState
}

struct FlightSearchProgressCard: View {
    let data: FlightSearchData

    private var progressValue: CGFloat {
        guard !data.steps.isEmpty else { return 0 }
        let completedCount = data.steps.filter { $0.state == .completed }.count
        return CGFloat(completedCount) / CGFloat(data.steps.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            progressBar

            HStack(alignment: .center, spacing: 16) {
                airportInfo(code: data.departureCode, city: data.departureCity)

                VStack(spacing: 4) {
                    Image(systemName: "airplane")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                    Text("직항 우선")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }
                .frame(maxWidth: .infinity)

                airportInfo(code: data.arrivalCode, city: data.arrivalCity)
            }

            dateTravelerPill

            VStack(alignment: .leading, spacing: 10) {
                ForEach(data.steps) { step in
                    HStack(spacing: 10) {
                        stepIndicator(for: step.state)
                        Text(step.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(step.state == .pending ? Color.secondary : Color.primary)
                        Spacer(minLength: 0)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
    }

    private var progressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.blue.opacity(0.15))
                Capsule()
                    .fill(Color.blue)
                    .frame(width: max(8, proxy.size.width * progressValue))
            }
        }
        .frame(height: 4)
    }

    private func airportInfo(code: String, city: String) -> some View {
        VStack(spacing: 2) {
            Text(code)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.primary)
            Text(city)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var dateTravelerPill: some View {
        HStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Text(data.dateRange)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }

            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 1.5, height: 16)

            HStack(spacing: 6) {
                Image(systemName: "person")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Text(data.travelers)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.12))
        .clipShape(Capsule())
    }

    @ViewBuilder
    private func stepIndicator(for state: StepState) -> some View {
        switch state {
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.blue)
        case .loading:
            ProgressView()
                .progressViewStyle(.circular)
                .tint(Color.blue)
                .frame(width: 16, height: 16)
        case .pending:
            Image(systemName: "circle")
                .font(.system(size: 16))
                .foregroundStyle(Color.gray.opacity(0.5))
        }
    }
}

// MARK: - Flight Results Summary

struct FlightResultsSummaryData: Hashable {
    let badgeText: String
    let heroImageName: String
    let resultCountText: String
    let priceSummaryText: String
    let routeText: String
    let dateText: String
    let cheapestLabel: String
    let airlineText: String
    let priceText: String
    let priceCaptionText: String
    let buttonTitle: String
}

struct FlightResultsSummaryCard: View {
    let data: FlightResultsSummaryData
    let onTapCTA: () -> Void

    init(
        data: FlightResultsSummaryData,
        onTapCTA: @escaping () -> Void = {}
    ) {
        self.data = data
        self.onTapCTA = onTapCTA
    }

    var body: some View {
        VStack(spacing: 0) {
            heroSection

            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(data.resultCountText) · \(data.priceSummaryText)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.primary)

                    Text("\(data.routeText) | \(data.dateText)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }

                cheapestOptionBox

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
                    .frame(height: 50)
                    .background(Color.outgoingBubble)
                    .clipShape(Capsule())
                }
            }
            .padding(16)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }

    private var heroSection: some View {
        ZStack(alignment: .topLeading) {
            Image(data.heroImageName)
                .resizable()
                .scaledToFill()
                .frame(height: 170)
                .clipped()

            LinearGradient(
                colors: [Color.white.opacity(0.0), Color.white.opacity(0.65)],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: 170)

            badgeView
                .padding(12)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
        )
    }

    private var badgeView: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.blue)
            Text(data.badgeText)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.blue)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.9))
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
    }

    private var cheapestOptionBox: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white)
                Image(systemName: "airplane")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.outgoingBubble)
            }
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(data.cheapestLabel)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Text(data.airlineText)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.primary)
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 2) {
                Text(data.priceText)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.outgoingBubble)
                Text(data.priceCaptionText)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
        }
        .padding(12)
        .background(Color(white: 0.95))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Flight Booking Confirmation Card

struct FlightBookingConfirmationData: Hashable {
    let reservationID: String
    let heroImageName: String
    let confirmationBadgeText: String
    let airlineName: String
    let routeText: String
    let dateText: String
    let passengerText: String
    let totalPaidLabel: String
    let totalPaidText: String
    let paymentInfoText: String
    let paymentMethodText: String
}

struct FlightBookingConfirmedCard: View {
    let data: FlightBookingConfirmationData

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

            Text("항공권 예약이 완료되었어요")
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
                Image(data.heroImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 170)
                    .clipped()

                VStack(alignment: .leading, spacing: 6) {
                    Text(data.routeText)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.white)
                    Text(data.airlineName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(
                    LinearGradient(
                        colors: [Color.black.opacity(0.0), Color.black.opacity(0.45)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 80)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                )

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
                Text(data.airlineName)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.primary)

                Text(data.routeText)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.primary)

                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                    Text(data.dateText)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }

                Text(data.passengerText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)

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
