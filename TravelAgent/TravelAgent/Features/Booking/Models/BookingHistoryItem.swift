import Foundation

enum BookingHistoryStatus: String, Codable {
    case confirmed
    case cancelled

    init(rawString: String?) {
        switch rawString?.lowercased() {
        case "cancelled": self = .cancelled
        default: self = .confirmed
        }
    }
}

struct BookingHistoryItem: Identifiable, Decodable, Hashable {
    let bookingCode: String
    let bookingType: BookingItemType
    let status: BookingHistoryStatus
    let title: String?
    let destination: String?
    let startDate: String?
    let endDate: String?
    let createdAt: String?
    let payload: BookingHistoryPayload

    var id: String { bookingCode }

    enum CodingKeys: String, CodingKey {
        case bookingCode = "booking_code"
        case bookingType = "booking_type"
        case status
        case title
        case destination
        case startDate = "start_date"
        case endDate = "end_date"
        case createdAt = "created_at"
        case payload
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bookingCode = try container.decode(String.self, forKey: .bookingCode)
        let typeRaw = (try? container.decode(String.self, forKey: .bookingType)) ?? "hotel"
        bookingType = BookingItemType(rawValue: typeRaw) ?? .hotel
        let statusRaw = try? container.decode(String.self, forKey: .status)
        status = BookingHistoryStatus(rawString: statusRaw)
        title = try? container.decodeIfPresent(String.self, forKey: .title)
        destination = try? container.decodeIfPresent(String.self, forKey: .destination)
        startDate = try? container.decodeIfPresent(String.self, forKey: .startDate)
        endDate = try? container.decodeIfPresent(String.self, forKey: .endDate)
        createdAt = try? container.decodeIfPresent(String.self, forKey: .createdAt)
        payload = (try? container.decode(BookingHistoryPayload.self, forKey: .payload))
            ?? BookingHistoryPayload(item: nil, passengerInfo: nil)
    }
}

struct BookingHistoryPayload: Decodable, Hashable {
    let item: BookingHistoryDetailItem?
    let passengerInfo: BookingHistoryPassenger?

    enum CodingKeys: String, CodingKey {
        case item
        case passengerInfo = "passenger_info"
    }
}

/// Captures the union of hotel- and flight-shaped item fields returned by
/// `/api/bookings`. Both shapes share JSON keys with `BookingItemDTO`, so we
/// decode leniently to tolerate missing values per booking type.
struct BookingHistoryDetailItem: Decodable, Hashable {
    let name: String?
    let price: String?
    let rating: Double?
    let address: String?
    let destinationKR: String?

    let airline: String?
    let flightNumber: String?
    let origin: String?
    let destination: String?
    let depTime: String?
    let depArrTime: String?
    let retDepTime: String?
    let retArrTime: String?
    let stops: String?
    let cabin: String?
    let baggage: String?
    let duration: String?
    let retDuration: String?
    let isRoundtrip: Bool?

    enum CodingKeys: String, CodingKey {
        case name
        case price
        case rating
        case address
        case destinationKR = "destination_kr"
        case airline
        case flightNumber = "flight_number"
        case origin
        case destination
        case depTime = "dep_time"
        case depArrTime = "dep_arr_time"
        case retDepTime = "ret_dep_time"
        case retArrTime = "ret_arr_time"
        case stops
        case cabin
        case baggage
        case duration
        case retDuration = "ret_duration"
        case isRoundtrip = "is_roundtrip"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = BookingHistoryDetailItem.string(c, .name)
        price = BookingHistoryDetailItem.string(c, .price)
        rating = BookingHistoryDetailItem.double(c, .rating)
        address = BookingHistoryDetailItem.string(c, .address)
        destinationKR = BookingHistoryDetailItem.string(c, .destinationKR)

