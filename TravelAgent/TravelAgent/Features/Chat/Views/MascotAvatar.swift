import SwiftUI

struct MascotAvatar: View {
    enum Size {
        case xsmall
        case small
        case medium
        case large

        var dimension: CGFloat {
            switch self {
            case .xsmall: return 24
            case .small: return 32
            case .medium: return 40
            case .large: return 140
            }
        }
    }

    let size: Size
    var showsRing: Bool = false

    var body: some View {
        Image("InsighTravelMascot")
            .resizable()
            .scaledToFill()
            .frame(width: size.dimension, height: size.dimension)
            .background(Color.white)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.outgoingBubble.opacity(showsRing ? 0.35 : 0.12), lineWidth: showsRing ? 1.5 : 1)
            )
    }
}
