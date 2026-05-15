import SwiftUI

struct SurveyActiveCardView: View {
    let currentIndex: Int
    let answers: SurveyAnswers
    let selectionLockedValue: String?
    let onSelectOption: (String) -> Void

    var body: some View {
        let safeIndex = min(max(currentIndex, 0), SURVEY_QUESTIONS.count - 1)
        let question = SURVEY_QUESTIONS[safeIndex]

        VStack(alignment: .leading, spacing: 12) {
            Text("안녕하세요 😊 여행을 더 잘 도와드리기 위해\n간단한 질문 4가지에 먼저 답해주세요!")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.chatText)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 6) {
                ForEach(0..<SURVEY_QUESTIONS.count, id: \.self) { i in
                    Circle()
                        .fill(i <= safeIndex ? Color.surveyDotActive : Color.surveyDotIdle)
                        .frame(width: 10, height: 10)
                }
            }
            .padding(.top, 4)
            .padding(.bottom, 4)

            Text(question.question)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color(white: 0.2))
                .padding(.bottom, 2)

            VStack(spacing: 8) {
                ForEach(question.options, id: \.value) { option in
                    let isSelected = selectionLockedValue == option.value
                    Button {
                        onSelectOption(option.value)
                    } label: {
                        HStack {
                            Text(option.label)
                                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                                .foregroundStyle(isSelected ? Color.surveyOptionSelectedText : Color(white: 0.27))
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(isSelected ? Color.surveyOptionSelectedBG : Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(isSelected ? Color.surveyDotActive : Color.surveyOptionBorder, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
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
