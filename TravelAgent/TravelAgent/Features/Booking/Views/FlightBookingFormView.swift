import SwiftUI

struct SelectedFlightSummaryData: Hashable {
    let airlineName: String
    let priceText: String
    let routeText: String
    let departureCity: String
    let arrivalCity: String
    let durationText: String
}

struct BookingFormView: View {
    let selectedFlight: SelectedFlightSummaryData
    let onBack: () -> Void
    let onReviewBooking: () -> Void

    @State private var passengerName = ""
    @State private var birthDate = Date()
    @State private var nationality = "대한민국"
    @State private var passportNumber = ""
    @State private var passportExpiry = Date()
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var departureDate = Date()
    @State private var returnDate = Date().addingTimeInterval(60 * 60 * 24 * 7)
    @State private var passengerCount = 1

    private let nationalityOptions = ["대한민국", "일본", "미국", "영국", "프랑스"]

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView {
                VStack(spacing: 24) {
                    SelectedFlightSummaryCard(data: selectedFlight)

                    BookingFormSection(title: "탑승자 정보") {
                        BookingTextFieldRow(
                            title: "탑승자 이름",
                            placeholder: "여권과 동일한 이름 입력",
                            text: $passengerName
                        )
                        BookingDateFieldRow(
                            title: "생년월일",
                            date: $birthDate
                        )
                        BookingPickerRow(
                            title: "국적",
                            selection: $nationality,
                            options: nationalityOptions
                        )
                        BookingTextFieldRow(
                            title: "여권 번호",
                            placeholder: "여권 번호 입력",
                            text: $passportNumber
                        )
                        BookingDateFieldRow(
                            title: "여권 만료일",
                            date: $passportExpiry
                        )
                    }

                    BookingFormSection(title: "연락처 정보") {
                        BookingTextFieldRow(
                            title: "이메일",
                            placeholder: "example@travel.com",
                            text: $email,
                            keyboardType: .emailAddress
                        )
                        BookingTextFieldRow(
                            title: "전화번호",
                            placeholder: "+82 10-1234-5678",
                            text: $phoneNumber,
                            keyboardType: .phonePad
                        )
                    }

                    BookingFormSection(title: "예약 정보") {
                        BookingDateFieldRow(
                            title: "출발일",
                            date: $departureDate
                        )
                        BookingDateFieldRow(
                            title: "귀국일",
                            date: $returnDate
                        )
                        PassengerCountStepper(
                            title: "탑승 인원",
                            count: $passengerCount
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .background(Color.chatBackground)
        .safeAreaInset(edge: .bottom) {
            bookingCTA
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
                    Text("예약 정보 입력")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.primary)
                    Text("항공편 선택 → 예약 정보 → 검토")
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

    private var bookingCTA: some View {
        VStack(spacing: 12) {
            HStack {
                Text("총 예상 금액 \(selectedFlight.priceText)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Spacer(minLength: 0)
            }

            Button(action: onReviewBooking) {
                HStack(spacing: 8) {
                    Spacer(minLength: 0)
                    Text("예약 검토하기")
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

struct SelectedFlightSummaryCard: View {
    let data: SelectedFlightSummaryData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("선택한 항공편")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.secondary)

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(data.airlineName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.primary)

                    HStack(spacing: 6) {
                        Image(systemName: "airplane")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.outgoingBubble)
                        Text(data.routeText)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.primary)
                    }

                    Text("\(data.departureCity) · \(data.arrivalCity) · \(data.durationText)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }

                Spacer(minLength: 0)

                Text(data.priceText)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.primary)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
    }
}
