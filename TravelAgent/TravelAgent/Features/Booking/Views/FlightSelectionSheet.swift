import SwiftUI

struct FlightOption: Identifiable, Hashable {
    let id: UUID
    let airlineName: String
    let airlineDetail: String
    let departureTime: String
    let departureInfo: String
    let arrivalTime: String
    let arrivalInfo: String
    let flightType: String
    let duration: String
    let priceText: String
    let tags: [String]
}

struct FlightSelectionSheet: View {
    let title: String
    let options: [FlightOption]
    let onClose: () -> Void
    let onContinue: (FlightOption) -> Void

    @State private var selectedOptionID: UUID

    init(
        title: String = "항공편 선택",
        options: [FlightOption],
        onClose: @escaping () -> Void = {},
        onContinue: @escaping (FlightOption) -> Void = { _ in }
    ) {
        self.title = title
        self.options = options
        self.onClose = onClose
        self.onContinue = onContinue
        _selectedOptionID = State(initialValue: options.first?.id ?? UUID())
    }

    private var selectedOption: FlightOption? {
        options.first(where: { $0.id == selectedOptionID })
    }

    var body: some View {
        VStack(spacing: 0) {
            dragHandle

            header

            ScrollView {
                VStack(spacing: 14) {
                    ForEach(options) { option in
                        FlightOptionCard(
                            option: option,
                            isSelected: option.id == selectedOptionID
                        )
                        .onTapGesture {
                            selectedOptionID = option.id
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }

            summarySection
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 18, x: 0, y: -2)
        .ignoresSafeArea(edges: .bottom)
    }

    private var dragHandle: some View {
        Capsule()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 44, height: 5)
            .padding(.top, 10)
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity)
    }

    private var header: some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.primary)

            Spacer(minLength: 0)

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .frame(width: 32, height: 32)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    private var summarySection: some View {
        VStack(spacing: 12) {
            Divider()

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("선택한 항공편")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                    Text(selectedOption?.summaryText ?? "항공편을 선택하세요")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.primary)
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: 4) {
                    Text("총액 (성인 1명)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                    Text(selectedOption?.priceText ?? "--")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.primary)
                }
            }

            Button(action: continueAction) {
                HStack(spacing: 8) {
                    Spacer(minLength: 0)
                    Text("계속하기")
                        .font(.system(size: 16, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                    Spacer(minLength: 0)
                }
                .foregroundStyle(Color.white)
                .frame(height: 54)
                .background(Color.outgoingBubble)
                .clipShape(Capsule())
            }
            .disabled(selectedOption == nil)
            .opacity(selectedOption == nil ? 0.6 : 1.0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: -2)
    }

    private func continueAction() {
        guard let option = selectedOption else { return }
        onContinue(option)
    }
}

struct FlightOptionCard: View {
    let option: FlightOption
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            topRow

            timelineSection

            Divider()

            FlightTagRow(tags: option.tags)
        }
        .padding(16)
        .background(Color(white: 0.98))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(isSelected ? Color.outgoingBubble : Color.clear, lineWidth: 1.5)
        )
        .shadow(color: isSelected ? Color.outgoingBubble.opacity(0.18) : Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }

    private var topRow: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white)
                Image(systemName: "airplane")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.outgoingBubble)
            }
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(option.airlineName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.primary)
                Text(option.airlineDetail)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }

            Spacer(minLength: 0)

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.outgoingBubble)
            }
        }
    }

    private var timelineSection: some View {
        HStack(alignment: .top, spacing: 14) {
            timelineIndicator

            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(option.departureTime)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.primary)
                    Text(option.departureInfo)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(option.arrivalTime)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.primary)
                    Text(option.arrivalInfo)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 6) {
                Text(option.flightType)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.outgoingBubble)
                Text(option.duration)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Text(option.priceText)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.primary)
            }
        }
    }

    private var timelineIndicator: some View {
        VStack(spacing: 0) {
            Circle()
                .fill(Color.outgoingBubble)
                .frame(width: 8, height: 8)

            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 2, height: 28)

            Circle()
                .fill(Color.gray.opacity(0.6))
                .frame(width: 8, height: 8)
        }
        .padding(.top, 4)
    }

}

private extension FlightOption {
    var summaryText: String {
        "\(airlineName) · \(priceText)"
    }
}
