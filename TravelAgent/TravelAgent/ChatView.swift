//
//  ChatView.swift
//  TravelAgent
//
//

// MARK: - Main Chat Screen

import Foundation
import SwiftUI
import Combine


// MARK: - Main Chat Screen
// ChatView manages:
// - current input text,
// - message list state,
// - sending mock messages,
// - auto-scrolling to the newest message.
//
struct ChatView: View {
    // Current text in the input field.
    @State private var messageText = ""
    @State private var isSidebarVisible = false
    @State private var isShowingBookingError = false
    @StateObject private var viewModel = ChatViewModel()

    // The screen is composed of:
    // - a fixed header,
    // - a scrollable chat feed,
    // - a bottom input bar pinned with safeAreaInset.
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

    // Keeps the latest message visible whenever new content is appended.
    //
    // TODO: Revisit this if message updates become more complex
    // (for example replacing a loading card with real response cards).
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

struct ChatSession: Identifiable, Codable, Hashable {
    let id: String
    var title: String
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
    case completed
    case error(String)
}

final class ChatViewModel: ObservableObject {
    @Published var items: [ChatItem] = []
    @Published var sessions: [ChatSession] = []
    @Published var currentSessionID: String?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var bookingFlowState: BookingFlowState = .idle
    @Published var isPrefetchingBookingItems = false
    @Published private(set) var latestPendingMessage: String = ""
    @Published private(set) var lastPlannerIntent: String?

    private var itemsBySession: [String: [ChatItem]] = [:]
    private let chatService = ChatAPIService()
    private let bookingService = BookingAPIService()

    @Published private(set) var cachedHotelItems: [HotelBookingItem] = []
    @Published private(set) var cachedFlightItems: [FlightBookingItem] = []
    private var hotelItemsByOptionID: [UUID: HotelBookingItem] = [:]
    private var flightItemsByOptionID: [UUID: FlightBookingItem] = [:]

    private let sessionsKey = "chat_sessions"
    private let lastSessionKey = "last_session_id"

    init() {
        loadSessions()
        if currentSessionID == nil {
            createNewSession()
        } else {
            restoreCurrentSession()
        }
    }

    func createNewSession() {
        let newSession = ChatSession(id: UUID().uuidString, title: "새 여행")
        sessions.insert(newSession, at: 0)
        currentSessionID = newSession.id
        itemsBySession[newSession.id] = []
        items = []
        errorMessage = nil
        isLoading = false
        isPrefetchingBookingItems = false
        bookingFlowState = .idle
        cachedHotelItems = []
        cachedFlightItems = []
        persistSessions()
    }

    func selectSession(_ session: ChatSession) {
        currentSessionID = session.id
        items = itemsBySession[session.id] ?? []
        errorMessage = nil
        isLoading = false
        isPrefetchingBookingItems = false
        bookingFlowState = .idle
        cachedHotelItems = []
        cachedFlightItems = []
        persistSessions()
    }

    func sendMessage(_ text: String) async {
        guard let sessionID = currentSessionID else {
            await MainActor.run { createNewSession() }
            await sendMessage(text)
            return
        }

        await MainActor.run {
            errorMessage = nil
            isLoading = true
            isPrefetchingBookingItems = false
            latestPendingMessage = text
            lastPlannerIntent = nil
            appendItem(.text(ChatTextItem(role: "user", text: text), id: UUID()), sessionID: sessionID)
            updateSessionTitleIfNeeded(with: text, sessionID: sessionID)
        }

        let context = buildContext(for: sessionID)

        do {
            let response = try await chatService.requestChat(
                message: text,
                sessionID: sessionID,
                context: context
            )

            await MainActor.run {
                isLoading = false
                latestPendingMessage = ""
                lastPlannerIntent = response.plan?.intent
                let responseItems = chatItems(from: response)
                appendItems(responseItems, sessionID: sessionID)
            }

            await handleBookingIntentIfNeeded(from: response, sessionID: sessionID)
        } catch {
            await MainActor.run {
                isLoading = false
                latestPendingMessage = ""
                errorMessage = "응답을 가져오지 못했어요. 잠시 후 다시 시도해주세요."
            }
        }
    }

    var progressCardData: PlanningProgressData? {
        guard isLoading || isPrefetchingBookingItems else { return nil }
        return planningProgressData(for: latestPendingMessage, isPrefetchingBookingItems: isPrefetchingBookingItems)
    }

    private func planningProgressData(for message: String, isPrefetchingBookingItems: Bool) -> PlanningProgressData {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowercased = trimmed.lowercased()

        if isPrefetchingBookingItems {
            if lastPlannerIntent == "stay_search" || trimmed.contains("호텔") || trimmed.contains("숙소") {
                return PlanningProgressData(
                    title: "숙소 후보를 정리하고 있어요",
                    subtitle: "예약 가능한 숙소 정보를 불러오는 중입니다.",
                    statusText: "숙소 탐색 중",
                    steps: [
                        PlanningProgressStep(title: "목적지와 일정 확인", state: .completed),
                        PlanningProgressStep(title: "숙소 후보 조회", state: .loading),
                        PlanningProgressStep(title: "추천 카드 준비", state: .pending)
                    ]
                )
            }

            if lastPlannerIntent == "flight_search" || trimmed.contains("항공") || trimmed.contains("항공권") || trimmed.contains("비행기") {
                return PlanningProgressData(
                    title: "항공편 후보를 정리하고 있어요",
                    subtitle: "조건에 맞는 항공편 정보를 불러오는 중입니다.",
                    statusText: "항공편 탐색 중",
                    steps: [
                        PlanningProgressStep(title: "출발/도착 조건 확인", state: .completed),
                        PlanningProgressStep(title: "항공편 후보 조회", state: .loading),
                        PlanningProgressStep(title: "추천 카드 준비", state: .pending)
                    ]
                )
            }
        }

        if trimmed.contains("호텔") || trimmed.contains("숙소") {
            return PlanningProgressData(
                title: "숙소 요청을 분석하고 있어요",
                subtitle: "여행 조건에 맞는 숙소 탐색 방향을 정리하는 중입니다.",
                statusText: "요청 분석 중",
                steps: [
                    PlanningProgressStep(title: "목적지 확인", state: .completed),
                    PlanningProgressStep(title: "숙박 일정 확인", state: .loading),
                    PlanningProgressStep(title: "숙소 추천 준비", state: .pending)
                ]
            )
        }

        if trimmed.contains("항공") || trimmed.contains("항공권") || trimmed.contains("비행기") {
            return PlanningProgressData(
                title: "항공 요청을 분석하고 있어요",
                subtitle: "여행 조건에 맞는 항공편 탐색 준비를 진행 중입니다.",
                statusText: "요청 분석 중",
                steps: [
                    PlanningProgressStep(title: "출발지와 목적지 확인", state: .completed),
                    PlanningProgressStep(title: "여행 날짜 확인", state: .loading),
                    PlanningProgressStep(title: "항공편 추천 준비", state: .pending)
                ]
            )
        }

        if trimmed.contains("일정") || trimmed.contains("코스") || trimmed.contains("플랜") || lowercased.contains("itinerary") {
            return PlanningProgressData(
                title: "일정 계획을 준비하고 있어요",
                subtitle: "여행 기간과 목적지에 맞춰 일정을 정리하는 중입니다.",
                statusText: "일정 구상 중",
                steps: [
                    PlanningProgressStep(title: "여행 조건 확인", state: .completed),
                    PlanningProgressStep(title: "추천 동선 구성", state: .loading),
                    PlanningProgressStep(title: "일정 카드 준비", state: .pending)
                ]
            )
        }

        return PlanningProgressData(
            title: "여행 요청을 정리하고 있어요",
            subtitle: "입력하신 내용을 바탕으로 다음 답변을 준비하는 중입니다.",
            statusText: "분석 중",
            steps: [
                PlanningProgressStep(title: "여행 조건 확인", state: .completed),
                PlanningProgressStep(title: "현재 단계 판단", state: .loading),
                PlanningProgressStep(title: "답변 카드 준비", state: .pending)
            ]
        )
    }
    private func appendItem(_ item: ChatItem, sessionID: String) {
        items.append(item)
        itemsBySession[sessionID, default: []].append(item)
    }

    private func appendItems(_ newItems: [ChatItem], sessionID: String) {
        items.append(contentsOf: newItems)
        itemsBySession[sessionID, default: []].append(contentsOf: newItems)
    }
    
    private func buildContext(for sessionID: String) -> String {
        let history = itemsBySession[sessionID] ?? []

        let textItems = history.compactMap { item -> ChatTextItem? in
            if case .text(let textItem, _) = item {
                return textItem
            }
            return nil
        }

        let recent = textItems.suffix(6)

        return recent.map { "\($0.role): \($0.text)" }.joined(separator: "\n")
    }

