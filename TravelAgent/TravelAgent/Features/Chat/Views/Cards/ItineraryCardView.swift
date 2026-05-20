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

private struct ItineraryWeatherSection: View {
    let info: ItineraryWeatherInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "cloud.sun.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.weatherHeader)
                Text(info.dateText ?? "현지 날씨")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.primary)
            }

            ForEach(info.summaryLines, id: \.self) { line in
                Text(line)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
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

private struct ItineraryTimeSlotRow: View {
    let slot: ItineraryTimeSlot

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(spacing: 0) {
                Text(slot.slot)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(width: 40, height: 28)
                    .background(slotColor)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(slot.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.primary)

                if let location = slot.location {
                    ItineraryDetailRow(icon: "mappin.and.ellipse", text: location)
                }

                if let transport = slot.transport {
                    ItineraryDetailRow(icon: "tram.fill", text: transport)
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
        switch slot.slot {
        case "오전", "아침":
            return Color(red: 0.96, green: 0.62, blue: 0.20)
        case "점심":
            return Color(red: 0.95, green: 0.45, blue: 0.30)
        case "오후":
            return Color(red: 0.33, green: 0.67, blue: 0.89)
        case "저녁", "밤":
            return Color(red: 0.42, green: 0.36, blue: 0.78)
        default:
            return Color.accentColor
        }
    }
}

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
                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.primary)
                        if let detail = event.detail {
                            Text(detail)
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

#Preview("Itinerary Card") {
    ItineraryCardView(
        data: ItineraryCardData(
            weather: ItineraryWeatherInfo(
                dateText: "5월 20일",
                summaryLines: [
                    "오전 17도 (비, 흐림, 강수확률 100%)",
                    "오후 15도 (비, 흐림, 강수확률 100%)"
                ],
                outfitTip: "비가 하루 종일 내리니 우산과 방수되는 겉옷을 준비하세요."
            ),
            timeSlots: [
                ItineraryTimeSlot(
                    slot: "오전",
                    title: "해유관",
                    location: "오사카시 미나토구",
                    transport: "난바역 → 오사카메트로 미도스지선 → 혼마치역 환승 (총 약 25분)",
                    planB: nil
                ),
                ItineraryTimeSlot(
                    slot: "오후",
                    title: "난바 지역 실내 탐방",
                    location: "난바",
                    transport: "오사카코역 → 주오선 → 미도스지선 환승 (총 약 25분)",
                    planB: "비가 잠시 그친다면 덴포잔 대관람차 탑승"
                ),
                ItineraryTimeSlot(
                    slot: "저녁",
                    title: "Sushi Making Experience Namba",
                    location: "난바",
                    transport: "난바 지역 내 도보 이동",
                    planB: "야키니쿠 호르몬 우치다 오사카"
                )
            ],
            events: [
                ItineraryEventInfo(
                    title: "도톤보리 탐방",
                    detail: "오사카 난바 지역 / 상시 진행 / 화려한 간판과 활기찬 분위기 즐기기"
                )
            ]
        )
    )
    .padding()
    .background(Color.chatBackground)
}
