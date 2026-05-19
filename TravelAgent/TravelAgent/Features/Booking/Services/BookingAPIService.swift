import Foundation

enum BookingItemType: String, Codable {
    case hotel
    case flight
}

final class BookingAPIService {
    private let baseURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        baseURL: String = "http://127.0.0.1:8000",
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = URL(string: baseURL) ?? URL(string: "http://127.0.0.1:8000")!
        self.encoder = encoder
        self.decoder = decoder
    }

    func fetchBookingItems(sessionID: String, type: BookingItemType) async throws -> BookingItemsResponse {
        var components = URLComponents(url: baseURL.appendingPathComponent("api/booking/data"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "session_id", value: sessionID),
            URLQueryItem(name: "type", value: type.rawValue)
        ]

        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 600
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try decoder.decode(BookingItemsResponse.self, from: data)
    }

    func confirmBooking(_ requestBody: BookingConfirmationRequest) async throws -> BookingConfirmationResponse {
        let url = baseURL.appendingPathComponent("booking/confirm")
        var request = URLRequest(url: url)
        request.timeoutInterval = 600
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try decoder.decode(BookingConfirmationResponse.self, from: data)
    }
}

// MARK: - Booking Models
struct HotelBookingItem: Decodable, Hashable {
    let name: String?
    let price: String?
    let rating: Double?
    let address: String?
    let source: String?
    let destinationKR: String?

    enum CodingKeys: String, CodingKey {
        case name
        case price
        case rating
        case address
        case source
        case destinationKR = "destination_kr"
    }
}

struct FlightBookingItem: Decodable, Hashable {
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
    let price: String?
    let isRoundtrip: Bool?

    enum CodingKeys: String, CodingKey {
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
        case price
        case isRoundtrip = "is_roundtrip"
    }
}

struct BookingItemsResponse: Decodable {
    let items: [BookingItemDTO]
    let sessionID: String?

    enum CodingKeys: String, CodingKey {
        case items
        case sessionID = "session_id"
    }

    var hotelItems: [HotelBookingItem]? {
        items.map { dto in
            HotelBookingItem(
                name: dto.name,
                price: dto.price,
                rating: dto.rating,
                address: dto.address,
                source: dto.source,
                destinationKR: dto.destinationKR
            )
        }
    }

    var flightItems: [FlightBookingItem]? {
        items.map { dto in
            FlightBookingItem(
                airline: dto.airline,
                flightNumber: dto.flightNumber,
                origin: dto.origin,
                destination: dto.destination,
                depTime: dto.depTime,
                depArrTime: dto.depArrTime,
                retDepTime: dto.retDepTime,
                retArrTime: dto.retArrTime,
                stops: dto.stops,
                cabin: dto.cabin,
                baggage: dto.baggage,
                duration: dto.duration,
                price: dto.price,
                isRoundtrip: dto.isRoundtrip
            )
        }
    }
}

struct BookingItemDTO: Decodable {
    let name: String?
    let price: String?
    let rating: Double?
    let address: String?
    let source: String?
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
    let isRoundtrip: Bool?

    enum CodingKeys: String, CodingKey {
        case name
        case price
        case rating
        case address
        case source
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
        case isRoundtrip = "is_roundtrip"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        func decodeString(_ key: CodingKeys) -> String? {
            if let value = try? container.decodeIfPresent(String.self, forKey: key) {
                return value
            }
            if let value = try? container.decodeIfPresent(Int.self, forKey: key) {
                return String(value)
            }
            if let value = try? container.decodeIfPresent(Double.self, forKey: key) {
                if value.rounded() == value {
                    return String(Int(value))
                }
                return String(value)
            }
            if let value = try? container.decodeIfPresent(Bool.self, forKey: key) {
                return value ? "true" : "false"
            }
            return nil
        }

        func decodeDouble(_ key: CodingKeys) -> Double? {
            if let value = try? container.decodeIfPresent(Double.self, forKey: key) {
                return value
            }
            if let value = try? container.decodeIfPresent(Int.self, forKey: key) {
                return Double(value)
            }
            if let value = try? container.decodeIfPresent(String.self, forKey: key) {
                let cleaned = value
                    .replacingOccurrences(of: ",", with: "")
                    .replacingOccurrences(of: "★", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                return Double(cleaned)
            }
            return nil
        }

        func decodeBool(_ key: CodingKeys) -> Bool? {
            if let value = try? container.decodeIfPresent(Bool.self, forKey: key) {
                return value
            }
            if let value = try? container.decodeIfPresent(String.self, forKey: key) {
                switch value.lowercased() {
                case "true", "1", "yes", "y":
                    return true
                case "false", "0", "no", "n":
                    return false
                default:
                    return nil
                }
            }
            if let value = try? container.decodeIfPresent(Int.self, forKey: key) {
                return value != 0
            }
            return nil
        }

        name = decodeString(.name)
        price = decodeString(.price)
        rating = decodeDouble(.rating)
        address = decodeString(.address)
        source = decodeString(.source)
        destinationKR = decodeString(.destinationKR)

        airline = decodeString(.airline)
        flightNumber = decodeString(.flightNumber)
        origin = decodeString(.origin)
        destination = decodeString(.destination)
        depTime = decodeString(.depTime)
        depArrTime = decodeString(.depArrTime)
        retDepTime = decodeString(.retDepTime)
        retArrTime = decodeString(.retArrTime)
        stops = decodeString(.stops)
        cabin = decodeString(.cabin)
        baggage = decodeString(.baggage)
        duration = decodeString(.duration)
        isRoundtrip = decodeBool(.isRoundtrip)
    }
}

struct BookingConfirmationRequest: Encodable {
    let sessionID: String
    let type: BookingItemType
    let itemIndex: Int?
    let passengerInfo: PassengerInfoPayload?

    enum CodingKeys: String, CodingKey {
        case sessionID = "session_id"
        case type = "booking_type"
        case itemIndex = "item_index"
        case passengerInfo = "passenger_info"
    }
}

enum PassengerInfoPayload: Encodable {
    case hotel(HotelPassengerInfoPayload)
    case flight(FlightPassengerInfoPayload)

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .hotel(let payload): try container.encode(payload)
        case .flight(let payload): try container.encode(payload)
        }
    }
}

struct BookingConfirmationResponse: Decodable {
    let status: String?
    let reservationID: String?
    let message: String?

    enum CodingKeys: String, CodingKey {
        case status
        case reservationID = "reservation_id"
        case message
    }
}
