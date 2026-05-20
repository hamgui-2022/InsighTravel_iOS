import SwiftUI

// MARK: - Text Message Bubble
// Reusable bubble used for plain text chat messages.
// Outgoing = user message, incoming = assistant text message.
struct MessageBubbleView: View {
    let text: String
    let isOutgoing: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isOutgoing {
                Spacer(minLength: 40)
            } else {
                MascotAvatar(size: .medium)
            }

            Text(text)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(isOutgoing ? Color.white : Color.chatText)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(isOutgoing ? Color.outgoingBubble : Color.incomingBubble)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .frame(maxWidth: 260, alignment: isOutgoing ? .trailing : .leading)

            if !isOutgoing { Spacer(minLength: 40) }
        }
    }
}
