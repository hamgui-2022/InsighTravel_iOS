import SwiftUI

// MARK: - Input Bar
// Bottom composer used to type and send a chat message.
//
// TODO: Add extra actions for the plus button.
// TODO: Consider microphone / attachment / quick prompt actions later if needed.
struct ChatInputBarView: View {
    @Binding var text: String
    let isSendEnabled: Bool
    let onSend: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 12) {
                Button(action: {}) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 30, height: 30)
                        .background(Color.white)
                        .clipShape(Circle())
                }

                TextField("메시지를 입력하세요", text: $text)
                    .font(.system(size: 15))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.inputBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                Button(action: onSend) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.white)
                        .frame(width: 32, height: 32)
                        .background(Color.accentColor)
                        .clipShape(Circle())
                }
                .disabled(!isSendEnabled)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 12)
            .background(Color.white)
        }
    }
}
