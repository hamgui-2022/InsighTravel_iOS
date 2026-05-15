import SwiftUI

// MARK: - Root Container
// ContentView is only responsible for hosting the main chat screen.
// This is a simple entry point so the preview/app launch stays clean.
struct ContentView: View {
    var body: some View {
        ChatView()
    }
}