    private func updateSessionTitleIfNeeded(with text: String, sessionID: String) {
        guard let index = sessions.firstIndex(where: { $0.id == sessionID }) else { return }
        if sessions[index].title == "새 여행" {
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                sessions[index].title = String(trimmed.prefix(18))
                persistSessions()
            }
        }
    }

    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: sessionsKey),
           let decoded = try? JSONDecoder().decode([ChatSession].self, from: data) {
            sessions = decoded
        } else {
            sessions = []
        }

        currentSessionID = UserDefaults.standard.string(forKey: lastSessionKey)
    }

    private func restoreCurrentSession() {
        guard let sessionID = currentSessionID else { return }
        items = itemsBySession[sessionID] ?? []
    }

    private func persistSessions() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: sessionsKey)
        }
        UserDefaults.standard.set(currentSessionID, forKey: lastSessionKey)
    }

    var isShowingBookingSelection: Bool {
        switch bookingFlowState {
        case .selectHotel, .selectFlight:
            return true
        default:
            return false
        }
    }

    var isShowingBookingFlowScreen: Bool {
        switch bookingFlowState {
        case .hotelForm, .hotelReview, .flightForm, .flightReview, .submitting:
            return true
        default:
            return false
        }
    }

    var bookingErrorText: String? {
        if case .error(let message) = bookingFlowState {
            return message
        }
        return nil
    }

    func dismissBookingSelection() {
        if case .selectHotel = bookingFlowState {
            isPrefetchingBookingItems = false
            bookingFlowState = .idle
        } else if case .selectFlight = bookingFlowState {
            isPrefetchingBookingItems = false
            bookingFlowState = .idle
        }
    }

    func dismissBookingFlowScreen() {
        switch bookingFlowState {
        case .hotelForm, .hotelReview, .flightForm, .flightReview, .submitting:
            isPrefetchingBookingItems = false
            bookingFlowState = .idle
        default:
            break
        }
    }

    func openHotelSelectionIfAvailable() {
        if !cachedHotelItems.isEmpty {
            bookingFlowState = .selectHotel(cachedHotelItems)
            return
        }

        guard let sessionID = currentSessionID else { return }
        Task {
            await fetchBookingItems(sessionID: sessionID, type: .hotel)
        }
    }

    func openFlightSelectionIfAvailable() {
        if !cachedFlightItems.isEmpty {
            bookingFlowState = .selectFlight(cachedFlightItems)
            return
        }

        guard let sessionID = currentSessionID else { return }
        Task {
            await fetchBookingItems(sessionID: sessionID, type: .flight)
        }
    }

    func hotelOptions(from items: [HotelBookingItem]) -> [HotelOption] {
        var options: [HotelOption] = []
        hotelItemsByOptionID = [:]

        for item in items {
            let id = UUID()
            hotelItemsByOptionID[id] = item
            let ratingText = item.rating.map { String(format: "%.1f", $0) } ?? "--"
            let sourceText = (item.source ?? "BOOKING.COM").uppercased()
            let location = item.address ?? item.destinationKR ?? "위치 정보 없음"

            options.append(
                HotelOption(
                    id: id,
                    imageName: "Santorini",
                    sourceText: sourceText,
                    hotelName: item.name ?? "이름 미정",
                    ratingText: ratingText,
                    reviewCountText: "리뷰 정보 없음",
                    locationText: location,
                    stayPriceLabel: "1박 기준",
                    priceText: item.price ?? "가격 정보 없음",
                    priceSuffixText: "/ 박"
                )
            )
        }

        return options
    }

    func flightOptions(from items: [FlightBookingItem]) -> [FlightOption] {
        var options: [FlightOption] = []
        flightItemsByOptionID = [:]

        for item in items {
            let id = UUID()
            flightItemsByOptionID[id] = item

            let stopsText: String = {
                guard let stops = item.stops else { return "정보 없음" }
                //return stops == 0 ? "직항" : "\(stops)회 경유"
                return stops
            }()

            var tags: [String] = []
            if let cabin = item.cabin { tags.append(cabin) }
            if let baggage = item.baggage { tags.append(baggage) }
            if let isRoundtrip = item.isRoundtrip {
                tags.append(isRoundtrip ? "왕복" : "편도")
            }

            if tags.isEmpty { tags = ["옵션 확인"] }

            options.append(
                FlightOption(
                    id: id,
                    airlineName: item.airline ?? "항공사 미정",
                    airlineDetail: item.flightNumber ?? "항공편 정보 없음",
                    departureTime: item.depTime ?? "--",
                    departureInfo: item.origin ?? "출발지",
                    arrivalTime: item.depArrTime ?? "--",
                    arrivalInfo: item.destination ?? "도착지",
                    flightType: stopsText,
                    duration: item.duration ?? "--",
                    priceText: item.price ?? "가격 정보 없음",
                    tags: tags
                )
            )
        }

        return options
    }

    func selectHotelOption(_ option: HotelOption) {
        guard let item = hotelItemsByOptionID[option.id] else { return }
        bookingFlowState = .hotelForm(item)
    }

    func selectFlightOption(_ option: FlightOption) {
        guard let item = flightItemsByOptionID[option.id] else { return }
        bookingFlowState = .flightForm(item)
    }

    func proceedToHotelReview() {
        if case .hotelForm(let item) = bookingFlowState {
            bookingFlowState = .hotelReview(item)
        }
    }

    func proceedToFlightReview() {
        if case .flightForm(let item) = bookingFlowState {
            bookingFlowState = .flightReview(item)
        }
    }

    func returnToHotelSelection() {
        if !cachedHotelItems.isEmpty {
            bookingFlowState = .selectHotel(cachedHotelItems)
        } else {
            bookingFlowState = .idle
        }
    }

    func returnToFlightSelection() {
        if !cachedFlightItems.isEmpty {
            bookingFlowState = .selectFlight(cachedFlightItems)
        } else {
            bookingFlowState = .idle
        }
    }

    func selectedHotelSummaryData(from item: HotelBookingItem) -> SelectedHotelSummaryData {
        SelectedHotelSummaryData(
            imageName: "Santorini",
            hotelName: item.name ?? "호텔",
            dateRangeText: "일정 미정",
            priceText: item.price ?? "가격 정보 없음",
            priceCaptionText: "/ 1박",
            locationText: item.address ?? item.destinationKR ?? "위치 정보 없음"
        )
    }

    func selectedFlightSummaryData(from item: FlightBookingItem) -> SelectedFlightSummaryData {
        let routeText = "\(item.origin ?? "출발지") → \(item.destination ?? "도착지")"
        return SelectedFlightSummaryData(
            airlineName: item.airline ?? "항공사",
            priceText: item.price ?? "가격 정보 없음",
            routeText: routeText,
            departureCity: item.origin ?? "출발지",
            arrivalCity: item.destination ?? "도착지",
            durationText: item.duration ?? "--"
        )
    }

    func hotelRecommendationData(from card: HotelSearchCardData) -> HotelRecommendationData {
        HotelRecommendationData(
            imageName: "Santorini",
            badgeText: "추천",
            hotelName: card.title,
            locationText: card.subtitle,
            priceText: "가격 정보 확인",
            priceCaptionText: "1박 기준",
            amenities: [
                HotelAmenity(iconName: "bed.double.fill", title: "객실"),
                HotelAmenity(iconName: "fork.knife", title: "식사"),
                HotelAmenity(iconName: "wifi", title: "와이파이")
            ],
            buttonTitle: "호텔 선택"
        )
    }

    func flightResultsSummaryData(from card: FlightSearchCardData) -> FlightResultsSummaryData {
        let count = cachedFlightItems.count
        let firstItem = cachedFlightItems.first

        let routeText: String = {
            guard let firstItem else { return "출발 → 도착" }
            let origin = firstItem.origin ?? "출발지"
            let destination = firstItem.destination ?? "도착지"
            return "\(origin) → \(destination)"
        }()

        let dateText: String = {
            guard let firstItem else { return "일정 확인" }
            if let depTime = firstItem.depTime, !depTime.isEmpty {
                return firstItem.isRoundtrip == true && (firstItem.retDepTime?.isEmpty == false)
                    ? "\(depTime) · \(firstItem.retDepTime ?? "")"
                    : depTime
            }
            return "일정 확인"
        }()

        let airlineText: String = {
            guard let firstItem else { return "항공편 정보 확인" }
            if let flightNumber = firstItem.flightNumber, !flightNumber.isEmpty {
                return "\(firstItem.airline ?? "항공사 미정") · \(flightNumber)"
            }
            return firstItem.airline ?? "항공사 미정"
        }()

        let priceText = firstItem?.price ?? "가격 확인"

        let priceCaptionText: String = {
            guard let firstItem else { return "조건 기준" }
            return firstItem.isRoundtrip == true ? "왕복 기준" : "편도 기준"
        }()

        let buttonTitle: String = {
            if count > 1 {
                return "이외 \(count - 1)개의 항공권 보기"
            } else if count == 1 {
                return "항공권 보기"
            } else {
                return card.buttonTitle
            }
        }()

        let resultCountText: String = {
            if count > 0 {
                return "\(card.title) · 총 \(count)개"
            }
            return card.title
        }()

        return FlightResultsSummaryData(
            badgeText: "항공권 탐색",
            heroImageName: "Santorini",
            resultCountText: resultCountText,
            priceSummaryText: card.subtitle,
            routeText: routeText,
            dateText: dateText,
            cheapestLabel: count > 0 ? "첫 번째 추천 항공편" : "추천 옵션",
            airlineText: airlineText,
            priceText: priceText,
            priceCaptionText: priceCaptionText,
            buttonTitle: buttonTitle
        )
    }

    func hotelReviewData(from item: HotelBookingItem) -> HotelBookingReviewData {
        HotelBookingReviewData(
            hotelName: item.name ?? "호텔",
            hotelDisplayName: item.name ?? "호텔 예약",
            hotelImageName: "Santorini",
            locationText: item.address ?? item.destinationKR ?? "위치 정보 없음",
            availabilityBadgeText: "예약 가능 확인됨",
            checkInDate: "체크인 일정 미정",
            checkInNote: "오후 2:00 이후",
            checkOutDate: "체크아웃 일정 미정",
            checkOutNote: "오전 11:00 이전",
            guestSummaryText: "성인 1명",
            totalPriceText: item.price ?? "가격 정보 없음",
            nightCountText: "/ 1박",
            trustBadgeText: "안심 예약",
            cancellationPolicyText: "예약 확정 전에는 무료 취소가 가능합니다. 확정 후에는 숙소 정책을 따릅니다."
        )
    }

    func flightReviewData(from item: FlightBookingItem) -> FlightBookingReviewData {
        let routeText = "\(item.origin ?? "출발지") → \(item.destination ?? "도착지")"
        let dateText: String = {
            if let dep = item.depTime, let ret = item.retDepTime {
                return "\(dep) - \(ret)"
            }
            return item.depTime ?? "일정 미정"
        }()

        return FlightBookingReviewData(
            summary: selectedFlightSummaryData(from: item),
            routeText: routeText,
            dateText: dateText,
            passengerText: "성인 1명",
            totalPriceText: item.price ?? "가격 정보 없음"
        )
    }

    func hotelConfirmationData(from item: HotelBookingItem, response: BookingConfirmationResponse) -> HotelBookingConfirmationData {
        HotelBookingConfirmationData(
            reservationID: response.reservationID ?? "예약 완료",
            imageName: "Santorini",
            confirmationBadgeText: "예약 확정",
            hotelName: item.name ?? "호텔",
            stayDateText: "일정 미정",
            totalPaidLabel: "총 결제 금액",
            totalPaidText: item.price ?? "가격 정보 없음",
            paymentInfoText: "세금 포함",
            paymentMethodText: "카드 결제"
        )
    }

    func flightConfirmationData(from item: FlightBookingItem, response: BookingConfirmationResponse) -> FlightBookingConfirmationData {
        let routeText = "\(item.origin ?? "출발지") → \(item.destination ?? "도착지")"
        let dateText: String = {
            if let dep = item.depTime, let ret = item.retDepTime {
                return "\(dep) - \(ret)"
            }
            return item.depTime ?? "일정 미정"
        }()

        return FlightBookingConfirmationData(
            reservationID: response.reservationID ?? "예약 완료",
            heroImageName: "Santorini",
            confirmationBadgeText: "예약 확정",
            airlineName: item.airline ?? "항공사",
            routeText: routeText,
            dateText: dateText,
            passengerText: "성인 1명",
            totalPaidLabel: "총 결제 금액",
            totalPaidText: item.price ?? "가격 정보 없음",
            paymentInfoText: "세금 포함",
            paymentMethodText: "카드 결제"
        )
    }

    func confirmBooking() async {
        guard let sessionID = currentSessionID else { return }

        let bookingType: BookingItemType
        let hotelItem: HotelBookingItem?
        let flightItem: FlightBookingItem?

        switch bookingFlowState {
        case .hotelReview(let item):
            bookingType = .hotel
            hotelItem = item
            flightItem = nil
        case .flightReview(let item):
            bookingType = .flight
            flightItem = item
            hotelItem = nil
        default:
            return
        }

        await MainActor.run {
            bookingFlowState = .submitting
        }

        do {
            let request = BookingConfirmationRequest(
                sessionID: sessionID,
                type: bookingType,
                itemID: nil,
                details: nil
            )
            let response = try await bookingService.confirmBooking(request)

            await MainActor.run {
                if let item = hotelItem {
                    appendItem(
                        .text(ChatTextItem(role: "assistant", text: "호텔 예약이 완료되었어요."), id: UUID()),
                        sessionID: sessionID
                    )
                    appendItem(.hotelBookingConfirmation(hotelConfirmationData(from: item, response: response), id: UUID()), sessionID: sessionID)
                } else if let item = flightItem {
                    appendItem(
                        .text(ChatTextItem(role: "assistant", text: "항공권 예약이 완료되었어요."), id: UUID()),
                        sessionID: sessionID
                    )
                    appendItem(.flightBookingConfirmation(flightConfirmationData(from: item, response: response), id: UUID()), sessionID: sessionID)
                }

                bookingFlowState = .idle
            }
        } catch {
            await MainActor.run {
                bookingFlowState = .error("예약을 완료하지 못했어요. 잠시 후 다시 시도해주세요.")
            }
        }
    }

    private func handleBookingIntentIfNeeded(from response: ChatResponse, sessionID: String) async {
        guard let intent = response.plan?.intent else { return }

        switch intent {
        case "stay_search":
            await prefetchBookingItems(sessionID: sessionID, type: .hotel)
        case "flight_search":
            await prefetchBookingItems(sessionID: sessionID, type: .flight)
        default:
            break
        }
    }

    private func prefetchBookingItems(sessionID: String, type: BookingItemType) async {
        await MainActor.run {
            isPrefetchingBookingItems = true
        }

        do {
            let response = try await bookingService.fetchBookingItems(sessionID: sessionID, type: type)

            await MainActor.run {
                isPrefetchingBookingItems = false
                switch type {
                case .hotel:
                    cachedHotelItems = response.hotelItems ?? []
                case .flight:
                    cachedFlightItems = response.flightItems ?? []
                }
            }
        } catch {
            await MainActor.run {
                isPrefetchingBookingItems = false
                switch type {
                case .hotel:
                    cachedHotelItems = []
                case .flight:
                    cachedFlightItems = []
                }
            }
        }
    }

    private func fetchBookingItems(sessionID: String, type: BookingItemType) async {
        await MainActor.run {
            isPrefetchingBookingItems = true
        }

        do {
            let response = try await bookingService.fetchBookingItems(sessionID: sessionID, type: type)

            await MainActor.run {
                isPrefetchingBookingItems = false
                switch type {
                case .hotel:
                    let items = response.hotelItems ?? []
                    cachedHotelItems = items
                    bookingFlowState = items.isEmpty ? .error("예약 가능한 호텔 정보를 찾지 못했어요.") : .selectHotel(items)
                case .flight:
                    let items = response.flightItems ?? []
                    cachedFlightItems = items
                    bookingFlowState = items.isEmpty ? .error("예약 가능한 항공편 정보를 찾지 못했어요.") : .selectFlight(items)
                }
            }
        } catch {
            await MainActor.run {
                isPrefetchingBookingItems = false
                bookingFlowState = .error("예약 정보를 불러오지 못했어요. 잠시 후 다시 시도해주세요.")
            }
        }
    }
}

