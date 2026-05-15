import Foundation

enum BookingFlowState: Equatable {
    case idle
    case selectHotel([HotelBookingItem])
    case selectFlight([FlightBookingItem])
    case hotelForm(HotelBookingItem)
    case hotelReview(HotelBookingItem)
    case flightForm(FlightBookingItem)
    case flightReview(FlightBookingItem)
    case submitting
    case completed
    case error(String)
}
