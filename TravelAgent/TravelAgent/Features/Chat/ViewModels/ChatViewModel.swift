import Foundation
import SwiftUI
import Combine

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
    private let surveyService = SurveyAPIService()

    // MARK: Survey state
    @Published private(set) var surveyAnswers: SurveyAnswers = SurveyAnswers()
    @Published private(set) var surveyCurrentIndex: Int = 0
    private var surveyAnswersBySession: [String: SurveyAnswers] = [:]
    private var surveyCurrentIndexBySession: [String: Int] = [:]
    private var surveyCompletedSessions: Set<String> = []
    private var surveyCardIDBySession: [String: UUID] = [:]
    private var isSurveyTransitioning: Bool = false

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
        surveyAnswersBySession[newSession.id] = SurveyAnswers()
        surveyCurrentIndexBySession[newSession.id] = 0
        surveyAnswers = SurveyAnswers()
        surveyCurrentIndex = 0
        isSurveyTransitioning = false
        persistSessions()
        scheduleSurveyCardAppearance(for: newSession.id)
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
        surveyAnswers = surveyAnswersBySession[session.id] ?? SurveyAnswers()
        surveyCurrentIndex = surveyCurrentIndexBySession[session.id] ?? 0
        isSurveyTransitioning = false
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
        let surveyPayload = surveyDictionaryForRequest(sessionID: sessionID)

        do {
            let response = try await chatService.requestChat(
                message: text,
                sessionID: sessionID,
                context: context,
                survey: surveyPayload
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
        let historyText = recent.map { "\($0.role): \($0.text)" }.joined(separator: "\n")

        let prefix = surveyContextPrefix(for: sessionID)
        return prefix + historyText
    }

    private func surveyContextPrefix(for sessionID: String) -> String {
        guard surveyCompletedSessions.contains(sessionID),
              let answers = surveyAnswersBySession[sessionID],
              answers.isComplete else {
            return ""
        }
        return """
        [사용자 여행 성향 설문결과] \
        여행분위기:\(answers.atmosphere ?? "미정") / \
        예산스타일:\(answers.budget ?? "미정") / \
        여행우선순위:\(answers.priority ?? "미정") / \
        일정스타일:\(answers.schedule ?? "미정")

        """
    }

    private func surveyDictionaryForRequest(sessionID: String) -> [String: String]? {
        guard surveyCompletedSessions.contains(sessionID),
              let answers = surveyAnswersBySession[sessionID],
              answers.isComplete else {
            return nil
        }
        return answers.asDictionary()
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
        surveyAnswers = surveyAnswersBySession[sessionID] ?? SurveyAnswers()
        surveyCurrentIndex = surveyCurrentIndexBySession[sessionID] ?? 0
    }

    // MARK: - Survey flow

    var surveySelectedValueForCurrentQuestion: String? {
        guard surveyCurrentIndex < SURVEY_QUESTIONS.count else { return nil }
        let key = SURVEY_QUESTIONS[surveyCurrentIndex].key
        return surveyAnswers.value(forKey: key)
    }

    private func scheduleSurveyCardAppearance(for sessionID: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self,
                  self.currentSessionID == sessionID,
                  !self.surveyCompletedSessions.contains(sessionID),
                  self.surveyCardIDBySession[sessionID] == nil else {
                return
            }
            let cardID = UUID()
            self.surveyCardIDBySession[sessionID] = cardID
            self.appendItem(.surveyActive(id: cardID), sessionID: sessionID)
        }
    }

    func selectSurveyOption(value: String) {
        guard let sessionID = currentSessionID else { return }
        guard !isSurveyTransitioning else { return }
        guard surveyCurrentIndex < SURVEY_QUESTIONS.count else { return }

        let question = SURVEY_QUESTIONS[surveyCurrentIndex]
        var answers = surveyAnswersBySession[sessionID] ?? SurveyAnswers()
        answers.setValue(value, forKey: question.key)
        surveyAnswersBySession[sessionID] = answers
        surveyAnswers = answers

        isSurveyTransitioning = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) { [weak self] in
            guard let self = self else { return }
            self.isSurveyTransitioning = false
            guard self.currentSessionID == sessionID else { return }

            let nextIndex = self.surveyCurrentIndex + 1
            if nextIndex < SURVEY_QUESTIONS.count {
                self.surveyCurrentIndex = nextIndex
                self.surveyCurrentIndexBySession[sessionID] = nextIndex
            } else {
                self.surveyCurrentIndex = SURVEY_QUESTIONS.count
                self.surveyCurrentIndexBySession[sessionID] = SURVEY_QUESTIONS.count
                self.finishSurvey(sessionID: sessionID)
            }
        }
    }

    private func finishSurvey(sessionID: String) {
        guard let answers = surveyAnswersBySession[sessionID], answers.isComplete else { return }
        surveyCompletedSessions.insert(sessionID)

        if let cardID = surveyCardIDBySession[sessionID] {
            replaceItem(withID: cardID, sessionID: sessionID, newItem: .surveyCompleted(answers, id: cardID))
        }
        surveyCardIDBySession[sessionID] = nil

        Task { [weak self] in
            guard let self = self else { return }
            do {
                try await self.surveyService.submit(sessionID: sessionID, answers: answers.asDictionary())
            } catch {
                print("⚠️ Failed to submit survey: \(error)")
            }
        }
    }

    private func replaceItem(withID id: UUID, sessionID: String, newItem: ChatItem) {
        if var sessionItems = itemsBySession[sessionID],
           let index = sessionItems.firstIndex(where: { $0.id == id }) {
            sessionItems[index] = newItem
            itemsBySession[sessionID] = sessionItems
        }
        if currentSessionID == sessionID,
           let index = items.firstIndex(where: { $0.id == id }) {
            items[index] = newItem
        }
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
        guard let plan = response.plan else { return }
        let intent = plan.intent
        let firstTool = plan.tools?.first

        // 백엔드 라우터는 plan.tools[0]만 실제로 실행하므로, planner LLM이 intent를 itinerary_planner 등으로 묶어도
        // 실행 도구 기준으로 prefetch를 결정해야 빈 booking_store 응답을 피할 수 있다.
        if intent == "accommodation_booking" || firstTool == "stay_search" || intent == "stay_search" {
            await prefetchBookingItems(sessionID: sessionID, type: .hotel)
        }
        if firstTool == "flight_search" || intent == "flight_search" {
            await prefetchBookingItems(sessionID: sessionID, type: .flight)
        }
        if intent == "booking_action" || firstTool == "booking_action" {
            await prefetchBookingItems(sessionID: sessionID, type: .hotel)
            await prefetchBookingItems(sessionID: sessionID, type: .flight)
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
