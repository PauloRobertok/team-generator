//
//  PreviewContainer.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 14/08/26.
//

import Foundation
import SwiftData

@MainActor
enum PreviewContainer {
    static let sample: ModelContainer = {
        let schema = Schema([GroupGame.self, Player.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])

        let players = [
            Player(name: "Sarah", gender: .female, skillLevel: .advanced),
            Player(name: "Mike", gender: .male, skillLevel: .pro),
            Player(name: "Elena", gender: .female, skillLevel: .advanced),
            Player(name: "David", gender: .male, skillLevel: .intermediate),
            Player(name: "Alex", gender: .female, skillLevel: .beginner)
        ]
        let group = GroupGame(name: "Turma do Bairro", sport: .volleyball, players: players)
        container.mainContext.insert(group)

        return container
    }()
}
