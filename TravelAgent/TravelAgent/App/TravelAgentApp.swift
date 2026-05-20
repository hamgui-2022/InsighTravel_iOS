//
//  TravelAgentApp.swift
//  TravelAgent
//
//  Created by 이재혁 on 3/17/26.
//

import SwiftUI

@main
struct TravelAgentApp: App {
    @State private var isShowingSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()

                if isShowingSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .task {
                try? await Task.sleep(for: .seconds(1.5))
                withAnimation(.easeOut(duration: 0.45)) {
                    isShowingSplash = false
                }
            }
        }
    }
}
