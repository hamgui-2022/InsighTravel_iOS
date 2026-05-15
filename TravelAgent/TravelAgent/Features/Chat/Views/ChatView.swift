//
//  ChatView.swift
//  TravelAgent
//

import Foundation
import SwiftUI
import Combine

// MARK: - Main Chat Screen
// ChatView manages:
// - current input text,
// - message list state,
// - sending mock messages,
// - auto-scrolling to the newest message.
struct ChatView: View {
    @State private var messageText = ""
    @State private var isSidebarVisible = false
    @State private var isShowingBookingError = false
    @StateObject private var viewModel = ChatViewModel()

    var body: some View {
        ZStack(alignment: .leading) {
            VStack(spacing: 0) {
                ChatHeaderView(
                    onMenuTap: { toggleSidebar(true) },
                    onProfileTap: {}
                )
                Divider()
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 16) {
                            if viewModel.items.isEmpty {
                                VStack(spacing: 8) {
                                    Text("여행을 어디로 떠나볼까요?")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundStyle(Color.primary)
                                    Text("메시지를 입력하면 여행 계획을 도와드릴게요.")
                                        .font(.system(size: 13))
                                        .foregroundStyle(Color.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(.horizontal, 32)
                            } else {
                                ForEach(viewModel.items) { item in
                                    switch item {
                                    case .text(let textItem, _):
                                        MessageBubbleView(
                                            text: textItem.text,
                                            isOutgoing: textItem.role == "user"
                                        )

                                    case .tripGoal(let data, _):
                                        TripGoalCardView(data: data)

                                    case .plannerSummary(let data, _):
                                        PlannerSummaryCardView(data: data)

                                    case .hotelSearch(let data, _):
                                        HotelRecommendationCard(
                                            data: viewModel.hotelRecommendationData(from: data),
                                            onTapCTA: { viewModel.openHotelSelectionIfAvailable() }
                                        )

                                    case .flightSearch(let data, _):
                                        FlightResultsSummaryCard(
                                            data: viewModel.flightResultsSummaryData(from: data),
                                            onTapCTA: { viewModel.openFlightSelectionIfAvailable() }
                                        )

                                    case .hotelBookingConfirmation(let data, _):
                                        HotelBookingConfirmedCard(data: data)

                                    case .flightBookingConfirmation(let data, _):
                                        FlightBookingConfirmedCard(data: data)

                                    case .surveyActive(_):
                                        SurveyActiveCardView(
                                            currentIndex: viewModel.surveyCurrentIndex,
                                            answers: viewModel.surveyAnswers,
                                            selectionLockedValue: viewModel.surveySelectedValueForCurrentQuestion,
                                            onSelectOption: { value in
                                                viewModel.selectSurveyOption(value: value)
                                            }
                                        )

                                    case .surveyCompleted(let answers, _):
                                        SurveyCompletedCardView(answers: answers)

                                    case .error(let message, _):
                                        ErrorMessageCardView(detailMessage: message)
                                    }
                                }

                                if let progressData = viewModel.progressCardData {
                                    PlanningProgressCardView(data: progressData)
                                }

                                if let errorMessage = viewModel.errorMessage {
                                    ErrorMessageCardView(detailMessage: errorMessage)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                    }
                    .background(Color.chatBackground)
                    .onChange(of: viewModel.items.count) {
                        scrollToBottom(using: proxy)
                    }
                    .onAppear {
                        scrollToBottom(using: proxy)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                ChatInputBarView(
                    text: $messageText,
                    isSendEnabled: !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    onSend: sendMessage
                )
            }

            if isSidebarVisible {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture { toggleSidebar(false) }
                    .transition(.opacity)

                ChatHistorySidebarView(
                    items: viewModel.sessions,
                    selectedID: viewModel.currentSessionID,
                    onClose: { toggleSidebar(false) },
                    onNewChat: startNewChat,
                    onSelect: selectHistory
                )
                .frame(width: sidebarWidth)
                .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isSidebarVisible)
        .sheet(isPresented: Binding(get: {
            viewModel.isShowingBookingSelection
        }, set: { isPresented in
            if !isPresented {
                viewModel.dismissBookingSelection()
            }
        })) {
            bookingSelectionSheet
        }
        .fullScreenCover(isPresented: Binding(get: {
            viewModel.isShowingBookingFlowScreen
        }, set: { isPresented in
            if !isPresented {
                viewModel.dismissBookingFlowScreen()
            }
        })) {
            bookingFlowScreen
        }
        .onChange(of: viewModel.bookingErrorText) { _, newValue in
            isShowingBookingError = newValue != nil
        }
        .onChange(of: isShowingBookingError) { _, newValue in
            if !newValue, viewModel.bookingErrorText != nil {
                viewModel.bookingFlowState = .idle
            }
        }
        .alert("예약 처리 중 오류", isPresented: $isShowingBookingError) {
            Button("확인", role: .cancel) {
                viewModel.bookingFlowState = .idle
            }
        } message: {
            Text(viewModel.bookingErrorText ?? "")
        }
    }

    private func sendMessage() {
        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        messageText = ""
        Task {
            await viewModel.sendMessage(trimmed)
        }
    }

    private func scrollToBottom(using proxy: ScrollViewProxy) {
        guard let lastId = viewModel.items.last?.id else { return }
        DispatchQueue.main.async {
            proxy.scrollTo(lastId, anchor: .bottom)
        }
    }

    private var sidebarWidth: CGFloat {
        min(UIScreen.main.bounds.width * 0.78, 320)
    }

    private func toggleSidebar(_ shouldShow: Bool) {
        withAnimation(.easeInOut(duration: 0.25)) {
            isSidebarVisible = shouldShow
        }
    }

    private func selectHistory(_ item: ChatSession) {
        viewModel.selectSession(item)
        toggleSidebar(false)
    }

    private func startNewChat() {
        messageText = ""
        viewModel.createNewSession()
        toggleSidebar(false)
    }

    @ViewBuilder
    private var bookingSelectionSheet: some View {
        switch viewModel.bookingFlowState {
        case .selectHotel(let items):
            HotelSelectionSheet(
                options: viewModel.hotelOptions(from: items),
                onClose: { viewModel.dismissBookingSelection() },
                onContinue: { option in
                    viewModel.selectHotelOption(option)
                }
            )
        case .selectFlight(let items):
            FlightSelectionSheet(
                options: viewModel.flightOptions(from: items),
                onClose: { viewModel.dismissBookingSelection() },
                onContinue: { option in
                    viewModel.selectFlightOption(option)
                }
            )
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    private var bookingFlowScreen: some View {
        switch viewModel.bookingFlowState {
        case .hotelForm(let item):
            HotelBookingFormView(
                selectedHotel: viewModel.selectedHotelSummaryData(from: item),
                onBack: { viewModel.returnToHotelSelection() },
                onProceedToReview: { viewModel.proceedToHotelReview() }
            )
        case .hotelReview(let item):
            HotelBookingReviewView(
                data: viewModel.hotelReviewData(from: item),
                onBack: { viewModel.bookingFlowState = .hotelForm(item) },
                onConfirmBooking: {
                    Task { await viewModel.confirmBooking() }
                },
                onEditAccommodation: { viewModel.bookingFlowState = .hotelForm(item) },
                onEditDates: { viewModel.bookingFlowState = .hotelForm(item) },
                onEditGuests: { viewModel.bookingFlowState = .hotelForm(item) }
            )
        case .flightForm(let item):
            BookingFormView(
                selectedFlight: viewModel.selectedFlightSummaryData(from: item),
                onBack: { viewModel.returnToFlightSelection() },
                onReviewBooking: { viewModel.proceedToFlightReview() }
            )
        case .flightReview(let item):
            FlightBookingReviewView(
                data: viewModel.flightReviewData(from: item),
                onBack: { viewModel.bookingFlowState = .flightForm(item) },
                onConfirmBooking: {
                    Task { await viewModel.confirmBooking() }
                }
            )
        case .submitting:
            BookingSubmittingView()
        default:
            EmptyView()
        }
    }
}

// MARK: - Preview

#Preview("Flight Search Progress Card") {
    FlightSearchProgressCard(
        data: FlightSearchData(
            departureCode: "ICN",
            departureCity: "서울",
            arrivalCode: "JTR",
            arrivalCity: "산토리니",
            dateRange: "10월 12일 - 10월 19일",
            travelers: "성인 1명",
            steps: [
                FlightSearchStep(title: "항공사 확인 중...", state: .completed),
                FlightSearchStep(title: "최적 가격 탐색 중...", state: .loading),
                FlightSearchStep(title: "수하물 옵션 비교 중", state: .pending)
            ]
        )
    )
    .padding()
    .background(Color.chatBackground)
}

#Preview("Flight Results Summary Card") {
    FlightResultsSummaryCard(
        data: FlightResultsSummaryData(
            badgeText: "결과 준비 완료",
            heroImageName: "Santorini",
            resultCountText: "항공권 12개",
            priceSummaryText: "최저 45만원부터",
            routeText: "LHR → JTR",
            dateText: "5월 12일 - 5월 19일",
            cheapestLabel: "최저가 옵션",
            airlineText: "British Airways · 직항",
            priceText: "₩450,000",
            priceCaptionText: "왕복 기준",
            buttonTitle: "결과 보기",
            footerHintText: nil
        )
    )
    .padding()
    .background(Color.chatBackground)
}

#Preview("Flight Selection Sheet") {
    FlightSelectionSheet(
        options: [
            FlightOption(
                id: UUID(),
                airlineName: "Aegean Airlines",
                airlineDetail: "A3 652 • Airbus A321neo",
                departureTime: "오전 10:30",
                departureInfo: "LHR · 런던 히드로",
                arrivalTime: "오후 3:45",
                arrivalInfo: "JTR · 산토리니",
                flightType: "직항",
                duration: "3시간 15분",
                priceText: "₩450,000",
                tags: ["직항", "이코노미", "수하물 1개", "무료 Wi-Fi"]
            ),
            FlightOption(
                id: UUID(),
                airlineName: "British Airways",
                airlineDetail: "BA 256 • Airbus A320",
                departureTime: "오전 11:20",
                departureInfo: "LHR · 런던 히드로",
                arrivalTime: "오후 4:55",
                arrivalInfo: "JTR · 산토리니",
                flightType: "1회 경유",
                duration: "5시간 30분",
                priceText: "₩512,000",
                tags: ["1회 경유", "이코노미", "수하물 1개"]
            )
        ],
        onClose: {}
    )
    .background(Color.chatBackground)
}

#Preview("Booking Form") {
    BookingFormView(
        selectedFlight: SelectedFlightSummaryData(
            airlineName: "Aegean Airlines",
            priceText: "₩450,000",
            routeText: "LHR → JTR",
            departureCity: "런던",
            arrivalCity: "산토리니",
            durationText: "3시간 40분"
        ),
        onBack: {},
        onReviewBooking: {}
    )
}

#Preview("Hotel Recommendation Card") {
    HotelRecommendationCard(
        data: HotelRecommendationData(
            imageName: "Santorini",
            badgeText: "추천",
            hotelName: "Canaves Oia Epitome",
            locationText: "Oia, Santorini",
            priceText: "₩850,000",
            priceCaptionText: "1박 기준",
            amenities: [
                HotelAmenity(iconName: "water.waves", title: "전용 수영장"),
                HotelAmenity(iconName: "fork.knife", title: "조식 포함"),
                HotelAmenity(iconName: "wifi", title: "초고속 와이파이")
            ],
            buttonTitle: "다른 호텔 보기",
            footerHintText: nil
        ),
        onTapCTA: {}
    )
    .padding()
    .background(Color.chatBackground)
}

#Preview("Hotel Selection Sheet") {
    HotelSelectionSheet(
        options: [
            HotelOption(
                id: UUID(),
                imageName: "Santorini",
                sourceText: "BOOKING.COM",
                hotelName: "Grace Santorini",
                ratingText: "4.9",
                reviewCountText: "120",
                locationText: "Imerovigli",
                stayPriceLabel: "5박 기준",
                priceText: "₩1,200,000",
                priceSuffixText: "/ 박"
            ),
            HotelOption(
                id: UUID(),
                imageName: "Santorini",
                sourceText: "EXPEDIA",
                hotelName: "Canaves Oia Epitome",
                ratingText: "4.8",
                reviewCountText: "98",
                locationText: "Oia",
                stayPriceLabel: "5박 기준",
                priceText: "₩1,450,000",
                priceSuffixText: "/ 박"
            )
        ],
        onClose: {}
    )
    .background(Color.chatBackground)
}

#Preview("Hotel Booking Form") {
    HotelBookingFormView(
        selectedHotel: SelectedHotelSummaryData(
            imageName: "Santorini",
            hotelName: "Grace Santorini",
            dateRangeText: "10월 12일 - 10월 15일",
            priceText: "₩1,200,000",
            priceCaptionText: "/ 1박",
            locationText: "Imerovigli, Greece"
        ),
        onBack: {},
        onProceedToReview: {}
    )
}

