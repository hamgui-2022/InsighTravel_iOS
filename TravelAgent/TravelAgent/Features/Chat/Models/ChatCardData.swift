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

struct ItineraryCardData: Hashable, Codable {
    let weather: ItineraryWeatherInfo?
    let timeSlots: [ItineraryTimeSlot]
    let events: [ItineraryEventInfo]
}

struct ItineraryWeatherInfo: Hashable, Codable {
    let dateText: String?
    let summaryLines: [String]
    let outfitTip: String?
}

struct ItineraryTimeSlot: Identifiable, Hashable, Codable {
    var id = UUID()
    let slot: String
    let title: String
    let location: String?
    let transport: String?
    let planB: String?
}

struct ItineraryEventInfo: Identifiable, Hashable, Codable {
    var id = UUID()
    let title: String
    let detail: String?
}
