import Foundation

struct TripGoalData: Hashable, Codable {
    let destination: String
    let duration: String
    let style: String
    let notes: [String]
}

struct PlannerSummaryData: Hashable, Codable {
    let tripStage: String
    let steps: [PlannerStepData]
}

struct PlannerStepData: Identifiable, Hashable, Codable {
    var id = UUID()
    let title: String
    let description: String
    let tool: String
}

struct HotelSearchCardData: Hashable, Codable {
    let title: String
    let subtitle: String
    let buttonTitle: String
}

struct FlightSearchCardData: Hashable, Codable {
    let title: String
    let subtitle: String
    let buttonTitle: String
}