private func summarizeAssistantReply(_ reply: String, intent: String?) -> String {
    let trimmed = reply.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return reply }

    switch intent {
    case "stay_search":
        if let summary = summarizeHotelReply(trimmed) {
            return summary
        }
    case "flight_search":
        if let summary = summarizeFlightReply(trimmed) {
            return summary
        }
    default:
        break
    }

    return summarizeGenericReply(trimmed)
}

private func summarizeHotelReply(_ text: String) -> String? {
    let normalized = text
        .replacingOccurrences(of: "\r\n", with: "\n")
        .replacingOccurrences(of: "\r", with: "\n")

    let patterns: [(String, String)] = [
        ("럭셔리", "럭셔리"),
        ("프리미엄", "중급"),
        ("부티크", "중급"),
        ("합리적인 가격", "가성비"),
        ("실용적인 숙소", "가성비"),
        ("가성비", "가성비")
    ]

    let lines = normalized
        .components(separatedBy: .newlines)
        .map { $0.trimmingCharacters(in: .whitespaces) }

    var buckets: [String: [String]] = [:]
    var currentBucket: String?

    for line in lines {
        guard !line.isEmpty else { continue }

        if line.contains("###") || line.contains("**") {
            for (keyword, bucket) in patterns {
                if line.contains(keyword) {
                    currentBucket = bucket
                    if buckets[bucket] == nil { buckets[bucket] = [] }
                    break
                }
            }
        }

        guard let currentBucket else { continue }

        if line.hasPrefix("*   **") || line.hasPrefix("- **") || line.hasPrefix("• **") {
            let cleaned = line
                .replacingOccurrences(of: "*   **", with: "")
                .replacingOccurrences(of: "- **", with: "")
                .replacingOccurrences(of: "• **", with: "")
                .replacingOccurrences(of: "**", with: "")
                .trimmingCharacters(in: .whitespaces)

            buckets[currentBucket, default: []].append(cleaned)
        }
    }

    let order = ["럭셔리", "중급", "가성비"]
    var sections: [String] = []

    for bucket in order {
        let values = Array((buckets[bucket] ?? []).prefix(2))
        guard !values.isEmpty else { continue }

        let body = values.map { "- \($0)" }.joined(separator: "\n")
        sections.append("\(bucket)\n\(body)")
    }

    guard !sections.isEmpty else { return nil }

    return "추천 숙소를 간단히 정리했어요.\n\n" + sections.joined(separator: "\n\n")
}

private func summarizeFlightReply(_ text: String) -> String? {
    let normalized = text
        .replacingOccurrences(of: "\r\n", with: "\n")
        .replacingOccurrences(of: "\r", with: "\n")

    let lines = normalized
        .components(separatedBy: .newlines)
        .map { $0.trimmingCharacters(in: .whitespaces) }
        .filter { !$0.isEmpty }

    let candidateLines = lines.filter {
        ($0.contains("항공") || $0.contains("직항") || $0.contains("경유") || $0.contains("원") || $0.contains("JPY") || $0.contains("KRW"))
        && ($0.hasPrefix("-") || $0.hasPrefix("*") || $0.hasPrefix("•") || $0.contains("**"))
    }

    let summaryItems = Array(candidateLines.prefix(3)).map {
        $0.replacingOccurrences(of: "**", with: "")
            .replacingOccurrences(of: "*", with: "")
            .replacingOccurrences(of: "•", with: "")
            .trimmingCharacters(in: .whitespaces)
    }

    guard !summaryItems.isEmpty else { return nil }

    return "추천 항공편을 간단히 정리했어요.\n\n" + summaryItems.map { "- \($0)" }.joined(separator: "\n")
}

private func summarizeGenericReply(_ text: String) -> String {
    let cleaned = text
        .replacingOccurrences(of: "\r\n", with: "\n")
        .replacingOccurrences(of: "\r", with: "\n")

    let paragraphs = cleaned
        .components(separatedBy: "\n\n")
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }

    if let first = paragraphs.first {
        let compact = first
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        if compact.count <= 180 {
            return compact
        }

        return String(compact.prefix(180)) + "…"
    }

    return text
}

func chatItems(from response: ChatResponse) -> [ChatItem] {
    var items: [ChatItem] = []

    // Booking items are decoded in ChatResponse and can be attached to UI later.

    let summarizedReply = summarizeAssistantReply(
        response.reply,
        intent: response.plan?.intent
    )

    items.append(
        .text(
            ChatTextItem(role: "assistant", text: summarizedReply),
            id: UUID()
        )
    )

    if let tripGoal = tripGoalFrom(response.tripGoal) {
        items.append(.tripGoal(tripGoal, id: UUID()))
    }

    if let planner = plannerSummaryFrom(response.plan) {
        items.append(.plannerSummary(planner, id: UUID()))
    }

    switch response.plan?.intent {
    case "stay_search":
        if let hotelCard = hotelSearchCardFrom(response: response) {
            items.append(.hotelSearch(hotelCard, id: UUID()))
        }
    case "flight_search":
        if let flightCard = flightSearchCardFrom(response: response) {
            items.append(.flightSearch(flightCard, id: UUID()))
        }
    default:
        break
    }

    return items
}

