import Foundation

final class SurveyAPIService {
    private let endpoint: URL
    private let encoder: JSONEncoder

    init(
        endpoint: String = "http://127.0.0.1:8000/survey",
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.endpoint = URL(string: endpoint) ?? URL(string: "http://127.0.0.1:8000/survey")!
        self.encoder = encoder
    }

    func submit(sessionID: String, answers: [String: String]) async throws {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = SurveyRequestBody(sessionID: sessionID, answers: answers)
        request.httpBody = try encoder.encode(body)

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }

    private struct SurveyRequestBody: Encodable {
        let sessionID: String
        let answers: [String: String]

        enum CodingKeys: String, CodingKey {
            case sessionID = "session_id"
            case answers
        }
    }
}