        airline = BookingHistoryDetailItem.string(c, .airline)
        flightNumber = BookingHistoryDetailItem.string(c, .flightNumber)
        origin = BookingHistoryDetailItem.string(c, .origin)
        destination = BookingHistoryDetailItem.string(c, .destination)
        depTime = BookingHistoryDetailItem.string(c, .depTime)
        depArrTime = BookingHistoryDetailItem.string(c, .depArrTime)
        retDepTime = BookingHistoryDetailItem.string(c, .retDepTime)
        retArrTime = BookingHistoryDetailItem.string(c, .retArrTime)
        stops = BookingHistoryDetailItem.string(c, .stops)
        cabin = BookingHistoryDetailItem.string(c, .cabin)
        baggage = BookingHistoryDetailItem.string(c, .baggage)
        duration = BookingHistoryDetailItem.string(c, .duration)
        retDuration = BookingHistoryDetailItem.string(c, .retDuration)
        isRoundtrip = BookingHistoryDetailItem.bool(c, .isRoundtrip)
    }

    private static func string(_ c: KeyedDecodingContainer<CodingKeys>, _ key: CodingKeys) -> String? {
        if let v = try? c.decodeIfPresent(String.self, forKey: key) { return v }
        if let v = try? c.decodeIfPresent(Int.self, forKey: key) { return String(v) }
        if let v = try? c.decodeIfPresent(Double.self, forKey: key) {
            return v.rounded() == v ? String(Int(v)) : String(v)
        }
        if let v = try? c.decodeIfPresent(Bool.self, forKey: key) { return v ? "true" : "false" }
        return nil
    }

    private static func double(_ c: KeyedDecodingContainer<CodingKeys>, _ key: CodingKeys) -> Double? {
        if let v = try? c.decodeIfPresent(Double.self, forKey: key) { return v }
        if let v = try? c.decodeIfPresent(Int.self, forKey: key) { return Double(v) }
        if let v = try? c.decodeIfPresent(String.self, forKey: key) {
            let cleaned = v
                .replacingOccurrences(of: ",", with: "")
                .replacingOccurrences(of: "★", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return Double(cleaned)
        }
        return nil
    }

    private static func bool(_ c: KeyedDecodingContainer<CodingKeys>, _ key: CodingKeys) -> Bool? {
        if let v = try? c.decodeIfPresent(Bool.self, forKey: key) { return v }
        if let v = try? c.decodeIfPresent(String.self, forKey: key) {
            switch v.lowercased() {
            case "true", "1", "yes": return true
            case "false", "0", "no": return false
            default: return nil
            }
        }
        if let v = try? c.decodeIfPresent(Int.self, forKey: key) { return v != 0 }
        return nil
    }
}

struct BookingHistoryPassenger: Decodable, Hashable {
    let name: String?
    let birth: String?
    let nationality: String?
    let passport: String?
    let email: String?
    let phone: String?
    let guests: String?
    let isRoundtrip: Bool?
    let departureDate: String?
    let returnDate: String?
    let checkin: String?
    let checkout: String?

    enum CodingKeys: String, CodingKey {
        case name
        case birth
        case nationality
        case passport
        case email
        case phone
        case guests
        case isRoundtrip = "is_roundtrip"
        case departureDate = "departure_date"
        case returnDate = "return_date"
        case checkin
        case checkout
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try? c.decodeIfPresent(String.self, forKey: .name)
        birth = try? c.decodeIfPresent(String.self, forKey: .birth)
        nationality = try? c.decodeIfPresent(String.self, forKey: .nationality)
        passport = try? c.decodeIfPresent(String.self, forKey: .passport)
        email = try? c.decodeIfPresent(String.self, forKey: .email)
        phone = try? c.decodeIfPresent(String.self, forKey: .phone)

        if let s = try? c.decodeIfPresent(String.self, forKey: .guests) {
            guests = s
        } else if let i = try? c.decodeIfPresent(Int.self, forKey: .guests) {
            guests = String(i)
        } else {
            guests = nil
        }

        isRoundtrip = try? c.decodeIfPresent(Bool.self, forKey: .isRoundtrip)
        departureDate = try? c.decodeIfPresent(String.self, forKey: .departureDate)
        returnDate = try? c.decodeIfPresent(String.self, forKey: .returnDate)
        checkin = try? c.decodeIfPresent(String.self, forKey: .checkin)
        checkout = try? c.decodeIfPresent(String.self, forKey: .checkout)
    }
}

struct BookingHistoryListResponse: Decodable {
    let items: [BookingHistoryItem]
}

struct BookingCancelResponse: Decodable {
    let ok: Bool
    let message: String?
    let bookingCode: String?

    enum CodingKeys: String, CodingKey {
        case ok
        case message
        case bookingCode = "booking_code"
    }
}