func plannerSummaryFrom(_ payload: PlannerPayload?) -> PlannerSummaryData? {
    guard let payload else { return nil }

    let subtasks = payload.subtasks ?? []
    let tools = payload.tools ?? []

    if subtasks.isEmpty && tools.isEmpty && (payload.tripStage == nil || payload.tripStage?.isEmpty == true) {
        return nil
    }

    func userFacingTripStage(_ raw: String?) -> String {
        switch raw {
        case "ideation":
            return "여행 아이디어 정리"
        case "planning":
            return "여행 계획 수립"
        case "booking":
            return "예약 준비"
        case "post_trip":
            return "여행 후 정리"
        default:
            return "여행 계획"
        }
    }

    func userFacingTool(_ raw: String?) -> String {
        switch raw {
        case "stay_search":
            return "숙소 탐색"
        case "flight_search":
            return "항공편 탐색"
        case "booking_action":
            return "예약 진행"
        case "budget_planner":
            return "예산 정리"
        case "food_spot_search":
            return "맛집/명소 탐색"
        case "local_guide":
            return "현지 정보 안내"
        case "weather_lookup":
            return "날씨 확인"
        default:
            return "여행 정보 정리"
        }
    }

    let defaultDescription: String = {
        switch payload.tripStage {
        case "ideation":
            return "여행 방향을 구체화하는 단계입니다."
        case "booking":
            return "예약 가능 여부와 조건을 확인하는 단계입니다."
        default:
            return "현재 여행 계획 단계에서 필요한 작업입니다."
        }
    }()

    var steps: [PlannerStepData] = []

    for (index, subtask) in subtasks.enumerated() {
        let mappedTool = index < tools.count ? userFacingTool(tools[index]) : "여행 정보 정리"
        steps.append(
            PlannerStepData(
                title: subtask,
                description: defaultDescription,
                tool: mappedTool
            )
        )
    }

    if steps.isEmpty, let intent = payload.intent {
        let fallbackTitle: String
        switch intent {
        case "stay_search":
            fallbackTitle = "숙소 후보를 정리하고 있어요"
        case "flight_search":
            fallbackTitle = "항공편 후보를 정리하고 있어요"
        case "trip_ideation":
            fallbackTitle = "여행 아이디어를 정리하고 있어요"
        default:
            fallbackTitle = "여행 계획을 정리하고 있어요"
        }

        steps.append(
            PlannerStepData(
                title: fallbackTitle,
                description: payload.originalUserMessage ?? "사용자 요청을 기반으로 계획을 생성했습니다.",
                tool: userFacingTool(tools.first ?? intent)
            )
        )
    }

    return PlannerSummaryData(
        tripStage: userFacingTripStage(payload.tripStage),
        steps: steps
    )
}

func tripGoalFrom(_ payload: TripGoalPayload?) -> TripGoalData? {
    guard let payload else { return nil }

    func userFacingStatus(_ raw: String?) -> String? {
        switch raw {
        case "just_started":
            return "여행 정보 수집 중"
        case "choosing_city":
            return "목적지 검토 중"
        case "planning_itinerary":
            return "일정 구체화 중"
        case "done":
            return "계획 정리 완료"
        default:
            return nil
        }
    }

    let destination = payload.destination ?? "미정"

    let duration: String = {
        if let nights = payload.nights, let days = payload.days {
            return "\(nights)박 \(days)일"
        } else {
            return "일정 미정"
        }
    }()

    let style: String = {
        let tags = payload.styleTags ?? []
        return tags.isEmpty ? "미정" : tags.joined(separator: " · ")
    }()

    var notes: [String] = []
    if let statusText = userFacingStatus(payload.status) {
        notes.append(statusText)
    }
    if let month = payload.month, !month.isEmpty {
        notes.append("시기: \(month)")
    }
    if let budget = payload.budgetKRW {
        notes.append("예산: \(budget.formatted())원")
    }

    return TripGoalData(
        destination: destination,
        duration: duration,
        style: style,
        notes: notes
    )
}
struct PlanningProgressData: Hashable {
    let title: String
    let subtitle: String
    let statusText: String
    let steps: [PlanningProgressStep]
}

struct PlanningProgressStep: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let state: StepState
}

struct PlanningProgressCardView: View {
    let data: PlanningProgressData

    private var progressValue: CGFloat {
        guard !data.steps.isEmpty else { return 0 }
        let completedCount = data.steps.filter { $0.state == .completed }.count
        let loadingCount = data.steps.filter { $0.state == .loading }.count
        let rawValue = CGFloat(completedCount) + (loadingCount > 0 ? 0.5 : 0)
        return rawValue / CGFloat(data.steps.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.12))
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.blue)
                }
                .frame(width: 38, height: 38)

                VStack(alignment: .leading, spacing: 4) {
                    Text(data.title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Color.primary)
                    Text(data.subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.secondary)
                }

                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(data.statusText)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.blue)
                    Spacer(minLength: 0)
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.blue.opacity(0.12))
                        Capsule()
                            .fill(Color.blue)
                            .frame(width: max(10, proxy.size.width * progressValue))
                    }
                }
                .frame(height: 6)
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(data.steps) { step in
                    HStack(spacing: 10) {
                        stepIndicator(for: step.state)
                        Text(step.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(step.state == .pending ? Color.secondary : Color.primary)
                        Spacer(minLength: 0)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
    }

    @ViewBuilder
    private func stepIndicator(for state: StepState) -> some View {
        switch state {
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.blue)
        case .loading:
            ProgressView()
                .progressViewStyle(.circular)
                .tint(Color.blue)
                .frame(width: 16, height: 16)
        case .pending:
            Image(systemName: "circle")
                .font(.system(size: 16))
                .foregroundStyle(Color.gray.opacity(0.5))
        }
    }
}

enum ChatItem: Identifiable, Hashable {
    case text(ChatTextItem, id: UUID)
    case tripGoal(TripGoalData, id: UUID)
    case plannerSummary(PlannerSummaryData, id: UUID)
    case hotelSearch(HotelSearchCardData, id: UUID)
    case flightSearch(FlightSearchCardData, id: UUID)
    case hotelBookingConfirmation(HotelBookingConfirmationData, id: UUID)
    case flightBookingConfirmation(FlightBookingConfirmationData, id: UUID)
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
        case .error(_, let id):
            return id
        }
    }
}

struct ChatTextItem: Hashable {
    let role: String
    let text: String
}

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
}

func hotelSearchCardFrom(response: ChatResponse) -> HotelSearchCardData? {
    guard response.plan?.intent == "stay_search" else { return nil }

    let destination = response.tripGoal?.destination ?? "숙소 목적지"
    let month = response.tripGoal?.month ?? "일정 미정"

    return HotelSearchCardData(
        title: "\(destination) 숙소 탐색",
        subtitle: "\(month) 기준으로 숙소 후보를 비교해볼 수 있어요.",
        buttonTitle: "호텔 결과 보기"
    )
}

func flightSearchCardFrom(response: ChatResponse) -> FlightSearchCardData? {
    guard response.plan?.intent == "flight_search" else { return nil }

    let destination = response.tripGoal?.destination ?? "항공 목적지"

    return FlightSearchCardData(
        title: "\(destination) 항공권 탐색",
        subtitle: "조건에 맞는 항공편 후보를 확인할 수 있어요.",
        buttonTitle: "항공권 보기"
    )
}

// MARK: - Flight Search Progress
struct FlightSearchCardData: Hashable {
    let title: String
    let subtitle: String
    let buttonTitle: String
}

struct FlightSearchData: Identifiable, Hashable {
    let id = UUID()
    let departureCode: String
    let departureCity: String
    let arrivalCode: String
    let arrivalCity: String
    let dateRange: String
    let travelers: String
    let steps: [FlightSearchStep]
}

struct FlightSearchStep: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let state: StepState
}

enum StepState: Hashable {
    case completed
    case loading
    case pending
}

struct FlightSearchProgressCard: View {
    let data: FlightSearchData

    private var progressValue: CGFloat {
        guard !data.steps.isEmpty else { return 0 }
        let completedCount = data.steps.filter { $0.state == .completed }.count
        return CGFloat(completedCount) / CGFloat(data.steps.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            progressBar

            HStack(alignment: .center, spacing: 16) {
                airportInfo(code: data.departureCode, city: data.departureCity)

                VStack(spacing: 4) {
                    Image(systemName: "airplane")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                    Text("직항 우선")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }
                .frame(maxWidth: .infinity)

                airportInfo(code: data.arrivalCode, city: data.arrivalCity)
            }

            dateTravelerPill

            VStack(alignment: .leading, spacing: 10) {
                ForEach(data.steps) { step in
                    HStack(spacing: 10) {
                        stepIndicator(for: step.state)
                        Text(step.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(step.state == .pending ? Color.secondary : Color.primary)
                        Spacer(minLength: 0)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
    }

    private var progressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.blue.opacity(0.15))
                Capsule()
                    .fill(Color.blue)
                    .frame(width: max(8, proxy.size.width * progressValue))
            }
        }
        .frame(height: 4)
    }

    private func airportInfo(code: String, city: String) -> some View {
        VStack(spacing: 2) {
            Text(code)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.primary)
            Text(city)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var dateTravelerPill: some View {
        HStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Text(data.dateRange)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }

            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 1.5, height: 16)

            HStack(spacing: 6) {
                Image(systemName: "person")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Text(data.travelers)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.12))
        .clipShape(Capsule())
    }

    @ViewBuilder
    private func stepIndicator(for state: StepState) -> some View {
        switch state {
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.blue)
        case .loading:
            ProgressView()
                .progressViewStyle(.circular)
                .tint(Color.blue)
                .frame(width: 16, height: 16)
        case .pending:
            Image(systemName: "circle")
                .font(.system(size: 16))
                .foregroundStyle(Color.gray.opacity(0.5))
        }
    }
}

