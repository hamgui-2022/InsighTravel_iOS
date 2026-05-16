import Foundation

struct HotelBookingFormData: Equatable {
    var guestName: String = ""
    var email: String = ""
    var phoneNumber: String = ""
    var checkInDate: Date = Date()
    var checkOutDate: Date = Date().addingTimeInterval(60 * 60 * 24 * 3)
    var guestCount: Int = 1
}

struct FlightBookingFormData: Equatable {
    var passengerName: String = ""
    var birthDate: Date = Date()
    var nationality: String = "대한민국"
    var passportNumber: String = ""
    var passportExpiry: Date = Date()
    var email: String = ""
    var phoneNumber: String = ""
    var departureDate: Date = Date()
    var returnDate: Date = Date().addingTimeInterval(60 * 60 * 24 * 7)
    var passengerCount: Int = 1
}

private enum BookingFormDateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        return f
    }()
}

struct HotelPassengerInfoPayload: Encodable {
    let name: String
    let email: String
    let phone: String
    let checkin: String
    let checkout: String
    let guests: Int
}

struct FlightPassengerInfoPayload: Encodable {
    let name: String
    let birth: String
    let nationality: String
    let passport: String
    let email: String
    let phone: String
    let guests: Int
    let isRoundtrip: Bool
    let departureDate: String
    let returnDate: String

    enum CodingKeys: String, CodingKey {
        case name, birth, nationality, passport, email, phone, guests
        case isRoundtrip = "is_roundtrip"
        case departureDate = "departure_date"
        case returnDate = "return_date"
    }
}

extension HotelBookingFormData {
    func toPassengerInfo() -> HotelPassengerInfoPayload {
        HotelPassengerInfoPayload(
            name: guestName,
            email: email,
            phone: phoneNumber,
            checkin: BookingFormDateFormatter.yyyyMMdd.string(from: checkInDate),
            checkout: BookingFormDateFormatter.yyyyMMdd.string(from: checkOutDate),
            guests: guestCount
        )
    }
}

extension FlightBookingFormData {
    func toPassengerInfo(isRoundtrip: Bool) -> FlightPassengerInfoPayload {
        FlightPassengerInfoPayload(
            name: passengerName,
            birth: BookingFormDateFormatter.yyyyMMdd.string(from: birthDate),
            nationality: nationality,
            passport: passportNumber,
            email: email,
            phone: phoneNumber,
            guests: passengerCount,
            isRoundtrip: isRoundtrip,
            departureDate: BookingFormDateFormatter.yyyyMMdd.string(from: departureDate),
            returnDate: BookingFormDateFormatter.yyyyMMdd.string(from: returnDate)
        )
    }
}
