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
    let periods: [ItineraryWeatherPeriod]
    let fallbackLines: [String]
    let outfitTip: String?
}

struct ItineraryWeatherPeriod: Identifiable, Hashable, Codable {
    var id = UUID()
    let label: String
    let temperatureText: String?
    let conditionText: String?
    let rainProbText: String?
}

struct ItineraryTimeSlot: Identifiable, Hashable, Codable {
    var id = UUID()
    let slotLabel: String
    let slotKind: ItinerarySlotKind
    let title: String
    let location: String?
    let transport: ItineraryTransportInfo?
    let planB: String?
}

enum ItinerarySlotKind: String, Codable, Hashable {
    case morning
    case noon
    case afternoon
    case evening
    case night
    case timestamp
    case other
}

struct ItineraryTransportInfo: Hashable, Codable {
    let transit: ItineraryTransportLeg?
    let taxi: ItineraryTransportLeg?
    let fallbackText: String?
}

struct ItineraryTransportLeg: Hashable, Codable {
    let description: String
    let durationText: String?
    let costText: String?
}

struct ItineraryEventInfo: Identifiable, Hashable, Codable {
    var id = UUID()
    let title: String
    let location: String?
    let period: String?
    let memo: String?
}