// MARK: - Flight Results Summary
struct FlightResultsSummaryData: Hashable {
    let badgeText: String
    let heroImageName: String
    let resultCountText: String
    let priceSummaryText: String
    let routeText: String
    let dateText: String
    let cheapestLabel: String
    let airlineText: String
    let priceText: String
    let priceCaptionText: String
    let buttonTitle: String
}

struct FlightResultsSummaryCard: View {
    let data: FlightResultsSummaryData
    let onTapCTA: () -> Void

    init(
        data: FlightResultsSummaryData,
        onTapCTA: @escaping () -> Void = {}
    ) {
        self.data = data
        self.onTapCTA = onTapCTA
    }

    var body: some View {
        VStack(spacing: 0) {
            heroSection

            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(data.resultCountText) · \(data.priceSummaryText)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.primary)

                    Text("\(data.routeText) | \(data.dateText)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }

                cheapestOptionBox

                Button(action: onTapCTA) {
                    HStack(spacing: 8) {
                        Spacer(minLength: 0)
                        Text(data.buttonTitle)
                            .font(.system(size: 16, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                        Spacer(minLength: 0)
                    }
                    .foregroundStyle(Color.white)
                    .frame(height: 50)
                    .background(Color.outgoingBubble)
                    .clipShape(Capsule())
                }
            }
            .padding(16)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }

    private var heroSection: some View {
        ZStack(alignment: .topLeading) {
            Image(data.heroImageName)
                .resizable()
                .scaledToFill()
                .frame(height: 170)
                .clipped()

            LinearGradient(
                colors: [Color.white.opacity(0.0), Color.white.opacity(0.65)],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: 170)

            badgeView
                .padding(12)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
        )
    }

    private var badgeView: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.blue)
            Text(data.badgeText)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.blue)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.9))
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
    }

    private var cheapestOptionBox: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white)
                Image(systemName: "airplane")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.outgoingBubble)
            }
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(data.cheapestLabel)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Text(data.airlineText)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.primary)
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 2) {
                Text(data.priceText)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.outgoingBubble)
                Text(data.priceCaptionText)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
        }
        .padding(12)
        .background(Color(white: 0.95))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Flight Selection Sheet
struct FlightOption: Identifiable, Hashable {
    let id: UUID
    let airlineName: String
    let airlineDetail: String
    let departureTime: String
    let departureInfo: String
    let arrivalTime: String
    let arrivalInfo: String
    let flightType: String
    let duration: String
    let priceText: String
    let tags: [String]
}

struct FlightSelectionSheet: View {
    let title: String
    let options: [FlightOption]
    let onClose: () -> Void
    let onContinue: (FlightOption) -> Void

    @State private var selectedOptionID: UUID

    init(
        title: String = "항공편 선택",
        options: [FlightOption],
        onClose: @escaping () -> Void = {},
        onContinue: @escaping (FlightOption) -> Void = { _ in }
    ) {
        self.title = title
        self.options = options
        self.onClose = onClose
        self.onContinue = onContinue
        _selectedOptionID = State(initialValue: options.first?.id ?? UUID())
    }

    private var selectedOption: FlightOption? {
        options.first(where: { $0.id == selectedOptionID })
    }

    var body: some View {
        VStack(spacing: 0) {
            dragHandle

            header

            ScrollView {
                VStack(spacing: 14) {
                    ForEach(options) { option in
                        FlightOptionCard(
                            option: option,
                            isSelected: option.id == selectedOptionID
                        )
                        .onTapGesture {
                            selectedOptionID = option.id
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }

            summarySection
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 18, x: 0, y: -2)
        .ignoresSafeArea(edges: .bottom)
    }

    private var dragHandle: some View {
        Capsule()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 44, height: 5)
            .padding(.top, 10)
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity)
    }

    private var header: some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.primary)

            Spacer(minLength: 0)

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .frame(width: 32, height: 32)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    private var summarySection: some View {
        VStack(spacing: 12) {
            Divider()

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("선택한 항공편")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                    Text(selectedOption?.summaryText ?? "항공편을 선택하세요")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.primary)
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: 4) {
                    Text("총액 (성인 1명)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                    Text(selectedOption?.priceText ?? "--")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.primary)
                }
            }

            Button(action: continueAction) {
                HStack(spacing: 8) {
                    Spacer(minLength: 0)
                    Text("계속하기")
                        .font(.system(size: 16, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                    Spacer(minLength: 0)
                }
                .foregroundStyle(Color.white)
                .frame(height: 54)
                .background(Color.outgoingBubble)
                .clipShape(Capsule())
            }
            .disabled(selectedOption == nil)
            .opacity(selectedOption == nil ? 0.6 : 1.0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: -2)
    }

    private func continueAction() {
        guard let option = selectedOption else { return }
        onContinue(option)
    }
}

struct FlightOptionCard: View {
    let option: FlightOption
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            topRow

            timelineSection

            Divider()

            tagRow
        }
        .padding(16)
        .background(Color(white: 0.98))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(isSelected ? Color.outgoingBubble : Color.clear, lineWidth: 1.5)
        )
        .shadow(color: isSelected ? Color.outgoingBubble.opacity(0.18) : Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }

    private var topRow: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white)
                Image(systemName: "airplane")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.outgoingBubble)
            }
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(option.airlineName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.primary)
                Text(option.airlineDetail)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }

            Spacer(minLength: 0)

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.outgoingBubble)
            }
        }
    }

    private var timelineSection: some View {
        HStack(alignment: .top, spacing: 14) {
            timelineIndicator

            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(option.departureTime)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.primary)
                    Text(option.departureInfo)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(option.arrivalTime)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.primary)
                    Text(option.arrivalInfo)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 6) {
                Text(option.flightType)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.outgoingBubble)
                Text(option.duration)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Text(option.priceText)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.primary)
            }
        }
    }

    private var timelineIndicator: some View {
        VStack(spacing: 0) {
            Circle()
                .fill(Color.outgoingBubble)
                .frame(width: 8, height: 8)

            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 2, height: 28)

            Circle()
                .fill(Color.gray.opacity(0.6))
                .frame(width: 8, height: 8)
        }
        .padding(.top, 4)
    }

    private var tagRow: some View {
        HStack(spacing: 8) {
            ForEach(option.tags, id: \.self) { tag in
                Text(tag)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
    }
}

private extension FlightOption {
    var summaryText: String {
        "\(airlineName) · \(priceText)"
    }
}

// MARK: - Booking Form
struct SelectedFlightSummaryData: Hashable {
    let airlineName: String
    let priceText: String
    let routeText: String
    let departureCity: String
    let arrivalCity: String
    let durationText: String
}

struct BookingFormView: View {
    let selectedFlight: SelectedFlightSummaryData
    let onBack: () -> Void
    let onReviewBooking: () -> Void

    @State private var passengerName = ""
    @State private var birthDate = Date()
    @State private var nationality = "대한민국"
    @State private var passportNumber = ""
    @State private var passportExpiry = Date()
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var departureDate = Date()
    @State private var returnDate = Date().addingTimeInterval(60 * 60 * 24 * 7)
    @State private var passengerCount = 1

    private let nationalityOptions = ["대한민국", "일본", "미국", "영국", "프랑스"]

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView {
                VStack(spacing: 24) {
                    SelectedFlightSummaryCard(data: selectedFlight)

                    BookingFormSection(title: "탑승자 정보") {
                        BookingTextFieldRow(
                            title: "탑승자 이름",
                            placeholder: "여권과 동일한 이름 입력",
                            text: $passengerName
                        )
                        BookingDateFieldRow(
                            title: "생년월일",
                            date: $birthDate
                        )
                        BookingPickerRow(
                            title: "국적",
                            selection: $nationality,
                            options: nationalityOptions
                        )
                        BookingTextFieldRow(
                            title: "여권 번호",
                            placeholder: "여권 번호 입력",
                            text: $passportNumber
                        )
                        BookingDateFieldRow(
                            title: "여권 만료일",
                            date: $passportExpiry
                        )
                    }

                    BookingFormSection(title: "연락처 정보") {
                        BookingTextFieldRow(
                            title: "이메일",
                            placeholder: "example@travel.com",
                            text: $email,
                            keyboardType: .emailAddress
                        )
                        BookingTextFieldRow(
                            title: "전화번호",
                            placeholder: "+82 10-1234-5678",
                            text: $phoneNumber,
                            keyboardType: .phonePad
                        )
                    }

                    BookingFormSection(title: "예약 정보") {
                        BookingDateFieldRow(
                            title: "출발일",
                            date: $departureDate
                        )
                        BookingDateFieldRow(
                            title: "귀국일",
                            date: $returnDate
                        )
                        PassengerCountStepper(
                            title: "탑승 인원",
                            count: $passengerCount
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .background(Color.chatBackground)
        .safeAreaInset(edge: .bottom) {
            bookingCTA
        }
    }

    private var topBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.primary)
                        .frame(width: 36, height: 36)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(Circle())
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("예약 정보 입력")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.primary)
                    Text("항공편 선택 → 예약 정보 → 검토")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            Divider()
        }
        .background(Color.white)
    }

    private var bookingCTA: some View {
        VStack(spacing: 12) {
            HStack {
                Text("총 예상 금액 \(selectedFlight.priceText)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Spacer(minLength: 0)
            }

            Button(action: onReviewBooking) {
                HStack(spacing: 8) {
                    Spacer(minLength: 0)
                    Text("예약 검토하기")
                        .font(.system(size: 16, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                    Spacer(minLength: 0)
                }
                .foregroundStyle(Color.white)
                .frame(height: 54)
                .background(Color.outgoingBubble)
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: -2)
    }
}

struct SelectedFlightSummaryCard: View {
    let data: SelectedFlightSummaryData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("선택한 항공편")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.secondary)

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(data.airlineName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.primary)

                    HStack(spacing: 6) {
                        Image(systemName: "airplane")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.outgoingBubble)
                        Text(data.routeText)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.primary)
                    }

                    Text("\(data.departureCity) · \(data.arrivalCity) · \(data.durationText)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }

                Spacer(minLength: 0)

                Text(data.priceText)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.primary)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
    }
}

