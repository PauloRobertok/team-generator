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
    @AppStorage("appearanceMode") private var appearanceModeRaw = AppearanceMode.light.rawValue

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
            .preferredColorScheme((AppearanceMode(rawValue: appearanceModeRaw) ?? .light).colorScheme)
        }
        .modelContainer(for: [GroupGame.self, Player.self, GameSession.self])
    }
}
