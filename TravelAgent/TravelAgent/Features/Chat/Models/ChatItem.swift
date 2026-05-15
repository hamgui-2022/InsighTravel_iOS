import Foundation

enum ChatItem: Identifiable, Hashable {
    case text(ChatTextItem, id: UUID)
    case tripGoal(TripGoalData, id: UUID)
    case plannerSummary(PlannerSummaryData, id: UUID)
    case hotelSearch(HotelSearchCardData, id: UUID)
    case flightSearch(FlightSearchCardData, id: UUID)
    case hotelBookingConfirmation(HotelBookingConfirmationData, id: UUID)
    case flightBookingConfirmation(FlightBookingConfirmationData, id: UUID)
    case surveyActive(id: UUID)
    case surveyCompleted(SurveyAnswers, id: UUID)
    case error(String, id: UUID)

    var id: UUID {
        switch self {
        case .text(_, let id):
            return id
        case .tripGoal(_, let id):
            return id
        case .plannerSummary(_, let id):
            return id
        case .hotelSearch(_, let id):
            return id
        case .flightSearch(_, let id):
            return id
        case .hotelBookingConfirmation(_, let id):
            return id
        case .flightBookingConfirmation(_, let id):
            return id
        case .surveyActive(let id):
            return id
        case .surveyCompleted(_, let id):
            return id
        case .error(_, let id):
            return id
        }
    }
}
