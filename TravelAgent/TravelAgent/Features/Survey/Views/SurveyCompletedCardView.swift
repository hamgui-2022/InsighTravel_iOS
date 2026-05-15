import SwiftUI

struct SurveyCompletedCardView: View {
    let answers: SurveyAnswers

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("설문이 완료됐어요! 🎉")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.chatText)

            Text("취향을 기억해서 맞춤 여행을 도와드릴게요.")
                .font(.system(size: 13))
                .foregroundStyle(Color.chatText)

            Text("분위기: \(answers.atmosphere ?? "-") / 예산: \(answers.budget ?? "-") / 중요: \(answers.priority ?? "-") / 일정: \(answers.schedule ?? "-")")
                .font(.system(size: 12))
                .foregroundStyle(Color.gray)
                .padding(.top, 2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(white: 0.88), lineWidth: 1)
        )
    }
}