struct BookingFormSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.primary)

            VStack(spacing: 12) {
                content
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct BookingTextFieldRow: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.secondary)

            TextField(placeholder, text: $text)
                .font(.system(size: 15, weight: .semibold))
                .keyboardType(keyboardType)
                .padding(12)
                .background(Color(white: 0.96))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

struct BookingDateFieldRow: View {
    let title: String
    @Binding var date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.secondary)

            DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(white: 0.96))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

struct BookingPickerRow: View {
    let title: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.secondary)

            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) {
                        selection = option
                    }
                }
            } label: {
                HStack {
                    Text(selection)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.primary)
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }
                .padding(12)
                .background(Color(white: 0.96))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
}

struct PassengerCountStepper: View {
    let title: String
    @Binding var count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.secondary)

            HStack(spacing: 12) {
                Button(action: decrement) {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.primary)
                        .frame(width: 36, height: 36)
                        .background(Color(white: 0.93))
                        .clipShape(Circle())
                }
                .disabled(count <= 1)

                Text("\(count)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .frame(minWidth: 40)

                Button(action: increment) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.primary)
                        .frame(width: 36, height: 36)
                        .background(Color(white: 0.93))
                        .clipShape(Circle())
                }
            }
            .padding(10)
            .background(Color(white: 0.96))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private func decrement() {
        count = max(1, count - 1)
    }

    private func increment() {
        count += 1
    }
}

// MARK: - Hotel Recommendation Card
struct HotelAmenity: Hashable {
    let iconName: String
    let title: String
}

struct HotelRecommendationData: Hashable {
    let imageName: String
    let badgeText: String
    let hotelName: String
    let locationText: String
    let priceText: String
    let priceCaptionText: String
    let amenities: [HotelAmenity]
    let buttonTitle: String
}

struct HotelRecommendationCard: View {
    let data: HotelRecommendationData
    let onTapCTA: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            heroSection

            hotelInfoSection

            Divider()
                .padding(.horizontal, 16)

            amenitiesSection

            Divider()
                .padding(.horizontal, 16)

            Button(action: onTapCTA) {
                HStack(spacing: 8) {
                    Spacer(minLength: 0)
                    Text(data.buttonTitle)
                        .font(.system(size: 16, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                    Spacer(minLength: 0)
                }
                .foregroundStyle(Color.white)
                .frame(height: 54)
                .background(Color.outgoingBubble)
                .clipShape(Capsule())
            }
            .padding(16)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.1), radius: 14, x: 0, y: 8)
    }

    private var heroSection: some View {
        ZStack(alignment: .topTrailing) {
            Image(data.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 240)
                .clipped()

            Text(data.badgeText)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.outgoingBubble)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.92))
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
                .padding(12)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var hotelInfoSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(data.hotelName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.primary)

                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                    Text(data.locationText)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 4) {
                Text(data.priceText)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.outgoingBubble)
                Text(data.priceCaptionText)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var amenitiesSection: some View {
        HStack(spacing: 0) {
            ForEach(data.amenities.prefix(3), id: \.self) { amenity in
                VStack(spacing: 6) {
                    Image(systemName: amenity.iconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.outgoingBubble)
                    Text(amenity.title)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - Hotel Selection Sheet
struct HotelOption: Identifiable, Hashable {
    let id: UUID
    let imageName: String
    let sourceText: String
    let hotelName: String
    let ratingText: String
    let reviewCountText: String
    let locationText: String
    let stayPriceLabel: String
    let priceText: String
    let priceSuffixText: String
}

struct HotelSelectionSheet: View {
    let title: String
    let options: [HotelOption]
    let onClose: () -> Void
    let onContinue: (HotelOption) -> Void

    @State private var selectedOptionID: UUID

    init(
        title: String = "호텔 선택",
        options: [HotelOption],
        onClose: @escaping () -> Void = {},
        onContinue: @escaping (HotelOption) -> Void = { _ in }
    ) {
        self.title = title
        self.options = options
        self.onClose = onClose
        self.onContinue = onContinue
        _selectedOptionID = State(initialValue: options.first?.id ?? UUID())
    }

    private var selectedOption: HotelOption? {
        options.first(where: { $0.id == selectedOptionID })
    }

    var body: some View {
        VStack(spacing: 0) {
            dragHandle
            header

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(options) { option in
                        HotelOptionCard(
                            option: option,
                            isSelected: option.id == selectedOptionID
                        )
                        .onTapGesture {
                            selectedOptionID = option.id
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }

            bottomCTA
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 18, x: 0, y: -2)
        .ignoresSafeArea(edges: .bottom)
    }

    private var dragHandle: some View {
        Capsule()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 44, height: 5)
            .padding(.top, 10)
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity)
    }

    private var header: some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.primary)

            Spacer(minLength: 0)

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .frame(width: 32, height: 32)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    private var bottomCTA: some View {
        VStack(spacing: 12) {
            Divider()

            HStack {
                Text(selectedOption?.summaryText ?? "호텔을 선택하세요")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Spacer(minLength: 0)
            }

            Button(action: continueAction) {
                HStack(spacing: 8) {
                    Spacer(minLength: 0)
                    Text("이 호텔로 진행하기")
                        .font(.system(size: 16, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                    Spacer(minLength: 0)
                }
                .foregroundStyle(Color.white)
                .frame(height: 54)
                .background(Color.outgoingBubble)
                .clipShape(Capsule())
            }
            .disabled(selectedOption == nil)
            .opacity(selectedOption == nil ? 0.6 : 1.0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: -2)
    }

    private func continueAction() {
        guard let option = selectedOption else { return }
        onContinue(option)
    }
}

struct HotelOptionCard: View {
    let option: HotelOption
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            imageSection

            sourceBadge

            Text(option.hotelName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.primary)

            metaRow

            Divider()

            priceRow
        }
        .padding(16)
        .background(Color(white: 0.98))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(isSelected ? Color.outgoingBubble : Color.clear, lineWidth: 1.5)
        )
        .shadow(color: isSelected ? Color.outgoingBubble.opacity(0.18) : Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }

    private var imageSection: some View {
        ZStack(alignment: .topTrailing) {
            Image(option.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.outgoingBubble)
                    .padding(10)
                    .background(Color.white.opacity(0.9))
                    .clipShape(Circle())
                    .padding(10)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var sourceBadge: some View {
        Text(option.sourceText)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(Color.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.outgoingBubble)
            .clipShape(Capsule())
    }

    private var metaRow: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.outgoingBubble)
                Text("\(option.ratingText) (\(option.reviewCountText))")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }

            HStack(spacing: 4) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Text(option.locationText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }

            Spacer(minLength: 0)
        }
    }

    private var priceRow: some View {
        HStack {
            Text(option.stayPriceLabel)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.secondary)

            Spacer(minLength: 0)

            HStack(spacing: 4) {
                Text(option.priceText)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.primary)
                Text(option.priceSuffixText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
        }
    }
}

private extension HotelOption {
    var summaryText: String {
        "선택한 호텔: \(hotelName)"
    }
}

// MARK: - Hotel Booking Form
struct SelectedHotelSummaryData: Hashable {
    let imageName: String
    let hotelName: String
    let dateRangeText: String
    let priceText: String
    let priceCaptionText: String
    let locationText: String
}

struct HotelBookingFormView: View {
    let selectedHotel: SelectedHotelSummaryData
    let onBack: () -> Void
    let onProceedToReview: () -> Void

    @State private var guestName = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var checkInDate = Date()
    @State private var checkOutDate = Date().addingTimeInterval(60 * 60 * 24 * 3)
    @State private var guestCount = 1

    @State private var nightlyRateText = "₩1,200,000"
    @State private var taxAndFeesText = "₩412,000"
    @State private var totalPriceText = "₩4,012,000"

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView {
                VStack(spacing: 24) {
                    SelectedHotelSummaryCard(data: selectedHotel)

                    BookingFormSection(title: "투숙객 정보") {
                        BookingTextFieldRow(
                            title: "이름",
                            placeholder: "홍길동",
                            text: $guestName
                        )
                        BookingTextFieldRow(
                            title: "이메일",
                            placeholder: "example@travel.com",
                            text: $email,
                            keyboardType: .emailAddress
                        )
                        BookingTextFieldRow(
                            title: "전화번호",
                            placeholder: "+82 10-1234-5678",
                            text: $phoneNumber,
                            keyboardType: .phonePad
                        )
                    }

                    BookingFormSection(title: "숙박 정보") {
                        BookingDateFieldRow(
                            title: "체크인",
                            date: $checkInDate
                        )
                        BookingDateFieldRow(
                            title: "체크아웃",
                            date: $checkOutDate
                        )
                        GuestCountStepper(
                            title: "투숙 인원",
                            count: $guestCount
                        )
                    }

                    HotelPriceSummaryCard(
                        nightsText: "3박 × \(nightlyRateText)",
                        nightsPriceText: "₩3,600,000",
                        taxText: "세금 및 수수료",
                        taxPriceText: taxAndFeesText,
                        totalText: "총 금액",
                        totalPriceText: totalPriceText
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .background(Color.chatBackground)
        .safeAreaInset(edge: .bottom) {
            bottomCTA
        }
    }

    private var topBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.primary)
                        .frame(width: 36, height: 36)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(Circle())
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("호텔 예약")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.primary)
                    Text("호텔 선택 → 예약 정보 → 검토")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            Divider()
        }
        .background(Color.white)
    }

    private var bottomCTA: some View {
        VStack(spacing: 12) {
            HStack {
                Text("총 금액 \(totalPriceText)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Spacer(minLength: 0)
            }

            Button(action: onProceedToReview) {
                HStack(spacing: 8) {
                    Spacer(minLength: 0)
                    Text("예약 검토로 이동")
                        .font(.system(size: 16, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                    Spacer(minLength: 0)
                }
                .foregroundStyle(Color.white)
                .frame(height: 54)
                .background(Color.outgoingBubble)
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: -2)
    }
}

struct SelectedHotelSummaryCard: View {
    let data: SelectedHotelSummaryData

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                Image(data.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()

                LinearGradient(
                    colors: [Color.black.opacity(0.0), Color.black.opacity(0.45)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text(data.hotelName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.white)
                    Text(data.locationText)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.9))
                }
                .padding(16)
            }
            .frame(height: 200)

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(data.dateRangeText)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                    Text(data.priceText)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.primary)
                }

                Spacer(minLength: 0)

                Text(data.priceCaptionText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
            .padding(16)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
    }
}

