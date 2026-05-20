import SwiftUI

// MARK: - Header
// Top navigation area for the chat screen.
//
// TODO: Add real actions such as profile, settings, or starting a new chat.
struct ChatHeaderView: View {
    let onMenuTap: () -> Void
    let onProfileTap: () -> Void

    var body: some View {
        ZStack {
            HStack(spacing: 8) {
                MascotAvatar(size: .small)
                Text("InsighTravel")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.primary)
            }

            HStack {
                Button(action: onMenuTap) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.primary)
                        .frame(width: 34, height: 34)
                        .background(Color.white)
                        .clipShape(Circle())
                }

                Spacer()
                Button(action: onProfileTap) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.gray)
                        .frame(width: 34, height: 34)
                        .background(Color.white)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 52)
        .background(Color.headerBackground)
    }
}
