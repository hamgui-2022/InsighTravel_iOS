import Foundation

struct SurveyOption: Hashable {
    let icon: String
    let label: String
    let value: String
}

struct SurveyQuestion: Hashable {
    let key: String
    let question: String
    let options: [SurveyOption]
}

// Mirrors chat.html SURVEY_QUESTIONS
let SURVEY_QUESTIONS: [SurveyQuestion] = [
    SurveyQuestion(
        key: "atmosphere",
        question: "Q1. 어떤 분위기의 여행지를 선호하세요?",
        options: [
            SurveyOption(icon: "building.2.fill",         label: "도심 — 번화가, 쇼핑, 핫플레이스",  value: "도심형"),
            SurveyOption(icon: "leaf.fill",               label: "자연/시골 — 한적한 풍경, 힐링",    value: "자연형"),
            SurveyOption(icon: "equal.circle.fill",       label: "둘 다 — 도심 + 자연 적당히",       value: "복합형"),
        ]
    ),
    SurveyQuestion(
        key: "budget",
        question: "Q2. 여행 예산 스타일은?",
        options: [
            SurveyOption(icon: "wonsign.circle.fill",     label: "가성비 — 합리적인 가격으로 알차게",        value: "가성비"),
            SurveyOption(icon: "sparkles",                label: "프리미엄 — 편하고 여유롭게, 퀄리티 우선",  value: "프리미엄"),
            SurveyOption(icon: "arrow.triangle.2.circlepath", label: "유동적 — 상황에 따라 다르게",          value: "유동적"),
        ]
    ),
    SurveyQuestion(
        key: "priority",
        question: "Q3. 여행에서 가장 중요한 것은?",
        options: [
            SurveyOption(icon: "scope",                   label: "관람/경험 — 명소, 전시, 액티비티", value: "관람경험"),
            SurveyOption(icon: "fork.knife",              label: "식도락 — 맛집, 카페, 로컬 음식",   value: "식도락"),
            SurveyOption(icon: "bed.double.fill",         label: "휴식 — 느긋하게 쉬는 것 자체",     value: "휴식"),
        ]
    ),
    SurveyQuestion(
        key: "schedule",
        question: "Q4. 여행 일정 스타일은?",
        options: [
            SurveyOption(icon: "checklist",               label: "계획형 — 시간표 빼곡하게 짜고 싶어요", value: "계획형"),
            SurveyOption(icon: "water.waves",             label: "즉흥형 — 그때그때 자유롭게",            value: "즉흥형"),
            SurveyOption(icon: "calendar",                label: "중간형 — 큰 틀만 잡고 여유 있게",       value: "중간형"),
        ]
    ),
]