struct GuestCountStepper: View {
    let title: String
    @Binding var count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.secondary)

            HStack(spacing: 12) {
                Text("성인")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.primary)

                Spacer(minLength: 0)

                Button(action: decrement) {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.primary)
                        .frame(width: 36, height: 36)
                        .background(Color(white: 0.93))
                        .clipShape(Circle())
                }
                .disabled(count <= 1)

                Text("\(count)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .frame(minWidth: 40)

                Button(action: increment) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.primary)
                        .frame(width: 36, height: 36)
                        .background(Color(white: 0.93))
                        .clipShape(Circle())
                }
            }
            .padding(10)
            .background(Color(white: 0.96))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private func decrement() {
        count = max(1, count - 1)
    }

    private func increment() {
        count += 1
    }
}

struct HotelPriceSummaryCard: View {
    let nightsText: String
    let nightsPriceText: String
    let taxText: String
    let taxPriceText: String
    let totalText: String
    let totalPriceText: String

    var body: some View {
        VStack(spacing: 12) {
            priceRow(title: nightsText, value: nightsPriceText, isEmphasized: false)
            priceRow(title: taxText, value: taxPriceText, isEmphasized: false)

            Divider()

            priceRow(title: totalText, value: totalPriceText, isEmphasized: true)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private func priceRow(title: String, value: String, isEmphasized: Bool) -> some View {
        HStack {
            Text(title)
                .font(.system(size: isEmphasized ? 14 : 13, weight: .semibold))
                .foregroundStyle(isEmphasized ? Color.primary : Color.secondary)
            Spacer(minLength: 0)
            Text(value)
                .font(.system(size: isEmphasized ? 18 : 14, weight: .bold))
                .foregroundStyle(isEmphasized ? Color.outgoingBubble : Color.primary)
        }
    }
}

// MARK: - Flight Booking Review
struct FlightBookingReviewData: Hashable {
    let summary: SelectedFlightSummaryData
    let routeText: String
    let dateText: String
    let passengerText: String
    let totalPriceText: String
}

struct FlightBookingReviewView: View {
    let data: FlightBookingReviewData
    let onBack: () -> Void
    let onConfirmBooking: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView {
                VStack(spacing: 24) {
                    SelectedFlightSummaryCard(data: data.summary)

                    HotelPriceTotalCard(
                        totalLabel: "총 결제 금액",
                        totalPriceText: data.totalPriceText,
                        nightCountText: "왕복 기준",
                        trustBadgeText: "안심 예약"
                    )

                    PolicyNoticeCard(
                        text: "예약 확정 전에는 무료 취소가 가능합니다. 확정 후에는 항공사 규정을 따릅니다.",
                        linkText: "이용약관 보기"
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .background(Color.chatBackground)
        .safeAreaInset(edge: .bottom) {
            bottomCTA
        }
    }

    private var topBar: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.primary)
                        .frame(width: 36, height: 36)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(Circle())
                }

                Spacer(minLength: 0)

                Text("예약 검토")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.primary)

                Spacer(minLength: 0)

                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                        .frame(width: 36, height: 36)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            Divider()
        }
        .background(Color.white)
    }

    private var bottomCTA: some View {
        VStack(spacing: 12) {
            HStack {
                Text("결제 전 마지막으로 내용을 확인하세요")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Spacer(minLength: 0)
            }

            Button(action: onConfirmBooking) {
                HStack(spacing: 8) {
                    Spacer(minLength: 0)
                    Text("예약 확정하기")
                        .font(.system(size: 16, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                    Spacer(minLength: 0)
                }
                .foregroundStyle(Color.white)
                .frame(height: 54)
                .background(Color.outgoingBubble)
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: -2)
    }
}

// MARK: - Hotel Booking Review
struct HotelBookingReviewData: Hashable {
    let hotelName: String
    let hotelDisplayName: String
    let hotelImageName: String
    let locationText: String
    let availabilityBadgeText: String
    let checkInDate: String
    let checkInNote: String
    let checkOutDate: String
    let checkOutNote: String
    let guestSummaryText: String
    let totalPriceText: String
    let nightCountText: String
    let trustBadgeText: String
    let cancellationPolicyText: String
}

struct HotelBookingReviewView: View {
    let data: HotelBookingReviewData
    let onBack: () -> Void
    let onConfirmBooking: () -> Void
    let onEditAccommodation: () -> Void
    let onEditDates: () -> Void
    let onEditGuests: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView {
                VStack(spacing: 24) {
                    HotelReviewHeroCard(
                        imageName: data.hotelImageName,
                        badgeText: data.availabilityBadgeText,
                        hotelName: data.hotelName
                    )

                    BookingDetailsSummaryCard(
                        hotelDisplayName: data.hotelDisplayName,
                        locationText: data.locationText,
                        checkInDate: data.checkInDate,
                        checkInNote: data.checkInNote,
                        checkOutDate: data.checkOutDate,
                        checkOutNote: data.checkOutNote,
                        guestSummaryText: data.guestSummaryText,
                        onEditAccommodation: onEditAccommodation,
                        onEditDates: onEditDates,
                        onEditGuests: onEditGuests
                    )

                    HotelPriceTotalCard(
                        totalLabel: "총 금액 (세금 포함)",
                        totalPriceText: data.totalPriceText,
                        nightCountText: data.nightCountText,
                        trustBadgeText: data.trustBadgeText
                    )

                    PolicyNoticeCard(
                        text: data.cancellationPolicyText,
                        linkText: "이용약관 보기"
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .background(Color.chatBackground)
        .safeAreaInset(edge: .bottom) {
            bottomCTA
        }
    }

    private var topBar: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.primary)
                        .frame(width: 36, height: 36)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(Circle())
                }

                Spacer(minLength: 0)

                Text("예약 검토")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.primary)

                Spacer(minLength: 0)

                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                        .frame(width: 36, height: 36)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            Divider()
        }
        .background(Color.white)
    }

    private var bottomCTA: some View {
        VStack(spacing: 12) {
            HStack {
                Text("결제 전 마지막으로 내용을 확인하세요")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Spacer(minLength: 0)
            }

            Button(action: onConfirmBooking) {
                HStack(spacing: 8) {
                    Spacer(minLength: 0)
                    Text("예약 확정하기")
                        .font(.system(size: 16, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                    Spacer(minLength: 0)
                }
                .foregroundStyle(Color.white)
                .frame(height: 54)
                .background(Color.outgoingBubble)
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: -2)
    }
}

struct HotelReviewHeroCard: View {
    let imageName: String
    let badgeText: String
    let hotelName: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 220)
                .clipped()

            LinearGradient(
                colors: [Color.black.opacity(0.0), Color.black.opacity(0.5)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(badgeText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.outgoingBubble.opacity(0.9))
                    .clipShape(Capsule())

                Text(hotelName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.white)
            }
            .padding(16)
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
    }
}

struct BookingDetailsSummaryCard: View {
    let hotelDisplayName: String
    let locationText: String
    let checkInDate: String
    let checkInNote: String
    let checkOutDate: String
    let checkOutNote: String
    let guestSummaryText: String
    let onEditAccommodation: () -> Void
    let onEditDates: () -> Void
    let onEditGuests: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            accommodationBlock

            Divider()

            datesBlock

            Divider()

            guestsBlock
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private var accommodationBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            ReviewSummaryHeader(title: "숙소", actionTitle: "수정", onTap: onEditAccommodation)

            Text(hotelDisplayName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.primary)

            HStack(spacing: 6) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Text(locationText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
        }
    }

    private var datesBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            ReviewSummaryHeader(title: "일정", actionTitle: "수정", onTap: onEditDates)

            HStack(spacing: 12) {
                ReviewSummaryColumn(
                    title: "체크인",
                    value: checkInDate,
                    note: checkInNote
                )

                ReviewSummaryColumn(
                    title: "체크아웃",
                    value: checkOutDate,
                    note: checkOutNote
                )
            }
        }
    }

    private var guestsBlock: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.outgoingBubble)
                .frame(width: 34, height: 34)
                .background(Color.outgoingBubble.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text("투숙 인원")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Text(guestSummaryText)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.primary)
            }

            Spacer(minLength: 0)

            Button(action: onEditGuests) {
                Text("수정")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.outgoingBubble)
            }
        }
    }
}

struct ReviewSummaryHeader: View {
    let title: String
    let actionTitle: String
    let onTap: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.secondary)
            Spacer(minLength: 0)
            Button(action: onTap) {
                Text(actionTitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.outgoingBubble)
            }
        }
    }
}

struct ReviewSummaryColumn: View {
    let title: String
    let value: String
    let note: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.secondary)
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.primary)
            Text(note)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct HotelPriceTotalCard: View {
    let totalLabel: String
    let totalPriceText: String
    let nightCountText: String
    let trustBadgeText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(totalLabel)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(totalPriceText)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.outgoingBubble)
                Text(nightCountText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }

            Text(trustBadgeText)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.green)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.12))
                .clipShape(Capsule())
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct PolicyNoticeCard: View {
    let text: String
    let linkText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.outgoingBubble)
                Text("안내")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.primary)
            }

            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.secondary)

            Button(action: {}) {
                Text(linkText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.outgoingBubble)
            }
        }
        .padding(16)
        .background(Color(white: 0.95))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Hotel Booking Confirmation Card
struct HotelBookingConfirmationData: Hashable {
    let reservationID: String
    let imageName: String
    let confirmationBadgeText: String
    let hotelName: String
    let stayDateText: String
    let totalPaidLabel: String
    let totalPaidText: String
    let paymentInfoText: String
    let paymentMethodText: String
}

