import SwiftUI

// MARK: - Booking step indicator (form → review → completed)

enum BookingStep: Int, CaseIterable {
    case form = 0
    case review = 1
    case completed = 2

    var title: String {
        switch self {
        case .form: return "정보 입력"
        case .review: return "검토"
        case .completed: return "완료"
        }
    }
}

struct BookingStepIndicator: View {
    let currentStep: BookingStep

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(BookingStep.allCases.enumerated()), id: \.element.rawValue) { index, step in
                stepLabel(for: step)

                if index < BookingStep.allCases.count - 1 {
                    Rectangle()
                        .fill(step.rawValue < currentStep.rawValue ? Color.outgoingBubble : Color.gray.opacity(0.2))
                        .frame(height: 2)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.white)
    }

    @ViewBuilder
    private func stepLabel(for step: BookingStep) -> some View {
        let isCompleted = step.rawValue < currentStep.rawValue
        let isCurrent = step == currentStep
        HStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(isCompleted || isCurrent ? Color.outgoingBubble : Color.gray.opacity(0.2))
                    .frame(width: 22, height: 22)
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.white)
                } else {
                    Text("\(step.rawValue + 1)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(isCurrent ? Color.white : Color.secondary)
                }
            }
            Text(step.title)
                .font(.system(size: 12, weight: isCurrent ? .bold : .semibold))
                .foregroundStyle(isCompleted ? Color.outgoingBubble : (isCurrent ? Color.primary : Color.secondary))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
    }
}

// MARK: - Journey summary chips for booking form headers

struct BookingJourneyChip: Hashable {
    let iconName: String
    let text: String
}

struct BookingJourneySummaryChips: View {
    let chips: [BookingJourneyChip]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(chips, id: \.self) { chip in
                    HStack(spacing: 6) {
                        Image(systemName: chip.iconName)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.outgoingBubble)
                        Text(chip.text)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.primary)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color.outgoingBubble.opacity(0.10))
                    .clipShape(Capsule())
                }
            }
        }
    }
}

// MARK: - Flight tag row (shared between selection / form / review / confirmation)

struct FlightTagRow: View {
    let tags: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(foreground(for: tag))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(background(for: tag))
                        .clipShape(Capsule())
                }
            }
        }
    }

    private func background(for tag: String) -> Color {
        if tag.contains("직항") { return Color.green.opacity(0.15) }
        if tag.contains("경유") { return Color.orange.opacity(0.18) }
        if tag.contains("왕복") || tag.contains("편도") { return Color.outgoingBubble.opacity(0.12) }
        return Color.gray.opacity(0.15)
    }

    private func foreground(for tag: String) -> Color {
        if tag.contains("직항") { return Color.green }
        if tag.contains("경유") { return Color.orange }
        if tag.contains("왕복") || tag.contains("편도") { return Color.outgoingBubble }
        return Color.secondary
    }
}

// MARK: - Shared booking date formatter (display)

enum BookingDisplayFormatter {
    static let shortKR: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        f.dateFormat = "M월 d일"
        return f
    }()

    static let mediumKR: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        f.dateFormat = "yyyy년 M월 d일"
        return f
    }()

    static func range(from: Date, to: Date) -> String {
        "\(shortKR.string(from: from)) - \(shortKR.string(from: to))"
    }
}

// Reusable form scaffolding shared by Flight/Hotel booking forms.

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
