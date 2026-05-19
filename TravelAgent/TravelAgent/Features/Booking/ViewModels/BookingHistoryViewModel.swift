import Foundation
import SwiftUI
import Combine

@MainActor
final class BookingHistoryViewModel: ObservableObject {
    @Published var tab: BookingHistoryTab = .active
    @Published private(set) var activeBookings: [BookingHistoryItem] = []
    @Published private(set) var cancelledBookings: [BookingHistoryItem] = []
    @Published var selectedBookingCode: String?
    @Published private(set) var isLoading = false
    @Published private(set) var isCancelling = false
    @Published var errorMessage: String?

    private let service: BookingHistoryAPIService
    private let sessionID: String

    init(sessionID: String, service: BookingHistoryAPIService = BookingHistoryAPIService()) {
        self.sessionID = sessionID
        self.service = service
    }

    var currentItems: [BookingHistoryItem] {
        tab == .active ? activeBookings : cancelledBookings
    }

    var selectedBooking: BookingHistoryItem? {
        guard let code = selectedBookingCode else { return currentItems.first }
        return currentItems.first { $0.bookingCode == code }
    }

    func switchTab(_ next: BookingHistoryTab) {
        guard tab != next else { return }
        tab = next
        selectedBookingCode = currentItems.first?.bookingCode
        Task { await loadCurrentTab() }
    }

    func onAppear() async {
        await loadCurrentTab()
    }

    func loadCurrentTab() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let items = try await service.fetchBookings(tab: tab, sessionID: sessionID)
            if tab == .active {
                activeBookings = items
            } else {
                cancelledBookings = items
            }
            if selectedBooking == nil {
                selectedBookingCode = items.first?.bookingCode
            }
        } catch {
            errorMessage = "예약 내역을 불러오지 못했습니다."
        }
    }

    func cancelBooking(_ booking: BookingHistoryItem) async {
        guard booking.status == .confirmed else { return }
        isCancelling = true
        defer { isCancelling = false }

        do {
            let response = try await service.cancelBooking(bookingCode: booking.bookingCode)
            guard response.ok else {
                errorMessage = response.message ?? "예약 취소에 실패했습니다."
                return
            }

            activeBookings.removeAll { $0.bookingCode == booking.bookingCode }
            if selectedBookingCode == booking.bookingCode {
                selectedBookingCode = activeBookings.first?.bookingCode
            }
            // Refresh cancelled list so the next tab switch reflects the move.
            cancelledBookings = []
        } catch {
            errorMessage = "예약 취소 중 오류가 발생했습니다."
        }
    }
}
