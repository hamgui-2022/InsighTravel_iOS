import Foundation

// Maps ChatAPIService responses into chat-feed ChatItem cards.

func chatItems(from response: ChatResponse) -> [ChatItem] {
    var items: [ChatItem] = []

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

// MARK: - Trip goal & planner mapping

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

// MARK: - Hotel & flight search cards

func hotelSearchCardFrom(response: ChatResponse) -> HotelSearchCardData? {
    guard response.plan?.intent == "stay_search" else { return nil }

    let destination = response.tripGoal?.destination ?? "숙소 목적지"
    let month = response.tripGoal?.month ?? "일정 미정"

    return HotelSearchCardData(
        title: "\(destination) 숙소 탐색",
        subtitle: "\(month) 기준 숙소 후보예요. 예약을 진행하려면 채팅에 \"예약할게\"라고 말씀해주세요.",
        buttonTitle: "호텔 결과 보기",
        isInteractive: false
    )
}

func flightSearchCardFrom(response: ChatResponse) -> FlightSearchCardData? {
    guard response.plan?.intent == "flight_search" else { return nil }

    let destination = response.tripGoal?.destination ?? "항공 목적지"

    return FlightSearchCardData(
        title: "\(destination) 항공권 탐색",
        subtitle: "조건에 맞는 항공편 후보예요. 예약을 진행하려면 채팅에 \"예약할게\"라고 말씀해주세요.",
        buttonTitle: "항공권 보기",
        isInteractive: false
    )
}

// MARK: - Assistant reply summarization

func summarizeAssistantReply(_ reply: String, intent: String?) -> String {
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
