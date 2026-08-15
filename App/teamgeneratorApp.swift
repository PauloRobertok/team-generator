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
    var body: some Scene {
        WindowGroup {
            GroupsView()
        }
        .modelContainer(for: [GroupGame.self, Player.self])
    }
}
