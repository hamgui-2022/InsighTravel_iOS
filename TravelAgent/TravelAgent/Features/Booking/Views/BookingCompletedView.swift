import SwiftUI

// MARK: - Shared layout pieces

private struct CompletedTopBar: View {
    let title: String
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer(minLength: 0)
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.primary)
                Spacer(minLength: 0)
            }
            .overlay(alignment: .trailing) {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
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
}

private struct CompletedHeroBlock: View {
    let title: String

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 96, height: 96)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundStyle(Color.green)
            }

            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ReservationIDBlock: View {
    let label: String
    let id: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.secondary)
            Text(id)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.outgoingBubble)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.outgoingBubble.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

private struct CompletedDetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.secondary)
                .frame(width: 90, alignment: .leading)
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct CompletedDetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.primary)
            VStack(spacing: 10) {
                content
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

private struct CompletedBottomCTA: View {
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onConfirm) {
                HStack(spacing: 8) {
                    Spacer(minLength: 0)
                    Text("확인")
                        .font(.system(size: 16, weight: .semibold))
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

private enum CompletedDateFormatter {
    static let mediumKR: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        f.dateFormat = "yyyy년 M월 d일"
        return f
    }()

    static func format(_ date: Date) -> String {
        mediumKR.string(from: date)
    }
}

// MARK: - Flight Completed View

struct FlightBookingCompletedView: View {
    let payload: FlightBookingCompletedPayload
    let onDismiss: () -> Void

    private var confirmation: FlightBookingConfirmationData { payload.confirmation }
    private var form: FlightBookingFormData { payload.form }

    var body: some View {
        VStack(spacing: 0) {
            CompletedTopBar(title: "예약 완료", onClose: onDismiss)

            BookingStepIndicator(currentStep: .completed)
            Divider()

            ScrollView {
                VStack(spacing: 20) {
                    CompletedHeroBlock(title: "항공권 예약이 완료되었습니다")
                        .padding(.top, 16)

                    reservationIDsBlock

                    flightInfoSection

                    passengerInfoSection

                    contactInfoSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .background(Color.chatBackground)
        .safeAreaInset(edge: .bottom) {
            CompletedBottomCTA(onConfirm: onDismiss)
        }
    }

    private var reservationIDsBlock: some View {
        VStack(spacing: 12) {
            if let returnID = confirmation.returnReservationID {
                ReservationIDBlock(label: "가는편 예약번호", id: confirmation.reservationID)
                ReservationIDBlock(label: "오는편 예약번호", id: returnID)
            } else {
                ReservationIDBlock(label: "예약번호", id: confirmation.reservationID)
            }
        }
    }

    private var flightInfoSection: some View {
        CompletedDetailSection(title: "항공편 정보") {
            CompletedDetailRow(title: "항공사", value: confirmation.airlineName)
            CompletedDetailRow(title: "경로", value: confirmation.routeText)
            CompletedDetailRow(title: "일정", value: confirmation.dateText)
            if let tags = confirmation.tags, !tags.isEmpty {
                HStack(alignment: .firstTextBaseline) {
                    Text("옵션")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                        .frame(width: 90, alignment: .leading)
                    FlightTagRow(tags: tags)
                }
            }
        }
    }

    private var passengerInfoSection: some View {
        CompletedDetailSection(title: "탑승객 정보") {
            CompletedDetailRow(title: "탑승자 이름", value: form.passengerName.isEmpty ? "-" : form.passengerName)
            CompletedDetailRow(title: "생년월일", value: CompletedDateFormatter.format(form.birthDate))
            CompletedDetailRow(title: "국적", value: form.nationality)
            CompletedDetailRow(title: "여권번호", value: form.passportNumber.isEmpty ? "-" : form.passportNumber)
            CompletedDetailRow(title: "여권 만료일", value: CompletedDateFormatter.format(form.passportExpiry))
            CompletedDetailRow(title: "탑승 인원", value: "성인 \(form.passengerCount)명")
        }
    }

    private var contactInfoSection: some View {
        CompletedDetailSection(title: "연락처") {
            CompletedDetailRow(title: "이메일", value: form.email.isEmpty ? "-" : form.email)
            CompletedDetailRow(title: "전화번호", value: form.phoneNumber.isEmpty ? "-" : form.phoneNumber)
        }
    }
}

// MARK: - Hotel Completed View

struct HotelBookingCompletedView: View {
    let payload: HotelBookingCompletedPayload
    let onDismiss: () -> Void

    private var confirmation: HotelBookingConfirmationData { payload.confirmation }
    private var form: HotelBookingFormData { payload.form }

    var body: some View {
        VStack(spacing: 0) {
            CompletedTopBar(title: "예약 완료", onClose: onDismiss)

            BookingStepIndicator(currentStep: .completed)
            Divider()

            ScrollView {
                VStack(spacing: 20) {
                    CompletedHeroBlock(title: "호텔 예약이 완료되었습니다")
                        .padding(.top, 16)

                    ReservationIDBlock(label: "예약번호", id: confirmation.reservationID)

                    hotelInfoSection

                    guestInfoSection

                    contactInfoSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .background(Color.chatBackground)
        .safeAreaInset(edge: .bottom) {
            CompletedBottomCTA(onConfirm: onDismiss)
        }
    }

    private var hotelInfoSection: some View {
        CompletedDetailSection(title: "숙소 정보") {
            CompletedDetailRow(title: "호텔명", value: confirmation.hotelName)
            CompletedDetailRow(title: "체크인", value: CompletedDateFormatter.format(form.checkInDate))
            CompletedDetailRow(title: "체크아웃", value: CompletedDateFormatter.format(form.checkOutDate))
            CompletedDetailRow(title: "총 결제 금액", value: confirmation.totalPaidText)
        }
    }

    private var guestInfoSection: some View {
        CompletedDetailSection(title: "투숙객 정보") {
            CompletedDetailRow(title: "투숙객 이름", value: form.guestName.isEmpty ? "-" : form.guestName)
            CompletedDetailRow(title: "투숙 인원", value: "성인 \(form.guestCount)명")
        }
    }

    private var contactInfoSection: some View {
        CompletedDetailSection(title: "연락처") {
            CompletedDetailRow(title: "이메일", value: form.email.isEmpty ? "-" : form.email)
            CompletedDetailRow(title: "전화번호", value: form.phoneNumber.isEmpty ? "-" : form.phoneNumber)
        }
    }
}
