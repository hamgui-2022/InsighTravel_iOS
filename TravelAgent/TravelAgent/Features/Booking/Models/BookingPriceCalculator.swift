import Foundation

/// 호텔/항공 예약 화면에서 1박(또는 1인) 단가 문자열을 받아
/// 박수·인원·세금을 곱한 합계를 다시 한국어 통화 문자열로 변환해주는 헬퍼.
///
/// 백엔드는 `item.price`를 `"₩1,200,000"` 처럼 포맷된 문자열로만 내려주기 때문에,
/// 검토/결제 화면에서 박수·인원만큼 곱하려면 한 번 숫자로 파싱해야 한다.
enum BookingPriceCalculator {
    /// 단가 문자열에서 숫자만 추출. 추출 실패 시 nil.
    static func parseAmount(_ text: String?) -> Decimal? {
        guard let text else { return nil }
        // 통화 기호, 천 단위 구분자, 공백, 한글("원") 등을 제거하고 숫자/소수점만 남긴다.
        let filtered = text.unicodeScalars.filter { CharacterSet(charactersIn: "0123456789.").contains($0) }
        let cleaned = String(String.UnicodeScalarView(filtered))
        guard !cleaned.isEmpty else { return nil }
        return Decimal(string: cleaned)
    }

    /// 체크인 ~ 체크아웃 사이의 박수. 동일 날짜이거나 역전된 경우 1박으로 보정.
    static func nights(from checkIn: Date, to checkOut: Date) -> Int {
        var calendar = Calendar(identifier: .gregorian)
        if let kst = TimeZone(identifier: "Asia/Seoul") {
            calendar.timeZone = kst
        }
        let startDay = calendar.startOfDay(for: checkIn)
        let endDay = calendar.startOfDay(for: checkOut)
        let days = calendar.dateComponents([.day], from: startDay, to: endDay).day ?? 0
        return max(1, days)
    }

    /// 숫자 합계를 `"₩1,234,567"` 형태로 포맷.
    static func formatKRW(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.maximumFractionDigits = 0
        let rounded = NSDecimalNumber(decimal: amount).rounding(accordingToBehavior: nil)
        let numberText = formatter.string(from: rounded) ?? "\(rounded.intValue)"
        return "₩\(numberText)"
    }

    /// 호텔 가격 요약 결과 묶음. 폼/검토/완료 화면에서 동일 계산을 공유.
    struct HotelBreakdown {
        let nights: Int
        let unitAmount: Decimal?
        let subtotal: Decimal?
        let tax: Decimal?
        let total: Decimal?

        /// "3박 × ₩1,200,000"
        var nightsLineText: String {
            if let unitAmount {
                return "\(nights)박 × \(formatKRW(unitAmount))"
            }
            return "\(nights)박"
        }

        /// "₩3,600,000" (계산 실패 시 단가 문자열을 그대로 fallback)
        func nightsPriceText(fallback: String) -> String {
            guard let subtotal else { return fallback }
            return formatKRW(subtotal)
        }

        /// "₩360,000" — 세금/수수료 (subtotal × taxRate)
        func taxPriceText(fallback: String) -> String {
            guard let tax else { return fallback }
            return formatKRW(tax)
        }

        /// "₩3,960,000" — 최종 합계
        func totalPriceText(fallback: String) -> String {
            guard let total else { return fallback }
            return formatKRW(total)
        }

        /// "/ 3박" — 합계 옆 보조 라벨
        var nightCountText: String {
            "/ \(nights)박"
        }

        private func formatKRW(_ amount: Decimal) -> String {
            BookingPriceCalculator.formatKRW(amount)
        }
    }

    /// 호텔 합계 계산. `taxRate` 기본 0.1 (10%).
    static func hotelBreakdown(
        unitPriceText: String?,
        checkIn: Date,
        checkOut: Date,
        taxRate: Decimal = Decimal(string: "0.1") ?? 0
    ) -> HotelBreakdown {
        let nightCount = nights(from: checkIn, to: checkOut)
        guard let unit = parseAmount(unitPriceText) else {
            return HotelBreakdown(nights: nightCount, unitAmount: nil, subtotal: nil, tax: nil, total: nil)
        }
        let subtotal = unit * Decimal(nightCount)
        let tax = subtotal * taxRate
        let total = subtotal + tax
        return HotelBreakdown(
            nights: nightCount,
            unitAmount: unit,
            subtotal: subtotal,
            tax: tax,
            total: total
        )
    }

    /// 항공 합계 계산 결과. 인원 × 단가 + 10% 세금.
    struct FlightBreakdown {
        let passengerCount: Int
        let unitAmount: Decimal?
        let subtotal: Decimal?
        let tax: Decimal?
        let total: Decimal?

        func totalPriceText(fallback: String) -> String {
            guard let total else { return fallback }
            return BookingPriceCalculator.formatKRW(total)
        }

        func subtotalPriceText(fallback: String) -> String {
            guard let subtotal else { return fallback }
            return BookingPriceCalculator.formatKRW(subtotal)
        }
    }

    static func flightBreakdown(
        unitPriceText: String?,
        passengerCount: Int,
        taxRate: Decimal = Decimal(string: "0.1") ?? 0
    ) -> FlightBreakdown {
        let count = max(1, passengerCount)
        guard let unit = parseAmount(unitPriceText) else {
            return FlightBreakdown(passengerCount: count, unitAmount: nil, subtotal: nil, tax: nil, total: nil)
        }
        let subtotal = unit * Decimal(count)
        let tax = subtotal * taxRate
        let total = subtotal + tax
        return FlightBreakdown(
            passengerCount: count,
            unitAmount: unit,
            subtotal: subtotal,
            tax: tax,
            total: total
        )
    }
}
