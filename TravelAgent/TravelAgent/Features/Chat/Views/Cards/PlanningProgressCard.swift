import SwiftUI

struct PlanningProgressCardView: View {
    let data: PlanningProgressData

    private var progressValue: CGFloat {
        guard !data.steps.isEmpty else { return 0 }
        let completedCount = data.steps.filter { $0.state == .completed }.count
        let loadingCount = data.steps.filter { $0.state == .loading }.count
        let rawValue = CGFloat(completedCount) + (loadingCount > 0 ? 0.5 : 0)
        return rawValue / CGFloat(data.steps.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.12))
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.blue)
                }
                .frame(width: 38, height: 38)

                VStack(alignment: .leading, spacing: 4) {
                    Text(data.title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Color.primary)
                    Text(data.subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.secondary)
                }

                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(data.statusText)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.blue)
                    Spacer(minLength: 0)
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.blue.opacity(0.12))
                        Capsule()
                            .fill(Color.blue)
                            .frame(width: max(10, proxy.size.width * progressValue))
                    }
                }
                .frame(height: 6)
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(data.steps) { step in
                    HStack(spacing: 10) {
                        stepIndicator(for: step.state)
                        Text(step.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(step.state == .pending ? Color.secondary : Color.primary)
                        Spacer(minLength: 0)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
    }

    @ViewBuilder
    private func stepIndicator(for state: StepState) -> some View {
        switch state {
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.blue)
        case .loading:
            ProgressView()
                .progressViewStyle(.circular)
                .tint(Color.blue)
                .frame(width: 16, height: 16)
        case .pending:
            Image(systemName: "circle")
                .font(.system(size: 16))
                .foregroundStyle(Color.gray.opacity(0.5))
        }
    }
}