struct HotelBookingConfirmedCard: View {
    let data: HotelBookingConfirmationData

    var body: some View {
        VStack(spacing: 16) {
            successHeader

            confirmationSummaryCard
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.1), radius: 14, x: 0, y: 8)
    }

    private var successHeader: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.outgoingBubble.opacity(0.12))
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Color.outgoingBubble)
            }
            .frame(width: 56, height: 56)

            Text("예약이 완료되었어요")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.primary)

            Text("예약번호: \(data.reservationID)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }

    private var confirmationSummaryCard: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                Image(data.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 190)
                    .clipped()

                Text(data.confirmationBadgeText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.outgoingBubble)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.92))
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
                    .padding(12)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            VStack(alignment: .leading, spacing: 10) {
                Text(data.hotelName)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.primary)

                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                    Text(data.stayDateText)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }

                Divider()

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(data.totalPaidLabel)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.secondary)
                        Text(data.totalPaidText)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Color.primary)
                    }

                    Spacer(minLength: 0)

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(data.paymentInfoText)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.secondary)
                        Text(data.paymentMethodText)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.outgoingBubble)
                    }
                }
            }
            .padding(16)
        }
        .background(Color(white: 0.97))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Flight Booking Confirmation Card
struct FlightBookingConfirmationData: Hashable {
    let reservationID: String
    let heroImageName: String
    let confirmationBadgeText: String
    let airlineName: String
    let routeText: String
    let dateText: String
    let passengerText: String
    let totalPaidLabel: String
    let totalPaidText: String
    let paymentInfoText: String
    let paymentMethodText: String
}

struct FlightBookingConfirmedCard: View {
    let data: FlightBookingConfirmationData

    var body: some View {
        VStack(spacing: 16) {
            successHeader

            confirmationSummaryCard
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.1), radius: 14, x: 0, y: 8)
    }

    private var successHeader: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.outgoingBubble.opacity(0.12))
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Color.outgoingBubble)
            }
            .frame(width: 56, height: 56)

            Text("항공권 예약이 완료되었어요")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.primary)

            Text("예약번호: \(data.reservationID)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }

    private var confirmationSummaryCard: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                Image(data.heroImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 170)
                    .clipped()

                VStack(alignment: .leading, spacing: 6) {
                    Text(data.routeText)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.white)
                    Text(data.airlineName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(
                    LinearGradient(
                        colors: [Color.black.opacity(0.0), Color.black.opacity(0.45)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 80)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                )

                Text(data.confirmationBadgeText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.outgoingBubble)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.92))
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
                    .padding(12)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            VStack(alignment: .leading, spacing: 10) {
                Text(data.airlineName)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.primary)

                Text(data.routeText)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.primary)

                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                    Text(data.dateText)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }

                Text(data.passengerText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)

                Divider()

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(data.totalPaidLabel)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.secondary)
                        Text(data.totalPaidText)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Color.primary)
                    }

                    Spacer(minLength: 0)

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(data.paymentInfoText)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.secondary)
                        Text(data.paymentMethodText)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.outgoingBubble)
                    }
                }
            }
            .padding(16)
        }
        .background(Color(white: 0.97))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct BookingSubmittingView: View {
    var body: some View {
        ZStack {
            Color.chatBackground.ignoresSafeArea()
            VStack(spacing: 12) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Color.outgoingBubble)
                Text("예약을 진행하고 있어요")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.primary)
                Text("잠시만 기다려주세요")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        }
    }
}




// MARK: - Trip Goal Card
// Summarizes the assistant's current understanding of the trip goal.
//
// TODO: Replace hardcoded values with real trip_goal data from backend responses.
struct TripGoalCardView: View {
    let data: TripGoalData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("여행 목표")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.primary)

            VStack(spacing: 10) {
                TripGoalRowView(
                    icon: "mappin.and.ellipse",
                    title: "목적지",
                    value: data.destination
                )
                TripGoalRowView(
                    icon: "calendar",
                    title: "기간",
                    value: data.duration
                )
                TripGoalRowView(
                    icon: "sparkles",
                    title: "스타일",
                    value: data.style
                )
            }

            if !data.notes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("메모")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 8)], alignment: .leading, spacing: 8) {
                        ForEach(data.notes, id: \.self) { note in
                            TripGoalNoteChipView(text: note)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
    }
}

// Small reusable row used inside the trip goal card.
// Displays icon + label + value in a compact summary format.
struct TripGoalRowView: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.accentColor)
                .frame(width: 28, height: 28)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.primary)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// Compact chip for trip goal notes.
struct TripGoalNoteChipView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Color.accentColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white)
            .clipShape(Capsule())
    }
}

// MARK: - Constraints Card
// Displays required conditions and softer preferences extracted from the conversation.
//
// TODO: This card does not match the current backend response structure.
// TODO: Keep for later if structured constraint data is reintroduced.
// TODO: Support dynamic wrapping for tags/chips when real constraint counts increase.
// TODO: Replace static chips with API-driven constraint data.
struct ConstraintsCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("여행 조건")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.primary)

            VStack(alignment: .leading, spacing: 8) {
                Text("필수 조건")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.secondary)

                HStack(spacing: 8) {
                    ConstraintChipView(text: "고정된 일정", icon: "calendar")
                    ConstraintChipView(text: "예산 제한", icon: "banknote")
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("선호 사항")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.secondary)

                HStack(spacing: 8) {
                    PreferenceChipView(text: "미식 중심", icon: "fork.knife")
                    PreferenceChipView(text: "여유로운 일정", icon: "leaf")
                }

                HStack(spacing: 8) {
                    PreferenceChipView(text: "경치 좋은 장소", icon: "mountain.2")
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
    }
}

// Chip used for high-priority or required constraints.
struct ConstraintChipView: View {
    let text: String
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.accentColor)
            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.accentColor)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white)
        .clipShape(Capsule())
    }
}

// Chip used for lower-priority preferences.
struct PreferenceChipView: View {
    let text: String
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.secondary)
            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.85))
        .clipShape(Capsule())
    }
}

// MARK: - Weather Card
// Shows weather summary information related to the selected trip.
//
// TODO: This card does not match the current backend response structure.
// TODO: Keep for later if structured weather data is reintroduced.
// TODO: Replace hardcoded weather values with backend weather_data.
// TODO: Decide whether this card should open a detailed forecast screen or sheet.
struct WeatherCardView: View {
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.white)
                    Text("날씨 정보")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.white)
                }

                Text("28°C")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.weatherHeader)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("대체로 맑음")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.primary)
                    Spacer()
                    Text("22°C - 28°C")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.12))
                        .clipShape(Capsule())
                }
                Text("그리스 산토리니")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.secondary)

                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.weatherTip)
                    Text("해변을 즐기기에 딱 좋아요! 선크림을 꼭 챙기세요.")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.weatherTip)
                }
                .padding(10)
                .background(Color.weatherTipBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                Button(action: {}) {
                    Text("7일 예보 보기")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(.top, 2)
            }
            .padding(16)
        }
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
    }
}

// MARK: - Planner Summary Card
// Preview card for the assistant planner output (not a day-by-day itinerary).
//
// TODO: Replace sample values with API-driven plan data.
struct PlannerSummaryCardView: View {
    let data: PlannerSummaryData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text("추천 계획")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.primary)
                Spacer()
                Text(data.tripStage)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.accentColor.opacity(0.12))
                    .clipShape(Capsule())
            }

            VStack(spacing: 10) {
                ForEach(data.steps) { step in
                    PlannerStepRowView(step: step)
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
    }
}

// Reusable row for a single planner step.
struct PlannerStepRowView: View {
    let step: PlannerStepData

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.accentColor)
                .frame(width: 28, height: 28)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.primary)
                Text(step.description)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.secondary)
                Text(step.tool)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
            }
        }
    }
}

// MARK: - Loading / Agent Progress Card
// Represents the assistant's progress while generating a response.
//
// TODO: Show and remove this card dynamically during real network requests.
// TODO: Update step states based on real processing stages if available.
struct LoadingProgressView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("여행을 계획하고 있어요")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.primary)

            VStack(spacing: 12) {
                LoadingStepView(title: "여행 의도 파악 중", status: "완료", isActive: true, isCompleted: true)
                LoadingStepView(title: "계획 생성 중", status: "진행 중", isActive: true, isCompleted: false)
                LoadingStepView(title: "결과 정리 중", status: "대기 중", isActive: false, isCompleted: false)
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
    }
}

// One progress row inside the loading card.
struct LoadingStepView: View {
    let title: String
    let status: String
    let isActive: Bool
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(isActive ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: 20, height: 20)
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.accentColor)
                } else if isActive {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 6, height: 6)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.primary)
                Text(status)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.secondary)
            }
        }
    }
}

// MARK: - Error Message Card
// Soft error card shown when a backend response fails.
struct ErrorMessageCardView: View {
    let detailMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("응답을 불러오지 못했어요")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.primary)

            if let detailMessage, !detailMessage.isEmpty {
                Text(detailMessage)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary)
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.accentColor.opacity(0.12), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}


// MARK: - Design Tokens
// Temporary local color palette for the prototype UI.
//
// TODO: Move these colors into a separate design system file if the project grows.
extension Color {
    static let headerBackground = Color(white: 0.97)
    static let chatBackground = Color(white: 0.95)
    static let outgoingBubble = Color(red: 0.0, green: 0.45, blue: 0.95)
    static let incomingBubble = Color(white: 0.9)
    static let chatText = Color(white: 0.15)
    static let cardBackground = Color(red: 0.96, green: 0.96, blue: 0.98)
    static let imagePlaceholder = Color(white: 0.9)
    static let inputBackground = Color(white: 0.94)
    static let weatherHeader = Color(red: 0.33, green: 0.67, blue: 0.89)
    static let weatherTipBackground = Color(red: 1.0, green: 0.96, blue: 0.86)
    static let weatherTip = Color(red: 0.66, green: 0.46, blue: 0.17)
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
            buttonTitle: "결과 보기"
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
            buttonTitle: "다른 호텔 보기"
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
