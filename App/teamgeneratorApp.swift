//
//  teamgeneratorApp.swift
//  teamgenerator
//
//  Created by Paulo Roberto on 06/05/26.
//

import SwiftUI
import SwiftData

@main
struct teamgeneratorApp: App {
    @State private var showingSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootTabView()

                if showingSplash {
                    SplashScreenView()
                        .transition(.opacity)
                }
            }
            .task {
                try? await Task.sleep(for: .seconds(1.5))
                withAnimation {
                    showingSplash = false
                }
            }
        }
        .modelContainer(for: [GroupGame.self, Player.self, GameSession.self])
    }
}
