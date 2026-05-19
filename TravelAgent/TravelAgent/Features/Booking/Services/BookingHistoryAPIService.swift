import Foundation

enum BookingHistoryTab: String, CaseIterable, Identifiable {
    case active
    case cancelled

    var id: String { rawValue }

    var title: String {
        switch self {
        case .active: return "예약 내역"
        case .cancelled: return "취소된 예약"
        }
    }
}

final class BookingHistoryAPIService {
    private let baseURL: URL
    private let decoder: JSONDecoder

    init(
        baseURL: String = "http://127.0.0.1:8000",
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = URL(string: baseURL) ?? URL(string: "http://127.0.0.1:8000")!
        self.decoder = decoder
    }

    func fetchBookings(tab: BookingHistoryTab, sessionID: String) async throws -> [BookingHistoryItem] {
        let path = tab == .active ? "api/bookings" : "api/cancelled-bookings"
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "session_id", value: sessionID)]
        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try decoder.decode(BookingHistoryListResponse.self, from: data).items
    }

    func cancelBooking(bookingCode: String) async throws -> BookingCancelResponse {
        guard let encoded = bookingCode.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw URLError(.badURL)
        }
        let url = baseURL.appendingPathComponent("api/bookings/\(encoded)/cancel")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        let decoded = try? decoder.decode(BookingCancelResponse.self, from: data)
        if !(200...299).contains(http.statusCode) {
            if let decoded, decoded.ok == false {
                return decoded
            }
            throw URLError(.badServerResponse)
        }

        return decoded ?? BookingCancelResponse(ok: true, message: nil, bookingCode: bookingCode)
    }
}
