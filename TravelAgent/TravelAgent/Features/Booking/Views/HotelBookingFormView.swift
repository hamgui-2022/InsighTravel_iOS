import SwiftUI

struct SelectedHotelSummaryData: Hashable {
    let imageName: String
    let hotelName: String
    let dateRangeText: String
    let priceText: String
    let priceCaptionText: String
    let locationText: String
}

struct HotelBookingFormView: View {
    let selectedHotel: SelectedHotelSummaryData
    @Binding var formData: HotelBookingFormData
    let onBack: () -> Void
    let onProceedToReview: () -> Void

    /// 선택된 호텔의 1박 단가를 기준으로 박수·세금까지 곱해 계산한 결과.
    /// 단가 파싱이 실패하면 selectedHotel.priceText 를 그대로 fallback 으로 사용한다.
    private var priceBreakdown: BookingPriceCalculator.HotelBreakdown {
        BookingPriceCalculator.hotelBreakdown(
            unitPriceText: selectedHotel.priceText,
            checkIn: formData.checkInDate,
            checkOut: formData.checkOutDate
        )
    }

    private var nightlyRateText: String { selectedHotel.priceText }
    private var nightsLineText: String { priceBreakdown.nightsLineText }
    private var nightsPriceText: String { priceBreakdown.nightsPriceText(fallback: selectedHotel.priceText) }
    private var taxAndFeesText: String { priceBreakdown.taxPriceText(fallback: "세금 별도") }
    private var totalPriceText: String { priceBreakdown.totalPriceText(fallback: selectedHotel.priceText) }

    private var journeyChips: [BookingJourneyChip] {
        [
            BookingJourneyChip(iconName: "mappin.and.ellipse", text: selectedHotel.locationText),
            BookingJourneyChip(iconName: "calendar", text: BookingDisplayFormatter.range(from: formData.checkInDate, to: formData.checkOutDate)),
            BookingJourneyChip(iconName: "person.2.fill", text: "성인 \(formData.guestCount)명")
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            BookingStepIndicator(currentStep: .form)
            Divider()

            ScrollView {
                VStack(spacing: 20) {
                    BookingJourneySummaryChips(chips: journeyChips)
                        .padding(.top, 12)

                    SelectedHotelSummaryCard(data: selectedHotel)

                    BookingFormSection(title: "투숙객 정보") {
                        BookingTextFieldRow(
                            title: "이름",
                            placeholder: "홍길동",
                            text: $formData.guestName
                        )
                        BookingTextFieldRow(
                            title: "이메일",
                            placeholder: "example@travel.com",
                            text: $formData.email,
                            keyboardType: .emailAddress
                        )
                        BookingTextFieldRow(
                            title: "전화번호",
                            placeholder: "+82 10-1234-5678",
                            text: $formData.phoneNumber,
                            keyboardType: .phonePad
                        )
                    }

                    BookingFormSection(title: "숙박 정보") {
                        BookingDateFieldRow(
                            title: "체크인",
                            date: $formData.checkInDate
                        )
                        BookingDateFieldRow(
                            title: "체크아웃",
                            date: $formData.checkOutDate
                        )
                        GuestCountStepper(
                            title: "투숙 인원",
                            count: $formData.guestCount
                        )
                    }

                    HotelPriceSummaryCard(
                        nightsText: nightsLineText,
                        nightsPriceText: nightsPriceText,
                        taxText: "세금 및 수수료",
                        taxPriceText: taxAndFeesText,
                        totalText: "총 금액",
                        totalPriceText: totalPriceText
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
            HStack(spacing: 12) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.primary)
                        .frame(width: 36, height: 36)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(Circle())
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("호텔 예약")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.primary)
                    Text("호텔 선택 → 예약 정보 → 검토")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }

                Spacer(minLength: 0)
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
                Text("총 금액 \(totalPriceText)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Spacer(minLength: 0)
            }

            Button(action: onProceedToReview) {
                HStack(spacing: 8) {
                    Spacer(minLength: 0)
                    Text("예약 검토로 이동")
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

struct SelectedHotelSummaryCard: View {
    let data: SelectedHotelSummaryData

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                Image(data.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()

                LinearGradient(
                    colors: [Color.black.opacity(0.0), Color.black.opacity(0.45)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text(data.hotelName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.white)
                    Text(data.locationText)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.9))
                }
                .padding(16)
            }
            .frame(height: 200)

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(data.dateRangeText)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                    Text(data.priceText)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.primary)
                }

                Spacer(minLength: 0)

                Text(data.priceCaptionText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
            .padding(16)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
    }
}

struct GuestCountStepper: View {
    let title: String
    @Binding var count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.secondary)

            HStack(spacing: 12) {
                Text("성인")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.primary)

                Spacer(minLength: 0)

                Button(action: decrement) {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.primary)
                        .frame(width: 36, height: 36)
                        .background(Color(white: 0.93))
                        .clipShape(Circle())
                }
                .disabled(count <= 1)

                Text("\(count)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .frame(minWidth: 40)

                Button(action: increment) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.primary)
                        .frame(width: 36, height: 36)
                        .background(Color(white: 0.93))
                        .clipShape(Circle())
                }
            }
            .padding(10)
            .background(Color(white: 0.96))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private func decrement() {
        count = max(1, count - 1)
    }

    private func increment() {
        count += 1
    }
}

struct HotelPriceSummaryCard: View {
    let nightsText: String
    let nightsPriceText: String
    let taxText: String
    let taxPriceText: String
    let totalText: String
    let totalPriceText: String

    var body: some View {
        VStack(spacing: 12) {
            priceRow(title: nightsText, value: nightsPriceText, isEmphasized: false)
            priceRow(title: taxText, value: taxPriceText, isEmphasized: false)

            Divider()

            priceRow(title: totalText, value: totalPriceText, isEmphasized: true)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private func priceRow(title: String, value: String, isEmphasized: Bool) -> some View {
        HStack {
            Text(title)
                .font(.system(size: isEmphasized ? 14 : 13, weight: .semibold))
                .foregroundStyle(isEmphasized ? Color.primary : Color.secondary)
            Spacer(minLength: 0)
            Text(value)
                .font(.system(size: isEmphasized ? 18 : 14, weight: .bold))
                .foregroundStyle(isEmphasized ? Color.outgoingBubble : Color.primary)
        }
    }
}
