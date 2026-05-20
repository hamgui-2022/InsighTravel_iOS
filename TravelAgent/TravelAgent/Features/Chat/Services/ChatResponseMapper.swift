import Foundation

// Maps ChatAPIService responses into chat-feed ChatItem cards.

func chatItems(from response: ChatResponse) -> [ChatItem] {
    var items: [ChatItem] = []

    let itineraryCard: ItineraryCardData? = {
        guard planSignalsItinerary(response.plan) else { return nil }
        return itineraryDataFrom(reply: response.reply)
    }()

    if itineraryCard == nil {
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
    }

    if let tripGoal = tripGoalFrom(response.tripGoal) {
        items.append(.tripGoal(tripGoal, id: UUID()))
    }

    if let planner = plannerSummaryFrom(response.plan) {
        items.append(.plannerSummary(planner, id: UUID()))
    }

    if let itineraryCard {
        items.append(.itinerary(itineraryCard, id: UUID()))
    }

    // planner LLM이 intent를 일정형(itinerary_planner)으로 묶어버려도, 백엔드 라우터는 plan.tools[0]만 실행한다.
    // 따라서 실제로 실행된 도구를 기준으로 카드 종류를 정한다.
    if planSignalsHotelSearch(response.plan) {
        if let hotelCard = hotelSearchCardFrom(response: response) {
            items.append(.hotelSearch(hotelCard, id: UUID()))
        }
    } else if planSignalsFlightSearch(response.plan) {
        if let flightCard = flightSearchCardFrom(response: response) {
            items.append(.flightSearch(flightCard, id: UUID()))
        }
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

// MARK: - Itinerary card

func planSignalsItinerary(_ plan: PlannerPayload?) -> Bool {
    guard let plan else { return false }
    if plan.intent == "itinerary_planner" { return true }
    return plan.tools?.first == "itinerary_planner"
}

func itineraryDataFrom(reply: String) -> ItineraryCardData? {
    let normalized = reply
        .replacingOccurrences(of: "\r\n", with: "\n")
        .replacingOccurrences(of: "\r", with: "\n")

    let blocks = normalized
        .components(separatedBy: "\n\n")
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }

    var weather: ItineraryWeatherInfo?
    var timeSlots: [ItineraryTimeSlot] = []
    var events: [ItineraryEventInfo] = []
    var inEventsSection = false

    for block in blocks {
        let lines = block
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        guard let firstLine = lines.first else { continue }

        if firstLine.contains("축제") || firstLine.contains("이벤트") || firstLine.contains("행사") {
            inEventsSection = true
            for line in lines.dropFirst() {
                events.append(parseEventLine(line))
            }
            continue
        }

        if firstLine.hasPrefix("날짜") || firstLine.hasPrefix("날씨") || firstLine.hasPrefix("옷차림") {
            weather = parseWeatherBlock(lines: lines)
            continue
        }

        if let (slotLabel, slotKind, slotTitle) = matchSlotStart(firstLine) {
            inEventsSection = false
            var location: String?
            var transport: ItineraryTransportInfo?
            var planB: String?

            for line in lines.dropFirst() {
                if let value = stripLabel(line, label: "위치") {
                    location = value
                } else if let value = stripLabel(line, label: "이동") {
                    transport = parseTransportLine(value)
                } else if let value = stripLabel(line, label: "플랜B") ?? stripLabel(line, label: "플랜 B") {
                    planB = value
                }
            }

            timeSlots.append(
                ItineraryTimeSlot(
                    slotLabel: slotLabel,
                    slotKind: slotKind,
                    title: slotTitle,
                    location: location,
                    transport: transport,
                    planB: planB
                )
            )
            continue
        }

        if inEventsSection {
            for line in lines {
                events.append(parseEventLine(line))
            }
        }
    }

    guard !timeSlots.isEmpty || weather != nil else { return nil }

    return ItineraryCardData(
        weather: weather,
        timeSlots: timeSlots,
        events: events
    )
}

// MARK: Slot parsing

private let slotKindMap: [(label: String, kind: ItinerarySlotKind)] = [
    ("오전", .morning),
    ("아침", .morning),
    ("점심", .noon),
    ("오후", .afternoon),
    ("저녁", .evening),
    ("밤", .night)
]

private func matchSlotStart(_ line: String) -> (label: String, kind: ItinerarySlotKind, title: String)? {
    // HH:MM 접두사 (예: "10:00 해유관")
    if let regex = try? NSRegularExpression(pattern: #"^(\d{1,2}:\d{2})\s+(.+)$"#),
       let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
       let timeRange = Range(match.range(at: 1), in: line),
       let titleRange = Range(match.range(at: 2), in: line) {
        let time = String(line[timeRange])
        let title = String(line[titleRange]).trimmingCharacters(in: .whitespaces)
        return (label: time, kind: .timestamp, title: title)
    }

    // 한국어 시간대 접두사 (예: "오전: 해유관" / "오전 해유관")
    for entry in slotKindMap {
        if line.hasPrefix("\(entry.label):") {
            let title = String(line.dropFirst(entry.label.count + 1)).trimmingCharacters(in: .whitespaces)
            return (entry.label, entry.kind, title.isEmpty ? line : title)
        }
        if line.hasPrefix("\(entry.label) ") {
            let title = String(line.dropFirst(entry.label.count + 1)).trimmingCharacters(in: .whitespaces)
            return (entry.label, entry.kind, title.isEmpty ? line : title)
        }
    }
    return nil
}

// MARK: Transport parsing

func parseTransportLine(_ raw: String) -> ItineraryTransportInfo {
    let legs = raw
        .components(separatedBy: " / ")
        .map { $0.trimmingCharacters(in: .whitespaces) }
        .filter { !$0.isEmpty }

    var transit: ItineraryTransportLeg?
    var taxi: ItineraryTransportLeg?

    for leg in legs {
        let isTransit = leg.hasPrefix("대중교통") || leg.hasPrefix("[대중교통]")
        let isTaxi = leg.hasPrefix("택시") || leg.hasPrefix("[택시]")

        guard isTransit || isTaxi else { continue }

        let parsed = parseTransportLeg(leg)
        if isTransit && transit == nil {
            transit = parsed
        } else if isTaxi && taxi == nil {
            taxi = parsed
        }
    }

    if transit == nil && taxi == nil {
        return ItineraryTransportInfo(transit: nil, taxi: nil, fallbackText: raw)
    }
    return ItineraryTransportInfo(transit: transit, taxi: taxi, fallbackText: nil)
}

private func parseTransportLeg(_ leg: String) -> ItineraryTransportLeg {
    var working = leg
        .replacingOccurrences(of: "[대중교통]", with: "")
        .replacingOccurrences(of: "[택시]", with: "")
    for prefix in ["대중교통", "택시"] {
        if working.hasPrefix(prefix) {
            working = String(working.dropFirst(prefix.count))
        }
    }
    working = working.trimmingCharacters(in: .whitespaces)

    // 요금: "예상 요금: 약 3,500엔" 같은 표현을 캡처
    var costText: String?
    if let regex = try? NSRegularExpression(pattern: #"예상\s*요금\s*[:：]?\s*([^)]+?)\s*(?=[)］\]]|$)"#),
       let match = regex.firstMatch(in: working, range: NSRange(working.startIndex..., in: working)),
       let range = Range(match.range(at: 1), in: working) {
        costText = String(working[range]).trimmingCharacters(in: .whitespaces)
    }

    // 소요시간: "총 약 25분" 우선, 없으면 첫 "약 N분"
    var durationText: String?
    if let regex = try? NSRegularExpression(pattern: #"총\s*약\s*([0-9]+\s*분)"#),
       let match = regex.firstMatch(in: working, range: NSRange(working.startIndex..., in: working)),
       let range = Range(match.range(at: 1), in: working) {
        durationText = "총 약 " + String(working[range])
    } else if let regex = try? NSRegularExpression(pattern: #"약\s*([0-9]+\s*분)"#),
              let match = regex.firstMatch(in: working, range: NSRange(working.startIndex..., in: working)),
              let range = Range(match.range(at: 1), in: working) {
        durationText = "약 " + String(working[range])
    }

    // 본문 설명: 마지막 괄호 블록(요금/소요시간) 제거
    var description = working
    if let regex = try? NSRegularExpression(pattern: #"\s*\([^)]*\)\s*$"#) {
        let range = NSRange(description.startIndex..., in: description)
        description = regex.stringByReplacingMatches(in: description, range: range, withTemplate: "")
    }
    description = description.trimmingCharacters(in: .whitespaces)
    if description.isEmpty {
        description = working
    }

    return ItineraryTransportLeg(
        description: description,
        durationText: durationText,
        costText: costText
    )
}

// MARK: Weather parsing

private func parseWeatherBlock(lines: [String]) -> ItineraryWeatherInfo {
    var dateText: String?
    var rawWeatherLines: [String] = []
    var outfitTip: String?

    for line in lines {
        if let value = stripLabel(line, label: "날짜") {
            dateText = value
        } else if let value = stripLabel(line, label: "날씨") {
            rawWeatherLines.append(value)
        } else if let value = stripLabel(line, label: "옷차림 팁") ?? stripLabel(line, label: "옷차림") {
            outfitTip = value
        } else {
            rawWeatherLines.append(line)
        }
    }

    let combined = rawWeatherLines.joined(separator: ", ")
    let periods = parseWeatherPeriods(from: combined)

    return ItineraryWeatherInfo(
        dateText: dateText,
        periods: periods,
        fallbackLines: periods.isEmpty ? rawWeatherLines : [],
        outfitTip: outfitTip
    )
}

private func parseWeatherPeriods(from text: String) -> [ItineraryWeatherPeriod] {
    let pattern = #"(오전|오후|아침|점심|저녁|밤)\s*(\d+)\s*도\s*\(([^)]*)\)"#
    guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }

    let range = NSRange(text.startIndex..., in: text)
    let matches = regex.matches(in: text, range: range)

    var periods: [ItineraryWeatherPeriod] = []
    for match in matches {
        guard
            let labelRange = Range(match.range(at: 1), in: text),
            let tempRange = Range(match.range(at: 2), in: text),
            let detailRange = Range(match.range(at: 3), in: text)
        else { continue }

        let label = String(text[labelRange])
        let temperatureText = "\(text[tempRange])°"
        let detail = String(text[detailRange])

        let parts = detail
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }

        var conditionParts: [String] = []
        var rainProb: String?
        for part in parts {
            if part.contains("강수") {
                rainProb = part
            } else if !part.isEmpty {
                conditionParts.append(part)
            }
        }

        periods.append(
            ItineraryWeatherPeriod(
                label: label,
                temperatureText: temperatureText,
                conditionText: conditionParts.isEmpty ? nil : conditionParts.joined(separator: ", "),
                rainProbText: rainProb
            )
        )
    }
    return periods
}

// MARK: Event parsing

private func parseEventLine(_ line: String) -> ItineraryEventInfo {
    let (title, detail) = splitTitleAndDetail(line)
    guard let detail else {
        return ItineraryEventInfo(title: title, location: nil, period: nil, memo: nil)
    }

    let parts = detail
        .components(separatedBy: " / ")
        .map { $0.trimmingCharacters(in: .whitespaces) }
        .filter { !$0.isEmpty }

    let location = parts.indices.contains(0) ? parts[0] : nil
    let period = parts.indices.contains(1) ? parts[1] : nil
    let memo: String? = parts.count > 2 ? parts[2...].joined(separator: " / ") : nil

    return ItineraryEventInfo(title: title, location: location, period: period, memo: memo)
}

// MARK: Shared helpers

private func stripLabel(_ line: String, label: String) -> String? {
    let prefix = "\(label):"
    if line.hasPrefix(prefix) {
        return String(line.dropFirst(prefix.count)).trimmingCharacters(in: .whitespaces)
    }
    return nil
}

private func splitTitleAndDetail(_ line: String) -> (String, String?) {
    if let colonRange = line.range(of: ":") {
        let title = String(line[..<colonRange.lowerBound]).trimmingCharacters(in: .whitespaces)
        let detail = String(line[colonRange.upperBound...]).trimmingCharacters(in: .whitespaces)
        if title.isEmpty {
            return (line, nil)
        }
        return (title, detail.isEmpty ? nil : detail)
    }
    return (line, nil)
}

// MARK: - Hotel & flight search cards

func planSignalsHotelSearch(_ plan: PlannerPayload?) -> Bool {
    guard let plan else { return false }
    if plan.intent == "stay_search" { return true }
    return plan.tools?.first == "stay_search"
}

func planSignalsFlightSearch(_ plan: PlannerPayload?) -> Bool {
    guard let plan else { return false }
    if plan.intent == "flight_search" { return true }
    return plan.tools?.first == "flight_search"
}

func hotelSearchCardFrom(response: ChatResponse) -> HotelSearchCardData? {
    guard planSignalsHotelSearch(response.plan) else { return nil }

    let destination = response.tripGoal?.destination ?? "숙소 목적지"
    let month = response.tripGoal?.month ?? "일정 미정"

    return HotelSearchCardData(
        title: "\(destination) 숙소 탐색",
        subtitle: "\(month) 기준으로 숙소 후보를 비교해볼 수 있어요.",
        buttonTitle: "호텔 결과 보기"
    )
}

func flightSearchCardFrom(response: ChatResponse) -> FlightSearchCardData? {
    guard planSignalsFlightSearch(response.plan) else { return nil }

    let destination = response.tripGoal?.destination ?? "항공 목적지"

    return FlightSearchCardData(
        title: "\(destination) 항공권 탐색",
        subtitle: "조건에 맞는 항공편 후보를 확인할 수 있어요.",
        buttonTitle: "항공권 보기"
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
