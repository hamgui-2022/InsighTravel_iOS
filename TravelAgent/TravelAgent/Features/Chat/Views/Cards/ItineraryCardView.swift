import SwiftUI

struct ItineraryCardView: View {
    let data: ItineraryCardData

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "map.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 28, height: 28)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                Text("추천 일정")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.primary)
            }

            if let weather = data.weather {
                ItineraryWeatherSection(info: weather)
            }

            if !data.timeSlots.isEmpty {
                VStack(spacing: 10) {
                    ForEach(data.timeSlots) { slot in
                        ItineraryTimeSlotRow(slot: slot)
                    }
                }
            }

            if !data.events.isEmpty {
                ItineraryEventsSection(events: data.events)
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
    }
}

// MARK: - Weather section

private struct ItineraryWeatherSection: View {
    let info: ItineraryWeatherInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "cloud.sun.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.weatherHeader)
                Text(info.dateText ?? "현지 날씨")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.primary)
            }

            if !info.periods.isEmpty {
                VStack(spacing: 6) {
                    ForEach(info.periods) { period in
                        ItineraryWeatherPeriodRow(period: period)
                    }
                }
            } else if !info.fallbackLines.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(info.fallbackLines, id: \.self) { line in
                        Text(line)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            if let tip = info.outfitTip {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.weatherTip)
                    Text(tip)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.weatherTip)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.weatherTipBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct ItineraryWeatherPeriodRow: View {
    let period: ItineraryWeatherPeriod

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(period.label)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.white)
                .frame(width: 36, height: 22)
                .background(Color.weatherHeader)
                .clipShape(Capsule())

            if let temp = period.temperatureText {
                Text(temp)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.primary)
            }

            if let condition = period.conditionText {
                Image(systemName: weatherIcon(for: condition))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.weatherHeader)
                Text(condition)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            if let rain = period.rainProbText {
                HStack(spacing: 4) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 10, weight: .semibold))
                    Text(rain)
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundStyle(Color.accentColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.accentColor.opacity(0.12))
                .clipShape(Capsule())
            }
        }
    }

    private func weatherIcon(for condition: String) -> String {
        if condition.contains("비") { return "cloud.rain.fill" }
        if condition.contains("눈") { return "cloud.snow.fill" }
        if condition.contains("천둥") { return "cloud.bolt.fill" }
        if condition.contains("흐림") { return "cloud.fill" }
        if condition.contains("구름") { return "cloud.sun.fill" }
        if condition.contains("맑음") { return "sun.max.fill" }
        return "cloud.sun.fill"
    }
}

// MARK: - Time slot row

private struct ItineraryTimeSlotRow: View {
    let slot: ItineraryTimeSlot

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(slot.slotLabel)
                .font(.system(size: slot.slotKind == .timestamp ? 11 : 12, weight: .bold))
                .foregroundStyle(Color.white)
                .padding(.horizontal, 8)
                .frame(minWidth: 40, minHeight: 28)
                .background(slotColor)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(slot.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.primary)

                if let location = slot.location {
                    ItineraryDetailRow(icon: "mappin.and.ellipse", text: location)
                }

                if let transport = slot.transport {
                    ItineraryTransportView(info: transport)
                }

                if let planB = slot.planB {
                    HStack(alignment: .top, spacing: 6) {
                        Text("플랜B")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.accentColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.12))
                            .clipShape(Capsule())
                        Text(planB)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var slotColor: Color {
        switch slot.slotKind {
        case .morning:
            return Color(red: 0.96, green: 0.62, blue: 0.20)
        case .noon:
            return Color(red: 0.95, green: 0.45, blue: 0.30)
        case .afternoon:
            return Color(red: 0.33, green: 0.67, blue: 0.89)
        case .evening, .night:
            return Color(red: 0.42, green: 0.36, blue: 0.78)
        case .timestamp, .other:
            return Color.accentColor
        }
    }
}

// MARK: - Transport view

private struct ItineraryTransportView: View {
    let info: ItineraryTransportInfo

    var body: some View {
        if let transit = info.transit, let taxi = info.taxi {
            VStack(spacing: 4) {
                ItineraryTransportLegRow(mode: .transit, leg: transit)
                ItineraryTransportLegRow(mode: .taxi, leg: taxi)
            }
        } else if let transit = info.transit {
            ItineraryTransportLegRow(mode: .transit, leg: transit)
        } else if let taxi = info.taxi {
            ItineraryTransportLegRow(mode: .taxi, leg: taxi)
        } else if let fallback = info.fallbackText {
            ItineraryDetailRow(icon: "tram.fill", text: fallback)
        }
    }
}

