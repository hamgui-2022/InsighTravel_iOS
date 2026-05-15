import SwiftUI

// Shows weather summary information related to the selected trip.
// Currently not used by ChatView; kept as a placeholder until structured weather_data is wired.
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
