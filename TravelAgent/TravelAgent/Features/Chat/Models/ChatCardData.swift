import Foundation

struct TripGoalData: Hashable {
    let destination: String
    let duration: String
    let style: String
    let notes: [String]
}

struct PlannerSummaryData: Hashable {
    let tripStage: String
    let steps: [PlannerStepData]
}

struct PlannerStepData: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let tool: String
}

struct HotelSearchCardData: Hashable {
    let title: String
    let subtitle: String
    let buttonTitle: String
    let isInteractive: Bool
}

struct FlightSearchCardData: Hashable {
    let title: String
    let subtitle: String
    let buttonTitle: String
    let isInteractive: Bool
}