#Preview("Hotel Booking Review") {
    HotelBookingReviewView(
        data: HotelBookingReviewData(
            hotelName: "The Azure Sanctuary",
            hotelDisplayName: "The Azure Sanctuary Resort & Spa",
            hotelImageName: "Santorini",
            locationText: "Amalfi Coast, Italy",
            availabilityBadgeText: "예약 가능 확인됨",
            checkInDate: "2024년 10월 14일",
            checkInNote: "오후 2:00 이후",
            checkOutDate: "2024년 10월 17일",
            checkOutNote: "오전 11:00 이전",
            guestSummaryText: "성인 2명, 아동 1명",
            totalPriceText: "₩3,600,000",
            nightCountText: "/ 3박",
            trustBadgeText: "최저가 보장",
            cancellationPolicyText: "10월 12일 이전까지는 무료 취소 가능합니다. 이후에는 1박 요금이 부과됩니다. 예약 확정을 누르면 이용약관에 동의한 것으로 간주됩니다."
        ),
        onBack: {},
        onConfirmBooking: {},
        onEditAccommodation: {},
        onEditDates: {},
        onEditGuests: {}
    )
}

#Preview("Hotel Booking Confirmed Card") {
    HotelBookingConfirmedCard(
        data: HotelBookingConfirmationData(
            reservationID: "JTR-772910",
            imageName: "Santorini",
            confirmationBadgeText: "예약 확정",
            hotelName: "Aman Tokyo",
            stayDateText: "10월 12일 - 10월 15일, 2024",
            totalPaidLabel: "총 결제 금액",
            totalPaidText: "₩2,450,000",
            paymentInfoText: "세금 포함",
            paymentMethodText: "Apple Pay"
        )
    )
    .padding()
    .background(Color.chatBackground)
}