private struct ItineraryTransportLegRow: View {
    enum Mode {
        case transit, taxi

        var icon: String {
            switch self {
            case .transit: return "tram.fill"
            case .taxi: return "car.fill"
            }
        }

        var label: String {
            switch self {
            case .transit: return "대중교통"
            case .taxi: return "택시"
            }
        }
    }

    let mode: Mode
    let leg: ItineraryTransportLeg

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: mode.icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
                Text(mode.label)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.accentColor)

                if let duration = leg.durationText {
                    ItineraryChip(icon: "clock.fill", text: duration, tint: .secondary)
                }
                if let cost = leg.costText {
                    ItineraryChip(icon: "wonsign.circle.fill", text: cost, tint: .accentColor)
                }
            }

            Text(leg.description)
                .font(.system(size: 12))
                .foregroundStyle(Color.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct ItineraryChip: View {
    let icon: String
    let text: String
    let tint: Color

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .semibold))
            Text(text)
                .font(.system(size: 10, weight: .semibold))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color.white)
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(tint.opacity(0.25), lineWidth: 0.5)
        )
    }
}

// MARK: - Detail row

private struct ItineraryDetailRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.secondary)
                .frame(width: 14)
            Text(text)
                .font(.system(size: 12))
                .foregroundStyle(Color.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Events section

private struct ItineraryEventsSection: View {
    let events: [ItineraryEventInfo]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
                Text("이벤트 & 축제")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.primary)
            }

            VStack(alignment: .leading, spacing: 6) {
                ForEach(events) { event in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(event.title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.primary)

                        HStack(spacing: 6) {
                            if let location = event.location {
                                ItineraryChip(icon: "mappin.and.ellipse", text: location, tint: .secondary)
                            }
                            if let period = event.period {
                                ItineraryChip(icon: "calendar", text: period, tint: .accentColor)
                            }
                        }

                        if let memo = event.memo {
                            Text(memo)
                                .font(.system(size: 12))
                                .foregroundStyle(Color.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Itinerary Card") {
    ItineraryCardView(
        data: ItineraryCardData(
            weather: ItineraryWeatherInfo(
                dateText: "5월 20일",
                periods: [
                    ItineraryWeatherPeriod(
                        label: "오전",
                        temperatureText: "17°",
                        conditionText: "비, 흐림",
                        rainProbText: "강수확률 100%"
                    ),
                    ItineraryWeatherPeriod(
                        label: "오후",
                        temperatureText: "15°",
                        conditionText: "비, 흐림",
                        rainProbText: "강수확률 100%"
                    )
                ],
                fallbackLines: [],
                outfitTip: "비가 하루 종일 내리니 우산과 방수되는 겉옷을 준비하세요."
            ),
            timeSlots: [
                ItineraryTimeSlot(
                    slotLabel: "오전",
                    slotKind: .morning,
                    title: "해유관",
                    location: "오사카시 미나토구",
                    transport: ItineraryTransportInfo(
                        transit: ItineraryTransportLeg(
                            description: "난바역에서 오사카메트로 미도스지선 탑승 후 혼마치역 환승, 오사카코역 하차 후 도보 5분",
                            durationText: "총 약 25분",
                            costText: nil
                        ),
                        taxi: ItineraryTransportLeg(
                            description: "택시",
                            durationText: "약 20분",
                            costText: "약 3,500엔"
                        ),
                        fallbackText: nil
                    ),
                    planB: nil
                ),
                ItineraryTimeSlot(
                    slotLabel: "10:00",
                    slotKind: .timestamp,
                    title: "유니버셜 스튜디오 재팬",
                    location: "오사카시 고노하나구",
                    transport: nil,
                    planB: "비가 잠시 그친다면 덴포잔 대관람차 탑승"
                )
            ],
            events: [
                ItineraryEventInfo(
                    title: "도톤보리 탐방",
                    location: "오사카 난바 지역",
                    period: "상시 진행",
                    memo: "화려한 간판과 활기찬 분위기 즐기기"
                )
            ]
        )
    )
    .padding()
    .background(Color.chatBackground)
}
