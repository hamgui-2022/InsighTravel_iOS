import SwiftUI

// Preview card for the assistant planner output (not a day-by-day itinerary).
struct PlannerSummaryCardView: View {
    let data: PlannerSummaryData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text("추천 계획")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.primary)
                Spacer()
                Text(data.tripStage)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.accentColor.opacity(0.12))
                    .clipShape(Capsule())
            }

            VStack(spacing: 10) {
                ForEach(data.steps) { step in
                    PlannerStepRowView(step: step)
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
    }
}

struct PlannerStepRowView: View {
    let step: PlannerStepData

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.accentColor)
                .frame(width: 28, height: 28)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.primary)
                Text(step.description)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.secondary)
                Text(step.tool)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
            }
        }
    }
}
