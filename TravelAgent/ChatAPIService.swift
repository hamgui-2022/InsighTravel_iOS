import Foundation

final class ChatAPIService {
    private let endpoint: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        endpoint: String = "http://127.0.0.1:8000/chat",
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.endpoint = URL(string: endpoint) ?? URL(string: "http://127.0.0.1:8000/chat")!
        self.encoder = encoder
        self.decoder = decoder
    }

    func requestChat(message: String, sessionID: String, context: String) async throws -> ChatResponse {
        var request = URLRequest(url: endpoint)
        request.timeoutInterval = 600
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody = ChatRequest(message: message, sessionID: sessionID, context: context)
        let encodedBody = try encoder.encode(requestBody)
        request.httpBody = encodedBody

        // 🔍 REQUEST LOG
        if let jsonString = String(data: encodedBody, encoding: .utf8) {
            print("\n================ REQUEST ================")
            print("URL: \(endpoint.absoluteString)")
            print("BODY: \n\(jsonString)")
            print("========================================\n")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        // 🔍 RAW RESPONSE LOG
        if let rawString = String(data: data, encoding: .utf8) {
            print("\n================ RESPONSE (RAW) ================")
            print(rawString)
            print("===============================================\n")
        }

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoded = try decoder.decode(ChatResponse.self, from: data)

        // 🔍 PARSED RESPONSE LOG
        print("\n================ RESPONSE (PARSED) ================")
        print("reply: \(decoded.reply)")
        print("plan: \(decoded.plan?.intent ?? "nil")")
        print("trip_goal: \(decoded.tripGoal?.destination ?? "nil")")
        print("==================================================\n")

        return decoded
    }
}

// MARK: - API Models
struct ChatRequest: Codable {
    let message: String
    let sessionID: String
    let context: String

    private enum CodingKeys: String, CodingKey {
        case message
        case sessionID = "session_id"
        case context
    }
}

struct ChatResponse: Decodable {
    let reply: String
    let plan: PlannerPayload?
    let tripGoal: TripGoalPayload?
    let hotelItems: [HotelBookingItem]?
    let flightItems: [FlightBookingItem]?

    enum CodingKeys: String, CodingKey {
        case reply
        case plan
        case tripGoal = "trip_goal"
        case hotelItems = "hotel_items"
        case flightItems = "flight_items"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        reply = try container.decodeIfPresent(String.self, forKey: .reply) ?? ""
        plan = try container.decodeIfPresent(PlannerPayload.self, forKey: .plan)
        tripGoal = try container.decodeIfPresent(TripGoalPayload.self, forKey: .tripGoal)
        hotelItems = try container.decodeIfPresent([HotelBookingItem].self, forKey: .hotelItems)
        flightItems = try container.decodeIfPresent([FlightBookingItem].self, forKey: .flightItems)
    }
}

struct PlannerPayload: Decodable {
    let intent: String?
    let tools: [String]?
    let subtasks: [String]?
    let tripStage: String?
    let originalUserMessage: String?

    enum CodingKeys: String, CodingKey {
        case intent
        case tools
        case subtasks
        case tripStage = "trip_stage"
        case originalUserMessage = "original_user_message"
    }
}

struct TripGoalPayload: Decodable {
    let destination: String?
    let nights: Int?
    let days: Int?
    let month: String?
    let budgetKRW: Int?
    let styleTags: [String]?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case destination
        case nights
        case days
        case month
        case budgetKRW = "budget_krw"
        case styleTags = "style_tags"
        case status
    }
}