#Preview("Flight Booking Confirmed Card") {
    FlightBookingConfirmedCard(
        data: FlightBookingConfirmationData(
            reservationID: "FLT-482913",
            heroImageName: "Santorini",
            confirmationBadgeText: "예약 확정",
            airlineName: "Aegean Airlines",
            routeText: "LHR → JTR",
            dateText: "10월 12일 - 10월 19일",
            passengerText: "성인 1명",
            totalPaidLabel: "총 결제 금액",
            totalPaidText: "₩1,280,000",
            paymentInfoText: "세금 포함",
            paymentMethodText: "Apple Pay"
        )
    )
    .padding()
    .background(Color.chatBackground)
}

#Preview("Chat History Sidebar") {
    ChatHistorySidebarView(
        items: [
            ChatSession(id: UUID().uuidString, title: "그리스 산토리니 7일 추천"),
            ChatSession(id: UUID().uuidString, title: "일본 오사카 3박 4일 일정"),
            ChatSession(id: UUID().uuidString, title: "도쿄 벚꽃 여행 추천"),
            ChatSession(id: UUID().uuidString, title: "부산 2박 3일 맛집 여행")
        ],
        selectedID: nil,
        onClose: {},
        onNewChat: {},
        onSelect: { _ in }
    )
    .frame(width: 300)
}

#Preview {
    ContentView()
}
