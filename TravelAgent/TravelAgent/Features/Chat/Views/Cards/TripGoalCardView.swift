import SwiftUI

// Summarizes the assistant's current understanding of the trip goal.
struct TripGoalCardView: View {
    let data: TripGoalData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("여행 목표")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.primary)

            VStack(spacing: 10) {
                TripGoalRowView(
                    icon: "mappin.and.ellipse",
                    title: "목적지",
                    value: data.destination
                )
                TripGoalRowView(
                    icon: "calendar",
                    title: "기간",
                    value: data.duration
                )
                TripGoalRowView(
                    icon: "sparkles",
                    title: "스타일",
                    value: data.style
                )
            }

            if !data.notes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("메모")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 8)], alignment: .leading, spacing: 8) {
                        ForEach(data.notes, id: \.self) { note in
                            TripGoalNoteChipView(text: note)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
    }
}

struct TripGoalRowView: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.accentColor)
                .frame(width: 28, height: 28)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.primary)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TripGoalNoteChipView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Color.accentColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white)
            .clipShape(Capsule())
    }
}
