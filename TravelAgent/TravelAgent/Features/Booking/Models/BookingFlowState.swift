import Foundation

struct FlightBookingCompletedPayload: Equatable {
    let item: FlightBookingItem
    let confirmation: FlightBookingConfirmationData
    let form: FlightBookingFormData
}

struct HotelBookingCompletedPayload: Equatable {
    let item: HotelBookingItem
    let confirmation: HotelBookingConfirmationData
    let form: HotelBookingFormData
}

enum BookingFlowState: Equatable {
    case idle
    case selectHotel([HotelBookingItem])
    case selectFlight([FlightBookingItem])
    case hotelForm(HotelBookingItem)
    case hotelReview(HotelBookingItem)
    case flightForm(FlightBookingItem)
    case flightReview(FlightBookingItem)
    case submitting
    case flightCompleted(FlightBookingCompletedPayload)
    case hotelCompleted(HotelBookingCompletedPayload)
    case error(String)
}
