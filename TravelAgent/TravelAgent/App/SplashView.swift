import SwiftUI

struct SplashView: View {
    @State private var mascotScale: CGFloat = 0.7
    @State private var mascotOpacity: Double = 0
    @State private var textOffset: CGFloat = 16
    @State private var textOpacity: Double = 0

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 24) {
                Image("InsighTravelMascot")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .scaleEffect(mascotScale)
                    .opacity(mascotOpacity)

                Text("InsighTravel")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.outgoingBubble)
                    .offset(y: textOffset)
                    .opacity(textOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.55)) {
                mascotScale = 1.0
                mascotOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.35)) {
                textOffset = 0
                textOpacity = 1.0
            }
        }
    }
}

#Preview {
    SplashView()
}
